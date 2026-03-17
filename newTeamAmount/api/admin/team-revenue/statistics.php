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
require_once __DIR__ . '/../../../../core/Token.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

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
$keyword = trim($_GET['keyword'] ?? '');
$isAgent = intval($_GET['is_agent'] ?? 0);
$minRevenue = floatval($_GET['min_revenue'] ?? 0);
$sortField = trim($_GET['sort_field'] ?? 'total_team_revenue');
$sortOrder = strtolower(trim($_GET['sort_order'] ?? 'desc'));

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
    
    if (!empty($keyword)) {
        $whereConditions[] = '(s.user_id = ? OR s.username LIKE ?)';
        $params[] = intval($keyword);
        $params[] = '%' . $keyword . '%';
    }
    
    if ($isAgent > 0) {
        $whereConditions[] = 'u.is_agent = ?';
        $params[] = $isAgent;
    }
    
    if ($minRevenue > 0) {
        $whereConditions[] = 's.total_team_revenue >= ?';
        $params[] = $minRevenue;
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
    
    // 构建返回结果
    $result = [
        'total' => intval($total),
        'list' => $formattedList
    ];
    
    Response::success($result, '团队收益统计列表查询成功');
    
} catch (PDOException $e) {
    // 输出错误信息到日志文件
    error_log('Admin端团队收益统计列表API Error: ' . $e->getMessage());
    // 返回错误信息
    Response::error('查询失败: ' . $e->getMessage(), $errorCodes['SERVER_ERROR'], 500);
}
