-- 添加登录设备配置导航面板
INSERT INTO `system_permission_template` (`name`, `code`, `description`, `parent_id`, `icon`, `url`, `sort_order`, `status`, `created_at`, `updated_at`)
VALUES ('登录设备配置', 'login-devices-config', '用户登录设备数量配置', NULL, 'ri-lock-unlock-line', 'login-devices-config', 20, 1, NOW(), NOW());

-- 如果需要更新排序顺序，可以使用以下语句
-- UPDATE `system_permission_template` SET `sort_order` = 20 WHERE `code` = 'login-devices-config';
