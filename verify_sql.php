<?php
// 验证SQL文件语法的脚本
$filePath = 'task_admin/sql/system_tables.sql';

// 读取SQL文件内容
$sqlContent = file_get_contents($filePath);

// 检查文件是否存在
if (!$sqlContent) {
    die("无法读取SQL文件: $filePath\n");
}

// 分割SQL语句
$sqlStatements = explode(';', $sqlContent);

// 基本语法检查
$errors = [];

foreach ($sqlStatements as $index => $statement) {
    $statement = trim($statement);
    if (empty($statement)) {
        continue;
    }
    
    // 检查常见语法问题
    if (stripos($statement, 'INSERT') !== false && stripos($statement, 'VALUES') === false) {
        $errors[] = "第 " . ($index + 1) . " 条语句: INSERT语句缺少VALUES子句";
    }
    
    if (stripos($statement, 'CREATE TABLE') !== false && stripos($statement, 'ENGINE') === false) {
        $errors[] = "第 " . ($index + 1) . " 条语句: CREATE TABLE语句缺少ENGINE定义";
    }
}

// 检查变量使用
if (strpos($sqlContent, '@admin_role_id') !== false) {
    $errors[] = "发现未定义的变量: @admin_role_id";
}

// 检查角色ID一致性
if (strpos($sqlContent, 'role_id, 1') === false) {
    $errors[] = "超级管理员用户的role_id设置不一致";
}

// 检查超级管理员角色是否存在
if (strpos($sqlContent, "'超级管理员'") === false) {
    $errors[] = "缺少超级管理员角色的插入语句";
}

// 输出检查结果
if (empty($errors)) {
    echo "SQL文件语法检查通过，未发现明显错误。\n";
} else {
    echo "SQL文件语法检查发现以下错误:\n";
    foreach ($errors as $error) {
        echo "- $error\n";
    }
}

// 检查文件结构
$tables = [
    'system_permission_template',
    'system_role_permission_template',
    'system_roles',
    'system_users',
    'magnifying_glass_tasks'
];

echo "\n检查是否包含所有必要的表:\n";
foreach ($tables as $table) {
    if (strpos($sqlContent, "CREATE TABLE `$table`") !== false) {
        echo "- 表 $table: 存在\n";
    } else {
        echo "- 表 $table: 缺失\n";
    }
}
?>