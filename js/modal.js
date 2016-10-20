// Get the modal
var modals = document.querySelector('.modal-success');

// Get the <span> element that closes the modal
var spans = document.querySelector(".modal-success .modal-content .modal-header .close");

// Open the modal
function showModalSuccess(msg) {
    document.querySelector('.modal-success .modal-content .modal-body').innerHTML = msg;
    modals.style.display = "block";
}

// When the user clicks on <span> (x), close the modal
spans.onclick = function() {
    modals.style.display = "none";
};

// When the user clicks anywhere outside of the modal, close it
window.onclick = function(event) {
    if (event.target == modals) {
        modals.style.display = "none";
    }
};

// Get the modal
var modalf = document.querySelector('.modal-fail');

// Get the <span> element that closes the modal
var spanf = document.querySelector(".modal-fail .modal-content .modal-header .close");

// Open the modal
function showModalFail(msg) {
    document.querySelector('.modal-fail .modal-content .modal-body').innerHTML = msg;
    modalf.style.display = "block";
}

// When the user clicks on <span> (x), close the modal
spanf.onclick = function() {
    modalf.style.display = "none";
};

// When the user clicks anywhere outside of the modal, close it
window.onclick = function(event) {
    if (event.target == modalf) {
        modalf.style.display = "none";
    }
};

// Get the modal
var modale = document.querySelector('.modal-form');

// Get the <span> element that closes the modal
var spane = document.querySelector(".modal-form .modal-content .modal-header .close");

if(modale != undefined && modale != null && spane != undefined && modale != undefined) {
    // Open the modal
    function showModalForm() {
        modale.style.display = "block";
    }

    // When the user clicks on <span> (x), close the modal
    spane.onclick = function() {
        modale.style.display = "none";
    };

    // When the user clicks anywhere outside of the modal, close it
    window.onclick = function(event) {
        if (event.target == modale) {
            modale.style.display = "none";
        }
    };

    $('.modal-form .modal-body button').click(function() {
        goPremium($(this).parent().find('input[name="license"]'));
    });
}