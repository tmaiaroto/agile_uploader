(function($) {
	var opts;
	var noURI;
	
	/**
	 * Agile Uploader Event Handler
	 * This method is responsible for catching all of the events coming from the swf.
	 * Every event will have a type and some sort of data. Mostly this includes the entire
	 * file object that was last attached, but some events return responses from the server.
	 *
	 * @param event {object} The event object from Flash
	*/
	$.fn.agileUploaderEvent = function(event) {
		//console.info('EVENT TRIGGERED: ' + event.type);
		switch(event.type) {
			case 'attach':
				$.fn.agileUploaderAttachFile(event.file);
				break;
			case 'progress':
				$.fn.agileUploaderCurrentEncodeProgress(event.file);
				break;
			case 'preview':
				$.fn.agileUploaderPreview(event.file);
				break;
			case 'file_removed':
				$.fn.agileUploaderDetachFile(event.file);
				break;
			case 'server_response':
				// this one is different, it doesn't get the file data, it gets the server response
				$.fn.agileUploaderServerResponse(event.response);
				break;
			case 'http_status':
				// this one is also gets the server response
				$.fn.agileUploaderHttpResponse(event.response);
				break;
			case 'max_post_size_reached':
				$.fn.agileUploaderMaxPostSize(event.file);
				break;
			case 'file_limit_reached':
				$.fn.agileUploaderFileLimit(event.file);
				break;
			case 'preview':
				$.fn.agileUploaderPreview(event.file);
				break;
			case 'file_already_attached':
				$.fn.agileUploaderFileAlreadyAttached(event.file);
				break;
			case 'encoding_still_in_progress':
				$.fn.agileUploaderNotReady(event.file);
				break;
		}
	}
	
	/**
	 * Serializes the form data to be submitted to the server.
	 *
	 * @return Serialized form data or false if the form is empty
	*/
	$.fn.agileUploaderSerializeFormData = function() {		
		if((typeof(opts.formId) == 'string') && ($('#'+opts.formId).length > 0)) {			
			return $('#'+opts.formId).serialize();		
		}
		return false;
	}

	/**
	 * Visually adds the thumbnail to the list of attached files when it's available.
	 * If it isn't an image file type or isn't returned in the file object, a default icon will be used.
	 *
	 * @param file {object} The file object
	 * @see $.fn.agileUploaderCurrentEncodeProgress
	 * @see $.fn.agileUploaderEvent
	*/
	$.fn.agileUploaderPreview = function(file) {
		if((typeof(file.base64Thumbnail) != 'undefined') && (noURI !== true) && (file.base64Thumbnail != null)) {			
			$('#id-'+file.uid+' .agileUploaderFilePreview').html('<img src="'+file.base64Thumbnail+'" />');
		} else {
			$('#id-'+file.uid+' .agileUploaderFilePreview').html('<img src="'+opts.genericFileIcon+'" />');
		}
		// adjust the file size
		var sizeKb = ((file.finalSize / 1024) * 100) / 100;
		$('#id-'+file.uid+' .agileUploaderFileSize').text('('+ sizeKb.toFixed(2) +'Kb)');
	}
	
	/**
	 * Callback after the form is submitted and data is returned from the server.
	 * The data returned will vary depending on the script used, defined in the "form_action" variable.
	 * If there's a "submit_reidrect" then the user will be redirected.
	 *
	 * @param response {mixed} The server response
	*/
	$.fn.agileUploaderServerResponse = function(response) {
		// If there's a div to put the return response data into, do so
		if(typeof(opts.updateDiv) == 'string') {
			$(opts.updateDiv).empty();
			$(opts.updateDiv).append(response);
		}		
		// Re-direct or empty the list so another submission can be made
		if(typeof(opts.submitRedirect) == 'string') {
			window.location = opts.submitRedirect;
		} else {			
			$('#agileUploaderFileList').empty();
		}
	}
	
	/**
	 * This callback is given the HTTP response code.
	 * Note the response is passed in as a string.
	 * 
	 * @param response {string} The HTTP response code
	*/
	$.fn.agileUploaderHttpResponse = function(response) {
		if(response == "200") {
			$('#agileUploaderRemoveAll').empty();
		}
	}
	
	/**
	 * This event is called when there's still an image file encoding.
	 * The form can't be sent until everything is ready, otherwise, images could
	 * pass on to the server at original size.
	 * 
	 * @param file {string} The file object that hasn't completed encoding yet
	*/
	$.fn.agileUploaderNotReady = function(file) {
		$("#agileUploaderMessages").show();
		$('#agileUploaderMessages').text(opts.notReadyMessage);
		clearTimeout();
		setTimeout('$("#agileUploaderMessages").fadeOut()', 3000);
	}
	
	/**
	 * Visually adds files to a list and shows their file name, thumbnail, progress, and delete button.
	 *
	 * @param file {object} The file object
	 * @see $.fn.agileUploaderCurrentEncodeProgress
	 * @see $.fn.agileUploaderEvent
	*/
	$.fn.agileUploaderAttachFile = function(file) {
		/*console.info('---');
		console.dir(file);
		console.info('---');*/
		// if in single file replace mode just empty the list visually, only the last attached file will be submitted by flash (rare, this shouldn't be w/ multiple uploads)
		if(opts.flashVars.file_limit == -1) { 			
			$('#agileUploaderFileList').empty();
		}
		$("#agileUploaderInfo").animate({ scrollTop: $("#agileUploaderInfo").attr("scrollHeight") }, opts.attachScrollSpeed);
		var alt = '';
		if ($('#agileUploaderFileList li').size() % 2 == 0) { alt = 'alt'; } 
		$('#agileUploaderFileList').append('<li id="id-'+file.uid+'" class="'+alt+'"><div class="agileUploaderFilePreview" style="display: none;"></div><div class="agileUploaderFileName" style="display: none;">'+file.fileName+'</div><div id="'+file.uid+'CurrentProgress" class="agileUploaderCurrentProgress"></div><div class="agileUploaderFileSize" style="display: none;"></div><div class="agileUploaderRemoveFile" style="display:none;"><a href="#" id="remove-'+file.uid+'" onClick="document.getElementById(\'agileUploaderSWF\').removeFile(\''+file.uid+'\'); return false;"><img class="agileUploaderRemoveIcon" src="'+opts.removeIcon+'" alt="remove" /></a></div></li>');
		// Check for IE, change css special for IE.
		if(/msie/i.test(navigator.userAgent) && !/opera/i.test(navigator.userAgent) === true) {
			$('#id-'+file.uid).css('height', opts.flashVars.preview_max_height+5);
		} else {
			$('#id-'+file.uid).css('height', opts.flashVars.preview_max_height);
		}		
		
		// If using a bar, the background gets the value of opts.progressBar, it can be '#123456' or 'url:("image.jpg")'  ... NOTE: no ending ;
		if((typeof(opts.progressBar) == 'string') && (opts.progressBar != 'percent')) {
			$('#'+file.uid+'CurrentProgress').css('background', opts.progressBarColor);
		}
		
		$('#agileUploaderFileInputText').val(file.fileName);
	}	
	
	/**
	 * Visually shows the percentage of each file as it's being resized and encoded.
	 * The progress bar was put onto the page from the attach method.
	 *
	 * @param file {object} The entire file object which also includes the progress.
	 * @see $.fn.agileUploaderAttachFile
	 * @see $.fn.agileUploaderEvent
	*/
	$.fn.agileUploaderCurrentEncodeProgress = function(file) {
		//console.info(parseInt(file.percentEncoded));
		if(opts.progressBar == 'percent') {				
			$('#'+file.uid+'CurrentProgress').text(parseInt(file.percentEncoded)+'%');
		} else {				
			$('#'+file.uid+'CurrentProgress').css('width', parseInt(file.percentEncoded)+'%');
			$('#agileUploaderProgressBar').css('width', parseInt(file.percentEncoded)+'%');
		}
		
		if(file.percentEncoded >= 100) {
			$('#'+file.uid+'CurrentProgress').remove();
			// add the file size
			var sizeKb = ((file.finalSize / 1024) * 100) / 100;
			$('#id-'+file.uid+' .agileUploaderFileSize').text('('+ sizeKb.toFixed(2) +'Kb)');
			
			$('.agileUploaderFileName, .agileUploaderRemoveFile, .agileUploaderFileSize, .agileUploaderFilePreview').show();
			// add remove all
			$('#agileUploaderRemoveAll').html('<a href="#" onClick="document.getElementById(\'agileUploaderSWF\').removeAllFiles(); $(\'#agileUploaderFileList\').empty(); $(\'#agileUploaderRemoveAll\').empty(); return false;">'+opts.removeAllText+'</a>');
		}
	}
	
	/**
	 * Visually removes the file from the attached files list.
	 * This only happens when Flash fires the 'filed_removed' event, so we are certain it's gone.
	 *
	 * @param file {object} The entire file object
	 * @see $.fn.agileUploaderEvent
	*/
	$.fn.agileUploaderDetachFile = function(file) {
		$('#id-'+file.uid).remove();
		if($('#agileUploaderFileList li').length < 1) {
			$('#agileUploaderRemoveAll').empty();
		}
	}
	
	/**
	 * Called when a duplicate file is attached.
	 * This just allows us to notify the user that they already attached the file.
	 * Purely for user experience.
	 *
	 * @param file {object} The file object of what was added twice
	*/
	$.fn.agileUploaderFileAlreadyAttached = function(file) {
		$("#agileUploaderMessages").show();
		$('#agileUploaderMessages').text(opts.duplicateFileMessage);
		clearTimeout();
		setTimeout('$("#agileUploaderMessages").fadeOut()', 3000);
	}
	
	/**
	 * Called when the maximum POST size (the combined total file size of all files) is reached.
	 * The last file trying to be attached will be returned to this method.
	 *
	 * @param file {object} The file object
	*/
	$.fn.agileUploaderMaxPostSize = function(file) {
		$('#id-'+file.uid).remove(); // in case the row was visually added because it had a progress bar (it's already removed in Flash, well, it was never added actually)
		$("#agileUploaderMessages").show();
		$('#agileUploaderMessages').text(opts.maxPostSizeMessage);
		clearTimeout();
		setTimeout('$("#agileUploaderMessages").fadeOut()', 3000);
	}
	
	/**
	 * Called when the maximum number of files has been reached.
	 * The last file trying to be attached will be returned to this method.
	 *
	 * @param file {object} The file object
	*/
	$.fn.agileUploaderFileLimit = function(file) {		
		$('#id-'+file.uid).remove(); // in case the row was visually added because it had a progress bar		
		$("#agileUploaderMessages").show();
		$('#agileUploaderMessages').text(opts.maxFileMessage);
		//clearTimeout();
		//setTimeout('$("#agileUploaderMessages").fadeOut()', 3000);
	}

	/**
	 * Main method that embeds the Agile Uploader to handle multiple files.
	 * (multiple file mode)
	 * 
	*/
	$.fn.agileUploader = function(options) {			
		opts = $.extend({}, $.fn.agileUploader.defaults, options);    
		opts.flashVars = $.extend({}, $.fn.agileUploader.defaults.flashVars, options.flashVars);    
		opts.flashParams = $.extend({}, $.fn.agileUploader.defaults.flashParams, options.flashParams);
		opts.flashAttributes = $.extend({}, $.fn.agileUploader.defaults.flashAttributes, options.flashAttributes);
		
		return this.each(function() {
			// We know IE6 & IE7 don't have data URI support
			if ($.browser.msie && (parseInt($.browser.version) < 8)) { 
				noURI = true; 
			} else {
				// If it's another browser, test data URI support
				var data = new Image();
				data.onload = data.onerror = function(){
					if(this.width != 1 || this.height != 1) {				
						noURI = true;
					}
				}
				data.src = "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==";
			}
			// end data uri check
	
			$('#'+this.id).append('<div id="agileUploaderAttachArea"><div id="agileUploaderEMBED"></div><div id="agileUploaderMessages"></div></div>');
			
			$.fn.agileUploaderEmbed(); // embed
			
			// Add the file queue list
			$('#'+this.id).prepend('<div id="agileUploaderRemoveAll"></div><div id="agileUploaderInfo"><ul id="agileUploaderFileList"></ul></div>');
		});	
	}
	
	/**
	 * Main method that embeds the Agile Uploader to handle a single file.
	 * (single file mode)
	 * 
	*/
	$.fn.agileUploaderSingle = function(options) {
		if(typeof(options) == 'undefined') { 
			var options = {};
		}
		// change around defaults for this	
		delete $.fn.agileUploader.defaults.flashVars.button_up;
		delete $.fn.agileUploader.defaults.flashVars.button_over;
		delete $.fn.agileUploader.defaults.flashVars.button_down;
		$.fn.agileUploader.defaults.flashWidth = 110;
		$.fn.agileUploader.defaults.flashHeight = 25;
		$.fn.agileUploader.defaults.flashVars.show_encode_progress = true;
		// combine everything together
		opts = $.extend({}, $.fn.agileUploader.defaults, options);		
		if(typeof(options.flashVars) == 'undefined') { options.flashVars = {}; }
		opts.flashVars = $.extend({}, $.fn.agileUploader.defaults.flashVars, options.flashVars);
		if(typeof(options.flashParams) == 'undefined') { options.flashParams = {}; }
		opts.flashParams = $.extend({}, $.fn.agileUploader.defaults.flashParams, options.flashParams);
		if(typeof(options.flashAttributes) == 'undefined') { options.flashAttributes = {}; }
		opts.flashAttributes = $.extend({}, $.fn.agileUploader.defaults.flashAttributes, options.flashAttributes);
		// always set to -1 so it goes into a single replace mode
		opts.flashVars.file_limit = -1; 
		
		return this.each(function() {
			$('#'+this.id).append('<div id="agileUploaderAttachArea"><div id="agileUploaderInfoContainer"><input id="agileUploaderFileInputText" type="text" /><div id="agileUploaderProgressBar"></div></div><div id="agileUploaderEMBED"></div><div id="agileUploaderMessages" class="agileUploaderSingleMessages"></div></div>');
			$.fn.agileUploaderEmbed(); // embed
			$('#agileUploaderProgressBar').css('background', opts.progressBarColor);
		});
	}

	$.fn.agileUploaderEmbed = function() {
		// Breaks up cache. When redirecting back to the page that embeds the swf, some browsers will have a problem. Randomizing the name seems to help.
		var flashSrcCacheBust=opts.flashSrc+'?'+Math.floor(Math.random()*9999+1);
		
		// Embed with jQuery Flash if available
		if(typeof($().flash) == 'function') {	
			$('#agileUploaderEMBED').flash({
				// As always; all settings are entirely optional.
			    id: "agileUploaderSWF", 
			    width: opts.flashWidth,
			    height: opts.flashHeight,
			    src: flashSrcCacheBust,
			    flashvars: opts.flashVars,
			    bgcolor: '#fff',
			    quality: 'high',
			    wmode: 'transparent',
			    allowscriptaccess: 'always',
			    classid: 'clsid:D27CDB6E-AE6D-11cf-96B8-444553540000', // For IE support.
			    codebase: 'http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=', // Ditto.
			    pluginspace: 'http://get.adobe.com/flashplayer', // Download Firefox plugin if missing.
			    version: '10.0.0'		
		     });
		} else 	{		
			// Embed the swf using swfobject (if swfobject is available)
			if(typeof(swfobject) != 'undefined') {
				swfobject.embedSWF(flashSrcCacheBust, 'agileUploaderEMBED', opts.flashWidth, opts.flashHeight, "10.0.0","expressInstall.swf", opts.flashVars, opts.flashParams, opts.flashAttributes);
			} else {
				$('#agileUploaderEMBED').html('<p>You need to have either swfobject or jquery flash in order to embed.</p>');
			}
		}
	}
		
	$.fn.agileUploaderSubmit = function() {
		document.getElementById('agileUploaderSWF').submit();
	}
	
	$.fn.agileUploader.defaults = {
		// First the Flash embed size and Flashvars (which is another object which makes it easy)
		flashSrc: 'agile-uploader.swf',
		flashWidth: 25,
		flashHeight: 22,
		flashParams: {allowscriptaccess: 'always'},
		flashAttributes: {id: "agileUploaderSWF"},
		flashVars: {
			max_height: 500,
			max_width: 500,
			jpg_quality: 85, 
			preview_max_height: 50,
			preview_max_width: 50,
			show_encode_progress: true,
			js_get_form_data: '$.fn.agileUploaderSerializeFormData',
			js_event_handler: '$.fn.agileUploaderEvent',
			return_submit_response: true,
			file_filter: '*.jpg;*.jpeg;*.gif;*.png;*.JPG;*.JPEG;*.GIF;*.PNG;*.zip',
			file_filter_description: 'Files',
			// max post size is in bytes (note: all file size values are in bytes)
			max_post_size: (1536 * 1024),
			file_limit: -1,
			button_up:'add-file.png',
			button_over:'add-file.png',
			button_down:'add-file.png'		
		},
		progressBarColor: '#000000',
		attachScrollSpeed: 1000,		
		removeIcon: 'trash-icon.png',
		genericFileIcon: 'file-icon.png',
		maxPostSizeMessage: 'Attachments exceed maximum size limit.',
		maxFileMessage: 'File limit hit, try removing a file first.',
		duplicateFileMessage: 'This file has already been attached.',
		notReadyMessage: 'The form can not be submitted yet because there are still files being resized.',
		removeAllText: 'remove all'
	}	
	
})(jQuery);
