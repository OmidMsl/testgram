<?php

require_once 'config.php';

// get parameters
if(isset($_POST['phone_number']) ) {
    $pn = $_POST['phone_number'];
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

$tsql = "SELECT * FROM [DB_A6D8FC_testgram].[dbo].[channel] WHERE id IN (SELECT channel_id FROM [DB_A6D8FC_testgram].[dbo].[channel_admin] WHERE admin_number=$pn) OR id IN (SELECT channel_id FROM [DB_A6D8FC_testgram].[dbo].[channel_member] WHERE user_number=$pn)";

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
    $record  = array();
    $record['id'] = $row[0];
    $record['link'] = $row[1];
    $record['name'] = $row[2];
    $record['picture_adress'] = $row[3];
    $record['sign_messages'] = $row[4];
    $record['type'] = $row[5];
    $record['description'] = $row[6];
    $record['is_notifications_on'] = $row[7];
    $output[] = $record;
}
echo json_encode($output);

?>