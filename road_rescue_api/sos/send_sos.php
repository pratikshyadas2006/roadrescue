<?php
// Response ko JSON format me set karne ke liye
header('Content-Type: application/json');

include("../config/db_connect.php");

$user_id = $_POST['user_id'] ?? '';
$latitude = $_POST['latitude'] ?? '';
$longitude = $_POST['longitude'] ?? '';
$location_address = $_POST['location_address'] ?? null;

if (empty($user_id) || $latitude === '' || $longitude === '') {
    echo json_encode([
        "success" => false,
        "message" => "user_id, latitude and longitude are required"
    ]);
    exit();
}

$stmt = mysqli_prepare($conn,
    "INSERT INTO sos_requests (user_id, latitude, longitude, location_address, status)
     VALUES (?, ?, ?, ?, 'Pending')"
);
mysqli_stmt_bind_param($stmt, "idds", $user_id, $latitude, $longitude, $location_address);

// Execute SOS query
if (mysqli_stmt_execute($stmt)) {

    // Get the created SOS ID
    $sos_id = mysqli_insert_id($conn);

    // Get all emergency contacts for this user
    $contacts_query = "
        SELECT contact_id, contact_name
        FROM emergency_contacts
        WHERE user_id = ?
    ";

    $contacts_stmt = mysqli_prepare($conn, $contacts_query);
    mysqli_stmt_bind_param($contacts_stmt, "i", $user_id);
    mysqli_stmt_execute($contacts_stmt);

    $result = mysqli_stmt_get_result($contacts_stmt);
    $notification_count = 0;

    // Create notification entry for every emergency contact
    while ($contact = mysqli_fetch_assoc($result)) {

        $message = "🚨 EMERGENCY ALERT! An emergency has been detected. Location: https://www.google.com/maps?q=" .
                   $latitude . "," . $longitude;

        $notification_query = "
            INSERT INTO emergency_notifications
            (sos_id, contact_id, message, status)
            VALUES (?, ?, ?, 'Sent')
        ";

        $notification_stmt = mysqli_prepare($conn, $notification_query);
        if ($notification_stmt) {
            mysqli_stmt_bind_param(
                $notification_stmt,
                "iis",
                $sos_id,
                $contact['contact_id'],
                $message
            );

            if (mysqli_stmt_execute($notification_stmt)) {
                $notification_count++;
            }

            mysqli_stmt_close($notification_stmt);
        }
    }

    mysqli_stmt_close($contacts_stmt);

    // Final Success Response
    echo json_encode([
        "success" => true,
        "message" => "SOS Request Sent Successfully",
        "sos_id" => $sos_id,
        "notifications_created" => $notification_count
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to Send SOS Request"
    ]);
}

mysqli_stmt_close($stmt);
mysqli_close($conn);

?>