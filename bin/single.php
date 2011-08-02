<html>
<head>
	<script src="jquery-1.4.min.js" type="text/javascript"></script>
	<script src="jquery.flash.min.js" type="text/javascript"></script>
	<link type="text/css" rel="stylesheet" href="unrelated.css" />
	
	<script src="agile-uploader-3.0.js" type="text/javascript"></script>
	<link type="text/css" rel="stylesheet" href="agile-uploader.css" />
</head>
<body>

<h1>Resize Before Upload Demo (single)</h1>
<form id="singularDemo" enctype="multipart/form-data">
<label for="title">Title</label><br />
<input id="title" type="input" name="title" />
<br style="clear: left;" />

<label>Image</label> <div id="single"></div>
    
<br style="clear: left;" />    
<label for="testdata">Another field</label><br />
<input id="testdata" type="input" name="testdata" />
<br />

</form>	
<a href="#" onClick="document.getElementById('agileUploaderSWF').submit();">Submit</a>
   
    <script type="text/javascript">
    	$('#single').agileUploaderSingle({
    		submitRedirect: 'results.php',
    		formId: 'singularDemo',
			progressBarColor: '#00ff00',
    		flashVars: {
			firebug: false,
    			form_action: '/process.php'
    		}	
    	});    	
    </script>
</body>
</html>
