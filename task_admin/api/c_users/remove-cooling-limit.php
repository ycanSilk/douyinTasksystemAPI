<?php
/**
 * 管理员设置 C 端用户冷却时间限制接口
 *
 * POST /task_admin/api/c_users/remove-cooling-limit.php
 *
 * 请求头：
 * Authorization: Bearer <admin_token>
 *
 * 请求体：
 * {
 *   "user_id": 123,
 *   "cooling_time_limit": 0
 * }
 *
 * 参数说明：
 * - user_id: C 端用户 ID
 * - cooling_time_limit: 接取任务冷却时间限制 0=不开启，1=开启
 *
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "设置成功",
 *   "data": {
 *     "user_id": 123,
 *     "cooling_time_limit": 0
 *   },
 *   "timestamp": 1736582400
 * }
 *
 * 功能说明：
 * 1. 修改 c_users 表的 cooling_time_limit 字段
 * 2. cooling_time_limit=0：不开启冷却时间限制，接单无需等待
 * 3. cooling_time_limit=1：开启冷却时间限制，接单需要冷却
 *
 * 错误码说明：
 * 1001  - 请求方法错误
 * 1002  - 数据库错误
 * 2001  - Token 无效
 * 2002  - Token 过期
 * 4001  - 参数错误
 * 4002  - 用户不存在
 * 5000  - 系统错误
 */

// 加载管理员认证和数据库
require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';

// 管理员认证
AdminAuthMiddleware::authenticate();
$db = Database::connect();

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);
$userId = $input['user_id'] ?? 0;
$coolingTimeLimit = $input['cooling_time_limit'] ?? null;

// 参数校验
if (empty($userId) || !is_numeric($userId)) {
    echo json_encode([
        'code' => 4001,
        'message' => '用户 ID 不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($coolingTimeLimit === null || !in_array($coolingTimeLimit, [0, 1], true)) {
    echo json_encode([
        'code' => 4001,
        'message' => '参数错误，cooling_time_limit 必须为 0 或 1',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 查询用户当前状态
    $stmt = $db->prepare("SELECT id, cooling_time_limit FROM c_users WHERE id = ?");
    $stmt->execute([$userId]);
    $userInfo = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$userInfo) {
        echo json_encode([
            'code' => 4002,
            'message' => '用户不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    $currentCoolingLimit = $userInfo['cooling_time_limit'] ?? 1;

    if ($currentCoolingLimit == $coolingTimeLimit) {
        echo json_encode([
            'code' => 0,
            'message' => '设置成功（无变化）',
            'data' => [
                'user_id' => (int)$userId,
                'cooling_time_limit' => (int)$coolingTimeLimit,
                'current_status' => (int)$currentCoolingLimit
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    // 更新用户冷却限制设置
    $stmt = $db->prepare("
        UPDATE c_users
        SET cooling_time_limit = ?, updated_at = NOW()
        WHERE id = ?
    ");
    $stmt->execute([$coolingTimeLimit, $userId]);
    $affectedRows = $stmt->rowCount();

    if ($affectedRows > 0) {
        $statusText = $coolingTimeLimit === 0 ? '已解除' : '已开启';
        echo json_encode([
            'code' => 0,
            'message' => "{$statusText}接取任务冷却时间限制",
            'data' => [
                'user_id' => (int)$userId,
                'cooling_time_limit' => (int)$coolingTimeLimit,
                'description' => $coolingTimeLimit === 0 ? '接单无需等待' : '接单需要冷却'
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);

    } else {
        echo json_encode([
            'code' => 5000,
            'message' => '设置失败',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
    }

} catch (PDOException $e) {
    echo json_encode([
        'code' => 5000,
        'message' => '数据库错误：' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    echo json_encode([
        'code' => 5000,
        'message' => '系统错误：' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
