<?php

define('SECRET_TOKEN', 'your_secret_token_here'); 
define('DATA_FILE', __DIR__ . '/current-track.json');

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    header('Content-Type: application/json');
    
    if (file_exists(DATA_FILE)) {
        echo file_get_contents(DATA_FILE);
    } else {
        echo json_encode([
            'is_playing' => false,
            'title' => 'Nothing playing',
            'artist' => '',
            'image' => '',
            'updated_at' => time()
        ]);
    }
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    header('Content-Type: application/json');

    $jsonPayload = file_get_contents('php://input');
    $data = json_decode($jsonPayload, true);

    if (json_last_error() !== JSON_ERROR_NONE || !$data) {
        http_response_code(400);
        echo json_encode(['error' => 'Malformed JSON']);
        exit;
    }

    $providedSecret = isset($data['secret']) ? (string)$data['secret'] : '';
    if (!hash_equals(SECRET_TOKEN, $providedSecret)) {
        http_response_code(403);
        echo json_encode(['error' => 'Unauthorized']);
        exit;
    }

    if (isset($data['title'])) {
        $trackData = json_encode([
            'is_playing' => (bool) $data['is_playing'],
            'title'      => htmlspecialchars($data['title'], ENT_QUOTES, 'UTF-8'),
            'artist'     => htmlspecialchars($data['artist'], ENT_QUOTES, 'UTF-8'),
            'image'      => filter_var($data['image'], FILTER_VALIDATE_URL) ? $data['image'] : '',
            'updated_at' => time()
        ]);

        if (file_put_contents(DATA_FILE, $trackData, LOCK_EX) !== false) {
            http_response_code(200);
            echo json_encode(['success' => true]);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Write failed']);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Missing title']);
    }
    exit;
}

http_response_code(405);
exit;
?>
