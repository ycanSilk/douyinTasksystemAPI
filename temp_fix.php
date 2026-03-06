<?php
/**
 * 临时修复脚本
 * 1. 查询task用户信息
 * 2. 为task用户的角色分配所有导航面板权限
 */

require_once __DIR__ . '/task_admin/api/c_users/list.php';

// 数据库连接
$db = Database::connect();

try {
    // 查询task用户信息
    echo "=== 查询task用户信息 ===\n";
    $stmt = $db->prepare('SELECT * FROM system_users WHERE username = ?');
    $stmt->execute(['task']);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        echo "错误：未找到task用户\n";
        exit;
    }
    
    print_r($user);
    echo "\n";
    
    // 查询用户角色
    echo "=== 查询用户角色 ===\n";
    $stmt = $db->prepare('SELECT * FROM system_roles WHERE id = ?');
    $stmt->execute([$user['role_id']]);
    $role = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$role) {
        echo "错误：未找到用户角色\n";
        exit;
    }
    
    print_r($role);
    echo "\n";
    
    // 查询所有导航面板
    echo "=== 查询所有导航面板 ===\n";
    $stmt = $db->query('SELECT id, name, code FROM system_permission_template ORDER BY sort_order ASC');
    $templates = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "共找到 " . count($templates) . " 个导航面板\n";
    foreach ($templates as $template) {
        echo "ID: {$template['id']}, 名称: {$template['name']}, 代码: {$template['code']}\n";
    }
    echo "\n";
    
    // 为角色分配所有权限
    echo "=== 为角色分配所有权限 ===\n";
    $roleId = $user['role_id'];
    
    // 开始事务
    $db->beginTransaction();
    
    // 删除原有权限
    $stmt = $db->prepare('DELETE FROM system_role_permission_template WHERE role_id = ?');
    $stmt->execute([$roleId]);
    echo "已删除原有权限\n";
    
    // 分配所有权限
    if (!empty($templates)) {
        $insertSql = 'INSERT INTO system_role_permission_template (role_id, template_id) VALUES ';
        $values = [];
        $params = [];
        
        foreach ($templates as $template) {
            $values[] = '(?, ?)';
            $params[] = $roleId;
            $params[] = $template['id'];
        }
        
        $insertSql .= implode(', ', $values);
        $stmt = $db->prepare($insertSql);
        $result = $stmt->execute($params);
        
        if ($result) {
            $db->commit();
            echo "成功为角色分配 " . count($templates) . " 个导航面板权限\n";
        } else {
            $db->rollBack();
            echo "错误：分配权限失败\n";
        }
    } else {
        $db->commit();
        echo "警告：没有找到导航面板\n";
    }
    
    // 验证权限分配结果
    echo "=== 验证权限分配结果 ===\n";
    $stmt = $db->prepare('SELECT COUNT(*) FROM system_role_permission_template WHERE role_id = ?');
    $stmt->execute([$roleId]);
    $count = $stmt->fetchColumn();
    
    echo "角色 {$role['name']} 现在拥有 {$count} 个导航面板权限\n";
    
} catch (PDOException $e) {
    echo "错误：" . $e->getMessage() . "\n";
}
?>