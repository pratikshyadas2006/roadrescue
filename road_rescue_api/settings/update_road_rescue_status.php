<?php

include("../config/db_connect.php");

$user_id = $_POST['user_id'] ?? '';
$status = $_POST['status'] ?? '';

if (empty($user_id) || empty($status)) {
    echo json_encode([
        "success" => false,
        "message" => "User ID and Status are required"
    ]);
    exit();
}

$sql = "UPDATE road_rescue_status SET status='$status' WHERE user_id='$user_id'";

if (mysqli_query($conn, $sql)) {
    echo json_encode([
        "success" => true,
        "message" => "Road Rescue Status Updated"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Update Failed"
    ]);
}

mysqli_close($conn);

?>