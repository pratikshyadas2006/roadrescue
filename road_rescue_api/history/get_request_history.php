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

$user_id = $_GET['user_id'] ?? $_POST['user_id'] ?? null;

if (!$user_id) {
    $rawInput = file_get_contents("php://input");
    $data = json_decode($rawInput, true);
    if ($data) {
        $user_id = $data['user_id'] ?? null;
    }
}

if (empty($user_id)) {
    echo json_encode([
        "success" => false,
        "message" => "User ID is required"
    ]);
    exit();
}

// Query your active breakdown_request table using a prepared statement
$sql = "SELECT request_id, vehicle_type, problen_type AS issue_type, latitude, longitude, status, created_at FROM breakdown_request WHERE user_id = ? ORDER BY request_id DESC";
$stmt = $conn->prepare($sql);

if ($stmt) {
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $history = [];
    while ($row = $result->fetch_assoc()) {
        $history[] = $row;
    }

    echo json_encode([
        "success" => true,
        "history" => $history
    ]);

    $stmt->close();
} else {
    echo json_encode([
        "success" => false,
        "message" => "Query prepare failed: " . $conn->error
    ]);
}

$conn->close();
?>