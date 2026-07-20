<?php

include("../config/db_connect.php");

$user_id = $_GET['user_id'] ?? '';

if (empty($user_id)) {
    echo json_encode([
        "success" => false,
        "message" => "User ID is required"
    ]);
    exit();
}

$sql = "SELECT * FROM emergency_contacts WHERE user_id='$user_id'";

$result = mysqli_query($conn, $sql);

$contacts = [];

while ($row = mysqli_fetch_assoc($result)) {
    $contacts[] = $row;
}

echo json_encode([
    "success" => true,
    "contacts" => $contacts
]);

mysqli_close($conn);

?>