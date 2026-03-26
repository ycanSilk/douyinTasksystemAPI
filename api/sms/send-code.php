<?php
/**
 * 发送验证码接口
 * 
 * POST /api/sms/send-code.php
 * 
 * 请求头：
 * Content-Type: application/json
 * 
 * 请求体：
 * {
 *   "phone_number": "string (必填，手机号)"
 * }
 * 
 * 响应示例（成功）：
 * {
 *   "code": 0,
 *   "message": "验证码发送成功",
 *   "data": {
 *     "phone_number": "13800138000"
 *   },
 *   "timestamp": 1736582400
 * }
 * 
 * 响应示例（失败）：
 * {
 *   "code": 1002,
 *   "message": "手机号格式不正确",
 *   "data": [],
 *   "timestamp": 1736582400
 * }
 * 
 * 错误码说明：
 * 1001 - 请求方法错误
 * 1002 - 手机号格式不正确
 * 1003 - 验证码发送失败
 * 1004 - 手机号不能为空
 * 1005 - 缺少依赖文件
 */

// 加载统一日志系统
require_once __DIR__ . '/../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前接口上下文（必须！）
LoggerRouter::setContext('sms/send-code');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$errorLogger = LoggerFactory::getLogger('error');
$auditLogger = LoggerFactory::getLogger('audit');

// 记录请求开始
$requestLogger->info('=== 发送验证码接口调用开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 加载必要的文件
require_once __DIR__ . '/../../config/smsconf.php';
$path = __DIR__ . '/../../vendor/autoload.php';

if (file_exists($path)) {
    require_once $path;
} else {
    $errorLogger->error('缺少依赖文件');
    echo json_encode([
        'code' => 1005,
        'message' => '缺少依赖文件',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

use AlibabaCloud\SDK\Dypnsapi\V20170525\Dypnsapi;
use Darabonba\OpenApi\Models\Config;
use AlibabaCloud\SDK\Dypnsapi\V20170525\Models\SendSmsVerifyCodeRequest;
use AlibabaCloud\Tea\Utils\Utils\RuntimeOptions;

// 获取配置
$smsConfig = require __DIR__ . '/../../config/smsconf.php';

// 获取请求参数
if (isset($_SERVER['CONTENT_TYPE']) && strpos($_SERVER['CONTENT_TYPE'], 'application/json') !== false) {
    $json = file_get_contents('php://input');
    $requestLogger->debug('请求体', ['body' => $json]);
    $data = json_decode($json, true);
    $phoneNumber = trim($data['phone_number'] ?? $data['phoneNumber'] ?? '');
} else {
    $phoneNumber = trim($_POST['phone_number'] ?? $_POST['phoneNumber'] ?? '');
    $requestLogger->debug('请求参数', ['phone_number' => $phoneNumber]);
}

// 参数验证
if (empty($phoneNumber)) {
    $requestLogger->warning('手机号不能为空');
    echo json_encode([
        'code' => 1004,
        'message' => '手机号不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 验证手机号格式
if (!preg_match('/^1[3-9]\d{9}$/', $phoneNumber)) {
    $requestLogger->warning('手机号格式不正确', ['phone_number' => $phoneNumber]);
    echo json_encode([
        'code' => 1002,
        'message' => '手机号格式不正确',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 生成随机验证码
$code = mt_rand(100000, 999999);
$requestLogger->debug('生成验证码', ['code' => $code, 'phone_number' => $phoneNumber]);

// 创建阿里云客户端
function createClient($config) {
    // 使用配置文件中的AccessKey
    $clientConfig = new Config([
        'accessKeyId' => $config['accessKeyId'],
        'accessKeySecret' => $config['accessKeySecret']
    ]);
    // Endpoint 请参考 https://api.aliyun.com/product/Dypnsapi
    $clientConfig->endpoint = $config['sms']['endpoint'];
    return new Dypnsapi($clientConfig);
}

// 发送验证码
try {
    $requestLogger->debug('创建阿里云客户端');
    $client = createClient($smsConfig);
    $requestLogger->debug('创建发送验证码请求');
    $sendSmsVerifyCodeRequest = new SendSmsVerifyCodeRequest([
        "phoneNumber" => $phoneNumber,
        "signName" => $smsConfig['sms']['signName'],
        "templateCode" => $smsConfig['sms']['templateCode'],
        "templateParam" => "{\"code\":\"##code##\",\"min\":\"5\"}",
        "codeLength" => 6
    ]);
    $runtime = new RuntimeOptions([]);
    $requestLogger->debug('发送验证码', ['phone_number' => $phoneNumber]);
    $resp = $client->sendSmsVerifyCodeWithOptions($sendSmsVerifyCodeRequest, $runtime);
    
    // 保存验证码到数据库或缓存（这里简化处理）
    // 实际项目中应该将验证码与手机号关联并设置过期时间
    
    $requestLogger->info('验证码发送成功', ['phone_number' => $phoneNumber]);
    $auditLogger->notice('验证码发送成功', ['phone_number' => $phoneNumber]);
    
    echo json_encode([
        'code' => 0,
        'message' => '验证码发送成功',
        'data' => [
            'phone_number' => $phoneNumber
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $error) {
    $errorLogger->error('验证码发送失败', [
        'phone_number' => $phoneNumber,
        'exception' => $error->getMessage(),
        'file' => $error->getFile(),
        'line' => $error->getLine()
    ]);
    echo json_encode([
        'code' => 1003,
        'message' => '验证码发送失败: ' . $error->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
