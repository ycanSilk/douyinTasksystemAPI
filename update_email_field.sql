-- 更新c_users表，将email字段改为允许null，并移除唯一索引
ALTER TABLE `c_users` MODIFY COLUMN `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮箱（选填）';

-- 移除email字段的唯一索引
ALTER TABLE `c_users` DROP INDEX `uk_email`;