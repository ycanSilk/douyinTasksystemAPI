<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 引入必要的文件
require_once '../../../core/Database.php';
require_once '../../../core/Response.php';
require_once '../../../core/Auth.php';
require_once '../../auth/AuthMiddleware.php';

// 初始化数据库连接
$pdo = Database::connect();

// 初始化响应
$response = new Response();

// 认证中间件
AdminAuthMiddleware::authenticate();

// 处理请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $response->error(405, '方法不允许');
    exit;
}

// 获取请求数据
$data = json_decode(file_get_contents('php://input'), true);
if (!$data) {
    $response->error(400, '无效的请求数据');
    exit;
}

// 验证参数
$id = isset($data['id']) ? intval($data['id']) : 0;
$status = isset($data['status']) ? intval($data['status']) : -1;
$remark = isset($data['remark']) ? $data['remark'] : '';

if (!$id || !in_array($status, [1, 2])) {
    $response->error(400, '参数错误');
    exit;
}

// 开始事务
$pdo->beginTransaction();

try {
    // 查询充值申请
    $sql = "SELECT * FROM recharge_requests WHERE id = ?";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$id]);
    $recharge = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$recharge) {
        throw new Exception('充值申请不存在');
    }

    if ($recharge['status'] !== 0) {
        throw new Exception('该充值申请已处理');
    }

    // 更新充值申请状态
    $sql = "UPDATE recharge_requests SET status = ?, remark = ? WHERE id = ?";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$status, $remark, $id]);

    // 如果审核通过，更新钱包余额
    if ($status == 1) {
        // 更新钱包余额
        $sql = "UPDATE wallets SET balance = balance + ? WHERE id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$recharge['amount'], $recharge['wallet_id']]);

        // 记录钱包流水
        $sql = "INSERT INTO wallets_log (wallet_id, user_id, user_type, type, amount, related_type, related_id, remark) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            $recharge['wallet_id'],
            $recharge['user_id'],
            $recharge['user_type'],
            1, // 1=充值
            $recharge['amount'],
            1, // 1=充值
            $id,
            '充值审核通过'
        ]);
    }

    // 提交事务
    $pdo->commit();

    $response->success(['message' => '审核成功']);
} catch (Exception $e) {
    // 回滚事务
    $pdo->rollBack();
    $response->error(500, $e->getMessage());
}
?>