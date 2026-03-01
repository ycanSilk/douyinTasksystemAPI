<?php
/**
 * Admin - 更新配置
 * POST /task_admin/api/config/update.php
 * 
 * 请求体：
 * {
 *   "config_key": "c_withdraw_min_amount",
 *   "config_value": "100"
 * }
 */

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';
require_once __DIR__ . '/../../../core/AppConfig.php';

header('Content-Type: application/json; charset=utf-8');

// Admin验证
AdminAuthMiddleware::authenticate();

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 获取POST数据
$input = json_decode(file_get_contents('php://input'), true);
$configKey = trim($input['config_key'] ?? '');
$configValue = $input['config_value'] ?? '';

// 参数校验
if (empty($configKey)) {
    Response::error('配置键名不能为空', $errorCodes['INVALID_PARAMS']);
}

try {
    $db = Database::connect();
    
    // 查询配置信息
    $stmt = $db->prepare("SELECT id, config_type FROM app_config WHERE config_key = ?");
    $stmt->execute([$configKey]);
    $config = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$config) {
        Response::error('配置不存在', $errorCodes['INVALID_PARAMS']);
    }
    
    // 根据类型验证和转换值
    $valueStr = '';
    switch ($config['config_type']) {
        case 'int':
            if (!is_numeric($configValue)) {
                Response::error('配置值必须是整数', $errorCodes['INVALID_PARAMS']);
            }
            $valueStr = strval(intval($configValue));
            break;
            
        case 'float':
            if (!is_numeric($configValue)) {
                Response::error('配置值必须是数字', $errorCodes['INVALID_PARAMS']);
            }
            $valueStr = strval(floatval($configValue));
            break;
            
        case 'boolean':
            $valueStr = $configValue ? '1' : '0';
            break;
            
        case 'array':
            if (is_array($configValue)) {
                $valueStr = implode(',', $configValue);
            } else {
                $valueStr = strval($configValue);
            }
            break;
            
        case 'json':
            if (is_array($configValue) || is_object($configValue)) {
                $valueStr = json_encode($configValue, JSON_UNESCAPED_UNICODE);
            } else {
                $valueStr = $configValue;
            }
            break;
            
        default:
            $valueStr = strval($configValue);
    }
    
    // 更新配置
    $updateStmt = $db->prepare("UPDATE app_config SET config_value = ? WHERE config_key = ?");
    $updateStmt->execute([$valueStr, $configKey]);
    
    // 清除缓存
    AppConfig::clearCache();
    
    Response::success([
        'config_key' => $configKey,
        'config_value' => $valueStr,
        'updated_at' => date('Y-m-d H:i:s')
    ], '配置更新成功');
    
} catch (Exception $e) {
    error_log("更新配置错误: " . $e->getMessage());
    Response::error('更新配置失败: ' . $e->getMessage(), $errorCodes['SYSTEM_ERROR'] ?? 5000);
}
