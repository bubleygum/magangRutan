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

// Update the status of promotions
$updateSql = "UPDATE promotion
SET Status = 
    CASE 
        WHEN EndDate < CURRENT_DATE AND Status = 1 THEN 0
        WHEN ReleaseDate >= CURRENT_DATE AND Status = 0 THEN 1
        ELSE Status
    END";

$resultUpdate = $mysqli->query($updateSql);

// Retrieve image URLs for active promotions
$selectSql = "SELECT a.idpromo, b.ImgPromo
from promotion a 
LEFT JOIN imgpromo b 
on a.IdPromo = b.IdPromo WHERE a.Status = 1;";

$resultSelect = $mysqli->query($selectSql);

if ($resultSelect->num_rows > 0) {
    $data = array();
    while ($row = $resultSelect->fetch_assoc()) {
        $data[] = $row;
    }
    $response = ['success' => true, 'data' => $data];
} else {
    $response = ['success' => false, 'message' => 'No carousel data found'];
}
echo json_encode($response);
?>