<?php
/**
 * 数据库配置
 */

return [
    'host' => 'localhost',
    'port' => 3306,
    'database' => 'task_platform',
    'username' => 'task_platform',
    'password' => 'ePXpWcMBGP6s2xrD',
    'charset' => 'utf8mb4',
    'options' => [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]
];

