<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}


// 引入必要的文件
require_once '../../../core/Database.php';
require_once '../../../core/Response.php';
require_once '../../../core/Auth.php';
require_once '../../auth/AuthMiddleware.php';

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
    $where[] = 'r.status = ?';
    $params[] = $status;
}

if ($startDate) {
    $where[] = 'r.created_at >= ?';
    $params[] = $startDate . ' 00:00:00';
}

if ($endDate) {
    $where[] = 'r.created_at <= ?';
    $params[] = $endDate . ' 23:59:59';
}

if ($userType !== null) {
    $where[] = 'r.user_type = ?';
    $params[] = $userType;
}

$whereClause = $where ? 'WHERE ' . implode(' AND ', $where) : '';

// 查询数据
$sql = "SELECT r.*, 
               CASE 
                   WHEN r.user_type = 0 THEN b.username 
                   WHEN r.user_type = 1 THEN c.username 
                   ELSE '未知用户' 
               END as username
        FROM recharge_requests r
        LEFT JOIN b_users b ON r.user_id = b.id AND r.user_type = 0
        LEFT JOIN c_users c ON r.user_id = c.id AND r.user_type = 1
        $whereClause
        ORDER BY r.created_at DESC";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$recharges = $stmt->fetchAll(PDO::FETCH_ASSOC);

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
$filename = 'recharge_records_' . date('YmdHis') . '.csv';
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
    '充值金额',
    '支付方式',
    '支付凭证',
    '状态',
    '备注',
    '创建时间'
]);

// 写入数据
foreach ($recharges as $index => $recharge) {
    fputcsv($output, [
        $index + 1,
        $userTypeMap[$recharge['user_type']] ?? '未知',
        $recharge['username'] ?? '未知',
        $recharge['amount'],
        $recharge['payment_method'] ?? '未知',
        $recharge['payment_voucher'] ?? '',
        $statusMap[$recharge['status']] ?? '未知',
        $recharge['remark'] ?? '',
        date('Y-m-d H:i:s', strtotime($recharge['created_at']))
    ]);
}

fclose($output);
?>