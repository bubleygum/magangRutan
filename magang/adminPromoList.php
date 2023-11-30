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

$todayDate = date("Y-m-d");

// Update the status of promotions
$updateSql = "UPDATE promotion SET Status = CASE 
                      WHEN EndDate < CURRENT_DATE AND Status = 1 THEN 0
                      WHEN ReleaseDate >= CURRENT_DATE AND Status = 0 THEN 1
                      ELSE Status
                  END";

$resultUpdate = $mysqli->query($updateSql);

// Fetch the promotion data
$sql = "SELECT p.*, i.ImgPromo
FROM promotion p
LEFT JOIN imgpromo i ON p.IdPromo = i.IdPromo;
";
$result = $mysqli->query($sql);

if ($result) {
    $data = array();
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    $response = ['success' => true, 'data' => $data];
} else {
    $response = ['success' => false, 'message' => 'No admin promo list data found'];
}

$jumlah = $_POST['jumlah'] ?? '';
// $jumlah = 'true';
if ($jumlah != null) {
    $sql2 = "SELECT COUNT(*) AS total FROM promotion WHERE Status = 1";
    $result2 = $mysqli->query($sql2);

    if ($result2) {
        $row = $result2->fetch_assoc();
        $totalRows = $row['total'];
        $response = ['success' => true, 'total_rows' => $totalRows];
    } else {
        $response = ['success' => false, 'message' => 'Failed to get the total number of rows'];
    }
}

echo json_encode($response);
?>