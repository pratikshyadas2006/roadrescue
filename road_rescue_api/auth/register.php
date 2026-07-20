<?php

include("../config/db_connect.php");

$full_name = $_POST['full_name'] ?? '';
$email = $_POST['email'] ?? '';
$phone = $_POST['phone'] ?? '';
$password = $_POST['password'] ?? '';

if (empty($full_name) || empty($email) || empty($phone) || empty($password)) {
    echo json_encode([
        "success" => false,
        "message" => "All fields are required"
    ]);
    exit();
}

$sql = "INSERT INTO users (full_name, email, phone, password)
VALUES ('$full_name', '$email', '$phone', '$password')";

if (mysqli_query($conn, $sql)) {
    echo json_encode([
        "success" => true,
        "message" => "Registration Successful"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Registration Failed"
    ]);
}

mysqli_close($conn);

?>