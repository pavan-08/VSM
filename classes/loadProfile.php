<?php
include(__DIR__.'/userConfig.php');
/**
* 
*/
class LoadProfile
{
	function __construct()
	{
		$userConfig = new UserConfig();
		?>
		<p title="<?=$userConfig->user['username']?>"><?=$userConfig->user['username']?></p>
		<p title="<?=$userConfig->user['money']?>">₹<?=number_format($userConfig->user['money'], 2)?></p>
		<button id="logout">Logout</button>
		<?php
	}
}

new LoadProfile();