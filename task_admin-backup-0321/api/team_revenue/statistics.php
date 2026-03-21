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

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Token.php';
require_once __DIR__ . '/../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 验证Admin端用户身份
$token = Token::getFromRequest();
if (!$token) {
    Response::error('未提供认证Token', 401);
}

$db = Database::connect();
$result = Token::verify($token, Token::TYPE_ADMIN, $db);

if (!$result['valid']) {
    Response::error($result['error'], $result['code']);
}

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
    
    // 按用户ID筛选
    if ($userId > 0) {
        $whereConditions[] = 's.user_id = ?';
        $params[] = $userId;
    }
    
    // 按用户名称筛选
    if (!empty($username)) {
        $whereConditions[] = 's.username = ?';
        $params[] = $username;
    }
    
    if ($isAgent > 0) {
        $whereConditions[] = 'u.is_agent = ?';
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
                'total' => number_format(floatval($item['total_team_revenue']) / 100, 2),
                'level1' => number_format(floatval($item['level1_team_revenue']) / 100, 2),
                'level2' => number_format(floatval($item['level2_team_revenue']) / 100, 2)
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
                'task_amount' => number_format(floatval($item['task_revenue_amount']) / 100, 2),
                'order_count' => intval($item['order_revenue_count']),
                'order_amount' => number_format(floatval($item['order_revenue_amount']) / 100, 2)
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
        'yesterday' => [
            'start' => date('Y-m-d 00:00:00', strtotime('-1 day')),
            'end' => date('Y-m-d 23:59:59', strtotime('-1 day'))
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
        WHERE agent_level = 1 AND created_at BETWEEN ? AND ?");
        $level1Stmt->execute([$period['start'], $period['end']]);
        $level1Data = $level1Stmt->fetch(PDO::FETCH_ASSOC);
        
        // 查询间接邀请（二级下线）的收益
        $level2Stmt = $db->prepare("SELECT
            COUNT(*) as count,
            SUM(team_revenue_amount) as amount
        FROM team_revenue_statistics_breakdown
        WHERE agent_level = 2 AND created_at BETWEEN ? AND ?");
        $level2Stmt->execute([$period['start'], $period['end']]);
        $level2Data = $level2Stmt->fetch(PDO::FETCH_ASSOC);
        
        $periodRevenue[$key] = [
            'direct' => [
                'count' => intval($level1Data['count'] ?? 0),
                'amount' => number_format(floatval($level1Data['amount'] ?? 0) / 100, 2)
            ],
            'indirect' => [
                'count' => intval($level2Data['count'] ?? 0),
                'amount' => number_format(floatval($level2Data['amount'] ?? 0) / 100, 2)
            ],
            'total' => [
                'count' => intval($level1Data['count'] ?? 0) + intval($level2Data['count'] ?? 0),
                'amount' => number_format((floatval($level1Data['amount'] ?? 0) + floatval($level2Data['amount'] ?? 0)) / 100, 2)
            ]
        ];
    }
    
    // 构建返回结果
    $result = [
        'total' => intval($total),
        'list' => $formattedList,
        'period_revenue' => $periodRevenue
    ];
    
    // 获取团队用户列表（包含一级、二级代理）
    try {
        $teamUsersStmt = $db->prepare("SELECT
            u.id as user_id,
            u.username,
            u.phone,
            u.is_agent,
            u.created_at,
            IFNULL(r.agent_id, 0) as parent_id,
            IFNULL(p.username, '') as parent_username,
            IFNULL(r.level, 0) as agent_level
        FROM c_users u
        LEFT JOIN c_user_relations r ON u.id = r.user_id
        LEFT JOIN c_users p ON r.agent_id = p.id
        WHERE u.is_agent > 0
        ORDER BY u.created_at DESC");
        $teamUsersStmt->execute();
        $teamUsers = $teamUsersStmt->fetchAll(PDO::FETCH_ASSOC);
        
        // 格式化团队用户列表
        $formattedTeamUsers = [];
        foreach ($teamUsers as $user) {
            $formattedTeamUsers[] = [
                'user_id' => intval($user['user_id']),
                'username' => $user['username'],
                'phone' => $user['phone'],
                'is_agent' => intval($user['is_agent']),
                'agent_level' => intval($user['agent_level']),
                'parent_id' => intval($user['parent_id']),
                'parent_username' => $user['parent_username'],
                'created_at' => $user['created_at']
            ];
        }
        
        $result['team_users'] = $formattedTeamUsers;
    } catch (PDOException $e) {
        // 团队用户列表查询失败不影响主查询结果
        error_log('Admin端团队用户列表查询 Error: ' . $e->getMessage());
        $result['team_users'] = [];
    }
    
    Response::success($result, '团队收益统计列表查询成功');
    
} catch (PDOException $e) {
    // 输出错误信息到日志文件
    error_log('Admin端团队收益统计列表API Error: ' . $e->getMessage());
    // 返回错误信息
    Response::error('查询失败: ' . $e->getMessage(), $errorCodes['SERVER_ERROR'], 500);
}
