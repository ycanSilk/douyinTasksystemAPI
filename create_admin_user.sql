-- Create super admin user and permission configuration script

-- 1. Insert super admin role if not exists
INSERT IGNORE INTO `system_roles` (`name`, `description`, `status`) VALUES
('超级管理员', '拥有最高权限', 1);

-- 2. Insert permissions if not exists
INSERT IGNORE INTO `system_permissions` (`name`, `code`, `description`) VALUES
('用户管理', 'user_manage', '管理系统用户'),
('角色管理', 'role_manage', '管理系统角色'),
('权限管理', 'permission_manage', '管理系统权限'),
('充值管理', 'recharge_manage', '管理充值申请'),
('提现管理', 'withdraw_manage', '管理提现申请'),
('任务管理', 'task_manage', '管理任务'),
('放大镜任务管理', 'magnifier_manage', '管理放大镜任务'),
('统计管理', 'stats_manage', '查看统计数据'),
('系统配置', 'system_config', '配置系统参数');

-- 3. Get super admin role ID
SET @admin_role_id = (SELECT id FROM `system_roles` WHERE `name` = '超级管理员');

-- 4. Assign all permissions to super admin
INSERT IGNORE INTO `system_role_permission` (`role_id`, `permission_id`)
SELECT @admin_role_id, id FROM `system_permissions`;

-- 5. Create super admin user if not exists
INSERT IGNORE INTO `system_users` (`username`, `password_hash`, `email`, `phone`, `role_id`, `status`)
VALUES
('task', 'e10adc3949ba59abbe56e057f20f883e', 'admin@example.com', '13800138000', @admin_role_id, 1);

-- 6. Verify creation result
SELECT 
    u.id AS user_id,
    u.username,
    u.email,
    r.name AS role_name,
    COUNT(p.id) AS permission_count
FROM 
    system_users u
JOIN 
    system_roles r ON u.role_id = r.id
JOIN 
    system_role_permission rp ON r.id = rp.role_id
JOIN 
    system_permissions p ON rp.permission_id = p.id
WHERE 
    u.username = 'task'
GROUP BY 
    u.id, u.username, u.email, r.name;

-- 7. Output execution result
SELECT '超级管理员用户创建成功' AS message;
SELECT '权限配置完成' AS message;
SELECT '执行完成' AS message;