var refreshLeaderboard;
function loadLeaderboard() {
	var file = "../classes/getLeaderboard.php";
	var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if(xhr.readyState == 4 && xhr.status == 200) {
            $('.leaderboard').html(xhr.responseText);
            footerpos();
        }
    };
    xhr.open('GET',file,true);
    xhr.send();
}

$(document).ready(function() {
	loadLeaderboard();
	refreshLeaderboard = setInterval(loadLeaderboard, 30000);
});