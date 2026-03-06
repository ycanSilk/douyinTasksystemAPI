/*
 Navicat Premium Dump SQL

 Source Server         : 本地数据库
 Source Server Type    : MySQL
 Source Server Version : 80406 (8.4.6)
 Source Host           : localhost:3306
 Source Schema         : task_platform

 Target Server Type    : MySQL
 Target Server Version : 80406 (8.4.6)
 File Encoding         : 65001

 Date: 06/03/2026 14:25:32
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for agent_applications
-- ----------------------------
DROP TABLE IF EXISTS `agent_applications`;
CREATE TABLE `agent_applications`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '申请ID',
  `c_user_id` bigint UNSIGNED NOT NULL COMMENT 'C端用户ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（冗余字段）',
  `invite_code` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邀请码（冗余字段）',
  `apply_type` tinyint NOT NULL DEFAULT 1 COMMENT '申请类型：1=普通团长，2=高级团长',
  `valid_invites` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '有效邀请人数（申请时的快照）',
  `total_invites` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '总邀请人数（申请时的快照）',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '审核状态：0=待审核，1=审核通过，2=审核拒绝',
  `reject_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '拒绝原因',
  `admin_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '审核管理员ID',
  `reviewed_at` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_c_user_id`(`c_user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '团长申请表-C端用户申请成为团长' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of agent_applications
-- ----------------------------
INSERT INTO `agent_applications` VALUES (1, 5, 'test', 'TX5ECJ', 1, 2, 2, 1, NULL, NULL, '2026-03-02 08:59:57', '2026-03-02 08:59:46', '2026-03-02 08:59:57');
INSERT INTO `agent_applications` VALUES (2, 5, 'test', 'TX5ECJ', 2, 2, 2, 1, NULL, NULL, '2026-03-02 09:00:21', '2026-03-02 09:00:15', '2026-03-02 09:00:21');
INSERT INTO `agent_applications` VALUES (3, 7, 'advanced1', 'W6ETMJ', 1, 1, 1, 1, NULL, NULL, '2026-03-02 09:01:55', '2026-03-02 09:01:48', '2026-03-02 09:01:55');

-- ----------------------------
-- Table structure for app_config
-- ----------------------------
DROP TABLE IF EXISTS `app_config`;
CREATE TABLE `app_config`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置键名',
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置值',
  `config_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'string' COMMENT '配置类型：string, int, float, boolean, json, array',
  `config_group` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'general' COMMENT '配置分组：general, withdraw, task, rental等',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '配置描述',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_config_key`(`config_key` ASC) USING BTREE,
  INDEX `idx_config_group`(`config_group` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 37 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '网站配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of app_config
-- ----------------------------
INSERT INTO `app_config` VALUES (1, 'website', 'https://api.kktaskpaas.com/', 'string', 'general', '网站地址', '2026-02-28 21:29:30');
INSERT INTO `app_config` VALUES (2, 'upload_path', './img', 'string', 'general', '上传文件路径', '2026-02-15 14:51:56');
INSERT INTO `app_config` VALUES (3, 'platform_fee_rate', '0.25', 'float', 'general', '平台抽成比例（0.25 = 25%）', '2026-02-15 14:51:56');
INSERT INTO `app_config` VALUES (4, 'task_submit_timeout', '600', 'int', 'task', '任务提交超时时间（秒）', '2026-02-15 14:51:56');
INSERT INTO `app_config` VALUES (7, 'c_withdraw_min_amount', '1', 'int', 'withdraw', 'C端每次提现最低金额（元）', '2026-02-23 20:53:03');
INSERT INTO `app_config` VALUES (8, 'c_withdraw_max_amount', '500', 'int', 'withdraw', 'C端每次提现最高金额（元）', '2026-02-15 14:51:56');
INSERT INTO `app_config` VALUES (9, 'c_withdraw_amount_multiple', '1', 'int', 'withdraw', 'C端提现金额必须是此数的整数倍', '2026-02-23 20:53:12');
INSERT INTO `app_config` VALUES (10, 'c_withdraw_daily_limit', '1000', 'int', 'withdraw', 'C端每天提现总额限制（元）', '2026-02-15 14:51:56');
INSERT INTO `app_config` VALUES (11, 'c_withdraw_allowed_weekdays', '0,1,2,3,4,5,6', 'array', 'withdraw', '允许提现的星期几（0=周日,1-6=周一至周六，多个用逗号分隔）', '2026-02-24 15:34:06');
INSERT INTO `app_config` VALUES (12, 'b_withdraw_min_amount', '100', 'int', 'withdraw', 'B端每次提现最低金额（元）', '2026-02-15 14:51:56');
INSERT INTO `app_config` VALUES (13, 'b_withdraw_max_amount', '5000', 'int', 'withdraw', 'B端每次提现最高金额（元）', '2026-02-15 14:51:56');
INSERT INTO `app_config` VALUES (14, 'b_withdraw_daily_limit', '10000', 'int', 'withdraw', 'B端每天提现总额限制（元）', '2026-02-15 14:51:56');
INSERT INTO `app_config` VALUES (15, 'rental_platform_rate', '25', 'int', 'rental', '租赁订单平台抽成比例（%）', '2026-02-15 14:51:56');
INSERT INTO `app_config` VALUES (16, 'rental_platform_fee_rate', '0.25', 'float', 'rental', '租赁系统平台抽成比例（小数形式，兼容旧代码）', '2026-02-15 14:51:56');
INSERT INTO `app_config` VALUES (17, 'c_withdraw_fee_rate', '0.03', 'float', 'withdraw', 'C端提现手续费比例（0.03=3%）', '2026-02-21 17:33:08');
INSERT INTO `app_config` VALUES (18, 'senior_agent_required_active_users', '2', 'int', 'task', '申请高级团长需要的有效活跃用户数', '2026-03-02 08:59:33');
INSERT INTO `app_config` VALUES (19, 'senior_agent_active_user_task_count', '1', 'int', 'task', '有效活跃用户需完成的任务数', '2026-03-02 08:42:18');
INSERT INTO `app_config` VALUES (20, 'senior_agent_active_user_hours', '48', 'int', 'task', '有效活跃用户注册后需在多少小时内完成任务', '2026-02-26 11:25:30');
INSERT INTO `app_config` VALUES (21, 'senior_agent_max_count', '100', 'int', 'task', '高级团长数量上限', '2026-02-26 11:25:39');
INSERT INTO `app_config` VALUES (23, 'agent_required_active_users', '1', 'int', 'task', '申请普通团长需要的有效活跃用户数', '2026-03-02 08:42:46');
INSERT INTO `app_config` VALUES (24, 'agent_active_user_task_count', '1', 'int', 'task', '普通团长有效活跃用户需完成的任务数', '2026-03-02 08:42:42');
INSERT INTO `app_config` VALUES (25, 'agent_active_user_hours', '24', 'int', 'task', '普通团长有效活跃用户注册后需在多少小时内完成任务', '2026-02-24 15:09:12');
INSERT INTO `app_config` VALUES (26, 'agent_incentive_enabled', '1', 'int', 'incentive', '团长激励活动开关', '2026-02-21 19:31:16');
INSERT INTO `app_config` VALUES (27, 'agent_incentive_end_time', '2099-12-31 23:59:59', 'string', 'incentive', '团长激励活动终止时间', '2026-02-21 19:24:37');
INSERT INTO `app_config` VALUES (28, 'agent_incentive_amount', '1000', 'int', 'incentive', '团长激励金额（分）', '2026-02-26 11:26:41');
INSERT INTO `app_config` VALUES (29, 'agent_incentive_min_withdraw', '10000', 'int', 'incentive', '触发激励最低提现金额（分）', '2026-02-26 11:26:36');
INSERT INTO `app_config` VALUES (30, 'agent_incentive_limit_enabled', '1', 'int', 'incentive', '人数限制开关', '2026-02-23 21:06:59');
INSERT INTO `app_config` VALUES (31, 'agent_incentive_limit_count', '5', 'int', 'incentive', '每个团长最多激励次数', '2026-02-24 15:52:44');
INSERT INTO `app_config` VALUES (32, 'rental_seller_rate', '70', 'int', 'rental', '租赁卖方分成比例（%）', '2026-02-26 11:26:20');
INSERT INTO `app_config` VALUES (33, 'rental_agent_rate', '5', 'int', 'rental', '租赁普通团长分成比例（%）', '2026-02-26 11:26:09');
INSERT INTO `app_config` VALUES (34, 'rental_senior_agent_rate', '5', 'int', 'rental', '租赁高级团长分成比例（%）', '2026-02-26 11:26:13');
INSERT INTO `app_config` VALUES (35, 'commission_c_user', '0', 'int', 'task', 'C端用户佣金比例（%）', '2026-02-26 11:25:53');
INSERT INTO `app_config` VALUES (36, 'commission_agent', '0', 'int', 'task', '团长（代理）佣金比例（%）', '2026-02-25 15:03:32');

-- ----------------------------
-- Table structure for b_tasks
-- ----------------------------
DROP TABLE IF EXISTS `b_tasks`;
CREATE TABLE `b_tasks`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `b_user_id` bigint UNSIGNED NOT NULL COMMENT 'B端用户ID',
  `combo_task_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '组合任务标识（同一组合任务共享）',
  `stage` tinyint NOT NULL DEFAULT 0 COMMENT '阶段：0=单任务，1=阶段1，2=阶段2',
  `stage_status` tinyint NOT NULL DEFAULT 1 COMMENT '阶段状态：0=未开放，1=已开放，2=已完成',
  `parent_task_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '父任务ID（阶段2指向阶段1）',
  `template_id` int UNSIGNED NOT NULL COMMENT '任务模板ID',
  `video_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '视频链接（阶段2创建时为空，等阶段1完成后分配）',
  `deadline` int UNSIGNED NOT NULL COMMENT '到期时间（10位时间戳-秒级）',
  `recommend_marks` json NULL COMMENT '推荐评论（JSON数组）',
  `task_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '任务总数量（评论数组长度）',
  `task_done` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '已完成数量（已通过审核）',
  `task_doing` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '进行中数量（C端正在做）',
  `task_reviewing` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '待审核数量（已提交待审核）',
  `unit_price` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '单价（元，从模板获取）',
  `total_price` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '总价（元，单价*数量）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=进行中，2=已完成，3=已取消，0=已过期',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `completed_at` datetime NULL DEFAULT NULL COMMENT '完成时间（任务完成时记录）',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_b_user_id`(`b_user_id` ASC) USING BTREE,
  INDEX `idx_combo_task_id`(`combo_task_id` ASC) USING BTREE,
  INDEX `idx_stage`(`stage` ASC) USING BTREE,
  INDEX `idx_stage_status`(`stage_status` ASC) USING BTREE,
  INDEX `idx_parent_task_id`(`parent_task_id` ASC) USING BTREE,
  INDEX `idx_template_id`(`template_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_deadline`(`deadline` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_completed_at`(`completed_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端发布任务表-商家派单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of b_tasks
-- ----------------------------
INSERT INTO `b_tasks` VALUES (1, 2, NULL, 0, 1, NULL, 1, '5.89 复制打开抖音，看看【辉总不累的作品】  https://v.douyin.com/jmtVNF6KEQQ/ 04/19 d@N.Wm zGI:/', 1772189758, '[{\"at_user\": \"\", \"comment\": \"还好遇见梅姐，每天肚子都吃得饱饱的😋\", \"image_url\": \"http://54.179.253.64:28806/img/6c031bd126d19509ddceb060e2c1d77f.jpg\"}, {\"at_user\": \"\", \"comment\": \"还好遇见梅姐，每天肚子都吃得饱饱的😋\", \"image_url\": \"http://54.179.253.64:28806/img/5f66e00f02b672e9ecb1cf1140586079.jpg\"}]', 2, 0, 0, 0, 3.00, 6.00, 0, '2026-02-27 18:25:58', '2026-02-27 18:56:02', NULL);
INSERT INTO `b_tasks` VALUES (2, 2, NULL, 0, 1, NULL, 2, '9:/Y.. 07/31 o@Q.Kj 复制打开抖音，查看【辉总不累】发布作品的评论：死磕，做到极致。➝➝o7wgJAyHg49ŠŠ', 1772190077, '[{\"at_user\": \"\", \"comment\": \"有你真好，梅姐\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"123456789224\", \"image_url\": \"\"}]', 2, 0, 0, 0, 2.00, 4.00, 0, '2026-02-27 18:31:19', '2026-02-27 19:02:01', NULL);
INSERT INTO `b_tasks` VALUES (3, 2, NULL, 0, 1, NULL, 1, '5-- 02/02 i@p.QX 复制打开抖音，查看【让我再次去思念】发布作品的评论：又几有道理喔，怪唔知得啲:/ 师奶咁钟意用荷花做微信头像...^^5iKugrrLi49※※', 1772293474, '[{\"at_user\": \"\", \"comment\": \"那天人山人海，没好意思去拜就走了😅 但听说真的超准！\", \"image_url\": \"\"}]', 1, 0, 0, 0, 3.00, 3.00, 0, '2026-02-28 23:34:35', '2026-02-28 23:45:01', NULL);
INSERT INTO `b_tasks` VALUES (4, 1, NULL, 0, 1, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1773072000, '[{\"comment\": \"测试上评评论\", \"image_url\": \"\"}]', 1, 0, 0, 1, 3.00, 3.00, 1, '2026-03-01 00:34:05', '2026-03-01 01:00:51', NULL);
INSERT INTO `b_tasks` VALUES (5, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1774800000, '[{\"comment\": \"新测试，单任务，上评评论,测试二级团长佣金奖励。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-02 08:47:31', '2026-03-02 08:50:13', '2026-03-02 00:50:13');
INSERT INTO `b_tasks` VALUES (6, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1774800000, '[{\"comment\": \"新测试，单任务，上评评论,测试二级团长佣金奖励。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-02 08:47:38', '2026-03-02 08:50:45', '2026-03-02 00:50:45');
INSERT INTO `b_tasks` VALUES (7, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1774800000, '[{\"comment\": \"新测试，单任务，上评评论,测试二级团长佣金奖励。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-02 08:47:40', '2026-03-02 09:01:16', '2026-03-02 01:01:16');
INSERT INTO `b_tasks` VALUES (8, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1774800000, '[{\"comment\": \"新测试，单任务，上评评论,测试二级团长佣金奖励。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-02 09:02:15', '2026-03-02 09:02:47', '2026-03-02 01:02:47');
INSERT INTO `b_tasks` VALUES (9, 3, NULL, 0, 1, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1774800000, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 0, 0, 0, 3.00, 3.00, 1, '2026-03-03 11:18:26', '2026-03-03 11:18:26', NULL);
INSERT INTO `b_tasks` VALUES (10, 3, NULL, 0, 1, NULL, 2, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1774800000, '[{\"comment\": \"新测试，单任务，中评评论18，测试高级团长邀请。\", \"image_url\": \"\"}, {\"comment\": \"新测试，单任务，中评评论18，测试高级团长邀请。\", \"image_url\": \"\"}, {\"comment\": \"新测试，单任务，中评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 3, 0, 0, 0, 2.00, 6.00, 1, '2026-03-03 11:20:37', '2026-03-03 11:20:37', NULL);

-- ----------------------------
-- Table structure for b_users
-- ----------------------------
DROP TABLE IF EXISTS `b_users`;
CREATE TABLE `b_users`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'B端用户ID',
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（必填，登录账号）',
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邮箱（必填）',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号（选填）',
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码哈希',
  `organization_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '组织名称',
  `organization_leader` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '组织负责人名称',
  `token` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前有效Token（base64格式）',
  `token_expired_at` datetime NULL DEFAULT NULL COMMENT 'Token过期时间',
  `wallet_id` bigint UNSIGNED NOT NULL COMMENT '关联钱包ID',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=正常，0=禁用',
  `reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '禁用原因',
  `create_ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '注册IP地址（支持IPv6）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_email`(`email` ASC) USING BTREE,
  UNIQUE INDEX `uk_phone`(`phone` ASC) USING BTREE,
  INDEX `idx_token`(`token`(255) ASC) USING BTREE,
  INDEX `idx_wallet_id`(`wallet_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端用户表-商家端' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of b_users
-- ----------------------------
INSERT INTO `b_users` VALUES (1, 'Ceshi', '271010169@qq.com', NULL, '$2y$10$SV7dHV/yam2IcgV5SmbbKur8TrpohySzBEQ032nQouiOnaBgmTWp6', 'Meili', 'Meili', 'eyJ1c2VyX2lkIjoxLCJ0eXBlIjoyLCJleHAiOjE3NzMyMjMxNDZ9', '2026-03-11 09:59:06', 1, 1, NULL, '34.143.229.197', '2026-02-27 11:49:20', '2026-03-04 17:59:06');
INSERT INTO `b_users` VALUES (2, 'Ceshi1', '459312160@qq.com', NULL, '$2y$10$F0HHwcgbu5Qh.xkir2UCcul4OHQPBYXwr970M4kIFVmdeZaDeh6ca', 'Meili', 'Meili', 'eyJ1c2VyX2lkIjoyLCJ0eXBlIjoyLCJleHAiOjE3NzI4OTc1MjZ9', '2026-03-07 23:32:06', 2, 1, NULL, '34.143.229.197', '2026-02-27 12:02:50', '2026-02-28 23:32:06');
INSERT INTO `b_users` VALUES (3, 'task', 'task@qq.com', NULL, '$2y$10$0PP6e.WnVHlu89mCdThwjemgzakVTpxzv021Cib9Yf/HULOolAhfK', 'task', 'task', 'eyJ1c2VyX2lkIjozLCJ0eXBlIjoyLCJleHAiOjE3NzMyMjMxMTJ9', '2026-03-11 09:58:32', 7, 1, NULL, '223.74.60.135', '2026-03-01 00:48:16', '2026-03-04 17:58:32');

-- ----------------------------
-- Table structure for c_task_records
-- ----------------------------
DROP TABLE IF EXISTS `c_task_records`;
CREATE TABLE `c_task_records`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `c_user_id` bigint UNSIGNED NOT NULL COMMENT 'C端用户ID',
  `b_task_id` bigint UNSIGNED NOT NULL COMMENT 'B端任务ID',
  `b_user_id` bigint UNSIGNED NOT NULL COMMENT 'B端用户ID（发布者）',
  `template_id` int UNSIGNED NOT NULL COMMENT '任务模板ID',
  `video_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '视频链接',
  `recommend_mark` json NULL COMMENT '分配的推荐评论（comment和image_url）',
  `comment_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户提交的评论链接',
  `screenshot_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户提交的截图',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=进行中(doing)，2=待审核(reviewing)，3=已通过(approved)，4=已驳回(rejected)',
  `reject_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '驳回原因',
  `reward_amount` bigint NOT NULL DEFAULT 0 COMMENT '奖励金额（单位：分）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '接单时间',
  `submitted_at` datetime NULL DEFAULT NULL COMMENT '提交时间',
  `reviewed_at` datetime NULL DEFAULT NULL COMMENT '审核时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_c_user_b_task`(`c_user_id` ASC, `b_task_id` ASC) USING BTREE,
  INDEX `idx_c_user_id`(`c_user_id` ASC) USING BTREE,
  INDEX `idx_b_task_id`(`b_task_id` ASC) USING BTREE,
  INDEX `idx_b_user_id`(`b_user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端任务记录表-接单执行审核全流程' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of c_task_records
-- ----------------------------
INSERT INTO `c_task_records` VALUES (1, 2, 2, 2, 2, '9:/Y.. 07/31 o@Q.Kj 复制打开抖音，查看【辉总不累】发布作品的评论：死磕，做到极致。➝➝o7wgJAyHg49ŠŠ', '{\"at_user\": \"\", \"comment\": \"123456789224\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 80, '2026-02-27 18:31:47', NULL, NULL);
INSERT INTO `c_task_records` VALUES (2, 3, 2, 2, 2, '9:/Y.. 07/31 o@Q.Kj 复制打开抖音，查看【辉总不累】发布作品的评论：死磕，做到极致。➝➝o7wgJAyHg49ŠŠ', '{\"at_user\": \"\", \"comment\": \"有你真好，梅姐\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 80, '2026-02-27 18:36:54', NULL, NULL);
INSERT INTO `c_task_records` VALUES (3, 2, 4, 1, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试上评评论\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 100, '2026-03-01 00:36:33', NULL, NULL);
INSERT INTO `c_task_records` VALUES (4, 5, 4, 1, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试上评评论\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"\"]', 2, NULL, 100, '2026-03-01 01:00:34', '2026-03-01 01:00:51', NULL);
INSERT INTO `c_task_records` VALUES (5, 6, 5, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论,测试二级团长佣金奖励。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/35efa290342aaaec4560b84d2e134463.jpg\"]', 3, NULL, 100, '2026-03-02 08:48:28', '2026-03-02 00:49:21', '2026-03-02 00:50:13');
INSERT INTO `c_task_records` VALUES (6, 7, 6, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论,测试二级团长佣金奖励。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/35efa290342aaaec4560b84d2e134463.jpg\"]', 3, NULL, 100, '2026-03-02 08:49:47', '2026-03-02 00:49:57', '2026-03-02 00:50:45');
INSERT INTO `c_task_records` VALUES (7, 8, 7, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论,测试二级团长佣金奖励。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/35efa290342aaaec4560b84d2e134463.jpg\"]', 3, NULL, 100, '2026-03-02 09:00:54', '2026-03-02 01:01:05', '2026-03-02 01:01:16');
INSERT INTO `c_task_records` VALUES (8, 8, 8, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论,测试二级团长佣金奖励。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/35efa290342aaaec4560b84d2e134463.jpg\"]', 3, NULL, 100, '2026-03-02 09:02:23', '2026-03-02 01:02:36', '2026-03-02 01:02:47');

-- ----------------------------
-- Table structure for c_user_daily_stats
-- ----------------------------
DROP TABLE IF EXISTS `c_user_daily_stats`;
CREATE TABLE `c_user_daily_stats`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `c_user_id` bigint UNSIGNED NOT NULL COMMENT 'C端用户ID',
  `stat_date` date NOT NULL COMMENT '统计日期',
  `accept_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '当日接单次数',
  `submit_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '当日提交次数',
  `approved_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '当日通过次数',
  `rejected_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '当日驳回次数',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_date`(`c_user_id` ASC, `stat_date` ASC) USING BTREE,
  INDEX `idx_c_user_id`(`c_user_id` ASC) USING BTREE,
  INDEX `idx_stat_date`(`stat_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端用户每日统计表-限制驳回次数' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of c_user_daily_stats
-- ----------------------------
INSERT INTO `c_user_daily_stats` VALUES (1, 2, '2026-02-27', 1, 0, 0, 0, '2026-02-27 18:31:47', '2026-02-27 18:31:47');
INSERT INTO `c_user_daily_stats` VALUES (2, 3, '2026-02-27', 1, 0, 0, 0, '2026-02-27 18:36:54', '2026-02-27 18:36:54');
INSERT INTO `c_user_daily_stats` VALUES (3, 2, '2026-03-01', 1, 0, 0, 0, '2026-03-01 00:36:33', '2026-03-01 00:36:33');
INSERT INTO `c_user_daily_stats` VALUES (4, 5, '2026-03-01', 1, 1, 0, 0, '2026-03-01 01:00:34', '2026-03-01 01:00:51');
INSERT INTO `c_user_daily_stats` VALUES (5, 6, '2026-03-02', 1, 1, 1, 0, '2026-03-02 08:48:28', '2026-03-02 08:50:13');
INSERT INTO `c_user_daily_stats` VALUES (6, 7, '2026-03-02', 1, 1, 1, 0, '2026-03-02 08:49:47', '2026-03-02 08:50:45');
INSERT INTO `c_user_daily_stats` VALUES (7, 8, '2026-03-02', 2, 2, 2, 0, '2026-03-02 09:00:54', '2026-03-02 09:02:47');

-- ----------------------------
-- Table structure for c_users
-- ----------------------------
DROP TABLE IF EXISTS `c_users`;
CREATE TABLE `c_users`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'C端用户ID',
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（必填，登录账号）',
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邮箱（必填）',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号（选填）',
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码哈希',
  `invite_code` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邀请码（6位数字字母组合，唯一）',
  `parent_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '上级用户ID（邀请人ID）',
  `is_agent` tinyint NOT NULL DEFAULT 0 COMMENT '代理身份：0=未激活团长，1=团长',
  `token` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前有效Token（base64格式）',
  `token_expired_at` datetime NULL DEFAULT NULL COMMENT 'Token过期时间',
  `wallet_id` bigint UNSIGNED NOT NULL COMMENT '关联钱包ID',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=正常，0=禁用',
  `reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '禁用原因',
  `create_ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '注册IP地址（支持IPv6）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_email`(`email` ASC) USING BTREE,
  UNIQUE INDEX `uk_invite_code`(`invite_code` ASC) USING BTREE,
  UNIQUE INDEX `uk_phone`(`phone` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  INDEX `idx_is_agent`(`is_agent` ASC) USING BTREE,
  INDEX `idx_token`(`token`(255) ASC) USING BTREE,
  INDEX `idx_wallet_id`(`wallet_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端用户表-消费者端' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of c_users
-- ----------------------------
INSERT INTO `c_users` VALUES (1, 'taskadmin', 'taskadmin@qq.com', NULL, '$2y$10$9gww7TqOTzSA9SqchkFEgeYftRKlJ4ciYWL6IiD8DPUbQv8/PnCGe', 'W6XMFJ', NULL, 0, 'eyJ1c2VyX2lkIjoxLCJ0eXBlIjoxLCJleHAiOjE3NzI3NzM1OTN9', '2026-03-06 13:06:33', 3, 1, NULL, '120.237.23.202', '2026-02-27 13:06:22', '2026-02-27 13:06:33');
INSERT INTO `c_users` VALUES (2, 'Ceshi', '12345678@qq.com', '13112345678', '$2y$10$lvlxvu.NzhAs6m7ID2fNg.lSn.cl/hytp6/1XIAEVeA3RRYtmmH4u', '6YHUBA', NULL, 0, 'eyJ1c2VyX2lkIjoyLCJ0eXBlIjoxLCJleHAiOjE3NzI5MDI3MTZ9', '2026-03-08 00:58:36', 4, 1, NULL, '34.143.229.197', '2026-02-27 17:24:33', '2026-03-01 00:58:36');
INSERT INTO `c_users` VALUES (3, 'Ceshi2', '123456789@qq.com', '13212345678', '$2y$10$Cvl7CIY5Oj2gPcKSvNE2mONLRs14Rr1ndstVn2FHJlco8GmXxS586', 'MCVFM9', NULL, 0, 'eyJ1c2VyX2lkIjozLCJ0eXBlIjoxLCJleHAiOjE3NzI3OTMxODh9', '2026-03-06 18:33:08', 5, 1, NULL, '34.143.229.197', '2026-02-27 17:26:28', '2026-02-27 18:33:08');
INSERT INTO `c_users` VALUES (4, 'Ceshi3', '123455677@qq.com', '13312345678', '$2y$10$qydW3B1EXlxJou5CUfPMaOvssOD/K8GugvQh.BeeX/KGBpPGC3awq', 'CZBBF5', NULL, 0, 'eyJ1c2VyX2lkIjo0LCJ0eXBlIjoxLCJleHAiOjE3NzI3ODk0Njh9', '2026-03-06 17:31:08', 6, 1, NULL, '34.143.229.197', '2026-02-27 17:31:08', '2026-02-27 17:31:08');
INSERT INTO `c_users` VALUES (5, 'test', 'test@qq.com', '15900000011', '$2y$12$TWASecPCWbA7IGN2lYJ.CO0HfcYhneMFTTEJnfMEP70FFP72GTolq', 'TX5ECJ', NULL, 2, 'eyJ1c2VyX2lkIjo1LCJ0eXBlIjoxLCJleHAiOjE3NzMxMTI3Mjd9', '2026-03-10 03:18:47', 8, 1, NULL, '223.74.60.135', '2026-03-01 00:53:23', '2026-03-03 11:18:47');
INSERT INTO `c_users` VALUES (6, 'advanced', 'advanced@qq.com', '15900000012', '$2y$12$UzfbaB5WqB1mqAXzaOL8BOeoJnp0CggDey/IDBy49nG95iHu9qEI6', '425EZK', 5, 0, 'eyJ1c2VyX2lkIjo2LCJ0eXBlIjoxLCJleHAiOjE3NzMxMTQzMjJ9', '2026-03-10 03:45:22', 9, 1, NULL, '::1', '2026-03-02 08:44:59', '2026-03-03 11:45:22');
INSERT INTO `c_users` VALUES (7, 'advanced1', 'advanced1@qq.com', '15900000013', '$2y$12$SYATdlDZJxMQmgO1NpgwgeCCan4Kf2Bp7Zc94uyflZy47WJhhN6k2', 'W6ETMJ', 5, 1, 'eyJ1c2VyX2lkIjo3LCJ0eXBlIjoxLCJleHAiOjE3NzMwMjAxNjF9', '2026-03-09 01:36:01', 10, 1, NULL, '::1', '2026-03-02 08:45:16', '2026-03-02 09:36:01');
INSERT INTO `c_users` VALUES (8, 'advanced3', 'advanced3@qq.com', '15900000014', '$2y$12$mGdZI1esf1mpZFue06uOhOhIf8nOlS7zWksDa5Y4uPTdvIo6Fl1uC', 'RHYMHT', 7, 0, 'eyJ1c2VyX2lkIjo4LCJ0eXBlIjoxLCJleHAiOjE3NzMwMTgxMjd9', '2026-03-09 01:02:07', 11, 1, NULL, '::1', '2026-03-02 08:45:58', '2026-03-02 09:02:07');

-- ----------------------------
-- Table structure for notifications
-- ----------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '通知ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知内容',
  `target_type` tinyint NOT NULL DEFAULT 0 COMMENT '目标类型：0=全体，1=C端全体，2=B端全体，3=指定用户',
  `target_user_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '目标用户ID（target_type=3时使用）',
  `target_user_type` tinyint NULL DEFAULT NULL COMMENT '目标用户类型（target_type=3时使用，1=C端，2=B端）',
  `sender_type` tinyint NOT NULL DEFAULT 3 COMMENT '发送者类型：1=系统自动，3=Admin',
  `sender_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '发送者ID（Admin ID，预留字段）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_target_type`(`target_type` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统通知表-通知模板' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notifications
-- ----------------------------
INSERT INTO `notifications` VALUES (1, '充值审核通过', '您的充值申请已审核通过，金额：¥1,000.00 已到账。感谢您的使用！', 3, 1, 2, 1, NULL, '2026-02-27 12:49:56');
INSERT INTO `notifications` VALUES (2, '充值审核通过', '您的充值申请已审核通过，金额：¥1,000.00 已到账。感谢您的使用！', 3, 2, 2, 1, NULL, '2026-02-27 12:49:58');
INSERT INTO `notifications` VALUES (3, '充值审核通过', '您的充值申请已审核通过，金额：¥100.00 已到账。感谢您的使用！', 3, 2, 2, 1, NULL, '2026-02-27 14:23:06');
INSERT INTO `notifications` VALUES (4, '充值审核通过', '您的充值申请已审核通过，金额：¥1,000.00 已到账。感谢您的使用！', 3, 1, 2, 1, NULL, '2026-02-27 14:23:08');
INSERT INTO `notifications` VALUES (5, '充值审核通过', '您的充值申请已审核通过，金额：¥1,000.00 已到账。感谢您的使用！', 3, 2, 2, 1, NULL, '2026-02-27 14:23:13');
INSERT INTO `notifications` VALUES (6, '收到新的应征申请', '您的求租「抖音日租」收到了新的应征，请前往查看审核', 3, 2, 2, 1, NULL, '2026-02-27 17:54:24');
INSERT INTO `notifications` VALUES (7, '任务已超时', '您接取的任务「中评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-02-27 18:31:47\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。', 3, 2, 1, 1, NULL, '2026-02-27 18:42:02');
INSERT INTO `notifications` VALUES (8, '任务已超时', '您接取的任务「中评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-02-27 18:36:54\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。', 3, 3, 1, 1, NULL, '2026-02-27 18:47:02');
INSERT INTO `notifications` VALUES (9, '任务已到期下架', '您发布的任务「上评评论」已到期自动下架。\n任务进度：0/2（0%）\n截止时间：2026-02-27 18:55:58\n', 3, 2, 2, 1, NULL, '2026-02-27 18:56:02');
INSERT INTO `notifications` VALUES (10, '任务已到期下架', '您发布的任务「中评评论」已到期自动下架。\n任务进度：0/2（0%）\n截止时间：2026-02-27 19:01:17\n', 3, 2, 2, 1, NULL, '2026-02-27 19:02:01');
INSERT INTO `notifications` VALUES (11, '充值审核通过', '您的充值申请已审核通过，金额：¥200.00 已到账。感谢您的使用！', 3, 1, 2, 1, NULL, '2026-02-28 23:20:14');
INSERT INTO `notifications` VALUES (12, '任务已到期下架', '您发布的任务「上评评论」已到期自动下架。\n任务进度：0/1（0%）\n截止时间：2026-02-28 23:44:34\n', 3, 2, 2, 1, NULL, '2026-02-28 23:45:01');
INSERT INTO `notifications` VALUES (13, '求租已过期', '您的求租「抖音日租」已过期，预算金额已退回您的钱包。', 3, 2, 2, 1, NULL, '2026-03-01 00:00:04');
INSERT INTO `notifications` VALUES (14, '任务已超时', '您接取的任务「上评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-03-01 00:36:33\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。', 3, 2, 1, 1, NULL, '2026-03-01 00:47:02');
INSERT INTO `notifications` VALUES (15, '充值审核通过', '您的充值申请已审核通过，金额：¥2,000.00 已到账。感谢您的使用！', 3, 3, 2, 1, NULL, '2026-03-01 00:51:51');
INSERT INTO `notifications` VALUES (16, '收到新的应征申请', '您的求租「测试求租发布」收到了新的应征，请前往查看审核', 3, 3, 2, 1, NULL, '2026-03-01 00:55:31');
INSERT INTO `notifications` VALUES (17, '收到新的应征申请', '您的求租「测试求租发布」收到了新的应征，请前往查看审核', 3, 3, 2, 1, NULL, '2026-03-01 00:56:41');
INSERT INTO `notifications` VALUES (18, '恭喜！团长申请已通过', '恭喜您！您的团长申请已审核通过。\n\n现在您可以享受以下权益：\n• 推广邀请码，获得下线用户\n• 下线完成任务时，您可获得佣金分成\n\n邀请码：TX5ECJ', 3, 5, 1, 1, NULL, '2026-03-02 08:59:57');
INSERT INTO `notifications` VALUES (19, '恭喜！高级团长申请已通过', '恭喜您！您的高级团长申请已审核通过。\n\n高级团长权益已生效，佣金将按高级团长标准结算。\n\n邀请码：TX5ECJ', 3, 5, 1, 1, NULL, '2026-03-02 09:00:21');
INSERT INTO `notifications` VALUES (20, '恭喜！团长申请已通过', '恭喜您！您的团长申请已审核通过。\n\n现在您可以享受以下权益：\n• 推广邀请码，获得下线用户\n• 下线完成任务时，您可获得佣金分成\n\n邀请码：W6ETMJ', 3, 7, 1, 1, NULL, '2026-03-02 09:01:55');
INSERT INTO `notifications` VALUES (21, '收到新的应征申请', '您的求租「测试求租发布」收到了新的应征，请前往查看审核', 3, 3, 2, 1, NULL, '2026-03-02 09:35:15');
INSERT INTO `notifications` VALUES (22, '收到新的应征申请', '您的求租「测试求租发布」收到了新的应征，请前往查看审核', 3, 3, 2, 1, NULL, '2026-03-02 09:35:48');
INSERT INTO `notifications` VALUES (23, '收到新的应征申请', '您的求租「测试求租发布」收到了新的应征，请前往查看审核', 3, 3, 2, 1, NULL, '2026-03-02 09:36:17');

-- ----------------------------
-- Table structure for recharge_requests
-- ----------------------------
DROP TABLE IF EXISTS `recharge_requests`;
CREATE TABLE `recharge_requests`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '充值申请ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '用户ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（冗余字段）',
  `user_type` tinyint NOT NULL COMMENT '用户类型：1=C端，2=B端',
  `wallet_id` bigint UNSIGNED NOT NULL COMMENT '钱包ID',
  `amount` bigint NOT NULL DEFAULT 0 COMMENT '充值金额（单位：分）',
  `payment_method` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '支付方式：alipay=支付宝，wechat=微信，usdt=USDT',
  `payment_voucher` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '支付凭证图片URL',
  `log_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '关联的钱包流水ID',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '审核状态：0=待审核，1=审核通过，2=审核拒绝',
  `reject_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '拒绝原因',
  `admin_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '审核管理员ID',
  `reviewed_at` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_user_type`(`user_type` ASC) USING BTREE,
  INDEX `idx_wallet_id`(`wallet_id` ASC) USING BTREE,
  INDEX `idx_log_id`(`log_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '充值申请表-需要管理员审核' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of recharge_requests
-- ----------------------------
INSERT INTO `recharge_requests` VALUES (1, 2, 'Ceshi1', 2, 2, 100000, 'alipay', 'http://54.179.253.64:28806/img/344ccc2b0873c9f91547ebce99c6434a.jpg', 1, 1, NULL, NULL, '2026-02-27 12:49:58', '2026-02-27 12:49:30');
INSERT INTO `recharge_requests` VALUES (2, 1, 'Ceshi', 2, 1, 100000, 'alipay', 'http://54.179.253.64:28806/img/344ccc2b0873c9f91547ebce99c6434a.jpg', 2, 1, NULL, NULL, '2026-02-27 12:49:56', '2026-02-27 12:49:46');
INSERT INTO `recharge_requests` VALUES (3, 2, 'Ceshi1', 2, 2, 100000, 'alipay', 'http://54.179.253.64:28806/img/5bd3c8f2949429377aeb618b1806bc00.jpg', 5, 1, NULL, NULL, '2026-02-27 14:23:13', '2026-02-27 13:17:34');
INSERT INTO `recharge_requests` VALUES (4, 1, 'Ceshi', 2, 1, 100000, 'alipay', 'http://54.179.253.64:28806/img/611c57187a88a0ff7dd2b378c6f265e1.jpg', 6, 1, NULL, NULL, '2026-02-27 14:23:08', '2026-02-27 13:18:09');
INSERT INTO `recharge_requests` VALUES (5, 2, 'Ceshi1', 2, 2, 10000, 'alipay', 'http://54.179.253.64:28806/img/ce3b52d16e59e4e5a46be99e18739ecd.jpg', 8, 1, NULL, NULL, '2026-02-27 14:23:06', '2026-02-27 14:22:20');
INSERT INTO `recharge_requests` VALUES (6, 1, 'Ceshi', 2, 1, 20000, 'alipay', 'https://api.kktaskpaas.com/img/15a21bda57f6cf3bc0a05e68292a82d6.jpg', 14, 1, NULL, NULL, '2026-02-28 23:20:14', '2026-02-28 23:20:05');
INSERT INTO `recharge_requests` VALUES (7, 3, 'task', 2, 7, 200000, 'alipay', 'https://api.kktaskpaas.com/img/15a21bda57f6cf3bc0a05e68292a82d6.jpg', 19, 1, NULL, NULL, '2026-03-01 00:51:51', '2026-03-01 00:51:42');

-- ----------------------------
-- Table structure for rental_applications
-- ----------------------------
DROP TABLE IF EXISTS `rental_applications`;
CREATE TABLE `rental_applications`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '应征ID',
  `demand_id` bigint UNSIGNED NOT NULL COMMENT '关联的求租信息ID',
  `applicant_user_id` bigint UNSIGNED NOT NULL COMMENT '应征者用户ID',
  `applicant_user_type` tinyint NOT NULL COMMENT '应征者类型：1=C端，2=B端',
  `allow_renew` tinyint NOT NULL DEFAULT 1 COMMENT '是否允许续租：0=不允许，1=允许',
  `application_json` json NULL COMMENT '应征资料（账号截图、说明等）',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态：0=待审核，1=审核通过（自动生成订单），2=已驳回',
  `review_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审核备注（通过/驳回原因）',
  `reviewed_at` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_demand_id`(`demand_id` ASC) USING BTREE,
  INDEX `idx_applicant`(`applicant_user_id` ASC, `applicant_user_type` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '求租应征表-我有符合要求的账号' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rental_applications
-- ----------------------------
INSERT INTO `rental_applications` VALUES (1, 1, 3, 1, 1, '{\"apply_days\": 1, \"description\": \"无异常，及时回复\", \"screenshots\": [\"https://api.kktaskpaas.com/img/35efa290342aaaec4560b84d2e134463.jpg\"]}', 0, NULL, NULL, '2026-02-27 17:54:24', '2026-02-28 23:21:52');
INSERT INTO `rental_applications` VALUES (2, 2, 5, 1, 0, '{\"description\": \"账号正常，及时回复消息\", \"screenshots\": [\"https://api.kktaskpaas.com/img/15a21bda57f6cf3bc0a05e68292a82d6.jpg\"]}', 0, NULL, NULL, '2026-03-01 00:55:31', '2026-03-01 00:55:31');
INSERT INTO `rental_applications` VALUES (3, 2, 2, 1, 0, '{\"description\": \"账号正常，及时回复消息,第二个接单用户应征\", \"screenshots\": [\"https://api.kktaskpaas.com/img/15a21bda57f6cf3bc0a05e68292a82d6.jpg\"]}', 0, NULL, NULL, '2026-03-01 00:56:41', '2026-03-01 00:56:41');
INSERT INTO `rental_applications` VALUES (4, 3, 8, 1, 0, '{\"description\": \"我来应征申请，测试应征人数数量\", \"screenshots\": [\"https://api.kktaskpaas.com/img/35efa290342aaaec4560b84d2e134463.jpg\"]}', 0, NULL, NULL, '2026-03-02 09:35:15', '2026-03-02 09:35:15');
INSERT INTO `rental_applications` VALUES (5, 2, 8, 1, 0, '{\"description\": \"我来应征申请，测试应征人数数量\", \"screenshots\": [\"https://api.kktaskpaas.com/img/35efa290342aaaec4560b84d2e134463.jpg\"]}', 0, NULL, NULL, '2026-03-02 09:35:48', '2026-03-02 09:35:48');
INSERT INTO `rental_applications` VALUES (6, 3, 7, 1, 0, '{\"description\": \"我来应征申请，测试应征人数数量\", \"screenshots\": [\"https://api.kktaskpaas.com/img/35efa290342aaaec4560b84d2e134463.jpg\"]}', 0, NULL, NULL, '2026-03-02 09:36:17', '2026-03-02 09:36:17');

-- ----------------------------
-- Table structure for rental_demands
-- ----------------------------
DROP TABLE IF EXISTS `rental_demands`;
CREATE TABLE `rental_demands`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '求租信息ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '求租方用户ID',
  `user_type` tinyint NOT NULL COMMENT '求租方类型：1=C端，2=B端',
  `wallet_id` bigint UNSIGNED NOT NULL COMMENT '钱包ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `budget_amount` bigint NOT NULL DEFAULT 0 COMMENT '预算金额（单位：分，发布时冻结）',
  `days_needed` int UNSIGNED NOT NULL COMMENT '需要租用天数',
  `deadline` datetime NOT NULL COMMENT '截止时间（最多30天）',
  `requirements_json` json NULL COMMENT '账号要求、登录要求等详细需求',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0=已下架（释放冻结），1=发布中（预算已冻结），2=已成交（订单生成），3=已过期（自动下架，释放冻结）',
  `view_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '浏览次数',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user`(`user_id` ASC, `user_type` ASC) USING BTREE,
  INDEX `idx_wallet_id`(`wallet_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_deadline`(`deadline` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '求租信息表-账号需求市场' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rental_demands
-- ----------------------------
INSERT INTO `rental_demands` VALUES (1, 2, 2, 2, '抖音日租', 5000, 1, '2026-03-01 00:00:00', '{\"email\": \"\", \"post_ad\": 0, \"qq_number\": \"271010123\", \"scan_code\": 1, \"deblocking\": 1, \"post_douyin\": 0, \"phone_number\": \"\", \"phone_message\": 1, \"platform_type\": \"douyin\", \"requested_all\": 1, \"account_password\": 0, \"basic_information\": 1, \"other_requirements\": 1, \"account_requirements\": \"账号正常，及时回复消息\", \"additional_requirements\": \"\", \"additional_requirements_tag\": 0}', 3, 9, '2026-02-27 13:47:33', '2026-03-01 00:00:04');
INSERT INTO `rental_demands` VALUES (2, 3, 2, 7, '测试求租发布', 5000, 2, '2026-03-10 00:00:00', '{\"deblocking\": \"true\", \"phone_number\": \"13912340001\", \"phone_message\": \"true\", \"basic_information\": \"账号正常，及时回复消息\"}', 1, 1, '2026-03-01 00:52:02', '2026-03-01 00:54:39');
INSERT INTO `rental_demands` VALUES (3, 3, 2, 7, '测试求租发布', 2000, 2, '2026-03-29 16:00:00', '{\"deblocking\": \"true\", \"phone_number\": \"13912340001\", \"phone_message\": \"true\", \"basic_information\": \"求租账号，要求账号正常，及时回复消息\"}', 1, 0, '2026-03-02 09:32:29', '2026-03-02 09:33:26');

-- ----------------------------
-- Table structure for rental_offers
-- ----------------------------
DROP TABLE IF EXISTS `rental_offers`;
CREATE TABLE `rental_offers`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '出租信息ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '出租方用户ID',
  `user_type` tinyint NOT NULL COMMENT '出租方类型：1=C端，2=B端',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `price_per_day` bigint NOT NULL DEFAULT 0 COMMENT '日租金（单位：分）',
  `min_days` int UNSIGNED NOT NULL DEFAULT 1 COMMENT '最少租赁天数',
  `max_days` int UNSIGNED NOT NULL DEFAULT 30 COMMENT '最多租赁天数',
  `allow_renew` tinyint NOT NULL DEFAULT 0 COMMENT '是否允许续租：0=不允许，1=允许',
  `content_json` json NULL COMMENT '详细内容（账号能力、登录方式、说明、截图等）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0=已下架，1=上架中，2=已封禁',
  `view_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '浏览次数',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user`(`user_id` ASC, `user_type` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_price`(`price_per_day` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '出租信息表-账号出租市场' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rental_offers
-- ----------------------------
INSERT INTO `rental_offers` VALUES (1, 2, 2, '抖音号日租', 5000, 1, 30, 1, '{\"email\": \"\", \"images\": [\"https://api.kktaskpaas.com/img/35efa290342aaaec4560b84d2e134463.jpg\"], \"post_ad\": \"false\", \"qq_number\": \"\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"false\", \"account_info\": \"信息真实，账号正常，及时响应回消息\", \"phone_number\": \"13112345678\", \"other_require\": \"false\", \"phone_message\": \"false\", \"platform_type\": \"douyin\", \"account_password\": \"false\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}', 1, 3, '2026-02-27 13:31:54', '2026-02-28 21:31:26');
INSERT INTO `rental_offers` VALUES (2, 1, 2, 'QQ号月租', 5000, 30, 31, 1, '{\"email\": \"\", \"images\": [\"https://api.kktaskpaas.com/img/35efa290342aaaec4560b84d2e134463.jpg\"], \"post_ad\": \"false\", \"qq_number\": \"\", \"scan_code\": \"true\", \"deblocking\": \"false\", \"post_douyin\": \"false\", \"account_info\": \"信息真实，账号无异常，回应消息及时\", \"phone_number\": \"13112345678\", \"other_require\": \"false\", \"phone_message\": \"false\", \"platform_type\": \"qq\", \"account_password\": \"true\", \"basic_information\": \"false\", \"identity_verification\": \"false\"}', 1, 4, '2026-02-27 13:32:43', '2026-02-28 21:31:36');
INSERT INTO `rental_offers` VALUES (3, 2, 2, 'QQ号日租', 5000, 1, 30, 0, '{\"email\": \"\", \"images\": [\"https://api.kktaskpaas.com/img/35efa290342aaaec4560b84d2e134463.jpg\"], \"post_ad\": \"true\", \"qq_number\": \"\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"false\", \"account_info\": \"账号真实有效，无异常，及时回应租客消息\", \"phone_number\": \"13794719208\", \"other_require\": \"false\", \"phone_message\": \"false\", \"platform_type\": \"qq\", \"account_password\": \"true\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}', 1, 0, '2026-02-28 03:27:04', '2026-02-28 21:31:46');
INSERT INTO `rental_offers` VALUES (4, 2, 2, '发布抖音日租', 5000, 1, 30, 0, '{\"email\": \"\", \"images\": [\"https://api.kktaskpaas.com/img/35efa290342aaaec4560b84d2e134463.jpg\"], \"post_ad\": \"false\", \"qq_number\": \"\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"账号真实有效，无异常，及时回应租客消息\", \"phone_number\": \"13794719208\", \"other_require\": \"false\", \"phone_message\": \"true\", \"platform_type\": \"douyin\", \"account_password\": \"false\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}', 1, 0, '2026-02-28 03:31:37', '2026-02-28 21:31:56');
INSERT INTO `rental_offers` VALUES (5, 2, 2, '发布抖音日租', 5000, 1, 30, 0, '{\"email\": \"\", \"images\": [\"https://api.kktaskpaas.com/img/35efa290342aaaec4560b84d2e134463.jpg\"], \"post_ad\": \"false\", \"qq_number\": \"\", \"scan_code\": \"true\", \"deblocking\": \"false\", \"post_douyin\": \"true\", \"account_info\": \"账号真实有效，无异常，及时回应租客消息\", \"phone_number\": \"13794719208\", \"other_require\": \"false\", \"phone_message\": \"false\", \"platform_type\": \"douyin\", \"account_password\": \"false\", \"basic_information\": \"false\", \"identity_verification\": \"false\"}', 1, 0, '2026-02-28 03:35:12', '2026-02-28 21:32:05');

-- ----------------------------
-- Table structure for rental_orders
-- ----------------------------
DROP TABLE IF EXISTS `rental_orders`;
CREATE TABLE `rental_orders`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `source_type` tinyint NOT NULL COMMENT '来源类型：0=出租信息成交，1=求租信息成交',
  `source_id` bigint UNSIGNED NOT NULL COMMENT '来源ID（offer_id或demand_id）',
  `buyer_user_id` bigint UNSIGNED NOT NULL COMMENT '买方（租用方）用户ID',
  `buyer_user_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '买方类型：b=B端，c=C端',
  `buyer_wallet_id` bigint UNSIGNED NOT NULL COMMENT '买方钱包ID',
  `buyer_info_json` json NULL COMMENT '买方详细信息（求租需求/下单备注等）',
  `seller_user_id` bigint UNSIGNED NOT NULL COMMENT '卖方（出租方）用户ID',
  `seller_user_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '卖方类型：b=B端，c=C端',
  `seller_wallet_id` bigint UNSIGNED NOT NULL COMMENT '卖方钱包ID',
  `seller_info_json` json NULL COMMENT '卖方详细信息（账号信息/应征资料等）',
  `agent_user_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '团长用户ID',
  `agent_amount` bigint NOT NULL DEFAULT 0 COMMENT '团长佣金金额（分）',
  `total_amount` bigint NOT NULL COMMENT '订单总金额（单位：分）',
  `platform_amount` bigint NOT NULL DEFAULT 0 COMMENT '平台抽成金额（单位：分）',
  `seller_amount` bigint NOT NULL DEFAULT 0 COMMENT '卖方实得金额（单位：分）',
  `days` int UNSIGNED NOT NULL COMMENT '租赁天数',
  `allow_renew` tinyint NOT NULL DEFAULT 0 COMMENT '是否允许续租：0=不允许，1=允许',
  `order_json` json NULL COMMENT '订单额外数据（价格快照等）',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态：0=待支付，1=已支付/待客服，2=进行中，3=已完成，4=已取消',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `second_agent_user_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '二级代理用户ID',
  `second_agent_amount` bigint NOT NULL DEFAULT 0 COMMENT '二级代理佣金金额',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_source`(`source_type` ASC, `source_id` ASC) USING BTREE,
  INDEX `idx_buyer`(`buyer_user_id` ASC, `buyer_user_type` ASC) USING BTREE,
  INDEX `idx_seller`(`seller_user_id` ASC, `seller_user_type` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '租赁订单表-成交订单记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rental_orders
-- ----------------------------

-- ----------------------------
-- Table structure for rental_ticket_messages
-- ----------------------------
DROP TABLE IF EXISTS `rental_ticket_messages`;
CREATE TABLE `rental_ticket_messages`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `ticket_id` bigint UNSIGNED NOT NULL COMMENT '工单ID',
  `sender_type` tinyint NOT NULL COMMENT '发送者类型：1=C端用户，2=B端用户，3=Admin，4=系统',
  `sender_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '发送者ID（系统消息为NULL）',
  `message_type` tinyint NOT NULL DEFAULT 0 COMMENT '消息类型：0=文本，1=图片，2=文件，3=系统通知',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '消息内容',
  `attachments` json NULL COMMENT '附件（JSON数组：[{url,type,name,size}]）',
  `is_read` tinyint NOT NULL DEFAULT 0 COMMENT '是否已读：0=未读，1=已读',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_ticket_id`(`ticket_id` ASC) USING BTREE,
  INDEX `idx_sender`(`sender_type` ASC, `sender_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '工单消息表-客服聊天记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rental_ticket_messages
-- ----------------------------

-- ----------------------------
-- Table structure for rental_tickets
-- ----------------------------
DROP TABLE IF EXISTS `rental_tickets`;
CREATE TABLE `rental_tickets`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '工单ID',
  `ticket_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工单编号（TK + YYYYMMDD + 6位随机数）',
  `order_id` bigint UNSIGNED NOT NULL COMMENT '关联订单ID',
  `creator_user_id` bigint UNSIGNED NOT NULL COMMENT '创建者用户ID',
  `creator_user_type` tinyint NOT NULL COMMENT '创建者类型：1=C端，2=B端',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工单标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '问题描述',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态：0=待处理，1=处理中，2=已解决，3=已关闭',
  `handler_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '处理人ID（Admin）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `closed_at` datetime NULL DEFAULT NULL COMMENT '关闭时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_ticket_no`(`ticket_no` ASC) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_creator`(`creator_user_id` ASC, `creator_user_type` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_handler_id`(`handler_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '租赁工单表-售后纠纷处理' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rental_tickets
-- ----------------------------

-- ----------------------------
-- Table structure for task_templates
-- ----------------------------
DROP TABLE IF EXISTS `task_templates`;
CREATE TABLE `task_templates`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '模板ID',
  `type` tinyint NOT NULL DEFAULT 0 COMMENT '任务类型：0=单任务，1=组合任务',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务标题',
  `price` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '单价（元，单任务用）',
  `description1` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '描述信息1',
  `description2` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '描述信息2',
  `stage1_title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '阶段1标题（组合任务用）',
  `stage1_price` decimal(18, 2) NULL DEFAULT NULL COMMENT '阶段1单价（组合任务用）',
  `stage2_title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '阶段2标题（组合任务用）',
  `stage2_price` decimal(18, 2) NULL DEFAULT NULL COMMENT '阶段2单价（组合任务用）',
  `default_stage1_count` int NULL DEFAULT 1 COMMENT '默认阶段1数量（组合任务用）',
  `default_stage2_count` int NULL DEFAULT 3 COMMENT '默认阶段2数量（组合任务用）',
  `c_user_commission` int NOT NULL DEFAULT 0 COMMENT '普通用户佣金（分）',
  `agent_commission` int NOT NULL DEFAULT 0 COMMENT '普通团长佣金（分）',
  `senior_agent_commission` int NOT NULL DEFAULT 0 COMMENT '高级团长佣金（分）',
  `stage1_c_user_commission` int NULL DEFAULT NULL COMMENT '组合任务阶段1-普通用户佣金（分）',
  `stage1_agent_commission` int NULL DEFAULT NULL COMMENT '组合任务阶段1-普通团长佣金（分）',
  `stage1_senior_agent_commission` int NULL DEFAULT NULL COMMENT '组合任务阶段1-高级团长佣金（分）',
  `stage2_c_user_commission` int NULL DEFAULT NULL COMMENT '组合任务阶段2-普通用户佣金（分）',
  `stage2_agent_commission` int NULL DEFAULT NULL COMMENT '组合任务阶段2-普通团长佣金（分）',
  `stage2_senior_agent_commission` int NULL DEFAULT NULL COMMENT '组合任务阶段2-高级团长佣金（分）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=启用，0=禁用',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '任务模板表-平台配置' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of task_templates
-- ----------------------------
INSERT INTO `task_templates` VALUES (1, 0, '上评评论', 3.00, '发布上评评论', '', NULL, NULL, NULL, NULL, NULL, NULL, 100, 50, 50, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (2, 0, '中评评论', 2.00, '发布中评评论', '', NULL, NULL, NULL, NULL, NULL, NULL, 80, 30, 30, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (3, 0, '放大镜搜索词', 5.00, '抖音平台规则问题，本产品属于稀罕出版大礼，搜索词搜索次数就越多，出现概率越大', '', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (4, 1, '上中评评论', 9.00, '组合评论：上评+中评(1+3)', '', '上评评论', 3.00, '中评回复', 2.00, 1, 3, 0, 0, 0, 100, 50, 50, 80, 30, 30, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (5, 1, '中下评评论', 6.00, '组合评论：中评+下评(1+1)3元/条', '真人评论，评论内容真实有效。下评完成后需要这个晒图评论为晒图套餐。', '中评评论', 3.00, '下评回复', 3.00, 1, 1, 0, 0, 0, 130, 45, 43, 130, 45, 45, 1, '2026-02-15 14:51:45');

-- ----------------------------
-- Table structure for user_notifications
-- ----------------------------
DROP TABLE IF EXISTS `user_notifications`;
CREATE TABLE `user_notifications`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `notification_id` bigint UNSIGNED NOT NULL COMMENT '通知ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '用户ID',
  `user_type` tinyint NOT NULL COMMENT '用户类型：1=C端，2=B端',
  `is_read` tinyint NOT NULL DEFAULT 0 COMMENT '是否已读：0=未读，1=已读',
  `read_at` datetime NULL DEFAULT NULL COMMENT '阅读时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '接收时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_notification_user`(`notification_id` ASC, `user_id` ASC, `user_type` ASC) USING BTREE,
  INDEX `idx_user`(`user_id` ASC, `user_type` ASC) USING BTREE,
  INDEX `idx_notification_id`(`notification_id` ASC) USING BTREE,
  INDEX `idx_is_read`(`is_read` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户通知表-每个用户收到的通知' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_notifications
-- ----------------------------
INSERT INTO `user_notifications` VALUES (1, 1, 1, 2, 1, '2026-02-27 13:18:23', '2026-02-27 12:49:56');
INSERT INTO `user_notifications` VALUES (2, 2, 2, 2, 1, '2026-02-27 14:06:06', '2026-02-27 12:49:58');
INSERT INTO `user_notifications` VALUES (3, 3, 2, 2, 1, '2026-02-27 14:26:23', '2026-02-27 14:23:06');
INSERT INTO `user_notifications` VALUES (4, 4, 1, 2, 1, '2026-02-27 18:10:23', '2026-02-27 14:23:08');
INSERT INTO `user_notifications` VALUES (5, 5, 2, 2, 1, '2026-02-27 14:26:23', '2026-02-27 14:23:13');
INSERT INTO `user_notifications` VALUES (6, 6, 2, 2, 1, '2026-02-27 18:11:40', '2026-02-27 17:54:24');
INSERT INTO `user_notifications` VALUES (7, 7, 2, 1, 0, NULL, '2026-02-27 18:42:02');
INSERT INTO `user_notifications` VALUES (8, 8, 3, 1, 0, NULL, '2026-02-27 18:47:02');
INSERT INTO `user_notifications` VALUES (9, 9, 2, 2, 0, NULL, '2026-02-27 18:56:02');
INSERT INTO `user_notifications` VALUES (10, 10, 2, 2, 0, NULL, '2026-02-27 19:02:01');
INSERT INTO `user_notifications` VALUES (11, 11, 1, 2, 0, NULL, '2026-02-28 23:20:14');
INSERT INTO `user_notifications` VALUES (12, 12, 2, 2, 0, NULL, '2026-02-28 23:45:01');
INSERT INTO `user_notifications` VALUES (13, 13, 2, 2, 0, NULL, '2026-03-01 00:00:04');
INSERT INTO `user_notifications` VALUES (14, 14, 2, 1, 0, NULL, '2026-03-01 00:47:02');
INSERT INTO `user_notifications` VALUES (15, 15, 3, 2, 0, NULL, '2026-03-01 00:51:51');
INSERT INTO `user_notifications` VALUES (16, 16, 3, 2, 0, NULL, '2026-03-01 00:55:31');
INSERT INTO `user_notifications` VALUES (17, 17, 3, 2, 0, NULL, '2026-03-01 00:56:41');
INSERT INTO `user_notifications` VALUES (18, 18, 5, 1, 0, NULL, '2026-03-02 08:59:57');
INSERT INTO `user_notifications` VALUES (19, 19, 5, 1, 0, NULL, '2026-03-02 09:00:21');
INSERT INTO `user_notifications` VALUES (20, 20, 7, 1, 0, NULL, '2026-03-02 09:01:55');
INSERT INTO `user_notifications` VALUES (21, 21, 3, 2, 0, NULL, '2026-03-02 09:35:15');
INSERT INTO `user_notifications` VALUES (22, 22, 3, 2, 0, NULL, '2026-03-02 09:35:48');
INSERT INTO `user_notifications` VALUES (23, 23, 3, 2, 0, NULL, '2026-03-02 09:36:17');

-- ----------------------------
-- Table structure for wallet_password
-- ----------------------------
DROP TABLE IF EXISTS `wallet_password`;
CREATE TABLE `wallet_password`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `wallet_id` bigint UNSIGNED NOT NULL COMMENT '钱包ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '用户ID',
  `user_type` tinyint NOT NULL COMMENT '用户类型：1=C端，2=B端，3=Admin端',
  `password_hash` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '支付密码（前端MD5 32位）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_wallet_id`(`wallet_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_user_type`(`user_type` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付密码表-钱包支付密码管理' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of wallet_password
-- ----------------------------

-- ----------------------------
-- Table structure for wallets
-- ----------------------------
DROP TABLE IF EXISTS `wallets`;
CREATE TABLE `wallets`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '钱包ID',
  `balance` bigint NOT NULL DEFAULT 0 COMMENT '余额（单位：分，100=1元）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_balance`(`balance` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '钱包表-三端共用' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of wallets
-- ----------------------------
INSERT INTO `wallets` VALUES (1, 219700, '2026-02-27 11:49:20', '2026-03-01 00:34:05');
INSERT INTO `wallets` VALUES (2, 208700, '2026-02-27 12:02:50', '2026-03-01 00:00:04');
INSERT INTO `wallets` VALUES (3, 0, '2026-02-27 13:06:22', '2026-02-27 13:06:22');
INSERT INTO `wallets` VALUES (4, 0, '2026-02-27 17:24:33', '2026-02-27 17:24:33');
INSERT INTO `wallets` VALUES (5, 0, '2026-02-27 17:26:27', '2026-02-27 17:26:27');
INSERT INTO `wallets` VALUES (6, 0, '2026-02-27 17:31:08', '2026-02-27 17:31:08');
INSERT INTO `wallets` VALUES (7, 183900, '2026-03-01 00:48:16', '2026-03-03 11:20:37');
INSERT INTO `wallets` VALUES (8, 50, '2026-03-01 00:53:23', '2026-03-02 09:02:47');
INSERT INTO `wallets` VALUES (9, 100, '2026-03-02 08:44:59', '2026-03-02 08:50:13');
INSERT INTO `wallets` VALUES (10, 150, '2026-03-02 08:45:16', '2026-03-02 09:02:47');
INSERT INTO `wallets` VALUES (11, 200, '2026-03-02 08:45:57', '2026-03-02 09:02:47');

-- ----------------------------
-- Table structure for wallets_log
-- ----------------------------
DROP TABLE IF EXISTS `wallets_log`;
CREATE TABLE `wallets_log`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '流水ID',
  `wallet_id` bigint UNSIGNED NOT NULL COMMENT '钱包ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '用户ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（冗余字段）',
  `user_type` tinyint NOT NULL COMMENT '用户类型：1=C端，2=B端，3=Admin端',
  `type` tinyint NOT NULL COMMENT '流水类型：1=收入，2=支出',
  `amount` bigint NOT NULL DEFAULT 0 COMMENT '变动金额（单位：分，正数）',
  `before_balance` bigint NOT NULL DEFAULT 0 COMMENT '变动前余额（单位：分）',
  `after_balance` bigint NOT NULL DEFAULT 0 COMMENT '变动后余额（单位：分）',
  `related_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关联类型：task=任务，recharge=充值，withdraw=提现，refund=退款',
  `related_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '关联ID（任务ID、订单ID等）',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '备注说明（扣费或收入原因）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_wallet_id`(`wallet_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_user_type`(`user_type` ASC) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_related`(`related_type` ASC, `related_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 36 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '钱包流水表-记录所有收支' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of wallets_log
-- ----------------------------
INSERT INTO `wallets_log` VALUES (1, 2, 2, 'Ceshi1', 2, 1, 0, 0, 0, 'recharge', 1, '充值 ¥1,000.00（alipay），审核中', '2026-02-27 12:49:30');
INSERT INTO `wallets_log` VALUES (2, 1, 1, 'Ceshi', 2, 1, 0, 0, 0, 'recharge', 2, '充值 ¥1,000.00（alipay），审核中', '2026-02-27 12:49:46');
INSERT INTO `wallets_log` VALUES (3, 1, 1, 'Ceshi', 2, 1, 100000, 0, 100000, 'recharge', 2, '充值到账：¥1,000.00', '2026-02-27 12:49:56');
INSERT INTO `wallets_log` VALUES (4, 2, 2, 'Ceshi1', 2, 1, 100000, 0, 100000, 'recharge', 1, '充值到账：¥1,000.00', '2026-02-27 12:49:58');
INSERT INTO `wallets_log` VALUES (5, 2, 2, 'Ceshi1', 2, 1, 0, 100000, 100000, 'recharge', 3, '充值 ¥1,000.00（alipay），审核中', '2026-02-27 13:17:34');
INSERT INTO `wallets_log` VALUES (6, 1, 1, 'Ceshi', 2, 1, 0, 100000, 100000, 'recharge', 4, '充值 ¥1,000.00（alipay），审核中', '2026-02-27 13:18:09');
INSERT INTO `wallets_log` VALUES (7, 2, 2, 'Ceshi1', 2, 2, 5000, 100000, 95000, 'rental_freeze', 1, '求租信息冻结预算（5000分/天×1天）：抖音日租', '2026-02-27 13:47:33');
INSERT INTO `wallets_log` VALUES (8, 2, 2, 'Ceshi1', 2, 1, 0, 95000, 95000, 'recharge', 5, '充值 ¥100.00（alipay），审核中', '2026-02-27 14:22:20');
INSERT INTO `wallets_log` VALUES (9, 2, 2, 'Ceshi1', 2, 1, 10000, 95000, 105000, 'recharge', 5, '充值到账：¥100.00', '2026-02-27 14:23:06');
INSERT INTO `wallets_log` VALUES (10, 1, 1, 'Ceshi', 2, 1, 100000, 100000, 200000, 'recharge', 4, '充值到账：¥1,000.00', '2026-02-27 14:23:08');
INSERT INTO `wallets_log` VALUES (11, 2, 2, 'Ceshi1', 2, 1, 100000, 105000, 205000, 'recharge', 3, '充值到账：¥1,000.00', '2026-02-27 14:23:13');
INSERT INTO `wallets_log` VALUES (12, 2, 2, 'Ceshi1', 2, 2, 600, 205000, 204400, 'task', 1, '发布任务【上评评论】2个任务，扣除 ¥6.00', '2026-02-27 18:25:58');
INSERT INTO `wallets_log` VALUES (13, 2, 2, 'Ceshi1', 2, 2, 400, 204400, 204000, 'task', 2, '发布任务【中评评论】2个任务，扣除 ¥4.00', '2026-02-27 18:31:19');
INSERT INTO `wallets_log` VALUES (14, 1, 1, 'Ceshi', 2, 1, 0, 200000, 200000, 'recharge', 6, '充值 ¥200.00（alipay），审核中', '2026-02-28 23:20:05');
INSERT INTO `wallets_log` VALUES (15, 1, 1, 'Ceshi', 2, 1, 20000, 200000, 220000, 'recharge', 6, '充值到账：¥200.00', '2026-02-28 23:20:14');
INSERT INTO `wallets_log` VALUES (16, 2, 2, 'Ceshi1', 2, 2, 300, 204000, 203700, 'task', 3, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-02-28 23:34:35');
INSERT INTO `wallets_log` VALUES (17, 2, 2, 'Ceshi1', 2, 1, 5000, 203700, 208700, 'rental_unfreeze', 1, '求租到期退回预算（5000分/天×1天）：抖音日租', '2026-03-01 00:00:04');
INSERT INTO `wallets_log` VALUES (18, 1, 1, 'Ceshi', 2, 2, 300, 220000, 219700, 'task', 4, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-01 00:34:05');
INSERT INTO `wallets_log` VALUES (19, 7, 3, 'task', 2, 1, 0, 0, 0, 'recharge', 7, '充值 ¥2,000.00（alipay），审核中', '2026-03-01 00:51:42');
INSERT INTO `wallets_log` VALUES (20, 7, 3, 'task', 2, 1, 200000, 0, 200000, 'recharge', 7, '充值到账：¥2,000.00', '2026-03-01 00:51:51');
INSERT INTO `wallets_log` VALUES (21, 7, 3, 'task', 2, 2, 10000, 200000, 190000, 'rental_freeze', 2, '求租信息冻结预算（5000分/天×2天）：测试求租发布', '2026-03-01 00:52:02');
INSERT INTO `wallets_log` VALUES (22, 7, 3, 'task', 2, 2, 300, 190000, 189700, 'task', 5, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-02 08:47:31');
INSERT INTO `wallets_log` VALUES (23, 7, 3, 'task', 2, 2, 300, 189700, 189400, 'task', 6, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-02 08:47:38');
INSERT INTO `wallets_log` VALUES (24, 7, 3, 'task', 2, 2, 300, 189400, 189100, 'task', 7, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-02 08:47:40');
INSERT INTO `wallets_log` VALUES (25, 9, 6, 'advanced', 1, 1, 100, 0, 100, 'commission', 5, '完成任务获得佣金，任务ID：5', '2026-03-02 08:50:13');
INSERT INTO `wallets_log` VALUES (26, 10, 7, 'advanced1', 1, 1, 100, 0, 100, 'commission', 6, '完成任务获得佣金，任务ID：6', '2026-03-02 08:50:45');
INSERT INTO `wallets_log` VALUES (27, 11, 8, 'advanced3', 1, 1, 100, 0, 100, 'commission', 7, '完成任务获得佣金，任务ID：7', '2026-03-02 09:01:16');
INSERT INTO `wallets_log` VALUES (28, 7, 3, 'task', 2, 2, 300, 189100, 188800, 'task', 8, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-02 09:02:15');
INSERT INTO `wallets_log` VALUES (29, 11, 8, 'advanced3', 1, 1, 100, 100, 200, 'commission', 8, '完成任务获得佣金，任务ID：8', '2026-03-02 09:02:47');
INSERT INTO `wallets_log` VALUES (30, 10, 7, 'advanced1', 1, 1, 50, 100, 150, 'agent_commission', 8, '下级用户 advanced3 完成任务，获得一级团长佣金，任务ID：8', '2026-03-02 09:02:47');
INSERT INTO `wallets_log` VALUES (31, 8, 5, 'test', 1, 1, 50, 0, 50, 'second_agent_commission', 8, '下级用户 advanced1 的团队成员完成任务，获得二级团长佣金，任务ID：8', '2026-03-02 09:02:47');
INSERT INTO `wallets_log` VALUES (32, 7, 3, 'task', 2, 2, 40, 188800, 188760, 'rental_freeze', 3, '求租信息冻结预算（20分/天×2天）：测试求租发布', '2026-03-02 09:32:29');
INSERT INTO `wallets_log` VALUES (33, 7, 3, 'task', 2, 2, 3960, 188760, 184800, 'rental_freeze', 3, '求租信息修改增加预算（2000分/天×2天）：测试求租发布（+3960）', '2026-03-02 09:33:26');
INSERT INTO `wallets_log` VALUES (34, 7, 3, 'task', 2, 2, 300, 184800, 184500, 'task', 9, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-03 11:18:26');
INSERT INTO `wallets_log` VALUES (35, 7, 3, 'task', 2, 2, 600, 184500, 183900, 'task', 10, '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-03 11:20:37');

-- ----------------------------
-- Table structure for withdraw_requests
-- ----------------------------
DROP TABLE IF EXISTS `withdraw_requests`;
CREATE TABLE `withdraw_requests`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '提现申请ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '用户ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（冗余字段）',
  `user_type` tinyint NOT NULL COMMENT '用户类型：1=C端，2=B端',
  `wallet_id` bigint UNSIGNED NOT NULL COMMENT '钱包ID',
  `amount` bigint NOT NULL DEFAULT 0 COMMENT '提现金额（单位：分）',
  `fee_rate` decimal(5, 4) NOT NULL DEFAULT 0.0300 COMMENT '手续费比例（如0.03=3%）',
  `fee_amount` bigint NOT NULL DEFAULT 0 COMMENT '手续费金额（单位：分）',
  `actual_amount` bigint NOT NULL DEFAULT 0 COMMENT '实际到账金额（单位：分）',
  `withdraw_method` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收款方式：alipay=支付宝，wechat=微信，bank=银行卡，usdt=USDT',
  `withdraw_account` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收款账号/信息',
  `account_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '收款人姓名',
  `log_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '关联的钱包流水ID',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '审核状态：0=待审核，1=审核通过，2=审核拒绝',
  `reject_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '拒绝原因',
  `img_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审核凭证图片URL（管理员审核通过后上传）',
  `admin_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '审核管理员ID',
  `reviewed_at` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_user_type`(`user_type` ASC) USING BTREE,
  INDEX `idx_wallet_id`(`wallet_id` ASC) USING BTREE,
  INDEX `idx_log_id`(`log_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '提现申请表-需要管理员审核' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of withdraw_requests
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
