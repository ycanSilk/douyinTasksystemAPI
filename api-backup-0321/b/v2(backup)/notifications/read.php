<?php
/**
 * B端标记通知已读接口
 * 
 * POST /api/b/v1/notifications/read
 * 
 * 请求头：
 * X-Token: <token> (B端)
 * 
 * 请求体：
 * {
 *   "id": 123,  // 用户通知记录ID（user_notifications.id），必填
 *   "ids": [1, 2, 3]  // 批量标记（可选，与id二选一）
 * }
 * 
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "标记成功",
 *   "data": {
 *     "affected_count": 3
 *   },
 *   "timestamp": 1736582400
 * }
 */

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
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

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 B端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateB();

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$id = (int)($input['id'] ?? 0);
$ids = $input['ids'] ?? [];

// 参数校验
if (empty($id) && empty($ids)) {
    Response::error('请提供要标记的通知ID', $errorCodes['NOTIFICATION_NOT_FOUND']);
}

// 构建ID列表
$targetIds = [];
if (!empty($id)) {
    $targetIds[] = $id;
}
if (is_array($ids) && !empty($ids)) {
    $targetIds = array_merge($targetIds, array_map('intval', $ids));
}
$targetIds = array_unique($targetIds);

if (empty($targetIds)) {
    Response::error('请提供有效的通知ID', $errorCodes['NOTIFICATION_NOT_FOUND']);
}

try {
    // 标记已读
    $placeholders = implode(',', array_fill(0, count($targetIds), '?'));
    $stmt = $db->prepare("
        UPDATE user_notifications 
        SET is_read = 1, read_at = NOW() 
        WHERE id IN ({$placeholders}) 
          AND user_id = ? 
          AND user_type = 2
          AND is_read = 0
    ");
    
    $params = array_merge($targetIds, [$currentUser['user_id']]);
    $stmt->execute($params);
    $affectedCount = $stmt->rowCount();
    
    // 返回成功响应
    Response::success([
        'affected_count' => $affectedCount
    ], '标记成功');
    
} catch (PDOException $e) {
    Response::error('操作失败', $errorCodes['NOTIFICATION_MARK_READ_FAILED'], 500);
}
