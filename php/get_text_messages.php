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

$tsql = "SELECT * FROM [DB_A6D8FC_testgram].[dbo].[text_message] WHERE sender_number=$pn OR user_receiver_number=$pn OR group_receiver_id IN (SELECT id FROM [DB_A6D8FC_testgram].[dbo].[group] WHERE creator_number=$pn OR id IN (SELECT group_id FROM [DB_A6D8FC_testgram].[dbo].[group_admin] WHERE admin_number=$pn) OR id IN (SELECT group_id FROM [DB_A6D8FC_testgram].[dbo].[group_member] WHERE user_number=$pn)) OR channel_receiber_id IN (SELECT id FROM [DB_A6D8FC_testgram].[dbo].[channel] WHERE id IN (SELECT channel_id FROM [DB_A6D8FC_testgram].[dbo].[channel_admin] WHERE admin_number=$pn) OR id IN (SELECT channel_id FROM [DB_A6D8FC_testgram].[dbo].[channel_member] WHERE user_number=$pn))";

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
    $record['seen'] = $row[1];
    $record['send_date'] = $row[2];
    $record['text'] = $row[3];
    $record['edited'] = $row[4];
    $record['sender_number'] = $row[5];
    $record['user_receiver_number'] = $row[6];
    $record['group_receiver_id'] = $row[7];
    $record['channel_receiber_id'] = $row[8];
    $output[] = $record;
}
echo json_encode($output);

?>