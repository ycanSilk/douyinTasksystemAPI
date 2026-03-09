/*
 Navicat Premium Dump SQL

 Source Server         : task
 Source Server Type    : MySQL
 Source Server Version : 80036 (8.0.36)
 Source Host           : 54.179.253.64:3306
 Source Schema         : task_platform

 Target Server Type    : MySQL
 Target Server Version : 80036 (8.0.36)
 File Encoding         : 65001

 Date: 09/03/2026 20:07:56
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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '团长申请表-C端用户申请成为团长' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of agent_applications
-- ----------------------------

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
INSERT INTO `app_config` VALUES (18, 'senior_agent_required_active_users', '15', 'int', 'task', '申请高级团长需要的有效活跃用户数', '2026-03-08 19:12:17');
INSERT INTO `app_config` VALUES (19, 'senior_agent_active_user_task_count', '100', 'int', 'task', '有效活跃用户需完成的任务数', '2026-03-08 19:12:13');
INSERT INTO `app_config` VALUES (20, 'senior_agent_active_user_hours', '24', 'int', 'task', '有效活跃用户注册后需在多少小时内完成任务', '2026-03-08 19:12:04');
INSERT INTO `app_config` VALUES (21, 'senior_agent_max_count', '100', 'int', 'task', '高级团长数量上限', '2026-02-26 11:25:39');
INSERT INTO `app_config` VALUES (23, 'agent_required_active_users', '5', 'int', 'task', '申请普通团长需要的有效活跃用户数', '2026-02-25 10:50:57');
INSERT INTO `app_config` VALUES (24, 'agent_active_user_task_count', '30', 'int', 'task', '普通团长有效活跃用户需完成的任务数', '2026-03-08 19:11:51');
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
) ENGINE = InnoDB AUTO_INCREMENT = 47 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端发布任务表-商家派单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of b_tasks
-- ----------------------------
INSERT INTO `b_tasks` VALUES (1, 2, NULL, 0, 1, NULL, 1, '5.89 复制打开抖音，看看【辉总不累的作品】  https://v.douyin.com/jmtVNF6KEQQ/ 04/19 d@N.Wm zGI:/', 1772189758, '[{\"at_user\": \"\", \"comment\": \"还好遇见梅姐，每天肚子都吃得饱饱的😋\", \"image_url\": \"http://54.179.253.64:28806/img/6c031bd126d19509ddceb060e2c1d77f.jpg\"}, {\"at_user\": \"\", \"comment\": \"还好遇见梅姐，每天肚子都吃得饱饱的😋\", \"image_url\": \"http://54.179.253.64:28806/img/5f66e00f02b672e9ecb1cf1140586079.jpg\"}]', 2, 0, 0, 0, 3.00, 6.00, 0, '2026-02-27 18:25:58', '2026-02-27 18:56:02', NULL);
INSERT INTO `b_tasks` VALUES (2, 2, NULL, 0, 1, NULL, 2, '9:/Y.. 07/31 o@Q.Kj 复制打开抖音，查看【辉总不累】发布作品的评论：死磕，做到极致。➝➝o7wgJAyHg49ŠŠ', 1772190077, '[{\"at_user\": \"\", \"comment\": \"有你真好，梅姐\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"123456789224\", \"image_url\": \"\"}]', 2, 0, 0, 0, 2.00, 4.00, 0, '2026-02-27 18:31:19', '2026-02-27 19:02:01', NULL);
INSERT INTO `b_tasks` VALUES (3, 2, NULL, 0, 1, NULL, 1, '5-- 02/02 i@p.QX 复制打开抖音，查看【让我再次去思念】发布作品的评论：又几有道理喔，怪唔知得啲:/ 师奶咁钟意用荷花做微信头像...^^5iKugrrLi49※※', 1772293474, '[{\"at_user\": \"\", \"comment\": \"那天人山人海，没好意思去拜就走了😅 但听说真的超准！\", \"image_url\": \"\"}]', 1, 0, 0, 0, 3.00, 3.00, 0, '2026-02-28 23:34:35', '2026-02-28 23:45:01', NULL);
INSERT INTO `b_tasks` VALUES (4, 1, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1773072000, '[{\"comment\": \"测试上评评论\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-01 00:34:05', '2026-03-04 17:33:01', '2026-03-04 17:33:01');
INSERT INTO `b_tasks` VALUES (5, 3, NULL, 0, 1, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1774800000, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 0, 0, 0, 3.00, 3.00, 1, '2026-03-03 11:02:13', '2026-03-03 11:39:01', NULL);
INSERT INTO `b_tasks` VALUES (6, 3, NULL, 0, 1, NULL, 2, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1774800000, '[{\"comment\": \"新测试，单任务，中评评论18，测试高级团长邀请。\", \"image_url\": \"\"}, {\"comment\": \"新测试，单任务，中评评论18，测试高级团长邀请。\", \"image_url\": \"\"}, {\"comment\": \"新测试，单任务，中评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 3, 0, 0, 0, 2.00, 6.00, 1, '2026-03-03 11:48:04', '2026-03-03 11:59:01', NULL);
INSERT INTO `b_tasks` VALUES (7, 3, NULL, 0, 1, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1774800000, '[{\"comment\": \"新测试，单任务，中评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 0, 0, 0, 3.00, 3.00, 1, '2026-03-03 12:03:50', '2026-03-03 12:15:01', NULL);
INSERT INTO `b_tasks` VALUES (8, 3, NULL, 0, 1, NULL, 1, 'https://www.bilibili.com/video/BV1PxAZzaE9Y/?spm_id_from=333.1007.tianma.1-2-2.click', 1772557659, '[{\"at_user\": \"\", \"comment\": \"愿亲人们三餐四季皆温暖，生活如春风般顺心如意，笑口常开，心花怒放！🌼💕\", \"image_url\": \"https://api.kktaskpaas.com/img/18ee2b8c21381a54914f36f6a58c6001.jpg\"}, {\"at_user\": \"\", \"comment\": \"愿亲人们三餐四季皆温暖，生活如意似春风，笑口常开心花放🌺✨\", \"image_url\": \"\"}]', 2, 0, 0, 0, 3.00, 6.00, 0, '2026-03-04 00:37:44', '2026-03-04 01:08:01', NULL);
INSERT INTO `b_tasks` VALUES (9, 3, 'COMBO_1772557208_3', 1, 1, NULL, 4, 'https://www.bilibili.com/video/BV1PxAZzaE9Y/?spm_id_from=333.1007.tianma.1-2-2.click', 1772558922, '[{\"comment\": \"真的准了！可惜钱包没跟上😭💸\", \"image_url\": \"\"}]', 1, 0, 0, 0, 3.00, 3.00, 0, '2026-03-04 01:00:08', '2026-03-04 01:29:01', NULL);
INSERT INTO `b_tasks` VALUES (10, 3, 'COMBO_1772557208_3', 2, 0, 9, 4, NULL, 1772558922, '[{\"comment\": \"⌛等待开奖的每一秒，心跳都在加速！💓\", \"image_url\": \"\"}, {\"comment\": \"我也来沾沾喜气，好运接住！🍀✨\", \"image_url\": \"\"}, {\"at_user\": \"超哥\", \"comment\": \"恭喜恭喜🎉天生一对💑才子佳人，郎才女貌如花似玉🌸祝福新人永浴爱河💕 @超哥\", \"image_url\": \"\"}]', 3, 0, 0, 0, 2.00, 6.00, 0, '2026-03-04 01:00:08', '2026-03-04 01:29:01', NULL);
INSERT INTO `b_tasks` VALUES (11, 1, NULL, 0, 1, NULL, 2, '4:/ 01/23 n@Q.Kj 复制打开抖音，查看【兰兰🌹】发布作品的评论：今晚买06※※Oaxb9iGNo49^^', 1772608931, '[{\"at_user\": \"\", \"comment\": \"以后指望你了，梅姐\", \"image_url\": \"https://api.kktaskpaas.com/img/199f90c1f2685b56917e7ace368ffe56.jpg\"}]', 1, 0, 0, 0, 2.00, 2.00, 0, '2026-03-04 15:12:11', '2026-03-04 15:23:01', NULL);
INSERT INTO `b_tasks` VALUES (12, 1, 'COMBO_1772610629_1', 1, 1, NULL, 4, '6:/ U@y.tE 06/08 复制打开抖音，查看【兰兰🌹】发布作品的评论：牛龙狗   特码15+20+[感谢]^^nQdLnAVi3D0p49︽︽', 1772611412, '[{\"comment\": \"\", \"image_url\": \"\"}]', 1, 0, 0, 0, 3.00, 3.00, 0, '2026-03-04 15:50:29', '2026-03-04 16:04:01', NULL);
INSERT INTO `b_tasks` VALUES (13, 1, 'COMBO_1772610629_1', 2, 0, 12, 4, NULL, 1772611412, '[{\"comment\": \"三宫六院七十二妃？🤔 这到底是啥神仙配置啊！\", \"image_url\": \"https://api.kktaskpaas.com/img/edaceeb86d3e9cac2c50c5a32088bcf5.jpg\"}, {\"comment\": \"🤣这习惯怕是改不掉了！\", \"image_url\": \"\"}, {\"at_user\": \"赵丽颖\", \"comment\": \"失败是成功之母💪 下次一定行！ @赵丽颖\", \"image_url\": \"\"}]', 3, 0, 0, 0, 2.00, 6.00, 0, '2026-03-04 15:50:29', '2026-03-04 16:04:01', NULL);
INSERT INTO `b_tasks` VALUES (14, 1, NULL, 0, 1, NULL, 1, '是对方分发给环境科技', 1772626386, '[{\"at_user\": \"\", \"comment\": \"桥叔关注你超久啦，终于等到你闪闪发光啦✨🌟\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"桥叔！从默默关注到看你闪闪发光，这一天终于来啦！✨\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"桥叔！关注你这么久，终于等到你闪闪发光啦✨💫\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"桥叔！关注你这么久，终于等到你闪闪发光啦✨太为你开心了！\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"桥叔！终于等到你闪闪发光啦✨关注你超久啦！\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"桥叔！关注你这么久，终于等到你闪闪发光啦✨为你开心！\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"桥叔！从默默关注到看你闪闪发光，这一天终于来啦！✨💫\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"桥叔，关注你这么久，终于等到你闪闪发光啦！✨🔥\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"桥叔！从默默关注到见证你闪闪发光，这一天终于来啦！✨💫\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"桥叔，从默默关注到看你闪闪发光✨，这一天终于来啦！\", \"image_url\": \"\"}]', 10, 0, 0, 0, 3.00, 30.00, 0, '2026-03-04 20:03:07', '2026-03-04 20:14:02', NULL);
INSERT INTO `b_tasks` VALUES (15, 3, NULL, 0, 1, NULL, 2, 'https://www.bilibili.com/video/BV1v2fhBbE8J/?spm_id_from=333.1007.tianma.1-3-3.click', 1772643690, '[{\"at_user\": \"\", \"comment\": \"🎲 理性投注，娱乐至上！开心最…\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"学到了！👍 收藏起来慢慢看~\", \"image_url\": \"\"}, {\"at_user\": \"超哥超车\", \"comment\": \"回点血就行😅\", \"image_url\": \"\"}]', 3, 0, 0, 0, 2.00, 6.00, 0, '2026-03-05 00:31:33', '2026-03-05 01:02:01', NULL);
INSERT INTO `b_tasks` VALUES (16, 1, NULL, 0, 1, NULL, 1, '0.74 复制打开抖音，看看【九键的图文作品】# 用抖音记生活 # 创作者中心 # 创作灵感  https://v.douyin.com/90yRSEXQdjs/ yTL:/ g@O.KW 04/19', 1772683424, '[{\"at_user\": \"\", \"comment\": \"我和你一样的负债，还好有梅姐拉我一把！感恩❤️\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"😭同是天涯负债人，还好有梅姐拉一把！感恩的心，感谢有你！🙏\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"同是天涯负债人😭还好有梅姐拉我一把，感恩遇见！🙏\", \"image_url\": \"\"}]', 3, 0, 0, 0, 3.00, 9.00, 0, '2026-03-05 11:53:47', '2026-03-05 12:04:01', NULL);
INSERT INTO `b_tasks` VALUES (17, 1, NULL, 0, 1, NULL, 1, '0.74 复制打开抖音，看看【九键的图文作品】# 用抖音记生活 # 创作者中心 # 创作灵感  https://v.douyin.com/90yRSEXQdjs/ yTL:/ g@O.KW 04/19', 1772686161, '[{\"at_user\": \"\", \"comment\": \"梅姐神了！😅 油门踩深点，速度与激情走起！🚗💨\", \"image_url\": \"https://api.kktaskpaas.com/img/f13e9f38cfd9a71a92db12807e2e760a.jpg\"}]', 1, 0, 0, 0, 3.00, 3.00, 0, '2026-03-05 12:19:22', '2026-03-05 12:50:01', NULL);
INSERT INTO `b_tasks` VALUES (18, 3, NULL, 0, 1, NULL, 1, '8.23 复制打开抖音，看看【电视剧太平年（五代十国已通关的作品】# 太平年 烽火连天，不如炊烟一缕，百姓所求，不过... https://v.douyin.com/v14bLVe_vso/ 06/13 m@q.eb IVl:/', 1772717374, '[{\"at_user\": \"\", \"comment\": \"超哥推荐的果然靠谱！亲测有效，没踩坑，又学到新技能啦！👍✨\", \"image_url\": \"\"}]', 1, 0, 0, 0, 3.00, 3.00, 0, '2026-03-05 20:59:37', '2026-03-05 21:30:01', NULL);
INSERT INTO `b_tasks` VALUES (19, 1, NULL, 0, 1, NULL, 1, '3.33 复制打开抖音，看看【ℳঞ洪  ໌້ᮨ꧔ꦿ᭄💕的作品】# 大山原生态之美 # 风水宝地山清水秀 # 户外... https://v.douyin.com/jY9mp8o3v7Y/ 12/13 N@w.sR HIv:/', 1772766945, '[{\"at_user\": \"\", \"comment\": \"亲测有效！小雅，稳得一批！💯\", \"image_url\": \"https://api.kktaskpaas.com/img/ede2c3f0e6f48082ef6883300719aa06.jpg\"}, {\"at_user\": \"\", \"comment\": \"小雅，这路子我亲测有效，体验感拉满！💯\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"小雅，听你的准没错！👍 靠谱认证，必须支持！💪\", \"image_url\": \"\"}]', 3, 0, 0, 0, 3.00, 9.00, 0, '2026-03-06 11:05:46', '2026-03-06 11:17:01', NULL);
INSERT INTO `b_tasks` VALUES (20, 1, NULL, 0, 1, NULL, 3, '1:/X i@p.QK 03/11 复制打开抖音，查看【ℳঞ洪  ໌້ᮨ꧔ꦿ᭄💕】发布作品的评论：有高45的吗︽︽MDI5cFl6s49︽︽', 1772769344, '[{\"comment\": \"\", \"keyword\": \"小雅\", \"image_url\": \"\"}]', 1, 0, 0, 0, 5.00, 5.00, 0, '2026-03-06 11:25:44', '2026-03-06 11:56:01', NULL);
INSERT INTO `b_tasks` VALUES (21, 1, NULL, 0, 1, NULL, 3, '2:/. M@w.FH 03/04 复制打开抖音，查看【ℳঞ洪  ໌້ᮨ꧔ꦿ᭄💕】发布作品的评论：有高45的吗ŠŠqRs1HmBYuIds49ǚǚ', 1772774188, '[{\"comment\": \"\", \"keyword\": \"小辣椒\", \"image_url\": \"\"}]', 1, 0, 0, 0, 5.00, 5.00, 0, '2026-03-06 13:06:31', '2026-03-06 13:17:01', NULL);
INSERT INTO `b_tasks` VALUES (22, 2, NULL, 0, 1, NULL, 2, '12346542', 1772781074, '[{\"at_user\": \"\", \"comment\": \"脚哥真是铁打的战士，连轴转几天依…\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"亲测有效！跟着超哥一路狂飙🚀，…\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"🚀冲就完事了！单车秒变摩托，起…\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"一起交流，一起进步！💪✨\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"@超哥超车 换个角度看，转角没准…\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"分析得明明白白，必须狠狠支持一波…\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"跟着大神走，吃喝全都有！🍻🍔…\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"这操作简直野出天际！路子野到银河…\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"🍀好运发射！biu～biu～b…\", \"image_url\": \"\"}, {\"at_user\": \"脚哥\", \"comment\": \"曹作简单，这路子稳得一批！💯 …\", \"image_url\": \"\"}]', 10, 1, 0, 0, 2.00, 20.00, 0, '2026-03-06 15:01:15', '2026-03-06 15:15:01', NULL);
INSERT INTO `b_tasks` VALUES (23, 1, 'COMBO_1772850783_1', 1, 2, NULL, 4, '1234567', 1772852582, '[{\"comment\": \"跟了这招，小野，靠谱到飞起！爽翻啦！🔥\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-07 10:33:03', '2026-03-07 10:38:37', '2026-03-07 10:38:37');
INSERT INTO `b_tasks` VALUES (24, 1, 'COMBO_1772850783_1', 2, 1, 23, 4, '1', 1772852582, '[{\"comment\": \"天天好运，日日是好日🍀✨\", \"image_url\": \"\"}, {\"comment\": \"超哥带带我飞…\", \"image_url\": \"\"}, {\"at_user\": \"小野\", \"comment\": \"双数都连开三期了，这期该转了吧！… @小野\", \"image_url\": \"\"}]', 3, 0, 0, 0, 2.00, 6.00, 0, '2026-03-07 10:33:03', '2026-03-07 11:04:01', NULL);
INSERT INTO `b_tasks` VALUES (25, 1, NULL, 0, 1, NULL, 3, '123456', 1772853155, '[{\"comment\": \"\", \"keyword\": \"1234567\", \"image_url\": \"\"}]', 1, 0, 0, 0, 5.00, 5.00, 0, '2026-03-07 10:42:36', '2026-03-07 11:13:01', NULL);
INSERT INTO `b_tasks` VALUES (26, 1, NULL, 0, 1, NULL, 3, '654321', 1772853742, '[{\"comment\": \"\", \"keyword\": \"小野\", \"image_url\": \"\"}]', 1, 0, 0, 0, 5.00, 5.00, 0, '2026-03-07 10:52:23', '2026-03-07 11:23:01', NULL);
INSERT INTO `b_tasks` VALUES (27, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1780243200, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-07 11:24:54', '2026-03-07 11:36:01', '2026-03-07 11:36:01');
INSERT INTO `b_tasks` VALUES (28, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1780243200, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-07 11:39:29', '2026-03-07 11:51:01', '2026-03-07 11:51:01');
INSERT INTO `b_tasks` VALUES (29, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1780243200, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-07 12:08:09', '2026-03-07 12:19:01', '2026-03-07 12:19:01');
INSERT INTO `b_tasks` VALUES (30, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1780243200, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-07 12:23:44', '2026-03-07 12:34:01', '2026-03-07 12:34:01');
INSERT INTO `b_tasks` VALUES (31, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1780243200, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-07 12:52:23', '2026-03-07 13:03:01', '2026-03-07 13:03:01');
INSERT INTO `b_tasks` VALUES (32, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1780243200, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-07 13:10:06', '2026-03-07 13:21:01', '2026-03-07 13:21:01');
INSERT INTO `b_tasks` VALUES (33, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1780243200, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-07 13:40:53', '2026-03-07 13:52:01', '2026-03-07 13:52:01');
INSERT INTO `b_tasks` VALUES (34, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1780243200, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-07 13:58:39', '2026-03-07 14:00:18', '2026-03-07 14:00:18');
INSERT INTO `b_tasks` VALUES (35, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1780243200, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-07 14:06:14', '2026-03-07 14:17:01', '2026-03-07 14:17:01');
INSERT INTO `b_tasks` VALUES (36, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1780243200, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-07 14:22:14', '2026-03-07 14:33:01', '2026-03-07 14:33:01');
INSERT INTO `b_tasks` VALUES (37, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1780243200, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-07 14:34:59', '2026-03-07 14:46:01', '2026-03-07 14:46:01');
INSERT INTO `b_tasks` VALUES (38, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1780243200, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-07 14:46:27', '2026-03-07 14:58:01', '2026-03-07 14:58:01');
INSERT INTO `b_tasks` VALUES (39, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1780243200, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-07 15:04:27', '2026-03-07 15:21:01', '2026-03-07 15:21:01');
INSERT INTO `b_tasks` VALUES (40, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1780243200, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-07 15:58:47', '2026-03-07 16:09:01', '2026-03-07 16:09:01');
INSERT INTO `b_tasks` VALUES (41, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1780243200, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-07 17:30:09', '2026-03-07 17:34:54', '2026-03-07 17:34:54');
INSERT INTO `b_tasks` VALUES (42, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1780243200, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-07 22:53:01', '2026-03-07 23:12:01', '2026-03-07 23:12:01');
INSERT INTO `b_tasks` VALUES (43, 2, NULL, 0, 1, NULL, 2, '87M:/ 03/16 Q@K.WZ 复制打开抖音，查看【ℳঞ洪  ໌້ᮨ꧔ꦿ᭄💕】发布作品的评论：摇双色球暴富比较快ŠŠScvpCdJBEv49︽︽', 1772950017, '[{\"at_user\": \"\", \"comment\": \"真的假的？太感谢分享了！😲👍\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"真的假的？太感谢分享了！💖\", \"image_url\": \"\"}, {\"at_user\": \"小野\", \"comment\": \"@小野 你这条视频也太有趣了吧！…\", \"image_url\": \"\"}]', 3, 0, 0, 0, 2.00, 6.00, 0, '2026-03-08 13:36:57', '2026-03-08 14:07:01', NULL);
INSERT INTO `b_tasks` VALUES (44, 1, NULL, 0, 1, NULL, 1, '123456', 1772950095, '[{\"at_user\": \"\", \"comment\": \"小野根了说的体验感超赞！给力到飞起～💯👍\", \"image_url\": \"https://api.kktaskpaas.com/img/7304ef37c13dbe5c4d4df97b80529d7f.jpg\"}, {\"at_user\": \"\", \"comment\": \"🌱方法太给力了，收益蹭蹭涨！小野继续冲鸭，支持你！💪\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"用了小野分享的，收益真不错！继续支持你！💪✨\", \"image_url\": \"\"}]', 3, 1, 0, 0, 3.00, 9.00, 0, '2026-03-08 13:38:15', '2026-03-08 14:09:01', NULL);
INSERT INTO `b_tasks` VALUES (45, 1, 'COMBO_1772948790_1', 1, 1, NULL, 5, '21345678', 1772950589, '[{\"comment\": \"1235发多少个环节小野\", \"image_url\": \"\"}]', 1, 0, 0, 0, 3.00, 3.00, 0, '2026-03-08 13:46:30', '2026-03-08 14:17:01', NULL);
INSERT INTO `b_tasks` VALUES (46, 1, 'COMBO_1772948790_1', 2, 0, 45, 5, NULL, 1772950589, '[{\"at_user\": \"小野\", \"comment\": \"@小野\", \"image_url\": \"\"}]', 1, 0, 0, 0, 3.00, 3.00, 0, '2026-03-08 13:46:30', '2026-03-08 14:17:01', NULL);

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
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端用户表-商家端' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of b_users
-- ----------------------------
INSERT INTO `b_users` VALUES (1, 'Ceshi', '271010169@qq.com', NULL, '$2y$10$SV7dHV/yam2IcgV5SmbbKur8TrpohySzBEQ032nQouiOnaBgmTWp6', 'Meili', 'Meili', 'eyJ1c2VyX2lkIjoxLCJ0eXBlIjoyLCJleHAiOjE3NzM0NTI5Nzd9', '2026-03-14 09:49:37', 1, 1, NULL, '34.143.229.197', '2026-02-27 11:49:20', '2026-03-07 09:49:37');
INSERT INTO `b_users` VALUES (2, 'Ceshi1', '459312160@qq.com', NULL, '$2y$10$F0HHwcgbu5Qh.xkir2UCcul4OHQPBYXwr970M4kIFVmdeZaDeh6ca', 'Meili', 'Meili', 'eyJ1c2VyX2lkIjoyLCJ0eXBlIjoyLCJleHAiOjE3NzM1NTIwNjV9', '2026-03-15 13:21:05', 2, 1, NULL, '34.143.229.197', '2026-02-27 12:02:50', '2026-03-08 13:21:05');
INSERT INTO `b_users` VALUES (3, 'task', 'task@qq.com', NULL, '$2y$10$0PP6e.WnVHlu89mCdThwjemgzakVTpxzv021Cib9Yf/HULOolAhfK', 'task', 'task', 'eyJ1c2VyX2lkIjozLCJ0eXBlIjoyLCJleHAiOjE3NzM1MDM1NTJ9', '2026-03-14 23:52:32', 7, 1, NULL, '223.74.60.135', '2026-03-01 00:48:16', '2026-03-07 23:52:32');
INSERT INTO `b_users` VALUES (4, '6666', '2625228169@qq.com', NULL, '$2y$10$cvmarlmOyyh0pZmNpZn2LeAEVveublaPt2QfK22mBGf/oH2789LyG', '11', 'QWE', 'eyJ1c2VyX2lkIjo0LCJ0eXBlIjoyLCJleHAiOjE3NzM1NzEzMTN9', '2026-03-15 18:41:53', 10, 1, NULL, '34.143.229.197', '2026-03-06 14:46:54', '2026-03-08 18:41:53');
INSERT INTO `b_users` VALUES (5, 'Ceshi3', '123456@gmail.com', '13145678910', '$2y$10$YIm6OTfuUhj5VxYfVWoSu.ONne..7NVIKVMYCx0zajHhzHeZqeQNG', '勇敢', '果断', 'eyJ1c2VyX2lkIjo1LCJ0eXBlIjoyLCJleHAiOjE3NzM1NDc2MTB9', '2026-03-15 12:06:50', 11, 1, NULL, '34.143.229.197', '2026-03-08 12:06:11', '2026-03-08 12:06:50');

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
) ENGINE = InnoDB AUTO_INCREMENT = 30 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端任务记录表-接单执行审核全流程' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of c_task_records
-- ----------------------------
INSERT INTO `c_task_records` VALUES (1, 2, 2, 2, 2, '9:/Y.. 07/31 o@Q.Kj 复制打开抖音，查看【辉总不累】发布作品的评论：死磕，做到极致。➝➝o7wgJAyHg49ŠŠ', '{\"at_user\": \"\", \"comment\": \"123456789224\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 80, '2026-02-27 18:31:47', NULL, NULL);
INSERT INTO `c_task_records` VALUES (2, 3, 2, 2, 2, '9:/Y.. 07/31 o@Q.Kj 复制打开抖音，查看【辉总不累】发布作品的评论：死磕，做到极致。➝➝o7wgJAyHg49ŠŠ', '{\"at_user\": \"\", \"comment\": \"有你真好，梅姐\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 80, '2026-02-27 18:36:54', NULL, NULL);
INSERT INTO `c_task_records` VALUES (3, 2, 4, 1, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试上评评论\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 100, '2026-03-01 00:36:33', NULL, NULL);
INSERT INTO `c_task_records` VALUES (4, 5, 4, 1, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试上评评论\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"\"]', 3, NULL, 100, '2026-03-01 01:00:34', '2026-03-01 01:00:51', '2026-03-04 17:33:01');
INSERT INTO `c_task_records` VALUES (5, 5, 5, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 100, '2026-03-03 11:28:36', NULL, NULL);
INSERT INTO `c_task_records` VALUES (6, 5, 6, 3, 2, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，中评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 80, '2026-03-03 11:48:48', NULL, NULL);
INSERT INTO `c_task_records` VALUES (7, 5, 7, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，中评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 100, '2026-03-03 12:04:06', NULL, NULL);
INSERT INTO `c_task_records` VALUES (8, 5, 18, 3, 1, '8.23 复制打开抖音，看看【电视剧太平年（五代十国已通关的作品】# 太平年 烽火连天，不如炊烟一缕，百姓所求，不过... https://v.douyin.com/v14bLVe_vso/ 06/13 m@q.eb IVl:/', '{\"at_user\": \"\", \"comment\": \"超哥推荐的果然靠谱！亲测有效，没踩坑，又学到新技能啦！👍✨\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 100, '2026-03-05 20:59:52', NULL, NULL);
INSERT INTO `c_task_records` VALUES (9, 5, 19, 1, 1, '3.33 复制打开抖音，看看【ℳঞ洪  ໌້ᮨ꧔ꦿ᭄💕的作品】# 大山原生态之美 # 风水宝地山清水秀 # 户外... https://v.douyin.com/jY9mp8o3v7Y/ 12/13 N@w.sR HIv:/', '{\"at_user\": \"\", \"comment\": \"小雅，听你的准没错！👍 靠谱认证，必须支持！💪\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 100, '2026-03-06 11:06:03', NULL, NULL);
INSERT INTO `c_task_records` VALUES (10, 5, 22, 2, 2, '12346542', '{\"at_user\": \"脚哥\", \"comment\": \"曹作简单，这路子稳得一批！💯 …\", \"image_url\": \"\"}', '12332422', '[\"\"]', 3, NULL, 80, '2026-03-06 15:01:40', '2026-03-06 15:04:54', '2026-03-06 15:15:01');
INSERT INTO `c_task_records` VALUES (11, 5, 23, 1, 4, '1234567', '{\"comment\": \"跟了这招，小野，靠谱到飞起！爽翻啦！🔥\", \"image_url\": \"\"}', '1', '[\"\"]', 3, NULL, 100, '2026-03-07 10:33:54', '2026-03-07 10:37:20', '2026-03-07 10:38:37');
INSERT INTO `c_task_records` VALUES (12, 5, 27, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"http:\\/\\/54.179.253.64:28806\\/img\\/344ccc2b0873c9f91547ebce99c6434a.jpg\"]', 3, NULL, 100, '2026-03-07 11:25:33', '2026-03-07 11:25:48', '2026-03-07 11:36:01');
INSERT INTO `c_task_records` VALUES (13, 5, 28, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/kktaskpaas.com\\/img\\/344ccc2b0873c9f91547ebce99c6434a.jpg\"]', 3, NULL, 100, '2026-03-07 11:39:38', '2026-03-07 11:40:10', '2026-03-07 11:51:01');
INSERT INTO `c_task_records` VALUES (14, 5, 29, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/kktaskpaas.com\\/img\\/344ccc2b0873c9f91547ebce99c6434a.jpg\"]', 3, NULL, 100, '2026-03-07 12:08:16', '2026-03-07 12:08:23', '2026-03-07 12:19:01');
INSERT INTO `c_task_records` VALUES (15, 5, 30, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/kktaskpaas.com\\/img\\/344ccc2b0873c9f91547ebce99c6434a.jpg\"]', 3, NULL, 100, '2026-03-07 12:23:52', '2026-03-07 12:24:00', '2026-03-07 12:34:01');
INSERT INTO `c_task_records` VALUES (16, 5, 31, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/kktaskpaas.com\\/img\\/344ccc2b0873c9f91547ebce99c6434a.jpg\"]', 3, NULL, 100, '2026-03-07 12:52:34', '2026-03-07 12:52:40', '2026-03-07 13:03:01');
INSERT INTO `c_task_records` VALUES (17, 5, 32, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/baa9a61426acb1550ceaf131d0b48ef6.png\"]', 3, NULL, 100, '2026-03-07 13:10:14', '2026-03-07 13:10:20', '2026-03-07 13:21:01');
INSERT INTO `c_task_records` VALUES (18, 5, 33, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/baa9a61426acb1550ceaf131d0b48ef6.png\"]', 3, NULL, 100, '2026-03-07 13:40:59', '2026-03-07 13:41:05', '2026-03-07 13:52:01');
INSERT INTO `c_task_records` VALUES (19, 5, 34, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/baa9a61426acb1550ceaf131d0b48ef6.png\"]', 3, NULL, 100, '2026-03-07 13:58:45', '2026-03-07 13:58:51', '2026-03-07 14:00:18');
INSERT INTO `c_task_records` VALUES (20, 5, 35, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/baa9a61426acb1550ceaf131d0b48ef6.png\"]', 3, NULL, 100, '2026-03-07 14:06:23', '2026-03-07 14:06:29', '2026-03-07 14:17:01');
INSERT INTO `c_task_records` VALUES (21, 5, 36, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/baa9a61426acb1550ceaf131d0b48ef6.png\"]', 3, NULL, 100, '2026-03-07 14:22:20', '2026-03-07 14:22:26', '2026-03-07 14:33:01');
INSERT INTO `c_task_records` VALUES (22, 5, 37, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/baa9a61426acb1550ceaf131d0b48ef6.png\"]', 3, NULL, 100, '2026-03-07 14:35:16', '2026-03-07 14:35:22', '2026-03-07 14:46:01');
INSERT INTO `c_task_records` VALUES (23, 5, 38, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/baa9a61426acb1550ceaf131d0b48ef6.png\"]', 3, NULL, 100, '2026-03-07 14:47:20', '2026-03-07 14:47:26', '2026-03-07 14:58:01');
INSERT INTO `c_task_records` VALUES (24, 5, 39, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/baa9a61426acb1550ceaf131d0b48ef6.png\"]', 3, NULL, 100, '2026-03-07 15:04:36', '2026-03-07 15:10:45', '2026-03-07 15:21:01');
INSERT INTO `c_task_records` VALUES (25, 5, 40, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/baa9a61426acb1550ceaf131d0b48ef6.png\"]', 3, NULL, 100, '2026-03-07 15:58:53', '2026-03-07 15:58:59', '2026-03-07 16:09:01');
INSERT INTO `c_task_records` VALUES (26, 5, 41, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/baa9a61426acb1550ceaf131d0b48ef6.png\"]', 3, NULL, 100, '2026-03-07 17:30:15', '2026-03-07 17:30:21', '2026-03-07 17:34:54');
INSERT INTO `c_task_records` VALUES (27, 5, 42, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.bilibili.com/video/BV1hEAUzLEmA/?spm_id_from=333.1007.tianma.1-2-2.click', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/b0be300971b95af52dbec55a52029b44.webp\"]', 3, NULL, 100, '2026-03-07 22:53:12', '2026-03-07 23:01:28', '2026-03-07 23:12:01');
INSERT INTO `c_task_records` VALUES (28, 5, 43, 2, 2, '87M:/ 03/16 Q@K.WZ 复制打开抖音，查看【ℳঞ洪  ໌້ᮨ꧔ꦿ᭄💕】发布作品的评论：摇双色球暴富比较快ŠŠScvpCdJBEv49︽︽', '{\"at_user\": \"\", \"comment\": \"真的假的？太感谢分享了！😲👍\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 80, '2026-03-08 13:38:28', NULL, NULL);
INSERT INTO `c_task_records` VALUES (29, 5, 44, 1, 1, '123456', '{\"at_user\": \"\", \"comment\": \"🌱方法太给力了，收益蹭蹭涨！小野继续冲鸭，支持你！💪\", \"image_url\": \"\"}', '134566', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/9cc5b16cc0798052dd5a24b2403c00c4.png\"]', 3, NULL, 100, '2026-03-08 13:58:14', '2026-03-08 13:58:42', '2026-03-08 14:09:01');

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
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端用户每日统计表-限制驳回次数' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of c_user_daily_stats
-- ----------------------------
INSERT INTO `c_user_daily_stats` VALUES (1, 2, '2026-02-27', 1, 0, 0, 0, '2026-02-27 18:31:47', '2026-02-27 18:31:47');
INSERT INTO `c_user_daily_stats` VALUES (2, 3, '2026-02-27', 1, 0, 0, 0, '2026-02-27 18:36:54', '2026-02-27 18:36:54');
INSERT INTO `c_user_daily_stats` VALUES (3, 2, '2026-03-01', 1, 0, 0, 0, '2026-03-01 00:36:33', '2026-03-01 00:36:33');
INSERT INTO `c_user_daily_stats` VALUES (4, 5, '2026-03-01', 1, 1, 0, 0, '2026-03-01 01:00:34', '2026-03-01 01:00:51');
INSERT INTO `c_user_daily_stats` VALUES (5, 5, '2026-03-03', 3, 0, 0, 0, '2026-03-03 11:28:36', '2026-03-03 12:04:06');
INSERT INTO `c_user_daily_stats` VALUES (6, 5, '2026-03-04', 0, 0, 1, 0, '2026-03-04 17:33:01', '2026-03-04 17:33:01');
INSERT INTO `c_user_daily_stats` VALUES (7, 5, '2026-03-05', 1, 0, 0, 0, '2026-03-05 20:59:52', '2026-03-05 20:59:52');
INSERT INTO `c_user_daily_stats` VALUES (8, 5, '2026-03-06', 2, 1, 1, 0, '2026-03-06 11:06:03', '2026-03-06 15:15:01');
INSERT INTO `c_user_daily_stats` VALUES (9, 5, '2026-03-07', 17, 17, 17, 0, '2026-03-07 10:33:54', '2026-03-07 23:12:01');
INSERT INTO `c_user_daily_stats` VALUES (10, 5, '2026-03-08', 2, 1, 1, 0, '2026-03-08 13:38:28', '2026-03-08 14:09:01');

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
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端用户表-消费者端' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of c_users
-- ----------------------------
INSERT INTO `c_users` VALUES (1, 'taskadmin', 'taskadmin@qq.com', NULL, '$2y$10$9gww7TqOTzSA9SqchkFEgeYftRKlJ4ciYWL6IiD8DPUbQv8/PnCGe', 'W6XMFJ', NULL, 0, 'eyJ1c2VyX2lkIjoxLCJ0eXBlIjoxLCJleHAiOjE3NzI3NzM1OTN9', '2026-03-06 13:06:33', 3, 1, NULL, '120.237.23.202', '2026-02-27 13:06:22', '2026-02-27 13:06:33');
INSERT INTO `c_users` VALUES (2, 'Ceshi', '12345678@qq.com', '13112345678', '$2y$10$lvlxvu.NzhAs6m7ID2fNg.lSn.cl/hytp6/1XIAEVeA3RRYtmmH4u', '6YHUBA', NULL, 0, 'eyJ1c2VyX2lkIjoyLCJ0eXBlIjoxLCJleHAiOjE3NzI5MDI3MTZ9', '2026-03-08 00:58:36', 4, 1, NULL, '34.143.229.197', '2026-02-27 17:24:33', '2026-03-01 00:58:36');
INSERT INTO `c_users` VALUES (3, 'Ceshi2', '123456789@qq.com', '13212345678', '$2y$10$Cvl7CIY5Oj2gPcKSvNE2mONLRs14Rr1ndstVn2FHJlco8GmXxS586', 'MCVFM9', NULL, 0, 'eyJ1c2VyX2lkIjozLCJ0eXBlIjoxLCJleHAiOjE3NzI3OTMxODh9', '2026-03-06 18:33:08', 5, 1, NULL, '34.143.229.197', '2026-02-27 17:26:28', '2026-02-27 18:33:08');
INSERT INTO `c_users` VALUES (4, 'Ceshi3', '123455677@qq.com', '13312345678', '$2y$10$qydW3B1EXlxJou5CUfPMaOvssOD/K8GugvQh.BeeX/KGBpPGC3awq', 'CZBBF5', NULL, 0, 'eyJ1c2VyX2lkIjo0LCJ0eXBlIjoxLCJleHAiOjE3NzI3ODk0Njh9', '2026-03-06 17:31:08', 6, 1, NULL, '34.143.229.197', '2026-02-27 17:31:08', '2026-02-27 17:31:08');
INSERT INTO `c_users` VALUES (5, 'test', 'test@qq.com', '15900000011', '$2y$10$hkD.XBnEsk7iKbrYdpuxyOmrn.vME26Z1gzkXkBEXaUQMey5b3MAm', 'TX5ECJ', NULL, 0, 'eyJ1c2VyX2lkIjo1LCJ0eXBlIjoxLCJleHAiOjE3NzM1NzIwMTd9', '2026-03-15 18:53:37', 8, 1, NULL, '223.74.60.135', '2026-03-01 00:53:23', '2026-03-08 18:53:37');
INSERT INTO `c_users` VALUES (6, 'tasktest', '', '13794719208', '$2y$10$B7twShdr0plATEq85mgnn.5qiIX7mxnWcMP4OX02L9La01U3PoUCi', 'Z2AYEM', 1, 2, 'eyJ1c2VyX2lkIjo2LCJ0eXBlIjoxLCJleHAiOjE3NzI5ODY0OTh9', '2026-03-09 00:14:58', 9, 1, NULL, '223.74.60.135', '2026-03-02 00:12:06', '2026-03-08 13:11:25');

-- ----------------------------
-- Table structure for magnifying_glass_tasks
-- ----------------------------
DROP TABLE IF EXISTS `magnifying_glass_tasks`;
CREATE TABLE `magnifying_glass_tasks`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `b_user_id` bigint UNSIGNED NOT NULL COMMENT 'B端用户ID',
  `task_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '父任务ID',
  `template_id` int UNSIGNED NOT NULL DEFAULT 3 COMMENT '任务模板ID，固定为3',
  `video_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '视频链接',
  `deadline` int UNSIGNED NOT NULL COMMENT '到期时间（10位时间戳-秒级）',
  `recommend_marks` json NULL COMMENT '推荐标记（JSON数组）',
  `task_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '任务总数量',
  `task_done` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '已完成数量',
  `task_doing` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '进行中数量',
  `task_reviewing` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '待审核数量',
  `unit_price` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '单价（元）',
  `total_price` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '总价（元）',
  `status` tinyint NOT NULL DEFAULT 2 COMMENT '状态：0=已发布，1=进行中，2=已完成，3=已取消',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `completed_at` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务标题',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_b_user_id`(`b_user_id` ASC) USING BTREE,
  INDEX `idx_task_id`(`task_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_deadline`(`deadline` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '放大镜任务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of magnifying_glass_tasks
-- ----------------------------
INSERT INTO `magnifying_glass_tasks` VALUES (1, 3, NULL, 3, 'https://www.bilibili.com/video/BV1qeZuBPE3i/?spm_id_from=333.1007.tianma.1-3-3.click&vd_source=786a0003ba5bc5348f314ee587d01658', 1780243200, '[{\"at_user\": \"@超哥超车\", \"comment\": \"蓝词搜索@超哥超车\", \"image_url\": \"\"}, {\"at_user\": \"@超哥超车\", \"comment\": \"蓝词搜索@超哥超车\", \"image_url\": \"\"}]', 2, 0, 0, 0, 5.00, 10.00, 2, '2026-03-06 20:28:07', '2026-03-06 20:28:07', NULL, '放大镜搜索词');
INSERT INTO `magnifying_glass_tasks` VALUES (2, 3, NULL, 3, 'https://www.bilibili.com/video/BV1qeZuBPE3i/?spm_id_from=333.1007.tianma.1-3-3.click&vd_source=786a0003ba5bc5348f314ee587d01658', 1780243200, '[{\"at_user\": \"@咕噜\", \"comment\": \"蓝词搜索@咕噜\", \"image_url\": \"\"}, {\"at_user\": \"@超哥超车\", \"comment\": \"蓝词搜索@超哥超车\", \"image_url\": \"\"}, {\"at_user\": \"@乔哥\", \"comment\": \"蓝词搜索@乔哥\", \"image_url\": \"\"}]', 3, 0, 0, 0, 5.00, 15.00, 2, '2026-03-06 22:40:41', '2026-03-06 22:40:41', NULL, '放大镜搜索词');
INSERT INTO `magnifying_glass_tasks` VALUES (3, 3, NULL, 3, 'https://www.bilibili.com/video/BV1xPZAB8ExF/?spm_id_from=333.1007.tianma.1-1-1.click', 1772851124, '[{\"at_user\": \"\", \"comment\": \"蓝词搜索：@超哥\", \"image_url\": \"\"}]', 5, 0, 0, 0, 5.00, 25.00, 2, '2026-03-07 10:28:44', '2026-03-07 10:28:44', NULL, '放大镜搜索词');
INSERT INTO `magnifying_glass_tasks` VALUES (4, 2, NULL, 3, '123456', 1772950514, '[{\"at_user\": \"\", \"comment\": \"小野\", \"image_url\": \"\"}]', 1, 0, 0, 0, 5.00, 5.00, 2, '2026-03-08 13:45:14', '2026-03-08 13:45:14', NULL, '放大镜搜索词');

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
) ENGINE = InnoDB AUTO_INCREMENT = 47 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统通知表-通知模板' ROW_FORMAT = Dynamic;

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
INSERT INTO `notifications` VALUES (18, '任务已超时', '您接取的任务「上评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-03-03 11:28:36\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。', 3, 5, 1, 1, NULL, '2026-03-03 11:39:01');
INSERT INTO `notifications` VALUES (19, '任务已超时', '您接取的任务「中评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-03-03 11:48:48\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。', 3, 5, 1, 1, NULL, '2026-03-03 11:59:01');
INSERT INTO `notifications` VALUES (20, '任务已超时', '您接取的任务「上评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-03-03 12:04:06\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。', 3, 5, 1, 1, NULL, '2026-03-03 12:15:01');
INSERT INTO `notifications` VALUES (21, '任务已到期下架', '您发布的任务「上评评论」已到期自动下架。\n任务进度：0/2（0%）\n截止时间：2026-03-04 01:07:39\n', 3, 3, 2, 1, NULL, '2026-03-04 01:08:01');
INSERT INTO `notifications` VALUES (22, '任务已到期下架', '您发布的任务「上中评评论」已到期自动下架。\n任务进度：0/1（0%）\n截止时间：2026-03-04 01:28:42\n', 3, 3, 2, 1, NULL, '2026-03-04 01:29:01');
INSERT INTO `notifications` VALUES (23, '任务已到期下架', '您发布的任务「上中评评论」已到期自动下架。\n任务进度：0/3（0%）\n截止时间：2026-03-04 01:28:42\n', 3, 3, 2, 1, NULL, '2026-03-04 01:29:01');
INSERT INTO `notifications` VALUES (24, '任务已到期下架', '您发布的任务「中评评论」已到期自动下架。\n任务进度：0/1（0%）\n截止时间：2026-03-04 15:22:11\n', 3, 1, 2, 1, NULL, '2026-03-04 15:23:01');
INSERT INTO `notifications` VALUES (25, '任务已到期下架', '您发布的任务「上中评评论」已到期自动下架。\n任务进度：0/1（0%）\n截止时间：2026-03-04 16:03:32\n', 3, 1, 2, 1, NULL, '2026-03-04 16:04:01');
INSERT INTO `notifications` VALUES (26, '任务已到期下架', '您发布的任务「上中评评论」已到期自动下架。\n任务进度：0/3（0%）\n截止时间：2026-03-04 16:03:32\n', 3, 1, 2, 1, NULL, '2026-03-04 16:04:01');
INSERT INTO `notifications` VALUES (27, '任务已到期下架', '您发布的任务「上评评论」已到期自动下架。\n任务进度：0/10（0%）\n截止时间：2026-03-04 20:13:06\n', 3, 1, 2, 1, NULL, '2026-03-04 20:14:02');
INSERT INTO `notifications` VALUES (28, '任务已到期下架', '您发布的任务「中评评论」已到期自动下架。\n任务进度：0/3（0%）\n截止时间：2026-03-05 01:01:30\n', 3, 3, 2, 1, NULL, '2026-03-05 01:02:01');
INSERT INTO `notifications` VALUES (29, '任务已到期下架', '您发布的任务「上评评论」已到期自动下架。\n任务进度：0/3（0%）\n截止时间：2026-03-05 12:03:44\n', 3, 1, 2, 1, NULL, '2026-03-05 12:04:01');
INSERT INTO `notifications` VALUES (30, '任务已到期下架', '您发布的任务「上评评论」已到期自动下架。\n任务进度：0/1（0%）\n截止时间：2026-03-05 12:49:21\n', 3, 1, 2, 1, NULL, '2026-03-05 12:50:01');
INSERT INTO `notifications` VALUES (31, '任务已超时', '您接取的任务「上评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-03-05 20:59:52\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。', 3, 5, 1, 1, NULL, '2026-03-05 21:10:02');
INSERT INTO `notifications` VALUES (32, '任务已到期下架', '您发布的任务「上评评论」已到期自动下架。\n任务进度：0/1（0%）\n截止时间：2026-03-05 21:29:34\n', 3, 3, 2, 1, NULL, '2026-03-05 21:30:01');
INSERT INTO `notifications` VALUES (33, '任务已到期下架', '您发布的任务「上评评论」已到期自动下架。\n任务进度：0/3（0%）\n截止时间：2026-03-06 11:15:45\n\n提示：仍有 1 个进行中、0 个待审核的记录，请及时处理。', 3, 1, 2, 1, NULL, '2026-03-06 11:16:02');
INSERT INTO `notifications` VALUES (34, '任务已超时', '您接取的任务「上评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-03-06 11:06:03\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。', 3, 5, 1, 1, NULL, '2026-03-06 11:17:01');
INSERT INTO `notifications` VALUES (35, '任务已到期下架', '您发布的任务「放大镜搜索词」已到期自动下架。\n任务进度：0/1（0%）\n截止时间：2026-03-06 11:55:44\n', 3, 1, 2, 1, NULL, '2026-03-06 11:56:01');
INSERT INTO `notifications` VALUES (36, '任务已到期下架', '您发布的任务「放大镜搜索词」已到期自动下架。\n任务进度：0/1（0%）\n截止时间：2026-03-06 13:16:28\n', 3, 1, 2, 1, NULL, '2026-03-06 13:17:01');
INSERT INTO `notifications` VALUES (37, '任务已到期下架', '您发布的任务「中评评论」已到期自动下架。\n任务进度：0/10（0%）\n截止时间：2026-03-06 15:11:14\n\n提示：仍有 0 个进行中、1 个待审核的记录，请及时处理。', 3, 2, 2, 1, NULL, '2026-03-06 15:12:02');
INSERT INTO `notifications` VALUES (38, '任务已到期下架', '您发布的任务「上中评评论」已到期自动下架。\n任务进度：0/3（0%）\n截止时间：2026-03-07 11:03:02\n', 3, 1, 2, 1, NULL, '2026-03-07 11:04:01');
INSERT INTO `notifications` VALUES (39, '任务已到期下架', '您发布的任务「放大镜搜索词」已到期自动下架。\n任务进度：0/1（0%）\n截止时间：2026-03-07 11:12:35\n', 3, 1, 2, 1, NULL, '2026-03-07 11:13:02');
INSERT INTO `notifications` VALUES (40, '任务已到期下架', '您发布的任务「放大镜搜索词」已到期自动下架。\n任务进度：0/1（0%）\n截止时间：2026-03-07 11:22:22\n', 3, 1, 2, 1, NULL, '2026-03-07 11:23:01');
INSERT INTO `notifications` VALUES (41, '充值审核通过', '您的充值申请已审核通过，金额：¥1,000.00 已到账。感谢您的使用！', 3, 5, 2, 1, NULL, '2026-03-08 13:01:11');
INSERT INTO `notifications` VALUES (42, '任务已超时', '您接取的任务「中评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-03-08 13:38:28\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。', 3, 5, 1, 1, NULL, '2026-03-08 13:49:01');
INSERT INTO `notifications` VALUES (43, '任务已到期下架', '您发布的任务「中评评论」已到期自动下架。\n任务进度：0/3（0%）\n截止时间：2026-03-08 14:06:57\n', 3, 2, 2, 1, NULL, '2026-03-08 14:07:01');
INSERT INTO `notifications` VALUES (44, '任务已到期下架', '您发布的任务「上评评论」已到期自动下架。\n任务进度：0/3（0%）\n截止时间：2026-03-08 14:08:15\n\n提示：仍有 0 个进行中、1 个待审核的记录，请及时处理。', 3, 1, 2, 1, NULL, '2026-03-08 14:09:01');
INSERT INTO `notifications` VALUES (45, '任务已到期下架', '您发布的任务「中下评评论」已到期自动下架。\n任务进度：0/1（0%）\n截止时间：2026-03-08 14:16:29\n', 3, 1, 2, 1, NULL, '2026-03-08 14:17:01');
INSERT INTO `notifications` VALUES (46, '任务已到期下架', '您发布的任务「中下评评论」已到期自动下架。\n任务进度：0/1（0%）\n截止时间：2026-03-08 14:16:29\n', 3, 1, 2, 1, NULL, '2026-03-08 14:17:01');

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
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '充值申请表-需要管理员审核' ROW_FORMAT = Dynamic;

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
INSERT INTO `recharge_requests` VALUES (8, 5, 'Ceshi3', 2, 11, 100000, 'alipay', 'https://api.kktaskpaas.com/img/d3fd6fa1daf6e4a5867af591b59bbbbe.jpg', 81, 0, NULL, NULL, NULL, '2026-03-08 12:35:07');
INSERT INTO `recharge_requests` VALUES (9, 5, 'Ceshi3', 2, 11, 100000, 'alipay', 'https://api.kktaskpaas.com/img/cbb0c3bcc0e18d29b03c28fc57850e36.jpg', 82, 1, NULL, NULL, '2026-03-08 13:01:11', '2026-03-08 12:44:28');

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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '求租应征表-我有符合要求的账号' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rental_applications
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '求租信息表-账号需求市场' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rental_demands
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '出租信息表-账号出租市场' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rental_offers
-- ----------------------------

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
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_source`(`source_type` ASC, `source_id` ASC) USING BTREE,
  INDEX `idx_buyer`(`buyer_user_id` ASC, `buyer_user_type` ASC) USING BTREE,
  INDEX `idx_seller`(`seller_user_id` ASC, `seller_user_type` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '租赁订单表-成交订单记录' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '工单消息表-客服聊天记录' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '租赁工单表-售后纠纷处理' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rental_tickets
-- ----------------------------

-- ----------------------------
-- Table structure for system_permission_template
-- ----------------------------
DROP TABLE IF EXISTS `system_permission_template`;
CREATE TABLE `system_permission_template`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '模板ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '面板名称（中文）',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '面板代码（英文）',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '面板描述',
  `parent_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '父级面板ID',
  `icon` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图标类名',
  `url` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '页面URL',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序顺序',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=启用，0=禁用',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统权限模板表（导航栏面板）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_permission_template
-- ----------------------------
INSERT INTO `system_permission_template` VALUES (1, '统计面板', 'dashboard', '系统运营概览', NULL, 'ri-dashboard-3-line', 'dashboard', 1, 1, '2026-03-06 16:44:05', '2026-03-06 16:44:05');
INSERT INTO `system_permission_template` VALUES (2, 'B端用户', 'b-users', 'B端用户管理', NULL, 'ri-building-4-line', 'b-users', 2, 1, '2026-03-06 16:44:05', '2026-03-06 16:44:05');
INSERT INTO `system_permission_template` VALUES (3, 'C端用户', 'c-users', 'C端用户管理', NULL, 'ri-user-3-line', 'c-users', 3, 1, '2026-03-06 16:44:05', '2026-03-06 16:44:05');
INSERT INTO `system_permission_template` VALUES (4, '系统用户', 'system-users', '系统用户管理', NULL, 'ri-admin-line', 'system-users', 4, 1, '2026-03-06 16:44:05', '2026-03-06 16:44:05');
INSERT INTO `system_permission_template` VALUES (5, '角色管理', 'system-roles', '角色权限管理', NULL, 'ri-shield-keyhole-line', 'system-roles', 5, 1, '2026-03-06 16:44:05', '2026-03-06 16:44:05');
INSERT INTO `system_permission_template` VALUES (6, '权限管理', 'system-permissions', '权限模板管理', NULL, 'ri-lock-line', 'system-permissions', 6, 1, '2026-03-06 16:44:05', '2026-03-06 16:44:05');
INSERT INTO `system_permission_template` VALUES (7, '任务模板', 'templates', '任务模板管理', NULL, 'ri-file-list-3-line', 'templates', 7, 1, '2026-03-06 16:44:05', '2026-03-06 16:44:05');
INSERT INTO `system_permission_template` VALUES (8, '任务市场', 'market', '任务市场监控', NULL, 'ri-store-2-line', 'market', 8, 1, '2026-03-06 16:44:05', '2026-03-06 16:44:05');
INSERT INTO `system_permission_template` VALUES (9, '任务审核', 'task-review', '任务审核管理', NULL, 'ri-check-double-line', 'task-review', 9, 1, '2026-03-06 16:44:05', '2026-03-06 16:44:05');
INSERT INTO `system_permission_template` VALUES (10, '放大镜任务', 'magnifier', '放大镜任务管理', NULL, 'ri-search-line', 'magnifier', 10, 1, '2026-03-06 16:44:05', '2026-03-06 16:44:05');
INSERT INTO `system_permission_template` VALUES (11, '钱包记录', 'wallet-logs', '钱包资金记录', NULL, 'ri-wallet-3-line', 'wallet-logs', 11, 1, '2026-03-06 16:44:05', '2026-03-06 16:44:05');
INSERT INTO `system_permission_template` VALUES (12, '充值审核', 'recharge', '充值审核管理', NULL, 'ri-money-dollar-circle-line', 'recharge', 12, 1, '2026-03-06 16:44:05', '2026-03-06 16:44:05');
INSERT INTO `system_permission_template` VALUES (13, '提现审核', 'withdraw', '提现审核管理', NULL, 'ri-hand-coin-line', 'withdraw', 13, 1, '2026-03-06 16:44:05', '2026-03-06 16:44:05');
INSERT INTO `system_permission_template` VALUES (14, '团长审核', 'agent', '团长申请审核', NULL, 'ri-vip-crown-line', 'agent', 14, 1, '2026-03-06 16:44:05', '2026-03-06 16:44:05');
INSERT INTO `system_permission_template` VALUES (15, '租赁处理', 'rental-orders', '租赁订单处理', NULL, 'ri-home-smile-2-line', 'rental-orders', 15, 1, '2026-03-06 16:44:05', '2026-03-06 16:44:05');
INSERT INTO `system_permission_template` VALUES (16, '工单管理', 'rental-tickets', '租赁工单管理', NULL, 'ri-customer-service-2-line', 'rental-tickets', 16, 1, '2026-03-06 16:44:05', '2026-03-06 16:44:05');
INSERT INTO `system_permission_template` VALUES (17, '网站配置', 'system-config', '网站系统配置', NULL, 'ri-settings-4-line', 'system-config', 17, 1, '2026-03-06 16:44:05', '2026-03-06 16:44:05');
INSERT INTO `system_permission_template` VALUES (18, '系统通知', 'notifications', '系统通知管理', NULL, 'ri-notification-3-line', 'notifications', 18, 1, '2026-03-06 16:44:05', '2026-03-06 16:44:05');

-- ----------------------------
-- Table structure for system_role_permission_template
-- ----------------------------
DROP TABLE IF EXISTS `system_role_permission_template`;
CREATE TABLE `system_role_permission_template`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `role_id` bigint UNSIGNED NOT NULL COMMENT '角色ID',
  `template_id` bigint UNSIGNED NOT NULL COMMENT '模板ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_template`(`role_id` ASC, `template_id` ASC) USING BTREE,
  INDEX `idx_role_id`(`role_id` ASC) USING BTREE,
  INDEX `idx_template_id`(`template_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 91 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '角色权限模板关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_role_permission_template
-- ----------------------------
INSERT INTO `system_role_permission_template` VALUES (1, 1, 1, '2026-03-06 16:44:05');
INSERT INTO `system_role_permission_template` VALUES (2, 1, 2, '2026-03-06 16:44:05');
INSERT INTO `system_role_permission_template` VALUES (3, 1, 3, '2026-03-06 16:44:05');
INSERT INTO `system_role_permission_template` VALUES (4, 1, 4, '2026-03-06 16:44:05');
INSERT INTO `system_role_permission_template` VALUES (5, 1, 5, '2026-03-06 16:44:05');
INSERT INTO `system_role_permission_template` VALUES (6, 1, 6, '2026-03-06 16:44:05');
INSERT INTO `system_role_permission_template` VALUES (7, 1, 7, '2026-03-06 16:44:05');
INSERT INTO `system_role_permission_template` VALUES (8, 1, 8, '2026-03-06 16:44:05');
INSERT INTO `system_role_permission_template` VALUES (9, 1, 9, '2026-03-06 16:44:05');
INSERT INTO `system_role_permission_template` VALUES (10, 1, 10, '2026-03-06 16:44:05');
INSERT INTO `system_role_permission_template` VALUES (11, 1, 11, '2026-03-06 16:44:05');
INSERT INTO `system_role_permission_template` VALUES (12, 1, 12, '2026-03-06 16:44:05');
INSERT INTO `system_role_permission_template` VALUES (13, 1, 13, '2026-03-06 16:44:05');
INSERT INTO `system_role_permission_template` VALUES (14, 1, 14, '2026-03-06 16:44:05');
INSERT INTO `system_role_permission_template` VALUES (15, 1, 15, '2026-03-06 16:44:05');
INSERT INTO `system_role_permission_template` VALUES (16, 1, 16, '2026-03-06 16:44:05');
INSERT INTO `system_role_permission_template` VALUES (17, 1, 17, '2026-03-06 16:44:05');
INSERT INTO `system_role_permission_template` VALUES (18, 1, 18, '2026-03-06 16:44:05');
INSERT INTO `system_role_permission_template` VALUES (32, 6, 1, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (33, 6, 2, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (34, 6, 3, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (35, 6, 4, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (36, 6, 5, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (37, 6, 6, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (38, 6, 7, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (39, 6, 8, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (40, 6, 9, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (41, 6, 10, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (42, 6, 11, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (43, 6, 12, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (44, 6, 13, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (45, 6, 14, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (46, 6, 15, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (47, 6, 16, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (48, 6, 17, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (49, 6, 18, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (59, 2, 1, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (60, 2, 2, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (61, 2, 3, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (62, 2, 7, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (63, 2, 8, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (64, 2, 9, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (65, 2, 10, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (66, 2, 11, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (67, 2, 12, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (68, 2, 13, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (69, 2, 14, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (70, 2, 15, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (71, 2, 16, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (72, 2, 18, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (73, 4, 1, '2026-03-06 17:58:30');
INSERT INTO `system_role_permission_template` VALUES (74, 4, 11, '2026-03-06 17:58:30');
INSERT INTO `system_role_permission_template` VALUES (75, 4, 12, '2026-03-06 17:58:30');
INSERT INTO `system_role_permission_template` VALUES (76, 4, 13, '2026-03-06 17:58:30');
INSERT INTO `system_role_permission_template` VALUES (77, 3, 1, '2026-03-06 17:58:54');
INSERT INTO `system_role_permission_template` VALUES (78, 3, 2, '2026-03-06 17:58:54');
INSERT INTO `system_role_permission_template` VALUES (79, 3, 3, '2026-03-06 17:58:54');
INSERT INTO `system_role_permission_template` VALUES (80, 5, 9, '2026-03-06 17:59:00');
INSERT INTO `system_role_permission_template` VALUES (81, 5, 10, '2026-03-06 17:59:00');
INSERT INTO `system_role_permission_template` VALUES (82, 5, 11, '2026-03-06 17:59:00');
INSERT INTO `system_role_permission_template` VALUES (83, 5, 12, '2026-03-06 17:59:00');
INSERT INTO `system_role_permission_template` VALUES (84, 5, 13, '2026-03-06 17:59:00');
INSERT INTO `system_role_permission_template` VALUES (85, 5, 14, '2026-03-06 17:59:00');
INSERT INTO `system_role_permission_template` VALUES (86, 5, 15, '2026-03-06 17:59:00');
INSERT INTO `system_role_permission_template` VALUES (87, 5, 16, '2026-03-06 17:59:00');
INSERT INTO `system_role_permission_template` VALUES (88, 5, 18, '2026-03-06 17:59:00');
INSERT INTO `system_role_permission_template` VALUES (90, 7, 1, '2026-03-07 10:58:18');

-- ----------------------------
-- Table structure for system_roles
-- ----------------------------
DROP TABLE IF EXISTS `system_roles`;
CREATE TABLE `system_roles`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色名称',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '角色描述',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=启用，0=禁用',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_name`(`name` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '后台管理角色表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_roles
-- ----------------------------
INSERT INTO `system_roles` VALUES (1, '超级管理员', '拥有最高权限', 1, '2026-03-06 15:03:35', '2026-03-06 15:03:35');
INSERT INTO `system_roles` VALUES (2, '管理员', '拥有大部分管理权限', 1, '2026-03-06 15:03:35', '2026-03-06 15:03:35');
INSERT INTO `system_roles` VALUES (3, '运营', '系统运维权限', 1, '2026-03-06 15:03:35', '2026-03-06 17:56:48');
INSERT INTO `system_roles` VALUES (4, '财务', '财务管理权限', 1, '2026-03-06 15:03:35', '2026-03-06 15:03:35');
INSERT INTO `system_roles` VALUES (5, '客服', '客户服务权限', 1, '2026-03-06 15:03:35', '2026-03-06 15:03:35');
INSERT INTO `system_roles` VALUES (7, '审计', '给投资方、股东查看平台流水', 1, '2026-03-06 18:15:28', '2026-03-06 18:15:28');

-- ----------------------------
-- Table structure for system_users
-- ----------------------------
DROP TABLE IF EXISTS `system_users`;
CREATE TABLE `system_users`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码哈希',
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邮箱',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `role_id` bigint UNSIGNED NOT NULL COMMENT '角色ID',
  `token` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前有效Token',
  `token_expired_at` datetime NULL DEFAULT NULL COMMENT 'Token过期时间',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=正常，0=禁用',
  `last_login_at` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_email`(`email` ASC) USING BTREE,
  INDEX `idx_role_id`(`role_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '后台管理用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_users
-- ----------------------------
INSERT INTO `system_users` VALUES (1, 'task', 'd7ec460ef7be466ab80efd4c289ab9f4', 'admin@example.com', '13800138000', 1, 'a889d07362d1b6a6d47d28060018c38a', '2026-03-09 19:11:12', 1, '2026-03-08 19:11:12', '2026-03-06 15:32:33', '2026-03-08 19:11:12');
INSERT INTO `system_users` VALUES (2, 'kefu', 'e99a18c428cb38d5f260853678922e03', 'kefu@qq.com', '15900000000', 5, '96e5c379ab22bc8165c9e5ccc37262ac', '2026-03-07 10:17:08', 1, '2026-03-06 18:17:08', '2026-03-06 18:09:15', '2026-03-06 18:17:08');
INSERT INTO `system_users` VALUES (3, 'shenji', 'e99a18c428cb38d5f260853678922e03', '', '15900000001', 7, '54de1ef7302bae1f7259845cef6d2ff8', '2026-03-07 22:51:52', 1, '2026-03-06 22:51:52', '2026-03-06 18:16:16', '2026-03-06 22:51:52');

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
INSERT INTO `task_templates` VALUES (1, 0, '上评评论', 3.00, '发布上评评论', '', NULL, NULL, NULL, NULL, 1, 0, 100, 50, 50, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (2, 0, '中评评论', 2.00, '发布中评评论', '', NULL, NULL, NULL, NULL, 3, 0, 80, 30, 30, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (3, 0, '放大镜搜索词', 5.00, '抖音平台规则问题，本产品属于概率出现蓝词，搜索词搜索次数就越多，出现概率越大', '', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (4, 1, '上中评评论', 9.00, '组合评论：上评+中评(1+3)', '', '上评评论', 3.00, '中评回复', 2.00, 1, 3, 0, 0, 0, 100, 50, 50, 80, 30, 30, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (5, 1, '中下评评论', 6.00, '组合评论：中评+下评(1+1)', '-', '中评评论', 3.00, '下评回复', 3.00, 1, 1, 0, 0, 0, 130, 45, 43, 130, 45, 45, 1, '2026-02-15 14:51:45');

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
) ENGINE = InnoDB AUTO_INCREMENT = 47 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户通知表-每个用户收到的通知' ROW_FORMAT = Dynamic;

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
INSERT INTO `user_notifications` VALUES (9, 9, 2, 2, 1, '2026-03-06 14:45:18', '2026-02-27 18:56:02');
INSERT INTO `user_notifications` VALUES (10, 10, 2, 2, 1, '2026-03-06 14:45:18', '2026-02-27 19:02:01');
INSERT INTO `user_notifications` VALUES (11, 11, 1, 2, 1, '2026-03-04 12:45:51', '2026-02-28 23:20:14');
INSERT INTO `user_notifications` VALUES (12, 12, 2, 2, 1, '2026-03-06 14:45:18', '2026-02-28 23:45:01');
INSERT INTO `user_notifications` VALUES (13, 13, 2, 2, 1, '2026-03-06 14:45:18', '2026-03-01 00:00:04');
INSERT INTO `user_notifications` VALUES (14, 14, 2, 1, 0, NULL, '2026-03-01 00:47:02');
INSERT INTO `user_notifications` VALUES (15, 15, 3, 2, 1, '2026-03-04 01:15:43', '2026-03-01 00:51:51');
INSERT INTO `user_notifications` VALUES (16, 16, 3, 2, 1, '2026-03-04 01:15:43', '2026-03-01 00:55:31');
INSERT INTO `user_notifications` VALUES (17, 17, 3, 2, 1, '2026-03-04 01:15:43', '2026-03-01 00:56:41');
INSERT INTO `user_notifications` VALUES (18, 18, 5, 1, 0, NULL, '2026-03-03 11:39:01');
INSERT INTO `user_notifications` VALUES (19, 19, 5, 1, 0, NULL, '2026-03-03 11:59:01');
INSERT INTO `user_notifications` VALUES (20, 20, 5, 1, 0, NULL, '2026-03-03 12:15:01');
INSERT INTO `user_notifications` VALUES (21, 21, 3, 2, 1, '2026-03-04 01:15:43', '2026-03-04 01:08:01');
INSERT INTO `user_notifications` VALUES (22, 22, 3, 2, 1, '2026-03-04 21:29:34', '2026-03-04 01:29:01');
INSERT INTO `user_notifications` VALUES (23, 23, 3, 2, 1, '2026-03-04 21:29:34', '2026-03-04 01:29:01');
INSERT INTO `user_notifications` VALUES (24, 24, 1, 2, 1, '2026-03-04 15:25:22', '2026-03-04 15:23:01');
INSERT INTO `user_notifications` VALUES (25, 25, 1, 2, 1, '2026-03-04 18:10:06', '2026-03-04 16:04:01');
INSERT INTO `user_notifications` VALUES (26, 26, 1, 2, 1, '2026-03-04 18:10:11', '2026-03-04 16:04:01');
INSERT INTO `user_notifications` VALUES (27, 27, 1, 2, 1, '2026-03-05 11:56:33', '2026-03-04 20:14:02');
INSERT INTO `user_notifications` VALUES (28, 28, 3, 2, 1, '2026-03-07 11:37:18', '2026-03-05 01:02:01');
INSERT INTO `user_notifications` VALUES (29, 29, 1, 2, 1, '2026-03-05 12:15:11', '2026-03-05 12:04:01');
INSERT INTO `user_notifications` VALUES (30, 30, 1, 2, 1, '2026-03-05 14:21:12', '2026-03-05 12:50:01');
INSERT INTO `user_notifications` VALUES (31, 31, 5, 1, 0, NULL, '2026-03-05 21:10:02');
INSERT INTO `user_notifications` VALUES (32, 32, 3, 2, 1, '2026-03-07 11:37:18', '2026-03-05 21:30:01');
INSERT INTO `user_notifications` VALUES (33, 33, 1, 2, 1, '2026-03-06 11:24:26', '2026-03-06 11:16:02');
INSERT INTO `user_notifications` VALUES (34, 34, 5, 1, 0, NULL, '2026-03-06 11:17:01');
INSERT INTO `user_notifications` VALUES (35, 35, 1, 2, 1, '2026-03-06 13:23:56', '2026-03-06 11:56:01');
INSERT INTO `user_notifications` VALUES (36, 36, 1, 2, 1, '2026-03-06 13:23:53', '2026-03-06 13:17:01');
INSERT INTO `user_notifications` VALUES (37, 37, 2, 2, 1, '2026-03-07 06:22:48', '2026-03-06 15:12:02');
INSERT INTO `user_notifications` VALUES (38, 38, 1, 2, 1, '2026-03-07 12:43:56', '2026-03-07 11:04:01');
INSERT INTO `user_notifications` VALUES (39, 39, 1, 2, 1, '2026-03-07 12:43:56', '2026-03-07 11:13:02');
INSERT INTO `user_notifications` VALUES (40, 40, 1, 2, 1, '2026-03-07 12:43:56', '2026-03-07 11:23:01');
INSERT INTO `user_notifications` VALUES (41, 41, 5, 2, 0, NULL, '2026-03-08 13:01:11');
INSERT INTO `user_notifications` VALUES (42, 42, 5, 1, 0, NULL, '2026-03-08 13:49:01');
INSERT INTO `user_notifications` VALUES (43, 43, 2, 2, 0, NULL, '2026-03-08 14:07:01');
INSERT INTO `user_notifications` VALUES (44, 44, 1, 2, 1, '2026-03-08 15:00:54', '2026-03-08 14:09:01');
INSERT INTO `user_notifications` VALUES (45, 45, 1, 2, 1, '2026-03-08 15:00:54', '2026-03-08 14:17:01');
INSERT INTO `user_notifications` VALUES (46, 46, 1, 2, 1, '2026-03-08 15:00:54', '2026-03-08 14:17:01');

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付密码表-钱包支付密码管理' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '钱包表-三端共用' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of wallets
-- ----------------------------
INSERT INTO `wallets` VALUES (1, 209100, '2026-02-27 11:49:20', '2026-03-08 13:46:30');
INSERT INTO `wallets` VALUES (2, 205600, '2026-02-27 12:02:50', '2026-03-08 13:45:14');
INSERT INTO `wallets` VALUES (3, 0, '2026-02-27 13:06:22', '2026-02-27 13:06:22');
INSERT INTO `wallets` VALUES (4, 0, '2026-02-27 17:24:33', '2026-02-27 17:24:33');
INSERT INTO `wallets` VALUES (5, 0, '2026-02-27 17:26:27', '2026-02-27 17:26:27');
INSERT INTO `wallets` VALUES (6, 0, '2026-02-27 17:31:08', '2026-02-27 17:31:08');
INSERT INTO `wallets` VALUES (7, 155600, '2026-03-01 00:48:16', '2026-03-07 22:53:01');
INSERT INTO `wallets` VALUES (8, 1980, '2026-03-01 00:53:23', '2026-03-08 14:09:01');
INSERT INTO `wallets` VALUES (9, 0, '2026-03-02 00:12:06', '2026-03-02 00:12:06');
INSERT INTO `wallets` VALUES (10, 0, '2026-03-06 14:46:54', '2026-03-06 14:46:54');
INSERT INTO `wallets` VALUES (11, 100000, '2026-03-08 12:06:11', '2026-03-08 13:01:11');

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
) ENGINE = InnoDB AUTO_INCREMENT = 89 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '钱包流水表-记录所有收支' ROW_FORMAT = Dynamic;

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
INSERT INTO `wallets_log` VALUES (22, 7, 3, 'task', 2, 2, 300, 190000, 189700, 'task', 5, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-03 11:02:13');
INSERT INTO `wallets_log` VALUES (23, 7, 3, 'task', 2, 2, 600, 189700, 189100, 'task', 6, '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-03 11:48:04');
INSERT INTO `wallets_log` VALUES (24, 7, 3, 'task', 2, 2, 300, 189100, 188800, 'task', 7, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-03 12:03:50');
INSERT INTO `wallets_log` VALUES (25, 7, 3, 'task', 2, 2, 1000, 188800, 187800, 'rental_freeze', 3, '求租信息冻结预算（1000分/天×1天）：更新求租信息模块。发布测试', '2026-03-03 20:53:18');
INSERT INTO `wallets_log` VALUES (26, 7, 3, 'task', 2, 2, 20000, 187800, 167800, 'rental_freeze', 4, '求租信息冻结预算（2000分/天×10天）：测试发布求租信息更新。抖音', '2026-03-03 21:08:53');
INSERT INTO `wallets_log` VALUES (27, 7, 3, 'task', 2, 2, 1000, 167800, 166800, 'rental_freeze', 5, '求租信息冻结预算（1000分/天×1天）：发布求租信息更新。抖音', '2026-03-03 21:25:27');
INSERT INTO `wallets_log` VALUES (28, 7, 3, 'task', 2, 2, 600, 166800, 166200, 'task', 8, '发布任务【上评评论】2个任务，扣除 ¥6.00', '2026-03-04 00:37:44');
INSERT INTO `wallets_log` VALUES (29, 7, 3, 'task', 2, 2, 900, 166200, 165300, 'task', 9, '发布任务【上中评评论】4个任务，扣除 ¥9.00', '2026-03-04 01:00:08');
INSERT INTO `wallets_log` VALUES (30, 1, 1, 'Ceshi', 2, 2, 200, 219700, 219500, 'task', 11, '发布任务【中评评论】1个任务，扣除 ¥2.00', '2026-03-04 15:12:11');
INSERT INTO `wallets_log` VALUES (31, 1, 1, 'Ceshi', 2, 2, 900, 219500, 218600, 'task', 12, '发布任务【上中评评论】4个任务，扣除 ¥9.00', '2026-03-04 15:50:29');
INSERT INTO `wallets_log` VALUES (32, 8, 5, 'test', 1, 1, 100, 0, 100, 'commission', 4, '自动审核通过任务获得佣金，任务ID：4', '2026-03-04 17:33:01');
INSERT INTO `wallets_log` VALUES (33, 1, 1, 'Ceshi', 2, 2, 3000, 218600, 215600, 'task', 14, '发布任务【上评评论】10个任务，扣除 ¥30.00', '2026-03-04 20:03:07');
INSERT INTO `wallets_log` VALUES (34, 7, 3, 'task', 2, 2, 600, 165300, 164700, 'task', 15, '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-05 00:31:33');
INSERT INTO `wallets_log` VALUES (35, 1, 1, 'Ceshi', 2, 2, 900, 215600, 214700, 'task', 16, '发布任务【上评评论】3个任务，扣除 ¥9.00', '2026-03-05 11:53:47');
INSERT INTO `wallets_log` VALUES (36, 1, 1, 'Ceshi', 2, 2, 300, 214700, 214400, 'task', 17, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-05 12:19:22');
INSERT INTO `wallets_log` VALUES (37, 7, 3, 'task', 2, 2, 300, 164700, 164400, 'task', 18, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-05 20:59:37');
INSERT INTO `wallets_log` VALUES (38, 1, 1, 'Ceshi', 2, 2, 900, 214400, 213500, 'task', 19, '发布任务【上评评论】3个任务，扣除 ¥9.00', '2026-03-06 11:05:46');
INSERT INTO `wallets_log` VALUES (39, 1, 1, 'Ceshi', 2, 2, 500, 213500, 213000, 'task', 20, '发布任务【放大镜搜索词】1个任务，扣除 ¥5.00', '2026-03-06 11:25:44');
INSERT INTO `wallets_log` VALUES (40, 1, 1, 'Ceshi', 2, 2, 500, 213000, 212500, 'task', 21, '发布任务【放大镜搜索词】1个任务，扣除 ¥5.00', '2026-03-06 13:06:31');
INSERT INTO `wallets_log` VALUES (41, 2, 2, 'Ceshi1', 2, 2, 2000, 208700, 206700, 'task', 22, '发布任务【中评评论】10个任务，扣除 ¥20.00', '2026-03-06 15:01:15');
INSERT INTO `wallets_log` VALUES (42, 8, 5, 'test', 1, 1, 80, 100, 180, 'commission', 22, '自动审核通过任务获得佣金，任务ID：22', '2026-03-06 15:15:01');
INSERT INTO `wallets_log` VALUES (43, 7, 3, 'task', 2, 2, 1500, 164400, 162900, 'task', 2, '发布放大镜任务【放大镜搜索词】3个任务，扣除 ¥15.00', '2026-03-06 22:40:41');
INSERT INTO `wallets_log` VALUES (44, 7, 3, 'task', 2, 2, 2500, 162900, 160400, 'task', 3, '发布放大镜任务【放大镜搜索词】5个任务，扣除 ¥25.00', '2026-03-07 10:28:44');
INSERT INTO `wallets_log` VALUES (45, 1, 1, 'Ceshi', 2, 2, 900, 212500, 211600, 'task', 23, '发布任务【上中评评论】4个任务，扣除 ¥9.00', '2026-03-07 10:33:03');
INSERT INTO `wallets_log` VALUES (46, 8, 5, 'test', 1, 1, 100, 180, 280, 'commission', 23, '完成任务获得佣金，任务ID：23', '2026-03-07 10:38:37');
INSERT INTO `wallets_log` VALUES (47, 1, 1, 'Ceshi', 2, 2, 500, 211600, 211100, 'task', 25, '发布任务【放大镜搜索词】1个任务，扣除 ¥5.00', '2026-03-07 10:42:36');
INSERT INTO `wallets_log` VALUES (48, 1, 1, 'Ceshi', 2, 2, 500, 211100, 210600, 'task', 26, '发布任务【放大镜搜索词】1个任务，扣除 ¥5.00', '2026-03-07 10:52:23');
INSERT INTO `wallets_log` VALUES (49, 7, 3, 'task', 2, 2, 300, 160400, 160100, 'task', 27, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 11:24:54');
INSERT INTO `wallets_log` VALUES (50, 8, 5, 'test', 1, 1, 100, 280, 380, 'commission', 27, '自动审核通过任务获得佣金，任务ID：27', '2026-03-07 11:36:01');
INSERT INTO `wallets_log` VALUES (51, 7, 3, 'task', 2, 2, 300, 160100, 159800, 'task', 28, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 11:39:29');
INSERT INTO `wallets_log` VALUES (52, 8, 5, 'test', 1, 1, 100, 380, 480, 'commission', 28, '自动审核通过任务获得佣金，任务ID：28', '2026-03-07 11:51:01');
INSERT INTO `wallets_log` VALUES (53, 7, 3, 'task', 2, 2, 300, 159800, 159500, 'task', 29, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 12:08:09');
INSERT INTO `wallets_log` VALUES (54, 8, 5, 'test', 1, 1, 100, 480, 580, 'commission', 29, '自动审核通过任务获得佣金，任务ID：29', '2026-03-07 12:19:01');
INSERT INTO `wallets_log` VALUES (55, 7, 3, 'task', 2, 2, 300, 159500, 159200, 'task', 30, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 12:23:44');
INSERT INTO `wallets_log` VALUES (56, 8, 5, 'test', 1, 1, 100, 580, 680, 'commission', 30, '自动审核通过任务获得佣金，任务ID：30', '2026-03-07 12:34:01');
INSERT INTO `wallets_log` VALUES (57, 7, 3, 'task', 2, 2, 300, 159200, 158900, 'task', 31, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 12:52:23');
INSERT INTO `wallets_log` VALUES (58, 8, 5, 'test', 1, 1, 100, 680, 780, 'commission', 31, '自动审核通过任务获得佣金，任务ID：31', '2026-03-07 13:03:01');
INSERT INTO `wallets_log` VALUES (59, 7, 3, 'task', 2, 2, 300, 158900, 158600, 'task', 32, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 13:10:06');
INSERT INTO `wallets_log` VALUES (60, 8, 5, 'test', 1, 1, 100, 780, 880, 'commission', 32, '自动审核通过任务获得佣金，任务ID：32', '2026-03-07 13:21:01');
INSERT INTO `wallets_log` VALUES (61, 7, 3, 'task', 2, 2, 300, 158600, 158300, 'task', 33, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 13:40:53');
INSERT INTO `wallets_log` VALUES (62, 8, 5, 'test', 1, 1, 100, 880, 980, 'commission', 33, '自动审核通过任务获得佣金，任务ID：33', '2026-03-07 13:52:01');
INSERT INTO `wallets_log` VALUES (63, 7, 3, 'task', 2, 2, 300, 158300, 158000, 'task', 34, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 13:58:39');
INSERT INTO `wallets_log` VALUES (64, 8, 5, 'test', 1, 1, 100, 980, 1080, 'commission', 34, '完成任务获得佣金，任务ID：34', '2026-03-07 14:00:18');
INSERT INTO `wallets_log` VALUES (65, 7, 3, 'task', 2, 2, 300, 158000, 157700, 'task', 35, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 14:06:14');
INSERT INTO `wallets_log` VALUES (66, 8, 5, 'test', 1, 1, 100, 1080, 1180, 'commission', 35, '自动审核通过任务获得佣金，任务ID：35', '2026-03-07 14:17:01');
INSERT INTO `wallets_log` VALUES (67, 7, 3, 'task', 2, 2, 300, 157700, 157400, 'task', 36, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 14:22:14');
INSERT INTO `wallets_log` VALUES (68, 8, 5, 'test', 1, 1, 100, 1180, 1280, 'commission', 36, '自动审核通过任务获得佣金，任务ID：36', '2026-03-07 14:33:01');
INSERT INTO `wallets_log` VALUES (69, 7, 3, 'task', 2, 2, 300, 157400, 157100, 'task', 37, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 14:34:59');
INSERT INTO `wallets_log` VALUES (70, 8, 5, 'test', 1, 1, 100, 1280, 1380, 'commission', 37, '自动审核通过任务获得佣金，任务ID：37', '2026-03-07 14:46:01');
INSERT INTO `wallets_log` VALUES (71, 7, 3, 'task', 2, 2, 300, 157100, 156800, 'task', 38, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 14:46:27');
INSERT INTO `wallets_log` VALUES (72, 8, 5, 'test', 1, 1, 100, 1380, 1480, 'commission', 38, '自动审核通过任务获得佣金，任务ID：38', '2026-03-07 14:58:01');
INSERT INTO `wallets_log` VALUES (73, 7, 3, 'task', 2, 2, 300, 156800, 156500, 'task', 39, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 15:04:27');
INSERT INTO `wallets_log` VALUES (74, 8, 5, 'test', 1, 1, 100, 1480, 1580, 'commission', 39, '自动审核通过任务获得佣金，任务ID：39', '2026-03-07 15:21:01');
INSERT INTO `wallets_log` VALUES (75, 7, 3, 'task', 2, 2, 300, 156500, 156200, 'task', 40, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 15:58:47');
INSERT INTO `wallets_log` VALUES (76, 8, 5, 'test', 1, 1, 100, 1580, 1680, 'commission', 40, '自动审核通过任务获得佣金，任务ID：40', '2026-03-07 16:09:01');
INSERT INTO `wallets_log` VALUES (77, 7, 3, 'task', 2, 2, 300, 156200, 155900, 'task', 41, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 17:30:09');
INSERT INTO `wallets_log` VALUES (78, 8, 5, 'test', 1, 1, 100, 1680, 1780, 'commission', 41, '完成任务获得佣金，任务ID：41', '2026-03-07 17:34:54');
INSERT INTO `wallets_log` VALUES (79, 7, 3, 'task', 2, 2, 300, 155900, 155600, 'task', 42, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 22:53:01');
INSERT INTO `wallets_log` VALUES (80, 8, 5, 'test', 1, 1, 100, 1780, 1880, 'commission', 42, '自动审核通过任务获得佣金，任务ID：42', '2026-03-07 23:12:01');
INSERT INTO `wallets_log` VALUES (81, 11, 5, 'Ceshi3', 2, 1, 0, 0, 0, 'recharge', 8, '充值 ¥1,000.00（alipay），审核中', '2026-03-08 12:35:07');
INSERT INTO `wallets_log` VALUES (82, 11, 5, 'Ceshi3', 2, 1, 0, 0, 0, 'recharge', 9, '充值 ¥1,000.00（alipay），审核中', '2026-03-08 12:44:28');
INSERT INTO `wallets_log` VALUES (83, 11, 5, 'Ceshi3', 2, 1, 100000, 0, 100000, 'recharge', 9, '充值到账：¥1,000.00', '2026-03-08 13:01:11');
INSERT INTO `wallets_log` VALUES (84, 2, 2, 'Ceshi1', 2, 2, 600, 206700, 206100, 'task', 43, '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-08 13:36:57');
INSERT INTO `wallets_log` VALUES (85, 1, 1, 'Ceshi', 2, 2, 900, 210600, 209700, 'task', 44, '发布任务【上评评论】3个任务，扣除 ¥9.00', '2026-03-08 13:38:15');
INSERT INTO `wallets_log` VALUES (86, 2, 2, 'Ceshi1', 2, 2, 500, 206100, 205600, 'task', 4, '发布放大镜任务【放大镜搜索词】1个任务，扣除 ¥5.00', '2026-03-08 13:45:14');
INSERT INTO `wallets_log` VALUES (87, 1, 1, 'Ceshi', 2, 2, 600, 209700, 209100, 'task', 45, '发布任务【中下评评论】2个任务，扣除 ¥6.00', '2026-03-08 13:46:30');
INSERT INTO `wallets_log` VALUES (88, 8, 5, 'test', 1, 1, 100, 1880, 1980, 'commission', 44, '自动审核通过任务获得佣金，任务ID：44', '2026-03-08 14:09:01');

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '提现申请表-需要管理员审核' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of withdraw_requests
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
