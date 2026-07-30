<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once __DIR__ . "/../config/db_connect.php";
$email = $_POST['email'] ?? '';
$new_password = $_POST['new_password'] ?? '';

if (empty($email) || empty($new_password)) {
    echo json_encode([
        "success" => false,
        "message" => "Email and new password are required"
    ]);
    exit();
}
$new_password = password_hash($new_password, PASSWORD_DEFAULT);

$sql = "UPDATE users SET password=? WHERE email=?";
$stmt = $conn->prepare($sql);

$stmt->bind_param("ss", $new_password, $email);

if ($stmt->execute()) {

    if ($stmt->affected_rows > 0) {
        echo json_encode([
            "success" => true,
            "message" => "Password updated successfully"
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Email not found"
        ]);
    }

} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to update password"
    ]);
}

$stmt->close();
$conn->close();