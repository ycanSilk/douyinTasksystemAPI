<?php
/**
 * C端用户代理数据统计接口
 * 
 * GET /api/c/v1/agent/stats
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "ok",
 *   "data": {
 *     "total_invites": 10,
 *     "valid_invites": 5,
 *     "total_tasks_completed": 150,
 *     "total_commission_earned": "120.00"
 *   },
 *   "timestamp": 1736582400
 * }
 * 
 * 说明：
 * - total_invites: 总邀请人数
 * - valid_invites: 有效邀请人数（做满20单的人数）
 * - total_tasks_completed: 下线完成的任务总数
 * - total_commission_earned: 作为团长获得的佣金总额
 */

header('Content-Type: application/json; charset=utf-8');

// 只允许 GET 请求
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';
require_once __DIR__ . '/../../../../core/AppConfig.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

try {
    // 1. 查询总邀请人数
    $stmt = $db->prepare("
        SELECT COUNT(*) as total
        FROM c_users
        WHERE parent_id = ?
    ");
    $stmt->execute([$currentUser['user_id']]);
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
    $stmt->execute([$currentUser['user_id'], $agentHours, $agentTaskCount]);
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
    $stmt->execute([$currentUser['user_id'], $seniorHours, $seniorTaskCount]);
    $seniorValidInvites = count($stmt->fetchAll(PDO::FETCH_ASSOC));

    // 6. 查询下线完成的任务总数
    $stmt = $db->prepare("
        SELECT COUNT(*) as total
        FROM c_task_records c
        INNER JOIN c_users u ON c.c_user_id = u.id
        WHERE u.parent_id = ? AND c.status = 3
    ");
    $stmt->execute([$currentUser['user_id']]);
    $totalTasksCompleted = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 4. 查询作为团长获得的佣金总额
    $stmt = $db->prepare("
        SELECT COALESCE(SUM(amount), 0) as total_commission
        FROM wallets_log
        WHERE user_id = ? AND user_type = 1 AND related_type = 'agent_commission'
    ");
    $stmt->execute([$currentUser['user_id']]);
    $totalCommission = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total_commission'];
    
    // 返回成功响应
    Response::success([
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
        ]
    ]);
    
} catch (PDOException $e) {
    Response::error('查询失败', $errorCodes['DATABASE_ERROR'], 500);
}
