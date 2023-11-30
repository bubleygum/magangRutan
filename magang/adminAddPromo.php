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

if (isset($_FILES["image"])) {
    $promoName = $_POST['promoName'] ?? '';
    $descPromo = $_POST['descPromo'] ?? '';
    $keterangan = $_POST['keterangan'] ?? '';
    $releaseDate = $_POST['releaseDate'] ?? '';
    $endDate = $_POST['endDate'] ?? '';
    $createdBy = $_POST['createdBy'] ?? '';
    $status = $_POST['status'] ?? '';

    $sql = "INSERT INTO `promotion` (`PromoName`, `DescPromo`, `Keterangan`, `ReleaseDate`, `Status`, `CreatedDate`, `CreatedBy`, `EndDate`) 
    VALUES ('$promoName', '$descPromo', '$keterangan', '$releaseDate', '$status', CURRENT_TIMESTAMP,'$createdBy', '$endDate')";
    $result = $mysqli->query($sql);

    if ($result) {
        // Get the last inserted ID
        $lastInsertedId = $mysqli->insert_id;

        $targetDir = "C:/xampp/htdocs/imgMagang/";

        if (!empty($_FILES["image"]["tmp_name"])) {
            $originalFileName = basename($_FILES["image"]["name"]);
            $uniqueFileName = generateUniqueFileName($targetDir, $lastInsertedId, $originalFileName);
            $targetFile = $targetDir . $uniqueFileName;

            $imageFileType = strtolower(pathinfo($targetFile, PATHINFO_EXTENSION));
            $check = getimagesize($_FILES["image"]["tmp_name"]);

            if ($check === false || empty($_FILES["image"]["tmp_name"])) {
                $response = ['success' => false, 'message' => 'File is not an image or path is empty.'];
            } else if (file_exists($targetFile)) {
                $response = ['success' => false, 'message' => 'Sorry, file already exists.'];
            } else if ($_FILES["image"]["size"] > 500000) {
                $response = ['success' => false, 'message' => 'Sorry, your file is too large.'];
            } else if ($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg" && $imageFileType != "gif") {
                $response = ['success' => false, 'message' => 'Sorry, only JPG, JPEG, PNG & GIF files are allowed.'];
            } else {
                if (move_uploaded_file($_FILES["image"]["tmp_name"], $targetFile)) {
                    $sqlInsert = "INSERT INTO `imgpromo` (`ImgPromo`, `IdPromo`) VALUES ('$uniqueFileName','$lastInsertedId')";
                    $resultInsert = $mysqli->query($sqlInsert);
                
                    if ($resultInsert) {
                        $response = ['success' => true, 'message' => 'Image uploaded successfully.'];
                    } else {
                        $response = ['success' => false, 'message' => 'Failed to insert image in the database. Error: ' . $mysqli->error];
                    }
                } else {
                    $response = ['success' => false, 'message' => 'Sorry, there was an error uploading your file. Error: ' . $_FILES["image"]["error"]];
                }
                
            }
        } else {
            $response = ['success' => false, 'message' => 'Image file not found.'];
        }
    } else {
        $response = ['success' => false, 'message' => 'Failed to insert promotion data.'];
    }
} else {
    $response = ['success' => false, 'message' => 'Image file not found.'];
}

echo json_encode($response);
$mysqli->close();
?>
