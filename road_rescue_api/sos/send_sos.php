<?php

include("../config/db_connect.php");

header("Content-Type: application/json");

// Check database connection
if (!$conn) {
    echo json_encode([
        "success" => false,
        "message" => "Database connection failed"
    ]);
    exit();
}

// Get POST data
$user_id = $_POST['user_id'] ?? '';
$latitude = $_POST['latitude'] ?? '';
$longitude = $_POST['longitude'] ?? '';
$location_address = $_POST['location_address'] ?? null;

// Validate required fields
if (empty($user_id) || $latitude === '' || $longitude === '') {

    echo json_encode([
        "success" => false,
        "message" => "user_id, latitude and longitude are required"
    ]);

    exit();
}

// Insert SOS request
$query = "INSERT INTO sos_requests 
          (user_id, latitude, longitude, location_address, status)
          VALUES (?, ?, ?, ?, 'Pending')";

$stmt = mysqli_prepare($conn, $query);

if (!$stmt) {
    echo json_encode([
        "success" => false,
        "message" => "Query preparation failed"
    ]);
    exit();
}

// Bind values
mysqli_stmt_bind_param(
    $stmt,
    "idds",
    $user_id,
    $latitude,
    $longitude,
    $location_address
);

// Execute query
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