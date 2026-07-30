<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Turn off error output to ensure clean JSON responses
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once 'config/db_connect.php'; 

$rawInput = file_get_contents("php://input");
$data = json_decode($rawInput, true);

if (!$data) {
    echo json_encode([
        "success" => false,
        "message" => "No JSON payload received."
    ]);
    exit();
}

$user_id = isset($data['user_id']) ? intval($data['user_id']) : 0;
$full_name = isset($data['full_name']) ? trim($data['full_name']) : '';
$phone = isset($data['phone']) ? trim($data['phone']) : '';

if ($user_id <= 0 || empty($full_name) || empty($phone)) {
    echo json_encode([
        "success" => false,
        "message" => "Missing required fields (user_id, full_name, or phone)."
    ]);
    exit();
}

// Fixed: Changed 'WHERE id = ?' to 'WHERE user_id = ?'
$query = "UPDATE users SET full_name = ?, phone = ? WHERE user_id = ?";
$stmt = $conn->prepare($query);

if ($stmt) {
    $stmt->bind_param("ssi", $full_name, $phone, $user_id);
    
    if ($stmt->execute()) {
        echo json_encode([
            "success" => true,
            "message" => "Profile updated successfully."
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Database execution error."
        ]);
    }
    $stmt->close();
} else {
    echo json_encode([
        "success" => false,
        "message" => "SQL statement preparation failed."
    ]);
}
?>