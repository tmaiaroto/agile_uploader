package com.shift8creative {

	import com.adobe.utils.IntUtil;
	import com.shift8creative.events.AgileImageResizeCompleteEvent;
	import flash.events.*;
	import flash.utils.ByteArray;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.net.FileReference;
	import flash.display.Loader;
	import GUID;
	
	// to get EXIF data -- in the future.
	//import com.patrickshyu.ExifReader;
	//import com.adobe.serialization.json;
	
	// for async encoding and events (VERY handy)
	import com.pfp.utils.*;
	import com.pfp.events.JPEGAsyncCompleteEvent;
	import flash.events.ProgressEvent;
	import Math;
	// following needed for scaling
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	//import com.dynamicflash.util.Base64; // not possible without this, takes the image and makes it a base64 string -- what happened? the next one works
	import com.jpauclair.Base64;
	import flash.external.ExternalInterface;
	import flash.events.EventDispatcher;
	[Event(name=AgileImageResizeCompleteEvent.RESIZE_COMPLETE, type="com.shift8creative.events.AgileImageResizeCompleteEvent")]


	/**
	 * This class is responsible for all of the image objects that Agile Uploader uses.
	 * The object contains the image binary data along with various properties, most importantly of which is the uid.
	 * 
	 * @author Tom Maiaroto
	 */
	public class AgileImage extends EventDispatcher {
		
		public var uid 				: String;
		public var fileName 		: String;
		public var extension 		: String;
		public var size 			: Number;
		public var finalSize		: Number;
		public var data 			: ByteArray;
		public var created 			: Date;
		public var base64Thumbnail 	: String;
		public var firebug			: Boolean = false;
		public var bytesLoaded		: Number;
		public var bytesTotal		: Number;
		public var percentEncoded	: Number;
		
		private var _loader					: Loader;
		private var _bitmap					: Bitmap;
		private var _imageByteArray			: ByteArray;
		private var _resizeOptions			: Object;
		private var _jsEventHandler			: String;
		private var _encodePercentComplete  : Number;
		
		public function AgileImage(file:FileReference) {
			//ExternalInterface.call('console.dir', file);
			
			// TODO: Set EXIF information too
			// Get the EXIF data and send to JavaScript function if set
			/*if(this.js_exif_callback != null) {
				var reader:ExifReader = new ExifReader();
				reader.localLoad(tempFileRef.data);						
				ExternalInterface.call(js_exif_callback, JSON.encode(reader.getAllValues()));	
			}*/
			
			this.uid = GUID.create();
			this.fileName = file.name;
			this.size = file.size;
			this.finalSize = file.size;
			this.data = file.data;
			this.created = file.creationDate;
		
			var extMatch:RegExp = /\.([^\.]+)$/i;
			var matches:Object = extMatch.exec(file.name);
			for( var j:String in matches ) {				
				//ExternalInterface.call('console.info', matches[i]);
				this.extension = matches[1];
				this.extension = this.extension.toLowerCase(); // important. otherwise capitalized extension images wouldn't match to be resized later on
			}
			
		}
		
		// GETTERS AND SETTERS ---------------------------------------------
		
		public function getByteArray():ByteArray {
			return this._imageByteArray;
		}
		
		public function getResizeOptions():Array {
			return this._resizeOptions;
		}
		
		// PUBLIC RESIZE METHODS --------------------------------------------------
		
		/**
		 *  Encodes and resizes the image
		 * 
		 * @param	options An array of resize options
		 */
		public function resize(options:Object, jsEventHandler:String, debug:Boolean):void {
			// Set the options for encoding
			this._resizeOptions = options;
			this._resizeOptions.fill_color = this._formatColorCode(this._resizeOptions.fill_color);
			
			// Set the firebug setting for debugging or not
			this.firebug = debug;
			
			// Set the callbacks
			this._jsEventHandler = jsEventHandler;
			
			// Images can only be resized to jpg, so change the file name (and extension?? JS needs the extension and it may be displayed to the user, so it could be confusing if its not the same as originally attached)
			var extensionLength:Number = this.extension.length;
			this.fileName = this.fileName.substr(0,(this.fileName.length - extensionLength)) + 'jpg';
			
			// Load the file's data
			_loader = new Loader ( ) ;
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onImageLoaded);
			_loader.loadBytes(this.data);
		}
		
		// PRIVATE CLASS METHODS --------------------------------------------------
		
		/**
		 * Encodes and resizes the image.
		 * TODO: Maybe move the image.bitmapData to this.bitmapData ...?
		 * 
		 * @param	image The image bitmap
		 */
		private function _encodeAndResize(image:Bitmap):void {		
			if (this.firebug === true) {
				ExternalInterface.call('console.info', 'Encoding with quality ' + this._resizeOptions.jpg_quality + ' at ' + this._resizeOptions.pixels_per_iteration + ' pixels per iteration.');
			}
			
			var jpgEncoder:JPEGAsyncVectorEncoder = new JPEGAsyncVectorEncoder(this._resizeOptions.jpg_quality); 
   			jpgEncoder.PixelsPerIteration = this._resizeOptions.pixels_per_iteration; // This option can allow us to process faster or slower (default is actually 128 anyway in the encoder class)
			
			// Add some helpful (and required) event listeners
			// The JPEGAsyncVectorEncoder can't return the ByteArray until it's done, it's async 
			// So it's available in the complete handler unlike the normal Adobe encoder (code above)
			jpgEncoder.addEventListener(JPEGAsyncCompleteEvent.JPEGASYNC_COMPLETE, _handleEncodeComplete);
			jpgEncoder.addEventListener(ProgressEvent.PROGRESS, _jpegProgressHandler);
		    if ( image.width > this._resizeOptions.max_width || image.height > this._resizeOptions.max_height ) {			
				if (this.firebug === true) { 
					ExternalInterface.call('console.info', 'A resize was necessary to fit into ' + this._resizeOptions.max_width + 'x' + this._resizeOptions.max_height + '.'); 
				}
				jpgEncoder.encode(this._resizeBitmapData(image, this._resizeOptions.max_width, this._resizeOptions.max_height, false, this._resizeOptions.fill_color));
			} else {
				if (this.firebug === true) { 
					ExternalInterface.call('console.info', 'No resize was necessary.'); 
				}
				jpgEncoder.encode(image.bitmapData); // No resize necessary, just encode
			}			
		}	
		
		/**
		 * SUPER handy function for resizing a bitmap, returns BitmapData
		 * 
		 * @param	theImage
		 * @param	rW
		 * @param	rH
		 * @param	transparent
		 * @param	fillColor
		 * @return
		 */
		private function _resizeBitmapData(theImage:Bitmap, rW:Number, rH:Number, transparent:Boolean = true, fillColor:uint = 0xffffff):BitmapData {
			var img:Bitmap = new Bitmap(theImage.bitmapData);
			//trace('resize bitmap : ' + img.height + '-' + img.width);
			//trace('resize bitmap : ' + rH + '-' + rW);
			if (img.width > img.height) {
					if (img.height>rH)
						rH = img.height * (rW / img.width);
					else{ // do not resize
						rH = img.height;
						rW = img.width;
					}
			}
			else {
				if (img.width>rW)
					rW = img.width * (rH / img.height);
				else{ // do not resize
						rH = img.height;
						rW = img.width;
					}				
			}			
			var bmpData:BitmapData = new BitmapData(rW, rH, transparent, fillColor);
			var scaleMatrix:Matrix = new Matrix( rW / img.width , 0, 0, rH / img.height, 0,0);
			var colorTransform:ColorTransform = new ColorTransform();
			bmpData.draw(theImage, scaleMatrix , colorTransform, null, null, true);
			return (bmpData);
		}
		
		// Handy function to format the color code properly, can pass 0x000000 format or web hex #000000 format
		private function _formatColorCode(color:String):String {
			var submittedColor:String = color;
			var validColor:String;
			var pattern:RegExp = /#/;
			submittedColor = color.replace(pattern,"");
			pattern = /0x/;
			if (submittedColor.substring(0,2) != "0x") {
				validColor = "0x"+submittedColor;
			} else {
				validColor = submittedColor;
			}
			return validColor;
		}
		
		/**
		 * In cases where the original image ends up being smaller than the thumbnail size, just send
		 * the original image as the preview. 
		 * 
		*/
		private function _sendOriginalAsPreview():void {
			if (this._jsEventHandler != null) {
				// Set the preview (just base64 encode the actual image that was provided)
				var base64String:String = Base64.encode(this._imageByteArray);
				this.base64Thumbnail = 'data:image/jpg;base64,' + base64String;
				
				// Send the preview to the JS
				if (this._jsEventHandler != null) {
					ExternalInterface.call(this._jsEventHandler, { type: 'preview', file: this } );
				}
			}
		}
		
		// LISTENERS -------------------------------------------------------
		
		/**
		 * Once the image is loaded, we can show it as a preview, but also now is a good time to start encoding and resizing if necessary
		 * 
		 * @param	evt 
		 */
		private function _onImageLoaded(evt:Event):void {	
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _onImageLoaded); // remove, it'll be added again of course
			_bitmap = Bitmap(evt.target.content);
			_bitmap.smoothing = true;
			
			// Does _bitmap have to be global?
			this._imageByteArray = this._encodeAndResize(this._bitmap);
		}
		
		/**
		 * Event handler for image encoding.
		 * We're going to replace the image data, provide the new final size, and send off some events
		 * so that the JS knows what happened.
		 * 
		 * @param	event JPEGAsyncCompleteEvent
		 */
		private function _handleEncodeComplete(event:JPEGAsyncCompleteEvent):void {
			// Here's the magic! Replace the image date with the resized image data
			this.data = event.ImageData;
			
			// Even though we replace the image data, we're going to make a new finalSize property in case we need to compare things or something
			this.finalSize = Number(event.ImageData.length);
			
			 // In case sending "this" becomes a problem
			/*var encodedFile:Object = new Object();
			encodedFile.fileName = this.fileName;
			encodedFile.finalSize = this.finalSize;
			encodedFile.uid = this.uid;
			encodedFile.size = this.size;
			encodedFile.data = this.data;
			encodedFile.created = this.created;
			encodedFile.base64Thumbnail = this.base64Thumbnail; // it will be null. the thumbnail is being generated and will be given to he JS in a separate event
			encodedFile.bytesLoaded = this.bytesLoaded;
			encodedFile.bytesTotal = this.bytesTotal;
			encodedFile.percentEncoded = this.percentEncoded;*/
			
			//ExternalInterface.call('console.dir', encodedFile);
			this.dispatchEvent(new AgileImageResizeCompleteEvent(this));
			
			this._imageByteArray = event.ImageData; // Image data is available now, so set it
			
			if (this.firebug === true) {
				ExternalInterface.call('console.info', 'Image encoding complete. Final file size (in Kb): ' + int( (this._imageByteArray.length / 1024)*100 ) /100 );
			}
			// If not showing the progress, still let JS know it's 100% complete because it could be waiting on the event.
			if ((this._resizeOptions.show_encode_progress === false) && (this._jsEventHandler != null)) {
				this.percentEncoded = 100;
				ExternalInterface.call(this._jsEventHandler, { type: 'progress', file: this } );
			}
			
			// Set the preview thumbnail image
			var previewSet:Boolean = false;
				if (this._jsEventHandler != null) {		
					// If the resized image's max dimensions are the SAME as the preview's max dimensions (default), why re-encode? Just use the image that was encoded already. It's faster/instant.
					/* 
					// possible DUPLICATE check and call (see below)
					if ((this._resizeOptions.preview_max_width == this._resizeOptions.max_width) && (this._resizeOptions.preview_max_height == this._resizeOptions.max_height)) {

						if (this.firebug === true) { ExternalInterface.call('console.info', 'No resize was necessary for the preview image (preview image max dimensions are the exact same as resized main image\'s, using main image for preview).'); }
						// #OK - fix the rest
						
						previewSet = true; // so we know we have it
						if (this._jsEventHandler != null) {
							// This sends off an event and uses the original image as the thumbnail
							this._sendOriginalAsPreview();
						}
					} */
				
					// If we can't re-use the main resized image and the preview max dimensions aren't larger than what was attached, scale it down.
					if ( (previewSet === false) && (this._bitmap.width > this._resizeOptions.preview_max_width || this._bitmap.height > this._resizeOptions.preview_max_height) ) {

						if (this.firebug === true) { ExternalInterface.call('console.info', 'A resize was necessary for the preview image to fit into ' + this._resizeOptions.preview_max_width + 'x' + this._resizeOptions.preview_max_height + '.'); }
						
						// Double encoding! There's nothing we can do about it. Converting BitmapData to ByteArray requires an encoder.
						// It's not so bad because it should encode REALLY fast since it should be set to a small size (default 300x300).
						// Do we need progress callback? The preview encoding complete callback is there just in case the user MUST see a preview image, but do we care about percentage?
						var jpgPreviewEncoder:JPEGAsyncVectorEncoder = new JPEGAsyncVectorEncoder(this._resizeOptions.preview_jpg_quality);
						
						var previewBitmapData:BitmapData = this._resizeBitmapData(this._bitmap, this._resizeOptions.preview_max_width, this._resizeOptions.preview_max_height, false, this._resizeOptions.fill_color);
						jpgPreviewEncoder.encode(previewBitmapData);
						jpgPreviewEncoder.addEventListener(JPEGAsyncCompleteEvent.JPEGASYNC_COMPLETE, _handlePreviewEncodeComplete);
						previewSet = true; // this isn't necessarily true if the encoding fails, but I think it'll be ok because it's only used to skip the next condition
					} 
				
					// If it hasn't been set yet, but the uploaded image is actually smaller than or equal to the preview image dimensions, then use the already encoded image.
					if ( (previewSet === false) && (this._bitmap.width <= this._resizeOptions.preview_max_width) && (this._bitmap.height <= this._resizeOptions.preview_max_height) ) {
						if (this.firebug === true) { 
							ExternalInterface.call('console.info', 'No resize was necessary for the preview image (attached image was smaller than preview max dimensions, using main image for preview).'); 
						}
						
						// This sends off an event and uses the original image as the thumbnail
						if (this._jsEventHandler != null) {
							this._sendOriginalAsPreview();
						}
					}				
				}		
		}
		
		// Event handler for the preview jpeg encoding
		private function _handlePreviewEncodeComplete(event:JPEGAsyncCompleteEvent):void {		
			var base64String:String = Base64.encode(event.ImageData);
			this.base64Thumbnail = 'data:image/jpg;base64,' + base64String;
			if (this._jsEventHandler != null) {
				ExternalInterface.call(this._jsEventHandler, { type: 'preview', file: this } );
			}	
		}
		
		private function _jpegProgressHandler(event:ProgressEvent):void {
			if (this._resizeOptions.show_encode_progress === true) {			
				this._encodePercentComplete = Math.round((event.bytesLoaded / event.bytesTotal) * 100);	
				
				this.percentEncoded = this._encodePercentComplete.toString();
				this.bytesLoaded = event.bytesLoaded;
				this.bytesTotal = event.bytesTotal;
				
				if (this._jsEventHandler != null) {
					ExternalInterface.call(this._jsEventHandler, { type: 'progress', file: this } );
				}
			}
			
		}
		
		// END CLASS
	}
	
	// END PACKAGE
}