<?php
/**
 * Admin - 获取配置列表
 * GET /task_admin/api/config/list.php
 */

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';

header('Content-Type: application/json; charset=utf-8');

// Admin验证
AdminAuthMiddleware::authenticate();

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

try {
    $db = Database::connect();
    
    // 获取筛选参数
    $group = $_GET['group'] ?? '';
    
    // 构建查询
    $sql = "SELECT id, config_key, config_value, config_type, config_group, description, updated_at 
            FROM app_config";
    $params = [];
    
    if (!empty($group)) {
        $sql .= " WHERE config_group = ?";
        $params[] = $group;
    }
    
    $sql .= " ORDER BY config_group, id";
    
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $configs = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 格式化配置值
    foreach ($configs as &$config) {
        $config['id'] = (int)$config['id'];
        // 根据类型解析值用于显示
        switch ($config['config_type']) {
            case 'int':
                $config['display_value'] = intval($config['config_value']);
                break;
            case 'float':
                $config['display_value'] = floatval($config['config_value']);
                break;
            case 'boolean':
                $config['display_value'] = filter_var($config['config_value'], FILTER_VALIDATE_BOOLEAN);
                break;
            case 'array':
                $config['display_value'] = explode(',', $config['config_value']);
                break;
            default:
                $config['display_value'] = $config['config_value'];
        }
    }
    
    Response::success(['configs' => $configs], '获取成功');
    
} catch (Exception $e) {
    error_log("获取配置列表错误: " . $e->getMessage());
    Response::error('获取配置失败: ' . $e->getMessage(), $errorCodes['SYSTEM_ERROR'] ?? 5000);
}
