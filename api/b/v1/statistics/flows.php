<?php
/**
 * B端流水列表接口
 * 
 * GET /api/b/v1/statistics/flows
 * 
 * 请求参数：
 * - b_user_id: B端用户ID（必填）
 * - page: 页码，默认1
 * - limit: 每页数量，默认20
 * - flow_type: 流水类型：1=收入，2=支出
 * - related_type: 关联类型：task_publish, recharge, account_rental, refund
 * - start_date: 开始日期，格式：YYYY-MM-DD
 * - end_date: 结束日期，格式：YYYY-MM-DD
 * - min_amount: 最小金额（分）
 * - max_amount: 最大金额（分）
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: X-Token, Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

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

$db = Database::connect();

// 测试模式：如果传入test参数，则使用默认用户ID
$testMode = isset($_GET['test']) && $_GET['test'] === '1';

// 获取URL参数中的b_user_id
$urlBUserId = isset($_GET['b_user_id']) ? (int)$_GET['b_user_id'] : 0;

if ($testMode) {
    // 测试模式下，如果URL中有b_user_id，则使用它；否则使用默认值1
    $bUserId = $urlBUserId > 0 ? $urlBUserId : 1;
} else {
    $auth = new AuthMiddleware($db);
    $currentUser = $auth->authenticateB();
    
    // 如果URL中有b_user_id，则使用它；否则使用token中的user_id
    $bUserId = $urlBUserId > 0 ? $urlBUserId : $currentUser['user_id'];
}

// 获取请求参数
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
$flowType = isset($_GET['flow_type']) ? (int)$_GET['flow_type'] : 0;
$relatedType = isset($_GET['related_type']) ? $_GET['related_type'] : '';
$startDate = isset($_GET['start_date']) ? $_GET['start_date'] : '';
$endDate = isset($_GET['end_date']) ? $_GET['end_date'] : '';
$minAmount = isset($_GET['min_amount']) ? (int)$_GET['min_amount'] : 0;
$maxAmount = isset($_GET['max_amount']) ? (int)$_GET['max_amount'] : 0;

// 验证参数 - 后台管理页面可以不传入b_user_id，查询所有用户数据
if (empty($bUserId) && !$testMode) {
    // 从token中获取用户信息，检查是否为管理员
    $auth = new AuthMiddleware($db);
    $currentUser = $auth->authenticateAdmin();
    if (!$currentUser) {
        Response::error('B端用户ID不能为空', $errorCodes['INVALID_PARAMS']);
    }
    // 管理员可以查询所有用户数据，设置bUserId为0表示查询所有
    $bUserId = 0;
}

// 构建查询条件
$where = "1=1";
$params = [];

// 如果bUserId不为0，则添加用户ID过滤条件
if (!empty($bUserId)) {
    $where .= " AND b_user_id = ?";
    $params[] = $bUserId;
}

if (!empty($flowType)) {
    $where .= " AND flow_type = ?";
    $params[] = $flowType;
}

if (!empty($relatedType)) {
    $where .= " AND related_type = ?";
    $params[] = $relatedType;
}

if (!empty($startDate)) {
    $where .= " AND DATE(created_at) >= ?";
    $params[] = $startDate;
}

if (!empty($endDate)) {
    $where .= " AND DATE(created_at) <= ?";
    $params[] = $endDate;
}

if (!empty($minAmount)) {
    $where .= " AND amount >= ?";
    $params[] = $minAmount;
}

if (!empty($maxAmount)) {
    $where .= " AND amount <= ?";
    $params[] = $maxAmount;
}

// 计算分页
$offset = ($page - 1) * $limit;

try {
    // 查询数据
    $stmt = $db->prepare("
        SELECT * FROM b_task_statistics 
        WHERE $where 
        ORDER BY created_at DESC 
        LIMIT ? OFFSET ?
    ");
    $params[] = $limit;
    $params[] = $offset;
    $stmt->execute($params);
    $list = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 计算总数
    $stmt = $db->prepare("
        SELECT COUNT(*) as total FROM b_task_statistics 
        WHERE $where
    ");
    $countParams = array_slice($params, 0, -2); // 移除limit和offset参数
    $stmt->execute($countParams);
    $total = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 格式化数据
    $formattedList = [];
    foreach ($list as $item) {
        $formattedList[] = [
            'id' => $item['id'],
            'b_user_id' => $item['b_user_id'],
            'username' => $item['username'],
            'flow_type' => $item['flow_type'],
            'flow_type_text' => $item['flow_type'] === 1 ? '收入' : '支出',
            'amount' => $item['amount'],
            'amount_yuan' => number_format($item['amount'] / 100, 2),
            'before_balance' => $item['before_balance'],
            'after_balance' => $item['after_balance'],
            'related_type' => $item['related_type'],
            'related_type_text' => getRelatedTypeText($item['related_type']),
            'related_id' => $item['related_id'],
            'task_types' => $item['task_types'],
            'task_types_text' => $item['task_types_text'],
            'remark' => $item['remark'],
            'created_at' => $item['created_at']
        ];
    }
    
    // 计算总页数
    $totalPages = ceil($total / $limit);
    
    // 返回结果
    Response::success([
        'list' => $formattedList,
        'pagination' => [
            'page' => $page,
            'limit' => $limit,
            'total' => $total,
            'total_pages' => $totalPages
        ]
    ], '获取流水列表成功');
    
} catch (PDOException $e) {
    Response::error('获取流水列表失败: ' . $e->getMessage(), $errorCodes['DATABASE_ERROR'], 500);
} catch (Exception $e) {
    Response::error('获取流水列表失败: ' . $e->getMessage(), $errorCodes['SYSTEM_ERROR'], 500);
}

// 获取关联类型文本
function getRelatedTypeText($relatedType) {
    $map = [
        'task_publish' => '任务发布',
        'recharge' => '充值',
        'account_rental' => '账号租赁',
        'refund' => '退款'
    ];
    return $map[$relatedType] ?? $relatedType;
}
?>