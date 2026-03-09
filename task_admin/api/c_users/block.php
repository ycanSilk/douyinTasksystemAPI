<?php
/**
 * C端用户封禁接口
 * POST /task_admin/api/c_users/block.php
 * 
 * 请求体：
 * {
 *   "user_id": 1,
 *   "blocked_status": 1, // 0: 解禁, 1: 禁止接单, 2: 禁止登录
 *   "blocked_duration": 24 // 封禁时长（小时），解禁时为0
 * }
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';

AdminAuthMiddleware::authenticate();
$db = Database::connect();

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$userId = (int)($input['user_id'] ?? 0);
$blockedStatus = (int)($input['blocked_status'] ?? 0);
$blockedDuration = (int)($input['blocked_duration'] ?? 0);

// 参数校验
if ($userId === 0) {
    http_response_code(400);
    echo json_encode([
        'code' => 400,
        'message' => '用户ID不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (!in_array($blockedStatus, [0, 1, 2])) {
    http_response_code(400);
    echo json_encode([
        'code' => 400,
        'message' => '封禁状态无效',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($blockedStatus > 0 && $blockedDuration <= 0) {
    http_response_code(400);
    echo json_encode([
        'code' => 400,
        'message' => '封禁时长必须大于0',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 计算封禁结束时间
    $blockedStartTime = null;
    $blockedEndTime = null;
    
    if ($blockedStatus > 0) {
        $blockedStartTime = date('Y-m-d H:i:s');
        $blockedEndTime = date('Y-m-d H:i:s', strtotime($blockedStartTime . ' + ' . $blockedDuration . ' hours'));
    }
    
    // 更新用户封禁状态
    $stmt = $db->prepare("UPDATE c_users SET 
        blocked_status = ?, 
        blocked_start_time = ?, 
        blocked_duration = ?, 
        blocked_end_time = ? 
        WHERE id = ?");
    
    $stmt->execute([
        $blockedStatus,
        $blockedStartTime,
        $blockedDuration,
        $blockedEndTime,
        $userId
    ]);
    
    if ($stmt->rowCount() === 0) {
        http_response_code(404);
        echo json_encode([
            'code' => 404,
            'message' => '用户不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 返回成功响应
    $message = $blockedStatus === 0 ? '解禁成功' : '封禁成功';
    echo json_encode([
        'code' => 0,
        'message' => $message,
        'data' => [
            'user_id' => $userId,
            'blocked_status' => $blockedStatus,
            'blocked_duration' => $blockedDuration,
            'blocked_start_time' => $blockedStartTime,
            'blocked_end_time' => $blockedEndTime
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'code' => 500,
        'message' => '操作失败: ' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
