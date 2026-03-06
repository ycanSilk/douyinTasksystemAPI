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

// 构建查询
$where = [];
$params = [];

// 只查询放大镜任务（模板ID=3）
$where[] = 'b.template_id = 3';

if ($status !== null) {
    $where[] = 'b.status = ?';
    $params[] = $status;
}

$whereClause = $where ? 'WHERE ' . implode(' AND ', $where) : '';

// 计算总数
$countSql = "SELECT COUNT(*) FROM b_tasks b $whereClause";
$stmt = $pdo->prepare($countSql);
$stmt->execute($params);
$total = $stmt->fetchColumn();

// 计算分页
$offset = ($page - 1) * $pageSize;

// 查询数据
$sql = "SELECT b.*, t.title, t.price FROM b_tasks b LEFT JOIN task_templates t ON b.template_id = t.id $whereClause ORDER BY b.created_at DESC LIMIT ? OFFSET ?";

$params[] = $pageSize;
$params[] = $offset;

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$tasks = $stmt->fetchAll(PDO::FETCH_ASSOC);

// 格式化状态
$statusMap = [
    0 => '待发布',
    1 => '发布中',
    2 => '已完成',
    3 => '已取消'
];

foreach ($tasks as &$task) {
    $task['status_text'] = $statusMap[$task['status']] ?? '未知';
    $task['created_at'] = date('Y-m-d H:i:s', strtotime($task['created_at']));
    $task['updated_at'] = date('Y-m-d H:i:s', strtotime($task['updated_at']));
}

// 返回结果
Response::success([
    'list' => $tasks,
    'total' => $total,
    'page' => $page,
    'pageSize' => $pageSize
]);
?>