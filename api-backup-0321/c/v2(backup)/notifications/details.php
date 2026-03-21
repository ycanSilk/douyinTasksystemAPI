<?php
/**
 * C端获取通知详情接口
 * 
 * GET /api/c/v1/notifications/details?id=123
 * 
 * 请求头：
 * X-Token: <token> (C端)
 */

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
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

$id = (int)($_GET['id'] ?? 0);

if (empty($id)) {
    Response::error('通知ID不能为空', $errorCodes['NOTIFICATION_NOT_FOUND']);
}

try {
    $stmt = $db->prepare("
        SELECT 
            un.id,
            un.notification_id,
            n.title,
            n.content,
            un.is_read,
            un.read_at,
            un.created_at
        FROM user_notifications un
        INNER JOIN notifications n ON un.notification_id = n.id
        WHERE un.id = ? AND un.user_id = ? AND un.user_type = 1
    ");
    $stmt->execute([$id, $currentUser['user_id']]);
    $notification = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$notification) {
        Response::error('通知不存在或无权访问', $errorCodes['NOTIFICATION_NOT_FOUND']);
    }
    
    // 自动标记为已读
    if ((int)$notification['is_read'] === 0) {
        $stmt = $db->prepare("
            UPDATE user_notifications 
            SET is_read = 1, read_at = NOW() 
            WHERE id = ?
        ");
        $stmt->execute([$id]);
        
        $notification['is_read'] = 1;
        $notification['read_at'] = date('Y-m-d H:i:s');
    }
    
    Response::success([
        'id' => (int)$notification['id'],
        'notification_id' => (int)$notification['notification_id'],
        'title' => $notification['title'],
        'content' => $notification['content'],
        'is_read' => (int)$notification['is_read'],
        'read_at' => $notification['read_at'],
        'created_at' => $notification['created_at']
    ]);
    
} catch (PDOException $e) {
    Response::error('查询失败', $errorCodes['DATABASE_ERROR'], 500);
}
