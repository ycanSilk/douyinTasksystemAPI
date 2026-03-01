<?php
/**
 * Admin发送通知API
 * POST /task_admin/api/notifications/send.php
 * 
 * 请求体：
 * {
 *   "title": "通知标题",
 *   "content": "通知内容",
 *   "target_type": 0,  // 0=全体，1=C端全体，2=B端全体，3=指定用户
 *   "target_user_id": 123,  // target_type=3时必填
 *   "target_user_type": 1  // target_type=3时必填（1=C端，2=B端）
 * }
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Notification.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

AdminAuthMiddleware::authenticate();

$db = Database::connect();

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$title = trim($input['title'] ?? '');
$content = trim($input['content'] ?? '');
$targetType = (int)($input['target_type'] ?? 0);
$targetUserId = !empty($input['target_user_id']) ? (int)$input['target_user_id'] : null;
$targetUserType = !empty($input['target_user_type']) ? (int)$input['target_user_type'] : null;

// 参数校验
if (empty($title)) {
    http_response_code(400);
    echo json_encode([
        'code' => $errorCodes['NOTIFICATION_TITLE_EMPTY'],
        'message' => '通知标题不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($content)) {
    http_response_code(400);
    echo json_encode([
        'code' => $errorCodes['NOTIFICATION_CONTENT_EMPTY'],
        'message' => '通知内容不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (!in_array($targetType, [0, 1, 2, 3])) {
    http_response_code(400);
    echo json_encode([
        'code' => $errorCodes['NOTIFICATION_TARGET_TYPE_INVALID'],
        'message' => '目标类型无效',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 如果是指定用户，必须提供用户ID和类型
if ($targetType === 3) {
    if (empty($targetUserId) || empty($targetUserType)) {
        http_response_code(400);
        echo json_encode([
            'code' => $errorCodes['NOTIFICATION_TARGET_USER_REQUIRED'],
            'message' => '指定用户时必须提供用户ID和用户类型',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    if (!in_array($targetUserType, [1, 2])) {
        http_response_code(400);
        echo json_encode([
            'code' => $errorCodes['NOTIFICATION_TARGET_USER_TYPE_INVALID'],
            'message' => '用户类型无效（1=C端，2=B端）',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
}

try {
    // 调用通知发送方法
    $result = Notification::send(
        $db,
        $title,
        $content,
        $targetType,
        $targetUserId,
        $targetUserType,
        Notification::SENDER_ADMIN,
        null  // Admin ID 预留
    );
    
    if ($result) {
        echo json_encode([
            'code' => 0,
            'message' => '通知发送成功',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
    } else {
        throw new Exception('发送失败');
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'code' => $errorCodes['NOTIFICATION_SEND_FAILED'],
        'message' => '通知发送失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
