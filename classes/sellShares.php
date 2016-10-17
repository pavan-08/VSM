<?php
include(__DIR__.'/userConfig.php');

class SellShares extends DBConnect {
	public function __construct() {
		parent::__construct();
		if (session_status() == PHP_SESSION_NONE) {
		    session_start();
		}
		$userConfig = new UserConfig();
		if(isset($_SESSION['uid']) && isset($_SESSION['pass']) 
			&& isset($_POST['tid']) && !empty($_POST['tid'])
			&& isset($_POST['count']) && !empty($_POST['count'])) {
			$uid = $this->test_input($userConfig->user['uid']);
			$tid = $this->test_input($_POST['tid']);
			$count = $this->test_input($_POST['count']);
			$sql = "CALL sell_shares(\"$tid\",\"$uid\",\"$count\")";
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

new SellShares();