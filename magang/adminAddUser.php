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

$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';
$email = $_POST['email'] ?? '';
$noHP = $_POST['noHP'] ?? '';
$alamat = $_POST['alamat'] ?? '';
$prov = $_POST['prov'] ?? '';
$kabKota = $_POST['kabKota'] ?? '';
$kec = $_POST['kec'] ?? '';
$kel = $_POST['kel'] ?? '';
$kodPos = $_POST['kodPos'] ?? '';
$userJob = $_POST['userJob'] ?? '';
$createdDate = $_POST['createdDate'] ?? '';
$userStat = $_POST['userStat'] ?? '';


$sql = "INSERT INTO `user` (`FullName`, `Hp`, `Email`, `Alamat`, `provinsi`, `KotaKab`, `Kecamatan`, `Kelurahan`, `KodePos`, `Keterangan`, `CreatedDate`, `StatusUser`) 
VALUES ('$username', '$noHP', '$email', '$alamat', '$prov', '$kabKota', '$kec', '$kel', '$kodPos', '$userJob', '$createdDate', '$userStat')";
$result = $mysqli->query($sql);

if ($result) {
    $sql2 = "INSERT INTO `userpass` (`NamaLengkap`, `Password`, `Status`, `LastLogin`) 
    VALUES ('$username', '$password', '$userStat', '$createdDate')";

    $next = $mysqli->query($sql2);
    if($next){
      $response = ['success' => true, 'message' => ('sukses 1')];
    }else{
      $response = ['success' => false, 'message' => ("gagal 1")];
    }
    $response = ['success' => true, 'message' => ('sukses 2')];
  
} else {
  $response = ['success' => false, 'message' => ("gagal 2")];
}
echo json_encode($response);
?>