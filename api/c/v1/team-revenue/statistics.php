<?php
/**
 * C端团队收益统计接口
 * 
 * GET /api/c/v1/team-revenue/statistics
 * 
 * 请求头：
 * X-Token: <token> (C端用户)
 * 
 * 请求参数：
 * - period: 统计周期（today、yesterday、7days、30days），默认today
 * 
 * 返回结果：
 * {
 *   "code": 0,
 *   "message": "团队收益统计查询成功",
 *   "data": {
 *     // 1. 团队总收益统计
 *     "team_summary": {
 *       "total_amount": "15.00",
 *       "total_count": 15,
 *       "user_count": 10
 *     },
 *     
 *     // 2. 每个用户的周期数据统计
 *     "user_stats": [
 *       {
 *         "user_id": 144,
 *         "username": "qqq7",
 *         "invite_level": 1,
 *         "period_amount": "5.00",
 *         "period_count": 5,
 *         "total_amount": "50.00",
 *         "total_count": 50
 *       }
 *     ]
 *   }
 * }
 * 
 * 错误码说明：
 * - 1001: 请求方法错误
 * - 1002: 无效的Token
 * - 1003: 权限不足
 * - 5000: 服务器内部错误
 * - 6001: 无效的统计周期参数
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: X-Token, Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// 加载统一日志系统
require_once __DIR__ . '/../../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

LoggerRouter::setContext('c/v1/team-revenue/statistics');

$requestLogger = LoggerFactory::getLogger('request');
$auditLogger = LoggerFactory::getLogger('audit');
$errorLogger = LoggerFactory::getLogger('error');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);

    $auditLogger->warning('C端用户获取团队收益统计失败：请求方法错误', [
        'reason' => '请求方法错误',
    ]);

    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

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

// 硬编码错误码
$errorCodes = [
    'INVALID_METHOD' => 1001,
    'INVALID_TOKEN' => 1002,
    'PERMISSION_DENIED' => 1003,
    'SERVER_ERROR' => 5000,
    'INVALID_PERIOD' => 6001
];

// 数据库连接
$db = Database::connect();

$requestLogger->info('=== C端团队收益统计接口调用开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
try {
    $currentUser = $auth->authenticateC();
    $requestLogger->info('Token认证成功', ['user_id' => $currentUser['user_id'], 'username' => $currentUser['username'] ?? '未知']);
} catch (Exception $e) {
    $errorLogger->error('Token认证失败', ['exception' => $e->getMessage()]);
    
    $auditLogger->warning('C端用户获取团队收益统计失败：Token认证失败', [
        'exception' => $e->getMessage(),
        'reason' => 'Token认证失败',
    ]);
    
    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    Response::error('无效的Token', $errorCodes['INVALID_TOKEN'], 401);
}

// 获取当前用户ID
$currentUserId = $currentUser['user_id'];

// 获取请求参数
$period = trim($_GET['period'] ?? 'today');
$validPeriods = ['today', 'yesterday', '7days', '30days'];

// 验证周期参数
if (!in_array($period, $validPeriods)) {
    $requestLogger->warning('无效的统计周期参数', ['period' => $period]);
    Response::error('无效的统计周期参数，可选值：today、yesterday、7days、30days', $errorCodes['INVALID_PERIOD'], 400);
}

// 计算时间范围
$today = date('Y-m-d');
switch ($period) {
    case 'today':
        $periodStart = $today . ' 00:00:00';
        $periodEnd = $today . ' 23:59:59';
        break;
    case 'yesterday':
        $yesterday = date('Y-m-d', strtotime('-1 day'));
        $periodStart = $yesterday . ' 00:00:00';
        $periodEnd = $yesterday . ' 23:59:59';
        break;
    case '7days':
        $sevenDaysAgo = date('Y-m-d', strtotime('-7 days'));
        $periodStart = $sevenDaysAgo . ' 00:00:00';
        $periodEnd = $today . ' 23:59:59';
        break;
    case '30days':
        $thirtyDaysAgo = date('Y-m-d', strtotime('-30 days'));
        $periodStart = $thirtyDaysAgo . ' 00:00:00';
        $periodEnd = $today . ' 23:59:59';
        break;
    default:
        $periodStart = $today . ' 00:00:00';
        $periodEnd = $today . ' 23:59:59';
}

try {
    // ========== 1. 查询c_user_relations获取邀请用户列表 ==========
    $stmt = $db->prepare("
        SELECT 
            u.id as user_id,
            u.username,
            r.level as invite_level
        FROM c_user_relations r
        JOIN c_users u ON r.user_id = u.id
        WHERE r.agent_id = ? AND r.level IN (1, 2)
        ORDER BY r.level ASC, u.id ASC
    ");
    $stmt->execute([$currentUserId]);
    $inviteUsers = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $requestLogger->info('获取邀请用户列表成功', [
        'user_id' => $currentUserId,
        'invite_count' => count($inviteUsers)
    ]);
    
    // ========== 2. 循环遍历查询c_task_statistics统计收益 ==========
    $userStats = [];
    $teamPeriodAmount = 0;
    $teamPeriodCount = 0;
    $teamTotalAmount = 0;
    $teamTotalCount = 0;
    
    foreach ($inviteUsers as $user) {
        $userId = $user['user_id'];
        
        // 查询指定周期的收益统计
        $periodStmt = $db->prepare("
            SELECT 
                COUNT(*) as period_count,
                SUM(amount) as period_amount
            FROM c_task_statistics
            WHERE c_user_id = ? 
              AND flow_type = 1 
              AND created_at BETWEEN ? AND ?
        ");
        $periodStmt->execute([$userId, $periodStart, $periodEnd]);
        $periodData = $periodStmt->fetch(PDO::FETCH_ASSOC);
        
        // 查询总收益统计
        $totalStmt = $db->prepare("
            SELECT 
                COUNT(*) as total_count,
                SUM(amount) as total_amount
            FROM c_task_statistics
            WHERE c_user_id = ? AND flow_type = 1
        ");
        $totalStmt->execute([$userId]);
        $totalData = $totalStmt->fetch(PDO::FETCH_ASSOC);
        
        $periodAmount = floatval($periodData['period_amount'] ?? 0);
        $periodCount = intval($periodData['period_count'] ?? 0);
        $totalAmount = floatval($totalData['total_amount'] ?? 0);
        $totalCount = intval($totalData['total_count'] ?? 0);
        
        // 累加团队统计
        $teamPeriodAmount += $periodAmount;
        $teamPeriodCount += $periodCount;
        $teamTotalAmount += $totalAmount;
        $teamTotalCount += $totalCount;
        
        // 添加用户统计
        $userStats[] = [
            'user_id' => intval($userId),
            'username' => $user['username'],
            'invite_level' => intval($user['invite_level']),
            'period_amount' => number_format($periodAmount / 100, 2),
            'period_count' => $periodCount,
            'total_amount' => number_format($totalAmount / 100, 2),
            'total_count' => $totalCount
        ];
    }
    
    // ========== 3. 构建返回结果 ==========
    $result = [
        'team_summary' => [
            'period' => $period,
            'period_amount' => number_format($teamPeriodAmount / 100, 2),
            'period_count' => $teamPeriodCount,
            'total_amount' => number_format($teamTotalAmount / 100, 2),
            'total_count' => $teamTotalCount,
            'user_count' => count($inviteUsers)
        ],
        'user_stats' => $userStats
    ];
    
    $auditLogger->notice('C端用户获取团队收益统计成功', [
        'user_id' => $currentUserId,
        'period' => $period,
        'user_count' => count($inviteUsers),
        'team_period_amount' => $teamPeriodAmount,
    ]);
    
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }
    
    $requestLogger->info('C端获取团队收益统计成功', [
        'user_id' => $currentUserId,
        'period' => $period,
        'user_count' => count($inviteUsers),
        'team_period_amount' => number_format($teamPeriodAmount / 100, 2),
    ]);
    
    Response::success($result, '团队收益统计查询成功');
    
} catch (PDOException $e) {
    $errorLogger->error('查询失败：数据库异常', [
        'message' => $e->getMessage(),
        'code' => $e->getCode(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    $auditLogger->error('C端用户获取团队收益统计失败：数据库异常', [
        'message' => $e->getMessage(),
        'reason' => '数据库异常',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('查询失败', $errorCodes['SERVER_ERROR'], 500);
} catch (Exception $e) {
    $errorLogger->error('查询失败：系统异常', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    $auditLogger->error('C端用户获取团队收益统计失败：系统异常', [
        'message' => $e->getMessage(),
        'reason' => '系统异常',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('查询失败', $errorCodes['SERVER_ERROR'], 500);
}