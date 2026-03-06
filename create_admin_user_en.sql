-- Create super admin user and permission configuration script

-- 1. Insert super admin role if not exists
INSERT IGNORE INTO `system_roles` (`name`, `description`, `status`) VALUES
('Super Admin', 'Highest permission', 1);

-- 2. Insert permissions if not exists
INSERT IGNORE INTO `system_permissions` (`name`, `code`, `description`) VALUES
('User Management', 'user_manage', 'Manage system users'),
('Role Management', 'role_manage', 'Manage system roles'),
('Permission Management', 'permission_manage', 'Manage system permissions'),
('Recharge Management', 'recharge_manage', 'Manage recharge requests'),
('Withdraw Management', 'withdraw_manage', 'Manage withdraw requests'),
('Task Management', 'task_manage', 'Manage tasks'),
('Magnifier Task Management', 'magnifier_manage', 'Manage magnifier tasks'),
('Statistics Management', 'stats_manage', 'View statistics'),
('System Configuration', 'system_config', 'Configure system parameters');

-- 3. Get super admin role ID
SET @admin_role_id = (SELECT id FROM `system_roles` WHERE `name` = 'Super Admin');

-- 4. Assign all permissions to super admin
INSERT IGNORE INTO `system_role_permission` (`role_id`, `permission_id`)
SELECT @admin_role_id, id FROM `system_permissions`;

-- 5. Create super admin user if not exists
INSERT IGNORE INTO `system_users` (`username`, `password_hash`, `email`, `phone`, `role_id`, `status`)
VALUES
('task', 'taskplatformMVP', 'admin@example.com', '13800138000', @admin_role_id, 1);

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
SELECT 'Super admin user created successfully' AS message;
SELECT 'Permission configuration completed' AS message;
SELECT 'Execution completed' AS message;