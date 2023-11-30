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
$nama = $_POST['nama'] ?? '';
$email = $_POST['email'] ?? '';
$noHP = $_POST['noHP'] ?? '';
$oldPass = $_POST['oldPass'] ?? '';
$newPass = $_POST['newPass'] ?? '';
// $uId = "6";
// $oldPass = "test2Pass!";
// $newPass = "newPass!";

$sql = "UPDATE user SET FullName ='$nama', Email ='$email', Hp ='$noHP' WHERE UserId = '$uId'";
$sql4 = "UPDATE userpass SET NamaLengkap ='$nama' WHERE UserId = '$uId'";
$result = $mysqli->query($sql);
$result4 = $mysqli->query($sql4);
if ($oldPass != null && $newPass != null) {
    $sql2 = "SELECT * FROM userpass WHERE UserId = '$uId'";
    $result2 = $mysqli->query($sql2);
    
    $row = $result2->fetch_assoc();
    $actualPassword = $row['Password'];

    if ($result2 && $oldPass == $actualPassword) {
        $sql3 = "UPDATE userpass SET NamaLengkap ='$nama', Password = '$newPass' WHERE UserId = '$uId'";
        $result3 = $mysqli->query($sql3);

        if (!$result3) {
            $response = ['success' => false, 'message' => 'Password update failed'];
        } else {
            $response = ['success' => true, 'message' => 'Password updated'];
        }
    } else {
        $response = ['success' => false, 'message' => 'Incorrect old password'];
    }
} else {
    if (!$result || !$result4) {
        $response = ['success' => false, 'message' => 'Update failed'];
    } else {
        $response = ['success' => true, 'message' => 'Updated'];
    }
}

echo json_encode($response);
?>
