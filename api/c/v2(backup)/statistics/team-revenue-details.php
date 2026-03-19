<?php
/**
 * 团队收益记录明细接口
 * 
 * GET /api/c/v1/statistics/team-revenue-details
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * 请求参数：
 * - period: 时间周期，可选值：1（1天）、7（7天）、30（30天）
 * - username: 团队用户名（可选）
 * - user_id: 团队用户ID（可选）
 * - page: 页码，默认1
 * - limit: 每页数量，默认20
 * 
 * 返回结果：
 * {
 *   "code": 0,
 *   "message": "成功",
 *   "data": {
 *     "total": 100,
 *     "page": 1,
 *     "limit": 20,
 *     "list": [
 *       {
 *         "id": 1,
 *         "team_user_id": 1001,
 *         "team_username": "user1",
 *         "revenue_type": 1,
 *         "revenue_type_text": "任务收益",
 *         "task_type": 1,
 *         "task_type_text": "上评评论",
 *         "task_stage": 1,
 *         "task_stage_text": "阶段1",
 *         "order_type": null,
 *         "order_type_text": null,
 *         "amount": 100,
 *         "related_id": 123,
 *         "level": 1,
 *         "created_at": "2026-03-16 12:00:00"
 *       }
 *     ]
 *   },
 *   "timestamp": 1620000000
 * }
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

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

// 获取请求参数
$period = intval($_GET['period'] ?? 7);
$username = trim($_GET['username'] ?? '');
$userId = intval($_GET['user_id'] ?? 0);
$page = intval($_GET['page'] ?? 1);
$limit = intval($_GET['limit'] ?? 20);

// 验证时间周期参数
if (!in_array($period, [1, 7, 30])) {
    Response::error('时间周期参数错误，只能是 1、7 或 30', $errorCodes['INVALID_PARAMS']);
}

// 计算时间范围
$startTime = date('Y-m-d H:i:s', strtotime("-{$period} days"));
$endTime = date('Y-m-d H:i:s');

// 计算分页偏移量
$offset = ($page - 1) * $limit;

try {
    // 构建查询条件
    $whereConditions = [
        'agent_user_id = ?',
        'created_at BETWEEN ? AND ?'
    ];
    $params = [
        $currentUser['user_id'],
        $startTime,
        $endTime
    ];
    
    if (!empty($username)) {
        $whereConditions[] = 'team_username LIKE ?';
        $params[] = '%' . $username . '%';
    }
    
    if ($userId > 0) {
        $whereConditions[] = 'team_user_id = ?';
        $params[] = $userId;
    }
    
    $whereClause = implode(' AND ', $whereConditions);
    
    // 查询总数
    $countStmt = $db->prepare("SELECT COUNT(*) as total FROM team_revenue_statistics_breakdown WHERE {$whereClause}");
    $countStmt->execute($params);
    $total = $countStmt->fetchColumn();
    
    // 查询明细数据
    $listStmt = $db->prepare("SELECT
        id,
        team_user_id,
        team_username,
        revenue_type,
        revenue_type_text,
        task_type,
        task_type_text,
        task_stage,
        task_stage_text,
        order_type,
        order_type_text,
        amount,
        related_id,
        level,
        created_at
    FROM team_revenue_statistics_breakdown
    WHERE {$whereClause}
    ORDER BY created_at DESC
    LIMIT ? OFFSET ?");
    
    $listParams = array_merge($params, [$limit, $offset]);
    $listStmt->execute($listParams);
    $list = $listStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 构建返回结果
    $result = [
        'total' => intval($total),
        'page' => $page,
        'limit' => $limit,
        'list' => $list
    ];
    
    Response::success($result, '团队收益记录明细查询成功');
    
} catch (PDOException $e) {
    Response::error('查询失败', $errorCodes['SERVER_ERROR'], 500);
}
