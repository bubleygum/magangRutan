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

$kategori = $_POST['kategori'] ?? '';
// $kategori = 1;
$sql = "SELECT p.ProdName, p.ProdCode, pp.UrlPhoto 
        FROM product p
        INNER JOIN detkatprod dp ON p.ProdCode = dp.prodcode
        LEFT JOIN Prodphoto pp ON p.ProdCode = pp.ProdCode
        WHERE dp.IdKategori = $kategori AND pp.StatusPhoto = 0"; //status photo perlu diganti 1 (main picture)

if($kategori == "All"){
    $sql = "SELECT p.ProdName, p.ProdCode, pp.UrlPhoto 
        FROM product p
        LEFT JOIN Prodphoto pp ON p.ProdCode = pp.ProdCode";
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
