<?php
include(__DIR__.'/dbconnect.php');
class Dashboard extends DBConnect {
	public function __construct() {
		parent::__construct();
		echo "Hello :)";
	}
}
new Dashboard();