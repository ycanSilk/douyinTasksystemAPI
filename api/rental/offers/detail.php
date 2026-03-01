<?php
/**
 * 出租信息详情接口
 * 
 * GET /api/rental/offers/detail
 * 
 * 请求参数：
 * - offer_id: 出租信息ID（必填）
 * 
 * 示例：
 * GET /api/rental/offers/detail?offer_id=1
 */

header('Content-Type: application/json; charset=utf-8');

// 只允许 GET 请求
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
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
require_once __DIR__ . '/../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// 获取请求参数
$offerId = intval($_GET['offer_id'] ?? 0);

// 参数校验
if ($offerId <= 0) {
    Response::error('出租信息ID无效', $errorCodes['RENTAL_OFFER_NOT_FOUND']);
}

try {
    // 查询出租信息详情
    $stmt = $db->prepare("
        SELECT 
            ro.id,
            ro.user_id,
            ro.user_type,
            ro.title,
            ro.price_per_day,
            ro.min_days,
            ro.max_days,
            ro.allow_renew,
            ro.content_json,
            ro.status,
            ro.view_count,
            ro.created_at,
            ro.updated_at,
            CASE 
                WHEN ro.user_type = 1 THEN cu.username
                WHEN ro.user_type = 2 THEN bu.username
            END as publisher_username,
            CASE 
                WHEN ro.user_type = 1 THEN cu.email
                WHEN ro.user_type = 2 THEN bu.email
            END as publisher_email
        FROM rental_offers ro
        LEFT JOIN c_users cu ON ro.user_type = 1 AND ro.user_id = cu.id
        LEFT JOIN b_users bu ON ro.user_type = 2 AND ro.user_id = bu.id
        WHERE ro.id = ?
    ");
    
    $stmt->execute([$offerId]);
    $offer = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$offer) {
        Response::error('出租信息不存在', $errorCodes['RENTAL_OFFER_NOT_FOUND']);
    }

    // 如果是公开市场访问（未登录或非本人），只能查看上架中的
    // 如果是本人访问，可以查看任何状态
    $isOwner = false;
    
    // 尝试获取当前用户身份（如果有Token）
    $token = $_SERVER['HTTP_X_TOKEN'] ?? $_SERVER['HTTP_AUTHORIZATION'] ?? '';
    if ($token) {
        require_once __DIR__ . '/../../../core/AuthMiddleware.php';
        require_once __DIR__ . '/../../../core/Token.php';
        
        try {
            $auth = new AuthMiddleware($db);
            $user = $auth->authenticateAny();
            
            // 判断是否为发布者本人
            if ($user['user_id'] == $offer['user_id'] && $user['type'] == $offer['user_type']) {
                $isOwner = true;
            }
        } catch (Exception $e) {
            // Token无效或过期，作为游客访问
        }
    }

    // 非本人访问，只能查看上架中的
    if (!$isOwner && $offer['status'] != 1) {
        Response::error('出租信息不存在或已下架', $errorCodes['RENTAL_OFFER_NOT_FOUND']);
    }

    // 增加浏览次数（仅非本人访问时）
    if (!$isOwner) {
        $updateStmt = $db->prepare("
            UPDATE rental_offers 
            SET view_count = view_count + 1 
            WHERE id = ?
        ");
        $updateStmt->execute([$offerId]);
        $offer['view_count'] = $offer['view_count'] + 1;
    }

    // 解析 JSON 数据
    $contentJson = null;
    if (!empty($offer['content_json'])) {
        $contentJson = json_decode($offer['content_json'], true);
    }

    // 格式化返回数据
    $result = [
        'id' => (int)$offer['id'],
        'user_id' => (int)$offer['user_id'],
        'user_type' => (int)$offer['user_type'],
        'user_type_text' => $offer['user_type'] == 1 ? 'C端' : 'B端',
        'publisher_username' => $offer['publisher_username'] ?? '未知',
        'publisher_email' => $offer['publisher_email'] ?? '',
        'title' => $offer['title'],
        'price_per_day' => (int)$offer['price_per_day'],
        'price_per_day_yuan' => number_format($offer['price_per_day'] / 100, 2),
        'min_days' => (int)$offer['min_days'],
        'max_days' => (int)$offer['max_days'],
        'allow_renew' => (int)$offer['allow_renew'],
        'allow_renew_text' => $offer['allow_renew'] == 1 ? '允许续租' : '不允许续租',
        'content_json' => $contentJson,
        'status' => (int)$offer['status'],
        'status_text' => $offer['status'] == 0 ? '已下架' : ($offer['status'] == 1 ? '上架中' : '已封禁'),
        'view_count' => (int)$offer['view_count'],
        'created_at' => $offer['created_at'],
        'updated_at' => $offer['updated_at'],
        'is_owner' => $isOwner
    ];

    Response::success($result, '获取成功');

} catch (Exception $e) {
    error_log('Rental offer detail failed: ' . $e->getMessage());
    Response::error('获取详情失败，请稍后重试', 1002);
}
