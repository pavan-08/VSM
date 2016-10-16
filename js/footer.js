$(document).ready( function() {
	console.log($(document).height());
	console.log($(window).height());
	if($(document).height() === $(window).height()) {
		$('footer').css({
			'position' : 'fixed',
			'bottom'   : '0'
		})
	}
});