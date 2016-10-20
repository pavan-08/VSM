<?php
include(__DIR__.'/userConfig.php');
class Graphs extends DBConnect {
	public function __construct() {
		parent::__construct();
		if (session_status() == PHP_SESSION_NONE) {
		    session_start();
		}
		if(isset($_SESSION['uid']) && isset($_SESSION['pass'])) {
			$output=array();
			$userConfig = new UserConfig();
			$limit = " LIMIT 4";
			if($userConfig->user['premium']) {
				$limit = "";
			}
			$sql = "SELECT `cid`, `name` FROM `company` ORDER BY ABS(`current_price`-`opening_price`) DESC".$limit;
			$result = mysqli_query($this->conn, $sql);
			while($row = mysqli_fetch_assoc($result)) {
				$cid = $row['cid'];
				$cname = $row['name'];
				$points = array();
				$points[] = array("Time", "Share Value");
				$sqlg = "SELECT * FROM `graph` WHERE `cid`=\"$cid\"";
				$res1 = mysqli_query($this->conn, $sqlg);
				while($row1 = mysqli_fetch_assoc($res1)) {
					$points[] = array($row1['timestamp'], (float)$row1['share_value']);
				}
				$output[] = array(
					'name'   => $cname,
					'cid'    => $cid,
					'points' => $points
				);
			}
			echo json_encode($output);
		}
	}
}

new Graphs();