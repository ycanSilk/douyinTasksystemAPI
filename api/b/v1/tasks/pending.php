<?php
/**
 * B端待审核任务列表接口
 * 
 * GET /api/b/v1/tasks/pending
 * 
 * 请求头：
 * X-Token: <token> (B端)
 * 
 * 查询参数（可选）：
 * - page: 页码（默认1）
 * - page_size: 每页数量（默认20）
 * - b_task_id: 筛选指定任务的待审核记录（可选）
 * 
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "ok",
 *   "data": {
 *     "list": [
 *       {
 *         "record_id": 456,
 *         "b_task_id": 123,
 *         "c_user_id": 789,
 *         "c_username": "user123",
 *         "template_title": "上评评论",
 *         "video_url": "https://...",
 *         "recommend_mark": {...},
 *         "comment_url": "https://...",
 *         "screenshots": ["http://..."],
 *         "reward_amount": "4.00",
 *         "submitted_at": "2026-01-11 12:00:00"
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

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 B端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateB();

// 获取查询参数
$bTaskIdFilter = isset($_GET['b_task_id']) && $_GET['b_task_id'] !== '' ? (int)$_GET['b_task_id'] : null;
$page = max(1, (int)($_GET['page'] ?? 1));
$pageSize = min(100, max(1, (int)($_GET['page_size'] ?? 20)));
$offset = ($page - 1) * $pageSize;

try {
    // 构建查询条件
    $whereConditions = ["c.b_user_id = ?", "c.status = 2"]; // status=2 待审核
    $params = [$currentUser['user_id']];
    
    if ($bTaskIdFilter !== null) {
        $whereConditions[] = "c.b_task_id = ?";
        $params[] = $bTaskIdFilter;
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
    
    // 2. 查询待审核记录（分页）
    $stmt = $db->prepare("
        SELECT 
            c.id as record_id,
            c.b_task_id,
            c.c_user_id,
            c.template_id,
            c.video_url,
            c.recommend_mark,
            c.comment_url,
            c.screenshot_url,
            c.reward_amount,
            c.submitted_at,
            c.task_stage,
            c.task_stage_text,
            cu.username as c_username,
            cu.email as c_email,
            tm.title as template_title
        FROM c_task_records c
        LEFT JOIN c_users cu ON c.c_user_id = cu.id
        LEFT JOIN task_templates tm ON c.template_id = tm.id
        WHERE {$whereClause}
        ORDER BY c.submitted_at ASC, c.id ASC
        LIMIT ? OFFSET ?
    ");
    
    $params[] = $pageSize;
    $params[] = $offset;
    $stmt->execute($params);
    $records = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 3. 格式化记录
    $formattedRecords = [];
    foreach ($records as $record) {
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
        
        $formattedRecords[] = [
            'record_id' => (int)$record['record_id'],
            'b_task_id' => (int)$record['b_task_id'],
            'c_user_id' => (int)$record['c_user_id'],
            'c_username' => $record['c_username'],
            'c_email' => $record['c_email'],
            'template_title' => $record['template_title'],
            'video_url' => $record['video_url'],
            'recommend_mark' => $recommendMark,
            'comment_url' => $record['comment_url'],
            'screenshots' => $screenshots,
            'reward_amount' => number_format($record['reward_amount'] / 100, 2),
            'task_stage' => (int)$record['task_stage'],
            'task_stage_text' => $record['task_stage_text'],
            'submitted_at' => $record['submitted_at']
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
