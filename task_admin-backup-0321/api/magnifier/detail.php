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

// 处理请求
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::error('方法不允许', 405, 405);
    exit;
}

// 获取任务ID
$id = isset($_GET['id']) ? intval($_GET['id']) : 0;
if (!$id) {
    Response::error('参数错误', 400, 400);
    exit;
}

// 查询任务详情
$sql = " 
    SELECT m.*, u.username as b_username 
    FROM magnifying_glass_tasks m 
    LEFT JOIN b_users u ON m.b_user_id = u.id 
    WHERE m.id = ?
";
$stmt = $pdo->prepare($sql);
$stmt->execute([$id]);
$task = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$task) {
    Response::error('任务不存在', 404, 404);
    exit;
}

// 处理JSON字段
if (!empty($task['recommend_marks'])) {
    $task['recommend_marks'] = json_decode($task['recommend_marks'], true);
}

// 状态文本映射
$statusMap = [
    0 => '已发布',
    1 => '进行中',
    2 => '已完成',
    3 => '已取消'
];
$task['status_text'] = $statusMap[$task['status']] ?? '未知状态';
$task['price'] = $task['unit_price']; // 保持与现有接口一致

// 格式化任务数据
$formattedTask = [
    'id' => (int)$task['id'],
    'b_user_id' => (int)$task['b_user_id'],
    'b_username' => $task['b_username'],
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

// 返回结果
Response::success([
    'task' => $formattedTask,
    'records' => [] // 新表暂时没有任务记录
]);
?>