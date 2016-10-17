<?php
include(__DIR__.'/dbconnect.php');
class UserConfig extends DBConnect {
	public function __construct() {
		parent::__construct();
		$this->user = NULL;
		$this->loggedIn = false;
		if (session_status() == PHP_SESSION_NONE) {
		    session_start();
		}
		if(isset($_SESSION['uid']) && isset($_SESSION['pass'])) {
			$username = $_SESSION['uid'];
			$password = $_SESSION['pass'];
			$sqlp = "SELECT * FROM `user` WHERE `email`=\"$username\" AND `password`=\"$password\"";
			$sqls = "SELECT * FROM `user` WHERE `username`=\"$username\" AND `password`=\"$password\"";
			$result = mysqli_query($this->conn, $sqlp);
			if(mysqli_num_rows($result) === 1) {
				$this->setUser($result);
			} else {
				$result = mysqli_query($this->conn, $sqls);
				if(mysqli_num_rows($result) === 1) {
					$this->setUser($result);	
				}
			}
		}
	}

	private function setUser($result) {
		while($row = mysqli_fetch_assoc($result)) {
			$this->user = $row;
		}
		$this->loggedIn = true;
	}
}