<?php
/**
 * C端获取任务池列表接口
 * 
 * GET /api/c/v1/tasks
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * 查询参数：
 * - page: 页码（默认1）
 * - limit: 每页数量（默认20）
 * - status: 状态筛选（1=进行中，2=已完成，默认1）
 */

header('Content-Type: application/json; charset=utf-8');

// 只允许 GET 请求
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
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

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

// 获取查询参数
$page = max(1, (int)($_GET['page'] ?? 1));
$limit = min(100, max(1, (int)($_GET['limit'] ?? 20)));
$statusFilter = (int)($_GET['status'] ?? 1);
$offset = ($page - 1) * $limit;

try {
    // 查询任务列表（只显示已开放且有剩余数量的任务：stage_status=1）
    $stmt = $db->prepare("
        SELECT 
            t.id,
            t.combo_task_id,
            t.stage,
            t.stage_status,
            t.parent_task_id,
            t.template_id,
            t.video_url,
            t.deadline,
            t.task_count,
            t.task_done,
            t.task_doing,
            t.task_reviewing,
            t.unit_price,
            t.total_price,
            t.status,
            t.created_at,
            tm.id AS template_id,
            tm.title AS template_title,
            tm.type AS template_type,
            tm.stage1_title,
            tm.stage2_title,
            tm.c_user_commission,
            tm.stage1_c_user_commission,
            tm.stage2_c_user_commission
        FROM b_tasks t
        LEFT JOIN task_templates tm ON t.template_id = tm.id
        WHERE t.stage_status = 1 
          AND t.status = ? 
          AND t.deadline > ?
          AND (t.task_count - t.task_done - t.task_doing - t.task_reviewing) > 0
        ORDER BY t.created_at DESC
        LIMIT ? OFFSET ?
    ");
    $stmt->execute([$statusFilter, time(), $limit, $offset]);
    $tasks = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // 查询当前用户已接取过的任务ID
    $acceptedTaskIds = [];
    if (!empty($tasks)) {
        $taskIds = array_column($tasks, 'id');
        $placeholders = implode(',', array_fill(0, count($taskIds), '?'));
        $acceptedStmt = $db->prepare("
            SELECT DISTINCT b_task_id FROM c_task_records
            WHERE c_user_id = ? AND b_task_id IN ({$placeholders})
        ");
        $acceptedStmt->execute(array_merge([$currentUser['user_id']], $taskIds));
        $acceptedTaskIds = array_column($acceptedStmt->fetchAll(PDO::FETCH_ASSOC), 'b_task_id');
    }

    // 统计总数
    $stmt = $db->prepare("
        SELECT COUNT(*) AS total
        FROM b_tasks
        WHERE stage_status = 1 
          AND status = ? 
          AND deadline > ?
          AND (task_count - task_done - task_doing - task_reviewing) > 0
    ");
    $stmt->execute([$statusFilter, time()]);
    $total = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 格式化任务列表
    $taskList = [];
    foreach ($tasks as $task) {
        $isCombo = !empty($task['combo_task_id']);
        $stage = (int)$task['stage'];
        
        // 任务标题（组合任务显示阶段标题）
        $taskTitle = $task['template_title'];
        if ($isCombo && $stage == 1 && $task['stage1_title']) {
            $taskTitle = $task['stage1_title'];
        } elseif ($isCombo && $stage == 2 && $task['stage2_title']) {
            $taskTitle = $task['stage2_title'];
        }
        
        // 剩余数量
        $remainCount = (int)$task['task_count'] - (int)$task['task_done'] - (int)$task['task_doing'] - (int)$task['task_reviewing'];
        
        // 计算佣金（单价 * 佣金比例）
        $unitPrice = (float)$task['unit_price'];
        if ($stage === 1) {
            $rewardAmount = (int)($task['stage1_c_user_commission'] ?? 0);
        } elseif ($stage === 2) {
            $rewardAmount = (int)($task['stage2_c_user_commission'] ?? 0);
        } else {
            $rewardAmount = (int)($task['c_user_commission'] ?? 0);
        }
        $rewardAmountYuan = number_format($rewardAmount / 100, 2);
        
        $taskList[] = [
            'id' => (int)$task['id'],
            'template_id' => (int)$task['template_id'],
            'title' => $taskTitle,
            'is_combo' => $isCombo,
            'stage' => $stage,
            'stage_text' => $stage == 0 ? '单任务' : ($stage == 1 ? '阶段1' : '阶段2'),
            'video_url' => $task['video_url'],
            'deadline' => (int)$task['deadline'],
            'deadline_text' => date('Y-m-d H:i:s', $task['deadline']),
            'task_count' => (int)$task['task_count'],
            'task_done' => (int)$task['task_done'],
            'task_doing' => (int)$task['task_doing'],
            'task_reviewing' => (int)$task['task_reviewing'],
            'remain_count' => max(0, $remainCount),
            'unit_price' => number_format($unitPrice, 2),
            'reward_amount' => $rewardAmountYuan,
            'commission' => $rewardAmountYuan,
            'total_price' => number_format((float)$task['total_price'], 2),
            'status' => (int)$task['status'],
            'has_accepted' => in_array($task['id'], $acceptedTaskIds),
            'created_at' => $task['created_at']
        ];
    }
    
    // 返回成功响应
    Response::success([
        'list' => $taskList,
        'pagination' => [
            'page' => $page,
            'limit' => $limit,
            'total' => $total,
            'total_pages' => ceil($total / $limit)
        ]
    ]);
    
} catch (PDOException $e) {
    Response::error('查询失败', $errorCodes['DATABASE_ERROR'], 500);
}
