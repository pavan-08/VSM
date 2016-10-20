<?php
include(__DIR__.'/dbconnect.php');
class GetCompanies extends DBConnect {
	public function __construct() {
		parent::__construct();
		session_start();
		if(!isset($_SESSION['uid']) || !isset($_SESSION['pass'])) {
			header('location: ../index.php');
		}
		$sql = "SELECT * FROM `company`";
		$result = mysqli_query($this->conn, $sql);
		?>
		<table>
			<thead>
				<tr>
					<th>Company</th>
					<th>Current Price</th>
					<th>Difference</th>
					<th>Day High</th>
					<th>Day Low</th>
					<th>Buy Shares</th>
				</tr>
			</thead>
			<tbody>
		<?php
		while($row = mysqli_fetch_assoc($result)) {
			?>
				<tr data-id="<?=$row['cid']?>">
					<td><?=$row['name']?></td>
					<td><?=number_format($row['current_price'], 2)?></td>
					<?php
						if($row['current_price'] - $row['opening_price'] < 0) {
							?>
							<td class="low"><i class="fa fa-caret-down" aria-hidden="true"></i> <?=number_format(round($row['current_price'] - $row['opening_price'], 2), 2)?></td>
							<?php
						} else {
							?>
							<td class="high"><i class="fa fa-caret-up" aria-hidden="true"></i> +<?=number_format(round($row['current_price'] - $row['opening_price'], 2), 2)?></td>
							<?php
						}
					?>
					<td><?=number_format($row['day_high'], 2)?></td>
					<td><?=number_format($row['day_low'], 2)?></td>
					<td class="buy_shares"><input type="number" name="count" placeholder="No. of shares" style="display: none"/><span>Buy</span></td>
				</tr>
			<?php
		}
		?>
			</tbody>
		</table>
		<?php
	}

}
new GetCompanies();