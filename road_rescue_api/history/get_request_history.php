<?php

header("Content-Type: application/json");

include("../config/db_connect.php");

$user_id = $_GET['user_id'] ?? '';

if ($user_id === '') {
    echo json_encode([
        "success" => false,
        "message" => "User ID is required"
    ]);
    exit();
}

$sql = "SELECT * FROM breakdown_request 
        WHERE user_id='$user_id' 
        ORDER BY request_id DESC";

$result = mysqli_query($conn, $sql);

if (!$result) {
    echo json_encode([
        "success" => false,
        "message" => "Database Error: " . mysqli_error($conn)
    ]);
    exit();
}

$history = [];

while ($row = mysqli_fetch_assoc($result)) {
    $history[] = $row;
}

echo json_encode([
    "success" => true,
    "history" => $history
]);

mysqli_close($conn);

?>