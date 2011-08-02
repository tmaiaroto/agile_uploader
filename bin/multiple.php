<html>
<head>
	<script src="jquery-1.4.min.js" type="text/javascript"></script>
	<script src="jquery.flash.min.js" type="text/javascript"></script>
	<link type="text/css" rel="stylesheet" href="unrelated.css" />
	
	<script src="agile-uploader-3.0.js" type="text/javascript"></script>
	<link type="text/css" rel="stylesheet" href="agile-uploader.css" />
</head>
<body>

<div id="demo">
<h1>Resize Before Upload Demo (multiple)</h1>

<p>
This example shows a general multiple image uploader that resizes the images before uploading them to the server. (*note: IE7 and IE6 users will not see thumbnails either way, they will always see file icons)
It provides a list of files that the user can see so they know what will be uploaded and gives them the ability to remove any of the files if they change their mind. It also displays the final file size that will be sent to the server.
</p>

<form id="multipleDemo" enctype="multipart/form-data">
<label for="title">Title</label><br />
<?php // <input id="title" type="input" name="title" /> ?>
<br style="clear: left;" />

<div id="multiple"></div>
    
<br style="clear: left;" /><br />
<label for="testdata">Another field</label><br />
<?php // <input id="testdata" type="input" name="testdata" /> ?>
<br />

</form>

<a href="#" onClick="document.getElementById('agileUploaderSWF').submit();">Submit</a>
</div>

    <script type="text/javascript">
    	$('#multiple').agileUploader({
		flashSrc: 'agile-uploader.swf',
    		submitRedirect: 'results.php',
    		formId: 'multipleDemo',
		flashVars: {
			firebug: true,
    			form_action: '/process.php',
			file_limit: 3,
			max_post_size: (10000 * 1024)
    		}
    	});	
    </script>

</body>
</html>
