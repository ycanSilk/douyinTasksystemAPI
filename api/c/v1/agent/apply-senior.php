<?php
/**
 * C端用户申请成为高级团长接口
 *
 * POST /api/c/v1/agent/apply-senior
 *
 * 申请条件：
 * - 必须已经是普通团长（is_agent=1）
 * - 无待审核的高级团长申请
 * - 邀请的有效活跃用户数达标（默认30个）
 * - 高级团长总数未达上限（默认100个）
 *
 * 有效活跃用户定义：
 * - 注册后48小时内完成10个任务（均可配置）
 */

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['code' => 1001, 'message' => '请求方法错误', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';
require_once __DIR__ . '/../../../../core/AppConfig.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

$db = Database::connect();

$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

try {
    // 1. 查询用户信息
    $stmt = $db->prepare("SELECT id, username, invite_code, is_agent FROM c_users WHERE id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        Response::error('用户信息不存在', $errorCodes['USER_NOT_FOUND']);
    }

    // 2. 必须是普通团长才能申请高级团长
    if ((int)$user['is_agent'] === 0) {
        Response::error('您还不是团长，请先申请成为普通团长', $errorCodes['SENIOR_AGENT_NOT_AGENT']);
    }

    if ((int)$user['is_agent'] === 2) {
        Response::error('您已经是高级团长，无需重复申请', $errorCodes['SENIOR_AGENT_ALREADY']);
    }

    // 3. 检查是否有待审核的高级团长申请
    $stmt = $db->prepare("SELECT id FROM agent_applications WHERE c_user_id = ? AND apply_type = 2 AND status = 0 LIMIT 1");
    $stmt->execute([$currentUser['user_id']]);
    if ($stmt->fetch()) {
        Response::error('您已有待审核的高级团长申请，请耐心等待', $errorCodes['SENIOR_AGENT_APPLICATION_PENDING']);
    }

    // 4. 检查高级团长数量上限
    $maxCount = AppConfig::get('senior_agent_max_count', 100);
    $stmt = $db->prepare("SELECT COUNT(*) as cnt FROM c_users WHERE is_agent = 2");
    $stmt->execute();
    $currentCount = (int)$stmt->fetch(PDO::FETCH_ASSOC)['cnt'];

    if ($currentCount >= $maxCount) {
        Response::error("高级团长名额已满（上限{$maxCount}个）", $errorCodes['SENIOR_AGENT_LIMIT_REACHED']);
    }

    // 5. 读取配置
    $requiredActiveUsers = AppConfig::get('senior_agent_required_active_users', 30);
    $taskCount = AppConfig::get('senior_agent_active_user_task_count', 10);
    $hours = AppConfig::get('senior_agent_active_user_hours', 48);

    // 6. 统计有效活跃用户数
    // 有效活跃用户 = 被当前用户邀请的下线，注册后N小时内完成M个任务
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
    $stmt->execute([$currentUser['user_id'], $hours, $taskCount]);
    $activeUsers = (int)$stmt->rowCount();

    // 7. 检查是否满足条件
    if ($activeUsers < $requiredActiveUsers) {
        Response::error("有效活跃用户数不足，当前{$activeUsers}个，需要{$requiredActiveUsers}个", $errorCodes['SENIOR_AGENT_INSUFFICIENT_ACTIVE_USERS']);
    }

    // 8. 查询总邀请人数
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM c_users WHERE parent_id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $totalInvites = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];

    // 9. 创建申请记录
    $stmt = $db->prepare("
        INSERT INTO agent_applications (
            c_user_id, username, invite_code, apply_type, valid_invites, total_invites, status
        ) VALUES (?, ?, ?, 2, ?, ?, 0)
    ");
    $stmt->execute([
        $currentUser['user_id'],
        $user['username'],
        $user['invite_code'],
        $activeUsers,
        $totalInvites
    ]);

    $applicationId = $db->lastInsertId();

    Response::success([
        'application_id' => (int)$applicationId,
        'active_users' => $activeUsers,
        'required_active_users' => $requiredActiveUsers,
        'total_invites' => $totalInvites,
        'status' => 0,
        'status_text' => '待审核',
        'created_at' => date('Y-m-d H:i:s')
    ], '高级团长申请提交成功，等待管理员审核');

} catch (PDOException $e) {
    Response::error('申请失败', $errorCodes['SENIOR_AGENT_APPLICATION_FAILED'], 500);
}
