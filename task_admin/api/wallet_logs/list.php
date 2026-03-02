<?php
/**
 * 钱包流水记录列表
 * GET /task_admin/api/wallet_logs/list.php
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
$pageSize = min(100, max(1, (int)($_GET['page_size'] ?? 50)));
$offset = ($page - 1) * $pageSize;

// 筛选参数（只有当参数不为空字符串时才处理）
$logId = !empty($_GET['log_id']) ? (int)$_GET['log_id'] : null;
$username = !empty($_GET['username']) ? trim($_GET['username']) : '';
$userType = !empty($_GET['user_type']) || $_GET['user_type'] === '0' ? (int)$_GET['user_type'] : null;
$type = !empty($_GET['type']) || $_GET['type'] === '0' ? (int)$_GET['type'] : null;
$relatedType = !empty($_GET['related_type']) ? trim($_GET['related_type']) : '';
$minAmount = !empty($_GET['min_amount']) || $_GET['min_amount'] === '0' ? (float)$_GET['min_amount'] : null;
$maxAmount = !empty($_GET['max_amount']) || $_GET['max_amount'] === '0' ? (float)$_GET['max_amount'] : null;
$startDate = !empty($_GET['start_date']) ? trim($_GET['start_date']) : '';
$endDate = !empty($_GET['end_date']) ? trim($_GET['end_date']) : '';

try {
    // 构建查询条件
    $whereClause = [];
    $params = [];
    
    if ($logId) {
        $whereClause[] = 'id = ?';
        $params[] = $logId;
    }
    
    if ($username) {
        $whereClause[] = 'username LIKE ?';
        $params[] = "%{$username}%";
    }
    
    if ($userType !== null) {
        $whereClause[] = 'user_type = ?';
        $params[] = $userType;
    }
    
    if ($type !== null) {
        $whereClause[] = 'type = ?';
        $params[] = $type;
    }
    
    if ($relatedType) {
        $whereClause[] = 'related_type = ?';
        $params[] = $relatedType;
    }
    
    if ($minAmount !== null) {
        $whereClause[] = 'amount >= ?';
        $params[] = (int)($minAmount * 100);
    }
    
    if ($maxAmount !== null) {
        $whereClause[] = 'amount <= ?';
        $params[] = (int)($maxAmount * 100);
    }
    
    if ($startDate) {
        $whereClause[] = 'DATE(created_at) >= ?';
        $params[] = $startDate;
    }
    
    if ($endDate) {
        $whereClause[] = 'DATE(created_at) <= ?';
        $params[] = $endDate;
    }
    
    $where = $whereClause ? 'WHERE ' . implode(' AND ', $whereClause) : '';
    
    // 查询总数
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM wallets_log $where");
    $stmt->execute($params);
    $total = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 查询列表
    $stmt = $db->prepare("
        SELECT *
        FROM wallets_log
        $where
        ORDER BY created_at DESC, id DESC
        LIMIT ? OFFSET ?
    ");
    $stmt->execute(array_merge($params, [$pageSize, $offset]));
    $list = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 格式化数据
    foreach ($list as &$item) {
        $item['id'] = (int)$item['id'];
        $item['wallet_id'] = (int)$item['wallet_id'];
        $item['user_id'] = (int)$item['user_id'];
        $item['user_type'] = (int)$item['user_type'];
        $item['type'] = (int)$item['type'];
        $item['amount'] = number_format((int)$item['amount'] / 100, 2);
        $item['before_balance'] = number_format((int)$item['before_balance'] / 100, 2);
        $item['after_balance'] = number_format((int)$item['after_balance'] / 100, 2);
        $item['related_id'] = $item['related_id'] ? (int)$item['related_id'] : null;
        
        // 添加类型文本
        $item['user_type_text'] = ['', 'C端', 'B端', 'Admin'][($item['user_type']) ?? 0] ?? '未知';
        $item['type_text'] = $item['type'] === 1 ? '收入' : '支出';
        
        // 添加关联类型文本
        $relatedTypeMap = [
            'task' => '任务佣金',
            'recharge' => '充值',
            'withdraw' => '提现',
            'refund' => '退款',
            'agent_commission' => '团长佣金',
            'senior_agent_commission' => '高级团长佣金',
            'commission' => '奖励佣金',
            'rental_freeze' => '求租信息租金冻结',
            'rental_unfreeze' => '求租信息租金解冻',
            'second_agent_commission' => '二级团长佣金'
        ];
        $item['related_type_text'] = $relatedTypeMap[$item['related_type']] ?? $item['related_type'];
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
