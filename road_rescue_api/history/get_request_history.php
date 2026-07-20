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

$sql = "SELECT * FROM request_history WHERE user_id='$user_id' ORDER BY history_id DESC";

$result = mysqli_query($conn, $sql);

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