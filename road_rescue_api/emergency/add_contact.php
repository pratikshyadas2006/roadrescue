<?php

include("../config/db_connect.php");

$user_id = $_POST['user_id'] ?? '';
$name = $_POST['name'] ?? '';
$phone = $_POST['phone'] ?? '';
$relationship = $_POST['relationship'] ?? '';

if (empty($user_id) || empty($name) || empty($phone) || empty($relationship)) {
    echo json_encode([
        "success" => false,
        "message" => "All fields are required"
    ]);
    exit();
}

$sql = "INSERT INTO emergency_contacts (user_id, name, phone, relationship)
VALUES ('$user_id', '$name', '$phone', '$relationship')";

if (mysqli_query($conn, $sql)) {
    echo json_encode([
        "success" => true,
        "message" => "Emergency Contact Added Successfully"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to Add Contact"
    ]);
}

mysqli_close($conn);

?>