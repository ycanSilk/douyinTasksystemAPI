<?php
/**
 * B端发布新手任务接口
 * 
 * POST /api/b/v1/newbie-tasks
 * 
 * 请求头：
 * X-Token: <token> (B端)
 * 
 * 请求参数：
 * {
 *   "title": "新手任务标题",
 *   "reward": 1.00,
 *   "steps": [
 *     {
 *       "step": 1,
 *       "content": "复制视频链接",
 *       "action": "copy",
 *       "value": "https://example.com/video"
 *     },
 *     {
 *       "step": 2,
 *       "content": "复制评论内容",
 *       "action": "copy",
 *       "value": "这个视频真不错！"
 *     },
 *     {
 *       "step": 3,
 *       "content": "提交任务",
 *       "action": "submit"
 *     }
 *   ],
 *   "priority": 10,
 *   "expire_at": "2026-12-31 23:59:59"
 * }
 */

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 B端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateB();

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);

// 验证参数
if (!isset($input['title']) || empty($input['title'])) {
    Response::error('任务标题不能为空', $errorCodes['INVALID_PARAMS']);
}

if (!isset($input['reward']) || (float)$input['reward'] <= 0) {
    Response::error('奖励金额必须大于0', $errorCodes['INVALID_PARAMS']);
}

if (!isset($input['steps']) || !is_array($input['steps']) || empty($input['steps'])) {
    Response::error('任务步骤不能为空', $errorCodes['INVALID_PARAMS']);
}

// 验证步骤格式
foreach ($input['steps'] as $step) {
    if (!isset($step['step']) || !isset($step['content']) || !isset($step['action'])) {
        Response::error('步骤格式错误', $errorCodes['INVALID_PARAMS']);
    }
}

try {
    // 插入新手任务
    $stmt = $db->prepare("INSERT INTO newbie_tasks (title, reward, steps, status, priority, expire_at, created_by) VALUES (?, ?, ?, ?, ?, ?, ?)");
    
    $title = $input['title'];
    $reward = (float)$input['reward'];
    $steps = json_encode($input['steps'], JSON_UNESCAPED_UNICODE);
    $status = 1; // 发布状态
    $priority = (int)($input['priority'] ?? 0);
    $expireAt = isset($input['expire_at']) ? $input['expire_at'] : null;
    $createdBy = $currentUser['user_id'];
    
    $stmt->execute([$title, $reward, $steps, $status, $priority, $expireAt, $createdBy]);
    
    $taskId = $db->lastInsertId();
    
    // 查询创建的任务
    $taskStmt = $db->prepare("SELECT * FROM newbie_tasks WHERE id = ?");
    $taskStmt->execute([$taskId]);
    $task = $taskStmt->fetch(PDO::FETCH_ASSOC);
    
    if ($task) {
        // 格式化响应数据
        $taskData = [
            'id' => (int)$task['id'],
            'title' => $task['title'],
            'reward' => number_format((float)$task['reward'], 2),
            'steps' => json_decode($task['steps'], true),
            'status' => (int)$task['status'],
            'priority' => (int)$task['priority'],
            'expire_at' => $task['expire_at'],
            'created_by' => (int)$task['created_by'],
            'created_at' => $task['created_at'],
            'updated_at' => $task['updated_at']
        ];
        
        Response::success(['task' => $taskData]);
    } else {
        Response::error('创建任务失败', $errorCodes['DATABASE_ERROR']);
    }
    
} catch (PDOException $e) {
    Response::error('创建任务失败', $errorCodes['DATABASE_ERROR'], 500);
}
