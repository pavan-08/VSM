<?php
include(__DIR__.'/dbconnect.php');
class Leaderboard extends DBConnect {
	public function __construct() {
		parent::__construct();
		if (session_status() == PHP_SESSION_NONE) {
		    session_start();
		}
		if(isset($_SESSION['uid']) && isset($_SESSION['pass'])) {
			$sql = "SELECT `username` FROM `user` ORDER BY `money` DESC";
			$result = mysqli_query($this->conn, $sql);
			?>
			<table>
			<thead>
				<tr>
					<th>Rank</th>
					<th>User</th>
				</tr>
			</thead>
			<tbody>
			<?php
			$i=1;
			while($row = mysqli_fetch_assoc($result)) {
			?>
				<tr>
					<td><?=$i?></td>
					<td><?=$row['username']?></td>
				</tr>
			<?php
			$i++;
		}
		?>
			</tbody>
		</table>
		<?php
		}
	}
}

new Leaderboard();