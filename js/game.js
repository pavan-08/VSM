function GetURLParameter(sParam)
{
    var sPageURL = window.location.search.substring(1);
    var sURLVariables = sPageURL.split('&');
    for (var i = 0; i < sURLVariables.length; i++)
    {
        var sParameterName = sURLVariables[i].split('=');
        if (sParameterName[0] == sParam)
        {
            return sParameterName[1];
        }
    }
}

function SetURLParameter(sParam, sValue){
    sParam = encodeURI(sParam);
    sValue = encodeURI(sValue);
    var sParams = window.location.search.substring(1).split('&');
    var i =0;
    for(i=0; i<sParams.length;i++){
        var sParameterName = sParams[i].split('=');
        if(sParameterName[0] == sParam){
            sParameterName[1] = sValue;
            sParams[i] = sParameterName.join('=');
            break;
        }
    }
    if(i==sParams.length){
        sParams.push(sParam+'='+sValue);
    }
    window.history.pushState({"html":'',"pageTitle":''},"", "?"+sParams.join('&'));
    //window.location.search = sParams.join('&');
    //console.log(sParams.join('&'));
}

function loadviaAJAX(section) {
    var file = '';
    var script = '';
    $('.content').empty();
    $('.loader').css('display', 'block');
    switch(section) {
        case 'Dashboard':
            file = '../classes/Dashboard.php';
            script = '../js/minified/dashboard.min.js';
            break;
        case 'My Shares':
            file = '../classes/MyShares.php';
            script = '../js/minified/myshares.min.js';
            break;
        case 'Leaderboard':
            file = '../classes/Leaderboard.php';
            script = '../js/minified/leaderboard.min.js';
            break;
        default :
            file = '../classes/Dashboard.php';
            script = '../js/minified/dashboard.min.js';
            section = "Dashboard";
            break;
    }
    SetURLParameter('section', section);
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if(xhr.readyState == 4 && xhr.status == 200) {
            $('.content').html(xhr.responseText);
            $('.loader').css('display', 'none');
            if(script !== '' ) {
                $.getScript(script)
                    .done(function (script, textStatus) {
                    })
                    .fail(function (jqxhr, settings, exception) {
                        console.error(script + " error");
                    });
            }
        }
    };
    xhr.open('GET',file,true);
    xhr.send();
}

$(document).ready(function () {
   loadviaAJAX(decodeURI(GetURLParameter('section')));
   $('header .nav-bar ul li').on('click', function() {
           loadviaAJAX($(this).find('p').find('span.2').html());
   })
});