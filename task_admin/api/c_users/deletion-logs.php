<?php
/**
 * C端用户注销日志查询接口
 * GET /task_admin/api/c_users/deletion-logs.php
 *
 * 功能：
 * 1. 查询C端用户注销日志记录
 * 2. 支持分页、搜索、筛选
 *
 * 请求参数：
 * - page: 页码（可选，默认1）
 * - page_size: 每页数量（可选，默认20，最大100）
 * - user_id: 用户ID筛选（可选）
 * - username: 用户名搜索（可选）
 * - status: 注销状态筛选（可选，1=成功，0=失败）
 * - start_date: 开始日期（可选，格式：Y-m-d）
 * - end_date: 结束日期（可选，格式：Y-m-d）
 *
 * 响应示例（成功）：
 * {
 *   "code": 0,
 *   "message": "查询成功",
 *   "data": {
 *     "list": [
 *       {
 *         "id": 1,
 *         "user_id": 152,
 *         "user_type": 1,
 *         "username": "ces1111",
 *         "wallet_id": 86,
 *         "wallet_balance_before": 0,
 *         "operator_id": 1,
 *         "operator_type": 3,
 *         "operator_username": "task",
 *         "operation_ip": "127.0.0.1",
 *         "status": 1,
 *         "error_code": null,
 *         "error_message": null,
 *         "created_at": "2026-03-31 17:45:44"
 *       }
 *     ],
 *     "pagination": {
 *       "page": 1,
 *       "page_size": 20,
 *       "total": 100,
 *       "total_pages": 5
 *     }
 *   },
 *   "timestamp": 1736582400
 * }
 *
 * 错误码说明：
 * - 1001: 请求方法错误
 * - 5000: 服务器内部错误
 */

// 硬编码错误码
const ERROR_CODES = [
    'SUCCESS' => 0,
    'METHOD_NOT_ALLOWED' => 1001,
    'SERVER_ERROR' => 5000,
];

// 加载统一日志系统
require_once __DIR__ . '/../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前接口上下文（必须！）
LoggerRouter::setContext('task_admin/c_users/deletion-logs');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$errorLogger = LoggerFactory::getLogger('error');

// 记录请求开始
$requestLogger->info('=== C端用户注销日志查询请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 只允许 GET 请求
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);
    http_response_code(405);
    echo json_encode([
        'code' => ERROR_CODES['METHOD_NOT_ALLOWED'],
        'message' => '请求方法错误，只允许GET请求',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';

// 管理员认证
AdminAuthMiddleware::authenticate();

$db = Database::connect();

// 获取查询参数
$page = (int)($_GET['page'] ?? 1);
$pageSize = (int)($_GET['page_size'] ?? 20);
$userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : null;
$username = $_GET['username'] ?? null;
$status = isset($_GET['status']) ? (int)$_GET['status'] : null;
$startDate = $_GET['start_date'] ?? null;
$endDate = $_GET['end_date'] ?? null;

// 参数校验
if ($page < 1) $page = 1;
if ($pageSize < 1) $pageSize = 20;
if ($pageSize > 100) $pageSize = 100;

// 记录请求参数
$requestLogger->debug('请求参数', [
    'page' => $page,
    'page_size' => $pageSize,
    'user_id' => $userId,
    'username' => $username,
    'status' => $status,
    'start_date' => $startDate,
    'end_date' => $endDate,
]);

try {
    // 构建查询条件
    $whereConditions = ['user_type = 1']; // 只查询C端用户
    $params = [];

    if ($userId) {
        $whereConditions[] = 'user_id = ?';
        $params[] = $userId;
    }

    if ($username) {
        $whereConditions[] = 'username LIKE ?';
        $params[] = '%' . $username . '%';
    }

    if ($status !== null) {
        $whereConditions[] = 'status = ?';
        $params[] = $status;
    }

    if ($startDate) {
        $whereConditions[] = 'created_at >= ?';
        $params[] = $startDate . ' 00:00:00';
    }

    if ($endDate) {
        $whereConditions[] = 'created_at <= ?';
        $params[] = $endDate . ' 23:59:59';
    }

    $whereClause = implode(' AND ', $whereConditions);

    // 查询总数
    $countSql = "SELECT COUNT(*) as total FROM user_deletion_logs WHERE {$whereClause}";
    $stmt = $db->prepare($countSql);
    $stmt->execute($params);
    $total = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];

    // 计算分页
    $totalPages = (int)ceil($total / $pageSize);
    $offset = ($page - 1) * $pageSize;

    // 查询数据
    $sql = "
        SELECT 
            id,
            user_id,
            user_type,
            username,
            wallet_id,
            wallet_balance_before,
            operator_id,
            operator_type,
            operator_username,
            operation_ip,
            status,
            error_code,
            error_message,
            created_at
        FROM user_deletion_logs
        WHERE {$whereClause}
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
    ";

    $stmt = $db->prepare($sql);
    // 合并参数
    $queryParams = array_merge($params, [$pageSize, $offset]);
    $stmt->execute($queryParams);
    $list = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // 格式化数据
    foreach ($list as &$item) {
        $item['id'] = (int)$item['id'];
        $item['user_id'] = (int)$item['user_id'];
        $item['user_type'] = (int)$item['user_type'];
        $item['wallet_id'] = $item['wallet_id'] ? (int)$item['wallet_id'] : null;
        $item['wallet_balance_before'] = (int)$item['wallet_balance_before'];
        $item['operator_id'] = $item['operator_id'] ? (int)$item['operator_id'] : null;
        $item['operator_type'] = (int)$item['operator_type'];
        $item['status'] = (int)$item['status'];
        $item['error_code'] = $item['error_code'] !== null ? (int)$item['error_code'] : null;
        
        // 格式化余额
        $item['wallet_balance_before_formatted'] = '¥' . number_format($item['wallet_balance_before'] / 100, 2);
        
        // 格式化状态文本
        $item['status_text'] = $item['status'] === 1 ? '成功' : '失败';
        
        // 格式化用户类型文本
        $userTypeMap = [
            1 => 'C端用户',
            2 => 'B端用户',
            3 => 'Admin用户',
        ];
        $item['user_type_text'] = $userTypeMap[$item['user_type']] ?? '未知';
        
        // 格式化操作人类型文本
        $operatorTypeMap = [
            1 => 'C端',
            2 => 'B端',
            3 => 'Admin端',
        ];
        $item['operator_type_text'] = $operatorTypeMap[$item['operator_type']] ?? '未知';
    }

    $requestLogger->info('C端用户注销日志查询成功', [
        'total' => $total,
        'page' => $page,
        'page_size' => $pageSize,
    ]);

    echo json_encode([
        'code' => ERROR_CODES['SUCCESS'],
        'message' => '查询成功',
        'data' => [
            'list' => $list,
            'pagination' => [
                'page' => $page,
                'page_size' => $pageSize,
                'total' => $total,
                'total_pages' => $totalPages,
            ],
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    $errorLogger->error('C端用户注销日志查询失败：数据库异常', [
        'message' => $e->getMessage(),
        'code' => $e->getCode(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    http_response_code(500);
    echo json_encode([
        'code' => ERROR_CODES['SERVER_ERROR'],
        'message' => '查询失败：' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
