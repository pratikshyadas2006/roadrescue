<?php

include("../config/db_connect.php");

header("Content-Type: application/json");

$user_id = $_GET['user_id'] ?? '';

if (empty($user_id)) {
    echo json_encode([
        "success" => false,
        "message" => "User ID is required"
    ]);
    exit();
}

$query = "
    SELECT 
        n.notification_id,
        n.sos_id,
        n.contact_id,
        n.message,
        n.status,
        n.created_at
    FROM emergency_notifications n
    INNER JOIN sos_requests s ON n.sos_id = s.sos_id
    WHERE s.user_id = ?
    ORDER BY n.created_at DESC
";

$stmt = mysqli_prepare($conn, $query);

if (!$stmt) {
    echo json_encode([
        "success" => false,
        "message" => "Query preparation failed: " . mysqli_error($conn)
    ]);
    exit();
}

mysqli_stmt_bind_param($stmt, "i", $user_id);

mysqli_stmt_execute($stmt);

$result = mysqli_stmt_get_result($stmt);

$notifications = [];

while ($row = mysqli_fetch_assoc($result)) {
    $notifications[] = $row;
}

echo json_encode([
    "success" => true,
    "notifications" => $notifications
]);

mysqli_stmt_close($stmt);
mysqli_close($conn);

?>