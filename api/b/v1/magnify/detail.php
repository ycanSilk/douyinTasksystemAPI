<?php
/**
 * B端查看放大镜任务详情接口
 * 
 * GET /api/b/v1/magnify/detail.php
 * 
 * 请求头：
 * X-Token: <token> (B端或Admin)
 * 
 * 路径参数：
 * id: 任务ID
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

// 获取任务ID
$taskId = $_GET['id'] ?? null;
if (empty($taskId) || !is_numeric($taskId)) {
    Response::error('任务ID不能为空', $errorCodes['INVALID_PARAMS']);
}
$taskId = (int)$taskId;

// 查询任务信息
if ($userType === 'b') {
    // B端用户只能查看自己的任务
    $stmt = $db->prepare(" 
        SELECT id, b_user_id, task_id, template_id, video_url, deadline, 
               recommend_marks, task_count, task_done, task_doing, task_reviewing, 
               unit_price, total_price, status, created_at, updated_at, completed_at, title 
        FROM magnifying_glass_tasks 
        WHERE id = ? AND b_user_id = ?
    ");
    $stmt->execute([$taskId, $currentUser['user_id']]);
} else {
    // Admin可以查看所有任务
    $stmt = $db->prepare(" 
        SELECT id, b_user_id, task_id, template_id, video_url, deadline, 
               recommend_marks, task_count, task_done, task_doing, task_reviewing, 
               unit_price, total_price, status, created_at, updated_at, completed_at, title 
        FROM magnifying_glass_tasks 
        WHERE id = ?
    ");
    $stmt->execute([$taskId]);
}

$task = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$task) {
    Response::error('任务不存在', $errorCodes['TASK_NOT_FOUND']);
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

// 返回响应
Response::success([
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
], '获取放大镜任务详情成功');