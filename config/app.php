<?php
/**
 * 应用配置
 * 从数据库动态读取配置
 */

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/AppConfig.php';

// 从数据库读取配置
return AppConfig::getAll();
