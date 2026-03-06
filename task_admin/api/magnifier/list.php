<?php
header('Content-Type: application/json');

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
$status = isset($_GET['status']) ? intval($_GET['status']) : null;
$bUserId = isset($_GET['b_user_id']) ? intval($_GET['b_user_id']) : null;

// 构建查询条件
$where = [];
$params = [];

// 状态筛选
if ($status !== null) {
    $where[] = 'status = ?';
    $params[] = $status;
}

// 用户筛选
if ($bUserId) {
    $where[] = 'b_user_id = ?';
    $params[] = $bUserId;
}

$whereClause = $where ? 'WHERE ' . implode(' AND ', $where) : '';

// 计算总数
$countSql = "SELECT COUNT(*) FROM magnifying_glass_tasks {$whereClause}";
$stmt = $pdo->prepare($countSql);
$stmt->execute($params);
$total = $stmt->fetchColumn();

// 计算分页
$offset = ($page - 1) * $pageSize;

// 查询数据
$sql = " 
    SELECT id, b_user_id, task_id, template_id, video_url, deadline, 
           recommend_marks, task_count, task_done, task_doing, task_reviewing, 
           unit_price, total_price, status, created_at, updated_at, completed_at, title 
    FROM magnifying_glass_tasks 
    {$whereClause} 
    ORDER BY created_at DESC 
    LIMIT ? OFFSET ?
";

$params[] = $pageSize;
$params[] = $offset;

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$tasks = $stmt->fetchAll(PDO::FETCH_ASSOC);

// 处理结果
$list = [];
$statusMap = [
    0 => '已发布',
    1 => '进行中',
    2 => '已完成',
    3 => '已取消'
];

foreach ($tasks as $task) {
    // 处理JSON字段
    if (!empty($task['recommend_marks'])) {
        $task['recommend_marks'] = json_decode($task['recommend_marks'], true);
    }
    
    // 状态文本
    $task['status_text'] = $statusMap[$task['status']] ?? '未知状态';
    $task['price'] = $task['unit_price']; // 保持与现有接口一致
    
    $list[] = [
        'id' => (int)$task['id'],
        'b_user_id' => (int)$task['b_user_id'],
        'combo_task_id' => null, // 保持与现有接口一致
        'parent_task_id' => $task['task_id'] ? (int)$task['task_id'] : null,
        'template_id' => (int)$task['template_id'],
        'video_url' => $task['video_url'],
        'deadline' => (int)$task['deadline'],
        'recommend_marks' => $task['recommend_marks'],
        'task_count' => (int)$task['task_count'],
        'task_done' => (int)$task['task_done'],
        'task_doing' => (int)$task['task_doing'],
        'task_reviewing' => (int)$task['task_reviewing'],
        'unit_price' => (string)$task['unit_price'],
        'total_price' => (string)$task['total_price'],
        'status' => (int)$task['status'],
        'created_at' => $task['created_at'],
        'updated_at' => $task['updated_at'],
        'completed_at' => $task['completed_at'],
        'title' => $task['title'],
        'price' => (string)$task['price'],
        'status_text' => $task['status_text']
    ];
}

// 返回结果
Response::success([
    'list' => $list,
    'total' => $total,
    'page' => $page,
    'pageSize' => $pageSize
]);
?>