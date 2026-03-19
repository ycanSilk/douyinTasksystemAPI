<?php
/**
 * C端用户团长申请列表接口
 * 
 * GET /api/c/v1/agent/applications
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * 返回数据（不分页，最新在上）：
 * {
 *   "code": 0,
 *   "message": "ok",
 *   "data": {
 *     "list": [
 *       {
 *         "id": 123,
 *         "valid_invites": 6,
 *         "total_invites": 10,
 *         "status": 0,
 *         "status_text": "待审核",
 *         "reject_reason": null,
 *         "reviewed_at": null,
 *         "created_at": "2026-01-11 15:00:00",
 *         "updated_at": "2026-01-11 15:00:00"
 *       }
 *     ],
 *     "total": 3
 *   },
 *   "timestamp": 1736582400
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

try {
    // 查询申请记录（不分页，最新在上）
    $stmt = $db->prepare("
        SELECT 
            id,
            valid_invites,
            total_invites,
            status,
            reject_reason,
            reviewed_at,
            created_at,
            updated_at
        FROM agent_applications
        WHERE c_user_id = ?
        ORDER BY created_at DESC
    ");
    $stmt->execute([$currentUser['user_id']]);
    $applications = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 状态文本映射
    $statusTexts = [
        0 => '待审核',
        1 => '审核通过',
        2 => '审核拒绝'
    ];
    
    // 格式化列表
    $formattedList = [];
    foreach ($applications as $app) {
        $formattedList[] = [
            'id' => (int)$app['id'],
            'valid_invites' => (int)$app['valid_invites'],
            'total_invites' => (int)$app['total_invites'],
            'status' => (int)$app['status'],
            'status_text' => $statusTexts[(int)$app['status']] ?? '未知',
            'reject_reason' => $app['reject_reason'],
            'reviewed_at' => $app['reviewed_at'],
            'created_at' => $app['created_at'],
            'updated_at' => $app['updated_at']
        ];
    }
    
    // 返回成功响应
    Response::success([
        'list' => $formattedList,
        'total' => count($formattedList)
    ]);
    
} catch (PDOException $e) {
    Response::error('查询失败', $errorCodes['DATABASE_ERROR'], 500);
}
