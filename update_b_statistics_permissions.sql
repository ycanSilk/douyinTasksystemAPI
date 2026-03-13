-- 添加B端用户交易流水的二级导航权限模板

-- 1. 首先添加父级菜单（如果不存在）
INSERT INTO `system_permission_template` (`name`, `code`, `description`, `parent_id`, `icon`, `url`, `sort_order`, `status`) 
VALUES ('B端用户交易流水', 'b-statistics', 'B端用户交易流水管理', NULL, 'ri-wallet-2-line', 'b-statistics', 12, 1)
ON DUPLICATE KEY UPDATE `name` = 'B端用户交易流水', `description` = 'B端用户交易流水管理', `icon` = 'ri-wallet-2-line', `url` = 'b-statistics', `sort_order` = 12, `status` = 1;

-- 2. 获取父级菜单ID
SET @parent_id = (SELECT id FROM system_permission_template WHERE code = 'b-statistics');

-- 3. 添加子级菜单
-- 用户交易流水
INSERT INTO `system_permission_template` (`name`, `code`, `description`, `parent_id`, `icon`, `url`, `sort_order`, `status`) 
VALUES ('用户交易流水', 'b-statistics-flows', 'B端用户交易流水记录', @parent_id, 'ri-list-check', 'b-statistics-flows', 1, 1)
ON DUPLICATE KEY UPDATE `name` = '用户交易流水', `description` = 'B端用户交易流水记录', `parent_id` = @parent_id, `icon` = 'ri-list-check', `url` = 'b-statistics-flows', `sort_order` = 1, `status` = 1;

-- 数据统计
INSERT INTO `system_permission_template` (`name`, `code`, `description`, `parent_id`, `icon`, `url`, `sort_order`, `status`) 
VALUES ('数据统计', 'b-statistics-summary', 'B端用户交易数据统计', @parent_id, 'ri-bar-chart-line', 'b-statistics-summary', 2, 1)
ON DUPLICATE KEY UPDATE `name` = '数据统计', `description` = 'B端用户交易数据统计', `parent_id` = @parent_id, `icon` = 'ri-bar-chart-line', `url` = 'b-statistics-summary', `sort_order` = 2, `status` = 1;

-- 4. 为现有角色添加这些权限（可选）
-- 为超级管理员角色添加权限
SET @super_admin_role_id = (SELECT id FROM system_roles WHERE name = '超级管理员');

-- 添加父级权限
INSERT IGNORE INTO `system_role_permission_template` (`role_id`, `template_id`, `created_at`) 
SELECT @super_admin_role_id, id, NOW() FROM system_permission_template WHERE code = 'b-statistics';

-- 添加子级权限
INSERT IGNORE INTO `system_role_permission_template` (`role_id`, `template_id`, `created_at`) 
SELECT @super_admin_role_id, id, NOW() FROM system_permission_template WHERE code IN ('b-statistics-flows', 'b-statistics-summary');
