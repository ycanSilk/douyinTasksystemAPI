<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');



// 处理OPTIONS预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}
// 引入必要的文件
// 引入必要的文件
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';
require_once __DIR__ . '/../../auth/AuthMiddleware.php';

// 初始化数据库连接
$pdo = Database::connect();

// 初始化响应
$response = new Response();

// 认证中间件
AdminAuthMiddleware::authenticate();

// 处理查询参数
$status = isset($_GET['status']) ? intval($_GET['status']) : null;
$startDate = isset($_GET['startDate']) ? $_GET['startDate'] : null;
$endDate = isset($_GET['endDate']) ? $_GET['endDate'] : null;
$userType = isset($_GET['userType']) ? intval($_GET['userType']) : null;

// 构建查询
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

// 查询数据
$sql = "SELECT w.*, 
               CASE 
                   WHEN w.user_type = 0 THEN b.username 
                   WHEN w.user_type = 1 THEN c.username 
                   ELSE '未知用户' 
               END as username
        FROM withdraw_requests w
        LEFT JOIN b_users b ON w.user_id = b.id AND w.user_type = 0
        LEFT JOIN c_users c ON w.user_id = c.id AND w.user_type = 1
        $whereClause
        ORDER BY w.created_at DESC";

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
    1 => 'C端用户'
];

// 准备CSV文件
$filename = 'withdraw_records_' . date('YmdHis') . '.csv';
header("Content-Disposition: attachment; filename=$filename");

// 创建CSV文件
$output = fopen('php://output', 'w');

// 写入BOM，解决中文乱码
fwrite($output, "\xEF\xBB\xBF");

// 写入表头
fputcsv($output, [
    '序号',
    '用户类型',
    '用户名',
    '提现金额',
    '手续费率',
    '手续费',
    '实际金额',
    '提现方式',
    '提现账号',
    '账号姓名',
    '状态',
    '备注',
    '创建时间'
]);

// 写入数据
foreach ($withdraws as $index => $withdraw) {
    fputcsv($output, [
        $index + 1,
        $userTypeMap[$withdraw['user_type']] ?? '未知',
        $withdraw['username'] ?? '未知',
        $withdraw['amount'],
        $withdraw['fee_rate'] ?? '0',
        $withdraw['fee_amount'] ?? '0',
        $withdraw['actual_amount'] ?? $withdraw['amount'],
        $withdraw['withdraw_method'] ?? '未知',
        $withdraw['withdraw_account'] ?? '',
        $withdraw['account_name'] ?? '',
        $statusMap[$withdraw['status']] ?? '未知',
        $withdraw['remark'] ?? '',
        date('Y-m-d H:i:s', strtotime($withdraw['created_at']))
    ]);
}

fclose($output);
?>