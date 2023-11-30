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
// check apa user sudah memilih cab rep
$check = $_POST['check'] ?? '';
$uId = $_POST['uId'] ?? '';
// $uId = "9";

if ($check != null) {
    $sql2 = "SELECT * FROM chat WHERE CustId = $uId";
    $result2 = $mysqli->query($sql2);

    if ($result2) {
        if ($result2->num_rows > 0) {
            $response = ['success' => true, 'message' => "success"];
        } else {
            $response = ['success' => false, 'message' => "failed"];
        }
    } else {
        $response = ['success' => false, 'message' => "failed"];
    }
}

// memilih cab rep
$selected = $_POST['selected'] ?? '';
// $selected = "true";
$repId = $_POST['repId'] ?? '';

if ($selected != null) {
    $sql2 = "SELECT * FROM chat WHERE CustId = $uId";
    $result2 = $mysqli->query($sql2);

    if ($result2) {
        if ($result2->num_rows > 0) {
            $response = ['success' => true, 'message' => "sudah memilih rep"];
        } else {
            $sql1 = "INSERT INTO chat (IdCabRep, CustId) VALUES ('$repId', '$uId')";
            $result1 = $mysqli->query($sql1);

            if ($result1) {
                $response = ['success' => true, 'message' => "success"];
            } else {
                $response = ['success' => false, 'message' => "failed ini"];
            }
        }
    } else {
        $response = ['success' => false, 'message' => "failed la"];
    }
}

// list cab rep

$sql = "SELECT * FROM cabangrep";
$result = $mysqli->query($sql);

if ($result) {
    if ($result->num_rows > 0) {
        $data = array();
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        $response = ['success' => true, 'data' => $data];
    } else {
        $response = ['success' => false, 'message' => "failed"];
    }
} else {
    $response = ['success' => false, 'message' => "failed"];
}

echo json_encode($response);


?>