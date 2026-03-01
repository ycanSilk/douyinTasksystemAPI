<?php
/**
 * C端用户下线列表接口
 * 
 * GET /api/c/v1/agent/downlines
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * 查询参数（可选）：
 * - page: 页码（默认1）
 * - page_size: 每页数量（默认20）
 * 
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "ok",
 *   "data": {
 *     "list": [
 *       {
 *         "username": "downline_user",
 *         "email": "user@example.com",
 *         "completed_tasks": 25,
 *         "created_at": "2026-01-10 15:00:00"
 *       }
 *     ],
 *     "pagination": {
 *       "page": 1,
 *       "page_size": 20,
 *       "total": 10,
 *       "total_pages": 1
 *     }
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

// 获取分页参数
$page = max(1, (int)($_GET['page'] ?? 1));
$pageSize = min(100, max(1, (int)($_GET['page_size'] ?? 20)));
$offset = ($page - 1) * $pageSize;

try {
    // 1. 查询总记录数
    $stmt = $db->prepare("
        SELECT COUNT(*) as total
        FROM c_users
        WHERE parent_id = ?
    ");
    $stmt->execute([$currentUser['user_id']]);
    $totalCount = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 2. 查询下线列表（分页）
    $stmt = $db->prepare("
        SELECT 
            u.username,
            u.email,
            u.created_at,
            COUNT(c.id) as completed_tasks
        FROM c_users u
        LEFT JOIN c_task_records c ON u.id = c.c_user_id AND c.status = 3
        WHERE u.parent_id = ?
        GROUP BY u.id
        ORDER BY u.created_at DESC
        LIMIT ? OFFSET ?
    ");
    $stmt->execute([$currentUser['user_id'], $pageSize, $offset]);
    $downlines = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 3. 格式化列表
    $formattedList = [];
    foreach ($downlines as $downline) {
        $formattedList[] = [
            'username' => $downline['username'],
            'email' => $downline['email'],
            'completed_tasks' => (int)$downline['completed_tasks'],
            'created_at' => $downline['created_at']
        ];
    }
    
    // 4. 计算总页数
    $totalPages = $totalCount > 0 ? (int)ceil($totalCount / $pageSize) : 0;
    
    // 5. 返回成功响应
    Response::success([
        'list' => $formattedList,
        'pagination' => [
            'page' => $page,
            'page_size' => $pageSize,
            'total' => $totalCount,
            'total_pages' => $totalPages
        ]
    ]);
    
} catch (PDOException $e) {
    Response::error('查询失败', $errorCodes['DATABASE_ERROR'], 500);
}
