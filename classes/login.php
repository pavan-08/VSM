<?php
include(__DIR__.'/dbconnect.php');

	class Login extends DBConnect{
		public function __construct() {
			parent::__construct();
			session_start();
			if(isset($_SESSION['uid']) && isset($_SESSION['pass'])) {
				echo "1";
				return;
			}
			if(isset($_POST['username']) && isset($_POST['password'])) {
				$username = $this->test_input($_POST['username']);
				$password = $this->test_input($_POST['password']);
				$sqlp = "SELECT `username`, `password` FROM user WHERE `username`=\"$username\"";
				$sqls = "SELECT `email`, `password` FROM user WHERE `email`=\"$username\"";
				$result = mysqli_query($this->conn, $sqlp);
				if(mysqli_num_rows($result) === 1) {
					$this->checkPassword($username, $password, $result);
				} else {
					$result = mysqli_query($this->conn, $sqls);
					if(mysqli_num_rows($result) === 1) {
						$this->checkPassword($username, $password, $result);
					} else {
						echo "0";
					}
				}
			}
		}

		private function checkPassword($username, $password, $result) {
			while($row = mysqli_fetch_assoc($result)) {
				if(md5($password) === $row['password']) {
					$_SESSION['uid'] = $username;
					$_SESSION['pass'] = $row['password'];
					echo "1";
				} else {
					echo "0";
				}
			}
		}

		private function test_input($data){
		$data = trim($data);
        $data = stripslashes($data);
        $data = htmlspecialchars($data);
        return $data;
	}
	}

	new Login();
?>