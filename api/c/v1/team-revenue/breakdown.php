<?php
/**
 * C端团队收益明细接口
 * 
 * GET /api/c/v1/team-revenue/breakdown
 * 
 * 请求头：
 * X-Token: <token> (C端用户)
 * 
 * 请求参数：
 * - page: 页码，默认1
 * - limit: 每页条数，默认20
 * - user_id: 用户ID筛选（不传：获取所有邀请用户记录；0：获取自己的记录；其他ID：获取指定用户的记录）
 * 
 * 返回结果：
 * {
 *   "code": 0,
 *   "message": "团队收益明细查询成功",
 *   "data": {
 *     "total": 156,      // 符合条件的记录总数
 *     "per_page": 20,    // 每页条数
 *     "current_page": 1, // 当前页码
 *     "last_page": 8,    // 总页数
 *     "list": [
 *       {
 *         "id": 1,                 // 记录ID
 *         "user_id": 144,          // 用户ID
 *         "username": "qqq7",      // 用户名
 *         "invite_level": 1,       // 邀请层级
 *         "amount": "5.00",        // 收益金额
 *         "before_balance": "0.00", // 变动前余额
 *         "after_balance": "5.00",  // 变动后余额
 *         "related_type": "任务佣金", // 关联类型
 *         "related_id": "25",      // 关联ID
 *         "task_types": 1,         // 任务类型
 *         "task_types_text": "上评评论", // 任务类型文本
 *         "record_status": 3,      // 记录状态
 *         "record_status_text": "已完成", // 记录状态文本
 *         "remark": "完成任务获得佣金", // 备注
 *         "created_at": "2026-04-01 10:15:22" // 创建时间
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

LoggerRouter::setContext('c/v1/team-revenue/breakdown');

$requestLogger = LoggerFactory::getLogger('request');
$auditLogger = LoggerFactory::getLogger('audit');
$errorLogger = LoggerFactory::getLogger('error');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);

    $auditLogger->warning('C端用户获取团队收益明细失败：请求方法错误', [
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
    'SERVER_ERROR' => 5000
];

// 数据库连接
$db = Database::connect();

$requestLogger->info('=== C端团队收益明细接口调用开始 ===', [
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
    
    $auditLogger->warning('C端用户获取团队收益明细失败：Token认证失败', [
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
$page = intval($_GET['page'] ?? 1);
$limit = intval($_GET['limit'] ?? 20);
$filterUserId = intval($_GET['user_id'] ?? null);

try {
    // ========== 1. 查询用户列表 ==========
    $userIds = [];
    $userLevelMap = [];
    
    // user_id 不传：获取所有邀请用户的记录
    // user_id = 0：获取自己的记录
    // user_id = 其他ID：获取指定用户的记录
    if ($filterUserId === null) {
        // user_id不传，获取所有邀请用户列表
        $sql = "
            SELECT 
                u.id as user_id,
                u.username,
                r.level as invite_level
            FROM c_user_relations r
            JOIN c_users u ON r.user_id = u.id
            WHERE r.agent_id = ? AND r.level IN (1, 2)
        ";
        $params = [$currentUserId];
        
        $sql .= " ORDER BY r.level ASC, u.id ASC";
        
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        $inviteUsers = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $requestLogger->info('获取邀请用户列表成功', [
            'user_id' => $currentUserId,
            'invite_count' => count($inviteUsers)
        ]);
        
        foreach ($inviteUsers as $user) {
            $userIds[] = $user['user_id'];
            $userLevelMap[$user['user_id']] = [
                'username' => $user['username'],
                'invite_level' => $user['invite_level']
            ];
        }
    } else {
        // user_id有值
        if ($filterUserId === 0) {
            // user_id=0，获取自己的记录
            $selfStmt = $db->prepare("SELECT id, username FROM c_users WHERE id = ?");
            $selfStmt->execute([$currentUserId]);
            $selfUser = $selfStmt->fetch(PDO::FETCH_ASSOC);
            
            if ($selfUser) {
                $userIds[] = $selfUser['id'];
                $userLevelMap[$selfUser['id']] = [
                    'username' => $selfUser['username'],
                    'invite_level' => 0
                ];
            }
            
            $requestLogger->info('查询当前用户自己的记录', [
                'user_id' => $currentUserId,
                'self_query' => true
            ]);
        } else {
            // user_id=其他ID，获取指定用户的记录
            // 先检查是否是自己的下级
            $checkSql = "
                SELECT level 
                FROM c_user_relations 
                WHERE user_id = ? AND agent_id = ? AND level IN (1, 2)
            ";
            $checkStmt = $db->prepare($checkSql);
            $checkStmt->execute([$filterUserId, $currentUserId]);
            $relation = $checkStmt->fetch(PDO::FETCH_ASSOC);
            
            if ($relation) {
                // 是下级用户，获取该用户信息
                $userStmt = $db->prepare("SELECT id, username FROM c_users WHERE id = ?");
                $userStmt->execute([$filterUserId]);
                $targetUser = $userStmt->fetch(PDO::FETCH_ASSOC);
                
                if ($targetUser) {
                    $userIds[] = $targetUser['id'];
                    $userLevelMap[$targetUser['id']] = [
                        'username' => $targetUser['username'],
                        'invite_level' => $relation['level']
                    ];
                }
                
                $requestLogger->info('查询指定下级用户的记录', [
                    'user_id' => $currentUserId,
                    'target_user_id' => $filterUserId,
                    'invite_level' => $relation['level']
                ]);
            } else {
                // 不是下级用户，检查是否是自己
                if ($filterUserId == $currentUserId) {
                    $selfStmt = $db->prepare("SELECT id, username FROM c_users WHERE id = ?");
                    $selfStmt->execute([$currentUserId]);
                    $selfUser = $selfStmt->fetch(PDO::FETCH_ASSOC);
                    
                    if ($selfUser) {
                        $userIds[] = $selfUser['id'];
                        $userLevelMap[$selfUser['id']] = [
                            'username' => $selfUser['username'],
                            'invite_level' => 0
                        ];
                    }
                    
                    $requestLogger->info('查询当前用户自己的记录（通过指定ID）', [
                        'user_id' => $currentUserId,
                        'target_user_id' => $filterUserId
                    ]);
                } else {
                    // 既不是下级也不是自己，返回空结果
                    $requestLogger->info('查询非下级用户记录，返回空', [
                        'user_id' => $currentUserId,
                        'target_user_id' => $filterUserId,
                        'is_not_subordinate_or_self' => true
                    ]);
                }
            }
        }
    }
    
    // 如果没有用户，直接返回空结果
    if (empty($userIds)) {
        $result = [
            'total' => 0,
            'per_page' => $limit,
            'current_page' => $page,
            'last_page' => 0,
            'list' => []
        ];
        
        Response::success($result, '团队收益明细查询成功');
        exit;
    }
    
    // ========== 2. 查询c_task_statistics获取收益明细 ==========
    $placeholders = implode(',', array_fill(0, count($userIds), '?'));
    
    // 查询总数
    $countSql = "
        SELECT COUNT(*) as total 
        FROM c_task_statistics 
        WHERE c_user_id IN ($placeholders) 
          AND flow_type = 1
    ";
    $countStmt = $db->prepare($countSql);
    $countStmt->execute($userIds);
    $total = $countStmt->fetchColumn();
    
    // 计算分页
    $lastPage = ceil($total / $limit);
    $offset = ($page - 1) * $limit;
    
    // 查询明细数据
    $listSql = "
        SELECT 
            id,
            c_user_id,
            username,
            flow_type,
            amount,
            before_balance,
            after_balance,
            related_type,
            related_id,
            task_types,
            task_types_text,
            record_status,
            record_status_text,
            remark,
            created_at
        FROM c_task_statistics
        WHERE c_user_id IN ($placeholders) 
          AND flow_type = 1
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
    ";
    $listStmt = $db->prepare($listSql);
    $listParams = array_merge($userIds, [$limit, $offset]);
    $listStmt->execute($listParams);
    $list = $listStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 格式化结果
    $formattedList = [];
    foreach ($list as $item) {
        $userId = $item['c_user_id'];
        $userInfo = $userLevelMap[$userId] ?? ['username' => $item['username'], 'invite_level' => 0];
        
        $formattedList[] = [
            'id' => intval($item['id']),
            'user_id' => intval($userId),
            'username' => $userInfo['username'],
            'invite_level' => intval($userInfo['invite_level']),
            'amount' => number_format(floatval($item['amount']) / 100, 2),
            'before_balance' => number_format(floatval($item['before_balance']) / 100, 2),
            'after_balance' => number_format(floatval($item['after_balance']) / 100, 2),
            'related_type' => $item['related_type'],
            'related_id' => $item['related_id'],
            'task_types' => $item['task_types'] ? intval($item['task_types']) : null,
            'task_types_text' => $item['task_types_text'],
            'record_status' => intval($item['record_status']),
            'record_status_text' => $item['record_status_text'],
            'remark' => $item['remark'],
            'created_at' => $item['created_at']
        ];
    }
    
    // ========== 3. 构建返回结果 ==========
    $result = [
        'total' => intval($total),
        'per_page' => $limit,
        'current_page' => $page,
        'last_page' => $lastPage,
        'list' => $formattedList
    ];
    
    $auditLogger->notice('C端用户获取团队收益明细成功', [
        'user_id' => $currentUserId,
        'total' => $total,
        'returned_count' => count($formattedList),
    ]);
    
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }
    
    $requestLogger->info('C端获取团队收益明细成功', [
        'user_id' => $currentUserId,
        'total' => $total,
        'returned_count' => count($formattedList),
    ]);
    
    Response::success($result, '团队收益明细查询成功');
    
} catch (PDOException $e) {
    $errorLogger->error('查询失败：数据库异常', [
        'message' => $e->getMessage(),
        'code' => $e->getCode(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    $auditLogger->error('C端用户获取团队收益明细失败：数据库异常', [
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

    $auditLogger->error('C端用户获取团队收益明细失败：系统异常', [
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
