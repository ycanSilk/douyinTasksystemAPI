<?php
/**
 * 任务市场列表（B端发布的任务）
 * GET /task_admin/api/market/list.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

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

$bUserId = !empty($_GET['b_user_id']) ? (int)$_GET['b_user_id'] : null;
$stage = !empty($_GET['stage']) || $_GET['stage'] === '0' ? (int)$_GET['stage'] : null;
$status = !empty($_GET['status']) || $_GET['status'] === '0' ? (int)$_GET['status'] : null;

try {
    // 构建查询条件
    $whereClause = [];
    $params = [];
    
    if ($bUserId) {
        $whereClause[] = 'b.b_user_id = ?';
        $params[] = $bUserId;
    }
    
    if ($stage !== null) {
        $whereClause[] = 'b.stage = ?';
        $params[] = $stage;
    }
    
    if ($status !== null) {
        $whereClause[] = 'b.status = ?';
        $params[] = $status;
    }
    
    $where = $whereClause ? 'WHERE ' . implode(' AND ', $whereClause) : '';
    
    // 查询总数
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM b_tasks b $where");
    $stmt->execute($params);
    $total = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 查询列表
    $stmt = $db->prepare("
        SELECT 
            b.*,
            bu.username as b_username,
            t.title as template_title,
            t.type as template_type
        FROM b_tasks b
        LEFT JOIN b_users bu ON b.b_user_id = bu.id
        LEFT JOIN task_templates t ON b.template_id = t.id
        $where
        ORDER BY b.created_at DESC
        LIMIT ? OFFSET ?
    ");
    $stmt->execute(array_merge($params, [$pageSize, $offset]));
    $list = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 格式化数据
    foreach ($list as &$item) {
        $item['id'] = (int)$item['id'];
        $item['b_user_id'] = (int)$item['b_user_id'];
        $item['template_id'] = (int)$item['template_id'];
        $item['stage'] = (int)$item['stage'];
        $item['stage_status'] = (int)$item['stage_status'];
        $item['parent_task_id'] = $item['parent_task_id'] ? (int)$item['parent_task_id'] : null;
        $item['task_count'] = (int)$item['task_count'];
        $item['task_done'] = (int)$item['task_done'];
        $item['task_doing'] = (int)$item['task_doing'];
        $item['task_reviewing'] = (int)$item['task_reviewing'];
        $item['unit_price'] = number_format((float)$item['unit_price'], 2);
        $item['total_price'] = number_format((float)$item['total_price'], 2);
        $item['status'] = (int)$item['status'];
        $item['deadline'] = (int)$item['deadline'];
        
        // 剩余数量
        $item['remaining'] = $item['task_count'] - $item['task_done'] - $item['task_doing'] - $item['task_reviewing'];
        
        // 状态文本
        $statusMap = [0 => '已过期', 1 => '进行中', 2 => '已完成', 3 => '已取消'];
        $item['status_text'] = $statusMap[$item['status']] ?? '未知';
        
        // 阶段文本
        $stageMap = [0 => '单任务', 1 => '阶段1', 2 => '阶段2'];
        $item['stage_text'] = $stageMap[$item['stage']] ?? '未知';
        
        // 阶段状态文本
        $stageStatusMap = [0 => '未开放', 1 => '已开放', 2 => '已完成'];
        $item['stage_status_text'] = $stageStatusMap[$item['stage_status']] ?? '未知';
    }
    
    echo json_encode([
        'code' => 0,
        'message' => 'ok',
        'data' => [
            'list' => $list,
            'pagination' => [
                'page' => $page,
                'page_size' => $pageSize,
                'total' => $total,
                'total_pages' => $total > 0 ? (int)ceil($total / $pageSize) : 0
            ]
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['code' => 5000, 'message' => '查询失败', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
}
