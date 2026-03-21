<?php
/**
 * 团队收益统计接口
 * 
 * GET /api/c/v1/statistics/team-revenue
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * 请求参数：
 * - period: 时间周期，可选值：1（1天）、7（7天）、30（30天）
 * 
 * 返回结果：
 * {
 *   "code": 0,
 *   "message": "成功",
 *   "data": {
 *     "task_revenue": 1000, // 评论任务收益（单位：分）
 *     "rental_revenue": 2000, // 账号租赁收益（单位：分）
 *     "total_revenue": 3000 // 总收益（单位：分）
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

// 验证时间周期参数
if (!in_array($period, [1, 7, 30])) {
    Response::error('时间周期参数错误，只能是 1、7 或 30', $errorCodes['INVALID_PARAMS']);
}

// 计算时间范围
$startTime = date('Y-m-d H:i:s', strtotime("-{$period} days"));
$endTime = date('Y-m-d H:i:s');

try {
    // 查询团队收益统计
    $stmt = $db->prepare("SELECT
        SUM(CASE WHEN revenue_type = 1 THEN amount ELSE 0 END) as task_revenue,
        SUM(CASE WHEN revenue_type = 2 THEN amount ELSE 0 END) as rental_revenue,
        SUM(amount) as total_revenue
    FROM team_revenue_statistics_breakdown
    WHERE agent_user_id = ?
    AND created_at BETWEEN ? AND ?");
    
    $stmt->execute([$currentUser['user_id'], $startTime, $endTime]);
    $statistics = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // 格式化结果
    $result = [
        'task_revenue' => intval($statistics['task_revenue'] ?? 0),
        'rental_revenue' => intval($statistics['rental_revenue'] ?? 0),
        'total_revenue' => intval($statistics['total_revenue'] ?? 0)
    ];
    
    Response::success($result, '团队收益统计查询成功');
    
} catch (PDOException $e) {
    Response::error('查询失败', $errorCodes['SERVER_ERROR'], 500);
}
