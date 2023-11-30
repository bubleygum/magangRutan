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

$userId = $_POST['UserId'];
$userStat = $_POST['userStat'];

$sql = "SELECT id, UserId, IdCabRep, TimeSend, status, Sender FROM chat_notifs WHERE UserId = '$userId' AND userStat = '$userStat'";
$result = mysqli_query($conn, $sql);

$chatNotifData = [];
while ($row = mysqli_fetch_assoc($result)) {
    $chatNotifData[] = $row;
}

echo json_encode($chatNotifData);
?>