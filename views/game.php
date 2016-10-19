<!DOCTYPE html>
<?php
session_start();
if(!isset($_SESSION['uid']) || !isset($_SESSION['pass'])) {
	$loggedin = false;
	header('location: ../index.php');
} else {
	$loggedin = true;
	include(__DIR__.'/../classes/userConfig.php');
	$userConfig = new UserConfig();
}
?>
<html>
	<head>
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<link rel="icon" type="image/png" href="../images/favico.png">
		<link rel="apple-touch-icon" type="image/png" href="../images/favico.png">
		<link rel="stylesheet" href="../css/style.min.css"/>
		<script type="text/javascript" src="../js/minified/jquery-3.1.1.min.js"></script>

	</head>
	<body>
	<?php
		include(__DIR__.'/../templates/header.html');
		?>
		<div class="loader">
            <i class="fa fa-spinner fa-pulse fa-5x"></i>
        </div>
        <div class="content">
        </div>
		<?php
		include(__DIR__.'/../templates/footer.html');
	?>
	<script type="text/javascript" src="../js/minified/footer.min.js"></script>
	<script type="text/javascript" src="../js/minified/header.min.js"></script>
	<script type="text/javascript" src="../js/minified/game.min.js"></script>	
	<script type="text/javascript" src="../js/googlecharts.js"></script>	
	<script type="text/javascript" src="../js/jquery.pause.js"></script>	
	</body>
</html>