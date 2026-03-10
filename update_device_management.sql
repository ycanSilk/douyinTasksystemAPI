-- 更新C端用户表，添加设备管理相关字段
ALTER TABLE `c_users` ADD COLUMN `device_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前登录设备ID';
ALTER TABLE `c_users` ADD COLUMN `device_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前登录设备名称';
ALTER TABLE `c_users` ADD COLUMN `max_devices` int NOT NULL DEFAULT 1 COMMENT '最大允许登录设备数，0表示无限制';
ALTER TABLE `c_users` ADD COLUMN `last_login_device` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '最后登录设备信息（JSON格式）';
ALTER TABLE `c_users` ADD COLUMN `device_list` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '已登录设备列表（JSON格式）';

-- 更新B端用户表，添加设备管理相关字段
ALTER TABLE `b_users` ADD COLUMN `device_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前登录设备ID';
ALTER TABLE `b_users` ADD COLUMN `device_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前登录设备名称';
ALTER TABLE `b_users` ADD COLUMN `max_devices` int NOT NULL DEFAULT 1 COMMENT '最大允许登录设备数，0表示无限制';
ALTER TABLE `b_users` ADD COLUMN `last_login_device` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '最后登录设备信息（JSON格式）';
ALTER TABLE `b_users` ADD COLUMN `device_list` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '已登录设备列表（JSON格式）';

-- 添加索引以提高查询性能
CREATE INDEX `idx_device_id` ON `c_users`(`device_id`);
CREATE INDEX `idx_device_id` ON `b_users`(`device_id`);
