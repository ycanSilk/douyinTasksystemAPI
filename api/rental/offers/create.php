<?php
/**
 * 发布出租信息接口
 * 
 * POST /api/rental/offers/create
 * 
 * 请求头：
 * X-Token: <token> (B端或C端)
 * 
 * 请求体：
 * {
 *   "title": "抖音高等级账号出租",
 *   "price_per_day": 5000,
 *   "min_days": 1,
 *   "max_days": 30,
 *   "allow_renew": 1,
 *   "content_json": {
 *     "account_info": "账号粉丝10w+，权重高",
 *     "capabilities": ["直播", "短视频发布"],
 *     "login_method": "扫码登录",
 *     "contact": "微信：xxx",
 *     "images": ["http://example.com/img1.jpg", "http://example.com/img2.jpg"]
 *   }
 * }
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
$title = trim($input['title'] ?? '');
$pricePerDay = intval($input['price_per_day'] ?? 0);
$minDays = intval($input['min_days'] ?? 1);
$maxDays = intval($input['max_days'] ?? 30);
$allowRenew = isset($input['allow_renew']) ? intval($input['allow_renew']) : 1;
$contentJson = $input['content_json'] ?? null;

// 参数校验
if (empty($title)) {
    Response::error('标题不能为空', $errorCodes['RENTAL_OFFER_TITLE_EMPTY']);
}

if ($pricePerDay <= 0) {
    Response::error('每日租金必须大于0', $errorCodes['RENTAL_OFFER_PRICE_INVALID']);
}

if ($minDays < 1 || $maxDays < 1 || $minDays > $maxDays) {
    Response::error('租期天数设置不合法', $errorCodes['RENTAL_OFFER_DAYS_INVALID']);
}

if (!in_array($allowRenew, [0, 1])) {
    $allowRenew = 1;
}

// JSON数据处理
$contentJsonStr = null;
if ($contentJson !== null) {
    $contentJsonStr = json_encode($contentJson, JSON_UNESCAPED_UNICODE);
}

try {
    $db->beginTransaction();

    // 插入出租信息
    $stmt = $db->prepare("
        INSERT INTO rental_offers 
        (user_id, user_type, title, price_per_day, min_days, max_days, allow_renew, content_json, status, created_at, updated_at) 
        VALUES 
        (?, ?, ?, ?, ?, ?, ?, ?, 1, NOW(), NOW())
    ");
    
    $stmt->execute([
        $userId,
        $userType,
        $title,
        $pricePerDay,
        $minDays,
        $maxDays,
        $allowRenew,
        $contentJsonStr
    ]);

    $offerId = $db->lastInsertId();

    $db->commit();

    Response::success([
        'offer_id' => $offerId,
        'title' => $title,
        'price_per_day' => $pricePerDay,
        'min_days' => $minDays,
        'max_days' => $maxDays,
        'allow_renew' => $allowRenew,
        'status' => 1 // 上架中
    ], '发布成功');

} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    error_log('Rental offer create failed: ' . $e->getMessage());
    Response::error('发布失败，请稍后重试', $errorCodes['RENTAL_OFFER_CREATE_FAILED']);
}
