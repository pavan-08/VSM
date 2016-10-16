<!DOCTYPE html>
<?php
session_start();
if(!isset($_SESSION['uid']) || !isset($_SESSION['pass'])) {
	$loggedin = false;
	header('location: ../index.php');

} else {
	$loggedin = true;
}
?>
<html>
	<head>
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<link rel="stylesheet" href="../css/style.min.css"/>
		<script type="text/javascript" src="../js/minified/jquery-3.1.1.min.js"></script>

	</head>
	<body>
	<?php
		include(__DIR__.'/../templates/header.html');
		
		include(__DIR__.'/../templates/footer.html');
	?>
	<script type="text/javascript" src="../js/minified/footer.min.js"></script>
	<script type="text/javascript" src="../js/minified/header.min.js"></script>
	</body>
</html>