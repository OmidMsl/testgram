<?php

require_once 'config.php';

// get parameters
if(isset($_POST['text']) && isset($_POST['sender_number'])) {
    $text = $_POST['text'];
    $sender = $_POST['sender_number'];
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
$tsql= "";
if (isset($_POST['user_receiver_number'])) {
    $receiver = $_POST['user_receiver_number'];

    $tsql = "INSERT INTO [DB_A6D8FC_testgram].[dbo].[text_message] (id, seen, send_date, text, edited, sender_number, user_receiver_number, group_receiver_id, channel_receiber_id) VALUES (NULL, 0, (SELECT CURRENT_TIMESTAMP), '$text', 0, $sender, $receiver, NULL, NULL)";
} else if (isset($_POST['group_receiver_id'])) {
    $receiver = $_POST['group_receiver_id'];
    $tsql = "INSERT INTO [DB_A6D8FC_testgram].[dbo].[text_message] (id, seen, send_date, text, edited, sender_number, user_receiver_number, group_receiver_id, channel_receiber_id) VALUES (NULL, 0, (SELECT CURRENT_TIMESTAMP), '$text', 0, $sender, NULL, $receiver, NULL)";
} else if (isset($_POST['channel_receiver_id'])) {
    $receiver = $_POST['channel_receiver_id'];
    $tsql = "INSERT INTO [DB_A6D8FC_testgram].[dbo].[text_message] (id, seen, send_date, text, edited, sender_number, user_receiver_number, group_receiver_id, channel_receiber_id) VALUES (NULL, 0, (SELECT CURRENT_TIMESTAMP), '$text', 0, $sender, NULL, NULL, $receiver)";
} else {
    echo "error";
    return;
}

/* Execute the query. */    
    
$stmt = sqlsrv_query( $conn, $tsql);
if ( $stmt ) {    
     echo "inserted";
} else {
    echo "error";
}

?>