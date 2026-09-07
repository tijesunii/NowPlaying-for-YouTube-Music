<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Same token as in the Chrome extension
define('SECRET_TOKEN', 'eben_custom_tracker_secret_2026');
define('DATA_FILE', __DIR__ . '/current-track.json');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// -----------------------------------------------------
// GET REQUEST: Serve the current track to the portfolio
// -----------------------------------------------------
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    header('Content-Type: application/json');
    
    if (file_exists(DATA_FILE)) {
        echo file_get_contents(DATA_FILE);
    } else {
        // Return a default state if no data exists yet
        echo json_encode([
            'is_playing' => false,
            'title' => 'Nothing playing',
            'artist' => '',
            'image' => ''
        ]);
    }
    exit;
}

// -----------------------------------------------------
// POST REQUEST: Receive updates from Chrome Extension
// -----------------------------------------------------
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // 1. Read Payload
    $jsonPayload = file_get_contents('php://input');
    $data = json_decode($jsonPayload, true);

    // 2. Authenticate Request
    if (!isset($data['secret']) || $data['secret'] !== SECRET_TOKEN) {
        http_response_code(403);
        echo json_encode(['error' => 'Unauthorized']);
        exit;
    }

    if ($data && isset($data['title'])) {
        file_put_contents(DATA_FILE, json_encode([
            'is_playing' => (bool) $data['is_playing'],
            'title' => htmlspecialchars($data['title'], ENT_QUOTES, 'UTF-8'),
            'artist' => htmlspecialchars($data['artist'], ENT_QUOTES, 'UTF-8'),
            'image' => htmlspecialchars($data['image'], ENT_QUOTES, 'UTF-8'),
            'updated_at' => time()
        ]));

        http_response_code(200);
        echo json_encode(['success' => true]);
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid payload']);
    }
    exit;
}

// Fallback
http_response_code(405);
echo json_encode(['error' => 'Method not allowed']);
?>
