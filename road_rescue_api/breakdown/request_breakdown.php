<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Content-Type: application/json");

include("../config/db_connect.php");

$user_id = $_POST['user_id'] ?? '';
$vehicle_type = $_POST['vehicle_type'] ?? '';
$issue_type = $_POST['issue_type'] ?? '';
$latitude = $_POST['latitude'] ?? '';
$longitude = $_POST['longitude'] ?? '';

if (
    $user_id === '' ||
    $vehicle_type === '' ||
    $issue_type === '' ||
    $latitude === '' ||
    $longitude === ''
) {
    echo json_encode([
        "success" => false,
        "message" => "All fields are required"
    ]);
    exit();
}

$sql = "INSERT INTO breakdown_request
(user_id, vehicle_type, issue_type, latitude, longitude, status)
VALUES
('$user_id', '$vehicle_type', '$issue_type', '$latitude', '$longitude', 'Pending')";

if (mysqli_query($conn, $sql)) {

    echo json_encode([
        "success" => true,
        "message" => "Breakdown Request Sent Successfully"
    ]);

} else {

    echo json_encode([
        "success" => false,
        "message" => "Database Error: " . mysqli_error($conn)
    ]);
}

mysqli_close($conn);

?>