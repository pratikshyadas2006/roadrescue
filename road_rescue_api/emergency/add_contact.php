<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

include("../config/db_connect.php");

$user_id = $_POST['user_id'] ?? '';
$contact_name = $_POST['contact_name'] ?? '';
$phone = $_POST['phone'] ?? '';
$relationship = $_POST['relationship'] ?? '';

if (
    empty($user_id) ||
    empty($contact_name) ||
    empty($phone) ||
    empty($relationship)
) {
    echo json_encode([
        "success" => false,
        "message" => "All fields are required"
    ]);
    exit();
}

$sql = "INSERT INTO emergency_contacts (user_id, contact_name, phone, relationship) VALUES ('$user_id', '$contact_name', '$phone', '$relationship')";

if (mysqli_query($conn, $sql)) {
    echo json_encode([
        "success" => true,
        "message" => "Emergency Contact Added Successfully"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to Add Contact: " . mysqli_error($conn)
    ]);
}

mysqli_close($conn);
?>