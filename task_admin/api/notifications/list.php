<?php
/**
 * Admin通知列表API
 * GET /task_admin/api/notifications/list.php
 * 
 * 查询参数：
 * - page: 页码
 * - limit: 每页数量
 * - target_type: 目标类型筛选（0=全体，1=C端，2=B端，3=指定用户）
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

$page = max(1, (int)($_GET['page'] ?? 1));
$limit = min(100, max(1, (int)($_GET['limit'] ?? 20)));
$targetTypeFilter = isset($_GET['target_type']) && $_GET['target_type'] !== '' ? (int)$_GET['target_type'] : null;
$offset = ($page - 1) * $limit;

try {
    // 构建查询条件
    $whereConditions = [];
    $params = [];
    
    if ($targetTypeFilter !== null) {
        $whereConditions[] = "target_type = ?";
        $params[] = $targetTypeFilter;
    }
    
    $whereClause = !empty($whereConditions) ? 'WHERE ' . implode(' AND ', $whereConditions) : '';
    
    // 查询通知列表
    $sql = "
        SELECT 
            id,
            title,
            content,
            target_type,
            target_user_id,
            target_user_type,
            sender_type,
            created_at
        FROM notifications
        {$whereClause}
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
    ";
    
    $params[] = $limit;
    $params[] = $offset;
    
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $notifications = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 查询总数
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM notifications {$whereClause}");
    $stmt->execute(array_slice($params, 0, -2));
    $total = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 为每个通知查询接收人数和已读人数
    $list = [];
    foreach ($notifications as $item) {
        // 查询接收人数
        $stmt = $db->prepare("SELECT COUNT(*) as count FROM user_notifications WHERE notification_id = ?");
        $stmt->execute([$item['id']]);
        $recipientCount = (int)$stmt->fetch(PDO::FETCH_ASSOC)['count'];
        
        // 查询已读人数
        $stmt = $db->prepare("SELECT COUNT(*) as count FROM user_notifications WHERE notification_id = ? AND is_read = 1");
        $stmt->execute([$item['id']]);
        $readCount = (int)$stmt->fetch(PDO::FETCH_ASSOC)['count'];
        
        // 目标类型文本
        $targetTypeText = match((int)$item['target_type']) {
            0 => '全体用户',
            1 => 'C端全体',
            2 => 'B端全体',
            3 => '指定用户',
            default => '未知'
        };
        
        $list[] = [
            'id' => (int)$item['id'],
            'title' => $item['title'],
            'content_preview' => mb_substr(strip_tags($item['content']), 0, 100) . '...',
            'target_type' => (int)$item['target_type'],
            'target_type_text' => $targetTypeText,
            'target_user_id' => $item['target_user_id'] ? (int)$item['target_user_id'] : null,
            'target_user_type' => $item['target_user_type'] ? (int)$item['target_user_type'] : null,
            'sender_type' => (int)$item['sender_type'],
            'recipient_count' => $recipientCount,
            'read_count' => $readCount,
            'unread_count' => $recipientCount - $readCount,
            'created_at' => $item['created_at']
        ];
    }
    
    echo json_encode([
        'code' => 0,
        'message' => 'ok',
        'data' => [
            'list' => $list,
            'pagination' => [
                'page' => $page,
                'limit' => $limit,
                'total' => $total,
                'total_pages' => ceil($total / $limit)
            ]
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'code' => 1002,
        'message' => '查询失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
