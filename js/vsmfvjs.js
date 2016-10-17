
    function checkemail(){
        var mail=document.forms["signup"]["eid"];
        var re =/^(([^&lt;&gt;()\[\]\.,;:\s@\"]+(\.[^&lt;&gt;()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^&lt;&gt;()[\]\.,;:\s@\"]+\.)+[^&lt;&gt;()[\]\.,;:\s@\"]{2,})$/i;
        if(re.test(mail.value))
                mail.setCustomValidity("Invalid Email id");
        else
                mail.setCustomValidity("");
    }
    function checkpass(){
        var pw=document.forms["signup"]["pass"];
        if(pw.value.length<6)
                pw.setCustomValidity("Password too short");
        else if(pw.value.length>50)
                pw.setCustomValidity("Password too long");
        else if(pw.value.search(/\d/) == -1) 
                pw.setCustomValidity("Password should contain atleast one digit");
        else if(pw.value.search(/[A-Z]/) == -1) 
                pw.setCustomValidity("Password should contain atleast one capital letter");
        else if(pw.value.search(/[\!\@\#\$\%\^\&amp;\*\(\)\_\+]/) == -1) 
                pw.setCustomValidity("Password should contain atleast one special character");
        else
                pw.setCustomValidity("");
    }
    function confirmpass(){
        var pw=document.forms["signup"]["pass"];
        var cpw=document.forms["signup"]["cpass"];
        if(cpw.value!=pw.value)
                cpw.setCustomValidity("Passwords do not match");
        else    
                cpw.setCustomValidity("");    
    }
    function checkusername(){
        var user=document.forms["signup"]["uname"];
        if(/^\d/.test(user.value))
                user.setCustomValidity("Username invalid, cannot start with a digit");
        else
                user.setCustomValidity("");
    }
    
