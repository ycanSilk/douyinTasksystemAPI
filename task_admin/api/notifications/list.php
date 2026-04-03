<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 引入必要的文件
require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';

// 初始化数据库连接
$pdo = Database::connect();

// 认证中间件
AdminAuthMiddleware::authenticate();

// 处理查询参数
$page = isset($_GET['page']) ? intval($_GET['page']) : 1;
$pageSize = isset($_GET['pageSize']) ? intval($_GET['pageSize']) : 10;
$targetType = isset($_GET['target_type']) ? intval($_GET['target_type']) : null;
$targetUserId = isset($_GET['target_user_id']) ? intval($_GET['target_user_id']) : null;
$targetUserType = isset($_GET['target_user_type']) ? intval($_GET['target_user_type']) : null;
$senderType = isset($_GET['sender_type']) ? intval($_GET['sender_type']) : null;

// 构建查询条件
$where = [];
$params = [];

// 目标类型筛选
if ($targetType !== null) {
    $where[] = 'target_type = ?';
    $params[] = $targetType;
}

// 目标用户ID筛选
if ($targetUserId) {
    $where[] = 'target_user_id = ?';
    $params[] = $targetUserId;
}

// 目标用户类型筛选
if ($targetUserType !== null) {
    $where[] = 'target_user_type = ?';
    $params[] = $targetUserType;
}

// 发送者类型筛选
if ($senderType !== null) {
    $where[] = 'sender_type = ?';
    $params[] = $senderType;
}

$whereClause = $where ? 'WHERE ' . implode(' AND ', $where) : '';

// 计算总数
$countSql = "SELECT COUNT(*) FROM notifications {$whereClause}";
$stmt = $pdo->prepare($countSql);
$stmt->execute($params);
$total = $stmt->fetchColumn();

// 计算分页
$offset = ($page - 1) * $pageSize;

// 查询数据
$sql = " 
    SELECT id, title, content, target_type, target_user_id, target_user_type, 
           sender_type, sender_id, created_at 
    FROM notifications 
    {$whereClause} 
    ORDER BY created_at DESC 
    LIMIT ? OFFSET ?
";

$params[] = $pageSize;
$params[] = $offset;

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$notifications = $stmt->fetchAll(PDO::FETCH_ASSOC);

// 处理结果
$list = [];
$targetTypeMap = [
    0 => '全体',
    1 => 'C端全体',
    2 => 'B端全体',
    3 => '指定用户'
];
$senderTypeMap = [
    1 => '系统自动',
    3 => 'Admin'
];

foreach ($notifications as $notification) {
    // 类型文本
    $notification['target_type_text'] = $targetTypeMap[$notification['target_type']] ?? '未知类型';
    $notification['sender_type_text'] = $senderTypeMap[$notification['sender_type']] ?? '未知类型';
    
    $list[] = [
        'id' => (int)$notification['id'],
        'title' => $notification['title'],
        'content' => $notification['content'],
        'target_type' => (int)$notification['target_type'],
        'target_type_text' => $notification['target_type_text'],
        'target_user_id' => $notification['target_user_id'] ? (int)$notification['target_user_id'] : null,
        'target_user_type' => $notification['target_user_type'] ? (int)$notification['target_user_type'] : null,
        'sender_type' => (int)$notification['sender_type'],
        'sender_type_text' => $notification['sender_type_text'],
        'sender_id' => $notification['sender_id'] ? (int)$notification['sender_id'] : null,
        'created_at' => $notification['created_at']
    ];
}

// 确保page值至少为1
$page = max(1, $page);

// 返回结果
Response::success([
    'list' => $list,
    'total' => $total,
    'page' => $page,
    'pageSize' => $pageSize
]);
?>