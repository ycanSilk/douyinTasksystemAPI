-- 更新用户表结构，允许wallet_id为NULL，以便支持先创建用户再创建钱包的逻辑
ALTER TABLE `c_users` 
MODIFY COLUMN `wallet_id` bigint UNSIGNED NULL COMMENT '关联钱包ID';

ALTER TABLE `b_users` 
MODIFY COLUMN `wallet_id` bigint UNSIGNED NULL COMMENT '关联钱包ID';

-- 更新wallets表结构，添加用户ID和用户类型字段
ALTER TABLE `wallets` 
ADD COLUMN `user_id` bigint UNSIGNED NOT NULL COMMENT '关联用户ID' AFTER `id`,
ADD COLUMN `user_type` tinyint NOT NULL DEFAULT 1 COMMENT '用户类型：1=C端，2=B端' AFTER `user_id`,
ADD INDEX `idx_user_id` (`user_id` ASC) USING BTREE,
ADD INDEX `idx_user_type` (`user_type` ASC) USING BTREE;

-- 更新现有C端用户的钱包记录
UPDATE wallets w
JOIN c_users c ON w.id = c.wallet_id
SET w.user_id = c.id, w.username = c.username, w.user_type = 1;

-- 更新现有B端用户的钱包记录
UPDATE wallets w
JOIN b_users b ON w.id = b.wallet_id
SET w.user_id = b.id, w.username = b.username, w.user_type = 2;