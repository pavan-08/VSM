<?php
session_start();
if(!isset($_SESSION['uid']) || !isset($_SESSION['pass'])) {
	header('location: ../index.php');
} 
echo "logged in :)";