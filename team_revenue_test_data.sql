-- 团队收益相关表创建语句
-- 1. 创建团队收益明细表
DROP TABLE IF EXISTS `team_revenue_statistics_breakdown`;
CREATE TABLE `team_revenue_statistics_breakdown`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `agent_id` bigint UNSIGNED NOT NULL COMMENT '代理用户ID（获得团队收益的人）',
  `agent_username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '代理用户名',
  `agent_level` tinyint NOT NULL COMMENT '代理层级：1=一级下线（直接邀请），2=二级下线（间接邀请）',
  `downline_user_id` bigint UNSIGNED NOT NULL COMMENT '下线用户ID（完成任务的人）',
  `downline_username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '下线用户名',
  `downline_user_amount` decimal(10,2) NOT NULL COMMENT '下线完成任务获得的金额',
  `team_revenue_amount` decimal(10,2) NOT NULL COMMENT '本次发放给代理的团队收益金额',
  `agent_before_amount` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '变更前代理团队收益总额',
  `agent_after_amount` decimal(10,2) NOT NULL COMMENT '变更后代理团队收益总额',
  `related_id` varchar(64) NOT NULL COMMENT '关联ID（任务ID或订单ID）',
  `revenue_source` tinyint NOT NULL COMMENT '收益来源：1=任务收益，2=账号出租收益',
  `revenue_source_text` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收益来源文本',
  `task_type` tinyint NULL DEFAULT NULL COMMENT '任务类型（来源为任务时有效）',
  `task_type_text` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务类型文本',
  `task_stage` tinyint NULL DEFAULT NULL COMMENT '任务阶段（来源为任务时有效）',
  `task_stage_text` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务阶段文本',
  `order_type` tinyint NULL DEFAULT NULL COMMENT '订单类型：1=出租订单，2=求租订单（来源为订单时有效）',
  `order_type_text` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '订单类型文本',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_agent_id`(`agent_id` ASC) USING BTREE,
  INDEX `idx_agent_level`(`agent_level` ASC) USING BTREE,
  INDEX `idx_downline_user_id`(`downline_user_id` ASC) USING BTREE,
  INDEX `idx_related_id`(`related_id` ASC) USING BTREE,
  INDEX `idx_revenue_source`(`revenue_source` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_agent_id_level`(`agent_id` ASC, `agent_level` ASC) USING BTREE COMMENT '复合索引，优化按代理和层级查询'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '团队收益明细表' ROW_FORMAT = DYNAMIC;

