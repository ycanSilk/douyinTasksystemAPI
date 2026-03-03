<?php
/**
 * C端我的任务列表接口
 * 
 * GET /api/c/v1/tasks/my-tasks
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * 查询参数（可选）：
 * - status: 状态筛选（1=进行中，2=待审核，3=已通过，4=已驳回，不传=全部）
 * - page: 页码（默认1）
 * - page_size: 每页数量（默认20）
 * 
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "ok",
 *   "data": {
 *     "list": [
 *       {
 *         "record_id": 1,
 *         "b_task_id": 123,
 *         "template_title": "上评评论",
 *         "video_url": "https://...",
 *         "recommend_mark": {...},
 *         "comment_url": "https://...",
 *         "screenshot_url": ["http://..."],
 *         "reward_amount": "4.00",
 *         "status": 1,
 *         "status_text": "进行中",
 *         "reject_reason": null,
 *         "created_at": "2026-01-11 11:00:00",
 *         "submitted_at": null,
 *         "reviewed_at": null,
 *         "deadline": 1736524800,
 *         "time_remaining": 540
 *       }
 *     ],
 *     "pagination": {...}
 *   },
 *   "timestamp": 1736582400
 * }
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

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';
$appConfig = require __DIR__ . '/../../../../config/app.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

// 获取查询参数
$statusFilter = isset($_GET['status']) && $_GET['status'] !== '' ? (int)$_GET['status'] : null;
$page = max(1, (int)($_GET['page'] ?? 1));
$pageSize = min(100, max(1, (int)($_GET['page_size'] ?? 20)));
$offset = ($page - 1) * $pageSize;

try {
    // 构建查询条件
    $whereConditions = ["c.c_user_id = ?"];
    $params = [$currentUser['user_id']];
    
    if ($statusFilter !== null) {
        $whereConditions[] = "c.status = ?";
        $params[] = $statusFilter;
    }
    
    $whereClause = implode(' AND ', $whereConditions);
    
    // 1. 查询总记录数
    $stmt = $db->prepare("
        SELECT COUNT(*) as total 
        FROM c_task_records c
        WHERE {$whereClause}
    ");
    $stmt->execute($params);
    $totalCount = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 2. 查询任务记录（分页）
    $stmt = $db->prepare("
        SELECT 
            c.id as record_id,
            c.b_task_id,
            c.template_id,
            c.video_url,
            c.recommend_mark,
            c.comment_url,
            c.screenshot_url,
            c.status,
            c.reject_reason,
            c.reward_amount,
            c.created_at,
            c.submitted_at,
            c.reviewed_at,
            t.deadline,
            t.task_count,
            t.task_done,
            t.task_doing,
            t.task_reviewing,
            tm.title as template_title
        FROM c_task_records c
        LEFT JOIN b_tasks t ON c.b_task_id = t.id
        LEFT JOIN task_templates tm ON c.template_id = tm.id
        WHERE {$whereClause}
        ORDER BY c.created_at DESC
        LIMIT ? OFFSET ?
    ");
    
    $params[] = $pageSize;
    $params[] = $offset;
    $stmt->execute($params);
    $records = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 3. 格式化记录
    $statusTexts = [
        1 => '进行中',
        2 => '待审核',
        3 => '已通过',
        4 => '已驳回',
        5 => '已超时'
    ];
    
    $taskSubmitTimeout = (int)$appConfig['task_submit_timeout'];
    $currentTime = time();
    
    $formattedRecords = [];
    foreach ($records as $record) {
        $status = (int)$record['status'];
        $createdAt = strtotime($record['created_at']);
        $deadline = (int)$record['deadline'];
        
        // 计算剩余时间（进行中状态才计算）
        $timeRemaining = null;
        $isTimeout = false;
        if ($status === 1) {
            $timeElapsed = $currentTime - $createdAt;
            $timeRemaining = max(0, $taskSubmitTimeout - $timeElapsed);
            $isTimeout = $timeRemaining <= 0;
        }
        
        // 解析截图
        $screenshots = null;
        if (!empty($record['screenshot_url'])) {
            $screenshots = json_decode($record['screenshot_url'], true);
        }
        
        // 解析推荐评论
        $recommendMark = null;
        if (!empty($record['recommend_mark'])) {
            $recommendMark = json_decode($record['recommend_mark'], true);
        }
        
        // 计算任务进度百分比
        $taskCount = (int)$record['task_count'];
        $taskDone = (int)$record['task_done'];
        $progressPercent = $taskCount > 0 ? round(($taskDone / $taskCount) * 100, 2) : 0;
        
        $formattedRecords[] = [
            'record_id' => (int)$record['record_id'],
            'b_task_id' => (int)$record['b_task_id'],
            'template_id' => (int)$record['template_id'],
            'template_title' => $record['template_title'],
            'video_url' => $record['video_url'],
            'recommend_mark' => $recommendMark,
            'comment_url' => $record['comment_url'],
            'screenshots' => $screenshots,
            'reward_amount' => number_format($record['reward_amount'] / 100, 2),
            'status' => $status,
            'status_text' => $statusTexts[$status] ?? '未知',
            'reject_reason' => $record['reject_reason'],
            'created_at' => $record['created_at'],
            'submitted_at' => $record['submitted_at'],
            'reviewed_at' => $record['reviewed_at'],
            'deadline' => $deadline,
            'deadline_text' => date('Y-m-d H:i:s', $deadline),
            'time_remaining' => $timeRemaining,
            'is_timeout' => $isTimeout,
            'task_progress' => [
                'task_count' => $taskCount,
                'task_done' => $taskDone,
                'task_doing' => (int)$record['task_doing'],
                'task_reviewing' => (int)$record['task_reviewing'],
                'task_available' => $taskCount - $taskDone - (int)$record['task_doing'] - (int)$record['task_reviewing'],
                'progress_percent' => $progressPercent
            ]
        ];
    }
    
    // 4. 计算总页数
    $totalPages = $totalCount > 0 ? (int)ceil($totalCount / $pageSize) : 0;
    
    // 5. 返回成功响应
    Response::success([
        'list' => $formattedRecords,
        'pagination' => [
            'page' => $page,
            'page_size' => $pageSize,
            'total' => $totalCount,
            'total_pages' => $totalPages
        ]
    ]);
    
} catch (PDOException $e) {
    Response::error('查询失败', $errorCodes['DATABASE_ERROR'], 500);
}
