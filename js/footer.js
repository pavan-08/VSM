$(document).ready( function() {

	if($(document).height() === $(window).height()) {
		$('footer').css({
			'position' : 'fixed',
			'bottom'   : '0'
		})
	}
});