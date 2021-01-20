<?php

require_once 'config.php';

// get parameters
if(isset($_POST['contacts'])) {
    $contacts = $_POST['contacts'];
} else {
    echo "error";
    return;
}

// connect to database
$conn = sqlsrv_connect( DB_HOST, DB_INFO);

// check connection
if ( !$conn ) {
     echo "error";
     //die( print_r( sqlsrv_errors(), true));
    return;
}

$tsql = "SELECT * FROM [DB_A6D8FC_testgram].[dbo].[user] WHERE phone_number IN ($contacts)";


/* Execute the query. */    
    
$stmt = sqlsrv_query( $conn, $tsql);
if ( !$stmt ) {    
     echo "error";    
     //die( print_r( sqlsrv_errors(), true));
    return;
}   
$output = array();

while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_NUMERIC))    
{   
    $pquery = "SELECT picture_adress FROM [DB_A6D8FC_testgram].[dbo].[user_profile_pictures] WHERE user_number=$row[0]";
    $stmt2 = sqlsrv_query( $conn, $pquery);
    $record  = array();
    $record['phone_number'] = $row[0];
    $record['id'] = $row[1];
    $record['name'] = $row[2];
    $record['bio'] = $row[3];
    $record['last_seen'] = $row[4];
    $record['images'] = sqlsrv_fetch_array( $stmt2, SQLSRV_FETCH_NUMERIC);
    $output[] = $record;
}
echo json_encode($output);

?>