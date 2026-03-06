<?php
/**
 * B端查看放大镜任务列表接口
 * 
 * GET /api/b/v1/magnify/list.php
 * 
 * 请求头：
 * X-Token: <token> (B端或Admin)
 * 
 * 请求参数：
 * page: 页码，默认1
 * pageSize: 每页条数，默认10
 * b_user_id: 可选，筛选特定用户的任务
 * status: 可选，筛选特定状态的任务
 */

header('Content-Type: application/json; charset=utf-8');
// 禁止跨域
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: X-Token');

// 只允许 GET 请求
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// Token 认证（B端或Admin用户）
$auth = new AuthMiddleware($db);
try {
    $currentUser = $auth->authenticateB();
    $userType = 'b';
} catch (Exception $e) {
    try {
        $currentUser = $auth->authenticateAdmin();
        $userType = 'admin';
    } catch (Exception $e) {
        Response::error('认证失败', $errorCodes['AUTH_FAILED']);
    }
}

// 获取请求参数
$page = (int)($_GET['page'] ?? 1);
$pageSize = (int)($_GET['pageSize'] ?? 10);
$bUserId = $_GET['b_user_id'] ?? null;
$status = $_GET['status'] ?? null;

// 参数校验
if ($page < 1) {
    $page = 1;
}
if ($pageSize < 1 || $pageSize > 100) {
    $pageSize = 10;
}

// 构建查询条件
$whereClause = [];
$params = [];

// B端用户只能查看自己的任务，Admin可以查看所有
if ($userType === 'b') {
    $whereClause[] = 'b_user_id = ?';
    $params[] = $currentUser['user_id'];
} else if ($bUserId) {
    // Admin可以筛选特定用户
    $whereClause[] = 'b_user_id = ?';
    $params[] = $bUserId;
}

// 状态筛选
if ($status !== null && is_numeric($status)) {
    $whereClause[] = 'status = ?';
    $params[] = (int)$status;
}

// 构建SQL语句
$whereSql = '';
if (!empty($whereClause)) {
    $whereSql = 'WHERE ' . implode(' AND ', $whereClause);
}

// 查询总数
$countSql = "SELECT COUNT(*) as total FROM magnifying_glass_tasks {$whereSql}";
$stmt = $db->prepare($countSql);
$stmt->execute($params);
$total = (int)$stmt->fetchColumn();

// 计算分页
$offset = ($page - 1) * $pageSize;

// 查询任务列表
$listSql = " 
    SELECT id, b_user_id, task_id, template_id, video_url, deadline, 
           recommend_marks, task_count, task_done, task_doing, task_reviewing, 
           unit_price, total_price, status, created_at, updated_at, completed_at, title 
    FROM magnifying_glass_tasks 
    {$whereSql} 
    ORDER BY created_at DESC 
    LIMIT ? OFFSET ?
";
$stmt = $db->prepare($listSql);
$params[] = $pageSize;
$params[] = $offset;
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

// 返回响应
Response::success([
    'list' => $list,
    'total' => $total,
    'page' => $page,
    'pageSize' => $pageSize
], '获取放大镜任务列表成功');