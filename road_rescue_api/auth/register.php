<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(0);
}

include("../config/db_connect.php");

// 1. Read JSON input stream
$raw_input = file_get_contents("php://input");
$data = json_decode($raw_input, true);

if (!is_array($data) || empty($data)) {
    $data = $_POST;
}

// 2. Extract and trim fields
$full_name = trim($data['full_name'] ?? '');
$email     = trim($data['email'] ?? '');
$phone     = trim($data['phone'] ?? '');
$password  = trim($data['password'] ?? '');

// 3. Check for empty fields
if (empty($full_name) || empty($email) || empty($phone) || empty($password)) {
    echo json_encode([
        "success" => false,
        "message" => "All fields are required"
    ]);
    exit();
}

// 4. Check duplicate email using user_id
$check_stmt = $conn->prepare("SELECT user_id FROM users WHERE email = ?");
$check_stmt->bind_param("s", $email);
$check_stmt->execute();
$check_stmt->store_result();

if ($check_stmt->num_rows > 0) {
    echo json_encode([
        "success" => false,
        "message" => "Email is already registered"
    ]);
    $check_stmt->close();
    $conn->close();
    exit();
}
$check_stmt->close();

// 5. Hash password and insert user
$hashed_password = password_hash($password, PASSWORD_BCRYPT);

$stmt = $conn->prepare("INSERT INTO users (full_name, email, phone, password) VALUES (?, ?, ?, ?)");
$stmt->bind_param("ssss", $full_name, $email, $phone, $hashed_password);

if ($stmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "Registration Successful"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Database error: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>