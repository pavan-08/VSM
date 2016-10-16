<?php
	class DBConnect {
		public function __construct() {
			$host   = "localhost";
			$user   = "root";
			$pass   = "";
			$dbname = "vsmwt";
			$this->conn = mysqli_connect($host, $user, $pass, $dbname);
			if (!$this->conn) {
			    echo "Error: Unable to connect to MySQL." . PHP_EOL;
			    echo "Debugging errno: " . mysqli_connect_errno() . PHP_EOL;
			    echo "Debugging error: " . mysqli_connect_error() . PHP_EOL;
			    exit;
			}
		}
	}