<?php
/**
 * 获取C端用户列表接口
 * GET /task_admin/api/agent/c-users-list.php
 * 
 * 参数：
 * - page: 页码，默认1
 * - page_size: 每页数量，默认20
 * - username: 用户名搜索
 * - user_id: 用户ID搜索
 * 
 * 功能：
 * - 获取C端用户列表
 * - 支持按用户名和用户ID搜索
 * - 支持分页
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';

// 认证中间件
AdminAuthMiddleware::authenticate();

// 初始化数据库连接
$db = Database::connect();

try {
    // 获取请求参数
    $page = max(1, (int)($_GET['page'] ?? 1));
    $pageSize = min(100, max(1, (int)($_GET['page_size'] ?? 20)));
    $username = $_GET['username'] ?? '';
    $userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 0;

    // 构建查询条件
    $where = [];
    $params = [];

    if (!empty($username)) {
        $where[] = 'username LIKE ?';
        $params[] = '%' . $username . '%';
    }

    if ($userId > 0) {
        $where[] = 'id = ?';
        $params[] = $userId;
    }

    $whereClause = $where ? 'WHERE ' . implode(' AND ', $where) : '';

    // 计算总数
    $countSql = "SELECT COUNT(*) as total FROM c_users {$whereClause}";
    $stmt = $db->prepare($countSql);
    $stmt->execute($params);
    $total = (int)$stmt->fetchColumn();

    // 计算分页
    $offset = ($page - 1) * $pageSize;

    // 查询数据
    $sql = "SELECT id, username, is_agent, created_at FROM c_users {$whereClause} ORDER BY id DESC LIMIT ? OFFSET ?";
    $params[] = $pageSize;
    $params[] = $offset;

    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // 处理数据
    foreach ($users as &$user) {
        $user['id'] = (int)$user['id'];
        $user['is_agent'] = (int)$user['is_agent'];
        $user['agent_text'] = $user['is_agent'] === 0 ? '普通用户' : ($user['is_agent'] === 1 ? '团长' : '高级团长');
    }

    // 返回成功响应
    echo json_encode([
        'code' => 0,
        'message' => 'success',
        'data' => [
            'list' => $users,
            'page' => $page,
            'page_size' => $pageSize,
            'total' => $total,
            'total_pages' => $total > 0 ? (int)ceil($total / $pageSize) : 0
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    // 错误处理
    echo json_encode([
        'code' => 500,
        'message' => '获取用户列表失败: ' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
?>