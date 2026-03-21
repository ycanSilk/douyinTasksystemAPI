<?php
/**
 * 审核应征（求租方审核）
 * POST /api/rental/applications/review
 *
 * 请求体：
 * {
 *   "application_id": 1,
 *   "action": "approve",  // approve=通过, reject=拒绝
 *   "days": 1,            // 租赁天数（通过时可选）
 *   "reject_reason": ""   // 拒绝原因（拒绝时可选）
 * }
 *
 * 兼容旧格式：
 * {
 *   "application_id": 1,
 *   "status": 1,  // 1=通过, 2=驳回
 *   "remark": "审核备注"
 * }
 */

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['code' => 1001, 'message' => '请求方法错误', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Response.php';
require_once __DIR__ . '/../../../core/Notification.php';
require_once __DIR__ . '/../../../core/AppConfig.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';
$db = Database::connect();

// 认证
$auth = new AuthMiddleware($db);
$user = $auth->authenticateAny();
$userId = $user['user_id'];
$userType = $user['type'];

// 获取参数
$input = json_decode(file_get_contents('php://input'), true);
$applicationId = intval($input['application_id'] ?? 0);

// 兼容两种参数格式：action(approve/reject) 或 status(1/2)
if (isset($input['action'])) {
    $reviewStatus = $input['action'] === 'approve' ? 1 : ($input['action'] === 'reject' ? 2 : 0);
} else {
    $reviewStatus = intval($input['status'] ?? 0);
}

$remark = trim($input['remark'] ?? $input['reject_reason'] ?? '');

if ($applicationId <= 0) {
    Response::error('应征ID无效', $errorCodes['RENTAL_APPLICATION_NOT_FOUND']);
}

if (!in_array($reviewStatus, [1, 2])) {
    Response::error('审核状态无效', $errorCodes['RENTAL_APPLICATION_INVALID_STATUS']);
}

try {
    // 获取应征信息
    $stmt = $db->prepare("
        SELECT 
            ra.*,
            rd.user_id as demand_user_id,
            rd.user_type as demand_user_type,
            rd.title as demand_title,
            rd.budget_amount,
            rd.days_needed,
            rd.requirements_json,
            rd.status as demand_status
        FROM rental_applications ra
        INNER JOIN rental_demands rd ON ra.demand_id = rd.id
        WHERE ra.id = ?
    ");
    $stmt->execute([$applicationId]);
    $application = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$application) {
        Response::error('应征记录不存在', $errorCodes['RENTAL_APPLICATION_NOT_FOUND']);
    }

    // 检查权限（只有求租方可以审核）
    if ($application['demand_user_id'] != $userId || $application['demand_user_type'] != $userType) {
        Response::error('无权审核此应征', $errorCodes['RENTAL_APPLICATION_NO_PERMISSION']);
    }

    // 检查应征状态
    if ($application['status'] != 0) {
        Response::error('应征已审核，无法重复操作', $errorCodes['RENTAL_APPLICATION_INVALID_STATUS']);
    }

    // 检查求租状态
    if ($application['demand_status'] != 1) {
        Response::error('求租信息已下架或已成交', $errorCodes['RENTAL_DEMAND_NOT_FOUND']);
    }

    $db->beginTransaction();

    // 更新应征状态
    $updateStmt = $db->prepare("
        UPDATE rental_applications 
        SET status = ?, review_remark = ?, reviewed_at = NOW(), updated_at = NOW()
        WHERE id = ?
    ");
    $updateStmt->execute([$reviewStatus, $remark, $applicationId]);

    $orderId = null;

    // 如果审核通过，创建订单
    if ($reviewStatus == 1) {
        // 更新求租状态为已成交
        $updateDemandStmt = $db->prepare("UPDATE rental_demands SET status = 2 WHERE id = ?");
        $updateDemandStmt->execute([$application['demand_id']]);

        // 获取求租方钱包信息
        $demandWalletStmt = $db->prepare("
            SELECT wallet_id, username 
            FROM " . ($application['demand_user_type'] == 'b' ? 'b_users' : 'c_users') . " 
            WHERE id = ?
        ");
        $demandWalletStmt->execute([$application['demand_user_id']]);
        $demandWallet = $demandWalletStmt->fetch(PDO::FETCH_ASSOC);

        // 获取应征方（出租方）钱包信息
        $applicantWalletStmt = $db->prepare("
            SELECT wallet_id, username 
            FROM " . ($application['applicant_user_type'] == 'b' ? 'b_users' : 'c_users') . " 
            WHERE id = ?
        ");
        $applicantWalletStmt->execute([$application['applicant_user_id']]);
        $applicantWallet = $applicantWalletStmt->fetch(PDO::FETCH_ASSOC);

        // 计算分成
        $sellerRate = (int)AppConfig::get('rental_seller_rate', 70);
        $agentRate = (int)AppConfig::get('rental_agent_rate', 10);
        $seniorAgentRate = (int)AppConfig::get('rental_senior_agent_rate', 10);

        $sellerAmount = intval($application['budget_amount'] * $sellerRate / 100);

        // 查询卖方（应征方/出租方）的团长上级
        $agentUserId = null;
        $agentAmount = 0;

        if ($application['applicant_user_type'] == 1) {
            // C端卖方才查团长
            $stmt = $db->prepare("SELECT parent_id FROM c_users WHERE id = ?");
            $stmt->execute([$application['applicant_user_id']]);
            $sellerCUser = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($sellerCUser && !empty($sellerCUser['parent_id'])) {
                $stmt = $db->prepare("SELECT id, is_agent FROM c_users WHERE id = ?");
                $stmt->execute([$sellerCUser['parent_id']]);
                $parentUser = $stmt->fetch(PDO::FETCH_ASSOC);

                if ($parentUser && (int)$parentUser['is_agent'] >= 1) {
                    $agentUserId = (int)$parentUser['id'];
                    if ((int)$parentUser['is_agent'] === 2) {
                        $agentAmount = intval($application['budget_amount'] * $seniorAgentRate / 100);
                    } else {
                        $agentAmount = intval($application['budget_amount'] * $agentRate / 100);
                    }
                }
            }
        }

        $platformAmount = $application['budget_amount'] - $sellerAmount - $agentAmount;

        // 创建订单
        $createOrderStmt = $db->prepare("
            INSERT INTO rental_orders
            (
                source_type, source_id,
                buyer_user_id, buyer_user_type, buyer_wallet_id, buyer_info_json,
                seller_user_id, seller_user_type, seller_wallet_id, seller_info_json,
                agent_user_id, agent_amount,
                total_amount, platform_amount, seller_amount,
                days, allow_renew, order_json,
                status, created_at, updated_at
            )
            VALUES
            (1, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, NOW(), NOW())
        ");
        // 计算订单总金额（日预算 × 天数）
        $pricePerDay = $application['budget_amount']; // 日预算直接作为日租金
        $totalAmount = $pricePerDay * $application['days_needed'];

        $createOrderStmt->execute([
            $application['demand_id'],
            $application['demand_user_id'],
            $application['demand_user_type'] == 1 ? 'c' : 'b',
            $demandWallet['wallet_id'],
            $application['requirements_json'],
            $application['applicant_user_id'],
            $application['applicant_user_type'] == 1 ? 'c' : 'b',
            $applicantWallet['wallet_id'],
            $application['application_json'],
            $agentUserId,
            $agentAmount,
            $totalAmount,
            $platformAmount,
            $sellerAmount,
            $application['days_needed'],
            $application['allow_renew'],
            json_encode([
                'application_id' => $applicationId,
                'demand_title' => $application['demand_title'],
                'price_per_day' => $pricePerDay,
                'min_days' => 1,
                'max_days' => 30
            ], JSON_UNESCAPED_UNICODE)
        ]);

        $orderId = $db->lastInsertId();

        // 求租方（买方）新增 wallet_log（标记冻结金额转入订单，金额=0因为余额不变）
        $insertBuyerLogStmt = $db->prepare("
            INSERT INTO wallets_log 
            (wallet_id, user_id, username, user_type, type, amount, before_balance, after_balance, related_type, related_id, remark, created_at) 
            VALUES 
            (?, ?, ?, ?, 2, 0, 0, 0, 'rental_order_pay', ?, ?, NOW())
        ");
        $insertBuyerLogStmt->execute([
            $demandWallet['wallet_id'],
            $application['demand_user_id'],
            $demandWallet['username'],
            $application['demand_user_type'],
            $orderId,
            "求租订单已创建：{$application['demand_title']}（冻结金额转入订单：{$application['budget_amount']}）"
        ]);

        // 出租方（卖方）生成 wallet_log（amount=0，冻结状态）
        $insertSellerLogStmt = $db->prepare("
            INSERT INTO wallets_log 
            (wallet_id, user_id, username, user_type, type, amount, before_balance, after_balance, related_type, related_id, remark, created_at) 
            VALUES 
            (?, ?, ?, ?, 2, 0, 0, 0, 'rental_order_pending', ?, ?, NOW())
        ");
        $insertSellerLogStmt->execute([
            $applicantWallet['wallet_id'],
            $application['applicant_user_id'],
            $applicantWallet['username'],
            $application['applicant_user_type'],
            $orderId,
            "租赁订单已创建，待客服处理：{$application['demand_title']}（预计收益：{$sellerAmount}）"
        ]);
        
        // 自动拒绝同一求租的其他待审核应征
        $rejectOthersStmt = $db->prepare("
            UPDATE rental_applications 
            SET status = 2, 
                review_remark = '该求租已被其他应征方满足，感谢您的申请~下次再早点哦',
                reviewed_at = NOW()
            WHERE demand_id = ? 
            AND id != ? 
            AND status = 0
        ");
        $rejectOthersStmt->execute([$application['demand_id'], $applicationId]);
        $rejectedCount = $rejectOthersStmt->rowCount();
        
        if ($rejectedCount > 0) {
            // 获取被自动拒绝的应征列表，用于发送通知
            $getRejectedStmt = $db->prepare("
                SELECT id, applicant_user_id, applicant_user_type 
                FROM rental_applications 
                WHERE demand_id = ? 
                AND id != ? 
                AND status = 2 
                AND review_remark LIKE '%其他应征方满足%'
            ");
            $getRejectedStmt->execute([$application['demand_id'], $applicationId]);
            $rejectedApplications = $getRejectedStmt->fetchAll(PDO::FETCH_ASSOC);
        }
    }

    $db->commit();

    // 发送通知（在事务外）
    if ($reviewStatus == 1) {
        // 通知应征方（出租方）
        Notification::sendToUser(
            $db,
            $application['applicant_user_id'],
            $application['applicant_user_type'],
            '应征审核通过',
            "您应征的求租「{$application['demand_title']}」已通过审核，订单已生成，等待客服处理",
            'rental_application',
            $applicationId
        );

        // 通知求租方
        Notification::sendToUser(
            $db,
            $application['demand_user_id'],
            $application['demand_user_type'],
            '应征已审核',
            "您的求租「{$application['demand_title']}」已选中应征方，订单已创建",
            'rental_order',
            $orderId
        );
        
        // 通知被自动拒绝的其他应征方
        if (!empty($rejectedApplications)) {
            foreach ($rejectedApplications as $rejected) {
                Notification::sendToUser(
                    $db,
                    $rejected['applicant_user_id'],
                    $rejected['applicant_user_type'],
                    '应征未被选中',
                    "很遗憾，您应征的求租「{$application['demand_title']}」已被其他应征方满足。感谢您的申请，下次再早点哦~",
                    'rental_application',
                    $rejected['id']
                );
            }
        }
    } else {
        // 驳回通知应征方
        Notification::sendToUser(
            $db,
            $application['applicant_user_id'],
            $application['applicant_user_type'],
            '应征审核未通过',
            "您应征的求租「{$application['demand_title']}」未通过审核" . ($remark ? "：{$remark}" : ''),
            'rental_application',
            $applicationId
        );
    }

    $statusText = $reviewStatus == 1 ? '审核通过' : '审核驳回';
    Response::success([
        'application_id' => $applicationId,
        'status' => $reviewStatus,
        'status_text' => $statusText,
        'order_id' => $orderId
    ], $statusText . '成功');

} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    error_log('Application review failed: ' . $e->getMessage());
    Response::error('审核失败：' . $e->getMessage(), $errorCodes['RENTAL_APPLICATION_REVIEW_FAILED']);
}
