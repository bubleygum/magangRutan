<?php
function cors()
{
    if (isset($_SERVER['HTTP_ORIGIN'])) {
        header("Access-Control-Allow-Origin: {$_SERVER['HTTP_ORIGIN']}");
        header('Access-Control-Allow-Credentials: true');
        header('Access-Control-Max-Age: 86400');
    }

    if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {

        if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD']))
            header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

        if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']))
            header("Access-Control-Allow-Headers: {$_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']}");

        exit(0);
    }
}
cors();

$mysqli = new mysqli("localhost", "root", "", "magang2");
if ($mysqli->connect_error) {
    die("Connection failed: " . $mysqli->connect_error);
}

$custId = $_POST['custId'] ?? '';
$cabRepId = $_POST['idCabRep'] ?? '';

$getHistory = "SELECT * FROM chat WHERE `CustId`='$custId' and `IdCabRep`='$cabRepId'";
$result = $mysqli->query($getHistory);
if ($result->num_rows > 0) {
    $data = array();
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    $response = ['success' => true, 'data' => $data];
} else {
    $response = ['success' => false, 'message' => 'No chat history found OMG'];
}

$message = $_POST['message'] ?? '';
// $message = "test";
$time = $_POST['time'] ?? '';
$sender = $_POST['sender'] ?? '';
$salesId = $_POST['salesId'] ?? '';
// echo $salesId;
if (!empty($message)) {
    $send = "INSERT INTO chat (CustId, IdCabRep, Message, TimeSend, Sender, idSales) VALUES ('$custId', '$cabRepId', '$message', '$time','$sender','$salesId')";
    $result2 = $mysqli->query($send);
    if ($result2 === TRUE) {
        $sendNotif = "INSERT INTO chatnotif (UserId, IdCabRep, TimeSend, Sender, status) VALUES ('$custId', '$cabRepId', '$time','$sender', '0')";
        $result3 = $mysqli->query($sendNotif);
        if($result3 === TRUE){
            $response = ['success' => true, 'message' => 'send'];
        }else{
            $response = ['success' => false, 'message' => 'failed here'];
        }
    } else {
        $response = ['success' => false, 'message' => 'failed to send AI'];
    }
}

echo json_encode($response);
?>