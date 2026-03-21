<?php
/**
 * 查看工单列表
 * GET /api/rental/tickets/list?page=1&page_size=10&role=all&status=0
 * 
 * 请求头：
 * X-Token: <token> (B端或C端)
 * 
 * 请求参数：
 * - page: 页码（选填，默认1）
 * - page_size: 每页条数（选填，默认10，最大50）
 * - role: 角色过滤（选填）creator=我创建的, participant=我参与的（作为卖方）, all=全部
 * - status: 状态过滤（选填）0=待处理, 1=处理中, 2=已解决, 3=已关闭, all=全部状态
 * 
 * 响应示例：
 * {
 *   "code": 200,
 *   "message": "获取成功",
 *   "data": {
 *     "list": [
 *       {
 *         "ticket_id": 1,
 *         "ticket_no": "TK20260114123456",
 *         "title": "账号无法登录",
 *         "status": 0,
 *         "status_text": "待处理",
 *         "order_id": 123,
 *         "is_creator": true,
 *         "my_role": "buyer",
 *         "message_count": 3,
 *         "unread_count": 1,
 *         "created_at": "2026-01-14 12:34:56"
 *       }
 *     ],
 *     "pagination": {
 *       "page": 1,
 *       "page_size": 10,
 *       "total": 1,
 *       "total_pages": 1
 *     }
 *   },
 *   "timestamp": 1737123456
 * }
 * 
 * 权限：查看自己创建或参与的工单
 */

require_once __DIR__ . '/../../../config/database.php';
require_once __DIR__ . '/../../../config/error_codes.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';

header('Content-Type: application/json; charset=utf-8');

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// 身份验证（B/C端共用）
$auth = new AuthMiddleware($db);
$user = $auth->authenticateAny();
$userId = $user['user_id'];
$userType = $user['type']; // 1=C端, 2=B端

// 获取参数
$page = max(1, intval($_GET['page'] ?? 1));
$pageSize = min(50, max(1, intval($_GET['page_size'] ?? 10)));
$role = trim($_GET['role'] ?? 'all'); // creator, participant, all
$statusRaw = isset($_GET['status']) ? trim($_GET['status']) : null;
$statusFilter = ($statusRaw === null || $statusRaw === 'all') ? null : intval($statusRaw);

// 验证参数
if (!in_array($role, ['creator', 'participant', 'all'])) {
    Response::error('role参数无效，仅支持：creator, participant, all', $errorCodes['INVALID_PARAMS']);
}

if ($statusRaw !== null && $statusRaw !== 'all' && !in_array($statusFilter, [0, 1, 2, 3])) {
    Response::error('status参数无效，仅支持：0, 1, 2, 3, all', $errorCodes['INVALID_PARAMS']);
}

