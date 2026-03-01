<?php
/**
 * 发送验证码接口
 * 
 * POST /api/sms/send-code.php
 * 
 * 请求体：
 * {
 *   "phone_number": "string (必填，手机号)"
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

$path = __DIR__ . '\..\..\vendor\autoload.php';
if (file_exists($path)) {
    require_once $path;
} else {
    Response::error('缺少依赖文件', 1001);
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
    $data = json_decode($json, true);
    $phoneNumber = trim($data['phone_number'] ?? $data['phoneNumber'] ?? '');
} else {
    $phoneNumber = trim($_POST['phone_number'] ?? $_POST['phoneNumber'] ?? '');
}

// 参数验证
if (empty($phoneNumber)) {
    Response::error('手机号不能为空', 1001);
}

// 验证手机号格式
if (!preg_match('/^1[3-9]\d{9}$/', $phoneNumber)) {
    Response::error('手机号格式不正确', 1002);
}

// 生成随机验证码
$code = mt_rand(100000, 999999);

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
    $client = createClient($smsConfig);
    $sendSmsVerifyCodeRequest = new SendSmsVerifyCodeRequest([
        "phoneNumber" => $phoneNumber,
        "signName" => $smsConfig['sms']['signName'],
        "templateCode" => $smsConfig['sms']['templateCode'],
        "templateParam" => "{\"code\":\"##code##\",\"min\":\"5\"}",
        "codeLength" => 6
    ]);
    $runtime = new RuntimeOptions([]);
    $resp = $client->sendSmsVerifyCodeWithOptions($sendSmsVerifyCodeRequest, $runtime);
    
    // 保存验证码到数据库或缓存（这里简化处理）
    // 实际项目中应该将验证码与手机号关联并设置过期时间
    
    Response::success([
        'phone_number' => $phoneNumber,
        'code' => $code // 实际项目中不应该返回验证码
    ], '验证码发送成功');
} catch (Exception $error) {
    Response::error('验证码发送失败: ' . $error->getMessage(), 1003);
}
