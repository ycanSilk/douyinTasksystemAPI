<?php
/**
 * 任务模板列表
 * GET /task_admin/api/tasks/list.php
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
$type = !empty($_GET['type']) || $_GET['type'] === '0' ? (int)$_GET['type'] : null;
$status = !empty($_GET['status']) || $_GET['status'] === '0' ? (int)$_GET['status'] : null;

try {
    // 构建查询条件
    $whereClause = [];
    $params = [];
    
    if ($type !== null) {
        $whereClause[] = 'type = ?';
        $params[] = $type;
    }
    
    if ($status !== null) {
        $whereClause[] = 'status = ?';
        $params[] = $status;
    }
    
    $where = $whereClause ? 'WHERE ' . implode(' AND ', $whereClause) : '';
    
    // 查询总数
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM task_templates $where");
    $stmt->execute($params);
    $total = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 查询列表
    $stmt = $db->prepare("
        SELECT *
        FROM task_templates
        $where
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
    ");
    $stmt->execute(array_merge($params, [$pageSize, $offset]));
    $list = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 格式化数据
    foreach ($list as &$item) {
        $item['id'] = (int)$item['id'];
        $item['type'] = (int)$item['type'];
        $item['status'] = (int)$item['status'];
        $item['price'] = number_format((float)$item['price'], 2);

        // 佣金字段
        $item['c_user_commission'] = (int)($item['c_user_commission'] ?? 0);
        $item['agent_commission'] = (int)($item['agent_commission'] ?? 0);
        $item['senior_agent_commission'] = (int)($item['senior_agent_commission'] ?? 0);

        if ($item['type'] === 1) {
            $item['stage1_price'] = $item['stage1_price'] ? number_format((float)$item['stage1_price'], 2) : null;
            $item['stage2_price'] = $item['stage2_price'] ? number_format((float)$item['stage2_price'], 2) : null;
            $item['default_stage1_count'] = $item['default_stage1_count'] ? (int)$item['default_stage1_count'] : null;
            $item['default_stage2_count'] = $item['default_stage2_count'] ? (int)$item['default_stage2_count'] : null;
            $item['stage1_c_user_commission'] = $item['stage1_c_user_commission'] !== null ? (int)$item['stage1_c_user_commission'] : null;
            $item['stage1_agent_commission'] = $item['stage1_agent_commission'] !== null ? (int)$item['stage1_agent_commission'] : null;
            $item['stage1_senior_agent_commission'] = $item['stage1_senior_agent_commission'] !== null ? (int)$item['stage1_senior_agent_commission'] : null;
            $item['stage2_c_user_commission'] = $item['stage2_c_user_commission'] !== null ? (int)$item['stage2_c_user_commission'] : null;
            $item['stage2_agent_commission'] = $item['stage2_agent_commission'] !== null ? (int)$item['stage2_agent_commission'] : null;
            $item['stage2_senior_agent_commission'] = $item['stage2_senior_agent_commission'] !== null ? (int)$item['stage2_senior_agent_commission'] : null;
        }
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
