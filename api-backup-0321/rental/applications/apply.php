<?php
/**
 * 应征求租信息
 * POST /api/rental/applications/apply
 * 
 * 请求体：
 * {
 *   "demand_id": 1,
 *   "allow_renew": 1,
 *   "application_json": {
 *     "screenshots": ["url1", "url2"],
 *     "description": "我有符合要求的账号"
 *   }
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

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';
$db = Database::connect();

// 认证
$auth = new AuthMiddleware($db);
$user = $auth->authenticateAny();
$userId = $user['user_id'];
$userType = $user['type'];

// 获取参数
$input = json_decode(file_get_contents('php://input'), true);
$demandId = intval($input['demand_id'] ?? 0);
$allowRenew = intval($input['allow_renew'] ?? 1);
$applicationJson = $input['application_json'] ?? null;

if ($demandId <= 0) {
    Response::error('求租信息ID无效', $errorCodes['RENTAL_DEMAND_NOT_FOUND']);
}

try {
    // 检查求租信息
    $stmt = $db->prepare("SELECT id, user_id, user_type, status, title FROM rental_demands WHERE id = ?");
    $stmt->execute([$demandId]);
    $demand = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$demand || $demand['status'] != 1) {
        Response::error('求租信息不存在或已下架', $errorCodes['RENTAL_DEMAND_NOT_FOUND']);
    }

    // 不能应征自己的求租
    if ($demand['user_id'] == $userId && $demand['user_type'] == $userType) {
        Response::error('不能应征自己的求租信息', $errorCodes['RENTAL_APPLICATION_NO_PERMISSION']);
    }

    // 检查是否已应征
    $checkStmt = $db->prepare("SELECT id FROM rental_applications WHERE demand_id = ? AND applicant_user_id = ? AND applicant_user_type = ?");
    $checkStmt->execute([$demandId, $userId, $userType]);
    if ($checkStmt->fetch()) {
        Response::error('您已经应征过此求租信息', $errorCodes['RENTAL_APPLICATION_ALREADY_EXISTS']);
    }

    $db->beginTransaction();

    // 插入应征记录
    $insertStmt = $db->prepare("
        INSERT INTO rental_applications 
        (demand_id, applicant_user_id, applicant_user_type, allow_renew, application_json, status, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, 0, NOW(), NOW())
    ");
    $insertStmt->execute([
        $demandId,
        $userId,
        $userType,
        $allowRenew,
        json_encode($applicationJson, JSON_UNESCAPED_UNICODE)
    ]);

    $applicationId = $db->lastInsertId();
    $db->commit();

    // 通知求租方收到新应征
    Notification::sendToUser(
        $db,
        $demand['user_id'],
        $demand['user_type'],
        '收到新的应征申请',
        "您的求租「{$demand['title']}」收到了新的应征，请前往查看审核",
        'rental_application',
        $applicationId
    );

    Response::success([
        'application_id' => $applicationId,
        'demand_id' => $demandId,
        'status' => 0,
        'status_text' => '待审核'
    ], '应征成功，等待审核');

} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    error_log('Application apply failed: ' . $e->getMessage());
    Response::error('应征失败', $errorCodes['RENTAL_APPLICATION_CREATE_FAILED']);
}
