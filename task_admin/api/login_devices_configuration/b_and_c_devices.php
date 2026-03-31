<?php
/**
 * B端和C端用户登录设备配置获取接口
 * 
 * GET /task_admin/api/login_devices_configuration/b_and_c_devices.php
 * 
 * 响应示例（成功）：
 * {
 *   "code": 0,
 *   "message": "获取设备配置成功",
 *   "data": {
 *     "current_config": {
 *       "c_user_login_max_devices": 2,
 *       "b_user_login_max_devices": 2
 *     }
 *   },
 *   "timestamp": 1736582400
 * }
 * 
 * 响应示例（失败）：
 * {
 *   "code": 1001,
 *   "message": "获取配置失败",
 *   "data": {},
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

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 数据库连接
try {
    $db = Database::connect();
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'code' => $errorCodes['SYSTEM_ERROR'],
        'message' => '数据库连接失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 查询 C端用户最大登录设备数配置
    $stmt = $db->prepare("SELECT config_value FROM app_config WHERE config_key = 'c_user_login_max_devices'");
    $stmt->execute();
    $cUserMaxDevices = $stmt->fetchColumn();
    $cUserMaxDevices = $cUserMaxDevices ? (int)$cUserMaxDevices : 0; // 默认值为1
    
    // 查询 B端用户最大登录设备数配置
    $stmt = $db->prepare("SELECT config_value FROM app_config WHERE config_key = 'b_user_login_max_devices'");
    $stmt->execute();
    $bUserMaxDevices = $stmt->fetchColumn();
    $bUserMaxDevices = $bUserMaxDevices ? (int)$bUserMaxDevices : 0; // 默认值为1
    
    // 返回成功响应
    Response::success([
        'current_config' => [
            'c_user_login_max_devices' => $cUserMaxDevices,
            'b_user_login_max_devices' => $bUserMaxDevices
        ]
    ], '获取设备配置成功');
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'code' => $errorCodes['SYSTEM_ERROR'],
        'message' => '获取配置失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
