<?php
// 模拟登录请求
$username = 'task';
$password = '123456';
$hashedPassword = md5($password);

echo "测试登录请求:\n";
echo "用户名: $username\n";
echo "原始密码: $password\n";
echo "MD5加密后: $hashedPassword\n";

// 构建请求数据
$data = [
    'username' => $username,
    'password' => $hashedPassword
];

// 发送请求
$ch = curl_init('http://localhost/task_admin/auth/login.php');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

curl_close($ch);

echo "\n响应状态码: $httpCode\n";
echo "响应内容:\n";
echo $response . "\n";

// 解析响应
try {
    $result = json_decode($response, true);
    echo "\n解析后的响应:\n";
    print_r($result);
} catch (Exception $e) {
    echo "解析失败: " . $e->getMessage() . "\n";
}
?>