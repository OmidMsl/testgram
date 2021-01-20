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

$tsql = "SELECT * FROM [DB_A6D8FC_testgram].[dbo].[group] WHERE creator_number=$pn OR id IN (SELECT group_id FROM [DB_A6D8FC_testgram].[dbo].[group_admin] WHERE admin_number=$pn) OR id IN (SELECT group_id FROM [DB_A6D8FC_testgram].[dbo].[group_member] WHERE user_number=$pn)";
//mysqli_query( $con , "SET CHARACTER SET utf8;" );

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
    $record['description'] = $row[4];
    $record['type'] = $row[5];
    $record['creator_number'] = $row[6];
    $output[] = $record;
}
echo json_encode($output);

?>