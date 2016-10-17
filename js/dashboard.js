var refreshCompanies;

function registerEvents() {
	$('.companies table tbody tr td.buy_shares span').click( function() {
		if(!$(this).siblings('input[type="number"]').is(':visible')) {
			$(this).siblings('input[type="number"]').show();
			clearInterval(refreshCompanies);
		} else {
			goBuyShares($(this).siblings('input[type="number"]'));
		}
	});
}

function goBuyShares(count) {
	if(count.val().trim() !== '' && /^\d+$/.test(count.val().trim())) {
		$.post("../classes/buyShares.php", {'cid': count.parent().parent().attr('data-id'), 'count': count.val().trim()})
			.done(function(data) {
				if(data == 1) {
					showModalSuccess("Successfully bought " + count.val().trim() + " shares.");
				} else {
					showModalFail("Sorry, you probably don't have enough money to buy.");
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
	loadCompanies();
	refreshCompanies = setInterval(loadCompanies, 30000);
}

function loadCompanies() {
	var file = "../classes/GetCompanies.php";
	var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if(xhr.readyState == 4 && xhr.status == 200) {
            $('.companies').html(xhr.responseText);
            footerpos();
            registerEvents();
        }
    };
    xhr.open('GET',file,true);
    xhr.send();
}

$(document).ready(function() {
	loadCompanies();
	refreshCompanies = setInterval(loadCompanies, 30000);

});