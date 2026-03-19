<?php
/**
 * B端流水列表接口
 * 
 * GET /api/b_users_static/flows
 * 
 * 请求参数：
 * - page: 页码，默认1
 * - limit: 每页数量，默认100
 * - b_user_id: B端用户ID
 * - related_id: 关联ID（任务ID、订单ID等）
 * - related_type: 关联类型：task_publish, recharge, account_rental, refund
 * - task_types: 任务类型：1=上评评论，2=中评评论，3=放大镜搜索词，4=上中评评论，5=中下评评论，6=出租订单，7=求租订单
 * - start_date: 开始日期，格式：YYYY-MM-DD
 * - end_date: 结束日期，格式：YYYY-MM-DD
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: X-Token, Content-Type, Authorization');

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
require_once __DIR__ . '/../../../../core/Response.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 连接数据库
$db = Database::connect();

// 验证C端用户身份
$auth = new AuthMiddleware($db);
$userInfo = $auth->authenticateC();
$cUserId = $userInfo['user_id'];

// 获取请求参数
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 100;
$relatedId = isset($_GET['related_id']) ? (int)$_GET['related_id'] : 0;
$relatedType = isset($_GET['related_type']) ? $_GET['related_type'] : '';
$taskTypes = isset($_GET['task_types']) ? (int)$_GET['task_types'] : 0;
$startDate = isset($_GET['start_date']) ? $_GET['start_date'] : '';
$endDate = isset($_GET['end_date']) ? $_GET['end_date'] : '';

// 构建查询条件
$where = "c_user_id = ?";
$params = [$cUserId];

// 这里不再接受c_user_id参数，因为我们使用当前认证用户的ID

if (!empty($relatedId)) {
    $where .= " AND related_id = ?";
    $params[] = $relatedId;
}

if (!empty($relatedType)) {
    $where .= " AND related_type = ?";
    $params[] = $relatedType;
}

if (!empty($taskTypes)) {
    $where .= " AND task_types = ?";
    $params[] = $taskTypes;
}

if (!empty($startDate)) {
    $where .= " AND DATE(created_at) >= ?";
    $params[] = $startDate;
}

if (!empty($endDate)) {
    $where .= " AND DATE(created_at) <= ?";
    $params[] = $endDate;
}

// 计算分页
$offset = ($page - 1) * $limit;

try {
    // 查询数据
    $stmt = $db->prepare("
        SELECT * FROM c_task_statistics 
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
        SELECT COUNT(*) as total FROM c_task_statistics 
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
            'c_user_id' => $item['c_user_id'],
            'username' => $item['username'],
            'flow_type' => $item['flow_type'],
            'flow_type_text' => $item['flow_type'] === 1 ? '收入' : '支出',
            'amount' => round($item['amount'] / 100, 2),
            'before_balance' => round($item['before_balance'] / 100, 2),
            'after_balance' => round($item['after_balance'] / 100, 2),
            'related_type' => $item['related_type'],
            'related_type_text' => getRelatedTypeText($item['related_type']),
            'related_id' => $item['related_id'],
            'task_types' => $item['task_types'],
            'task_types_text' => getTaskTypesText($item['task_types']),
            'record_status_text' => $item['record_status_text'] ?? '',
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
    return $map[(string)$relatedType] ?? $relatedType;
}

// 获取任务类型文本
function getTaskTypesText($taskTypes) {
    $map = [
        1 => '上评评论',
        2 => '中评评论',
        3 => '放大镜搜索词',
        4 => '上中评评论',
        5 => '中下评评论',
        6 => '出租订单',
        7 => '求租订单'
    ];
    return $map[(int)$taskTypes] ?? '';
}
?>