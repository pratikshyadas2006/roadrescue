<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(0);
}

include("../config/db_connect.php");

// Read JSON input stream
$raw_input = file_get_contents("php://input");
$data = json_decode($raw_input, true);
file_put_contents("debug.txt", "RAW: ".$raw_input.PHP_EOL, FILE_APPEND);
file_put_contents("debug.txt", "POST: ".print_r($_POST, true).PHP_EOL, FILE_APPEND);
file_put_contents("debug.txt", "DATA: ".print_r($data, true).PHP_EOL, FILE_APPEND);

if (!is_array($data) || empty($data)) {
    $data = $_POST;
}

$email    = trim($data['email'] ?? '');
$password = trim($data['password'] ?? '');

// Validate required fields
if (empty($email) || empty($password)) {
    echo json_encode([
        "success" => false,
        "message" => "Email and password are required"
    ]);
    exit();
}

// Fetch user by email
$stmt = $conn->prepare("SELECT user_id, full_name, email, phone, password FROM users WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {
    $user = $result->fetch_assoc();
    
    // Verify password hash
    file_put_contents("debug.txt", "Entered Password: $password\n", FILE_APPEND);
file_put_contents("debug.txt", "DB Password: ".$user['password']."\n", FILE_APPEND);
file_put_contents("debug.txt", "Verify: ".(password_verify($password, $user['password']) ? "TRUE" : "FALSE")."\n\n", FILE_APPEND);
    if (password_verify($password,$user['password'])){
        echo json_encode([
            "success" => true,
            "message" => "Login Successful",
            "user" => [
                "user_id"   => $user['user_id'],
                "full_name" => $user['full_name'],
                "email"     => $user['email'],
                "phone"     => $user['phone'],
            ]
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Invalid credentials"
        ]);
    }
} else {
    echo json_encode([
        "success" => false,
        "message" => "Account not found"
    ]);
}

$stmt->close();
$conn->close();
?>