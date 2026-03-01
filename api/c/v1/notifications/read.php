<?php
/**
 * C端标记通知已读接口
 * 
 * POST /api/c/v1/notifications/read
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * 请求体：
 * {
 *   "id": 123,  // 单个标记
 *   "ids": [1, 2, 3]  // 批量标记（可选）
 * }
 */

header('Content-Type: application/json; charset=utf-8');

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

$db = Database::connect();
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

$input = json_decode(file_get_contents('php://input'), true);
$id = (int)($input['id'] ?? 0);
$ids = $input['ids'] ?? [];

if (empty($id) && empty($ids)) {
    Response::error('请提供要标记的通知ID', $errorCodes['NOTIFICATION_NOT_FOUND']);
}

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
    $placeholders = implode(',', array_fill(0, count($targetIds), '?'));
    $stmt = $db->prepare("
        UPDATE user_notifications 
        SET is_read = 1, read_at = NOW() 
        WHERE id IN ({$placeholders}) 
          AND user_id = ? 
          AND user_type = 1
          AND is_read = 0
    ");
    
    $params = array_merge($targetIds, [$currentUser['user_id']]);
    $stmt->execute($params);
    $affectedCount = $stmt->rowCount();
    
    Response::success([
        'affected_count' => $affectedCount
    ], '标记成功');
    
} catch (PDOException $e) {
    Response::error('操作失败', $errorCodes['NOTIFICATION_MARK_READ_FAILED'], 500);
}
