<?php

include("../config/db_connect.php");

$user_id = $_POST['user_id'] ?? '';
$latitude = $_POST['latitude'] ?? '';
$longitude = $_POST['longitude'] ?? '';
$location_address = $_POST['location_address'] ?? null;

if (empty($user_id) || $latitude === '' || $longitude === '') {
    echo json_encode([
        "success" => false,
        "message" => "user_id, latitude and longitude are required"
    ]);
    exit();
}

$stmt = mysqli_prepare($conn,
    "INSERT INTO sos_requests (user_id, latitude, longitude, location_address, status)
     VALUES (?, ?, ?, ?, 'Pending')"
);
mysqli_stmt_bind_param($stmt, "idds", $user_id, $latitude, $longitude, $location_address);

if (mysqli_stmt_execute($stmt)) {
    echo json_encode([
        "success" => true,
        "message" => "SOS Request Sent Successfully",
        "sos_id" => mysqli_insert_id($conn)
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to Send SOS Request"
    ]);
}

mysqli_stmt_close($stmt);
mysqli_close($conn);

?>