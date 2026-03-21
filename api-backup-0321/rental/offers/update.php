<?php
/**
 * 修改出租信息接口
 * 
 * POST /api/rental/offers/update
 * 
 * 请求头：
 * X-Token: <token> (B端或C端)
 * 
 * 请求体（除 offer_id 外，其他字段都是可选的）：
 * {
 *   "offer_id": 1,                  // 必填
 *   "title": "抖音高等级账号出租（已修改）",  // 可选
 *   "price_per_day": 6000,          // 可选
 *   "min_days": 1,                  // 可选
 *   "max_days": 30,                 // 可选
 *   "allow_renew": 1,               // 可选
 *   "content_json": {...}           // 可选
 * }
 * 
 * 说明：未传的字段保持原值不变
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

// 获取请求参数（兼容 JSON 和 form-data 两种提交方式）
$input = json_decode(file_get_contents('php://input'), true);
if (!is_array($input)) {
    $input = $_POST;
}
$offerId = intval($input['offer_id'] ?? $input['id'] ?? 0);

// 参数校验：offer_id 必填
if ($offerId <= 0) {
    Response::error('出租信息ID无效', $errorCodes['RENTAL_OFFER_NOT_FOUND']);
}

// 其他参数都是可选的
$hasTitle = isset($input['title']);
$hasPricePerDay = isset($input['price_per_day']);
$hasMinDays = isset($input['min_days']);
$hasMaxDays = isset($input['max_days']);
$hasAllowRenew = isset($input['allow_renew']);
$hasContentJson = isset($input['content_json']);

// 如果传了参数，进行校验
if ($hasTitle) {
    $title = trim($input['title']);
    if (empty($title)) {
        Response::error('标题不能为空', $errorCodes['RENTAL_OFFER_TITLE_EMPTY']);
    }
}

if ($hasPricePerDay) {
    $pricePerDay = intval($input['price_per_day']);
    if ($pricePerDay <= 0) {
        Response::error('每日租金必须大于0', $errorCodes['RENTAL_OFFER_PRICE_INVALID']);
    }
}

try {
    // 检查出租信息是否存在，并校验权限
    $stmt = $db->prepare("
        SELECT id, user_id, user_type, title, price_per_day, min_days, max_days, allow_renew, content_json, status 
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

    // 已封禁的信息不能修改
    if ($offer['status'] == 2) {
        Response::error('该出租信息已被封禁，无法修改', $errorCodes['RENTAL_OFFER_ALREADY_BANNED']);
    }

    // 使用新值或保留旧值
    $newTitle = $hasTitle ? $title : $offer['title'];
    $newPricePerDay = $hasPricePerDay ? $pricePerDay : $offer['price_per_day'];
    $newMinDays = $hasMinDays ? intval($input['min_days']) : $offer['min_days'];
    $newMaxDays = $hasMaxDays ? intval($input['max_days']) : $offer['max_days'];
    $newAllowRenew = $hasAllowRenew ? intval($input['allow_renew']) : $offer['allow_renew'];
    $newContentJson = $hasContentJson ? json_encode($input['content_json'], JSON_UNESCAPED_UNICODE) : $offer['content_json'];

    // 验证天数范围（使用最终值）
    if ($newMinDays < 1 || $newMaxDays < 1 || $newMinDays > $newMaxDays) {
        Response::error('租期天数设置不合法', $errorCodes['RENTAL_OFFER_DAYS_INVALID']);
    }

    // 验证 allow_renew 值
    if (!in_array($newAllowRenew, [0, 1])) {
        $newAllowRenew = 1;
    }

    $db->beginTransaction();

    // 更新出租信息
    $stmt = $db->prepare("
        UPDATE rental_offers 
        SET 
            title = ?,
            price_per_day = ?,
            min_days = ?,
            max_days = ?,
            allow_renew = ?,
            content_json = ?,
            updated_at = NOW()
        WHERE id = ?
    ");
    
    $stmt->execute([
        $newTitle,
        $newPricePerDay,
        $newMinDays,
        $newMaxDays,
        $newAllowRenew,
        $newContentJson,
        $offerId
    ]);

    $db->commit();

    Response::success([
        'offer_id' => $offerId,
        'title' => $newTitle,
        'price_per_day' => $newPricePerDay,
        'min_days' => $newMinDays,
        'max_days' => $newMaxDays,
        'allow_renew' => $newAllowRenew
    ], '修改成功');

} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    error_log('Rental offer update failed: ' . $e->getMessage());
    Response::error('修改失败，请稍后重试', $errorCodes['RENTAL_OFFER_UPDATE_FAILED']);
}
