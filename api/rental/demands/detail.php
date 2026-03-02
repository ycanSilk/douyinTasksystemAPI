<?php
/**
 * 求租信息详情接口
 * 
 * GET /api/rental/demands/detail
 * 
 * 请求参数：
 * - demand_id: 求租信息ID（必填）
 * 
 * 示例：
 * GET /api/rental/demands/detail?demand_id=1
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
$demandId = intval($_GET['demand_id'] ?? 0);

// 参数校验
if ($demandId <= 0) {
    Response::error('求租信息ID无效', $errorCodes['RENTAL_DEMAND_NOT_FOUND']);
}

try {
    // 查询求租信息详情
    $stmt = $db->prepare("
        SELECT 
            rd.id,
            rd.user_id,
            rd.user_type,
            rd.wallet_id,
            rd.title,
            rd.budget_amount,
            rd.days_needed,
            rd.deadline,
            rd.requirements_json,
            rd.status,
            rd.view_count,
            rd.created_at,
            rd.updated_at,
            CASE 
                WHEN rd.user_type = 1 THEN cu.username
                WHEN rd.user_type = 2 THEN bu.username
            END as publisher_username,
            CASE 
                WHEN rd.user_type = 1 THEN cu.email
                WHEN rd.user_type = 2 THEN bu.email
            END as publisher_email,
            (SELECT COUNT(*) FROM rental_applications WHERE demand_id = rd.id) as application_count
        FROM rental_demands rd
        LEFT JOIN c_users cu ON rd.user_type = 1 AND rd.user_id = cu.id
        LEFT JOIN b_users bu ON rd.user_type = 2 AND rd.user_id = bu.id
        WHERE rd.id = ?
    ");
    
    $stmt->execute([$demandId]);
    $demand = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$demand) {
        Response::error('求租信息不存在', $errorCodes['RENTAL_DEMAND_NOT_FOUND']);
    }

    // 如果是公开市场访问（未登录或非本人），只能查看发布中且未过期的
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
            if ($user['user_id'] == $demand['user_id'] && $user['type'] == $demand['user_type']) {
                $isOwner = true;
            }
        } catch (Exception $e) {
            // Token无效或过期，作为游客访问
        }
    }

    // 非本人访问，只能查看发布中且未过期的
    if (!$isOwner) {
        if ($demand['status'] != 1 || strtotime($demand['deadline']) < time()) {
            Response::error('求租信息不存在或已过期', $errorCodes['RENTAL_DEMAND_NOT_FOUND']);
        }
    }

    // 增加浏览次数（仅非本人访问时）
    if (!$isOwner) {
        $updateStmt = $db->prepare("
            UPDATE rental_demands 
            SET view_count = view_count + 1 
            WHERE id = ?
        ");
        $updateStmt->execute([$demandId]);
        $demand['view_count'] = $demand['view_count'] + 1;
    }

    // 解析 JSON 数据
    $requirementsJson = null;
    if (!empty($demand['requirements_json'])) {
        $requirementsJson = json_decode($demand['requirements_json'], true);
    }

    // 状态文本
    $statusTexts = [
        0 => '已下架',
        1 => '发布中',
        2 => '已成交',
        3 => '已过期'
    ];

    // 格式化返回数据
    $result = [
        'id' => (int)$demand['id'],
        'user_id' => (int)$demand['user_id'],
        'user_type' => (int)$demand['user_type'],
        'user_type_text' => $demand['user_type'] == 1 ? 'C端' : 'B端',
        'publisher_username' => $demand['publisher_username'] ?? '未知',
        'publisher_email' => $demand['publisher_email'] ?? '',
        'title' => $demand['title'],
        'budget_amount' => (int)$demand['budget_amount'],
        'budget_amount_yuan' => number_format($demand['budget_amount'] / 100, 2),
        'days_needed' => (int)$demand['days_needed'],
        'deadline' => strtotime($demand['deadline']),
        'deadline_datetime' => $demand['deadline'],
        'requirements_json' => $requirementsJson,
        'status' => (int)$demand['status'],
        'status_text' => $statusTexts[$demand['status']] ?? '未知',
        'view_count' => (int)$demand['view_count'],
        'application_count' => (int)$demand['application_count'],
        'created_at' => $demand['created_at'],
        'updated_at' => $demand['updated_at'],
        'is_owner' => $isOwner
    ];

    Response::success($result, '获取成功');

} catch (Exception $e) {
    error_log('Rental demand detail failed: ' . $e->getMessage());
    Response::error('获取详情失败，请稍后重试', 1002);
}
