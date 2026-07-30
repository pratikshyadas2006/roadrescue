<?php

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include("../config/db_connect.php");

// Accept POST data
$user_id = $_POST['user_id'] ?? '';
$contact_name = $_POST['contact_name'] ?? '';
$phone = $_POST['phone'] ?? '';
$relationship = $_POST['relationship'] ?? '';

// Validate
if (empty($user_id) || empty($contact_name) || empty($phone) || empty($relationship)) {
    echo json_encode([
        "success" => false,
        "message" => "All fields are required"
    ]);
    exit();
}

// Insert using prepared statement
$sql = "INSERT INTO emergency_contacts (user_id, contact_name, phone, relationship)
VALUES (?, ?, ?, ?)";

$stmt = $conn->prepare($sql);

$stmt->bind_param("isss", $user_id, $contact_name, $phone, $relationship);

if ($stmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "Emergency Contact Added Successfully"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => $stmt->error
    ]);
}

$stmt->close();
$conn->close();

?>