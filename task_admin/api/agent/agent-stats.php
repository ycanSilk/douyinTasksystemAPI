<?php
/**
 * 团长数据统计接口
 * GET /task_admin/api/agent/agent-stats.php
 * 
 * 参数：
 * - user_id: C端用户ID
 * 
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "ok",
 *   "data": {
 *     "total_invites": 10,
 *     "valid_invites": 5,
 *     "senior_valid_invites": 3,
 *     "total_tasks_completed": 150,
 *     "total_commission_earned": "120.00",
 *     "agent_require": {
 *       "required_active_users": 5,
 *       "task_count": 5,
 *       "hours": 24
 *     },
 *     "senior_agent_require": {
 *       "required_active_users": 30,
 *       "task_count": 10,
 *       "hours": 48
 *     },
 *     "upgraded_agent": true,
 *     "upgraded_senior_agent": false
 *   },
 *   "timestamp": 1736582400
 * }
 * 
 * 说明：
 * - total_invites: 总邀请人数
 * - valid_invites: 普通团长有效邀请人数
 * - senior_valid_invites: 高级团长有效邀请人数
 * - total_tasks_completed: 下线完成的任务总数
 * - total_commission_earned: 作为团长获得的佣金总额
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';
require_once __DIR__ . '/../../../core/AppConfig.php';

// 认证中间件
AdminAuthMiddleware::authenticate();

// 初始化数据库连接
$db = Database::connect();

try {
    // 获取请求参数
    $userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 0;
    
    if ($userId <= 0) {
        echo json_encode([
            'code' => 400,
            'message' => '用户ID不能为空',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 1. 查询总邀请人数
    $stmt = $db->prepare("
        SELECT COUNT(*) as total
        FROM c_users
        WHERE parent_id = ?
    ");
    $stmt->execute([$userId]);
    $totalInvites = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 2. 读取普通团长有效邀请配置
    $agentTaskCount = AppConfig::get('agent_active_user_task_count', 5);
    $agentHours = AppConfig::get('agent_active_user_hours', 24);
    $agentRequiredUsers = AppConfig::get('agent_required_active_users', 5);

    // 3. 读取高级团长有效邀请配置
    $seniorTaskCount = AppConfig::get('senior_agent_active_user_task_count', 10);
    $seniorHours = AppConfig::get('senior_agent_active_user_hours', 48);
    $seniorRequiredUsers = AppConfig::get('senior_agent_required_active_users', 30);

    // 4. 查询普通团长有效邀请人数（注册后N小时内完成M个任务）
    $stmt = $db->prepare("
        SELECT COUNT(DISTINCT u.id) as active_count
        FROM c_users u
        INNER JOIN c_task_records r ON r.c_user_id = u.id
        WHERE u.parent_id = ?
          AND r.status = 3
          AND r.reviewed_at <= DATE_ADD(u.created_at, INTERVAL ? HOUR)
        GROUP BY u.id
        HAVING COUNT(r.id) >= ?
    ");
    $stmt->execute([$userId, $agentHours, $agentTaskCount]);
    $validInvites = count($stmt->fetchAll(PDO::FETCH_ASSOC));

    // 5. 查询高级团长有效邀请人数
    $stmt = $db->prepare("
        SELECT COUNT(DISTINCT u.id) as active_count
        FROM c_users u
        INNER JOIN c_task_records r ON r.c_user_id = u.id
        WHERE u.parent_id = ?
          AND r.status = 3
          AND r.reviewed_at <= DATE_ADD(u.created_at, INTERVAL ? HOUR)
        GROUP BY u.id
        HAVING COUNT(r.id) >= ?
    ");
    $stmt->execute([$userId, $seniorHours, $seniorTaskCount]);
    $seniorValidInvites = count($stmt->fetchAll(PDO::FETCH_ASSOC));

    // 6. 查询下线完成的任务总数
    $stmt = $db->prepare("
        SELECT COUNT(*) as total
        FROM c_task_records c
        INNER JOIN c_users u ON c.c_user_id = u.id
        WHERE u.parent_id = ? AND c.status = 3
    ");
    $stmt->execute([$userId]);
    $totalTasksCompleted = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 7. 查询作为团长获得的佣金总额
    $stmt = $db->prepare("
        SELECT COALESCE(SUM(amount), 0) as total_commission
        FROM wallets_log
        WHERE user_id = ? AND user_type = 1 AND related_type = 'agent_commission'
    ");
    $stmt->execute([$userId]);
    $totalCommission = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total_commission'];
    
    // 判断是否满足团长和高级团长条件
    $upgradedAgent = $validInvites >= $agentRequiredUsers;
    $upgradedSeniorAgent = $seniorValidInvites >= $seniorRequiredUsers;
    
    // 返回成功响应
    echo json_encode([
        'code' => 0,
        'message' => 'ok',
        'data' => [
            'total_invites' => $totalInvites,
            'valid_invites' => $validInvites,
            'senior_valid_invites' => $seniorValidInvites,
            'total_tasks_completed' => $totalTasksCompleted,
            'total_commission_earned' => number_format($totalCommission / 100, 2),
            'agent_require' => [
                'required_active_users' => $agentRequiredUsers,
                'task_count' => $agentTaskCount,
                'hours' => $agentHours
            ],
            'senior_agent_require' => [
                'required_active_users' => $seniorRequiredUsers,
                'task_count' => $seniorTaskCount,
                'hours' => $seniorHours
            ],
            'upgraded_agent' => $upgradedAgent,
            'upgraded_senior_agent' => $upgradedSeniorAgent
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    // 错误处理
    echo json_encode([
        'code' => 500,
        'message' => '查询失败: ' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
?>