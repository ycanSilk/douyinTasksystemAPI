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
$sql = "SELECT b.*, t.title, t.price, t.description1, u.username as b_username FROM b_tasks b LEFT JOIN task_templates t ON b.template_id = t.id LEFT JOIN b_users u ON b.b_user_id = u.id WHERE b.id = ? AND b.template_id = 3";
$stmt = $pdo->prepare($sql);
$stmt->execute([$id]);
$task = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$task) {
    Response::error('任务不存在或不是放大镜任务', 404, 404);
    exit;
}

// 查询任务记录
$recordSql = "SELECT c.*, u.username as c_username FROM c_task_records c LEFT JOIN c_users u ON c.c_user_id = u.id WHERE c.b_task_id = ? ORDER BY c.created_at DESC";
$recordStmt = $pdo->prepare($recordSql);
$recordStmt->execute([$id]);
$records = $recordStmt->fetchAll(PDO::FETCH_ASSOC);

// 格式化状态
$taskStatusMap = [
    0 => '待发布',
    1 => '发布中',
    2 => '已完成',
    3 => '已取消'
];

$recordStatusMap = [
    0 => '待接取',
    1 => '进行中',
    2 => '待审核',
    3 => '已通过',
    4 => '已驳回'
];

$task['status_text'] = $taskStatusMap[$task['status']] ?? '未知';
$task['created_at'] = date('Y-m-d H:i:s', strtotime($task['created_at']));
$task['updated_at'] = date('Y-m-d H:i:s', strtotime($task['updated_at']));

foreach ($records as &$record) {
    $record['status_text'] = $recordStatusMap[$record['status']] ?? '未知';
    $record['created_at'] = date('Y-m-d H:i:s', strtotime($record['created_at']));
    $record['reviewed_at'] = $record['reviewed_at'] ? date('Y-m-d H:i:s', strtotime($record['reviewed_at'])) : null;
}

// 返回结果
Response::success([
    'task' => $task,
    'records' => $records
]);
?>