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

function generateUniqueFileName($targetDir, $idPromo, $originalFileName)
{
    $extension = pathinfo($originalFileName, PATHINFO_EXTENSION);
    $uniqueName = $idPromo . '.' . $extension;
    $counter = 1;

    while (file_exists($targetDir . $uniqueName)) {
        $uniqueName = $idPromo . '_' . $counter . '.' . $extension;
        $counter++;
    }

    return $uniqueName;
}



cors();

$mysqli = new mysqli("localhost", "root", "", "magang2");
if ($mysqli->connect_error) {
    die("Connection failed: " . $mysqli->connect_error);
}

$idPromo = $_POST['idPromo'] ?? '';
// echo($idPromo);
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // $targetDir = "C:/xampp/htdocs/imgMagang/";
    // // $targetDir="C:/Users/Gabriella/Documents/GitHub/magangRutan/app/assets";
    // $originalFileName = basename($_FILES[$idPromo]["name"]);
    // $uniqueFileName = generateUniqueFileName($idPromo, $originalFileName); 
    // $targetFile = $targetDir . $uniqueFileName;
    // // $imgSource = "http://localhost/imgMagang/$uniqueFileName";
    // // $imgSource = "assets/".$uniqueFileName;
    // $imageFileType = strtolower(pathinfo($targetFile, PATHINFO_EXTENSION));

    $targetDir = "C:/xampp/htdocs/imgMagang/";
    $originalFileName = basename($_FILES["image"]["name"]);
    $idPromo = $_POST['idPromo'] ?? '';
    $uniqueFileName = generateUniqueFileName($targetDir, $idPromo, $originalFileName);
    $targetFile = $targetDir . $uniqueFileName;

    $imageFileType = strtolower(pathinfo($targetFile, PATHINFO_EXTENSION));
    $check = getimagesize($_FILES["image"]["tmp_name"]);
    if ($check === false) {
        $response = ['success' => false, 'message' => 'File is not an image.'];
    }else if (file_exists($targetFile)) {
        $response = ['success' => false, 'message' => 'Sorry, file already exists.'];
        echo "Sorry, file already exists.";
    }else if ($_FILES["image"]["size"] > 500000) {
        echo "Sorry, your file is too large.";
        $response = ['success' => false, 'message' => 'Sorry, your file is too large.'];
    }else if ($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg" && $imageFileType != "gif") {
        echo "Sorry, only JPG, JPEG, PNG & GIF files are allowed.";
        $response = ['success' => false, 'message' => 'Sorry, only JPG, JPEG, PNG & GIF files are allowed.'];

    }else if (move_uploaded_file($_FILES["image"]["tmp_name"], $targetFile)) {
        // $sql = "UPDATE promotion SET ImgPromo = '$imgSource' WHERE IdPromo = '$idPromo'";
        $sql = "UPDATE promotion SET ImgPromo = '$uniqueFileName' WHERE IdPromo = '$idPromo'";
        if ($mysqli->query($sql) === TRUE) {
            $response = ['success' => true, 'message' => 'Image uploaded successfully.'];
        } else {
            $response = ['success' => false, 'message' => 'Failed to upload image to database.'];
        }
    } else {
        $response = ['success' => false, 'message' => 'Sorry, there was an error uploading your file.'];
    }
}
echo json_encode($response);
$mysqli->close();
?>
