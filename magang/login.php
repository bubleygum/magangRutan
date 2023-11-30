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

// Login
$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';
$lastLogin = $_POST['lastLogin'] ?? '';
$sql = "SELECT userpass.UserId, userpass.Status, userpass.LastLogin, user.FullName FROM `userpass`
        INNER JOIN `user` ON userpass.UserId = user.UserId
        WHERE user.Email = '$email' AND userpass.Password = '$password'";
$result = $mysqli->query($sql);

if ($result->num_rows > 0) {
  $data = array();
  while ($row = $result->fetch_assoc()) {
    $data[] = $row;
  }
  $response = ['success' => true, 'data' => $data];
  $insertSql = "UPDATE userpass SET LastLogin='$lastLogin' WHERE UserId = (SELECT UserId FROM `user` WHERE Email = '$email')";
  $mysqli->query($insertSql);
} else {
  $response = ['success' => false, 'message' => "Invalid email or password"];
}
header('Content-Type: application/json');
echo json_encode($response);
?>
