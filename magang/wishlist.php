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

$uId = $_POST['uId'] ?? '';
// $uId = 6;
$removeId = $_POST['remove_id'] ?? '';

// Remove the wishlist item
if (!empty($removeId)) {
    $removeId = $mysqli->real_escape_string($removeId);
    $removeSql = "DELETE FROM wishlist WHERE ProdName = '$removeId' AND CustId = '$uId'";
    if ($mysqli->query($removeSql) === TRUE) {
        $response = ['success' => true, 'message' => 'Wishlist item removed successfully'];
        echo json_encode($response);
        exit;
    } else {
        $response = ['success' => false, 'message' => 'Failed to remove wishlist item'];
        echo json_encode($response);
        exit;
    }
}

$sql = "SELECT * FROM wishlist WHERE CustId = '$uId'";
$result = $mysqli->query($sql);

if ($result->num_rows > 0) {
    $data = array();
    while ($row = $result->fetch_assoc()) {
        $data[] = $row; 
    }
    $response = ['success' => true, 'data' => $data];
} else {
    $response = ['success' => false, 'message' => 'No wishlist data found'];
}
echo json_encode($response);

?>
