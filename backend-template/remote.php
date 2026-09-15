<?php

define('SECRET_TOKEN', 'your_secret_token_here');
define('COMMAND_FILE', __DIR__ . '/command.json');

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
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

    if (isset($data['command'])) {
        $validCommands = ['next', 'prev', 'play_pause'];
        $command = (string) $data['command'];

        if (!in_array($command, $validCommands, true)) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid command']);
            exit;
        }

        $commandData = json_encode([
            'command' => $command,
            'timestamp' => time()
        ]);

        if (file_put_contents(COMMAND_FILE, $commandData, LOCK_EX) !== false) {
            http_response_code(200);
            echo json_encode(['success' => true, 'queued' => $command]);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Write failed']);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Missing command']);
    }
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    header('Content-Type: application/json');
    
    if (file_exists(COMMAND_FILE)) {
        $commandData = file_get_contents(COMMAND_FILE);
        
        if (unlink(COMMAND_FILE)) {
            echo $commandData;
        } else {
            file_put_contents(COMMAND_FILE, '');
            echo $commandData;
        }
    } else {
        echo json_encode(['command' => null]);
    }
    exit;
}

http_response_code(405);
exit;
?>
