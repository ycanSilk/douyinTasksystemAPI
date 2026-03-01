<?php
/**
 * 上架/下架出租信息接口
 * 
 * POST /api/rental/offers/toggle-status
 * 
 * 请求头：
 * X-Token: <token> (B端或C端)
 * 
 * 请求体：
 * {
 *   "offer_id": 1,
 *   "status": 1
 * }
 * 
 * status 说明：
 * 0 = 已下架
 * 1 = 上架中
 * （2 = 已封禁，仅Admin可设置，用户不能自己封禁）
 */

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
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

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// 认证（B/C端共用）
$auth = new AuthMiddleware($db);
$user = $auth->authenticateAny();
$userId = $user['user_id'];
$userType = $user['type']; // 1=C端 2=B端

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$offerId = intval($input['offer_id'] ?? 0);
$status = intval($input['status'] ?? -1);

// 参数校验
if ($offerId <= 0) {
    Response::error('出租信息ID无效', $errorCodes['RENTAL_OFFER_NOT_FOUND']);
}

// 用户只能设置 0（下架）或 1（上架），不能设置 2（封禁）
if (!in_array($status, [0, 1])) {
    Response::error('状态参数无效', $errorCodes['RENTAL_OFFER_STATUS_INVALID']);
}

try {
    // 检查出租信息是否存在，并校验权限
    $stmt = $db->prepare("
        SELECT id, user_id, user_type, status, title 
        FROM rental_offers 
        WHERE id = ?
    ");
    $stmt->execute([$offerId]);
    $offer = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$offer) {
        Response::error('出租信息不存在', $errorCodes['RENTAL_OFFER_NOT_FOUND']);
    }

    // 权限检查：只有发布者本人可以修改
    if ($offer['user_id'] != $userId || $offer['user_type'] != $userType) {
        Response::error('无权修改此出租信息', $errorCodes['RENTAL_OFFER_NO_PERMISSION']);
    }

    // 已封禁的信息不能修改状态
    if ($offer['status'] == 2) {
        Response::error('该出租信息已被封禁，无法修改状态', $errorCodes['RENTAL_OFFER_ALREADY_BANNED']);
    }

    $db->beginTransaction();

    // 更新状态
    $stmt = $db->prepare("
        UPDATE rental_offers 
        SET status = ?, updated_at = NOW()
        WHERE id = ?
    ");
    
    $stmt->execute([$status, $offerId]);

    $db->commit();

    $statusText = $status == 1 ? '上架中' : '已下架';

    Response::success([
        'offer_id' => $offerId,
        'status' => $status,
        'status_text' => $statusText
    ], '状态修改成功');

} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    error_log('Rental offer toggle status failed: ' . $e->getMessage());
    Response::error('状态修改失败，请稍后重试', $errorCodes['RENTAL_OFFER_UPDATE_FAILED']);
}
