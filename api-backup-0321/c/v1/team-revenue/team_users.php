<?php
/**
 * Admin端团队用户列表接口
 * 
 * GET /api/admin/team-revenue/team-users
 * 
 * 请求头：
 * X-Token: <token> (Admin端)
 * 
 * 请求参数：
 * - page: 页码，默认1
 * - limit: 每页条数，默认20
 * - user_id: 用户ID
 * - username: 用户名（精确匹配）
 * - phone: 手机号
 * - is_agent: 代理等级（0=普通用户，1=普通团长，2=高级团长，3=大团团长）
 * - agent_level: 代理层级（1=一级代理，2=二级代理）
 * - parent_id: 上级代理ID
 * - start_date: 注册开始日期 YYYY-MM-DD
 * - end_date: 注册结束日期 YYYY-MM-DD
 * - days: 按天数筛选（例如：7=最近7天）
 * - sort_field: 排序字段（user_id, username, created_at, is_agent）
 * - sort_order: 排序方式（asc, desc）
 * 
 * 返回结果：
 * {
 *   "code": 0,
 *   "message": "团队用户列表查询成功",
 *   "data": {
 *     "total": 50,
 *     "per_page": 20,
 *     "current_page": 1,
 *     "last_page": 3,
 *     "statistics": {
 *       "total_users": 50,
 *       "agent_users": 30,
 *       "non_agent_users": 20,
 *       "level1_agents": 15,
 *       "level2_agents": 15
 *     },
 *     "list": [
 *       {
 *         "id": 101,
 *         "user_id": 101,
 *         "username": "user101",
 *         "phone": "13800138001",
 *         "is_agent": 2,
 *         "is_agent_text": "高级团长",
 *         "agent_level": 1,
 *         "created_at": "2026-03-17 10:00:00",
 *         "superiors": {
 *           "direct": {
 *             "id": 100,
 *             "user_id": 100,
 *             "username": "user100"
 *           },
 *           "indirect": null
 *         },
 *         "subordinates": {
 *           "direct": [
 *             {
 *               "id": 102,
 *               "user_id": 102,
 *               "username": "user102"
 *             }
 *           ],
 *           "indirect": [
 *             {
 *               "id": 103,
 *               "user_id": 103,
 *               "username": "user103"
 *             }
 *           ]
 *         },
 *         "subordinate_counts": {
 *           "direct": 1,
 *           "indirect": 1,
 *           "total": 2
 *         }
 *       }
 *     ]
 *   },
 *   "timestamp": 1773722166
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
$userId = intval($_GET['user_id'] ?? 0);
$username = trim($_GET['username'] ?? '');
$phone = trim($_GET['phone'] ?? '');
$isAgent = intval($_GET['is_agent'] ?? 0);
$agentLevel = intval($_GET['agent_level'] ?? 0);
$parentId = intval($_GET['parent_id'] ?? 0);
$startDate = trim($_GET['start_date'] ?? '');
$endDate = trim($_GET['end_date'] ?? '');
$days = intval($_GET['days'] ?? 0); // 按天数筛选
$sortField = trim($_GET['sort_field'] ?? 'created_at');
$sortOrder = strtolower(trim($_GET['sort_order'] ?? 'desc'));

// 如果提供了days参数，自动计算时间范围
if ($days > 0) {
    $endDate = date('Y-m-d');
    $startDate = date('Y-m-d', strtotime("-{$days} days"));
}

// 验证排序参数
$validSortFields = ['user_id', 'username', 'created_at', 'is_agent'];
if (!in_array($sortField, $validSortFields)) {
    $sortField = 'created_at';
}

if (!in_array($sortOrder, ['asc', 'desc'])) {
    $sortOrder = 'desc';
}

// 映射排序字段到实际数据库字段
$sortFieldMap = [
    'user_id' => 'id',
    'username' => 'username',
    'created_at' => 'created_at',
    'is_agent' => 'is_agent'
];
$actualSortField = $sortFieldMap[$sortField] ?? 'created_at';

// 计算分页偏移量
$offset = ($page - 1) * $limit;

try {
    // 构建查询条件
    $whereConditions = [];
    $params = [];
    
    // 强制筛选当前用户数据
    // 只返回当前用户自己的数据
    $whereConditions[] = 'u.id = ?';
    $params[] = $currentUserId;
    
    if (!empty($username)) {
        $whereConditions[] = 'u.username = ?';
        $params[] = $username;
    }
    
    if (!empty($phone)) {
        $whereConditions[] = 'u.phone = ?';
        $params[] = $phone;
    }
    
    if ($isAgent > 0) {
        $whereConditions[] = 'u.is_agent = ?';
        $params[] = $isAgent;
    }
    
    if (!empty($startDate)) {
        $whereConditions[] = 'DATE(u.created_at) >= ?';
        $params[] = $startDate;
    }
    
    if (!empty($endDate)) {
        $whereConditions[] = 'DATE(u.created_at) <= ?';
        $params[] = $endDate;
    }
    
    // 处理代理层级和上级代理ID的条件
    if ($agentLevel > 0 && in_array($agentLevel, [1, 2])) {
        $whereConditions[] = 'r.level = ?';
        $params[] = $agentLevel;
    }
    
    if ($parentId > 0) {
        $whereConditions[] = 'r.agent_id = ?';
        $params[] = $parentId;
    }
    
    $whereClause = !empty($whereConditions) ? 'WHERE ' . implode(' AND ', $whereConditions) : '';
    
    // 查询总数（去重）
    $countStmt = $db->prepare("SELECT COUNT(DISTINCT u.id) as total FROM c_users u LEFT JOIN c_user_relations r ON u.id = r.user_id {$whereClause}");
    $countStmt->execute($params);
    $total = $countStmt->fetchColumn();
    
    // 计算总页数
    $lastPage = ceil($total / $limit);
    
    // 查询用户列表（主查询c_users表，左连接c_user_relations表）
    $listStmt = $db->prepare("SELECT DISTINCT
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
    {$whereClause}
    ORDER BY u.{$actualSortField} {$sortOrder}
    LIMIT ? OFFSET ?");
    
    $listParams = array_merge($params, [$limit, $offset]);
    $listStmt->execute($listParams);
    $users = $listStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 统计数据 - 基于当前用户
    $statistics = [
        'total_users' => 1, // 始终为1，因为只返回当前用户
        'total_superiors' => 0,
        'total_subordinates' => 0,
        'direct_superiors' => 0,
        'indirect_superiors' => 0,
        'direct_subordinates' => 0,
        'indirect_subordinates' => 0,
        'normal_users' => 0, // 普通用户数量
        'normal_captains' => 0, // 普通团长数量
        'senior_captains' => 0, // 高级团长数量
        'large_captains' => 0 // 大团团长数量
    ];
    
    // 查询当前用户的代理等级，用于统计
    $stmt = $db->prepare("SELECT is_agent FROM c_users WHERE id = ?");
    $stmt->execute([$currentUserId]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user) {
        $isAgent = intval($user['is_agent']);
        switch ($isAgent) {
            case 0:
                $statistics['normal_users'] = 1;
                break;
            case 1:
                $statistics['normal_captains'] = 1;
                break;
            case 2:
                $statistics['senior_captains'] = 1;
                break;
            case 3:
                $statistics['large_captains'] = 1;
                break;
        }
    }
    
    // 查询当前用户的上级和下级统计
    // 查询直接上级数量
    $stmt = $db->prepare("SELECT COUNT(*) as count FROM c_user_relations WHERE user_id = ? AND level = 1");
    $stmt->execute([$currentUserId]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    $statistics['direct_superiors'] = intval($result['count']);
    
    // 查询间接上级数量
    $stmt = $db->prepare("SELECT COUNT(*) as count FROM c_user_relations WHERE user_id = ? AND level = 2");
    $stmt->execute([$currentUserId]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    $statistics['indirect_superiors'] = intval($result['count']);
    
    // 查询直接下级数量
    $stmt = $db->prepare("SELECT COUNT(*) as count FROM c_user_relations WHERE agent_id = ? AND level = 1");
    $stmt->execute([$currentUserId]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    $statistics['direct_subordinates'] = intval($result['count']);
    
    // 查询间接下级数量
    $stmt = $db->prepare("SELECT COUNT(*) as count FROM c_user_relations WHERE agent_id = ? AND level = 2");
    $stmt->execute([$currentUserId]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    $statistics['indirect_subordinates'] = intval($result['count']);
    
    // 计算总上级和总下级
    $statistics['total_superiors'] = $statistics['direct_superiors'] + $statistics['indirect_superiors'];
    $statistics['total_subordinates'] = $statistics['direct_subordinates'] + $statistics['indirect_subordinates'];
    
    // 格式化结果 - 为每个用户计算上级和下级信息（去重）
    $formattedList = [];
    $processedUserIds = [];
    
    foreach ($users as $userItem) {
        $userId = intval($userItem['user_id']);
        
        // 跳过重复用户
        if (in_array($userId, $processedUserIds)) {
            continue;
        }
        
        $processedUserIds[] = $userId;
        $userIsAgent = intval($userItem['is_agent']);
        
        // 构建用户基本信息
        $formattedItem = [
            'user_id' => $userId,
            'username' => $userItem['username'],
            'phone' => $userItem['phone'],
            'is_agent' => $userIsAgent,
            'is_agent_text' => $userIsAgent == 0 ? '普通用户' : ($userIsAgent == 1 ? '普通团长' : ($userIsAgent == 2 ? '高级团长' : '大团团长')),
            'agent_level' => intval($userItem['agent_level']),
            'created_at' => $userItem['created_at']
        ];
        
        // 获取上级代理信息
        $directParent = null;
        $indirectParent = null;
        
        // 查询直接上级（一级代理）
        $stmt = $db->prepare("SELECT id, username, is_agent FROM c_users WHERE id = (SELECT agent_id FROM c_user_relations WHERE user_id = ? AND level = 1 LIMIT 1)");
        $stmt->execute([$userId]);
        if ($parent = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $parentIsAgent = intval($parent['is_agent']);
            $directParent = [
                'user_id' => intval($parent['id']),
                'username' => $parent['username'],
                'is_agent' => $parentIsAgent,
                'is_agent_text' => $parentIsAgent == 0 ? '普通用户' : ($parentIsAgent == 1 ? '普通团长' : ($parentIsAgent == 2 ? '高级团长' : '大团团长')),
                'agent_level_text' => '一级代理'
            ];
        }
        
        // 查询间接上级（二级代理）
        $stmt = $db->prepare("SELECT id, username, is_agent FROM c_users WHERE id = (SELECT agent_id FROM c_user_relations WHERE user_id = ? AND level = 2 LIMIT 1)");
        $stmt->execute([$userId]);
        if ($parent = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $parentIsAgent = intval($parent['is_agent']);
            $indirectParent = [
                'user_id' => intval($parent['id']),
                'username' => $parent['username'],
                'is_agent' => $parentIsAgent,
                'is_agent_text' => $parentIsAgent == 0 ? '普通用户' : ($parentIsAgent == 1 ? '普通团长' : ($parentIsAgent == 2 ? '高级团长' : '大团团长')),
                'agent_level_text' => '二级代理'
            ];
        }
        
        $formattedItem['superiors'] = [
            'direct' => $directParent,
            'indirect' => $indirectParent
        ];
        
        // 获取下级邀请人信息
        $directChildren = [];
        $indirectChildren = [];
        
        // 查询直接下级（一级代理）
        $stmt = $db->prepare("SELECT u.id, u.username, u.is_agent, r.level FROM c_users u JOIN c_user_relations r ON u.id = r.user_id WHERE r.agent_id = ? AND r.level = 1");
        $stmt->execute([$userId]);
        while ($child = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $childIsAgent = intval($child['is_agent']);
            $directChildren[] = [
                'user_id' => intval($child['id']),
                'username' => $child['username'],
                'is_agent' => $childIsAgent,
                'is_agent_text' => $childIsAgent == 0 ? '普通用户' : ($childIsAgent == 1 ? '普通团长' : ($childIsAgent == 2 ? '高级团长' : '大团团长')),
                'agent_level' => intval($child['level']),
                'agent_level_text' => '一级邀请'
            ];
        }
        
        // 查询间接下级（二级代理）
        $stmt = $db->prepare("SELECT u.id, u.username, u.is_agent, r.level FROM c_users u JOIN c_user_relations r ON u.id = r.user_id WHERE r.agent_id = ? AND r.level = 2");
        $stmt->execute([$userId]);
        while ($child = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $childIsAgent = intval($child['is_agent']);
            $indirectChildren[] = [
                'user_id' => intval($child['id']),
                'username' => $child['username'],
                'is_agent' => $childIsAgent,
                'is_agent_text' => $childIsAgent == 0 ? '普通用户' : ($childIsAgent == 1 ? '普通团长' : ($childIsAgent == 2 ? '高级团长' : '大团团长')),
                'agent_level' => intval($child['level']),
                'agent_level_text' => '二级邀请'
            ];
        }
        
        $formattedItem['subordinates'] = [
            'direct' => $directChildren,
            'indirect' => $indirectChildren
        ];
        
        $formattedList[] = $formattedItem;
    }
    
    // 构建返回结果
    $responseData = [
        'total' => intval($total),
        'per_page' => $limit,
        'current_page' => $page,
        'last_page' => $lastPage,
        'statistics' => $statistics,
        'list' => $formattedList
    ];
    
    Response::success($responseData, '团队用户列表查询成功');
    
} catch (PDOException $e) {
    // 输出错误信息到日志文件
    error_log('Admin端团队用户列表API Error: ' . $e->getMessage());
    // 返回错误信息
    Response::error('查询失败: ' . $e->getMessage(), $errorCodes['DATABASE_ERROR'], 500);
}
