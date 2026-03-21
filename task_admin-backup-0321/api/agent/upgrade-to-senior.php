<?php
/**
 * 管理员直接升级用户为团长或高级团长接口
 * POST /task_admin/api/agent/upgrade-to-senior.php
 * 
 * 参数：
 * - user_id: C端用户ID
 * - level: 目标等级，1=团长，2=高级团长
 * - username: 用户名（可选，用于验证）
 * 
 * 功能：
 * - 直接将指定用户升级为团长或高级团长
 * - 绕过有效活跃用户数的检查
 * - 自动创建申请记录并设置为已通过
 * - 记录用户跃迁历史
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
require_once __DIR__ . '/../../../core/AppConfig.php';

// 认证中间件
AdminAuthMiddleware::authenticate();

// 初始化数据库连接
$db = Database::connect();

try {
    // 获取请求数据
    $input = json_decode(file_get_contents('php://input'), true);
    $userId = isset($input['user_id']) ? (int)$input['user_id'] : 0;
    $level = isset($input['level']) ? (int)$input['level'] : 0;
    $username = $input['username'] ?? '';

    // 验证参数
    if ($userId <= 0) {
        echo json_encode([
            'code' => 400,
            'message' => '用户ID不能为空',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    if (!in_array($level, [1, 2, 3])) {
        echo json_encode([
            'code' => 400,
            'message' => '目标等级必须是 1（团长）、2（高级团长）或 3（大团团长）',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    // 查询用户信息（确保是C端用户）
    $stmt = $db->prepare("SELECT id, username, is_agent, invite_code FROM c_users WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        echo json_encode([
            'code' => 404,
            'message' => '用户不存在或不是C端用户',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    // 验证用户名（如果提供）
    if (!empty($username) && $user['username'] !== $username) {
        echo json_encode([
            'code' => 400,
            'message' => '用户名与用户ID不匹配',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    // 检查用户当前状态
    $currentLevel = (int)$user['is_agent'];
    if ($currentLevel >= $level) {
        $levelText = $level === 1 ? '团长' : ($level === 2 ? '高级团长' : '大团团长');
        $currentLevelText = $currentLevel === 0 ? '普通用户' : ($currentLevel === 1 ? '团长' : ($currentLevel === 2 ? '高级团长' : '大团团长'));
        echo json_encode([
            'code' => 400,
            'message' => "用户当前已是{$currentLevelText}，无法升级为{$levelText}",
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    // 开始事务
    $db->beginTransaction();

    try {
        // 1. 更新用户等级
        $stmt = $db->prepare("UPDATE c_users SET is_agent = ? WHERE id = ?");
        $stmt->execute([$level, $userId]);

        // 2. 创建申请记录并设置为已通过
        $applyType = $level === 1 ? 1 : 2;
        // 从配置中获取要求的有效活跃用户数
        $requiredActiveUsers = $level === 1 ? 
            AppConfig::get('agent_required_active_users') : 
            AppConfig::get('senior_agent_required_active_users');
        $stmt = $db->prepare("INSERT INTO agent_applications (c_user_id, username, invite_code, apply_type, valid_invites, total_invites, status, admin_id, reviewed_at) VALUES (?, ?, ?, ?, ?, ?, 1, ?, NOW())");
        $stmt->execute([$userId, $user['username'], $user['invite_code'], $applyType, $requiredActiveUsers, 0, 1]);

        // 3. 记录用户跃迁历史
        $stmt = $db->prepare("INSERT INTO c_user_agent_upgrade_history (c_user_id, username, from_level, to_level, admin_id, created_at) VALUES (?, ?, ?, ?, ?, NOW())");
        $stmt->execute([$userId, $user['username'], $currentLevel, $level, 1]);

        // 提交事务
        $db->commit();

        // 返回成功响应
        $levelText = $level === 1 ? '团长' : ($level === 2 ? '高级团长' : '大团团长');
        echo json_encode([
            'code' => 0,
            'message' => "用户已成功升级为{$levelText}",
            'data' => [
                'user_id' => $userId,
                'username' => $user['username'],
                'is_agent' => $level,
                'status' => "已升级为{$levelText}"
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);

    } catch (Exception $e) {
        // 回滚事务
        $db->rollBack();
        throw $e;
    }

} catch (Exception $e) {
    // 错误处理
    echo json_encode([
        'code' => 500,
        'message' => '升级失败: ' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
?>