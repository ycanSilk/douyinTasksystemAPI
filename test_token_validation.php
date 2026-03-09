<?php
/**
 * Token验证测试脚本
 * 测试旧token在新token生成后是否会失效
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/core/Database.php';
require_once __DIR__ . '/core/Token.php';
require_once __DIR__ . '/core/Response.php';

// 测试用户ID
$testUserId = 1;
$testUserType = Token::TYPE_C;

// 连接数据库
$db = Database::connect();

// 第一次登录 - 生成第一个token
echo "=== 第一次登录 ===\n";
$tokenData1 = Token::generate($testUserId, $testUserType);
$token1 = $tokenData1['token'];
echo "生成的第一个token: {$token1}\n";

// 更新数据库中的token
Token::updateToDatabase($testUserId, $testUserType, $token1, $tokenData1['expired_at'], $db);
echo "第一个token已更新到数据库\n";

// 验证第一个token是否有效
echo "\n=== 验证第一个token ===\n";
$result1 = Token::verify($token1, $testUserType, $db);
echo "第一个token验证结果: " . json_encode($result1, JSON_UNESCAPED_UNICODE) . "\n";

// 第二次登录 - 生成第二个token
echo "\n=== 第二次登录 ===\n";
// 添加1秒延迟，确保exp字段不同
sleep(1);
$tokenData2 = Token::generate($testUserId, $testUserType);
$token2 = $tokenData2['token'];
echo "生成的第二个token: {$token2}\n";

// 更新数据库中的token
Token::updateToDatabase($testUserId, $testUserType, $token2, $tokenData2['expired_at'], $db);
echo "第二个token已更新到数据库\n";

// 验证第二个token是否有效
echo "\n=== 验证第二个token ===\n";
$result2 = Token::verify($token2, $testUserType, $db);
echo "第二个token验证结果: " . json_encode($result2, JSON_UNESCAPED_UNICODE) . "\n";

// 验证第一个token是否已失效
echo "\n=== 验证第一个token是否已失效 ===\n";
$result1Expired = Token::verify($token1, $testUserType, $db);
echo "第一个token验证结果: " . json_encode($result1Expired, JSON_UNESCAPED_UNICODE) . "\n";

// 总结
echo "\n=== 测试总结 ===\n";
if ($result1['valid'] && $result2['valid'] && !$result1Expired['valid']) {
    echo "✅ 测试通过！旧token在新token生成后已失效\n";
} else {
    echo "❌ 测试失败！旧token仍然有效\n";
}
?>