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

$userId = $_POST['UserId'] ?? '';
$userStat = $_POST['userStat'] ?? '';
// $userId = "6";
// $userStat = "3";
// $userId = "7";
// $userStat = "1";
$data = array();

if ($userStat == "1") {
    $sql = "SELECT *
    FROM chatnotif 
    WHERE Sender != 'admin' AND chatnotif.status = '0'
    ORDER BY TimeSend DESC"; 

    $result = $mysqli->query($sql);

} elseif ($userStat == "3") {
    $sql = "SELECT *
    FROM chatnotif 
    WHERE UserId = '$userId' AND Sender = 'admin'
    ORDER BY TimeSend DESC"; 

    $result = $mysqli->query($sql);
} elseif ($userStat == "2") {
    $sql = "SELECT *
            FROM chatnotif 
            INNER JOIN user ON chatnotif.UserId = user.UserId
            WHERE chatnotif.UserId = '$userId' AND chatnotif.Sender = user.FullName AND chatnotif.status = '0'
            ORDER BY TimeSend DESC";

    $result = $mysqli->query($sql);
}

if ($result) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    $response = ['success' => true, 'data' => $data];
} else {
    $response = ['success' => false, 'message' => 'No chat notif data found'];
}

echo json_encode($response);
?>