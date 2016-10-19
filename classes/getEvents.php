<?php
include(__DIR__.'/dbconnect.php');
class Events extends DBConnect {
	public function __construct() {
		parent::__construct();
		if (session_status() == PHP_SESSION_NONE) {
		    session_start();
		}
		if(isset($_SESSION['uid']) && isset($_SESSION['pass'])) {
			$sql = "SELECT `message` FROM `events` ORDER BY `eid` DESC";
			$result = mysqli_query($this->conn, $sql);
			?>
			<table>
			<thead>
				<tr>
					<th>External News Feed</th>
				</tr>
			</thead>
			<tbody>
			<?php
			while($row = mysqli_fetch_assoc($result)) {
			?>
				<tr>
					<td><i class="fa fa-newspaper-o" aria-hidden="true"></i> <?=$row['message']?></td>
				</tr>
			<?php
		}
		?>
			</tbody>
		</table>
		<?php
		}
	}
}

new Events();