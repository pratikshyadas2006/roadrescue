<?php

include("../config/db_connect.php");

$user_id = $_POST['user_id'] ?? '';
$vehicle_type = $_POST['vehicle_type'] ?? '';
$issue_type = $_POST['issue_type'] ?? '';
$description = $_POST['description'] ?? '';
$latitude = $_POST['latitude'] ?? '';
$longitude = $_POST['longitude'] ?? '';

if (
    empty($user_id) ||
    empty($vehicle_type) ||
    empty($issue_type) ||
    empty($description) ||
    empty($latitude) ||
    empty($longitude)
) {
    echo json_encode([
        "success" => false,
        "message" => "All fields are required"
    ]);
    exit();
}

$sql = "INSERT INTO breakdown_request
(user_id, vehicle_type, issue_type, description, latitude, longitude)
VALUES
('$user_id', '$vehicle_type', '$issue_type', '$description', '$latitude', '$longitude')";

if (mysqli_query($conn, $sql)) {
    echo json_encode([
        "success" => true,
        "message" => "Breakdown Request Sent Successfully"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to Send Request"
    ]);
}

mysqli_close($conn);

?>