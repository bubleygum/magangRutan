<?php
function cors() {
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
$idPromo = $_POST['IdPromo'] ?? '';
$viewBy = $_POST['userId'] ?? '';
$timeView = $_POST['timeView'] ?? '';
// $idPromo = '1';
// $viewBy = '6';
// $timeView = '1';
$sql = "INSERT INTO promoanalytic (IdPromo, ViewBy, TimeViews) 
VALUES ('$idPromo', '$viewBy', '$timeView')";
$result = $mysqli->query($sql);

if ($result === TRUE) {
    $response = ['success' => true, 'message' => 'Success to insert data into prodanalytic'];
} else {
    $response = ['success' => false, 'message' => 'Failed to insert data into prodanalytic'];
}
echo json_encode($response);
?>
