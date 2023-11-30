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


$sql = "SELECT p.ProdName, p.ProdCode, pp.UrlPhoto 
FROM product p
LEFT JOIN Prodphoto pp ON p.ProdCode = pp.ProdCode
WHERE pp.StatusPhoto = 0";
$newest = $_POST['newest'] ?? '';
$bestSeller = $_POST['best'] ?? '';
$promo = $_POST['promo'] ?? '';
// $newest = 'true';
// $bestSeller = 'true';
// $promo = 'true';
if ($newest != null) {
    $sql = "SELECT p.ProdCode, p.ProdName, p.Description, dp.IdTaging, pp.UrlPhoto
    FROM product p
    JOIN dettagprod dp ON p.ProdCode = dp.ProdCode
    JOIN mtaging t ON dp.IdTaging = t.IdTaging
    LEFT JOIN Prodphoto pp ON p.ProdCode = pp.ProdCode
    WHERE t.IdTaging = 1 and pp.StatusPhoto = 0
    ";
} elseif ($bestSeller != null) {
    $sql = "SELECT p.ProdCode, p.ProdName, p.Description, dp.IdTaging, pp.UrlPhoto
    FROM product p
    JOIN dettagprod dp ON p.ProdCode = dp.ProdCode
    JOIN mtaging t ON dp.IdTaging = t.IdTaging
    LEFT JOIN Prodphoto pp ON p.ProdCode = pp.ProdCode
    WHERE t.IdTaging = 2 and pp.StatusPhoto = 0
    ";
} elseif ($promo != null) {
    $sql = "SELECT p.ProdCode, p.ProdName, p.Description, dp.IdTaging, pp.UrlPhoto
    FROM product p
    JOIN dettagprod dp ON p.ProdCode = dp.ProdCode
    JOIN mtaging t ON dp.IdTaging = t.IdTaging
    LEFT JOIN Prodphoto pp ON p.ProdCode = pp.ProdCode
    WHERE t.IdTaging = 3 and pp.StatusPhoto = 0
    ";
}
$result = $mysqli->query($sql);
if ($result->num_rows > 0) {
    $data = array();
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    $response = ['success' => true, 'data' => $data];
} else {
    $response = ['success' => false, 'message' => 'No prod list data found'];
}
echo json_encode($response);
?>