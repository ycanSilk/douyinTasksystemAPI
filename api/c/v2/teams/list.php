<?php
/**
 * 团队列表接口
 * 
 * GET /api/c/v2/teams/list
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * 返回结果：
 * {
 *   "code": 0,
 *   "message": "成功",
 *   "data": {
 *     "teams": [
 *       {
 *         "team_id": "uuid",
 *         "team_name": "团队名称",
 *         "creator_id": 1,
 *         "creator_name": "创建者名称",
 *         "role": 1,
 *         "role_text": "团长",
 *         "member_count": 10,
 *         "status": 1,
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

try {
    // 查询用户所属的团队
    $stmt = $db->prepare("SELECT
        t.id as team_id,
        t.team_name,
        t.creator_id,
        c.username as creator_name,
        utr.role,
        CASE utr.role WHEN 1 THEN '团长' WHEN 2 THEN '成员' END as role_text,
        (SELECT COUNT(*) FROM user_team_relations WHERE team_id = t.id AND status = 1) as member_count,
        t.status,
        t.created_at
    FROM teams t
    JOIN user_team_relations utr ON t.id = utr.team_id
    JOIN c_users c ON t.creator_id = c.id
    WHERE utr.user_id = ? AND utr.status = 1 AND t.status = 1
    ORDER BY t.created_at DESC");
    
    $stmt->execute([$currentUser['user_id']]);
    $teams = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    Response::success(['teams' => $teams], '团队列表查询成功');
    
} catch (PDOException $e) {
    Response::error('查询失败', $errorCodes['SERVER_ERROR'], 500);
}