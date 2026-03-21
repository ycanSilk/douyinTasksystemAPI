<?php
/**
 * 校验验证码接口
 * 
 * POST /api/sms/verify-code.php
 * 
 * 请求体：
 * {
 *   "phoneNumber": "string (必填，手机号)",
 *   "verifyCode": "string (必填，验证码)"
 * }
 */

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

// 加载必要的文件
require_once __DIR__ . '/../../core/Response.php';
require_once __DIR__ . '/../../config/smsconf.php';

$path = __DIR__ . '/../../vendor/autoload.php'; // 修正路径分隔符
if (file_exists($path)) {
    require_once $path;
} else {
    Response::error('缺少依赖文件', 1001);
}

// 引入所需的类（完全按照官方示例）
use AlibabaCloud\SDK\Dypnsapi\V20170525\Dypnsapi;
use AlibabaCloud\Credentials\Credential;
use Darabonba\OpenApi\Models\Config;
use AlibabaCloud\SDK\Dypnsapi\V20170525\Models\CheckSmsVerifyCodeRequest;
use AlibabaCloud\Tea\Utils\Utils\RuntimeOptions;
use AlibabaCloud\Tea\Exception\TeaError;

// 获取配置
$smsConfig = require __DIR__ . '/../../config/smsconf.php';

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$phoneNumber = trim($input['phoneNumber'] ?? $input['phone_number'] ?? '');
$verifyCode = trim($input['verifyCode'] ?? $input['verify_code'] ?? '');

// 参数验证
if (empty($phoneNumber)) {
    Response::error('手机号不能为空', 1001);
}

if (empty($verifyCode)) {
    Response::error('验证码不能为空', 1002);
}

if (!preg_match('/^1[3-9]\d{9}$/', $phoneNumber)) {
    Response::error('手机号格式不正确', 1003);
}

if (!preg_match('/^\d{6}$/', $verifyCode)) {
    Response::error('验证码格式不正确', 1004);
}

/**
 * 创建阿里云客户端（完全按照官方示例）
 * 官方示例使用的是无AK方式，通过Credential自动获取凭据
 * 需要先在环境变量中配置 ALIBABA_CLOUD_ACCESS_KEY_ID 和 ALIBABA_CLOUD_ACCESS_KEY_SECRET
 */
function createClient($config) {
     // 直接使用配置文件中的AccessKey
     $clientConfig = new Config([
        'accessKeyId' => $config['accessKeyId'],
        'accessKeySecret' => $config['accessKeySecret']
    ]);
    // Endpoint 请参考 https://api.aliyun.com/product/Dypnsapi
    $clientConfig->endpoint = $config['sms']['endpoint'];
    return new Dypnsapi($clientConfig);
}

// 校验验证码
try {
    // 然后在调用时传入配置
$client = createClient($smsConfig);
    
    // 创建请求对象（完全按照官方示例）
    $request = new CheckSmsVerifyCodeRequest([
        "phoneNumber" => $phoneNumber,
        "verifyCode" => $verifyCode
    ]);
    
    $runtime = new RuntimeOptions([]);
    
    // 发送请求
    $response = $client->checkSmsVerifyCodeWithOptions($request, $runtime);
    
    // 验证成功
    Response::success([
        'phone_number' => $phoneNumber
    ], '验证码验证成功');
    
} catch (Exception $error) {
    // 完全按照官方示例的错误处理方式
    if (!($error instanceof TeaError)) {
        $error = new TeaError([], $error->getMessage(), $error->getCode(), $error);
    }
    
    // 获取错误信息
    $errorMessage = $error->message;
    if (isset($error->data["Recommend"])) {
        $errorMessage .= ' ' . $error->data["Recommend"];
    }
    
    // 记录错误日志
    error_log('验证码校验失败: ' . $errorMessage);
    
    // 返回错误
    Response::error('验证码验证失败: ' . $errorMessage, 1005);
}