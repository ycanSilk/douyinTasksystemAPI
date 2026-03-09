<?php
/**
 * 待审核任务列表
 * GET /task_admin/api/tasks/pending.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');



// 处理OPTIONS预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}
require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';

AdminAuthMiddleware::authenticate();
$db = Database::connect();

$page = max(1, (int)($_GET['page'] ?? 1));
$pageSize = min(100, max(1, (int)($_GET['page_size'] ?? 20)));
$offset = ($page - 1) * $pageSize;
$bTaskId = !empty($_GET['b_task_id']) ? (int)$_GET['b_task_id'] : null;
$cUserId = !empty($_GET['c_user_id']) ? (int)$_GET['c_user_id'] : null;
$bUserId = !empty($_GET['b_user_id']) ? (int)$_GET['b_user_id'] : null;

try {
    // 构建查询条件
    $whereConditions = ["c.status = 2"]; // status=2 待审核
    $params = [];
    
    if ($bTaskId !== null) {
        $whereConditions[] = "c.b_task_id = ?";
        $params[] = $bTaskId;
    }
    
    if ($cUserId !== null) {
        $whereConditions[] = "c.c_user_id = ?";
        $params[] = $cUserId;
    }
    
    if ($bUserId !== null) {
        $whereConditions[] = "c.b_user_id = ?";
        $params[] = $bUserId;
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
            c.b_user_id,
            c.video_url,
            c.recommend_mark,
            c.comment_url,
            c.screenshot_url,
            c.reward_amount,
            c.submitted_at,
            cu.username as c_username,
            cu.email as c_email,
            bu.username as b_username,
            tm.title as template_title
        FROM c_task_records c
        LEFT JOIN c_users cu ON c.c_user_id = cu.id
        LEFT JOIN b_users bu ON c.b_user_id = bu.id
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
            'b_user_id' => (int)$record['b_user_id'],
            'c_username' => $record['c_username'],
            'b_username' => $record['b_username'],
            'c_email' => $record['c_email'],
            'template_title' => $record['template_title'],
            'video_url' => $record['video_url'],
            'recommend_mark' => $recommendMark,
            'comment_url' => $record['comment_url'],
            'screenshots' => $screenshots,
            'reward_amount' => number_format($record['reward_amount'] / 100, 2),
            'submitted_at' => $record['submitted_at']
        ];
    }
    
    // 4. 计算总页数
    $totalPages = $totalCount > 0 ? (int)ceil($totalCount / $pageSize) : 0;
    
    // 5. 返回成功响应
    echo json_encode([
        'code' => 0,
        'message' => 'ok',
        'data' => [
            'list' => $formattedRecords,
            'pagination' => [
                'page' => $page,
                'page_size' => $pageSize,
                'total' => $totalCount,
                'total_pages' => $totalPages
            ]
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['code' => 5000, 'message' => '查询失败', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
}