/**
 * Agile Uploader
 * Copyright (c) 2010, Shift8Creative LLC http://www.shift8creative.com
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *   * Neither the name of Minerva, Shift8Creative nor the names of its 
 *     contributors may be used to endorse or promote products derived from 
 *     this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * http://opensource.org/licenses/bsd-license.php The BSD License
 * 
 * Other 3rd party libraries may carry difference licenses, please refer to those
 * library files for any such licenses. Agle Uploader is built upon open software. 
*/
package {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.display.LoaderInfo;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;	
	import flash.events.MouseEvent;
	import flash.events.*;
	import flash.ui.ContextMenuItem;
	import uint;
	
	// for external control via javascript
	import flash.external.ExternalInterface;
	
	// for form submission
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	// for making the browse button from three user defined images
	import com.efnx.GUI.button;
	
	import ru.inspirit.net.MultipartURLLoader; // A multi-part url loader class (also VERY helpful, just too bad we can't send file data with Adobe's security issues) 	
	
	// These work, but add a LOT of size to the swf and don't support things like LZW compression. out for now.
	//import com.ctyeung.WindowsBitmap.*;
	//import com.ctyeung.TIFFbaseline.*;
	
	// to customize the right click context menu
	import flash.ui.ContextMenu;
	
	// to send the flash version in the user agent
	import flash.system.Capabilities;
	
	// Magic sauce
	import com.shift8creative.AgileImage;
	import com.shift8creative.events.AgileImageResizeCompleteEvent;
	
	
	public class Main extends Sprite {
		
		public var max_width				: Number = 300;
		public var max_height				: Number = 300;
		public var preview_max_width		: Number = 300; // the preview image that is sent to JavaScript, max dimensions (helps prevent browser lockup)
		public var preview_max_height		: Number = 300;
		public var jpg_quality				: Number = 85; // JPG encode quality
		public var preview_jpg_quality		: Number = 65; // PREVIEW JPG encode quality (lower to help with encode speed and because we don't need it to be higher quality, it's not the final image)
		public var pixels_per_iteration		: Number = 128; // How many pixels per iteration - for encoding (BE CAREFUL with this setting)
		public var show_encode_progress		: Boolean = true; // The progress % for encoding will be shown next to the image name in the input field (so disable the input field and you also disable the progress)
		
		public var js_event_handler			: String = undefined; // '$.fn.agileUploaderEvent'
		public var js_get_form_data			: String = undefined; // The javascript function that gathers form data from the page to hand off to Flash to post (technically optional, but most likely used)
		
		public var form_action				: String = undefined; // The "form action" URL that you'd normally see in the HTML code (where to submit the form data to) This IS required
		public var submit_complete_input_text 		: String = ''; // The input text field's copy when submission is complete (useful for when the user is not navigated away after submitting)
		public var submit_complete_reset_progress	: Boolean = true; // Reset the progress bar on submission complete (useful when the visitor is not navigated away, it helps with the illusion of "resetting" the upload field)
		
		public var filesArray				: Array = new Array();
		public var file_limit				: Number = -1; // 0 for unlimited image attachments, -1 for a single attachment in replace mode where every file attached just replaces the previous attached file (default)
		public var file_post_var			: String = 'Filedata'; // The $_POST variable name that holds the file data (which is a base64 encoded string)
		public var encodeBarPosition		: Object = new Object();
		
		public var firebug					: Boolean = false; // Enable firebug debug messages when set true		
		public var button_up				: String = undefined;
		public var button_over				: String = undefined;
		public var button_down				: String = undefined;
		public var return_submit_response	: Boolean = false; // Enable this to return the server response from the server and pass in the js_submit_callback
		//public var flash_user_agent			: String = 'false'; // Send the User-Agent as being Flash (with version)
		public var fill_color				: String = '0xffffff'; // The background fill color for transparent images. If a png or gif has transparency and it's converted to jpg, the background color can be set (default: white). Note: this may not always matter because png and gif images may be denied or passed through to not re-size depending on other options. Can be web hex #ffffff or RGB 0xffffff
		public var file_filter				: String = '*.jpg;*.gif;*.png;*.jpeg;*.JPG;*.GIF;*.PNG;*.JPEG'; // optional file filter...Uploader can be use to pass along other images too, they just won't be resized. Note the format.
		public var file_filter_description	: String = 'Image'; // optional description that a user sees when attaching a file. Not necessary to change at all, but may be visually helpful if the file types are changed.
		public var resize					: String = 'jpg,gif,png,jpeg'; // This should be a no brainer and probably left along, but maybe someone doesn't want to resize images by some off chance..or maybe only certain types of images. Comma separate a list of extensions to be resized. Note: NO SPACES.
		public var max_post_size			: Number = 1572864; // Size limit for all attachments in bytes, optional. Deafult: 1.5mb
		
		private var _encodePercentComplete  : Number;
		private var _multiFileRef			: FileReferenceList;
		private var _fileRef				: FileReference;
		private var _fileFilter				: FileFilter;
		public var browseBtn				: button;
		
		public var file						: AgileImage;
		public var currentPostSize			: Number = 0; // in bytes
		public var fileCount				: Number = 0;
		
		public function Main ( ) {			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			_init ( ) ;
		}
		
		private function _init ( ) : void {	
			// Hide the context menu default items and give our uploader a tramp stamp. Now we can see where it's been.
			var agile_uploader_menu:ContextMenu = new ContextMenu();	
			contextMenu = agile_uploader_menu;	
			agile_uploader_menu.hideBuiltInItems();
			var title_notice:ContextMenuItem = new ContextMenuItem("Agile Uploader v3.0"); // EXTREMELY important to update this version number						
			var copyright_notice:ContextMenuItem = new ContextMenuItem("Copyright © 2011, Shift8");
			copyright_notice.enabled = false;
			agile_uploader_menu.customItems.push(title_notice, copyright_notice);
			title_notice.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:ContextMenuEvent):void {
				var url:String = 'http://www.shift8creative.com/projects/agile-uploader/index.html';
				var window:String = '_blank';
				var req:URLRequest = url is String ? new URLRequest(url) : url;
				if (!ExternalInterface.available) {
					navigateToURL(req, window);
				} else {
					var strUserAgent:String = String(ExternalInterface.call("function() {return navigator.userAgent;}")).toLowerCase();
					if (strUserAgent.indexOf("opera") != -1 || strUserAgent.indexOf("safari") != -1 || strUserAgent.indexOf("chrome") != -1 || strUserAgent.indexOf("firefox") != -1 || (strUserAgent.indexOf("msie") != -1 && uint(strUserAgent.substr(strUserAgent.indexOf("msie") + 5, 3)) >= 7)) {
						ExternalInterface.call("window.open", req.url, window);
					} else {
						navigateToURL(req, window);
					}
				}				
			} );
				
			// Load flashvars
			var paramObj:Object = LoaderInfo(this.root.loaderInfo).parameters;
			
			//ExternalInterface.call('console.dir', paramObj);
			
			if (paramObj.file_limit) { this.file_limit = Number(paramObj.file_limit); }
			if (paramObj.max_height) { this.max_height = Number(paramObj.max_height); }
			if (paramObj.max_width) { this.max_width = Number(paramObj.max_width); }
			if (paramObj.preview_max_width) { this.preview_max_width = Number(paramObj.preview_max_width); }
			if (paramObj.preview_max_height) { this.preview_max_height = Number(paramObj.preview_max_height); }
			if (paramObj.jpg_quality) { this.jpg_quality = Number(paramObj.jpg_quality); }
			if (paramObj.preview_jpg_quality) { this.preview_jpg_quality = Number(paramObj.preview_jpg_quality); }
			if (paramObj.pixels_per_iteration) { this.pixels_per_iteration = Number(paramObj.pixels_per_iteration); }
			if (paramObj.show_encode_progress) { this.show_encode_progress = this._convertToBoolean(paramObj.show_encode_progress); }
			if (paramObj.js_event_handler) { this.js_event_handler = paramObj.js_event_handler; }
			if (paramObj.js_get_form_data) { this.js_get_form_data = paramObj.js_get_form_data; }
			if (paramObj.form_action) { this.form_action = paramObj.form_action; }
			if (paramObj.firebug) { this.firebug = this._convertToBoolean(paramObj.firebug); }
			if (paramObj.file_post_var) { this.file_post_var = paramObj.file_post_var; }
			if (paramObj.submit_complete_input_text) { this.submit_complete_input_text = paramObj.submit_complete_input_text; }
			if (paramObj.submit_complete_reset_progress) { this.submit_complete_reset_progress = this._convertToBoolean(paramObj.submit_complete_reset_progress); }
			if (paramObj.button_up) { this.button_up = paramObj.button_up; }
			if (paramObj.button_over) { this.button_over = paramObj.button_over; }
			if (paramObj.button_down) { this.button_down = paramObj.button_down; }
			if (paramObj.return_submit_response) { this.return_submit_response = this._convertToBoolean(paramObj.return_submit_response); }
			if (paramObj.flash_user_agent) { this.flash_user_agent = paramObj.flash_user_agent; }
			if (paramObj.fill_color) { this.fill_color = paramObj.fill_color; }
			if (paramObj.file_filter) { this.file_filter = paramObj.file_filter; }
			if (paramObj.file_filter_description) { this.file_filter_description = paramObj.file_filter_description; }
			if (paramObj.resize) { this.resize = paramObj.resize; }
			if (paramObj.max_post_size) { this.max_post_size = Number(paramObj.max_post_size); }
			
			// Making people specify in bytes now because that's what Flash uses. Keep consistent
			// this.max_post_size = int((this.max_post_size / 1024) * 100 / 100); // <-- TO kb
			// Convert from Kb
			// this.max_post_size = int(this.max_post_size * 1024);
			
			// Setup the file filter for uploadable extensions 
			//_fileFilter = new FileFilter ( "Image", "*.jpg;*.gif;*.png;*.jpeg;*.bmp;*.tiff;*.tif" ) ;	// maybe tiff and bmp at a later date
			this._fileFilter = new FileFilter(this.file_filter_description, this.file_filter);
			
			// Setup browse button
			if (this.firebug === true) { 
				ExternalInterface.call('console.info', 'Custom browse button used from these sources: ' + this.button_up + ' (up), ' + this.button_over + ' (over), ' + this.button_down + ' (down).'); 
			}
			this.browseBtn = new button(new Array(this.button_up, this.button_over, this.button_down), _handleMouseEvent, false);
			this.browseBtn.useHandCursor = true;
			this.browseBtn.addEventListener(MouseEvent.CLICK, _handleMouseEvent);
			this.browseBtn.y = 0;
			this.browseBtn.name = 'browse';
			addChild(this.browseBtn);			
			
			// Very important: Register the JS call to send the form
			ExternalInterface.addCallback('submit', submit);
			// Also register the JS calls to remove file(s) after they are attached
			ExternalInterface.addCallback('removeFile', removeFile);
			ExternalInterface.addCallback('removeAllFiles', removeAllFiles);
		}				
		
		// Flash vars come in as strings. We need them as booleans.
		private function _convertToBoolean(value:*):Boolean {
			switch(value) {
				case "1":
				case 1:
				case "true":
				case "yes":
				case "on":
					return true;
				case "0":
				case 0:
				case "false":
				case "no":
				case "off":
				case "undefined":
				default:
					return false;
				//default:
					//return Boolean(value);
			}
		}
			
		// Handle the mouse event for the browse button
		private function _handleMouseEvent(evt:MouseEvent):void {
			switch ( String ( evt.target.name ))
			{
				case "browse" :		
					if(this.file_limit == 0) {
						_fileRef = new FileReference();
						_fileRef.browse([this._fileFilter]);
						_fileRef.addEventListener(Event.SELECT, _onImageSelect);
					} else {
						_multiFileRef = new FileReferenceList();
						_multiFileRef.browse([this._fileFilter]);
						_multiFileRef.addEventListener(Event.SELECT, _onMultiImageSelect);
					}
				break;
			}
		}
		
		/*
		 * Process multiple files that were attached.
		*/
		private function _onMultiImageSelect(evt:Event):void {
			_multiFileRef.removeEventListener(Event.SELECT, _onMultiImageSelect); // Don't need this right now (gets added again on click)
			
			var file:FileReference;
			for (var f:uint = 0; f < evt.target.fileList.length; f++) {
				file = FileReference(evt.target.fileList[f]);
				
				var _inArray:Boolean = false;
				// If the file name is already in the iamges array, that means the user already attached this file! It would be ovewritten anyway and not posted twice to the server, but we don't want all of our encoding and resizing and preview callbacks running so discard it.	 
				if (this.filesArray.length > 0) {				
					for (var key:* in this.filesArray) {
						// Some servers may see fileName.jpg and filename.jpg as two different files, but we're going to allow it. This is important also because we change extensions to lowercase, so filename.JPG and filename.jpg for example would also be caught.
						if (this.filesArray[key].fileName.toLowerCase() == file.name.toLowerCase()) {						 
							if (this.firebug === true) { 
								ExternalInterface.call('console.info', 'File was already attached, skipping.');
							}
							if (this.js_event_handler != null) {
								ExternalInterface.call(this.js_event_handler, { type: 'file_already_attached', file: this.filesArray[key] });
							}
							_inArray = true;
						}
					}				
				}
				if (_inArray === false) {				
					// No images attached yet, so run load the file so we can continue
					this.browseBtn.removeEventListener(MouseEvent.CLICK, _handleMouseEvent); // Let the image process before allowing the user to attach another
					file.load();
					file.addEventListener(Event.COMPLETE, _onDataLoaded);				
				}
			} 
		}
		
		private function _onImageSelect(evt:Event):void	{					
			_fileRef.removeEventListener(Event.SELECT, _onImageSelect); // Don't need this right now (gets added again on click)			
			
			var _inArray:Boolean = false;
			// If the file name is already in the iamges array, that means the user already attached this file! It would be ovewritten anyway and not posted twice to the server, but we don't want all of our encoding and resizing and preview callbacks running so discard it.	 
			if (this.filesArray.length > 0) {				
				for (var key:* in this.filesArray) {					
					// Some servers may see fileName.jpg and filename.jpg as two different files, but we're going to allow it. This is important also because we change extensions to lowercase, so filename.JPG and filename.jpg for example would also be caught.
					if (this.filesArray[key].fileName.toLowerCase() == evt.target.fileName.toLowerCase()) {
						if (this.firebug === true) { 
							ExternalInterface.call('console.info', 'File was already attached, skipping.');
						}
						// Technically the image hasn't "fully" attached, but it has been queued. 
						// The file could be an image still in need of resizing or it could be a large file of some other type and it's data may not be loaded yet. 
						// So the _onDataLoaded event listener is the one that actually sets encodePercent to 100 (even if there's no encoding). 
						// This encodePercent property is checked for with each file and if they are not all at 100, the form can't be submitted.
						if (this.js_event_handler != null) {
							ExternalInterface.call(this.js_event_handler, { type: 'file_already_attached', file: this.filesArray[key] });
						}
						_inArray = true;
					}
				}				
			}
			if (_inArray === false) {				
				// No images attached yet, so run load the file so we can continue
				this.browseBtn.removeEventListener(MouseEvent.CLICK, _handleMouseEvent); // Let the image process before allowing the user to attach another
				_fileRef.load();
				_fileRef.addEventListener(Event.COMPLETE, _onDataLoaded);				
			}	
		}
		
		private function _resizeComplete(evt:Event):void {
			this.currentPostSize += evt.resizedInfo.finalSize;
			//ExternalInterface.call('console.info', 'Current POST Size (after last attempted file attach): ' + this.currentPostSize);
			
			//ExternalInterface.call('console.info', this.currentPostSize);
			//ExternalInterface.call('console.info', this.max_post_size);
			
			// Remove the image from the filesArray if it doesn't fit
			if (this.currentPostSize > this.max_post_size) {
				if (this.firebug === true) {
					ExternalInterface.call('console.info', 'Max POST size limit reached (' + this.max_post_size + ' bytes).');
				}
				if (this.js_event_handler != null) {
					ExternalInterface.call(this.js_event_handler, { type: 'max_post_size_reached', file: evt.resizedInfo });
				}
				this.removeFile(evt.resizedInfo.uid);
			}
			
			//ExternalInterface.call('console.dir', this.filesArray);
		}
		
		// AFTER FILE DATA HAS LOADED -
		private function _onDataLoaded(evt:Event):void {
			//_fileRef.removeEventListener(Event.COMPLETE, _onDataLoaded); // We don't need this anymore (right now)
			this.browseBtn.addEventListener(MouseEvent.CLICK, _handleMouseEvent); // Let another file be attached
			
			var file:AgileImage = new AgileImage(FileReference(evt.target));
			//file.addEventListener(AgileImageResizeCompleteEvent.RESIZE_COMPLETE, _resizeComplete); // here? or only if theres a resize? (below)
			
			if (this.firebug === true) { 
				ExternalInterface.call('console.info', 'File data loaded for:' + file.fileName); 
				//ExternalInterface.call('console.dir', file);
			}
			
			// Encode and resize (if necessary) the image for submission			
			var resizeTypes:Array = this.resize.toLowerCase().split(',');				
			var _resize:Boolean = false;
			var currentType:String;
				// Now check to see if this is something we are going to resize
				for (var i:Number = 0; i < resizeTypes.length; i++) {	
					currentType = resizeTypes[i];				
					if (currentType.toLowerCase() == file.extension) {	
						_resize = true;
					}
				}
				
			// First check if the file limit has been reached. If not, blindly attach the file. (it could be removed though).
			if (((this.fileCount >= this.file_limit) && (this.file_limit != -1)) || (this.file_limit == 0) || (this.file_limit < -1)) {
				// Callback to notify max limit callback (number of files not total size)
				if(this.js_event_handler != null) {
					ExternalInterface.call(this.js_event_handler, { type: 'file_limit_reached', file: file });
				}
			} else {
				// A file limit of -1 is valid - it means only one file but keep replacing it (single file upload method) so empty the array and reset the count
				if (this.file_limit == -1) {
					this.filesArray = new Array();
					this.fileCount = 0;
				}
				this.filesArray.push(file);
				this.fileCount++;
				// Trigger the attach event
				if(this.js_event_handler != null) {
					ExternalInterface.call(this.js_event_handler, { type: 'attach', file: file } ); // Pass to the JS function the file name for reference (could be handy)
				}
				
			}
			
			// Now the file is either attached in its final state, or it's going to be resized.
				if (_resize === true) {
					if(this.firebug === true) {
						ExternalInterface.call('console.info', 'Resize required.'); 
					}
					//this.browseBtn.removeEventListener(MouseEvent.CLICK, _handleMouseEvent); // Wait until encoding is complete to allow another file to be attached
				
					// Set all the resize options that were passed to Flash
					var resizeOptions:Object = new Object();
					resizeOptions.jpg_quality = this.jpg_quality;
					resizeOptions.pixels_per_iteration = this.pixels_per_iteration;
					resizeOptions.max_height = this.max_height;
					resizeOptions.max_width = this.max_width;
					resizeOptions.fill_color = this.fill_color;
					resizeOptions.show_encode_progress = this.show_encode_progress;
					resizeOptions.preview_max_width = this.preview_max_width;
					resizeOptions.preview_max_height = this.preview_max_height;
					resizeOptions.preview_jpg_quality = this.preview_jpg_quality;
					
					//ExternalInterface.call('console.dir', resizeOptions);
					file.addEventListener(AgileImageResizeCompleteEvent.RESIZE_COMPLETE, _resizeComplete);
					
					// The resize complete handler (_resizeComplete) will tell us if the file doesn't fit. We don't know that yet, which is why it was blindly added.
					file.resize(resizeOptions, this.js_event_handler, this.firebug);
					
					//this.browseBtn.addEventListener(MouseEvent.CLICK, _handleMouseEvent); 
				
				} else {				
				// File is not to be resized just attach it (so long as it fits)
				
					// Add to the current post size and check to see if post limit has been reached
					this.currentPostSize += file.finalSize;	
						// If max total file size is reached, trigger callback
						if ((this.currentPostSize > this.max_post_size) && (this.js_event_handler != null)) {
							this.currentPostSize -= file.finalSize; // subtract the file that was going to be added
							if(this.js_event_handler != null) {
								ExternalInterface.call(this.js_event_handler, { type: 'max_post_size_reached', file: file } );
							}
							if (this.firebug === true) {
								ExternalInterface.call('console.info', 'Max POST size limit reached (' + this.max_post_size + ' bytes).');
							}
						} else {
				
						// AGAIN, check for file number limit and if not reached (or unlimited), attach the file (because there's asynch processes)
						// if((this.fileCount < this.file_limit) || (this.file_limit == 0) || (this.file_limit == -1)) {
							
								// There was no encoding, but something may look for it so sure the file is 100% ready/loaded/encoded
								if (this.js_event_handler != null) {
									file.percentEncoded = 100;
									ExternalInterface.call(this.js_event_handler, { type: 'progress', file: file } );
								}
								
								// There won't be a preview image, but trigger the event anyway because the JS may use it to show a generic image
								if (this.js_event_handler != null) {
									ExternalInterface.call(this.js_event_handler, { type: 'preview', file: file } );
								}
							
								// Now add the file size to the counter and check for limit	
								// (this is done after all the events are triggered and after the item is attached so it's easier to remove on both ends the front end which may use javascript and have a certain ways of dealing with removal and the flash which has a remove function too that could be called from javascript)
								// TODO: Look into this "currentFileSize" variable... is it just file.size ??
								/*if (this.firebug === true) { 
									ExternalInterface.call('console.info', 'Attached file size: ' + currentFileSize);
								}*/	
							
						/*} else {
								// Callback to notify max limit callback (number of files not total size)
								if(this.js_event_handler != null) {
									ExternalInterface.call(this.js_event_handler, { type: 'file_limit_reached', file: file });
								}
							}*/				
						}
					
				}	
			
				// Let the user know the file was attached (it technically isn't done resizing yet though)
				if (this.firebug === true) { 
					ExternalInterface.call('console.info', 'File attached, current size: (note: it could be resizing).'); 
				}
				// This event that's sent to JS can be used to disable a submit button until the image is done processing.
				//if(this.js_event_handler != null) {
				//	ExternalInterface.call(this.js_event_handler, {type: 'attach', file: file}); 
				//}
			
			
		}
		
		/**
		 * This function can be called automatically (if set) or by JavaScript.
		 * The submit() method will call this.
		 * 
		*/
		public function sendForm():void {
			// We don't want to send the form before all the images are done resizing.
			var ready:Boolean = true;
			if (this.filesArray.length > 0) {				
				for (var k:* in this.filesArray) {
					if (this.filesArray[k].percentEncoded != 100) {
						if (this.firebug === true) { 
							ExternalInterface.call('console.info', 'Can not submit form until everything has finished encoding.');
						}
						if (this.js_event_handler != null) {
							ExternalInterface.call(this.js_event_handler, { type: 'encoding_still_in_progress', file: this.filesArray[k] });
						}
						ready = false;
					}
				}				
			}
			
			// If everything has encoded and the form is ready to be submitted...
			if (ready === true) {				
				if (this.firebug === true) { 
					ExternalInterface.call('console.info', 'Trying to send form...'); 
				}
				if(this.form_action != null) {
					var ml:MultipartURLLoader = new MultipartURLLoader();
					/*if(this.ajax_headers === true) {
						ml.addHeader('X-Requested-With', 'XMLHttpRequest');
						if(this.ajax_update != null) {
							ml.addHeader('X-Update', this.ajax_update);
						}
					}*/
					/*
					if (this.flash_user_agent === true) {
						// Get the player's version by using the flash.system.Capabilities class.
						var versionNumber:String = Capabilities.version;					
						// The version number is a list of items divided by ","
						var versionArray:Array = versionNumber.split(",");
						var length:Number = versionArray.length;
						// The main version contains the OS type too so we split it in two and we'll have the OS type and the major version number separately.
						var platformAndVersion:Array = versionArray[0].split(" ");
						var majorVersion:Number = parseInt(platformAndVersion[1]);
						var minorVersion:Number = parseInt(versionArray[1]);
						var buildNumber:Number = parseInt(versionArray[2]);
						//ml.addHeader("User-Agent", "Adobe Flash Player " + majorVersion + "." + minorVersion);					
						// User-Agent ONLY available in AIR and it's set by URLRequest.userAgent = 'whatever';  anyway... Adding the header doesn't work.			
					}
					*/
				
					ml.addEventListener(Event.COMPLETE, handleSubmitComplete);
					ml.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);			
					if(this.return_submit_response === true) {
						ml.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, _handleServerResponse);
					}
					
					var form_data:String = null;
					
					// GET ALL THE DATA (if there's any other form data on the page - provided by the JS function)
					if(this.js_get_form_data != null) {
						form_data = ExternalInterface.call(this.js_get_form_data);
					}
					
					// Put the form data into URLVariables only if there's form data to do so
					if((form_data != null) && (form_data != '')) {
						//trace(form_data); // This is a string, like:  inputName=value+with+space&inputName2=value
						var form_vars:URLVariables = new URLVariables(form_data);
						
						for (var prop:* in form_vars) {
							ml.addVariable(prop, form_vars[prop]);
						}			
					}
					// Add images to POST data
					if (this.filesArray.length > 1) {					
						var i:Number = 0;
						for (var key:* in this.filesArray) {											
							ml.addFile(this.filesArray[key].data, this.filesArray[key].fileName, this.file_post_var + '['+i+']', 'image/jpeg');
							i++;
						}
					} else if(this.filesArray.length == 1) {
						ml.addFile(this.filesArray[0].data, this.filesArray[0].fileName, this.file_post_var, 'image/jpeg');
					}
				
					// Some optional info helpful for debugging
					if (this.firebug === true) {
						ExternalInterface.call('console.info', 'Posting with the following data:');
						if(form_vars) {
							ExternalInterface.call('console.dir', form_vars);
						}
						for(var key2:* in this.filesArray) {
							ExternalInterface.call('console.info', 'File: ' + this.filesArray[key2].fileName);
						}
					}
				
					// SEND DATA (if there's a place specified to send it)
					ml.load(this.form_action);
				} else {
					// No URL to post to!
					if (this.firebug === true) { 
						ExternalInterface.call('console.error', 'No URL specified to send form data to, define "form_action" variable.'); 
					}
				}
			
			}
		}		
		
		/**
		 * The submit method. 
		 * Version 2.0+ now requires all submits to be done via ExternalInterface (JS). 
		 * This cuts down on swf size.
		 * 
		*/
		public function submit():void {			
			try {
				this.sendForm();
			} catch (error:Error) { 
				trace(error); 
				if (this.firebug === true) { 
					ExternalInterface.call('console.dir', error);  
				}
			}
		}	
		
		/**
		 * This will remove an attached file
		 * 
		 * @param	uid The uid for the AgileFile object.
		*/
		public function removeFile(uid:String):void {
			if (uid != null) {
				//ExternalInterface.call('console.dir', this.filesArray);
				var i:Number = 0;
				for (var key:* in this.filesArray) {
					
					if (this.filesArray[key].uid == uid) {
						// Trigger an event so the JS knows a file was removed, it may have requested the removal, but not necessarily (it could also be from a reached file count or size limit)
						if (this.js_event_handler != null) {
							ExternalInterface.call(this.js_event_handler, { type: 'file_removed', file: this.filesArray[key] });
						}
						if(this.firebug === true) {
							ExternalInterface.call('console.info', 'Removed file: ' + this.filesArray[key].fileName + ' (' + this.filesArray[key].finalSize  + ' bytes)');
						}
						
						// subtract file size from the counter
						this.currentPostSize -= this.filesArray[key].finalSize;
						// subtract file count
						this.fileCount = this.fileCount - 1;
						// finally, drop the file from the files array
						this.filesArray.splice(key, 1);
					}
					i++;
				}
			}
		}
		
		
		/**
		 * This will remove all attached files
		 * 
		*/
		public function removeAllFiles():void {
			this.filesArray = new Array();
			this.fileCount = 0;
			if(this.firebug === true) {
				ExternalInterface.call('console.info', 'Removed all images.');
			}
			this.currentPostSize = 0; // reset the file size counter
			
			var i:Number = 0;
			for (var key:* in this.filesArray) {
				if (this.js_event_handler != null) {
					ExternalInterface.call(this.js_event_handler, { type: 'file_removed', file: this.filesArray[key] });
				}
				i++;
			}
			
		}
		
		// Event handler for http status. Will tell us things like 200 or 404 for the form action URL. 
		// Handy to let it tell JS that status but not required.
		public function httpStatusHandler(event:HTTPStatusEvent):void {
			 //trace("httpStatusHandler: " + event.status);
			 if(this.firebug === true) {
				ExternalInterface.call('console.info', 'HTTP Status Code: ' + event.status);
			 }
			 // Call the javascript status callback method to let it know the HTTP status code
			 if(this.js_event_handler != null) {
				ExternalInterface.call(this.js_event_handler, { type: 'http_status', response: event.status });
			}
		}	
		
		// Event handler for form submit complete. Will tell us if the form was submitted or not.
		// VERY handy to let it tell JS that the form submission is complete but not required.
		// The JS callback could then navigate the user to another page...Or refresh the data on the page even.
		// Flash is not steering the browser, JS does. So without telling JS the form submitted, there won't be any way of knowing when it's ok to leave the page.
		public function handleSubmitComplete(e:Event):void {
			this.filesArray = new Array(); // Clear this out on submit, it will prevent malicious submitters. If someone can somehow disable JavaScript right before submitting and the submit button is within the swf, they can keep submitting over and over. Or if they can prevent the re-direct or if there is no re-direct...Maybe the intent was to allow multiple submits without going anywhere.
			if(this.firebug === true) {
				//ExternalInterface.call('console.dir', e.data);
				ExternalInterface.call('console.info', 'Submission complete.');
			}
			// Call the js callback function (if return_submit_response is true then we'll call this below along with the server response, no need to call it twice)
			if (this.js_event_handler != null) {
				// IF this was called then the entire server response would be available include the request made... its overkill?
				//ExternalInterface.call(this.js_event_handler, { type: 'submitted', request: e });
			}
		}
		
		/**
		 *  Send back the server response to the JS.
		 * 
		 * @param	e Event data returned from server
		 */
		private function _handleServerResponse(e:Event):void {
			if (this.js_event_handler != null) {
				ExternalInterface.call(this.js_event_handler, { type: 'server_response', response: e.data });
			}
		}
		
	} // class
	
} // package