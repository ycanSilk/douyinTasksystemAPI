-- 更新wallets_log表结构，添加任务类型字段
ALTER TABLE `wallets_log` ADD COLUMN `task_types` tinyint UNSIGNED NULL DEFAULT NULL COMMENT '任务类型：1=上评评论，2=中评评论，3=放大镜搜索词，4=上中评评论，5=中下评评论，6=出租订单，7=求租订单' AFTER `related_id`;
ALTER TABLE `wallets_log` ADD COLUMN `task_types_text` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务类型文本描述' AFTER `task_types`;

-- 添加索引
ALTER TABLE `wallets_log` ADD INDEX `idx_task_types`(`task_types` ASC) USING BTREE;
