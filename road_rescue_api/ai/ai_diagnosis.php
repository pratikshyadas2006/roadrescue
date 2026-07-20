<?php

include("../config/db_connect.php");

$user_id = $_POST['user_id'] ?? '';
$issue = $_POST['issue'] ?? '';
$diagnosis = $_POST['diagnosis'] ?? '';

if (empty($user_id) || empty($issue) || empty($diagnosis)) {
    echo json_encode([
        "success" => false,
        "message" => "All fields are required"
    ]);
    exit();
}

$sql = "INSERT INTO ai_diagnosis (user_id, issue, diagnosis)
VALUES ('$user_id', '$issue', '$diagnosis')";

if (mysqli_query($conn, $sql)) {
    echo json_encode([
        "success" => true,
        "message" => "Diagnosis Saved Successfully"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to Save Diagnosis"
    ]);
}

mysqli_close($conn);

?>