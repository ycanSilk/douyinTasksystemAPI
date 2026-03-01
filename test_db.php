<?php
/**
 * 数据库连接测试脚本
 */

header('Content-Type: application/json; charset=utf-8');

$config = require __DIR__ . '/config/database.php';

$dsn = sprintf(
    'mysql:host=%s;port=%d;dbname=%s;charset=%s',
    $config['host'],
    $config['port'],
    $config['database'],
    $config['charset']
);

try {
    $pdo = new PDO($dsn, $config['username'], $config['password'], $config['options']);
    echo json_encode([
        'code' => 0,
        'message' => '数据库连接成功',
        'data' => [
            'dsn' => $dsn,
            'username' => $config['username']
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    echo json_encode([
        'code' => 1002,
        'message' => '数据库连接失败: ' . $e->getMessage(),
        'data' => [
            'dsn' => $dsn,
            'username' => $config['username']
        ]
    ], JSON_UNESCAPED_UNICODE);
}
