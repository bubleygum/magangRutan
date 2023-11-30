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


$sql = "SELECT DISTINCT chat.CustId, chat.IdCabRep FROM chat";
$result = $mysqli->query($sql);

if ($result) {
    $data = [];
    while ($row = $result->fetch_assoc()) {
        $customerId = $row['CustId'];
        $sql2 = "SELECT FullName FROM user WHERE UserId = '$customerId'";
        $result2 = $mysqli->query($sql2);

        if ($result2 && $result2->num_rows > 0) {
            $customerRow = $result2->fetch_assoc();
            $customerFullName = $customerRow['FullName'];
            $row['CustName'] = $customerFullName;
        } else {
            $row['CustName'] = 'Unknown';
        }

        $data[] = $row;
    }
    $response = ['success' => true, 'data' => $data];
} else {
    $response = ['success' => false, 'message' => 'No admin chat list data found'];
}

echo json_encode($response);
?>