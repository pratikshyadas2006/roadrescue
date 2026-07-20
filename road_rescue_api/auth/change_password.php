<?php

include("../config/db_connect.php");

$email = $_POST['email'] ?? '';
$new_password = $_POST['new_password'] ?? '';

if (empty($email) || empty($new_password)) {
    echo json_encode([
        "success" => false,
        "message" => "Email and New Password are required"
    ]);
    exit();
}

$sql = "UPDATE users SET password='$new_password' WHERE email='$email'";

if (mysqli_query($conn, $sql) && mysqli_affected_rows($conn) > 0) {
    echo json_encode([
        "success" => true,
        "message" => "Password Updated Successfully"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "User Not Found or Password Not Updated"
    ]);
}

mysqli_close($conn);

?>