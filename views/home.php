<?php
	session_start();
	$loggedin = false;
	if(isset($_SESSION['uid']) && isset($_SESSION['pass'])) {

	}
	include(__DIR__.'/../templates/header.html');
	include(__DIR__.'/../templates/home.html');
	include(__DIR__.'/../templates/footer.html');
	?>
	<script type="text/javascript" src="js/minified/footer.min.js"></script>