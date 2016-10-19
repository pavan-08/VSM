<?php
    include('db_connection.php');
    ini_set('max_execution_time', 180);
    function generateRandomID($conn) {
        $qr = strtoupper(bin2hex(openssl_random_pseudo_bytes(5)));
        //echo $qr."<br/>";
        $insert_query = "INSERT INTO `licensekeys`(`id`) VALUES(\"$qr\")";
        /*echo $insert_query;*/
        if(mysqli_query($conn, $insert_query)) {
            return $qr;
        } else {
            return generateRandomID($conn);
        }
    }
    $success = "";
    if($_SERVER["REQUEST_METHOD"] == "POST") {
        //echo "here";
        $count = $_POST['count'];
        $content = "";
        for($i = 0; $i < $count; $i++) {
            //echo "here";
            $id = generateRandomID($conn);
            $content = $content.$id."\r\n";
        }
        date_default_timezone_set("Asia/Kolkata");
        $fname = date("m-d-Y-H-i-s");
        $myfile = fopen($fname.".txt", "w") or die("Unable to open file!");
        fwrite($myfile, $content);
        fclose($myfile);
        $success = "Reg IDs have been created successfully.";
    }

    include('templates/index-form.html');