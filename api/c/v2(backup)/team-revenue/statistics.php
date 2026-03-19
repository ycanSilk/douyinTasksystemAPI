<?php
/**
 * Admin端团队收益统计列表接口
 * 
 * GET /api/admin/team-revenue/statistics
 * 
 * 请求头：
 * X-Token: <token> (Admin端)
 * 
 * 请求参数：
 * - page: 页码
 * - limit: 每页条数
 * - keyword: 搜索（用户ID/用户名）
 * - is_agent: 代理等级筛选
 * - min_revenue: 最小团队收益
 * - sort_field: 排序字段
 * - sort_order: 排序方式：asc/desc
 * 
 * 返回结果：
 * {
 *   "code": 200,
 *   "message": "success",
 *   "data": {
 *     "total": 150,
 *     "list": [
 *       {
 *         "user_id": 1001,
 *         "username": "zhangzong",
 *         "is_agent": 3,
 *         "team_revenue": {
 *           "total": "3680.50",
 *           "level1": "2180.30",
 *           "level2": "1500.20"
 *         },
 *         "team_members": {
 *           "level1": {
 *             "total": 15,
 *             "active": 12
 *           },
 *           "level2": {
 *             "total": 28,
 *             "active": 20
 *           }
 *         },
 *         "revenue_stats": {
 *           "task_count": 86,
 *           "task_amount": "2280.50",
 *           "order_count": 22,
 *           "order_amount": "1400.00"
 *         },
 *         "last_revenue_time": "2024-01-20 15:30:45"
 *       }
 *     ]
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
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

// 获取当前用户ID
$currentUserId = $currentUser['user_id'];

// 获取请求参数
$page = intval($_GET['page'] ?? 1);
$limit = intval($_GET['limit'] ?? 20);
$userId = intval($_GET['user_id'] ?? 0); // 可选参数，指定用户ID
$username = trim($_GET['username'] ?? ''); // 可选参数，用户名称
$revenueSource = intval($_GET['revenue_source'] ?? 0); // 可选参数，收益来源
$startDate = trim($_GET['start_date'] ?? ''); // 可选参数，开始日期
$endDate = trim($_GET['end_date'] ?? ''); // 可选参数，结束日期
$days = intval($_GET['days'] ?? 0); // 可选参数，按天数筛选
$isAgent = intval($_GET['is_agent'] ?? 0);
$minRevenue = floatval($_GET['min_revenue'] ?? 0);
$sortField = trim($_GET['sort_field'] ?? 'total_team_revenue');
$sortOrder = strtolower(trim($_GET['sort_order'] ?? 'desc'));

// 如果提供了days参数，自动计算时间范围
if ($days > 0) {
    $endDate = date('Y-m-d');
    $startDate = date('Y-m-d', strtotime("-{$days} days"));
}

// 验证排序参数
$validSortFields = [
    'total_team_revenue',
    'level1_team_revenue',
    'level2_team_revenue',
    'level1_downline_count',
    'level2_downline_count',
    'total_downline_count',
    'task_revenue_count',
    'order_revenue_count',
    'last_revenue_time'
];

if (!in_array($sortField, $validSortFields)) {
    $sortField = 'total_team_revenue';
}

if (!in_array($sortOrder, ['asc', 'desc'])) {
    $sortOrder = 'desc';
}

// 计算分页偏移量
$offset = ($page - 1) * $limit;

try {
    // 构建查询条件
    $whereConditions = [];
    $params = [];
    
    // 强制筛选当前用户ID
    $whereConditions[] = 's.user_id = ?';
    $params[] = $currentUserId;
    
    // 按用户名称筛选
    if (!empty($username)) {
        $whereConditions[] = 's.username = ?';
        $params[] = $username;
    }
    
    if ($isAgent > 0) {
        $whereConditions[] = '(u.is_agent = ? OR u.is_agent IS NULL)';
        $params[] = $isAgent;
    }
    
    if ($minRevenue > 0) {
        $whereConditions[] = 's.total_team_revenue >= ?';
        $params[] = $minRevenue;
    }
    
    // 按收益来源筛选（需要从明细表关联查询）
    if ($revenueSource > 0 && in_array($revenueSource, [1, 2])) {
        $whereConditions[] = 's.user_id IN (SELECT DISTINCT agent_id FROM team_revenue_statistics_breakdown WHERE revenue_source = ?)';
        $params[] = $revenueSource;
    }
    
    // 按日期范围筛选（需要从明细表关联查询）
    if (!empty($startDate)) {
        $whereConditions[] = 's.user_id IN (SELECT DISTINCT agent_id FROM team_revenue_statistics_breakdown WHERE DATE(created_at) >= ?)';
        $params[] = $startDate;
    }
    
    if (!empty($endDate)) {
        $whereConditions[] = 's.user_id IN (SELECT DISTINCT agent_id FROM team_revenue_statistics_breakdown WHERE DATE(created_at) <= ?)';
        $params[] = $endDate;
    }
    
    $whereClause = '';
    if (!empty($whereConditions)) {
        $whereClause = 'WHERE ' . implode(' AND ', $whereConditions);
    }
    
    // 查询总数
    $countStmt = $db->prepare("SELECT COUNT(*) as total FROM team_revenue_statistics_summary s LEFT JOIN c_users u ON s.user_id = u.id {$whereClause}");
    $countStmt->execute($params);
    $total = $countStmt->fetchColumn();
    
    // 查询统计数据
    $listStmt = $db->prepare("SELECT
        s.user_id,
        s.username,
        u.is_agent,
        s.total_team_revenue,
        s.level1_team_revenue,
        s.level2_team_revenue,
        s.level1_downline_count,
        s.level2_downline_count,
        s.level1_active_count,
        s.level2_active_count,
        s.task_revenue_count,
        s.order_revenue_count,
        s.task_revenue_amount,
        s.order_revenue_amount,
        s.last_revenue_time
    FROM team_revenue_statistics_summary s
    LEFT JOIN c_users u ON s.user_id = u.id
    {$whereClause}
    ORDER BY s.{$sortField} {$sortOrder}
    LIMIT ? OFFSET ?");
    
    $listParams = array_merge($params, [$limit, $offset]);
    $listStmt->execute($listParams);
    $list = $listStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 格式化结果
    $formattedList = [];
    foreach ($list as $item) {
        $formattedList[] = [
            'user_id' => intval($item['user_id']),
            'username' => $item['username'],
            'is_agent' => intval($item['is_agent'] ?? 0),
            'team_revenue' => [
                'total' => $item['total_team_revenue'],
                'level1' => $item['level1_team_revenue'],
                'level2' => $item['level2_team_revenue']
            ],
            'team_members' => [
                'level1' => [
                    'total' => intval($item['level1_downline_count']),
                    'active' => intval($item['level1_active_count'])
                ],
                'level2' => [
                    'total' => intval($item['level2_downline_count']),
                    'active' => intval($item['level2_active_count'])
                ]
            ],
            'revenue_stats' => [
                'task_count' => intval($item['task_revenue_count']),
                'task_amount' => $item['task_revenue_amount'],
                'order_count' => intval($item['order_revenue_count']),
                'order_amount' => $item['order_revenue_amount']
            ],
            'last_revenue_time' => $item['last_revenue_time']
        ];
    }
    
    // 获取周期收益统计
    $periodRevenue = [];
    $timePeriods = [
        'today' => [
            'start' => date('Y-m-d 00:00:00'),
            'end' => date('Y-m-d 23:59:59')
        ],
        '7days' => [
            'start' => date('Y-m-d 00:00:00', strtotime('-7 days')),
            'end' => date('Y-m-d 23:59:59')
        ],
        '30days' => [
            'start' => date('Y-m-d 00:00:00', strtotime('-30 days')),
            'end' => date('Y-m-d 23:59:59')
        ]
    ];
    
    foreach ($timePeriods as $key => $period) {
        // 查询直接邀请（一级下线）的收益
        $level1Stmt = $db->prepare("SELECT
            COUNT(*) as count,
            SUM(team_revenue_amount) as amount
        FROM team_revenue_statistics_breakdown
        WHERE agent_id = ? AND agent_level = 1 AND created_at BETWEEN ? AND ?");
        $level1Stmt->execute([$currentUserId, $period['start'], $period['end']]);
        $level1Data = $level1Stmt->fetch(PDO::FETCH_ASSOC);
        
        // 查询间接邀请（二级下线）的收益
        $level2Stmt = $db->prepare("SELECT
            COUNT(*) as count,
            SUM(team_revenue_amount) as amount
        FROM team_revenue_statistics_breakdown
        WHERE agent_id = ? AND agent_level = 2 AND created_at BETWEEN ? AND ?");
        $level2Stmt->execute([$currentUserId, $period['start'], $period['end']]);
        $level2Data = $level2Stmt->fetch(PDO::FETCH_ASSOC);
        
        $periodRevenue[$key] = [
            'direct' => [
                'count' => intval($level1Data['count'] ?? 0),
                'amount' => $level1Data['amount'] ?? '0.00'
            ],
            'indirect' => [
                'count' => intval($level2Data['count'] ?? 0),
                'amount' => $level2Data['amount'] ?? '0.00'
            ],
            'total' => [
                'count' => intval($level1Data['count'] ?? 0) + intval($level2Data['count'] ?? 0),
                'amount' => number_format(floatval($level1Data['amount'] ?? 0) + floatval($level2Data['amount'] ?? 0), 2)
            ]
        ];
    }
    
    // 获取邀请用户周期收益
    $inviteUsersRevenue = [];
    
    // 查询当前用户的所有一级邀请用户（直接邀请）
    $level1Stmt = $db->prepare("SELECT
        u.id as user_id,
        u.username,
        r.level as agent_level
    FROM c_users u
    JOIN c_user_relations r ON u.id = r.user_id
    WHERE r.agent_id = ? AND r.level = 1");
    $level1Stmt->execute([$currentUserId]);
    $level1Users = $level1Stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 查询当前用户的所有二级邀请用户（间接邀请）
    $level2Stmt = $db->prepare("SELECT
        u.id as user_id,
        u.username,
        r.level as agent_level
    FROM c_users u
    JOIN c_user_relations r ON u.id = r.user_id
    WHERE r.agent_id = ? AND r.level = 2");
    $level2Stmt->execute([$currentUserId]);
    $level2Users = $level2Stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 合并一级和二级用户，确保每个用户只出现一次
    $inviteUsers = array_merge($level1Users, $level2Users);
    
    // 去重，保留用户的最高层级（一级优先于二级）
    $uniqueUsers = [];
    foreach ($inviteUsers as $user) {
        if (!isset($uniqueUsers[$user['user_id']]) || $user['agent_level'] < $uniqueUsers[$user['user_id']]['agent_level']) {
            $uniqueUsers[$user['user_id']] = $user;
        }
    }
    $inviteUsers = array_values($uniqueUsers);
    
    // 为每个邀请用户获取周期收益
    foreach ($inviteUsers as $user) {
        $userRevenue = [];
        
        foreach ($timePeriods as $key => $period) {
            // 查询该用户作为下线产生的收益
            $userRevenueStmt = $db->prepare("SELECT
                COUNT(*) as count,
                SUM(team_revenue_amount) as amount
            FROM team_revenue_statistics_breakdown
            WHERE downline_user_id = ? AND created_at BETWEEN ? AND ?");
            $userRevenueStmt->execute([$user['user_id'], $period['start'], $period['end']]);
            $userRevenueData = $userRevenueStmt->fetch(PDO::FETCH_ASSOC);
            
            $userRevenue[$key] = [
                'count' => intval($userRevenueData['count'] ?? 0),
                'amount' => $userRevenueData['amount'] ?? '0.00'
            ];
        }
        
        $inviteUsersRevenue[] = [
            'user_id' => intval($user['user_id']),
            'username' => $user['username'],
            'agent_level' => intval($user['agent_level']),
            'revenue' => $userRevenue
        ];
    }
    
    // 构建返回结果
    $result = [
        'total' => intval($total),
        'list' => $formattedList,
        'period_revenue' => $periodRevenue,
        'invite_users_revenue' => $inviteUsersRevenue
    ];
    
    Response::success($result, '团队收益统计列表查询成功');
    
} catch (PDOException $e) {
    // 输出错误信息到日志文件
    error_log('Admin端团队收益统计列表API Error: ' . $e->getMessage());
    // 返回错误信息
    Response::error('查询失败: ' . $e->getMessage(), $errorCodes['SERVER_ERROR'], 500);
}