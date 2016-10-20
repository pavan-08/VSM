<?php
include(__DIR__.'/userConfig.php');

class GoPremium extends DBConnect {
	public function __construct() {
		parent::__construct();
		if (session_status() == PHP_SESSION_NONE) {
		    session_start();
		}
		$userConfig = new UserConfig();
		if(isset($_SESSION['uid']) && isset($_SESSION['pass']) 
			&& isset($_POST['key']) && !empty($_POST['key'])) {
			$uid = $this->test_input($userConfig->user['uid']);
			$key = $this->test_input($_POST['key']);
			$sql = "CALL go_premium_user(\"$uid\",\"$key\")";
			if(mysqli_query($this->conn, $sql)) {
				echo "1";
			} else {
				echo "0";
			}
		} else {
			echo "0";
		}
	}

	private function test_input($data){
		$data = trim($data);
        $data = stripslashes($data);
        $data = htmlspecialchars($data);
        return $data;
	}
}

new GoPremium();