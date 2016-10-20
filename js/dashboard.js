var refreshCompanies, refreshEvents, refreshGraphs;

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

function goPremium(key) {
	if(key.val().trim() !== '') {
		$.post("../classes/goPremium.php", {'key': key.val().trim()})
			.done(function(data) {
				$('.modal-form').css('display',"none");
				if(data == 1) {
					showModalSuccess("Congratulation! You are a premium user now!");
					loadGraphs();
				} else {
					showModalFail("Entered key is invalid or duplicate.");
				}
			})
			.fail(function() {
				showModalFail("Something went wrong! :(");
			});
		loadProfile();
	} else {
		showModalFail('Please enter a license key');
	}

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

function loadEvents() {
	var file = "../classes/getEvents.php";
	var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if(xhr.readyState == 4 && xhr.status == 200) {
            $('.events').html(xhr.responseText);
            footerpos();
        }
    };
    xhr.open('GET',file,true);
    xhr.send();
}

function loadGraphs() {
	var file = "../classes/getGraphs.php";
	var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if(xhr.readyState == 4 && xhr.status == 200) {
        	$('.graphs').empty();
        	var data = JSON.parse(xhr.responseText);
        	var container;

        	data.forEach(function(item, index) {
        		container = $(document.createElement('div'));
        		container.addClass('graph-container');
		   		if($(window).width() <= 500) {
		   			container.width($(window).width() * 0.9); 
				} else if($(window).width() <= 700) {
		   			container.width($(window).width() * 0.5); 
				} else {
					container.width($(window).width() * 0.25); 	
				}
        		$('.graphs').append(container);
        		google.charts.load('current', {packages: ['corechart']});
   				google.charts.setOnLoadCallback(function() {
   					// Define the chart to be drawn.
				    var plot = new google.visualization.arrayToDataTable(item.points);
				    var options = {
			          title: item.name,
			          titleTextStyle: {
						    color: 'white'
						},
					  colors: ['white'],
			          backgroundColor: 'transparent',
			          legend:{position: 'none'},
			          hAxis: {
							    textStyle:{color: '#FFF'}
							},
					  vAxis: {
							    textStyle:{color: '#FFF'}
							}
			        };
				    // Instantiate and draw the chart.
				    var chart = new google.visualization.AreaChart(document.getElementsByClassName('graphs')[0].childNodes[index]);
				    chart.draw(plot, options);
				    if(index == data.length - 1) {
				    	if(index == 3) {
					    	container = $(document.createElement('div'));
	        				container.addClass('graph-container');
	        				var gopremium = $(document.createElement('button'));
	        				gopremium.html('Go Premium for more graphs');
	        				gopremium.addClass("go-premium");
	        				gopremium.click(showModalForm);
	        				container.append(gopremium);
	        				$('.graphs').append(container);
	        				$('.graphs').width($('.graph-container').width() * (data.length + 1));
        				} else {
        					$('.graphs').width($('.graph-container').width() * data.length);
        				}
				    	console.log($('.graph-container').width() * data.length);
				    	
				    }
   				});
				
        	});
            //$('.events').html(xhr.responseText);
            footerpos();
        }
    };
    xhr.open('GET',file,true);
    xhr.send();
}

$(document).ready(function() {
	$('.graphs-container').width($(window).width());
	$(window).resize(function() {
		$('.graphs-container').width($(window).width());
	});
	function loop() {
        
        var offset = $('.graphs').width();
        var time = 30000*$('.graphs .graph-container').length / 10;
        $('.graphs').animate ({
            left: -offset,
        }, time, 'linear', function() {
        	loadGraphs();
        	$('.graphs').css({right:'-100%', left: ''});
            loop();
        });
    }
    $('.graphs').hover(function() {
	  $('.graphs').pause();
	}, function() {
	  $('.graphs').resume();
	})
	loadCompanies();
	loadEvents();
	loadGraphs();
	refreshCompanies = setInterval(loadCompanies, 30000);
	refreshEvents    = setInterval(loadEvents, 30000);
	/*refreshGraphs    = setInterval(loadGraphs, 10000);*/
	setTimeout(loop, 1000);
});