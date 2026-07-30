<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

error_reporting(0);
ini_set('display_errors', 0);

require_once __DIR__ . '/../config/db_connect.php';

if (!isset($conn) || $conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Database connection failed"]);
    exit();
}

// Read payload from $_POST or raw JSON body
$user_id = $_POST['user_id'] ?? null;
$vehicle_type = $_POST['vehicle_type'] ?? null;
$issue_type = $_POST['issue_type'] ?? null;
$latitude = $_POST['latitude'] ?? null;
$longitude = $_POST['longitude'] ?? null;

if (!$user_id) {
    $rawInput = file_get_contents("php://input");
    $data = json_decode($rawInput, true);
    if ($data) {
        $user_id = $data['user_id'] ?? null;
        $vehicle_type = $data['vehicle_type'] ?? null;
        $issue_type = $data['issue_type'] ?? null;
        $latitude = $data['latitude'] ?? null;
        $longitude = $data['longitude'] ?? null;
    }
}

// Validate fields
if ($user_id === null || $user_id === '' || 
    $vehicle_type === null || $vehicle_type === '' || 
    $issue_type === null || $issue_type === '' || 
    $latitude === null || $latitude === '' || 
    $longitude === null || $longitude === '') {

    echo json_encode(["success" => false, "message" => "All fields are required"]);
    exit();
}

// Insert into breakdown_request table
$sql = "INSERT INTO breakdown_request (user_id, vehicle_type, problen_type, latitude, longitude, status) VALUES (?, ?, ?, ?, ?, 'pending')";
$stmt = $conn->prepare($sql);

if ($stmt) {
    $stmt->bind_param("issss", $user_id, $vehicle_type, $issue_type, $latitude, $longitude);
    if ($stmt->execute()) {
        echo json_encode([
            "success" => true, 
            "message" => "Breakdown Request Sent Successfully"
        ]);
    } else {
        echo json_encode([
            "success" => false, 
            "message" => "Execution error: " . $stmt->error
        ]);
    }
    $stmt->close();
} else {
    echo json_encode([
        "success" => false, 
        "message" => "Prepare error: " . $conn->error
    ]);
}

$conn->close();
?>