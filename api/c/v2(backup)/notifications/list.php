<?php
/**
 * C端获取通知列表接口
 * 
 * GET /api/c/v1/notifications/list
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * 查询参数：
 * - page: 页码（默认1）
 * - limit: 每页数量（默认20）
 * - is_read: 已读状态筛选（0=未读，1=已读，不传=全部）
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

$page = max(1, (int)($_GET['page'] ?? 1));
$limit = min(100, max(1, (int)($_GET['limit'] ?? 20)));
$isReadFilter = isset($_GET['is_read']) && $_GET['is_read'] !== '' ? (int)$_GET['is_read'] : null;
$offset = ($page - 1) * $limit;

try {
    // 查询未读数量
    $stmt = $db->prepare("
        SELECT COUNT(*) as count
        FROM user_notifications
        WHERE user_id = ? AND user_type = 1 AND is_read = 0
    ");
    $stmt->execute([$currentUser['user_id']]);
    $unreadCount = (int)$stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    // 构建查询条件
    $whereConditions = ["un.user_id = ?", "un.user_type = 1"];
    $params = [$currentUser['user_id']];
    
    if ($isReadFilter !== null) {
        $whereConditions[] = "un.is_read = ?";
        $params[] = $isReadFilter;
    }
    
    $whereClause = implode(' AND ', $whereConditions);
    
    // 查询通知列表
    $sql = "
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
        WHERE {$whereClause}
        ORDER BY un.created_at DESC
        LIMIT ? OFFSET ?
    ";
    
    $params[] = $limit;
    $params[] = $offset;
    
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $notifications = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 查询总数
    $stmt = $db->prepare("
        SELECT COUNT(*) as total
        FROM user_notifications un
        WHERE {$whereClause}
    ");
    $stmt->execute(array_slice($params, 0, -2));
    $total = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 格式化列表
    $list = [];
    foreach ($notifications as $item) {
        $list[] = [
            'id' => (int)$item['id'],
            'notification_id' => (int)$item['notification_id'],
            'title' => $item['title'],
            'preview' => mb_substr(strip_tags($item['content']), 0, 50) . '...',
            'is_read' => (int)$item['is_read'],
            'read_at' => $item['read_at'],
            'created_at' => $item['created_at']
        ];
    }
    
    Response::success([
        'total' => $total,
        'unread_count' => $unreadCount,
        'list' => $list,
        'pagination' => [
            'page' => $page,
            'limit' => $limit,
            'total' => $total,
            'total_pages' => ceil($total / $limit)
        ]
    ]);
    
} catch (PDOException $e) {
    Response::error('查询失败', $errorCodes['DATABASE_ERROR'], 500);
}
