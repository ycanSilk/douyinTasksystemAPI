<?php
/**
 * B端发布放大镜任务接口
 * 
 * POST /api/b/v1/magnify/create.php
 * 
 * 请求头：
 * X-Token: <token> (B端)
 * 
 * 请求体：
 * {
 *   "video_url": "https://example.com/video.mp4",
 *   "deadline": 1705420800,
 *   "task_count": 2,
 *   "unit_price": 5.00,
 *   "total_price": 10.00,
 *   "title": "放大镜搜索词",
 *   "recommend_marks": [
 *     {
 *       "at_user": "@超哥超车",
 *       "comment": "蓝词搜索@超哥超车",
 *       "image_url": ""
 *     },
 *     {
 *       "at_user": "@超哥超车",
 *       "comment": "蓝词搜索@超哥超车",
 *       "image_url": ""
 *     }
 *   ]
 * }
 */

header('Content-Type: application/json; charset=utf-8');
// 禁止跨域
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: X-Token, Content-Type');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
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

// Token 认证（必须是 B端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateB();

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$videoUrl = trim($input['video_url'] ?? '');
$deadline = $input['deadline'] ?? 0;
$taskCount = $input['task_count'] ?? 0;
$unitPrice = $input['unit_price'] ?? 0;
$totalPrice = $input['total_price'] ?? 0;
$title = trim($input['title'] ?? '');
$recommendMarks = $input['recommend_marks'] ?? [];

// 参数校验
if (empty($videoUrl)) {
    Response::error('视频链接不能为空', $errorCodes['INVALID_PARAMS']);
}

if (empty($deadline) || !is_numeric($deadline)) {
    Response::error('到期时间不能为空', $errorCodes['INVALID_PARAMS']);
}

if ($deadline < time()) {
    Response::error('到期时间不能早于当前时间', $errorCodes['INVALID_PARAMS']);
}

if (empty($taskCount) || !is_numeric($taskCount) || $taskCount <= 0) {
    Response::error('任务数量必须大于0', $errorCodes['INVALID_PARAMS']);
}

if (empty($unitPrice) || !is_numeric($unitPrice) || $unitPrice <= 0) {
    Response::error('任务单价必须大于0', $errorCodes['INVALID_PARAMS']);
}

if (empty($totalPrice) || !is_numeric($totalPrice) || $totalPrice <= 0) {
    Response::error('任务总价必须大于0', $errorCodes['INVALID_PARAMS']);
}

if (empty($title)) {
    Response::error('任务标题不能为空', $errorCodes['INVALID_PARAMS']);
}

// 校验 recommend_marks 数量
if (!is_array($recommendMarks)) {
    Response::error('推荐标记格式错误', $errorCodes['INVALID_PARAMS']);
}

if (count($recommendMarks) !== (int)$taskCount) {
    Response::error("推荐标记数量不匹配，应为 {$taskCount} 组", $errorCodes['INVALID_PARAMS']);
}

// 校验每组数据格式
foreach ($recommendMarks as $index => $mark) {
    if (!is_array($mark)) {
        Response::error('推荐标记格式错误', $errorCodes['INVALID_PARAMS']);
    }
    
    if (!array_key_exists('comment', $mark)) {
        Response::error('推荐标记必须包含 comment 字段', $errorCodes['INVALID_PARAMS']);
    }
}

// 校验总价
$calculatedTotalPrice = (float)$unitPrice * (int)$taskCount;
if (abs($calculatedTotalPrice - (float)$totalPrice) > 0.01) {
    Response::error('总价计算错误，应为 ' . number_format($calculatedTotalPrice, 2), $errorCodes['INVALID_PARAMS']);
}

try {
    // 查询B端用户信息（获取钱包ID和用户名）
    $stmt = $db->prepare("SELECT wallet_id, username FROM b_users WHERE id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $bUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$bUser) {
        Response::error('用户信息异常', $errorCodes['USER_NOT_FOUND']);
    }
    
    // 查询钱包余额
    $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
    $stmt->execute([$bUser['wallet_id']]);
    $wallet = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$wallet) {
        Response::error('钱包不存在', $errorCodes['WALLET_NOT_FOUND']);
    }
    
    // 将总价转换为分（元 -> 分）
    $totalPriceInCents = (int)round($calculatedTotalPrice * 100);
    $beforeBalance = (int)$wallet['balance'];
    
    // 校验余额是否足够
    if ($beforeBalance < $totalPriceInCents) {
        $needAmount = number_format($totalPriceInCents / 100, 2);
        $currentAmount = number_format($beforeBalance / 100, 2);
        Response::error("余额不足，当前余额：¥{$currentAmount}，需要：¥{$needAmount}", $errorCodes['WALLET_INSUFFICIENT_BALANCE']);
    }
    
    // 开启事务
    $db->beginTransaction();
    
    // 1. 创建放大镜任务
    $stmt = $db->prepare(" 
        INSERT INTO magnifying_glass_tasks (
            b_user_id, task_id, template_id, video_url, deadline, 
            recommend_marks, task_count, task_done, task_doing, task_reviewing, 
            unit_price, total_price, status, title
        ) VALUES (?, NULL, 3, ?, ?, ?, ?, 0, 0, 0, ?, ?, 2, ?)
    ");
    
    $stmt->execute([
        $currentUser['user_id'],
        $videoUrl,
        $deadline,
        json_encode($recommendMarks, JSON_UNESCAPED_UNICODE),
        $taskCount,
        $unitPrice,
        $calculatedTotalPrice,
        $title
    ]);
    
    $taskId = $db->lastInsertId();
    
    // 2. 扣除钱包余额
    $afterBalance = $beforeBalance - $totalPriceInCents;
    $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
    $stmt->execute([$afterBalance, $bUser['wallet_id']]);
    
    // 3. 记录钱包流水
    $remark = "发布放大镜任务【{$title}】{$taskCount}个任务，扣除 ¥" . number_format($calculatedTotalPrice, 2);
    $stmt = $db->prepare(" 
        INSERT INTO wallets_log (
            wallet_id, user_id, username, user_type, type, 
            amount, before_balance, after_balance, 
            related_type, related_id, remark
        ) VALUES (?, ?, ?, 2, 2, ?, ?, ?, 'task', ?, ?)
    ");
    $stmt->execute([
        $bUser['wallet_id'],
        $currentUser['user_id'],
        $bUser['username'],
        $totalPriceInCents,
        $beforeBalance,
        $afterBalance,
        $taskId,
        $remark
    ]);
    
    // 提交事务
    $db->commit();
    
    // 获取创建的任务信息
    $stmt = $db->prepare(" 
        SELECT id, b_user_id, task_id, template_id, video_url, deadline, 
               recommend_marks, task_count, task_done, task_doing, task_reviewing, 
               unit_price, total_price, status, created_at, updated_at, completed_at, title 
        FROM magnifying_glass_tasks 
        WHERE id = ?
    ");
    $stmt->execute([$taskId]);
    $task = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // 处理JSON字段
    if ($task && !empty($task['recommend_marks'])) {
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
    
    // 返回成功响应
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
        'status_text' => $task['status_text'],
        'wallet' => [
            'before_balance' => number_format($beforeBalance / 100, 2),
            'after_balance' => number_format($afterBalance / 100, 2),
            'deducted' => number_format($totalPriceInCents / 100, 2)
        ]
    ], '放大镜任务发布成功');
    
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    Response::error('任务发布失败', $errorCodes['TASK_CREATE_FAILED'], 500);
}