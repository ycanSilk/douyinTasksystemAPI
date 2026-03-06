<?php
/**
 * 角色权限模板配置接口
 * POST /task_admin/api/system_permission_template/role_permissions.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// 处理OPTIONS预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 只允许POST请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';

// Token 认证
AdminAuthMiddleware::authenticate();

// 数据库连接
$db = Database::connect();

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$role_id = (int)($input['role_id'] ?? 0);
$template_ids = $input['template_ids'] ?? [];

// 参数校验
if (empty($role_id)) {
    echo json_encode([
        'code' => 1002,
        'message' => '角色ID不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 检查角色是否存在
    $stmt = $db->prepare("SELECT id FROM system_roles WHERE id = ? AND status = 1");
    $stmt->execute([$role_id]);
    if (!$stmt->fetch()) {
        echo json_encode([
            'code' => 1003,
            'message' => '角色不存在或已禁用',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 开启事务
    $db->beginTransaction();
    
    // 删除原有权限模板
    $stmt = $db->prepare("DELETE FROM system_role_permission_template WHERE role_id = ?");
    $stmt->execute([$role_id]);
    
    // 添加新权限模板
    if (!empty($template_ids)) {
        $insertSql = "INSERT INTO system_role_permission_template (role_id, template_id) VALUES ";
        $values = [];
        $params = [];
        
        foreach ($template_ids as $template_id) {
            $values[] = "(?, ?)";
            $params[] = $role_id;
            $params[] = $template_id;
        }
        
        $insertSql .= implode(", ", $values);
        $stmt = $db->prepare($insertSql);
        $stmt->execute($params);
    }
    
    // 提交事务
    $db->commit();
    
    echo json_encode([
        'code' => 0,
        'message' => '权限模板配置成功',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    http_response_code(500);
    echo json_encode([
        'code' => 5000,
        'message' => '数据库操作失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
