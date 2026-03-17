<?php
/**
 * C端团队收益统计接口
 * 
 * GET /api/c/team-revenue/statistics
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * 返回结果：
 * {
 *   "code": 200,
 *   "message": "success",
 *   "data": {
 *     "user_info": {
 *       "user_id": 1001,
 *       "username": "zhangzong",
 *       "is_agent": 3
 *     },
 *     "team_revenue": {
 *       "total": "3680.50",
 *       "level1": "2180.30",
 *       "level2": "1500.20"
 *     },
 *     "team_members": {
 *       "level1": {
 *         "total_count": 15,
 *         "active_count": 12
 *       },
 *       "level2": {
 *         "total_count": 28,
 *         "active_count": 20
 *       },
 *       "total_count": 43
 *     },
 *     "revenue_details": {
 *       "task": {
 *         "count": 86,
 *         "amount": "2280.50"
 *       },
 *       "order": {
 *         "count": 22,
 *         "amount": "1400.00"
 *       }
 *     },
 *     "last_revenue_time": "2024-01-20 15:30:45",
 *     "last_level1_time": "2024-01-20 15:30:45",
 *     "last_level2_time": "2024-01-20 14:20:10"
 *   }
 * }
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
require_once __DIR__ . '/../../../../core/Token.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 验证C端用户身份
$token = Token::getFromRequest();
if (!$token) {
    Response::error('未提供认证Token', 401);
}

$db = Database::connect();
$result = Token::verify($token, Token::TYPE_C, $db);

if (!$result['valid']) {
    Response::error($result['error'], $result['code']);
}

$userId = $result['user_id'];

try {
    // 查询用户信息
    $userStmt = $db->prepare("SELECT id, username, is_agent FROM c_users WHERE id = ?");
    $userStmt->execute([$userId]);
    $userInfo = $userStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$userInfo) {
        Response::error('用户不存在', 404);
    }
    
    // 查询团队收益汇总信息
    $summaryStmt = $db->prepare("SELECT
        total_team_revenue,
        level1_team_revenue,
        level2_team_revenue,
        level1_downline_count,
        level2_downline_count,
        total_downline_count,
        level1_active_count,
        level2_active_count,
        task_revenue_count,
        order_revenue_count,
        task_revenue_amount,
        order_revenue_amount,
        last_revenue_time,
        last_level1_revenue_time,
        last_level2_revenue_time
    FROM team_revenue_statistics_summary
    WHERE user_id = ?");
    
    $summaryStmt->execute([$userId]);
    $summary = $summaryStmt->fetch(PDO::FETCH_ASSOC);
    
    // 如果没有记录，返回默认值
    if (!$summary) {
        $summary = [
            'total_team_revenue' => '0.00',
            'level1_team_revenue' => '0.00',
            'level2_team_revenue' => '0.00',
            'level1_downline_count' => 0,
            'level2_downline_count' => 0,
            'total_downline_count' => 0,
            'level1_active_count' => 0,
            'level2_active_count' => 0,
            'task_revenue_count' => 0,
            'order_revenue_count' => 0,
            'task_revenue_amount' => '0.00',
            'order_revenue_amount' => '0.00',
            'last_revenue_time' => null,
            'last_level1_revenue_time' => null,
            'last_level2_revenue_time' => null
        ];
    }
    
    // 构建响应数据
    $responseData = [
        'user_info' => [
            'user_id' => intval($userInfo['id']),
            'username' => $userInfo['username'] ?? '',
            'is_agent' => intval($userInfo['is_agent'] ?? 0)
        ],
        'team_revenue' => [
            'total' => $summary['total_team_revenue'],
            'level1' => $summary['level1_team_revenue'],
            'level2' => $summary['level2_team_revenue']
        ],
        'team_members' => [
            'level1' => [
                'total_count' => intval($summary['level1_downline_count']),
                'active_count' => intval($summary['level1_active_count'])
            ],
            'level2' => [
                'total_count' => intval($summary['level2_downline_count']),
                'active_count' => intval($summary['level2_active_count'])
            ],
            'total_count' => intval($summary['total_downline_count'])
        ],
        'revenue_details' => [
            'task' => [
                'count' => intval($summary['task_revenue_count']),
                'amount' => $summary['task_revenue_amount']
            ],
            'order' => [
                'count' => intval($summary['order_revenue_count']),
                'amount' => $summary['order_revenue_amount']
            ]
        ],
        'last_revenue_time' => $summary['last_revenue_time'],
        'last_level1_time' => $summary['last_level1_revenue_time'],
        'last_level2_time' => $summary['last_level2_revenue_time']
    ];
    
    Response::success($responseData, '团队收益统计查询成功');
    
} catch (PDOException $e) {
    // 输出错误信息到日志文件
    error_log('C端团队收益统计API Error: ' . $e->getMessage());
    // 返回错误信息
    Response::error('查询失败: ' . $e->getMessage(), $errorCodes['SERVER_ERROR'], 500);
}
