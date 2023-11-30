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

$sql = "SELECT * FROM user";
$result = $mysqli->query($sql);


if ($result) {
    $data = array();
    while ($row = $result->fetch_assoc()) {
        $userId = $row['UserId'];
        $sql2 = "SELECT LastLogin FROM userpass WHERE UserId = '$userId'";
        $result2 = $mysqli->query($sql2);

        // Check if there is data available for the user in the second query
        if ($result2 && $result2->num_rows > 0) {
            $row2 = $result2->fetch_assoc();
            $row['LastLogin'] = $row2['LastLogin'];
        } else {
            $row['LastLogin'] = "00:00:00"; // or any default value if you prefer
        }

        $data[] = $row;
    }

    $response = ['success' => true, 'data' => $data];
} else {
    $response = ['success' => false, 'message' => 'No admin user list data found'];
}

$jumlah = $_POST['jumlah'] ?? '';
if ($jumlah != null) {
    $sql2 = "SELECT COUNT(*) AS total FROM user";
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