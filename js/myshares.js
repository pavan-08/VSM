var refreshShares;

function registerEventShares() {
	$('.myshares table tbody tr td.sell_shares span').click( function() {
		if(!$(this).siblings('input[type="number"]').is(':visible')) {
			$(this).siblings('input[type="number"]').show();
			clearInterval(refreshShares);
		} else {
			goSellShares($(this).siblings('input[type="number"]'));
		}
	});
}

function goSellShares(count) {
	if(count.val().trim() !== '' && /^\d+$/.test(count.val().trim())) {
		$.post("../classes/sellShares.php", {'tid': count.parent().parent().attr('data-id'), 'count': count.val().trim()})
			.done(function(data) {
				if(data == 1) {
					showModalSuccess("Successfully sold " + count.val().trim() + " shares.");
				} else {
					showModalFail("Sorry, you probably don't have those many shares.");
				}
			})
			.fail(function() {
				showModalFail("Something went wrong! :(");
			});
		loadProfile();
	} else {
		showModalFail('Please enter a valid count of shares');
	}

	count.hide();
	loadShares();
	refreshShares = setInterval(loadShares, 30000);
}

function loadShares() {
	var file = "../classes/getMyShares.php";
	var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if(xhr.readyState == 4 && xhr.status == 200) {
            $('.myshares').html(xhr.responseText);
            footerpos();
            registerEventShares();
        }
    };
    xhr.open('GET',file,true);
    xhr.send();
}

$(document).ready(function() {
	loadShares();
	refreshShares = setInterval(loadShares, 30000);

});