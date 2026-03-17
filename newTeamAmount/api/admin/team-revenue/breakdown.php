<?php
/**
 * Admin端指定用户的团队收益明细接口
 * 
 * GET /api/admin/team-revenue/breakdown/{user_id}
 * 
 * 请求头：
 * X-Token: <token> (Admin端)
 * 
 * 请求参数：
 * - page: 页码，默认1
 * - limit: 每页条数，默认20
 * - agent_level: 代理层级：1=一级下线贡献，2=二级下线贡献
 * - revenue_source: 收益来源：1=任务，2=订单
 * - downline_user_id: 按具体下线筛选
 * - start_date: 开始日期 YYYY-MM-DD
 * - end_date: 结束日期 YYYY-MM-DD
 * 
 * 返回结果：
 * {
 *   "code": 200,
 *   "message": "success",
 *   "data": {
 *     "total": 156,
 *     "per_page": 20,
 *     "current_page": 1,
 *     "last_page": 8,
 *     "list": [
 *       {
 *         "id": 1,
 *         "agent_level": 1,
 *         "agent_level_text": "一级下线",
 *         "downline_user": {
 *           "id": 1005,
 *           "username": "xiaoming",
 *           "relation": "直接邀请"
 *         },
 *         "revenue": {
 *           "amount": "25.00",
 *           "source": 1,
 *           "source_text": "任务收益"
 *         },
 *         "downline_amount": "25.00",
 *         "task_info": {
 *           "type": 3,
 *           "type_text": "评论任务",
 *           "stage": 2,
 *           "stage_text": "已完成"
 *         },
 *         "related_id": "TASK20240120001",
 *         "created_at": "2024-01-20 10:15:22",
 *         "before_amount": "100.00",
 *         "after_amount": "125.00"
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

// 获取用户ID参数
$path = $_SERVER['REQUEST_URI'];
$parts = explode('/', $path);
$userId = intval(end($parts));

if ($userId <= 0) {
    Response::error('用户ID参数错误', 400);
}

// 获取请求参数
$page = intval($_GET['page'] ?? 1);
$limit = intval($_GET['limit'] ?? 20);
$agentLevel = intval($_GET['agent_level'] ?? 0);
$revenueSource = intval($_GET['revenue_source'] ?? 0);
$downlineUserId = intval($_GET['downline_user_id'] ?? 0);
$startDate = trim($_GET['start_date'] ?? '');
$endDate = trim($_GET['end_date'] ?? '');

// 计算分页偏移量
$offset = ($page - 1) * $limit;

try {
    // 构建查询条件
    $whereConditions = ['agent_id = ?'];
    $params = [$userId];
    
    if ($agentLevel > 0 && in_array($agentLevel, [1, 2])) {
        $whereConditions[] = 'agent_level = ?';
        $params[] = $agentLevel;
    }
    
    if ($revenueSource > 0 && in_array($revenueSource, [1, 2])) {
        $whereConditions[] = 'revenue_source = ?';
        $params[] = $revenueSource;
    }
    
    if ($downlineUserId > 0) {
        $whereConditions[] = 'downline_user_id = ?';
        $params[] = $downlineUserId;
    }
    
    if (!empty($startDate)) {
        $whereConditions[] = 'DATE(created_at) >= ?';
        $params[] = $startDate;
    }
    
    if (!empty($endDate)) {
        $whereConditions[] = 'DATE(created_at) <= ?';
        $params[] = $endDate;
    }
    
    $whereClause = implode(' AND ', $whereConditions);
    
    // 查询总数
    $countStmt = $db->prepare("SELECT COUNT(*) as total FROM team_revenue_statistics_breakdown WHERE {$whereClause}");
    $countStmt->execute($params);
    $total = $countStmt->fetchColumn();
    
    // 计算总页数
    $lastPage = ceil($total / $limit);
    
    // 查询明细数据
    $listStmt = $db->prepare("SELECT
        id,
        agent_level,
        downline_user_id,
        downline_username,
        team_revenue_amount,
        downline_user_amount,
        revenue_source,
        revenue_source_text,
        task_type,
        task_type_text,
        task_stage,
        task_stage_text,
        order_type,
        order_type_text,
        related_id,
        agent_before_amount,
        agent_after_amount,
        created_at
    FROM team_revenue_statistics_breakdown
    WHERE {$whereClause}
    ORDER BY created_at DESC
    LIMIT ? OFFSET ?");
    
    $listParams = array_merge($params, [$limit, $offset]);
    $listStmt->execute($listParams);
    $list = $listStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 格式化结果
    $formattedList = [];
    foreach ($list as $item) {
        $formattedItem = [
            'id' => intval($item['id']),
            'agent_level' => intval($item['agent_level']),
            'agent_level_text' => $item['agent_level'] == 1 ? '一级下线' : '二级下线',
            'downline_user' => [
                'id' => intval($item['downline_user_id']),
                'username' => $item['downline_username'],
                'relation' => $item['agent_level'] == 1 ? '直接邀请' : '间接邀请'
            ],
            'revenue' => [
                'amount' => $item['team_revenue_amount'],
                'source' => intval($item['revenue_source']),
                'source_text' => $item['revenue_source_text']
            ],
            'downline_amount' => $item['downline_user_amount'],
            'related_id' => $item['related_id'],
            'created_at' => $item['created_at'],
            'before_amount' => $item['agent_before_amount'],
            'after_amount' => $item['agent_after_amount']
        ];
        
        // 添加任务信息或订单信息
        if ($item['revenue_source'] == 1) {
            $formattedItem['task_info'] = [
                'type' => intval($item['task_type'] ?? 0),
                'type_text' => $item['task_type_text'] ?? '',
                'stage' => intval($item['task_stage'] ?? 0),
                'stage_text' => $item['task_stage_text'] ?? ''
            ];
        } else {
            $formattedItem['order_info'] = [
                'type' => intval($item['order_type'] ?? 0),
                'type_text' => $item['order_type_text'] ?? ''
            ];
        }
        
        $formattedList[] = $formattedItem;
    }
    
    // 构建返回结果
    $result = [
        'total' => intval($total),
        'per_page' => $limit,
        'current_page' => $page,
        'last_page' => $lastPage,
        'list' => $formattedList
    ];
    
    Response::success($result, '团队收益明细查询成功');
    
} catch (PDOException $e) {
    // 输出错误信息到日志文件
    error_log('Admin端团队收益明细API Error: ' . $e->getMessage());
    // 返回错误信息
    Response::error('查询失败: ' . $e->getMessage(), $errorCodes['SERVER_ERROR'], 500);
}
