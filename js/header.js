$(document).ready(function() {
	$('header .login-nav span button').click(function() {
		var uname = $('#login-user');
		var password = $('#login-password');
		if(uname.val().trim() !== '' && password.val().trim() !== '') {
			$('header .login-nav span button i').css('display', 'inline-block');
			$.post("classes/login.php", {'username': uname.val().trim(), 'password': password.val().trim()})
				.done(function(data) {
					$('header .login-nav span button i').css('display', 'none');
					if(data == 1) {
						$('header .login-nav span .err').css('display', 'none');
						location.assign('views/game.php');
					} else {
						$('header .login-nav span .err').css('display', 'inline-block');
					}
					
				});
		} else {
			$('header .login-nav span .err').css('display', 'inline-block');
		}
	});
	$('header .nav-bar #logout').click(function() {
		location.assign("../classes/logout.php");
	});
});