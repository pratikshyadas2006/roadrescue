<?php

header("Content-Type: application/json");

include "../config/db_connect.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    $contact_id = $_POST["contact_id"] ?? null;

    if (!$contact_id) {
        echo json_encode([
            "success" => false,
            "message" => "Contact ID is required"
        ]);
        exit;
    }

    $sql = "DELETE FROM emergency_contacts WHERE contact_id = ?";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $contact_id);

    if ($stmt->execute()) {

        if ($stmt->affected_rows > 0) {
            echo json_encode([
                "success" => true,
                "message" => "Emergency contact deleted successfully"
            ]);
        } else {
            echo json_encode([
                "success" => false,
                "message" => "Contact not found"
            ]);
        }

    } else {
        echo json_encode([
            "success" => false,
            "message" => "Failed to delete contact"
        ]);
    }

    $stmt->close();

} else {
    echo json_encode([
        "success" => false,
        "message" => "Invalid request method"
    ]);
}

$conn->close();

?>