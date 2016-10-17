function footerpos() {
	//console.log('');
	if($(document).height() === $(window).height()) {
		$('footer').css({
			'position' : 'fixed',
			'bottom'   : '0'
		});
	} else {
		$('footer').css({
			'position': 'inherit'
		});
	}
}

$(document).ready( function() {
	$(window).resize(footerpos);
	footerpos();
});