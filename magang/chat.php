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

$uId = $_POST['uId'] ?? '';
// $uId = 6;

// $sql = "SELECT cabangrep.IdCabRep
// FROM user
// INNER JOIN cabangrep ON user.KotaKab = cabangrep.kota
// WHERE user.UserId = '$uId'";
$sql = "SELECT IdCabRep
FROM chat
WHERE CustId = '$uId'";
$result = $mysqli->query($sql);
if ($result->num_rows > 0) {
    $cabRep = $result->fetch_assoc();
} else {
    $response = ['success' => false, 'message' => 'No chat data found UGH'];
}

if (!empty($cabRep)) {
    $cabRepId = $cabRep['IdCabRep'];
    $checkList = "SELECT * FROM chat WHERE `CustId`='$uId' and `IdCabRep`='$cabRepId'";
    $result2 = $mysqli->query($checkList);
    if ($result2->num_rows == 0) {
        $insertQuery = "INSERT INTO chat (IdCabRep, CustId) VALUES ('$cabRepId', '$uId')";
        if ($mysqli->query($insertQuery) === true) {
            $response = ['success' => true, 'message' => 'Data inserted successfully'];
        } else {
            $response = ['success' => false, 'message' => 'Failed to insert data HHH'];
        }
    } else {
        $getHistory = "SELECT * FROM chat WHERE `CustId`='$uId' and `IdCabRep`='$cabRepId'";
        $result4 = $mysqli->query($getHistory);
        if ($result4->num_rows > 0) {
            $data = array();
            while ($row = $result4->fetch_assoc()) {
                $data[] = $row;
            }
            $response = ['success' => true, 'data' => $data];
        } else {
            $response = ['success' => false, 'message' => 'No chat history found OMG'];
        }
    }
}
$getWA = $_POST['getWA'] ?? '';
// $getWA = "true";
if (!empty($getWA)) {
    if (!empty($cabRep)) {
        $cabRepId = $cabRep['IdCabRep'];
        $noWA = "SELECT hp FROM customercare WHERE `IdCabRep`='$cabRepId'";
        $result3 = $mysqli->query($noWA);
        if ($result3->num_rows > 0) {
            $data = array();
            while ($row = $result3->fetch_assoc()) {
                $data[] = $row;
            }
            $response = ['success' => true, 'data' => $data];
        } else {
            $response = ['success' => false, 'message' => 'No WhatsApp number found EY'];
        }
    } else {
        $response = ['success' => false, 'message' => 'Cab rep tidak ada NO'];
    }
}
$message = $_POST['message'] ?? '';
// $message = "test";
$time = $_POST['time'] ?? '';
$sender = $_POST['sender'] ?? '';

if (!empty($message)) {
    $send = "INSERT INTO chat (CustId, IdCabRep, Message, TimeSend, Sender) VALUES ('$uId', '$cabRepId', '$message', '$time','$sender')";
    $result2 = $mysqli->query($send);
    if ($result2 === TRUE) {
        $sendNotif = "INSERT INTO chatnotif (UserId, IdCabRep, TimeSend, Sender, status, title, body) VALUES ('$uId', '$cabRepId', '$time','$sender', '0', 'Chat Baru', 'Anda memiliki chat baru dari $sender')";
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