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
//send to wishlist
$addCode = $_POST['addCode'] ?? '';
$uId = $_POST['uId'] ?? '';
$addTime = $_POST['addTime'] ?? '';
$picUrl = $_POST['picUrl'] ?? '';
if (!empty($addCode)) {
    // Check if the item is already in the wishlist
    $checkSql = "SELECT * FROM `wishlist` WHERE `ProdName`='$addCode' AND `CustId`='$uId'";
    $checkResult = $mysqli->query($checkSql);

    if ($checkResult->num_rows > 0) {
        $response = ['success' => false, 'message' => 'Item already added to the wishlist'];
    } else {
        $addSql = "INSERT INTO `wishlist` (`ProdName`, `CustId`, `AddedDate`, `PhotoUrl`) 
        VALUES ('$addCode', '$uId','$addTime','$picUrl')";

        if ($mysqli->query($addSql) === TRUE) {
            $response = ['success' => true, 'message' => 'Wishlist item added successfully'];
        } else {
            $response = ['success' => false, 'message' => 'Failed to add wishlist item'];
        }
    }

    echo json_encode($response);
    exit;
}

//product detail
$prodCode = $_POST['prodCode'] ?? '';
$viewBy = $_POST['userId'] ?? '';
$timeView = $_POST['timeView'] ?? '';
$sql = "SELECT * FROM product WHERE ProdCode = '$prodCode'";
$result = $mysqli->query($sql);

$sql2 = "SELECT UrlPhoto FROM prodphoto WHERE ProdCode = '$prodCode' ORDER BY CASE WHEN StatusPhoto = 'Main' THEN 0 ELSE 1 END, Seq";
$result2 = $mysqli->query($sql2);

$sql3 = "INSERT INTO prodanalytic (ProdCode, ViewBy, TimeView) 
VALUES ('$prodCode', '$viewBy', '$timeView')";
$result3 = $mysqli->query($sql3);

if ($result3 === TRUE) {
    $response = ['success' => true, 'message' => 'Success to insert data into prodanalytic'];
} else {
    $response = ['success' => false, 'message' => 'Failed to insert data into prodanalytic'];
}


if ($result->num_rows > 0) {
    $data = $result->fetch_assoc();

    if ($result2->num_rows > 0) {
        $photos = [];
        while ($row = $result2->fetch_assoc()) {
            $photos[] = $row;
        }
        $data['photos'] = $photos;
    }

    $response = ['success' => true, 'data' => $data];
} else {
    $response = ['success' => false, 'message' => 'No product data found'];
}

echo json_encode($response);


?>