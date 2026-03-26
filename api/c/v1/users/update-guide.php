<?php
/**
 * C端用户更新新手指引状态接口
 * 
 * POST /api/c/v1/users/update-guide.php
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * Content-Type: application/json
 * 
 * 响应示例（成功）：
 * {
 *   "code": 0,
 *   "message": "更新成功",
 *   "data": {
 *     "has_completed_newbie_guide": 1
 *   },
 *   "timestamp": 1736582400
 * }
 * 
 * 响应示例（失败）：
 * {
 *   "code": 1001,
 *   "message": "请求方法错误",
 *   "data": [],
 *   "timestamp": 1736582400
 * }
 * 
 * 错误码说明：
 * 1001 - 请求方法错误
 * 3003 - 用户信息不存在
 * 1002 - 数据库连接失败
 * 401 - 认证失败
 * 500 - 未知错误
 * 501 - 更新失败
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前接口上下文（必须！）
LoggerRouter::setContext('c/v1/users/update-guide');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$errorLogger = LoggerFactory::getLogger('error');

// 记录请求开始
$requestLogger->info('=== C端用户更新新手指引状态接口调用开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
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
try {
    $db = Database::connect();
    $requestLogger->debug('数据库连接成功');
} catch (Exception $e) {
    $errorLogger->error('数据库连接失败', ['exception' => $e->getMessage()]);
    http_response_code(500);
    echo json_encode([
        'code' => 1002,
        'message' => '数据库连接失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
try {
    $currentUser = $auth->authenticateC();
    $requestLogger->debug('用户认证成功', ['user_id' => $currentUser['user_id']]);
} catch (Exception $e) {
    $errorLogger->error('用户认证失败', ['exception' => $e->getMessage()]);
    http_response_code(401);
    echo json_encode([
        'code' => 401,
        'message' => '认证失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 查询用户当前的新手指引状态
try {
    $requestLogger->debug('查询用户新手指引状态', ['user_id' => $currentUser['user_id']]);
    $stmt = $db->prepare("SELECT has_completed_newbie_guide FROM c_users WHERE id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $userInfo = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$userInfo) {
        $errorLogger->error('用户不存在', ['user_id' => $currentUser['user_id']]);
        echo json_encode([
            'code' => 3003,
            'message' => '用户信息不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 判断是否已经完成新手指引
    if ($userInfo['has_completed_newbie_guide'] == 1) {
        $requestLogger->debug('用户已完成新手指引', ['user_id' => $currentUser['user_id']]);
        echo json_encode([
            'code' => 0,
            'message' => '已完成新手指引',
            'data' => [
                'has_completed_newbie_guide' => 1
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 更新新手指引状态为已完成
    $requestLogger->debug('更新新手指引状态', ['user_id' => $currentUser['user_id']]);
    $stmt = $db->prepare("UPDATE c_users SET has_completed_newbie_guide = 1 WHERE id = ?");
    $result = $stmt->execute([$currentUser['user_id']]);
    
    if ($result) {
        $requestLogger->info('新手指引状态更新成功', ['user_id' => $currentUser['user_id']]);
        echo json_encode([
            'code' => 0,
            'message' => '更新成功',
            'data' => [
                'has_completed_newbie_guide' => 1
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
    } else {
        $errorLogger->error('新手指引状态更新失败', ['user_id' => $currentUser['user_id']]);
        echo json_encode([
            'code' => 500,
            'message' => '更新失败',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
} catch (Exception $e) {
    $errorLogger->error('更新新手指引状态异常', [
        'user_id' => $currentUser['user_id'],
        'exception' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
    echo json_encode([
        'code' => 501,
        'message' => '更新失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
