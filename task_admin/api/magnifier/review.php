<?php
header('Content-Type: application/json');

// 引入必要的文件
require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';

// 初始化数据库连接
$pdo = Database::connect();

// 认证中间件
AdminAuthMiddleware::authenticate();

// 处理请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error('方法不允许', 405, 405);
    exit;
}

// 获取请求数据
$data = json_decode(file_get_contents('php://input'), true);
if (!$data) {
    Response::error('无效的请求数据', 400, 400);
    exit;
}

// 验证参数
$recordId = isset($data['recordId']) ? intval($data['recordId']) : 0;
$status = isset($data['status']) ? intval($data['status']) : -1;
$remark = isset($data['remark']) ? $data['remark'] : '';

if (!$recordId || !in_array($status, [3, 4])) {
    Response::error('参数错误', 400, 400);
    exit;
}

// 开始事务
$pdo->beginTransaction();

try {
    // 查询任务记录
    $sql = "SELECT c.*, b.template_id FROM c_task_records c LEFT JOIN b_tasks b ON c.b_task_id = b.id WHERE c.id = ?";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$recordId]);
    $record = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$record) {
        throw new Exception('任务记录不存在');
    }

    // 验证是否是放大镜任务
    if ($record['template_id'] != 3) {
        throw new Exception('不是放大镜任务');
    }

    if ($record['status'] !== 2) {
        throw new Exception('该任务记录不是待审核状态');
    }

    // 更新任务记录状态
    $sql = "UPDATE c_task_records SET status = ?, remark = ?, reviewed_at = NOW() WHERE id = ?";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$status, $remark, $recordId]);

    // 如果审核通过，更新钱包余额和记录
    if ($status == 3) {
        // 查询任务信息
        $sql = "SELECT b.unit_price FROM b_tasks b WHERE b.id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$record['b_task_id']]);
        $task = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$task) {
            throw new Exception('任务不存在');
        }

        // 查询C端用户信息
        $sql = "SELECT c.wallet_id, c.parent_id FROM c_users c WHERE c.id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$record['c_user_id']]);
        $cUser = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$cUser) {
            throw new Exception('用户不存在');
        }

        // 计算佣金
        $config = require __DIR__ . '/../../../config/app.php';
        $commissionCUser = $config['commission_c_user'] ?? 57; // 57%
        $commissionAgent = $config['commission_agent'] ?? 8; // 8%

        $unitPrice = (float)$task['unit_price'];
        $cUserCommission = $unitPrice * ($commissionCUser / 100);
        $agentCommission = 0;

        // 如果有上级且上级是团长
        if ($cUser['parent_id']) {
            $sql = "SELECT u.wallet_id, u.is_agent FROM c_users u WHERE u.id = ?";
            $stmt = $pdo->prepare($sql);
            $stmt->execute([$cUser['parent_id']]);
            $parentUser = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($parentUser && $parentUser['is_agent']) {
                $agentCommission = $unitPrice * ($commissionAgent / 100);
                
                // 给团长加佣金
                $sql = "UPDATE wallets SET balance = balance + ? WHERE id = ?";
                $stmt = $pdo->prepare($sql);
                $stmt->execute([$agentCommission, $parentUser['wallet_id']]);

                // 记录团长佣金流水
                $sql = "INSERT INTO wallets_log (wallet_id, user_id, user_type, type, amount, related_type, related_id, remark) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                $stmt = $pdo->prepare($sql);
                $stmt->execute([
                    $parentUser['wallet_id'],
                    $cUser['parent_id'],
                    1, // C端用户
                    1, // 收入
                    $agentCommission,
                    'agent_commission',
                    $recordId,
                    '放大镜任务团长佣金'
                ]);
            }
        }

        // 给C端用户加佣金
        $sql = "UPDATE wallets SET balance = balance + ? WHERE id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$cUserCommission, $cUser['wallet_id']]);

        // 记录C端用户佣金流水
        $sql = "INSERT INTO wallets_log (wallet_id, user_id, user_type, type, amount, related_type, related_id, remark) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            $cUser['wallet_id'],
            $record['c_user_id'],
            1, // C端用户
            1, // 收入
            $cUserCommission,
            'task_commission',
            $recordId,
            '放大镜任务佣金'
        ]);
    }

    // 检查任务是否已完成
    $sql = "SELECT COUNT(*) as pending_count FROM c_task_records WHERE b_task_id = ? AND status < 3";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$record['b_task_id']]);
    $pendingCount = $stmt->fetchColumn();

    if ($pendingCount == 0) {
        // 更新任务状态为已完成
        $sql = "UPDATE b_tasks SET status = 2 WHERE id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$record['b_task_id']]);
    }

    // 提交事务
    $pdo->commit();

    Response::success(['message' => '审核成功']);
} catch (Exception $e) {
    // 回滚事务
    $pdo->rollBack();
    Response::error($e->getMessage(), 500, 500);
}
?>