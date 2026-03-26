<?php
/**
 * C端用户发展下线列表接口
 * 
 * GET /api/c/v1/agent/develop-downlines
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * 响应示例（成功）：
 * {
 *   "code": 0,
 *   "message": "获取发展下线列表成功",
 *   "data": {
 *     "total": 2,
 *     "list": [
 *       {
 *         "downline_id": 123,
 *         "downline_username": "testuser1",
 *         "downline_invite_code": "ABC123",
 *         "completed_task_count": 10,
 *         "rejected_task_count": 2,
 *         "abandoned_task_count": 1,
 *         "appeal_task_count": 0
 *       },
 *       {
 *         "downline_id": 124,
 *         "downline_username": "testuser2",
 *         "downline_invite_code": "DEF456",
 *         "completed_task_count": 5,
 *         "rejected_task_count": 1,
 *         "abandoned_task_count": 0,
 *         "appeal_task_count": 1
 *       }
 *     ]
 *   },
 *   "timestamp": 1736582400
 * }
 * 
 * 错误码说明：
 * 1001 - 请求方法错误
 * 3003 - 用户信息不存在
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前接口上下文（必须！）
LoggerRouter::setContext('c/v1/agent/develop-downlines');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$errorLogger = LoggerFactory::getLogger('error');

// 记录请求开始
$requestLogger->info('=== C端用户发展下线列表接口调用开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');

// 只允许 GET 请求
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

try {
    // 查询当前用户发展的下线列表及其任务统计数据
    $requestLogger->debug('查询当前用户发展的下线列表', ['user_id' => $currentUser['user_id']]);
    $stmt = $db->prepare(" 
        SELECT 
            d.downline_user_id as downline_id,
            d.downline_username,
            d.downline_invite_code,
            COALESCE(s.completed_task_count, 0) as completed_task_count,
            COALESCE(s.rejected_task_count, 0) as rejected_task_count,
            COALESCE(s.abandoned_task_count, 0) as abandoned_task_count,
            COALESCE(s.appeal_task_count, 0) as appeal_task_count
        FROM develop_downline_users_count d
        LEFT JOIN c_user_task_records_static s ON s.user_id = d.downline_user_id
        WHERE d.developer_user_id = ?
        ORDER BY d.id DESC
    ");
    $stmt->execute([$currentUser['user_id']]);
    $downlines = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $requestLogger->debug('发展下线列表查询成功', ['count' => count($downlines)]);
    
    // 返回成功响应
    echo json_encode([
        'code' => 0,
        'message' => '获取发展下线列表成功',
        'data' => [
            'total' => count($downlines),
            'list' => $downlines
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    $errorLogger->error('获取发展下线列表失败', [
        'user_id' => $currentUser['user_id'],
        'exception' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
    echo json_encode([
        'code' => 3003,
        'message' => '获取发展下线列表失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    $errorLogger->error('获取发展下线列表失败', [
        'user_id' => $currentUser['user_id'],
        'exception' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
    echo json_encode([
        'code' => 3003,
        'message' => '获取发展下线列表失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
