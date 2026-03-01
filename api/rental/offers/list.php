<?php
/**
 * 出租市场列表接口
 * 
 * GET /api/rental/offers/list
 * 
 * 请求参数：
 * - page: 页码（默认1）
 * - page_size: 每页数量（默认20，最大100）
 * - user_type: 筛选用户类型（可选，1=C端，2=B端）
 * - my: 是否只查看我的（可选，1=是）
 * 
 * 示例：
 * GET /api/rental/offers/list?page=1&page_size=20
 * GET /api/rental/offers/list?my=1&page=1
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

// 数据库连接
$db = Database::connect();

// 获取请求参数
$page = max(1, intval($_GET['page'] ?? 1));
$pageSize = min(100, max(1, intval($_GET['page_size'] ?? 20)));
$filterUserType = isset($_GET['user_type']) && in_array($_GET['user_type'], ['1', '2']) ? intval($_GET['user_type']) : null;
$onlyMy = isset($_GET['my']) && $_GET['my'] == '1' ? true : false;

// 尝试获取当前用户身份（可选认证）
$currentUserId = null;
$currentUserType = null;
$token = $_SERVER['HTTP_X_TOKEN'] ?? $_SERVER['HTTP_AUTHORIZATION'] ?? '';

if ($token) {
    require_once __DIR__ . '/../../../core/AuthMiddleware.php';
    require_once __DIR__ . '/../../../core/Token.php';
    
    try {
        $auth = new AuthMiddleware($db);
        $user = $auth->authenticateAny();
        $currentUserId = $user['user_id'];
        $currentUserType = $user['type'];
    } catch (Exception $e) {
        // Token 无效或过期，作为游客访问
        if ($onlyMy) {
            // 如果明确要查看"我的"，但 Token 无效，则报错
            Response::error('请先登录', 2000);
        }
    }
}

// 如果要查看"我的"但未登录，则报错
if ($onlyMy && !$currentUserId) {
    Response::error('请先登录', 2000);
}

$offset = ($page - 1) * $pageSize;

try {
    // 构建查询条件
    $whereClauses = [];
    $params = [];

    // 只显示上架中的（status=1），除非是查看"我的"
    if ($onlyMy) {
        // 查看"我的"：只显示当前用户的所有状态（0/1/2）
        $whereClauses[] = "ro.user_id = ?";
        $params[] = $currentUserId;
        $whereClauses[] = "ro.user_type = ?";
        $params[] = $currentUserType;
        // 不添加 status 限制，显示所有状态
    } else {
        // 公开市场只显示上架中的
        $whereClauses[] = "ro.status = 1";
        
        // 用户类型筛选（仅在公开市场有效，避免与 onlyMy 冲突）
        if ($filterUserType !== null) {
            $whereClauses[] = "ro.user_type = ?";
            $params[] = $filterUserType;
        }
    }

    $whereSQL = !empty($whereClauses) ? 'WHERE ' . implode(' AND ', $whereClauses) : '';

    // 查询总数
    $countStmt = $db->prepare("
        SELECT COUNT(*) as total
        FROM rental_offers ro
        $whereSQL
    ");
    $countStmt->execute($params);
    $total = $countStmt->fetch(PDO::FETCH_ASSOC)['total'];

    // 查询列表数据
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
            ro.status,
            ro.content_json,
            ro.view_count,
            ro.created_at,
            ro.updated_at,
            CASE 
                WHEN ro.user_type = 1 THEN cu.username
                WHEN ro.user_type = 2 THEN bu.username
            END as publisher_username
        FROM rental_offers ro
        LEFT JOIN c_users cu ON ro.user_type = 1 AND ro.user_id = cu.id
        LEFT JOIN b_users bu ON ro.user_type = 2 AND ro.user_id = bu.id
        $whereSQL
        ORDER BY ro.created_at DESC
        LIMIT ? OFFSET ?
    ");
    
    $params[] = $pageSize;
    $params[] = $offset;
    $stmt->execute($params);
    $offers = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // 格式化数据
    $formattedOffers = array_map(function($offer) use ($currentUserId, $currentUserType) {
        // 判断是否为当前用户的信息
        $isMy = false;
        if ($currentUserId && $currentUserType) {
            $isMy = ($offer['user_id'] == $currentUserId && $offer['user_type'] == $currentUserType);
        }
        
        return [
            'id' => (int)$offer['id'],
            'user_id' => (int)$offer['user_id'],
            'user_type' => (int)$offer['user_type'],
            'user_type_text' => $offer['user_type'] == 1 ? 'C端' : 'B端',
            'publisher_username' => $offer['publisher_username'] ?? '未知',
            'title' => $offer['title'],
            'content_json' => json_decode($offer['content_json'], true),
            'price_per_day' => (int)$offer['price_per_day'],
            'price_per_day_yuan' => number_format($offer['price_per_day'] / 100, 2),
            'min_days' => (int)$offer['min_days'],
            'max_days' => (int)$offer['max_days'],
            'allow_renew' => (int)$offer['allow_renew'],
            'allow_renew_text' => $offer['allow_renew'] == 1 ? '允许续租' : '不允许续租',
            'status' => (int)$offer['status'],
            'status_text' => $offer['status'] == 0 ? '已下架' : ($offer['status'] == 1 ? '上架中' : '已封禁'),
            'view_count' => (int)$offer['view_count'],
            'created_at' => $offer['created_at'],
            'updated_at' => $offer['updated_at'],
            'is_my' => $isMy
        ];
    }, $offers);

    Response::success([
        'list' => $formattedOffers,
        'pagination' => [
            'page' => $page,
            'page_size' => $pageSize,
            'total' => (int)$total,
            'total_pages' => ceil($total / $pageSize)
        ]
    ], '获取成功');

} catch (Exception $e) {
    error_log('Rental offers list failed: ' . $e->getMessage());
    Response::error('获取列表失败，请稍后重试', 1002);
}
