<html>
<head>
	<script src="jquery-1.4.min.js" type="text/javascript"></script>
	<script src="jquery.flash.min.js" type="text/javascript"></script>
	<link type="text/css" rel="stylesheet" href="unrelated.css" />
	
	<script src="agile-uploader-2.0.min.js" type="text/javascript"></script>
	<link type="text/css" rel="stylesheet" href="agile-uploader.css" />
</head>
<body>

<h1>Resize Before Upload Demo (multiple)</h1>

<p>
This example shows a multiple file uploader that resizes any attached images before uploading them to the server. It accepts other types of files, represented by a file icon instead of a thumbnail preview. (*note: IE7 and IE6 users will not see thumbnails either way, they will always see file icons)
A list of files is provided so that the user will know what will be uploaded and gives them the ability to remove any of the files if they change their mind. It also displays the final file size that will be sent to the server.
</p>

<form id="multipleDemo" enctype="multipart/form-data">
<label for="title">Title</label><br />
<input id="title" type="input" name="title" />
<br style="clear: left;" />

<div id="multiple"></div>
    
<br style="clear: left;" />    
<label for="testdata">Another field</label><br />
<input id="testdata" type="input" name="testdata" />
<br />

</form>	
<a href="#" onClick="$().agileUploaderSubmit();">Submit</a>

    <script type="text/javascript">
    	$('#multiple').agileUploader({    		
    		submitRedirect: 'results.php',
    		formId: 'multipleDemo',
    		flashVars: {
    			form_action: '/resizer/process.php',
    			file_filter:'*.*' 
    			// another example: '*.doc;*.DOC;*.pdf;*.PDF;*.jpg;*.jpeg;*.gif;*.png;*.JPG;*.JPEG;*.GIF;*.PNG'
    		}		
    	});	
    </script>
</body>
</html>
