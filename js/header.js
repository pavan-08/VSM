function loadProfile() {
	$.get("../classes/loadProfile.php")
		.done(function(data) {
			$('header .nav-bar span.profile').empty();
			$('header .nav-bar span.profile').html(data);
		})
		.fail(function() {
			console.error("Failed to load profile");
		})
}

function logoutEvent() {
	location.assign("../classes/logout.php");
}

$(document).ready(function() {
	$('header .login-nav span .button').click(function() {
		var uname = $('#login-user');
		var password = $('#login-password');
		if(uname.val().trim() !== '' && password.val().trim() !== '') {
			$('header .login-nav span .button i').css('display', 'inline-block');
			$.post("classes/login.php", {'username': uname.val().trim(), 'password': password.val().trim()})
				.done(function(data) {
					$('header .login-nav span .button i').css('display', 'none');
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
	$('header .nav-bar #logout').click(logoutEvent);
});