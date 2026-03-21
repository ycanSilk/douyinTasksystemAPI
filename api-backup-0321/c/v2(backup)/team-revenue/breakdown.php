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
$agentLevel = intval($_GET['agent_level'] ?? 0);
$revenueSource = intval($_GET['revenue_source'] ?? 0);
$downlineUserId = intval($_GET['downline_user_id'] ?? 0);
$startDate = trim($_GET['start_date'] ?? '');
$endDate = trim($_GET['end_date'] ?? '');
$days = intval($_GET['days'] ?? 0); // 可选参数，按天数筛选

// 如果提供了days参数，自动计算时间范围
if ($days > 0) {
    $endDate = date('Y-m-d');
    $startDate = date('Y-m-d', strtotime("-{$days} days"));
}

// 计算分页偏移量
$offset = ($page - 1) * $limit;

try {
    // 构建查询条件
    $whereConditions = [];
    $params = [];
    
    // 强制筛选当前用户ID
    $whereConditions[] = 'agent_id = ?';
    $params[] = $currentUserId;
    
    // 按用户名称筛选
    if (!empty($username)) {
        $whereConditions[] = 'agent_username LIKE ?';
        $params[] = '%' . $username . '%';
    }
    
    // 按完成任务用户名筛选
    $downlineUsername = trim($_GET['downline_username'] ?? '');
    if (!empty($downlineUsername)) {
        $whereConditions[] = 'downline_username LIKE ?';
        $params[] = '%' . $downlineUsername . '%';
    }
    
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
    
    $whereClause = !empty($whereConditions) ? 'WHERE ' . implode(' AND ', $whereConditions) : '';
    
    // 查询总数
    $countStmt = $db->prepare("SELECT COUNT(*) as total FROM team_revenue_statistics_breakdown {$whereClause}");
    $countStmt->execute($params);
    $total = $countStmt->fetchColumn();
    
    // 计算总页数
    $lastPage = ceil($total / $limit);
    
    // 查询明细数据
    $listStmt = $db->prepare("SELECT
        id,
        agent_id,
        agent_username,
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
    {$whereClause}
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
            'agent_id' => intval($item['agent_id'] ?? 0),
            'agent_username' => $item['agent_username'] ?? '',
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
            'agent_before_amount' => $item['agent_before_amount'],
            'agent_after_amount' => $item['agent_after_amount'],
            'team_revenue_amount' => $item['team_revenue_amount'],
            'revenue_source_text' => $item['revenue_source_text'],
            'downline_username' => $item['downline_username']
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
