<?php
	session_start();
	$loggedin = false;
	if(isset($_SESSION['uid']) && isset($_SESSION['pass'])) {
		header('location: views/game.php');
	}
	include(__DIR__.'/../templates/header.html');
	?><div class="home-content"><?php
	include(__DIR__.'/../templates/home.html');
	?></div><?php
	include(__DIR__.'/../templates/footer.html');
	?>
	<script type="text/javascript" src="js/minified/footer.min.js"></script>
	<script type="text/javascript" src="js/minified/header.min.js"></script>
	<script type="text/javascript" src="js/minified/vsmfvjs.min.js"></script>