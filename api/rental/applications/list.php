<?php
/**
 * 查看应征列表
 * GET /api/rental/applications/list?demand_id=1&page=1&page_size=20&status=0
 *
 * - 传 demand_id：查看指定求租的应征列表（仅求租发布者）
 * - 不传 demand_id：查看所有相关应征（我作为求租方收到的 + 我作为应征方提交的）
 * - my (可选)：1=仅返回我提交的应征，2=仅返回别人向我申请的应征
 * - status (可选)：按状态筛选 0=待审核 1=审核通过 2=审核驳回
 */

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['code' => 1001, 'message' => '请求方法错误', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';
$db = Database::connect();

// 认证
$auth = new AuthMiddleware($db);
$user = $auth->authenticateAny();
$userId = $user['user_id'];
$userType = $user['type'];

// 获取参数
$demandId = isset($_GET['demand_id']) ? intval($_GET['demand_id']) : null;
$statusFilter = isset($_GET['status']) ? intval($_GET['status']) : null;
$myFilter = isset($_GET['my']) ? intval($_GET['my']) : 0;
$page = max(1, intval($_GET['page'] ?? 1));
$pageSize = max(1, min(100, intval($_GET['page_size'] ?? 20)));
$offset = ($page - 1) * $pageSize;

try {
    // 模式1：查看指定求租的应征
    if ($demandId !== null && $demandId > 0) {
        // 检查求租信息是否存在
        $stmt = $db->prepare("SELECT id, user_id, user_type FROM rental_demands WHERE id = ?");
        $stmt->execute([$demandId]);
        $demand = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$demand) {
            Response::error('求租信息不存在', $errorCodes['RENTAL_DEMAND_NOT_FOUND']);
        }

        // 判断当前用户角色
        $isDemandOwner = ($demand['user_id'] == $userId && $demand['user_type'] == $userType);
        
        // 检查是否有应征记录
        $checkAppStmt = $db->prepare("
            SELECT COUNT(*) FROM rental_applications 
            WHERE demand_id = ? AND applicant_user_id = ? AND applicant_user_type = ?
        ");
        $checkAppStmt->execute([$demandId, $userId, $userType]);
        $hasApplication = $checkAppStmt->fetchColumn() > 0;

        // 既不是求租发布者，也不是应征方，无权查看
        if (!$isDemandOwner && !$hasApplication) {
            Response::error('无权查看此求租信息的应征记录', $errorCodes['RENTAL_APPLICATION_NO_PERMISSION']);
        }

        // 构建查询条件
        if ($isDemandOwner) {
            // 求租发布者：看所有应征
            $countSql = "SELECT COUNT(*) FROM rental_applications WHERE demand_id = ?";
            $countParams = [$demandId];

            if ($statusFilter !== null && in_array($statusFilter, [0, 1, 2], true)) {
                $countSql .= " AND status = ?";
                $countParams[] = $statusFilter;
            }

            $listSql = "
                SELECT
                    ra.id,
                    ra.demand_id,
                    ra.applicant_user_id,
                    ra.applicant_user_type,
                    ra.allow_renew,
                    ra.application_json,
                    ra.status,
                    ra.review_remark,
                    ra.created_at,
                    ra.reviewed_at,
                    rd.title as demand_title,
                    rd.deadline as demand_deadline,
                    rd.status as demand_status,
                    CASE
                        WHEN ra.applicant_user_type = 2 THEN bu.username
                        WHEN ra.applicant_user_type = 1 THEN cu.username
                    END as applicant_username
                FROM rental_applications ra
                LEFT JOIN rental_demands rd ON ra.demand_id = rd.id
                LEFT JOIN b_users bu ON ra.applicant_user_id = bu.id AND ra.applicant_user_type = 2
                LEFT JOIN c_users cu ON ra.applicant_user_id = cu.id AND ra.applicant_user_type = 1
                WHERE ra.demand_id = ?";
            $listParams = [$demandId];

            if ($statusFilter !== null && in_array($statusFilter, [0, 1, 2], true)) {
                $listSql .= " AND ra.status = ?";
                $listParams[] = $statusFilter;
            }

            $listSql .= "
                ORDER BY ra.created_at DESC
                LIMIT ? OFFSET ?
            ";
            $listParams[] = $pageSize;
            $listParams[] = $offset;
        } else {
            // 应征方：只看自己的应征
            $countSql = "
                SELECT COUNT(*) FROM rental_applications
                WHERE demand_id = ? AND applicant_user_id = ? AND applicant_user_type = ?
            ";
            $countParams = [$demandId, $userId, $userType];

            if ($statusFilter !== null && in_array($statusFilter, [0, 1, 2], true)) {
                $countSql .= " AND status = ?";
                $countParams[] = $statusFilter;
            }

            $listSql = "
                SELECT
                    ra.id,
                    ra.demand_id,
                    ra.applicant_user_id,
                    ra.applicant_user_type,
                    ra.allow_renew,
                    ra.application_json,
                    ra.status,
                    ra.review_remark,
                    ra.created_at,
                    ra.reviewed_at,
                    rd.title as demand_title,
                    rd.deadline as demand_deadline,
                    rd.status as demand_status,
                    CASE
                        WHEN ra.applicant_user_type = 2 THEN bu.username
                        WHEN ra.applicant_user_type = 1 THEN cu.username
                    END as applicant_username
                FROM rental_applications ra
                LEFT JOIN rental_demands rd ON ra.demand_id = rd.id
                LEFT JOIN b_users bu ON ra.applicant_user_id = bu.id AND ra.applicant_user_type = 2
                LEFT JOIN c_users cu ON ra.applicant_user_id = cu.id AND ra.applicant_user_type = 1
                WHERE ra.demand_id = ? AND ra.applicant_user_id = ? AND ra.applicant_user_type = ?";
            $listParams = [$demandId, $userId, $userType];

            if ($statusFilter !== null && in_array($statusFilter, [0, 1, 2], true)) {
                $listSql .= " AND ra.status = ?";
                $listParams[] = $statusFilter;
            }

            $listSql .= "
                ORDER BY ra.created_at DESC
                LIMIT ? OFFSET ?
            ";
            $listParams[] = $pageSize;
            $listParams[] = $offset;
        }

        // 获取应征总数
        $countStmt = $db->prepare($countSql);
        $countStmt->execute($countParams);
        $total = $countStmt->fetchColumn();

        // 获取应征列表
        $listStmt = $db->prepare($listSql);
        $listStmt->execute($listParams);
        $applications = $listStmt->fetchAll(PDO::FETCH_ASSOC);
    } 
    // 模式2：查看所有相关应征
    else {
        // 获取应征总数
        if ($myFilter === 1) {
            // my=1：仅我提交的应征
            $countSql = "
                SELECT COUNT(*) FROM rental_applications ra
                INNER JOIN rental_demands rd ON ra.demand_id = rd.id
                WHERE ra.applicant_user_id = ? AND ra.applicant_user_type = ?
            ";
            $countParams = [$userId, $userType];
        } elseif ($myFilter === 2) {
            // my=2：仅别人向我申请的应征（我发布的求租收到的）
            $countSql = "
                SELECT COUNT(*) FROM rental_applications ra
                INNER JOIN rental_demands rd ON ra.demand_id = rd.id
                WHERE rd.user_id = ? AND rd.user_type = ?
                  AND NOT (ra.applicant_user_id = ? AND ra.applicant_user_type = ?)
            ";
            $countParams = [$userId, $userType, $userId, $userType];
        } else {
            // 默认：我发布的求租收到的应征 + 我提交的应征
            $countSql = "
                SELECT COUNT(*) FROM rental_applications ra
                INNER JOIN rental_demands rd ON ra.demand_id = rd.id
                WHERE ((rd.user_id = ? AND rd.user_type = ?)
                   OR (ra.applicant_user_id = ? AND ra.applicant_user_type = ?))
            ";
            $countParams = [$userId, $userType, $userId, $userType];
        }

        if ($statusFilter !== null && in_array($statusFilter, [0, 1, 2], true)) {
            $countSql .= " AND ra.status = ?";
            $countParams[] = $statusFilter;
        }

        $countStmt = $db->prepare($countSql);
        $countStmt->execute($countParams);
        $total = $countStmt->fetchColumn();

        // 获取应征列表
        $listSql = "
            SELECT
                ra.id,
                ra.demand_id,
                ra.applicant_user_id,
                ra.applicant_user_type,
                ra.allow_renew,
                ra.application_json,
                ra.status,
                ra.review_remark,
                ra.created_at,
                ra.reviewed_at,
                rd.title as demand_title,
                rd.user_id as demand_user_id,
                rd.user_type as demand_user_type,
                rd.deadline as demand_deadline,
                rd.status as demand_status,
                CASE
                    WHEN ra.applicant_user_type = 2 THEN bu.username
                    WHEN ra.applicant_user_type = 1 THEN cu.username
                END as applicant_username,
                CASE
                    WHEN rd.user_id = ? AND rd.user_type = ? THEN 'received'
                    ELSE 'submitted'
                END as relation_type
            FROM rental_applications ra
            INNER JOIN rental_demands rd ON ra.demand_id = rd.id
            LEFT JOIN b_users bu ON ra.applicant_user_id = bu.id AND ra.applicant_user_type = 2
            LEFT JOIN c_users cu ON ra.applicant_user_id = cu.id AND ra.applicant_user_type = 1
        ";
        if ($myFilter === 1) {
            $listSql .= " WHERE ra.applicant_user_id = ? AND ra.applicant_user_type = ?";
            $listParams = [$userId, $userType, $userId, $userType];
        } elseif ($myFilter === 2) {
            $listSql .= " WHERE rd.user_id = ? AND rd.user_type = ?
               AND NOT (ra.applicant_user_id = ? AND ra.applicant_user_type = ?)";
            $listParams = [$userId, $userType, $userId, $userType, $userId, $userType];
        } else {
            $listSql .= " WHERE ((rd.user_id = ? AND rd.user_type = ?)
               OR (ra.applicant_user_id = ? AND ra.applicant_user_type = ?))";
            $listParams = [$userId, $userType, $userId, $userType, $userId, $userType];
        }

        if ($statusFilter !== null && in_array($statusFilter, [0, 1, 2], true)) {
            $listSql .= " AND ra.status = ?";
            $listParams[] = $statusFilter;
        }

        $listSql .= "
            ORDER BY ra.created_at DESC
            LIMIT ? OFFSET ?
        ";
        $listParams[] = $pageSize;
        $listParams[] = $offset;

        $listStmt = $db->prepare($listSql);
        $listStmt->execute($listParams);
        $applications = $listStmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // 格式化数据
    $formatted = array_map(function($app) use ($demandId, $userId, $userType) {
        $statusMap = [
            0 => '待审核',
            1 => '审核通过',
            2 => '审核驳回'
        ];

        // 判断求租信息是否已过期下架
        $demandExpired = false;
        if (isset($app['demand_deadline']) && isset($app['demand_status'])) {
            $demandStatus = intval($app['demand_status']);
            // status=3 已过期 或 status=0 已下架 或 deadline已过
            if ($demandStatus === 3 || $demandStatus === 0) {
                $demandExpired = true;
            } elseif ($app['demand_deadline'] && strtotime($app['demand_deadline']) < time()) {
                $demandExpired = true;
            }
        }

        // 判断是否是当前用户提交的应征
        $isMy = (intval($app['applicant_user_id']) === intval($userId)
                && intval($app['applicant_user_type']) === intval($userType));

        $result = [
            'id' => intval($app['id']),
            'demand_id' => intval($app['demand_id']),
            'demand_title' => $app['demand_title'] ?? '',
            'applicant_user_id' => intval($app['applicant_user_id']),
            'applicant_user_type' => $app['applicant_user_type'],
            'applicant_username' => $app['applicant_username'],
            'allow_renew' => intval($app['allow_renew']),
            'application_json' => json_decode($app['application_json'], true),
            'status' => intval($app['status']),
            'status_text' => $statusMap[$app['status']] ?? '未知',
            'review_remark' => $app['review_remark'],
            'is_my' => $isMy,
            'is_expired' => $demandExpired,
            'created_at' => $app['created_at'],
            'reviewed_at' => $app['reviewed_at']
        ];
        
        // 如果是全部列表模式，添加关系类型
        if ($demandId === null && isset($app['relation_type'])) {
            $result['relation_type'] = $app['relation_type']; // 'received' 或 'submitted'
            $result['relation_text'] = $app['relation_type'] === 'received' ? '收到的应征' : '我的应征';
        }
        
        return $result;
    }, $applications);

    Response::success([
        'total' => intval($total),
        'page' => $page,
        'page_size' => $pageSize,
        'list' => $formatted
    ]);

} catch (Exception $e) {
    error_log('Application list failed: ' . $e->getMessage());
    
    // 调试模式
    if (isset($_GET['debug']) && $_GET['debug'] == '1') {
        Response::error('获取应征列表失败：' . $e->getMessage(), $errorCodes['SYSTEM_ERROR']);
    }
    
    Response::error('获取应征列表失败', $errorCodes['SYSTEM_ERROR']);
}
