<?php
/**
 * 提现申请列表接口
 * GET /task_admin/api/withdraw/list.php
 * 
 * 参数：
 * - page: 页码，默认1
 * - pageSize: 每页数量，默认10
 * - status: 状态筛选，0=待审核, 1=已通过, 2=已拒绝
 * - startDate: 开始日期
 * - endDate: 结束日期
 * - userType: 用户类型，0=B端, 1=C端, 2=其他
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');



// 处理OPTIONS预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 引入必要的文件
require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/Response.php';
require_once __DIR__ . '/../../auth/AuthMiddleware.php';

// 认证中间件
AdminAuthMiddleware::authenticate();

// 初始化数据库连接
$pdo = Database::connect();

// 初始化响应
$response = new Response();

// 处理查询参数
$page = max(1, (int)($_GET['page'] ?? 1));
$pageSize = min(100, max(1, (int)($_GET['pageSize'] ?? 10)));
$status = isset($_GET['status']) ? (int)$_GET['status'] : null;
$startDate = $_GET['startDate'] ?? null;
$endDate = $_GET['endDate'] ?? null;
$userType = isset($_GET['userType']) ? (int)$_GET['userType'] : null;

// 构建查询条件
$where = [];
$params = [];

if ($status !== null) {
    $where[] = 'w.status = ?';
    $params[] = $status;
}

if ($startDate) {
    $where[] = 'w.created_at >= ?';
    $params[] = $startDate . ' 00:00:00';
}

if ($endDate) {
    $where[] = 'w.created_at <= ?';
    $params[] = $endDate . ' 23:59:59';
}

if ($userType !== null) {
    $where[] = 'w.user_type = ?';
    $params[] = $userType;
}

$whereClause = $where ? 'WHERE ' . implode(' AND ', $where) : '';

// 计算总数
$countSql = "SELECT COUNT(*) FROM withdraw_requests w $whereClause";
$stmt = $pdo->prepare($countSql);
$stmt->execute($params);
$total = (int)$stmt->fetchColumn();

// 计算分页
$offset = ($page - 1) * $pageSize;

// 查询数据
$sql = "SELECT w.*, 
               COALESCE(b.username, c.username, CONCAT('用户ID:', w.user_id)) as username
        FROM withdraw_requests w
        LEFT JOIN b_users b ON w.user_id = b.id
        LEFT JOIN c_users c ON w.user_id = c.id
        $whereClause
        ORDER BY w.created_at DESC
        LIMIT ? OFFSET ?";

$params[] = $pageSize;
$params[] = $offset;

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$withdraws = $stmt->fetchAll(PDO::FETCH_ASSOC);

// 格式化状态
$statusMap = [
    0 => '待审核',
    1 => '已通过',
    2 => '已拒绝'
];

$userTypeMap = [
    0 => 'B端用户',
    1 => 'C端用户',
    2 => '其他用户'
];

foreach ($withdraws as &$withdraw) {
    $withdraw['status_text'] = $statusMap[$withdraw['status']] ?? '未知';
    $withdraw['user_type_text'] = $userTypeMap[$withdraw['user_type']] ?? '未知';
    $withdraw['created_at'] = date('Y-m-d H:i:s', strtotime($withdraw['created_at']));
}

// 返回结果
$response->success([
    'list' => $withdraws,
    'total' => $total,
    'page' => $page,
    'pageSize' => $pageSize,
    'total_pages' => $total > 0 ? (int)ceil($total / $pageSize) : 0
], time());
?>