<?php
header('Content-Type: application/json');

// 引入必要的文件
require_once '../../../core/DB.php';
require_once '../../../core/Response.php';
require_once '../../../core/Auth.php';
require_once '../../auth/AuthMiddleware.php';
// 数据库连接

// 初始化数据库连接
$db = new DB();
$pdo = $db->getConnection();

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
    // 查询提现申请
    $sql = "SELECT * FROM withdraw_requests WHERE id = ?";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$id]);
    $withdraw = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$withdraw) {
        throw new Exception('提现申请不存在');
    }

    if ($withdraw['status'] !== 0) {
        throw new Exception('该提现申请已处理');
    }

    // 如果审核通过，检查钱包余额
    if ($status == 1) {
        // 查询钱包余额
        $sql = "SELECT balance FROM wallets WHERE id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$withdraw['wallet_id']]);
        $wallet = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$wallet) {
            throw new Exception('钱包不存在');
        }

        if ($wallet['balance'] < $withdraw['amount']) {
            throw new Exception('钱包余额不足');
        }

        // 更新钱包余额
        $sql = "UPDATE wallets SET balance = balance - ? WHERE id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$withdraw['amount'], $withdraw['wallet_id']]);

        // 记录钱包流水
        $sql = "INSERT INTO wallets_log (wallet_id, user_id, user_type, type, amount, related_type, related_id, remark) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            $withdraw['wallet_id'],
            $withdraw['user_id'],
            $withdraw['user_type'],
            2, // 2=提现
            $withdraw['amount'],
            2, // 2=提现
            $id,
            '提现审核通过'
        ]);
    }

    // 更新提现申请状态
    $sql = "UPDATE withdraw_requests SET status = ?, remark = ? WHERE id = ?";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$status, $remark, $id]);

    // 提交事务
    $pdo->commit();

    $response->success(['message' => '审核成功']);
} catch (Exception $e) {
    // 回滚事务
    $pdo->rollBack();
    $response->error(500, $e->getMessage());
}
?>