try {
    $userTypeStr = ($userType === 1) ? 'c' : 'b';

    // 构建查询条件
    $conditions = [];
    $params = [];

    // 角色条件
    if ($role === 'creator') {
        // 我创建的工单（我是买方）
        $conditions[] = "(rt.creator_user_id = ? AND rt.creator_user_type = ?)";
        $params[] = $userId;
        $params[] = $userType;
    } elseif ($role === 'participant') {
        // 我参与的工单（我是卖方）
        $conditions[] = "(ro.seller_user_id = ? AND (ro.seller_user_type = ? OR ro.seller_user_type = ?))";
        $params[] = $userId;
        $params[] = $userTypeStr;
        $params[] = strval($userType);
        $conditions[] = "(rt.creator_user_id != ? OR rt.creator_user_type != ?)";
        $params[] = $userId;
        $params[] = $userType;
    } else {
        // 全部：我创建的 或 我参与的
        $conditions[] = "((rt.creator_user_id = ? AND rt.creator_user_type = ?) OR (ro.seller_user_id = ? AND (ro.seller_user_type = ? OR ro.seller_user_type = ?)))";
        $params[] = $userId;
        $params[] = $userType;
        $params[] = $userId;
        $params[] = $userTypeStr;
        $params[] = strval($userType);
    }

    // 状态条件
    if ($statusFilter !== null) {
        $conditions[] = "rt.status = ?";
        $params[] = $statusFilter;
    }

    $whereClause = 'WHERE ' . implode(' AND ', $conditions);

    // 查询总数
    $countSql = "
        SELECT COUNT(*) as total
        FROM rental_tickets rt
        INNER JOIN rental_orders ro ON rt.order_id = ro.id
        {$whereClause}
    ";
    $countStmt = $db->prepare($countSql);
    $countStmt->execute($params);
    $total = intval($countStmt->fetch(PDO::FETCH_ASSOC)['total']);

    $totalPages = $total > 0 ? ceil($total / $pageSize) : 1;
    $offset = ($page - 1) * $pageSize;

    // 查询数据
    $dataSql = "
        SELECT 
            rt.id, rt.ticket_no, rt.order_id, rt.title, rt.description, 
            rt.status, rt.creator_user_id, rt.creator_user_type, 
            rt.created_at, rt.updated_at, rt.closed_at,
            ro.buyer_user_id, ro.buyer_user_type, ro.seller_user_id, ro.seller_user_type,
            ro.total_amount, ro.days, ro.status as order_status,
            CASE 
                WHEN ro.buyer_user_type = 'c' OR ro.buyer_user_type = '1' THEN COALESCE(cu_buyer.username, '未知用户')
                ELSE COALESCE(bu_buyer.username, '未知用户')
            END as buyer_username,
            CASE 
                WHEN ro.seller_user_type = 'c' OR ro.seller_user_type = '1' THEN COALESCE(cu_seller.username, '未知用户')
                ELSE COALESCE(bu_seller.username, '未知用户')
            END as seller_username,
            (SELECT COUNT(*) FROM rental_ticket_messages WHERE ticket_id = rt.id) as message_count,
            (SELECT COUNT(*) FROM rental_ticket_messages WHERE ticket_id = rt.id AND is_read = 0) as unread_count
        FROM rental_tickets rt
        INNER JOIN rental_orders ro ON rt.order_id = ro.id
        LEFT JOIN c_users cu_buyer ON (ro.buyer_user_type = 'c' OR ro.buyer_user_type = '1') AND ro.buyer_user_id = cu_buyer.id
        LEFT JOIN b_users bu_buyer ON (ro.buyer_user_type = 'b' OR ro.buyer_user_type = '2') AND ro.buyer_user_id = bu_buyer.id
        LEFT JOIN c_users cu_seller ON (ro.seller_user_type = 'c' OR ro.seller_user_type = '1') AND ro.seller_user_id = cu_seller.id
        LEFT JOIN b_users bu_seller ON (ro.seller_user_type = 'b' OR ro.seller_user_type = '2') AND ro.seller_user_id = bu_seller.id
        {$whereClause}
        ORDER BY rt.created_at DESC
        LIMIT {$pageSize} OFFSET {$offset}
    ";
    $dataStmt = $db->prepare($dataSql);
    $dataStmt->execute($params);
    $tickets = $dataStmt->fetchAll(PDO::FETCH_ASSOC);

    // 格式化数据
    $statusText = [0 => '待处理', 1 => '处理中', 2 => '已解决', 3 => '已关闭'];
    $orderStatusText = [0 => '待支付', 1 => '待客服', 2 => '进行中', 3 => '已完成', 4 => '已取消'];

    $formattedTickets = array_map(function($ticket) use ($userId, $userType, $userTypeStr, $statusText, $orderStatusText) {
        // 判断当前用户角色
        $isBuyer = ($ticket['buyer_user_id'] == $userId && 
                    ($ticket['buyer_user_type'] === $userTypeStr || intval($ticket['buyer_user_type']) === $userType));
        $isSeller = ($ticket['seller_user_id'] == $userId && 
                     ($ticket['seller_user_type'] === $userTypeStr || intval($ticket['seller_user_type']) === $userType));
        
        return [
            'ticket_id' => intval($ticket['id']),
            'ticket_no' => $ticket['ticket_no'],
            'title' => $ticket['title'],
            'description' => mb_substr($ticket['description'], 0, 100) . (mb_strlen($ticket['description']) > 100 ? '...' : ''),
            'status' => intval($ticket['status']),
            'status_text' => $statusText[$ticket['status']] ?? '未知',
            'order_id' => intval($ticket['order_id']),
            'order_amount' => number_format($ticket['total_amount'] / 100, 2),
            'order_days' => intval($ticket['days']),
            'order_status' => intval($ticket['order_status']),
            'order_status_text' => $orderStatusText[$ticket['order_status']] ?? '未知',
            'buyer_username' => $ticket['buyer_username'],
            'seller_username' => $ticket['seller_username'],
            'is_creator' => $ticket['creator_user_id'] == $userId,
            'my_role' => $isBuyer ? 'buyer' : 'seller',
            'message_count' => intval($ticket['message_count']),
            'unread_count' => intval($ticket['unread_count']),
            'created_at' => $ticket['created_at'],
            'updated_at' => $ticket['updated_at'],
            'closed_at' => $ticket['closed_at']
        ];
    }, $tickets);

    Response::success([
        'list' => $formattedTickets,
        'pagination' => [
            'page' => $page,
            'page_size' => $pageSize,
            'total' => $total,
            'total_pages' => $totalPages
        ]
    ], '获取成功');

} catch (PDOException $e) {
    Response::error('获取工单列表失败：' . $e->getMessage(), $errorCodes['SYSTEM_ERROR']);
} catch (Exception $e) {
    Response::error($e->getMessage(), $errorCodes['SYSTEM_ERROR']);
}
