<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once __DIR__ . '/../config/db_connect.php';
require_once __DIR__ . '/../config/gemini_config.php';

if (!isset($conn) || $conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Database connection failed"]);
    exit();
}

$user_id = $_POST['user_id'] ?? null;

if ($user_id === null || $user_id === '') {
    echo json_encode(["success" => false, "message" => "user_id is required"]);
    exit();
}

if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
    echo json_encode(["success" => false, "message" => "An image file is required"]);
    exit();
}

$imagePath = $_FILES['image']['tmp_name'];
$mimeType = mime_content_type($imagePath);

$allowedMimes = ['image/jpeg', 'image/png', 'image/webp', 'image/heic'];
if (!in_array($mimeType, $allowedMimes)) {
    echo json_encode(["success" => false, "message" => "Unsupported image type: $mimeType"]);
    exit();
}

$imageData = file_get_contents($imagePath);
$imageBase64 = base64_encode($imageData);

// ---- Build the Gemini vision prompt ----
$prompt = "You are an AI vehicle breakdown assistant for the Road Rescue app. "
    . "The attached photo shows a dashboard warning light or indicator from a "
    . "vehicle's instrument cluster. Identify which warning light it is, explain "
    . "what it means, provide safety advice, whether the vehicle can still be "
    . "driven, a severity rating (Low, Medium, or High — how urgently this needs "
    . "attention), a recommended next step, and an estimated repair cost in Indian "
    . "Rupees (approximate). If no recognizable warning light is visible in the "
    . "photo, say so plainly in possible_cause and give general dashboard-check "
    . "guidance in the other fields. Keep the response concise, practical, and "
    . "easy to understand.";

$requestBody = [
    "contents" => [
        [
            "parts" => [
                ["text" => $prompt],
                [
                    "inline_data" => [
                        "mime_type" => $mimeType,
                        "data" => $imageBase64,
                    ],
                ],
            ]
        ]
    ],
    "generationConfig" => [
        "responseMimeType" => "application/json",
        "responseSchema" => [
            "type" => "OBJECT",
            "properties" => [
                "warning_light_identified" => ["type" => "STRING"],
                "possible_cause" => ["type" => "STRING"],
                "safety_advice" => ["type" => "STRING"],
                "can_be_driven" => ["type" => "STRING", "enum" => ["Yes", "No"]],
                "severity" => ["type" => "STRING", "enum" => ["Low", "Medium", "High"]],
                "recommended_next_step" => ["type" => "STRING"],
                "estimated_repair_cost" => ["type" => "STRING"],
            ],
            "required" => [
                "warning_light_identified",
                "possible_cause",
                "safety_advice",
                "can_be_driven",
                "severity",
                "recommended_next_step",
                "estimated_repair_cost",
            ],
        ],
    ],
];

$geminiUrl = "https://generativelanguage.googleapis.com/v1beta/models/" . GEMINI_MODEL . ":generateContent";

$ch = curl_init($geminiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Content-Type: application/json",
    "x-goog-api-key: " . GEMINI_API_KEY,
]);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($requestBody));
curl_setopt($ch, CURLOPT_TIMEOUT, 45);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);

$geminiResponseRaw = curl_exec($ch);
$curlError = curl_error($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($geminiResponseRaw === false) {
    echo json_encode(["success" => false, "message" => "Gemini API request failed: " . $curlError]);
    exit();
}

$geminiResponse = json_decode($geminiResponseRaw, true);

if ($httpCode !== 200 || !isset($geminiResponse['candidates'][0]['content']['parts'][0]['text'])) {
    $errMsg = $geminiResponse['error']['message'] ?? 'Unexpected response from the AI service.';
    echo json_encode(["success" => false, "message" => "Gemini error: " . $errMsg]);
    exit();
}

$aiResponseText = $geminiResponse['candidates'][0]['content']['parts'][0]['text'];
$aiParsed = json_decode($aiResponseText, true);

if (!$aiParsed || !isset($aiParsed['possible_cause'])) {
    echo json_encode(["success" => false, "message" => "Could not parse the AI response. Please try again."]);
    exit();
}

// ---- Save to database (ai_diagnosis table) ----
// Reuses the same history table as the text-based diagnosis flow, with
// a fixed user_message label so image-based entries are distinguishable
// in history views. If this insert fails, we still return the
// diagnosis rather than blocking on it.
$userMessageLabel = "[Image] Dashboard warning light photo";
$sql = "INSERT INTO ai_diagnosis (user_id, user_message, ai_response, created_at) VALUES (?, ?, ?, NOW())";
$stmt = $conn->prepare($sql);

if (!$stmt) {
    $conn->close();

    echo json_encode([
        "success" => false,
        "message" => "Failed to prepare diagnosis history."
    ]);
    exit();
}

$stmt->bind_param("iss", $user_id, $userMessageLabel, $aiResponseText);

if (!$stmt->execute()) {
    $stmt->close();
    $conn->close();

    echo json_encode([
        "success" => false,
        "message" => "Failed to save diagnosis history."
    ]);
    exit();
}

$stmt->close();
$conn->close();

// ---- Return the diagnosis to the app ----
echo json_encode([
    "success" => true,
    "diagnosis" => [
        "warning_light_identified" => $aiParsed['warning_light_identified'] ?? 'Not identified',
        "possible_cause" => $aiParsed['possible_cause'] ?? 'Not determined',
        "safety_advice" => $aiParsed['safety_advice'] ?? '',
        "can_be_driven" => $aiParsed['can_be_driven'] ?? 'No',
        "severity" => $aiParsed['severity'] ?? 'Medium',
        "recommended_next_step" => $aiParsed['recommended_next_step'] ?? '',
        "estimated_repair_cost" => $aiParsed['estimated_repair_cost'] ?? 'Not available',
    ],
]);
exit();