-- 2. 创建团队收益汇总表
DROP TABLE IF EXISTS `team_revenue_statistics_summary`;
CREATE TABLE `team_revenue_statistics_summary`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '用户ID（代理）',
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `total_team_revenue` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '总团队收益',
  `level1_team_revenue` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '一级下线贡献收益（agent_level=1）',
  `level2_team_revenue` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '二级下线贡献收益（agent_level=2）',
  `level1_downline_count` int NOT NULL DEFAULT 0 COMMENT '一级下线人数（直接邀请）',
  `level2_downline_count` int NOT NULL DEFAULT 0 COMMENT '二级下线人数（间接邀请）',
  `total_downline_count` int NOT NULL DEFAULT 0 COMMENT '总下线人数（去重）',
  `level1_active_count` int NOT NULL DEFAULT 0 COMMENT '活跃一级下线人数',
  `level2_active_count` int NOT NULL DEFAULT 0 COMMENT '活跃二级下线人数',
  `total_active_count` int NOT NULL DEFAULT 0 COMMENT '总活跃下线人数',
  `task_revenue_count` int NOT NULL DEFAULT 0 COMMENT '任务收益笔数',
  `order_revenue_count` int NOT NULL DEFAULT 0 COMMENT '订单收益笔数',
  `task_revenue_amount` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '任务收益总额',
  `order_revenue_amount` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '订单收益总额',
  `level1_revenue_count` int NOT NULL DEFAULT 0 COMMENT '一级下线收益笔数',
  `level2_revenue_count` int NOT NULL DEFAULT 0 COMMENT '二级下线收益笔数',
  `last_revenue_time` datetime NULL DEFAULT NULL COMMENT '最后收益时间',
  `last_level1_revenue_time` datetime NULL DEFAULT NULL COMMENT '最后一级下线收益时间',
  `last_level2_revenue_time` datetime NULL DEFAULT NULL COMMENT '最后二级下线收益时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_total_team_revenue`(`total_team_revenue` ASC) USING BTREE,
  INDEX `idx_level1_revenue`(`level1_team_revenue` ASC) USING BTREE,
  INDEX `idx_level2_revenue`(`level2_team_revenue` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '团队收益汇总表' ROW_FORMAT = DYNAMIC;

-- 3. 插入c_users表测试数据（用户ID从100开始）
-- 生成测试用户，建立层级关系
INSERT INTO `c_users` (`id`, `username`, `email`, `phone`, `password_hash`, `invite_code`, `parent_id`, `parent_username`, `is_agent`, `wallet_id`, `status`, `created_at`) VALUES
(100, 'user100', 'user100@example.com', '15900013810', '$2y$10$9gww7TqOTzSA9SqchkFEgeYftRKlJ4ciYWL6IiD8DPUbQv8/PnCGe', 'INV100', NULL, NULL, 3, 100, 1, NOW()),
(101, 'user101', 'user101@example.com', '15900013811', '$2y$10$hkD.XBnEsk7iKbrYdpuxyOmrn.vME26Z1gzkXkBEXaUQMey5b3MAm', 'INV101', 100, 'user100', 2, 101, 1, NOW()),
(102, 'user102', 'user102@example.com', '15900013812', '$2y$10$Cvl7CIY5Oj2gPcKSvNE2mONLRs14Rr1ndstVn2FHJlco8GmXxS586', 'INV102', 100, 'user100', 2, 102, 1, NOW()),
(103, 'user103', 'user103@example.com', '15900013813', '$2y$10$qydW3B1EXlxJou5CUfPMaOvssOD/K8GugvQh.BeeX/KGBpPGC3awq', 'INV103', 101, 'user101', 1, 103, 1, NOW()),
(104, 'user104', 'user104@example.com', '15900013814', '$2y$12$BcNzzO08Ioin60d4mXd4UeY7V8bahMDqUYhkHuFHCR3vh690fXKhu', 'INV104', 101, 'user101', 1, 104, 1, NOW()),
(105, 'user105', 'user105@example.com', '15900013815', '$2y$12$zgG9QJ4V5vLg9NJ0n8Wc2uj7Uoo1dh3q33mBwRf/xm.q0ovFfrPcu', 'INV105', 102, 'user102', 1, 105, 1, NOW()),
(106, 'user106', 'user106@example.com', '15900013816', '$2y$12$8z7vXjSjouSHHcO33xpoX..Px3DQVrcNAixczIfbfXhy.1mo0r5yW', 'INV106', 103, 'user103', 0, 106, 1, NOW()),
(107, 'user107', 'user107@example.com', '15900013817', '$2y$12$nyojdrP1YvXOE7Zkrva3.Os8fn0goB671mqPJmODF8piW8aRqGinm', 'INV107', 103, 'user103', 0, 107, 1, NOW()),
(108, 'user108', 'user108@example.com', '15900013818', '$2y$12$n.eutQbVaWv91iQeFltN2ueUb9Ff.Fzw1dwk/h2pyKfbgh/itcHcO', 'INV108', 104, 'user104', 0, 108, 1, NOW()),
(109, 'user109', 'user109@example.com', '15900013819', '$2y$12$huLJYXF6k4LW9fCO0FC2meaOkLsNE24UJDSclYEv/Y8d9RiUWYuW.', 'INV109', 105, 'user105', 0, 109, 1, NOW()),
(110, 'user110', 'user110@example.com', '15900013820', '$2y$12$/7d7wzdvWDXCDp1jEdYA7e5.PKI.WGYsYdK2YJhNqyk7/OjQ9UH6y', 'INV110', 105, 'user105', 0, 110, 1, NOW());

-- 4. 插入团队收益汇总表初始数据
INSERT INTO `team_revenue_statistics_summary` (`user_id`, `username`) VALUES
(100, 'user100'),
(101, 'user101'),
(102, 'user102'),
(103, 'user103'),
(104, 'user104'),
(105, 'user105');

-- 5. 插入团队收益明细表测试数据
-- 测试数据1：user106完成任务，为上级代理贡献收益
-- user106 -> user103 (一级) -> user101 (二级) -> user100 (三级，不计算)
INSERT INTO `team_revenue_statistics_breakdown` (`agent_id`, `agent_username`, `agent_level`, `downline_user_id`, `downline_username`, `downline_user_amount`, `team_revenue_amount`, `agent_before_amount`, `agent_after_amount`, `related_id`, `revenue_source`, `revenue_source_text`, `task_type`, `task_type_text`, `task_stage`, `task_stage_text`, `created_at`) VALUES
(103, 'user103', 1, 106, 'user106', 25.00, 25.00, 0.00, 25.00, 'TASK001', 1, '任务收益', 3, '评论任务', 2, '已完成', NOW()),
(101, 'user101', 2, 106, 'user106', 25.00, 25.00, 0.00, 25.00, 'TASK001', 1, '任务收益', 3, '评论任务', 2, '已完成', NOW());

-- 更新汇总表数据
UPDATE `team_revenue_statistics_summary` SET 
`total_team_revenue` = 25.00, 
`level1_team_revenue` = 25.00, 
`level1_revenue_count` = 1, 
`level1_active_count` = 1, 
`total_active_count` = 1, 
`task_revenue_count` = 1, 
`task_revenue_amount` = 25.00, 
`last_revenue_time` = NOW(), 
`last_level1_revenue_time` = NOW() 
WHERE `user_id` = 103;

UPDATE `team_revenue_statistics_summary` SET 
`total_team_revenue` = 25.00, 
`level2_team_revenue` = 25.00, 
`level2_revenue_count` = 1, 
`level2_active_count` = 1, 
`total_active_count` = 1, 
`task_revenue_count` = 1, 
`task_revenue_amount` = 25.00, 
`last_revenue_time` = NOW(), 
`last_level2_revenue_time` = NOW() 
WHERE `user_id` = 101;

-- 测试数据2：user107完成任务，为上级代理贡献收益
-- user107 -> user103 (一级) -> user101 (二级) -> user100 (三级，不计算)
INSERT INTO `team_revenue_statistics_breakdown` (`agent_id`, `agent_username`, `agent_level`, `downline_user_id`, `downline_username`, `downline_user_amount`, `team_revenue_amount`, `agent_before_amount`, `agent_after_amount`, `related_id`, `revenue_source`, `revenue_source_text`, `task_type`, `task_type_text`, `task_stage`, `task_stage_text`, `created_at`) VALUES
(103, 'user103', 1, 107, 'user107', 30.00, 30.00, 25.00, 55.00, 'TASK002', 1, '任务收益', 3, '评论任务', 2, '已完成', NOW()),
(101, 'user101', 2, 107, 'user107', 30.00, 30.00, 25.00, 55.00, 'TASK002', 1, '任务收益', 3, '评论任务', 2, '已完成', NOW());

-- 更新汇总表数据
UPDATE `team_revenue_statistics_summary` SET 
`total_team_revenue` = 55.00, 
`level1_team_revenue` = 55.00, 
`level1_revenue_count` = 2, 
`level1_active_count` = 2, 
`total_active_count` = 2, 
`task_revenue_count` = 2, 
`task_revenue_amount` = 55.00, 
`last_revenue_time` = NOW(), 
`last_level1_revenue_time` = NOW() 
WHERE `user_id` = 103;

UPDATE `team_revenue_statistics_summary` SET 
`total_team_revenue` = 55.00, 
`level2_team_revenue` = 55.00, 
`level2_revenue_count` = 2, 
`level2_active_count` = 2, 
`total_active_count` = 2, 
`task_revenue_count` = 2, 
`task_revenue_amount` = 55.00, 
`last_revenue_time` = NOW(), 
`last_level2_revenue_time` = NOW() 
WHERE `user_id` = 101;

-- 测试数据3：user108完成订单，为上级代理贡献收益
-- user108 -> user104 (一级) -> user101 (二级) -> user100 (三级，不计算)
INSERT INTO `team_revenue_statistics_breakdown` (`agent_id`, `agent_username`, `agent_level`, `downline_user_id`, `downline_username`, `downline_user_amount`, `team_revenue_amount`, `agent_before_amount`, `agent_after_amount`, `related_id`, `revenue_source`, `revenue_source_text`, `order_type`, `order_type_text`, `created_at`) VALUES
(104, 'user104', 1, 108, 'user108', 50.00, 50.00, 0.00, 50.00, 'ORDER001', 2, '账号出租收益', 1, '出租订单', NOW()),
(101, 'user101', 2, 108, 'user108', 50.00, 50.00, 55.00, 105.00, 'ORDER001', 2, '账号出租收益', 1, '出租订单', NOW());

-- 更新汇总表数据
UPDATE `team_revenue_statistics_summary` SET 
`total_team_revenue` = 50.00, 
`level1_team_revenue` = 50.00, 
`level1_revenue_count` = 1, 
`level1_active_count` = 1, 
`total_active_count` = 1, 
`order_revenue_count` = 1, 
`order_revenue_amount` = 50.00, 
`last_revenue_time` = NOW(), 
`last_level1_revenue_time` = NOW() 
WHERE `user_id` = 104;

UPDATE `team_revenue_statistics_summary` SET 
`total_team_revenue` = 105.00, 
`level2_team_revenue` = 105.00, 
`level2_revenue_count` = 3, 
`level2_active_count` = 3, 
`total_active_count` = 3, 
`order_revenue_count` = 1, 
`order_revenue_amount` = 50.00, 
`last_revenue_time` = NOW(), 
`last_level2_revenue_time` = NOW() 
WHERE `user_id` = 101;

-- 测试数据4：user109完成任务，为上级代理贡献收益
-- user109 -> user105 (一级) -> user102 (二级) -> user100 (三级，不计算)
INSERT INTO `team_revenue_statistics_breakdown` (`agent_id`, `agent_username`, `agent_level`, `downline_user_id`, `downline_username`, `downline_user_amount`, `team_revenue_amount`, `agent_before_amount`, `agent_after_amount`, `related_id`, `revenue_source`, `revenue_source_text`, `task_type`, `task_type_text`, `task_stage`, `task_stage_text`, `created_at`) VALUES
(105, 'user105', 1, 109, 'user109', 20.00, 20.00, 0.00, 20.00, 'TASK003', 1, '任务收益', 3, '评论任务', 2, '已完成', NOW()),
(102, 'user102', 2, 109, 'user109', 20.00, 20.00, 0.00, 20.00, 'TASK003', 1, '任务收益', 3, '评论任务', 2, '已完成', NOW());

-- 更新汇总表数据
UPDATE `team_revenue_statistics_summary` SET 
`total_team_revenue` = 20.00, 
`level1_team_revenue` = 20.00, 
`level1_revenue_count` = 1, 
`level1_active_count` = 1, 
`total_active_count` = 1, 
`task_revenue_count` = 1, 
`task_revenue_amount` = 20.00, 
`last_revenue_time` = NOW(), 
`last_level1_revenue_time` = NOW() 
WHERE `user_id` = 105;

UPDATE `team_revenue_statistics_summary` SET 
`total_team_revenue` = 20.00, 
`level2_team_revenue` = 20.00, 
`level2_revenue_count` = 1, 
`level2_active_count` = 1, 
`total_active_count` = 1, 
`task_revenue_count` = 1, 
`task_revenue_amount` = 20.00, 
`last_revenue_time` = NOW(), 
`last_level2_revenue_time` = NOW() 
WHERE `user_id` = 102;

-- 测试数据5：user110完成订单，为上级代理贡献收益
-- user110 -> user105 (一级) -> user102 (二级) -> user100 (三级，不计算)
INSERT INTO `team_revenue_statistics_breakdown` (`agent_id`, `agent_username`, `agent_level`, `downline_user_id`, `downline_username`, `downline_user_amount`, `team_revenue_amount`, `agent_before_amount`, `agent_after_amount`, `related_id`, `revenue_source`, `revenue_source_text`, `order_type`, `order_type_text`, `created_at`) VALUES
(105, 'user105', 1, 110, 'user110', 45.00, 45.00, 20.00, 65.00, 'ORDER002', 2, '账号出租收益', 1, '出租订单', NOW()),
(102, 'user102', 2, 110, 'user110', 45.00, 45.00, 20.00, 65.00, 'ORDER002', 2, '账号出租收益', 1, '出租订单', NOW());

-- 更新汇总表数据
UPDATE `team_revenue_statistics_summary` SET 
`total_team_revenue` = 65.00, 
`level1_team_revenue` = 65.00, 
`level1_revenue_count` = 2, 
`level1_active_count` = 2, 
`total_active_count` = 2, 
`task_revenue_count` = 1, 
`task_revenue_amount` = 20.00, 
`order_revenue_count` = 1, 
`order_revenue_amount` = 45.00, 
`last_revenue_time` = NOW(), 
`last_level1_revenue_time` = NOW() 
WHERE `user_id` = 105;

UPDATE `team_revenue_statistics_summary` SET 
`total_team_revenue` = 65.00, 
`level2_team_revenue` = 65.00, 
`level2_revenue_count` = 2, 
`level2_active_count` = 2, 
`total_active_count` = 2, 
`task_revenue_count` = 1, 
`task_revenue_amount` = 20.00, 
`order_revenue_count` = 1, 
`order_revenue_amount` = 45.00, 
`last_revenue_time` = NOW(), 
`last_level2_revenue_time` = NOW() 
WHERE `user_id` = 102;

-- 6. 创建团队关系表测试数据
-- 一级代理关系（直接邀请）
INSERT INTO `c_user_relations` (`user_id`, `agent_id`, `level`) VALUES
(101, 100, 1),
(102, 100, 1),
(103, 101, 1),
(104, 101, 1),
(105, 102, 1),
(106, 103, 1),
(107, 103, 1),
(108, 104, 1),
(109, 105, 1),
(110, 105, 1);

-- 二级代理关系（间接邀请）
INSERT INTO `c_user_relations` (`user_id`, `agent_id`, `level`) VALUES
(103, 100, 2),
(104, 100, 2),
(105, 100, 2),
(106, 101, 2),
(107, 101, 2),
(108, 101, 2),
(109, 102, 2),
(110, 102, 2);

-- 7. 更新汇总表的团队成员统计数据
UPDATE `team_revenue_statistics_summary` SET 
`level1_downline_count` = 2, 
`total_downline_count` = 2 
WHERE `user_id` = 100;

UPDATE `team_revenue_statistics_summary` SET 
`level1_downline_count` = 2, 
`level2_downline_count` = 2, 
`total_downline_count` = 4 
WHERE `user_id` = 101;

UPDATE `team_revenue_statistics_summary` SET 
`level1_downline_count` = 2, 
`level2_downline_count` = 2, 
`total_downline_count` = 4 
WHERE `user_id` = 102;

UPDATE `team_revenue_statistics_summary` SET 
`level1_downline_count` = 2, 
`total_downline_count` = 2 
WHERE `user_id` = 103;

UPDATE `team_revenue_statistics_summary` SET 
`level1_downline_count` = 1, 
`total_downline_count` = 1 
WHERE `user_id` = 104;

UPDATE `team_revenue_statistics_summary` SET 
`level1_downline_count` = 2, 
`total_downline_count` = 2 
WHERE `user_id` = 105;