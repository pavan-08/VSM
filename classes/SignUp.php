<?php
include (__DIR__.'/dbconnect.php');
$error = "";
class SignUp extends DBConnect {
	public function __construct() {
		parent::__construct();
		$this->error = "";
		if($_SERVER['REQUEST_METHOD'] == "POST" 
		&& isset($_POST['fname']) && !empty($_POST['fname'])
		&& isset($_POST['lname']) && !empty($_POST['lname'])
		&& isset($_POST['eid']) && !empty($_POST['eid'])
		&& isset($_POST['uname']) && !empty($_POST['uname'])
		&& isset($_POST['pass']) && !empty($_POST['pass'])
		&& isset($_POST['cpass']) && !empty($_POST['cpass'])
		&& isset($_POST['gender']) && !empty($_POST['gender'])
		&& isset($_POST['bday']) && !empty($_POST['bday'])) {
			$fname  = $this->test_input($_POST['fname']);
			$lname  = $this->test_input($_POST['lname']);
			$email  = $this->test_input($_POST['eid']);
			$uname  = $this->test_input($_POST['uname']);
			$pass   = md5($this->test_input($_POST['pass']));
			$gender = $this->test_input($_POST['gender']);
			$dob    = $this->test_input($_POST['bday']);
			
			$sql = "INSERT INTO `user`(`fname`, `lname`, `email`, `username`, `password`, `gender`, `DOB`) VALUES"
									."(\"$fname\",\"$lname\",\"$email\",\"$uname\",\"$pass\",\"$gender\",\"$dob\")";
			if(mysqli_query($this->conn, $sql)) {
				
				session_start();
				$_SESSION['uid']  = $uname;
				$_SESSION['pass'] = $pass;
				header('location: views/game.php');
			} else {
				$this->error = "That username or email ID is probably registered already.";
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
$sup = new SignUp();
$error = $sup->error;