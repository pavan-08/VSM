<?php
include(__DIR__.'/userConfig.php');
class MyShares extends DBConnect {
	public function __construct() {
		parent::__construct();
		if (session_status() == PHP_SESSION_NONE) {
		    session_start();
		}
		if(isset($_SESSION['uid']) && isset($_SESSION['pass'])) {
			$userConfig = new UserConfig();
			$uid = $userConfig->user['uid'];
			$sql = "SELECT * FROM `transactions` WHERE `uid`=\"$uid\"";
			$result = mysqli_query($this->conn, $sql);
			?>
			<table>
			<thead>
				<tr>
					<th>Company</th>
					<th>Current Price</th>
					<th>Bought At</th>
					<th>Difference</th>
					<th>No. Of Shares</th>
					<th>Sell Shares</th>
				</tr>
			</thead>
			<tbody>
			<?php
			while($row = mysqli_fetch_assoc($result)) {
				$cid = $row['cid'];
				$sql1 = "SELECT * FROM `company` WHERE `cid`=\"$cid\"";
				$res1 = mysqli_query($this->conn, $sql1);
				while($row1 = mysqli_fetch_assoc($res1)) {
					$cname = $row1['name'];
					$cprice = $row1['current_price'];
				}
			?>
				<tr data-id="<?=$row['tid']?>">
					<td><?=$cname?></td>
					<td><?=number_format($cprice, 2)?></td>
					<td><?=number_format($row['bought_at'], 2)?></td>
					<?php
						if($cprice - $row['bought_at'] < 0) {
							?>
							<td class="low"><i class="fa fa-caret-down" aria-hidden="true"></i><?=number_format(round($cprice - $row['bought_at'], 2), 2)?></td>
							<?php
						} else {
							?>
							<td class="high"><i class="fa fa-caret-up" aria-hidden="true"></i>+<?=number_format(round($cprice - $row['bought_at'], 2), 2)?></td>
							<?php
						}
					?>
					<td><?=$row['count']?></td>
					<td class="sell_shares"><input type="number" name="count" placeholder="No. of shares" style="display: none"/><span>Sell</span></td>
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

new MyShares();