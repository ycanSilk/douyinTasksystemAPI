<?php
/**
 * C端用户登录设备配置接口
 * 
 * POST /task_admin/api/login_devices_configuration/c_users.php
 * 
 * 请求参数：
 * - max_devices: 最大允许登录设备数量（整数，1-10）
 * 
 * 响应示例（成功）：
 * {
 *   "code": 0,
 *   "message": "C端用户设备配置更新成功",
 *   "data": {
 *     "max_devices": 2
 *   },
 *   "timestamp": 1736582400
 * }
 * 
 * 响应示例（失败）：
 * {
 *   "code": 1001,
 *   "message": "参数错误",
 *   "data": {},
 *   "timestamp": 1736582400
 * }
 */

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
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

// 获取请求数据
$input = json_decode(file_get_contents('php://input'), true);
$maxDevices = intval($input['max_devices'] ?? 0);

// 验证参数
if ($maxDevices < 0) {
    http_response_code(400);
    echo json_encode([
        'code' => 1002,
        'message' => '设备数量不能小于0',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

try {
    // 开启事务
    $db->beginTransaction();
    
    // 设置C端用户的最大设备数量为0（不限制）
    $stmt = $db->prepare("UPDATE c_users SET max_devices = 0");
    $stmt->execute();
    
    // 更新 app_config 表中的配置值为0（不限制）
    $stmt = $db->prepare("UPDATE app_config SET config_value = 0 WHERE config_key = 'c_user_login_max_devices'");
    $stmt->execute();
    
    // 提交事务
    $db->commit();
    
    // 返回成功响应
    Response::success([
        'max_devices' => 0,
        'message' => '已设置为不限制登录设备数量'
    ], 'C端用户设备配置更新成功');
    
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    http_response_code(500);
    echo json_encode([
        'code' => $errorCodes['SYSTEM_ERROR'],
        'message' => '服务器错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
