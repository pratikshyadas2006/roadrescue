<?php
$host = "localhost";
$user = "root";
$password = ""; // Default XAMPP MySQL password is empty
$database = "road_rescue"; // Make sure this database exists in phpMyAdmin

$conn = new mysqli($host, $user, $password, $database);

if ($conn->connect_error) {
    die(json_encode([
        "success" => false,
        "message" => "Database connection failed: " . $conn->connect_error
    ]));
}
?>