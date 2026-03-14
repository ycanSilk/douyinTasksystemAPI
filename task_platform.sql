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

 Date: 14/03/2026 22:47:51
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admin_system_notification
-- ----------------------------
DROP TABLE IF EXISTS `admin_system_notification`;
CREATE TABLE `admin_system_notification`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `type` enum('recharge','withdraw','agent','magnifier','rental','ticket','system') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知类型',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知内容',
  `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '状态：0-未读，1-已读',
  `priority` tinyint(1) NOT NULL DEFAULT 0 COMMENT '优先级：0-普通，1-重要',
  `data` json NULL COMMENT '附加数据',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_type_status`(`type` ASC, `status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 38 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统通知表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of admin_system_notification
-- ----------------------------
INSERT INTO `admin_system_notification` VALUES (1, 'recharge', '充值审核提醒', '有1条充值申请待审核', 1, 1, '{\"count\": 1}', '2026-03-09 20:31:01', '2026-03-09 20:32:46');
INSERT INTO `admin_system_notification` VALUES (2, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-09 21:13:46', '2026-03-09 21:15:38');
INSERT INTO `admin_system_notification` VALUES (3, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-09 21:15:43', '2026-03-09 21:31:17');
INSERT INTO `admin_system_notification` VALUES (4, 'recharge', '充值审核提醒', '有1条充值申请待审核', 1, 1, '{\"count\": 1}', '2026-03-09 21:20:02', '2026-03-09 21:31:17');
INSERT INTO `admin_system_notification` VALUES (5, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-09 21:33:01', '2026-03-09 21:33:28');
INSERT INTO `admin_system_notification` VALUES (6, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-10 12:45:07', '2026-03-11 12:45:19');
INSERT INTO `admin_system_notification` VALUES (7, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-11 12:47:02', '2026-03-11 12:47:18');
INSERT INTO `admin_system_notification` VALUES (8, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-11 12:49:02', '2026-03-11 12:49:26');
INSERT INTO `admin_system_notification` VALUES (9, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-11 12:52:02', '2026-03-11 12:56:07');
INSERT INTO `admin_system_notification` VALUES (10, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-11 12:59:03', '2026-03-11 12:59:27');
INSERT INTO `admin_system_notification` VALUES (11, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-11 13:01:02', '2026-03-11 13:03:19');
INSERT INTO `admin_system_notification` VALUES (12, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-11 13:03:32', '2026-03-11 15:48:02');
INSERT INTO `admin_system_notification` VALUES (13, 'withdraw', '提现审核提醒', '有1条提现申请待审核', 1, 1, '{\"count\": 1}', '2026-03-11 15:43:36', '2026-03-11 17:30:01');
INSERT INTO `admin_system_notification` VALUES (14, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-11 16:27:04', '2026-03-11 17:30:01');
INSERT INTO `admin_system_notification` VALUES (15, 'withdraw', '提现审核提醒', '有1条提现申请待审核', 1, 1, '{\"count\": 1}', '2026-03-11 17:30:01', '2026-03-11 17:41:45');
INSERT INTO `admin_system_notification` VALUES (16, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-11 17:30:02', '2026-03-11 17:41:45');
INSERT INTO `admin_system_notification` VALUES (17, 'withdraw', '提现审核提醒', '有1条提现申请待审核', 1, 1, '{\"count\": 1}', '2026-03-11 17:42:02', '2026-03-11 17:42:03');
INSERT INTO `admin_system_notification` VALUES (18, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-11 17:42:02', '2026-03-11 17:42:03');
INSERT INTO `admin_system_notification` VALUES (19, 'withdraw', '提现审核提醒', '有1条提现申请待审核', 1, 1, '{\"count\": 1}', '2026-03-11 17:44:03', '2026-03-11 22:01:11');
INSERT INTO `admin_system_notification` VALUES (20, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-11 17:44:03', '2026-03-11 22:01:11');
INSERT INTO `admin_system_notification` VALUES (21, 'withdraw', '提现审核提醒', '有1条提现申请待审核', 1, 1, '{\"count\": 1}', '2026-03-11 22:01:13', '2026-03-11 22:01:32');
INSERT INTO `admin_system_notification` VALUES (22, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-11 22:01:13', '2026-03-11 22:01:32');
INSERT INTO `admin_system_notification` VALUES (23, 'withdraw', '提现审核提醒', '有1条提现申请待审核', 1, 1, '{\"count\": 1}', '2026-03-11 22:02:29', '2026-03-11 22:03:04');
INSERT INTO `admin_system_notification` VALUES (24, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-11 22:02:29', '2026-03-11 22:03:04');
INSERT INTO `admin_system_notification` VALUES (25, 'withdraw', '提现审核提醒', '有1条提现申请待审核', 1, 1, '{\"count\": 1}', '2026-03-11 22:03:29', '2026-03-11 22:22:39');
INSERT INTO `admin_system_notification` VALUES (26, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-11 22:03:29', '2026-03-11 22:22:37');
INSERT INTO `admin_system_notification` VALUES (27, 'withdraw', '提现审核提醒', '有1条提现申请待审核', 1, 1, '{\"count\": 1}', '2026-03-11 22:23:29', '2026-03-11 22:24:12');
INSERT INTO `admin_system_notification` VALUES (28, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-11 22:23:29', '2026-03-11 22:24:12');
INSERT INTO `admin_system_notification` VALUES (29, 'withdraw', '提现审核提醒', '有1条提现申请待审核', 1, 1, '{\"count\": 1}', '2026-03-11 22:24:29', '2026-03-13 22:44:44');
INSERT INTO `admin_system_notification` VALUES (30, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-11 22:24:29', '2026-03-13 22:44:44');
INSERT INTO `admin_system_notification` VALUES (31, 'recharge', '充值审核提醒', '有1条充值申请待审核', 1, 1, '{\"count\": 1}', '2026-03-11 22:40:29', '2026-03-13 22:44:44');
INSERT INTO `admin_system_notification` VALUES (32, 'magnifier', '放大镜任务提醒', '有1个新的放大镜任务', 1, 0, '{\"count\": 1}', '2026-03-12 00:01:49', '2026-03-13 22:44:44');
INSERT INTO `admin_system_notification` VALUES (33, 'recharge', '充值审核提醒', '有1条充值申请待审核', 0, 1, '{\"count\": 1}', '2026-03-14 16:43:08', '2026-03-14 16:43:08');
INSERT INTO `admin_system_notification` VALUES (34, 'withdraw', '提现审核提醒', '有7条提现申请待审核', 0, 1, '{\"count\": 7}', '2026-03-14 16:43:08', '2026-03-14 16:43:08');
INSERT INTO `admin_system_notification` VALUES (35, 'system', '系统通知', '{content}', 0, 0, '{\"count\": 0}', '2026-03-14 16:43:08', '2026-03-14 16:43:08');
INSERT INTO `admin_system_notification` VALUES (36, 'magnifier', '放大镜任务提醒', '有1个新的放大镜任务', 0, 0, '{\"count\": 1}', '2026-03-14 20:24:09', '2026-03-14 20:24:09');
INSERT INTO `admin_system_notification` VALUES (37, 'rental', '租赁处理提醒', '有1个租赁订单待处理', 0, 1, '{\"count\": 1}', '2026-03-14 20:32:09', '2026-03-14 20:32:09');

-- ----------------------------
-- Table structure for admin_system_notification_config
-- ----------------------------
DROP TABLE IF EXISTS `admin_system_notification_config`;
CREATE TABLE `admin_system_notification_config`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知类型编码',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知类型名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '通知类型描述',
  `enabled` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否启用：0-禁用，1-启用',
  `detection_interval` int UNSIGNED NOT NULL DEFAULT 60 COMMENT '检测间隔（秒）',
  `judgment_condition` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '通知判断条件',
  `priority` tinyint(1) NOT NULL DEFAULT 0 COMMENT '默认优先级：0-普通，1-重要',
  `notification_template` json NULL COMMENT '通知模板',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_code`(`code` ASC) USING BTREE,
  INDEX `idx_enabled`(`enabled` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '通知配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of admin_system_notification_config
-- ----------------------------
INSERT INTO `admin_system_notification_config` VALUES (1, 'recharge', '充值审核', '检测充值申请待审核数量', 1, 60, 'count > 0', 1, '{\"title\": \"充值审核提醒\", \"content\": \"有{count}条充值申请待审核\"}', '2026-03-09 20:16:21', '2026-03-09 20:16:21');
INSERT INTO `admin_system_notification_config` VALUES (2, 'withdraw', '提现审核', '检测提现申请待审核数量', 1, 60, 'count > 0', 1, '{\"title\": \"提现审核提醒\", \"content\": \"有{count}条提现申请待审核\"}', '2026-03-09 20:16:21', '2026-03-09 20:16:21');
INSERT INTO `admin_system_notification_config` VALUES (3, 'agent', '团长审核', '检测团长申请待审核数量', 1, 60, 'count > 0', 1, '{\"title\": \"团长审核提醒\", \"content\": \"有{count}条团长申请待审核\"}', '2026-03-09 20:16:21', '2026-03-09 20:16:21');
INSERT INTO `admin_system_notification_config` VALUES (4, 'magnifier', '放大镜任务', '检测放大镜任务数量变化', 1, 60, 'count > 0', 0, '{\"title\": \"放大镜任务提醒\", \"content\": \"有{count}个新的放大镜任务\"}', '2026-03-09 20:16:21', '2026-03-09 20:16:21');
INSERT INTO `admin_system_notification_config` VALUES (5, 'rental', '租赁处理', '检测待客服处理的租赁订单', 1, 60, 'count > 0', 1, '{\"title\": \"租赁处理提醒\", \"content\": \"有{count}个租赁订单待处理\"}', '2026-03-09 20:16:21', '2026-03-09 20:16:21');
INSERT INTO `admin_system_notification_config` VALUES (6, 'ticket', '工单管理', '检测工单待处理数量', 1, 60, 'count > 0', 1, '{\"title\": \"工单提醒\", \"content\": \"有{count}个工单待处理\"}', '2026-03-09 20:16:21', '2026-03-09 20:16:21');
INSERT INTO `admin_system_notification_config` VALUES (7, 'system', '系统通知', '系统级别的通知', 1, 3600, 'true', 0, '{\"title\": \"系统通知\", \"content\": \"{content}\"}', '2026-03-09 20:16:21', '2026-03-09 20:16:21');

-- ----------------------------
-- Table structure for admin_system_notification_log
-- ----------------------------
DROP TABLE IF EXISTS `admin_system_notification_log`;
CREATE TABLE `admin_system_notification_log`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `detection_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '检测时间',
  `has_new_notification` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否有新通知：0-无，1-有',
  `notification_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '本次检测新增通知数量',
  `detection_result` json NULL COMMENT '检测结果详情',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_detection_time`(`detection_time` ASC) USING BTREE,
  INDEX `idx_has_new_notification`(`has_new_notification` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 27 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '通知检测日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of admin_system_notification_log
-- ----------------------------
INSERT INTO `admin_system_notification_log` VALUES (1, '2026-03-09 21:13:46', 1, 1, '{\"agent\": 0, \"rental\": 0, \"system\": 0, \"ticket\": 0, \"recharge\": 0, \"withdraw\": 0, \"magnifier\": 0}', '2026-03-09 21:13:46');
INSERT INTO `admin_system_notification_log` VALUES (2, '2026-03-09 21:15:43', 1, 1, '{\"agent\": 0, \"rental\": 0, \"system\": 0, \"ticket\": 0, \"recharge\": 0, \"withdraw\": 0, \"magnifier\": 0}', '2026-03-09 21:15:43');
INSERT INTO `admin_system_notification_log` VALUES (3, '2026-03-09 21:20:02', 1, 1, '{\"agent\": 0, \"rental\": 0, \"system\": 0, \"ticket\": 0, \"recharge\": 1, \"withdraw\": 0, \"magnifier\": 0}', '2026-03-09 21:20:02');
INSERT INTO `admin_system_notification_log` VALUES (4, '2026-03-09 21:33:02', 1, 1, '{\"agent\": 0, \"rental\": 0, \"system\": 0, \"ticket\": 0, \"recharge\": 0, \"withdraw\": 0, \"magnifier\": 0}', '2026-03-09 21:33:02');
INSERT INTO `admin_system_notification_log` VALUES (5, '2026-03-10 12:45:07', 1, 1, '{\"agent\": 0, \"rental\": 0, \"system\": 0, \"ticket\": 0, \"recharge\": 0, \"withdraw\": 0, \"magnifier\": 0}', '2026-03-10 12:45:07');
INSERT INTO `admin_system_notification_log` VALUES (6, '2026-03-11 12:47:02', 1, 1, '{\"agent\": 0, \"rental\": 0, \"system\": 0, \"ticket\": 0, \"recharge\": 0, \"withdraw\": 0, \"magnifier\": 0}', '2026-03-11 12:47:02');
INSERT INTO `admin_system_notification_log` VALUES (7, '2026-03-11 12:49:02', 1, 1, '{\"agent\": 0, \"rental\": 0, \"system\": 0, \"ticket\": 0, \"recharge\": 0, \"withdraw\": 0, \"magnifier\": 0}', '2026-03-11 12:49:02');
INSERT INTO `admin_system_notification_log` VALUES (8, '2026-03-11 12:52:02', 1, 1, '{\"agent\": 0, \"rental\": 0, \"system\": 0, \"ticket\": 0, \"recharge\": 0, \"withdraw\": 0, \"magnifier\": 0}', '2026-03-11 12:52:02');
INSERT INTO `admin_system_notification_log` VALUES (9, '2026-03-11 12:59:03', 1, 1, '{\"agent\": 0, \"rental\": 0, \"system\": 0, \"ticket\": 0, \"recharge\": 0, \"withdraw\": 0, \"magnifier\": 0}', '2026-03-11 12:59:03');
INSERT INTO `admin_system_notification_log` VALUES (10, '2026-03-11 13:01:03', 1, 1, '{\"agent\": 0, \"rental\": 0, \"system\": 0, \"ticket\": 0, \"recharge\": 0, \"withdraw\": 0, \"magnifier\": 0}', '2026-03-11 13:01:03');
INSERT INTO `admin_system_notification_log` VALUES (11, '2026-03-11 13:03:32', 1, 1, '{\"agent\": 0, \"rental\": 0, \"system\": 0, \"ticket\": 0, \"recharge\": 0, \"withdraw\": 0, \"magnifier\": 0}', '2026-03-11 13:03:32');
INSERT INTO `admin_system_notification_log` VALUES (12, '2026-03-11 15:43:36', 1, 1, '{\"agent\": 0, \"rental\": 0, \"system\": 0, \"ticket\": 0, \"recharge\": 0, \"withdraw\": 1, \"magnifier\": 0}', '2026-03-11 15:43:36');
INSERT INTO `admin_system_notification_log` VALUES (13, '2026-03-11 16:27:04', 1, 1, '{\"agent\": 0, \"rental\": 0, \"system\": 0, \"ticket\": 0, \"recharge\": 0, \"withdraw\": 1, \"magnifier\": 0}', '2026-03-11 16:27:04');
INSERT INTO `admin_system_notification_log` VALUES (14, '2026-03-11 17:30:02', 1, 2, '{\"agent\": 0, \"rental\": 0, \"system\": 0, \"ticket\": 0, \"recharge\": 0, \"withdraw\": 1, \"magnifier\": 0}', '2026-03-11 17:30:02');
INSERT INTO `admin_system_notification_log` VALUES (15, '2026-03-11 17:42:02', 1, 2, '{\"agent\": 0, \"rental\": 0, \"system\": 0, \"ticket\": 0, \"recharge\": 0, \"withdraw\": 1, \"magnifier\": 0}', '2026-03-11 17:42:02');
INSERT INTO `admin_system_notification_log` VALUES (16, '2026-03-11 17:44:03', 1, 2, '{\"agent\": 0, \"rental\": 0, \"system\": 0, \"ticket\": 0, \"recharge\": 0, \"withdraw\": 1, \"magnifier\": 0}', '2026-03-11 17:44:03');
INSERT INTO `admin_system_notification_log` VALUES (17, '2026-03-11 22:01:13', 1, 2, '{\"agent\": 0, \"system\": 0, \"recharge\": 0, \"withdraw\": 1, \"magnifier\": 0}', '2026-03-11 22:01:13');
INSERT INTO `admin_system_notification_log` VALUES (18, '2026-03-11 22:02:29', 1, 2, '{\"agent\": 0, \"system\": 0, \"recharge\": 0, \"withdraw\": 1, \"magnifier\": 0}', '2026-03-11 22:02:29');
INSERT INTO `admin_system_notification_log` VALUES (19, '2026-03-11 22:03:29', 1, 2, '{\"agent\": 0, \"system\": 0, \"recharge\": 0, \"withdraw\": 1, \"magnifier\": 0}', '2026-03-11 22:03:29');
INSERT INTO `admin_system_notification_log` VALUES (20, '2026-03-11 22:23:29', 1, 2, '{\"agent\": 0, \"system\": 0, \"recharge\": 0, \"withdraw\": 1, \"magnifier\": 0}', '2026-03-11 22:23:29');
INSERT INTO `admin_system_notification_log` VALUES (21, '2026-03-11 22:24:29', 1, 2, '{\"agent\": 0, \"system\": 0, \"recharge\": 0, \"withdraw\": 1, \"magnifier\": 0}', '2026-03-11 22:24:29');
INSERT INTO `admin_system_notification_log` VALUES (22, '2026-03-11 22:40:29', 1, 1, '{\"agent\": 0, \"system\": 0, \"recharge\": 1, \"withdraw\": 1, \"magnifier\": 0}', '2026-03-11 22:40:29');
INSERT INTO `admin_system_notification_log` VALUES (23, '2026-03-12 00:01:49', 1, 1, '{\"agent\": 0, \"system\": 0, \"recharge\": 2, \"withdraw\": 1, \"magnifier\": 1}', '2026-03-12 00:01:49');
INSERT INTO `admin_system_notification_log` VALUES (24, '2026-03-14 16:43:08', 1, 3, '{\"agent\": 0, \"system\": 0, \"recharge\": 1, \"withdraw\": 7, \"magnifier\": -3}', '2026-03-14 16:43:08');
INSERT INTO `admin_system_notification_log` VALUES (25, '2026-03-14 20:24:09', 1, 1, '{\"agent\": 0, \"system\": 0, \"recharge\": 1, \"withdraw\": 0, \"magnifier\": 1}', '2026-03-14 20:24:09');
INSERT INTO `admin_system_notification_log` VALUES (26, '2026-03-14 20:32:09', 1, 1, '{\"agent\": 0, \"rental\": 1, \"system\": 0, \"recharge\": 0, \"withdraw\": 0, \"magnifier\": 0}', '2026-03-14 20:32:09');

-- ----------------------------
-- Table structure for admin_system_notification_magnifier_count
-- ----------------------------
DROP TABLE IF EXISTS `admin_system_notification_magnifier_count`;
CREATE TABLE `admin_system_notification_magnifier_count`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `current_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '当前任务数量',
  `previous_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '上次任务数量',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `last_viewed_count` int NOT NULL DEFAULT 0 COMMENT '上次查看时的任务数量',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_updated_at`(`updated_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 712 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '放大镜任务数量记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of admin_system_notification_magnifier_count
-- ----------------------------
INSERT INTO `admin_system_notification_magnifier_count` VALUES (1, 0, 0, '2026-03-09 20:16:21', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (2, 0, 0, '2026-03-09 21:13:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (3, 0, 0, '2026-03-09 21:13:10', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (4, 0, 0, '2026-03-09 21:13:10', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (5, 0, 0, '2026-03-09 21:13:11', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (6, 0, 0, '2026-03-09 21:13:46', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (7, 0, 0, '2026-03-09 21:15:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (8, 0, 0, '2026-03-09 21:15:43', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (9, 0, 0, '2026-03-09 21:18:07', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (10, 0, 0, '2026-03-09 21:20:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (11, 0, 0, '2026-03-09 21:23:28', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (12, 0, 0, '2026-03-09 21:26:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (13, 0, 0, '2026-03-09 21:27:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (14, 0, 0, '2026-03-09 21:29:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (15, 0, 0, '2026-03-09 21:31:12', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (16, 0, 0, '2026-03-09 21:33:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (17, 0, 0, '2026-03-10 12:45:07', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (18, 0, 0, '2026-03-10 13:06:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (19, 0, 0, '2026-03-10 13:35:18', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (20, 0, 0, '2026-03-11 11:21:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (21, 0, 0, '2026-03-11 11:24:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (22, 0, 0, '2026-03-11 11:26:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (23, 0, 0, '2026-03-11 11:28:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (24, 0, 0, '2026-03-11 12:05:37', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (25, 0, 0, '2026-03-11 12:29:58', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (26, 0, 0, '2026-03-11 12:32:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (27, 0, 0, '2026-03-11 12:38:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (28, 0, 0, '2026-03-11 12:45:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (29, 0, 0, '2026-03-11 12:47:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (30, 0, 0, '2026-03-11 12:49:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (31, 0, 0, '2026-03-11 12:52:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (32, 0, 0, '2026-03-11 12:54:54', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (33, 0, 0, '2026-03-11 12:56:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (34, 0, 0, '2026-03-11 12:59:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (35, 0, 0, '2026-03-11 13:01:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (36, 0, 0, '2026-03-11 13:03:32', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (37, 0, 0, '2026-03-11 13:05:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (38, 0, 0, '2026-03-11 13:15:47', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (39, 0, 0, '2026-03-11 13:17:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (40, 0, 0, '2026-03-11 13:18:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (41, 0, 0, '2026-03-11 13:19:10', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (42, 0, 0, '2026-03-11 13:20:37', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (43, 0, 0, '2026-03-11 13:21:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (44, 0, 0, '2026-03-11 13:22:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (45, 0, 0, '2026-03-11 13:23:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (46, 0, 0, '2026-03-11 13:24:05', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (47, 0, 0, '2026-03-11 13:25:30', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (48, 0, 0, '2026-03-11 13:26:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (49, 0, 0, '2026-03-11 13:27:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (50, 0, 0, '2026-03-11 13:28:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (51, 0, 0, '2026-03-11 13:29:05', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (52, 0, 0, '2026-03-11 13:30:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (53, 0, 0, '2026-03-11 13:31:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (54, 0, 0, '2026-03-11 13:33:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (55, 0, 0, '2026-03-11 13:33:06', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (56, 0, 0, '2026-03-11 13:35:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (57, 0, 0, '2026-03-11 13:37:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (58, 0, 0, '2026-03-11 13:39:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (59, 0, 0, '2026-03-11 13:41:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (60, 0, 0, '2026-03-11 13:43:07', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (61, 0, 0, '2026-03-11 13:45:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (62, 0, 0, '2026-03-11 13:47:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (63, 0, 0, '2026-03-11 13:49:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (64, 0, 0, '2026-03-11 13:53:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (65, 0, 0, '2026-03-11 13:53:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (66, 0, 0, '2026-03-11 13:56:04', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (67, 0, 0, '2026-03-11 14:04:45', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (68, 0, 0, '2026-03-11 14:06:54', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (69, 0, 0, '2026-03-11 14:08:06', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (70, 0, 0, '2026-03-11 14:08:41', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (71, 0, 0, '2026-03-11 14:10:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (72, 0, 0, '2026-03-11 14:12:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (73, 0, 0, '2026-03-11 14:14:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (74, 0, 0, '2026-03-11 14:16:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (75, 0, 0, '2026-03-11 14:18:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (76, 0, 0, '2026-03-11 15:43:36', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (77, 0, 0, '2026-03-11 16:27:04', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (78, 0, 0, '2026-03-11 16:29:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (79, 0, 0, '2026-03-11 16:31:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (80, 0, 0, '2026-03-11 16:33:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (81, 0, 0, '2026-03-11 16:35:06', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (82, 0, 0, '2026-03-11 16:37:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (83, 0, 0, '2026-03-11 16:39:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (84, 0, 0, '2026-03-11 16:41:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (85, 0, 0, '2026-03-11 16:43:04', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (86, 0, 0, '2026-03-11 16:45:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (87, 0, 0, '2026-03-11 16:47:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (88, 0, 0, '2026-03-11 16:49:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (89, 0, 0, '2026-03-11 16:51:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (90, 0, 0, '2026-03-11 16:59:58', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (91, 0, 0, '2026-03-11 17:01:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (92, 0, 0, '2026-03-11 17:22:10', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (93, 0, 0, '2026-03-11 17:24:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (94, 0, 0, '2026-03-11 17:26:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (95, 0, 0, '2026-03-11 17:28:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (96, 0, 0, '2026-03-11 17:30:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (97, 0, 0, '2026-03-11 17:32:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (98, 0, 0, '2026-03-11 17:34:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (99, 0, 0, '2026-03-11 17:36:04', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (100, 0, 0, '2026-03-11 17:38:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (101, 0, 0, '2026-03-11 17:40:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (102, 0, 0, '2026-03-11 17:42:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (103, 0, 0, '2026-03-11 17:44:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (104, 0, 0, '2026-03-11 17:46:04', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (105, 0, 0, '2026-03-11 17:48:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (106, 0, 0, '2026-03-11 17:50:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (107, 0, 0, '2026-03-11 17:52:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (108, 0, 0, '2026-03-11 17:54:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (109, 0, 0, '2026-03-11 17:56:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (110, 0, 0, '2026-03-11 17:58:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (111, 0, 0, '2026-03-11 18:00:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (112, 0, 0, '2026-03-11 18:02:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (113, 0, 0, '2026-03-11 18:04:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (114, 0, 0, '2026-03-11 18:06:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (115, 0, 0, '2026-03-11 18:08:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (116, 0, 0, '2026-03-11 18:10:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (117, 0, 0, '2026-03-11 18:12:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (118, 0, 0, '2026-03-11 18:14:04', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (119, 0, 0, '2026-03-11 18:23:11', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (120, 0, 0, '2026-03-11 18:27:20', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (121, 0, 0, '2026-03-11 18:29:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (122, 0, 0, '2026-03-11 18:31:01', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (123, 0, 0, '2026-03-11 18:33:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (124, 0, 0, '2026-03-11 18:53:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (125, 0, 0, '2026-03-11 19:03:40', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (126, 0, 0, '2026-03-11 19:35:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (127, 0, 0, '2026-03-11 20:09:36', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (128, 0, 0, '2026-03-11 20:25:23', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (129, 0, 0, '2026-03-11 20:36:40', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (130, 0, 0, '2026-03-11 20:38:07', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (131, 0, 0, '2026-03-11 21:52:00', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (132, 0, 0, '2026-03-11 21:52:03', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (133, 0, 0, '2026-03-11 21:53:04', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (134, 0, 0, '2026-03-11 21:54:05', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (135, 0, 0, '2026-03-11 21:58:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (136, 0, 0, '2026-03-11 21:58:56', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (137, 0, 0, '2026-03-11 21:59:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (138, 0, 0, '2026-03-11 21:59:58', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (139, 0, 0, '2026-03-11 22:00:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (140, 0, 0, '2026-03-11 22:01:02', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (141, 0, 0, '2026-03-11 22:01:13', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (142, 0, 0, '2026-03-11 22:01:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (143, 0, 0, '2026-03-11 22:02:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (144, 0, 0, '2026-03-11 22:03:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (145, 0, 0, '2026-03-11 22:04:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (146, 0, 0, '2026-03-11 22:05:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (147, 0, 0, '2026-03-11 22:06:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (148, 0, 0, '2026-03-11 22:07:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (149, 0, 0, '2026-03-11 22:08:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (150, 0, 0, '2026-03-11 22:09:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (151, 0, 0, '2026-03-11 22:10:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (152, 0, 0, '2026-03-11 22:11:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (153, 0, 0, '2026-03-11 22:12:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (154, 0, 0, '2026-03-11 22:13:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (155, 0, 0, '2026-03-11 22:14:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (156, 0, 0, '2026-03-11 22:15:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (157, 0, 0, '2026-03-11 22:16:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (158, 0, 0, '2026-03-11 22:17:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (159, 0, 0, '2026-03-11 22:18:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (160, 0, 0, '2026-03-11 22:19:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (161, 0, 0, '2026-03-11 22:20:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (162, 0, 0, '2026-03-11 22:21:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (163, 0, 0, '2026-03-11 22:22:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (164, 0, 0, '2026-03-11 22:23:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (165, 0, 0, '2026-03-11 22:24:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (166, 0, 0, '2026-03-11 22:25:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (167, 0, 0, '2026-03-11 22:26:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (168, 0, 0, '2026-03-11 22:27:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (169, 0, 0, '2026-03-11 22:28:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (170, 0, 0, '2026-03-11 22:29:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (171, 0, 0, '2026-03-11 22:30:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (172, 0, 0, '2026-03-11 22:31:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (173, 0, 0, '2026-03-11 22:32:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (174, 0, 0, '2026-03-11 22:33:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (175, 0, 0, '2026-03-11 22:34:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (176, 0, 0, '2026-03-11 22:35:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (177, 0, 0, '2026-03-11 22:36:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (178, 0, 0, '2026-03-11 22:37:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (179, 0, 0, '2026-03-11 22:38:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (180, 0, 0, '2026-03-11 22:39:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (181, 0, 0, '2026-03-11 22:40:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (182, 0, 0, '2026-03-11 22:41:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (183, 0, 0, '2026-03-11 22:42:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (184, 0, 0, '2026-03-11 22:43:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (185, 0, 0, '2026-03-11 22:44:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (186, 0, 0, '2026-03-11 22:45:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (187, 0, 0, '2026-03-11 22:46:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (188, 0, 0, '2026-03-11 22:47:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (189, 0, 0, '2026-03-11 22:48:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (190, 0, 0, '2026-03-11 22:49:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (191, 0, 0, '2026-03-11 22:50:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (192, 0, 0, '2026-03-11 22:51:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (193, 0, 0, '2026-03-11 22:52:11', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (194, 0, 0, '2026-03-11 22:52:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (195, 0, 0, '2026-03-11 22:53:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (196, 0, 0, '2026-03-11 22:53:31', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (197, 0, 0, '2026-03-11 22:54:30', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (198, 0, 0, '2026-03-11 22:55:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (199, 0, 0, '2026-03-11 22:56:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (200, 0, 0, '2026-03-11 22:57:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (201, 0, 0, '2026-03-11 22:58:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (202, 0, 0, '2026-03-11 22:59:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (203, 0, 0, '2026-03-11 23:00:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (204, 0, 0, '2026-03-11 23:01:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (205, 0, 0, '2026-03-11 23:02:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (206, 0, 0, '2026-03-11 23:03:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (207, 0, 0, '2026-03-11 23:04:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (208, 0, 0, '2026-03-11 23:05:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (209, 0, 0, '2026-03-11 23:06:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (210, 0, 0, '2026-03-11 23:07:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (211, 0, 0, '2026-03-11 23:08:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (212, 0, 0, '2026-03-11 23:09:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (213, 0, 0, '2026-03-11 23:10:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (214, 0, 0, '2026-03-11 23:11:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (215, 0, 0, '2026-03-11 23:12:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (216, 0, 0, '2026-03-11 23:13:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (217, 0, 0, '2026-03-11 23:14:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (218, 0, 0, '2026-03-11 23:15:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (219, 0, 0, '2026-03-11 23:16:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (220, 0, 0, '2026-03-11 23:17:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (221, 0, 0, '2026-03-11 23:18:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (222, 0, 0, '2026-03-11 23:19:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (223, 0, 0, '2026-03-11 23:20:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (224, 0, 0, '2026-03-11 23:21:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (225, 0, 0, '2026-03-11 23:22:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (226, 0, 0, '2026-03-11 23:23:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (227, 0, 0, '2026-03-11 23:24:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (228, 0, 0, '2026-03-11 23:25:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (229, 0, 0, '2026-03-11 23:26:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (230, 0, 0, '2026-03-11 23:27:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (231, 0, 0, '2026-03-11 23:28:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (232, 0, 0, '2026-03-11 23:29:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (233, 0, 0, '2026-03-11 23:30:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (234, 0, 0, '2026-03-11 23:31:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (235, 0, 0, '2026-03-11 23:32:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (236, 0, 0, '2026-03-11 23:33:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (237, 0, 0, '2026-03-11 23:34:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (238, 0, 0, '2026-03-11 23:35:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (239, 0, 0, '2026-03-11 23:36:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (240, 0, 0, '2026-03-11 23:37:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (241, 0, 0, '2026-03-11 23:38:29', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (242, 1, 0, '2026-03-12 00:01:49', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (243, 1, 1, '2026-03-12 00:05:52', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (244, 1, 1, '2026-03-12 00:09:25', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (245, 1, 1, '2026-03-12 00:13:44', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (246, 1, 1, '2026-03-12 00:14:44', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (247, 1, 1, '2026-03-12 00:14:52', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (248, 1, 1, '2026-03-12 00:15:44', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (249, 1, 1, '2026-03-12 00:15:52', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (250, 1, 1, '2026-03-12 00:16:44', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (251, 1, 1, '2026-03-12 00:16:52', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (252, 1, 1, '2026-03-12 00:17:44', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (253, 1, 1, '2026-03-12 00:17:52', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (254, 1, 1, '2026-03-12 00:18:44', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (255, 1, 1, '2026-03-12 00:18:52', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (256, 1, 1, '2026-03-12 15:02:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (257, 1, 1, '2026-03-12 15:03:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (258, 1, 1, '2026-03-12 15:04:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (259, 1, 1, '2026-03-12 15:05:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (260, 1, 1, '2026-03-12 15:06:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (261, 1, 1, '2026-03-12 15:07:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (262, 1, 1, '2026-03-12 15:08:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (263, 1, 1, '2026-03-12 15:09:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (264, 1, 1, '2026-03-12 15:10:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (265, 1, 1, '2026-03-12 15:11:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (266, 1, 1, '2026-03-12 15:12:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (267, 1, 1, '2026-03-12 15:13:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (268, 1, 1, '2026-03-12 15:14:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (269, 1, 1, '2026-03-12 15:15:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (270, 1, 1, '2026-03-12 15:16:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (271, 1, 1, '2026-03-12 15:17:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (272, 1, 1, '2026-03-12 15:18:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (273, 1, 1, '2026-03-12 15:19:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (274, 1, 1, '2026-03-12 15:20:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (275, 1, 1, '2026-03-12 15:21:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (276, 1, 1, '2026-03-12 15:22:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (277, 1, 1, '2026-03-12 15:23:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (278, 1, 1, '2026-03-12 15:24:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (279, 1, 1, '2026-03-12 15:25:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (280, 1, 1, '2026-03-12 15:26:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (281, 1, 1, '2026-03-12 15:27:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (282, 1, 1, '2026-03-12 15:28:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (283, 1, 1, '2026-03-12 15:29:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (284, 1, 1, '2026-03-12 15:30:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (285, 1, 1, '2026-03-12 15:31:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (286, 1, 1, '2026-03-12 15:32:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (287, 1, 1, '2026-03-12 15:33:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (288, 1, 1, '2026-03-12 15:34:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (289, 1, 1, '2026-03-12 15:35:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (290, 1, 1, '2026-03-12 15:36:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (291, 1, 1, '2026-03-12 15:37:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (292, 1, 1, '2026-03-12 15:38:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (293, 1, 1, '2026-03-12 15:39:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (294, 1, 1, '2026-03-12 15:40:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (295, 1, 1, '2026-03-12 15:41:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (296, 1, 1, '2026-03-12 15:42:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (297, 1, 1, '2026-03-12 15:43:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (298, 1, 1, '2026-03-12 15:44:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (299, 1, 1, '2026-03-12 15:45:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (300, 1, 1, '2026-03-12 15:46:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (301, 1, 1, '2026-03-12 15:47:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (302, 1, 1, '2026-03-12 15:48:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (303, 1, 1, '2026-03-12 15:49:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (304, 1, 1, '2026-03-12 15:50:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (305, 1, 1, '2026-03-12 15:51:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (306, 1, 1, '2026-03-12 15:52:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (307, 1, 1, '2026-03-12 15:53:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (308, 1, 1, '2026-03-12 15:54:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (309, 1, 1, '2026-03-12 15:55:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (310, 1, 1, '2026-03-12 15:56:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (311, 1, 1, '2026-03-12 15:57:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (312, 1, 1, '2026-03-12 15:58:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (313, 1, 1, '2026-03-12 15:59:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (314, 1, 1, '2026-03-12 16:00:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (315, 1, 1, '2026-03-12 16:01:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (316, 1, 1, '2026-03-12 16:02:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (317, 1, 1, '2026-03-12 16:03:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (318, 1, 1, '2026-03-12 16:04:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (319, 1, 1, '2026-03-12 16:05:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (320, 1, 1, '2026-03-12 16:06:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (321, 1, 1, '2026-03-12 16:07:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (322, 1, 1, '2026-03-12 16:08:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (323, 1, 1, '2026-03-12 16:09:12', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (324, 1, 1, '2026-03-12 16:10:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (325, 1, 1, '2026-03-12 16:11:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (326, 1, 1, '2026-03-12 16:12:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (327, 1, 1, '2026-03-12 16:13:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (328, 1, 1, '2026-03-12 16:14:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (329, 1, 1, '2026-03-12 16:15:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (330, 1, 1, '2026-03-12 16:16:11', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (331, 1, 1, '2026-03-12 16:16:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (332, 1, 1, '2026-03-12 16:17:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (333, 1, 1, '2026-03-12 16:18:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (334, 1, 1, '2026-03-12 16:19:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (335, 1, 1, '2026-03-12 16:20:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (336, 1, 1, '2026-03-12 16:21:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (337, 1, 1, '2026-03-12 16:22:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (338, 1, 1, '2026-03-12 16:23:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (339, 1, 1, '2026-03-12 16:24:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (340, 1, 1, '2026-03-12 16:25:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (341, 1, 1, '2026-03-12 16:26:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (342, 1, 1, '2026-03-12 16:27:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (343, 1, 1, '2026-03-12 16:28:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (344, 1, 1, '2026-03-12 16:29:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (345, 1, 1, '2026-03-12 16:30:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (346, 1, 1, '2026-03-12 16:31:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (347, 1, 1, '2026-03-12 16:32:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (348, 1, 1, '2026-03-12 16:33:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (349, 1, 1, '2026-03-12 16:34:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (350, 1, 1, '2026-03-12 16:35:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (351, 1, 1, '2026-03-12 16:36:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (352, 1, 1, '2026-03-12 16:37:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (353, 1, 1, '2026-03-12 16:38:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (354, 1, 1, '2026-03-12 16:39:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (355, 1, 1, '2026-03-12 16:40:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (356, 1, 1, '2026-03-12 16:41:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (357, 1, 1, '2026-03-12 16:42:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (358, 1, 1, '2026-03-12 16:43:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (359, 1, 1, '2026-03-12 16:44:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (360, 1, 1, '2026-03-12 16:45:22', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (361, 2, 1, '2026-03-12 16:46:22', 2);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (362, 3, 2, '2026-03-12 16:47:22', 3);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (363, 3, 3, '2026-03-12 16:58:42', 3);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (364, 3, 3, '2026-03-12 16:59:42', 3);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (365, 3, 3, '2026-03-12 17:00:42', 3);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (366, 3, 3, '2026-03-12 17:01:42', 3);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (367, 3, 3, '2026-03-12 17:02:42', 3);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (368, 3, 3, '2026-03-12 17:03:42', 3);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (369, 3, 3, '2026-03-13 22:51:01', 3);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (370, 3, 3, '2026-03-13 22:51:05', 3);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (371, 3, 3, '2026-03-13 22:51:05', 3);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (372, 3, 3, '2026-03-13 22:51:06', 3);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (373, 3, 3, '2026-03-13 22:51:06', 3);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (374, 3, 3, '2026-03-13 22:51:08', 3);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (375, 0, 3, '2026-03-14 16:43:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (376, 0, 0, '2026-03-14 16:44:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (377, 0, 0, '2026-03-14 16:45:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (378, 0, 0, '2026-03-14 16:46:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (379, 0, 0, '2026-03-14 16:47:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (380, 0, 0, '2026-03-14 16:48:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (381, 0, 0, '2026-03-14 16:49:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (382, 0, 0, '2026-03-14 16:50:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (383, 0, 0, '2026-03-14 16:51:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (384, 0, 0, '2026-03-14 16:52:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (385, 0, 0, '2026-03-14 16:53:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (386, 0, 0, '2026-03-14 16:54:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (387, 0, 0, '2026-03-14 16:55:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (388, 0, 0, '2026-03-14 16:56:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (389, 0, 0, '2026-03-14 16:57:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (390, 0, 0, '2026-03-14 16:58:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (391, 0, 0, '2026-03-14 16:59:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (392, 0, 0, '2026-03-14 17:00:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (393, 0, 0, '2026-03-14 17:01:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (394, 0, 0, '2026-03-14 17:02:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (395, 0, 0, '2026-03-14 17:03:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (396, 0, 0, '2026-03-14 17:04:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (397, 0, 0, '2026-03-14 17:05:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (398, 0, 0, '2026-03-14 17:06:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (399, 0, 0, '2026-03-14 17:07:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (400, 0, 0, '2026-03-14 17:08:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (401, 0, 0, '2026-03-14 17:09:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (402, 0, 0, '2026-03-14 17:10:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (403, 0, 0, '2026-03-14 17:11:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (404, 0, 0, '2026-03-14 17:12:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (405, 0, 0, '2026-03-14 17:13:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (406, 0, 0, '2026-03-14 17:14:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (407, 0, 0, '2026-03-14 17:15:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (408, 0, 0, '2026-03-14 17:16:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (409, 0, 0, '2026-03-14 17:17:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (410, 0, 0, '2026-03-14 17:18:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (411, 0, 0, '2026-03-14 17:19:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (412, 0, 0, '2026-03-14 17:20:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (413, 0, 0, '2026-03-14 17:21:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (414, 0, 0, '2026-03-14 17:22:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (415, 0, 0, '2026-03-14 17:23:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (416, 0, 0, '2026-03-14 17:24:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (417, 0, 0, '2026-03-14 17:25:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (418, 0, 0, '2026-03-14 17:26:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (419, 0, 0, '2026-03-14 17:27:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (420, 0, 0, '2026-03-14 17:28:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (421, 0, 0, '2026-03-14 17:29:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (422, 0, 0, '2026-03-14 17:30:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (423, 0, 0, '2026-03-14 17:31:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (424, 0, 0, '2026-03-14 17:32:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (425, 0, 0, '2026-03-14 17:33:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (426, 0, 0, '2026-03-14 17:34:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (427, 0, 0, '2026-03-14 17:35:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (428, 0, 0, '2026-03-14 17:36:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (429, 0, 0, '2026-03-14 17:37:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (430, 0, 0, '2026-03-14 17:38:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (431, 0, 0, '2026-03-14 17:39:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (432, 0, 0, '2026-03-14 17:40:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (433, 0, 0, '2026-03-14 17:41:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (434, 0, 0, '2026-03-14 17:42:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (435, 0, 0, '2026-03-14 17:43:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (436, 0, 0, '2026-03-14 17:44:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (437, 0, 0, '2026-03-14 17:45:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (438, 0, 0, '2026-03-14 17:46:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (439, 0, 0, '2026-03-14 17:47:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (440, 0, 0, '2026-03-14 17:48:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (441, 0, 0, '2026-03-14 17:49:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (442, 0, 0, '2026-03-14 17:50:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (443, 0, 0, '2026-03-14 17:51:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (444, 0, 0, '2026-03-14 17:52:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (445, 0, 0, '2026-03-14 17:53:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (446, 0, 0, '2026-03-14 17:54:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (447, 0, 0, '2026-03-14 17:55:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (448, 0, 0, '2026-03-14 17:56:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (449, 0, 0, '2026-03-14 17:57:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (450, 0, 0, '2026-03-14 17:58:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (451, 0, 0, '2026-03-14 17:59:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (452, 0, 0, '2026-03-14 18:00:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (453, 0, 0, '2026-03-14 18:01:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (454, 0, 0, '2026-03-14 18:02:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (455, 0, 0, '2026-03-14 18:03:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (456, 0, 0, '2026-03-14 18:04:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (457, 0, 0, '2026-03-14 18:05:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (458, 0, 0, '2026-03-14 18:06:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (459, 0, 0, '2026-03-14 18:07:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (460, 0, 0, '2026-03-14 18:08:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (461, 0, 0, '2026-03-14 18:09:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (462, 0, 0, '2026-03-14 18:10:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (463, 0, 0, '2026-03-14 18:11:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (464, 0, 0, '2026-03-14 18:12:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (465, 0, 0, '2026-03-14 18:13:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (466, 0, 0, '2026-03-14 18:14:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (467, 0, 0, '2026-03-14 18:15:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (468, 0, 0, '2026-03-14 18:16:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (469, 0, 0, '2026-03-14 18:17:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (470, 0, 0, '2026-03-14 18:18:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (471, 0, 0, '2026-03-14 18:19:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (472, 0, 0, '2026-03-14 18:20:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (473, 0, 0, '2026-03-14 18:21:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (474, 0, 0, '2026-03-14 18:22:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (475, 0, 0, '2026-03-14 18:23:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (476, 0, 0, '2026-03-14 18:24:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (477, 0, 0, '2026-03-14 18:25:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (478, 0, 0, '2026-03-14 18:26:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (479, 0, 0, '2026-03-14 18:27:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (480, 0, 0, '2026-03-14 18:28:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (481, 0, 0, '2026-03-14 18:29:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (482, 0, 0, '2026-03-14 18:30:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (483, 0, 0, '2026-03-14 18:31:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (484, 0, 0, '2026-03-14 18:32:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (485, 0, 0, '2026-03-14 18:33:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (486, 0, 0, '2026-03-14 18:34:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (487, 0, 0, '2026-03-14 18:35:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (488, 0, 0, '2026-03-14 18:36:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (489, 0, 0, '2026-03-14 18:37:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (490, 0, 0, '2026-03-14 18:38:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (491, 0, 0, '2026-03-14 18:39:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (492, 0, 0, '2026-03-14 18:40:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (493, 0, 0, '2026-03-14 18:41:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (494, 0, 0, '2026-03-14 18:42:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (495, 0, 0, '2026-03-14 18:43:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (496, 0, 0, '2026-03-14 18:44:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (497, 0, 0, '2026-03-14 18:45:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (498, 0, 0, '2026-03-14 18:46:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (499, 0, 0, '2026-03-14 18:47:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (500, 0, 0, '2026-03-14 18:48:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (501, 0, 0, '2026-03-14 18:49:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (502, 0, 0, '2026-03-14 18:50:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (503, 0, 0, '2026-03-14 18:51:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (504, 0, 0, '2026-03-14 18:52:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (505, 0, 0, '2026-03-14 18:53:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (506, 0, 0, '2026-03-14 18:54:08', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (507, 0, 0, '2026-03-14 18:55:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (508, 0, 0, '2026-03-14 18:56:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (509, 0, 0, '2026-03-14 18:57:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (510, 0, 0, '2026-03-14 18:58:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (511, 0, 0, '2026-03-14 18:59:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (512, 0, 0, '2026-03-14 19:00:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (513, 0, 0, '2026-03-14 19:01:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (514, 0, 0, '2026-03-14 19:02:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (515, 0, 0, '2026-03-14 19:03:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (516, 0, 0, '2026-03-14 19:04:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (517, 0, 0, '2026-03-14 19:05:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (518, 0, 0, '2026-03-14 19:06:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (519, 0, 0, '2026-03-14 19:07:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (520, 0, 0, '2026-03-14 19:08:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (521, 0, 0, '2026-03-14 19:09:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (522, 0, 0, '2026-03-14 19:10:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (523, 0, 0, '2026-03-14 19:11:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (524, 0, 0, '2026-03-14 19:12:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (525, 0, 0, '2026-03-14 19:13:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (526, 0, 0, '2026-03-14 19:14:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (527, 0, 0, '2026-03-14 19:15:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (528, 0, 0, '2026-03-14 19:16:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (529, 0, 0, '2026-03-14 19:17:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (530, 0, 0, '2026-03-14 19:18:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (531, 0, 0, '2026-03-14 19:19:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (532, 0, 0, '2026-03-14 19:20:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (533, 0, 0, '2026-03-14 19:21:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (534, 0, 0, '2026-03-14 19:22:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (535, 0, 0, '2026-03-14 19:23:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (536, 0, 0, '2026-03-14 19:24:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (537, 0, 0, '2026-03-14 19:25:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (538, 0, 0, '2026-03-14 19:26:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (539, 0, 0, '2026-03-14 19:27:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (540, 0, 0, '2026-03-14 19:28:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (541, 0, 0, '2026-03-14 19:29:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (542, 0, 0, '2026-03-14 19:30:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (543, 0, 0, '2026-03-14 19:31:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (544, 0, 0, '2026-03-14 19:32:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (545, 0, 0, '2026-03-14 19:33:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (546, 0, 0, '2026-03-14 19:34:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (547, 0, 0, '2026-03-14 19:35:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (548, 0, 0, '2026-03-14 19:36:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (549, 0, 0, '2026-03-14 19:37:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (550, 0, 0, '2026-03-14 19:38:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (551, 0, 0, '2026-03-14 19:39:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (552, 0, 0, '2026-03-14 19:40:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (553, 0, 0, '2026-03-14 19:41:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (554, 0, 0, '2026-03-14 19:42:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (555, 0, 0, '2026-03-14 19:43:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (556, 0, 0, '2026-03-14 19:44:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (557, 0, 0, '2026-03-14 19:45:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (558, 0, 0, '2026-03-14 19:46:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (559, 0, 0, '2026-03-14 19:47:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (560, 0, 0, '2026-03-14 19:48:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (561, 0, 0, '2026-03-14 19:49:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (562, 0, 0, '2026-03-14 19:50:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (563, 0, 0, '2026-03-14 19:51:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (564, 0, 0, '2026-03-14 19:52:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (565, 0, 0, '2026-03-14 19:53:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (566, 0, 0, '2026-03-14 19:54:10', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (567, 0, 0, '2026-03-14 19:55:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (568, 0, 0, '2026-03-14 19:56:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (569, 0, 0, '2026-03-14 19:57:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (570, 0, 0, '2026-03-14 19:58:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (571, 0, 0, '2026-03-14 19:59:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (572, 0, 0, '2026-03-14 20:00:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (573, 0, 0, '2026-03-14 20:01:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (574, 0, 0, '2026-03-14 20:02:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (575, 0, 0, '2026-03-14 20:03:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (576, 0, 0, '2026-03-14 20:04:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (577, 0, 0, '2026-03-14 20:05:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (578, 0, 0, '2026-03-14 20:06:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (579, 0, 0, '2026-03-14 20:07:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (580, 0, 0, '2026-03-14 20:08:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (581, 0, 0, '2026-03-14 20:09:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (582, 0, 0, '2026-03-14 20:10:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (583, 0, 0, '2026-03-14 20:11:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (584, 0, 0, '2026-03-14 20:12:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (585, 0, 0, '2026-03-14 20:13:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (586, 0, 0, '2026-03-14 20:14:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (587, 0, 0, '2026-03-14 20:15:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (588, 0, 0, '2026-03-14 20:16:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (589, 0, 0, '2026-03-14 20:17:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (590, 0, 0, '2026-03-14 20:18:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (591, 0, 0, '2026-03-14 20:19:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (592, 0, 0, '2026-03-14 20:20:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (593, 0, 0, '2026-03-14 20:21:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (594, 0, 0, '2026-03-14 20:22:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (595, 0, 0, '2026-03-14 20:23:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (596, 1, 0, '2026-03-14 20:24:09', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (597, 1, 1, '2026-03-14 20:25:09', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (598, 1, 1, '2026-03-14 20:26:09', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (599, 1, 1, '2026-03-14 20:27:09', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (600, 1, 1, '2026-03-14 20:27:39', 1);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (601, 0, 1, '2026-03-14 20:28:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (602, 0, 0, '2026-03-14 20:29:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (603, 0, 0, '2026-03-14 20:30:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (604, 0, 0, '2026-03-14 20:31:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (605, 0, 0, '2026-03-14 20:32:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (606, 0, 0, '2026-03-14 20:33:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (607, 0, 0, '2026-03-14 20:34:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (608, 0, 0, '2026-03-14 20:35:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (609, 0, 0, '2026-03-14 20:36:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (610, 0, 0, '2026-03-14 20:37:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (611, 0, 0, '2026-03-14 20:38:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (612, 0, 0, '2026-03-14 20:39:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (613, 0, 0, '2026-03-14 20:40:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (614, 0, 0, '2026-03-14 20:41:09', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (615, 0, 0, '2026-03-14 20:41:37', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (616, 0, 0, '2026-03-14 20:42:37', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (617, 0, 0, '2026-03-14 20:43:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (618, 0, 0, '2026-03-14 20:44:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (619, 0, 0, '2026-03-14 20:45:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (620, 0, 0, '2026-03-14 20:46:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (621, 0, 0, '2026-03-14 20:47:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (622, 0, 0, '2026-03-14 20:48:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (623, 0, 0, '2026-03-14 20:49:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (624, 0, 0, '2026-03-14 20:50:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (625, 0, 0, '2026-03-14 20:51:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (626, 0, 0, '2026-03-14 20:52:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (627, 0, 0, '2026-03-14 20:53:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (628, 0, 0, '2026-03-14 20:54:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (629, 0, 0, '2026-03-14 20:55:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (630, 0, 0, '2026-03-14 20:56:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (631, 0, 0, '2026-03-14 20:57:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (632, 0, 0, '2026-03-14 20:58:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (633, 0, 0, '2026-03-14 20:59:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (634, 0, 0, '2026-03-14 21:00:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (635, 0, 0, '2026-03-14 21:01:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (636, 0, 0, '2026-03-14 21:02:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (637, 0, 0, '2026-03-14 21:03:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (638, 0, 0, '2026-03-14 21:04:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (639, 0, 0, '2026-03-14 21:05:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (640, 0, 0, '2026-03-14 21:06:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (641, 0, 0, '2026-03-14 21:07:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (642, 0, 0, '2026-03-14 21:08:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (643, 0, 0, '2026-03-14 21:09:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (644, 0, 0, '2026-03-14 21:10:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (645, 0, 0, '2026-03-14 21:11:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (646, 0, 0, '2026-03-14 21:12:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (647, 0, 0, '2026-03-14 21:13:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (648, 0, 0, '2026-03-14 21:14:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (649, 0, 0, '2026-03-14 21:15:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (650, 0, 0, '2026-03-14 21:16:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (651, 0, 0, '2026-03-14 21:17:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (652, 0, 0, '2026-03-14 21:18:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (653, 0, 0, '2026-03-14 21:19:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (654, 0, 0, '2026-03-14 21:20:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (655, 0, 0, '2026-03-14 21:21:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (656, 0, 0, '2026-03-14 21:22:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (657, 0, 0, '2026-03-14 21:23:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (658, 0, 0, '2026-03-14 21:24:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (659, 0, 0, '2026-03-14 21:25:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (660, 0, 0, '2026-03-14 21:26:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (661, 0, 0, '2026-03-14 21:27:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (662, 0, 0, '2026-03-14 21:28:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (663, 0, 0, '2026-03-14 21:29:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (664, 0, 0, '2026-03-14 21:30:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (665, 0, 0, '2026-03-14 21:31:27', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (666, 0, 0, '2026-03-14 21:32:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (667, 0, 0, '2026-03-14 21:33:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (668, 0, 0, '2026-03-14 21:34:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (669, 0, 0, '2026-03-14 21:35:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (670, 0, 0, '2026-03-14 21:36:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (671, 0, 0, '2026-03-14 21:37:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (672, 0, 0, '2026-03-14 21:38:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (673, 0, 0, '2026-03-14 21:39:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (674, 0, 0, '2026-03-14 21:40:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (675, 0, 0, '2026-03-14 21:41:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (676, 0, 0, '2026-03-14 21:42:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (677, 0, 0, '2026-03-14 21:43:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (678, 0, 0, '2026-03-14 21:44:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (679, 0, 0, '2026-03-14 21:45:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (680, 0, 0, '2026-03-14 21:46:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (681, 0, 0, '2026-03-14 21:47:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (682, 0, 0, '2026-03-14 21:48:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (683, 0, 0, '2026-03-14 21:49:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (684, 0, 0, '2026-03-14 21:50:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (685, 0, 0, '2026-03-14 21:51:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (686, 0, 0, '2026-03-14 21:52:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (687, 0, 0, '2026-03-14 21:53:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (688, 0, 0, '2026-03-14 21:54:26', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (689, 0, 0, '2026-03-14 22:24:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (690, 0, 0, '2026-03-14 22:25:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (691, 0, 0, '2026-03-14 22:26:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (692, 0, 0, '2026-03-14 22:27:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (693, 0, 0, '2026-03-14 22:28:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (694, 0, 0, '2026-03-14 22:29:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (695, 0, 0, '2026-03-14 22:30:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (696, 0, 0, '2026-03-14 22:31:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (697, 0, 0, '2026-03-14 22:32:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (698, 0, 0, '2026-03-14 22:33:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (699, 0, 0, '2026-03-14 22:34:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (700, 0, 0, '2026-03-14 22:35:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (701, 0, 0, '2026-03-14 22:36:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (702, 0, 0, '2026-03-14 22:37:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (703, 0, 0, '2026-03-14 22:38:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (704, 0, 0, '2026-03-14 22:39:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (705, 0, 0, '2026-03-14 22:40:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (706, 0, 0, '2026-03-14 22:41:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (707, 0, 0, '2026-03-14 22:42:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (708, 0, 0, '2026-03-14 22:43:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (709, 0, 0, '2026-03-14 22:44:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (710, 0, 0, '2026-03-14 22:45:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (711, 0, 0, '2026-03-14 22:46:52', 0);

-- ----------------------------
-- Table structure for admin_system_notification_timer
-- ----------------------------
DROP TABLE IF EXISTS `admin_system_notification_timer`;
CREATE TABLE `admin_system_notification_timer`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `last_detection_time` datetime NOT NULL,
  `next_detection_time` datetime NOT NULL,
  `detection_interval` int NOT NULL DEFAULT 60,
  `status` tinyint NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '消息通知检测计时器倒计时' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of admin_system_notification_timer
-- ----------------------------
INSERT INTO `admin_system_notification_timer` VALUES (1, '2026-03-11 18:50:01', '2026-03-11 18:51:01', 60, 1, '2026-03-09 20:16:21', '2026-03-11 18:49:01');

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
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '团长申请表-C端用户申请成为团长' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of agent_applications
-- ----------------------------
INSERT INTO `agent_applications` VALUES (1, 5, 'test', 'TX5ECJ', 1, 5, 0, 1, NULL, 1, '2026-03-09 21:24:51', '2026-03-09 21:24:51', '2026-03-09 21:24:51');
INSERT INTO `agent_applications` VALUES (2, 5, 'test', 'TX5ECJ', 2, 15, 0, 1, NULL, 1, '2026-03-09 21:24:53', '2026-03-09 21:24:53', '2026-03-09 21:24:53');
INSERT INTO `agent_applications` VALUES (3, 1, 'taskadmin', 'W6XMFJ', 1, 5, 0, 1, NULL, 1, '2026-03-12 10:14:05', '2026-03-12 10:14:05', '2026-03-12 10:14:05');
INSERT INTO `agent_applications` VALUES (4, 1, 'taskadmin', 'W6XMFJ', 2, 15, 0, 1, NULL, 1, '2026-03-12 10:14:13', '2026-03-12 10:14:13', '2026-03-12 10:14:13');
INSERT INTO `agent_applications` VALUES (5, 6, 'tasktest', 'Z2AYEM', 2, 15, 0, 1, NULL, 1, '2026-03-12 10:14:39', '2026-03-12 10:14:39', '2026-03-12 10:14:39');
INSERT INTO `agent_applications` VALUES (6, 2, 'Ceshi', '6YHUBA', 2, 15, 0, 1, NULL, 1, '2026-03-12 10:14:47', '2026-03-12 10:14:47', '2026-03-12 10:14:47');
INSERT INTO `agent_applications` VALUES (7, 5, 'test', 'TX5ECJ', 2, 15, 0, 1, NULL, 1, '2026-03-12 10:21:56', '2026-03-12 10:21:56', '2026-03-12 10:21:56');
INSERT INTO `agent_applications` VALUES (8, 19, 'test1', 'Z2GJ43', 1, 5, 0, 1, NULL, 1, '2026-03-12 11:15:15', '2026-03-12 11:15:15', '2026-03-12 11:15:15');
INSERT INTO `agent_applications` VALUES (9, 20, 'test2', '4Q5A5X', 2, 15, 0, 1, NULL, 1, '2026-03-12 11:15:20', '2026-03-12 11:15:20', '2026-03-12 11:15:20');
INSERT INTO `agent_applications` VALUES (10, 26, 'test8', 'F256G7', 1, 5, 0, 1, NULL, 1, '2026-03-12 14:30:44', '2026-03-12 14:30:44', '2026-03-12 14:30:44');

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
) ENGINE = InnoDB AUTO_INCREMENT = 43 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '网站配置表' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `app_config` VALUES (26, 'agent_incentive_enabled', '0', 'int', 'incentive', '团长激励活动开关', '2026-03-13 23:01:07');
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
INSERT INTO `app_config` VALUES (37, 'notification_enabled', '1', 'boolean', 'notification', '是否启用消息通知', '2026-03-09 20:16:21');
INSERT INTO `app_config` VALUES (38, 'notification_sound_enabled', '1', 'boolean', 'notification', '是否启用通知提示音', '2026-03-09 20:16:21');
INSERT INTO `app_config` VALUES (39, 'notification_check_interval', '60', 'int', 'notification', '通知检测间隔（秒）', '2026-03-09 20:16:21');
INSERT INTO `app_config` VALUES (40, 'notification_max_unread', '50', 'int', 'notification', '最大未读通知数量', '2026-03-09 20:16:21');
INSERT INTO `app_config` VALUES (41, 'notification_types', 'recharge,withdraw,agent,magnifier,rental,ticket,system', 'array', 'notification', '启用的通知类型', '2026-03-09 20:16:21');
INSERT INTO `app_config` VALUES (42, 'large_group_agent', '0.8', 'float', 'agent', '大团团长任务佣金比例，1*100（%）', '2026-03-12 10:31:19');

-- ----------------------------
-- Table structure for b_task_statistics
-- ----------------------------
DROP TABLE IF EXISTS `b_task_statistics`;
CREATE TABLE `b_task_statistics`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '统计ID',
  `b_user_id` bigint UNSIGNED NOT NULL COMMENT 'B端用户ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（冗余字段）',
  `flow_type` tinyint NOT NULL COMMENT '流水类型：1=收入，2=支出',
  `amount` bigint NOT NULL DEFAULT 0 COMMENT '变动金额（单位：分，正数）',
  `before_balance` bigint NOT NULL DEFAULT 0 COMMENT '变动前余额（单位：分）',
  `after_balance` bigint NOT NULL DEFAULT 0 COMMENT '变动后余额（单位：分）',
  `related_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关联类型：task_publish=任务发布，recharge=充值，account_rental=账号租赁，refund=退款',
  `related_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '关联ID（任务ID、订单ID等）',
  `task_types` tinyint UNSIGNED NULL DEFAULT NULL COMMENT '任务类型：1=上评评论，2=中评评论，3=放大镜搜索词，4=上中评评论，5=中下评评论，6=出租订单，7=求租订单',
  `task_types_text` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务类型文本描述',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '流水的详细说明记录',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_b_user_id`(`b_user_id` ASC) USING BTREE,
  INDEX `idx_flow_type`(`flow_type` ASC) USING BTREE,
  INDEX `idx_related`(`related_type` ASC, `related_id` ASC) USING BTREE,
  INDEX `idx_task_types`(`task_types` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 36 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端任务统计表-记录B端用户所有金额变动' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of b_task_statistics
-- ----------------------------
INSERT INTO `b_task_statistics` VALUES (21, 3, 'task', 1, 0, 225200, 225200, 'recharge', 14, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-03-14 16:40:58');
INSERT INTO `b_task_statistics` VALUES (22, 3, 'task', 1, 20000, 225200, 245200, 'recharge', 14, 1, '充值', '充值到账：¥200.00', '2026-03-14 16:44:32');
INSERT INTO `b_task_statistics` VALUES (23, 3, 'task', 1, 20000, 245200, 245200, 'recharge', 0, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-03-14 20:21:03');
INSERT INTO `b_task_statistics` VALUES (24, 3, 'task', 2, 300, 245200, 244900, 'task_publish', 68, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-14 20:21:11');
INSERT INTO `b_task_statistics` VALUES (25, 3, 'task', 2, 600, 244900, 244300, 'task_publish', 69, 2, '中评评论', '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-14 20:22:05');
INSERT INTO `b_task_statistics` VALUES (26, 3, 'task', 2, 900, 244300, 243400, 'task_publish', 70, 4, '上中评评论', '发布任务【上中评评论】4个任务，扣除 ¥9.00', '2026-03-14 20:22:55');
INSERT INTO `b_task_statistics` VALUES (27, 3, 'task', 2, 600, 243400, 242800, 'task_publish', 72, 5, '中下评评论', '发布任务【中下评评论】2个任务，扣除 ¥6.00', '2026-03-14 20:23:08');
INSERT INTO `b_task_statistics` VALUES (28, 3, 'task', 2, 1000, 242800, 241800, 'task_publish', 10, 3, '放大镜搜索词', '发布放大镜任务【放大镜搜索词】2个任务，扣除 ¥10.00', '2026-03-14 20:23:29');
INSERT INTO `b_task_statistics` VALUES (29, 3, 'task', 2, 35000, 241800, 206800, 'account_rental', 1, 6, '出租订单', '租赁订单支付：测试租赁系统的新功能，佣金结算（7天）', '2026-03-14 20:24:49');
INSERT INTO `b_task_statistics` VALUES (30, 3, 'task', 1, 20000, 206800, 226800, 'recharge', 15, NULL, NULL, '充值到账：¥200.00', '2026-03-14 20:25:32');
INSERT INTO `b_task_statistics` VALUES (31, 3, 'task', 2, 300, 226800, 226500, 'task_publish', 74, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-14 21:19:09');
INSERT INTO `b_task_statistics` VALUES (32, 3, 'task', 2, 300, 226500, 226200, 'task_publish', 75, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-14 21:21:45');
INSERT INTO `b_task_statistics` VALUES (33, 3, 'task', 2, 25000, 196200, 171200, 'account_rental', 2, 6, '出租订单', '租赁订单支付：测试租赁系统的新功能，佣金结算（5天）', '2026-03-14 22:23:22');
INSERT INTO `b_task_statistics` VALUES (34, 3, 'task', 2, 25000, 171200, 171200, 'rental_order', 2, 7, '求租订单', '租赁订单支付（订单#2）', '2026-03-14 22:31:31');
INSERT INTO `b_task_statistics` VALUES (35, 3, 'task', 2, 30000, 0, 0, 'rental_order', 3, 7, '求租订单', '租赁订单支付（订单#3）', '2026-03-14 22:33:28');

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
) ENGINE = InnoDB AUTO_INCREMENT = 76 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端发布任务表-商家派单' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of b_tasks
-- ----------------------------
INSERT INTO `b_tasks` VALUES (1, 2, NULL, 0, 1, NULL, 1, '5.89 复制打开抖音，看看【辉总不累的作品】  https://v.douyin.com/jmtVNF6KEQQ/ 04/19 d@N.Wm zGI:/', 1772189758, '[{\"at_user\": \"\", \"comment\": \"还好遇见梅姐，每天肚子都吃得饱饱的😋\", \"image_url\": \"http://54.179.253.64:28806/img/6c031bd126d19509ddceb060e2c1d77f.jpg\"}, {\"at_user\": \"\", \"comment\": \"还好遇见梅姐，每天肚子都吃得饱饱的😋\", \"image_url\": \"http://54.179.253.64:28806/img/5f66e00f02b672e9ecb1cf1140586079.jpg\"}]', 2, 0, 0, 0, 3.00, 6.00, 0, '2026-02-27 18:25:58', '2026-02-27 18:56:02', NULL);
INSERT INTO `b_tasks` VALUES (2, 2, NULL, 0, 1, NULL, 2, '9:/Y.. 07/31 o@Q.Kj 复制打开抖音，查看【辉总不累】发布作品的评论：死磕，做到极致。➝➝o7wgJAyHg49ŠŠ', 1772190077, '[{\"at_user\": \"\", \"comment\": \"有你真好，梅姐\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"123456789224\", \"image_url\": \"\"}]', 2, 0, 0, 0, 2.00, 4.00, 0, '2026-02-27 18:31:19', '2026-02-27 19:02:01', NULL);
INSERT INTO `b_tasks` VALUES (3, 2, NULL, 0, 1, NULL, 1, '5-- 02/02 i@p.QX 复制打开抖音，查看【让我再次去思念】发布作品的评论：又几有道理喔，怪唔知得啲:/ 师奶咁钟意用荷花做微信头像...^^5iKugrrLi49※※', 1772293474, '[{\"at_user\": \"\", \"comment\": \"那天人山人海，没好意思去拜就走了😅 但听说真的超准！\", \"image_url\": \"\"}]', 1, 0, 0, 0, 3.00, 3.00, 0, '2026-02-28 23:34:35', '2026-02-28 23:45:01', NULL);
INSERT INTO `b_tasks` VALUES (4, 1, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1773072000, '[{\"comment\": \"测试上评评论\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-01 00:34:05', '2026-03-04 17:33:01', '2026-03-04 17:33:01');
INSERT INTO `b_tasks` VALUES (5, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1774800000, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-03 11:02:13', '2026-03-11 15:50:01', '2026-03-11 15:50:01');
INSERT INTO `b_tasks` VALUES (6, 3, NULL, 0, 1, NULL, 2, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1774800000, '[{\"comment\": \"新测试，单任务，中评评论18，测试高级团长邀请。\", \"image_url\": \"\"}, {\"comment\": \"新测试，单任务，中评评论18，测试高级团长邀请。\", \"image_url\": \"\"}, {\"comment\": \"新测试，单任务，中评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 3, 2, 0, 0, 2.00, 6.00, 1, '2026-03-03 11:48:04', '2026-03-11 17:09:01', NULL);
INSERT INTO `b_tasks` VALUES (7, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1774800000, '[{\"comment\": \"新测试，单任务，中评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-03 12:03:50', '2026-03-11 12:51:01', '2026-03-11 12:51:01');
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
INSERT INTO `b_tasks` VALUES (47, 1, NULL, 0, 1, NULL, 1, '1111111测试', 1773201164, '[{\"at_user\": \"\", \"comment\": \"根着张总推荐走，准没错！💪🔥\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"张总，这波分享我学废了！🤣 学到了学到了，感谢分享！👍\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"亲测有效！张总亲测的方法，真的绝了！👍✨\", \"image_url\": \"\"}]', 3, 0, 0, 0, 3.00, 9.00, 0, '2026-03-11 11:42:44', '2026-03-11 11:53:01', NULL);
INSERT INTO `b_tasks` VALUES (48, 1, NULL, 0, 1, NULL, 1, '11111', 1773202034, '[{\"at_user\": \"\", \"comment\": \"小野的方法绝了！👍 根了根了，太实用了！💡\", \"image_url\": \"\"}]', 1, 0, 0, 0, 3.00, 3.00, 0, '2026-03-11 11:57:14', '2026-03-11 12:08:01', NULL);
INSERT INTO `b_tasks` VALUES (49, 1, NULL, 0, 1, NULL, 2, '111111', 1773202104, '[{\"at_user\": \"\", \"comment\": \"[[]]说的太准了！亲测有效，太…\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"…\", \"image_url\": \"\"}, {\"at_user\": \"小野\", \"comment\": \"@小野 姐妹，你这\", \"image_url\": \"\"}]', 3, 0, 0, 0, 2.00, 6.00, 0, '2026-03-11 11:58:24', '2026-03-11 12:09:01', NULL);
INSERT INTO `b_tasks` VALUES (50, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1773226800, '[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-11 15:51:37', '2026-03-11 16:05:02', '2026-03-11 16:05:02');
INSERT INTO `b_tasks` VALUES (51, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-12 10:27:10', '2026-03-12 10:49:48', '2026-03-12 10:49:48');
INSERT INTO `b_tasks` VALUES (52, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-12 10:31:44', '2026-03-12 10:58:39', '2026-03-12 10:58:39');
INSERT INTO `b_tasks` VALUES (53, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-12 10:31:46', '2026-03-12 11:07:31', '2026-03-12 11:07:31');
INSERT INTO `b_tasks` VALUES (54, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-12 10:31:49', '2026-03-12 11:10:03', '2026-03-12 11:10:03');
INSERT INTO `b_tasks` VALUES (55, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-12 10:31:52', '2026-03-12 11:19:54', '2026-03-12 11:19:54');
INSERT INTO `b_tasks` VALUES (56, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-12 10:32:10', '2026-03-12 11:26:32', '2026-03-12 11:26:32');
INSERT INTO `b_tasks` VALUES (57, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-12 11:28:02', '2026-03-12 11:30:13', '2026-03-12 11:30:13');
INSERT INTO `b_tasks` VALUES (58, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-12 11:28:03', '2026-03-12 11:32:04', '2026-03-12 11:32:04');
INSERT INTO `b_tasks` VALUES (59, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-12 11:28:05', '2026-03-12 11:37:36', '2026-03-12 11:37:36');
INSERT INTO `b_tasks` VALUES (60, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-12 14:31:30', '2026-03-12 14:42:45', '2026-03-12 14:42:45');
INSERT INTO `b_tasks` VALUES (61, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-12 14:48:57', '2026-03-12 14:51:39', '2026-03-12 14:51:39');
INSERT INTO `b_tasks` VALUES (62, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-12 14:48:59', '2026-03-12 14:53:44', '2026-03-12 14:53:44');
INSERT INTO `b_tasks` VALUES (63, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-12 14:49:00', '2026-03-12 14:55:49', '2026-03-12 14:55:49');
INSERT INTO `b_tasks` VALUES (64, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-12 14:49:01', '2026-03-12 14:59:04', '2026-03-12 14:59:04');
INSERT INTO `b_tasks` VALUES (65, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-12 14:49:02', '2026-03-13 11:17:15', '2026-03-13 11:17:15');
INSERT INTO `b_tasks` VALUES (66, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-13 11:14:06', '2026-03-14 21:07:06', '2026-03-14 21:07:06');
INSERT INTO `b_tasks` VALUES (67, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-13 11:24:10', '2026-03-14 21:09:08', '2026-03-14 21:09:08');
INSERT INTO `b_tasks` VALUES (68, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-14 20:21:11', '2026-03-14 21:09:08', '2026-03-14 21:09:08');
INSERT INTO `b_tasks` VALUES (69, 3, NULL, 0, 1, NULL, 2, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金1\", \"image_url\": \"\"}, {\"comment\": \"测试大团团长的任务奖励和佣金2\", \"image_url\": \"\"}, {\"comment\": \"测试大团团长的任务奖励和佣金3\", \"image_url\": \"\"}]', 3, 1, 0, 0, 2.00, 6.00, 1, '2026-03-14 20:22:05', '2026-03-14 21:09:08', NULL);
INSERT INTO `b_tasks` VALUES (70, 3, 'COMBO_1773490975_3', 1, 2, NULL, 4, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"阶段1上评评论\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-14 20:22:55', '2026-03-14 21:09:08', '2026-03-14 21:09:08');
INSERT INTO `b_tasks` VALUES (71, 3, 'COMBO_1773490975_3', 2, 1, 70, 4, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"阶段2中评回复1\", \"image_url\": \"\"}, {\"comment\": \"阶段2中评回复2\", \"image_url\": \"\"}, {\"comment\": \"阶段2中评回复3\", \"image_url\": \"\"}]', 3, 0, 0, 0, 2.00, 6.00, 1, '2026-03-14 20:22:55', '2026-03-14 21:09:08', NULL);
INSERT INTO `b_tasks` VALUES (72, 3, 'COMBO_1773490988_3', 1, 2, NULL, 5, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"阶段1上评评论\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-14 20:23:08', '2026-03-14 21:09:08', '2026-03-14 21:09:08');
INSERT INTO `b_tasks` VALUES (73, 3, 'COMBO_1773490988_3', 2, 1, 72, 5, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"阶段2中评回复1\", \"image_url\": \"\"}]', 1, 0, 0, 0, 3.00, 3.00, 1, '2026-03-14 20:23:08', '2026-03-14 21:09:08', NULL);
INSERT INTO `b_tasks` VALUES (74, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金1\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-14 21:19:09', '2026-03-14 21:21:07', '2026-03-14 21:21:07');
INSERT INTO `b_tasks` VALUES (75, 3, NULL, 0, 2, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金1\", \"image_url\": \"\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-03-14 21:21:45', '2026-03-14 21:24:48', '2026-03-14 21:24:48');

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
  `device_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前登录设备ID',
  `device_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前登录设备名称',
  `max_devices` int NOT NULL DEFAULT 1 COMMENT '最大允许登录设备数，0表示无限制',
  `last_login_device` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '最后登录设备信息（JSON格式）',
  `device_list` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '已登录设备列表（JSON格式）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_email`(`email` ASC) USING BTREE,
  UNIQUE INDEX `uk_phone`(`phone` ASC) USING BTREE,
  INDEX `idx_token`(`token`(255) ASC) USING BTREE,
  INDEX `idx_wallet_id`(`wallet_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_device_id`(`device_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端用户表-商家端' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of b_users
-- ----------------------------
INSERT INTO `b_users` VALUES (1, 'Ceshi', '271010169@qq.com', NULL, '$2y$10$SV7dHV/yam2IcgV5SmbbKur8TrpohySzBEQ032nQouiOnaBgmTWp6', 'Meili', 'Meili', 'eyJ1c2VyX2lkIjoxLCJ0eXBlIjoyLCJleHAiOjE3NzM4MDQ4NjF9', '2026-03-18 11:34:21', 1, 1, NULL, '34.143.229.197', '2026-02-27 11:49:20', '2026-03-11 11:34:21', 'ad69cb319a720ccec6096ab21bfe577a', 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1', 1, '{\"device_id\":\"ad69cb319a720ccec6096ab21bfe577a\",\"device_name\":\"Mozilla\\/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit\\/605.1.15 (KHTML, like Gecko) Version\\/16.6 Mobile\\/15E148 Safari\\/604.1\",\"login_time\":\"2026-03-11 11:34:21\",\"last_activity\":\"2026-03-11 11:34:21\"}', '[{\"device_id\":\"ad69cb319a720ccec6096ab21bfe577a\",\"device_name\":\"Mozilla\\/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit\\/605.1.15 (KHTML, like Gecko) Version\\/16.6 Mobile\\/15E148 Safari\\/604.1\",\"login_time\":\"2026-03-11 11:34:21\",\"last_activity\":\"2026-03-11 11:34:21\"}]');
INSERT INTO `b_users` VALUES (2, 'Ceshi1', '459312160@qq.com', NULL, '$2y$10$F0HHwcgbu5Qh.xkir2UCcul4OHQPBYXwr970M4kIFVmdeZaDeh6ca', 'Meili', 'Meili', 'eyJ1c2VyX2lkIjoyLCJ0eXBlIjoyLCJleHAiOjE3NzM1NTIwNjV9', '2026-03-15 13:21:05', 2, 1, NULL, '34.143.229.197', '2026-02-27 12:02:50', '2026-03-08 13:21:05', NULL, NULL, 1, NULL, NULL);
INSERT INTO `b_users` VALUES (3, 'task', 'task@qq.com', NULL, '$2y$10$hkD.XBnEsk7iKbrYdpuxyOmrn.vME26Z1gzkXkBEXaUQMey5b3MAm', 'task', 'task', 'eyJ1c2VyX2lkIjozLCJ0eXBlIjoyLCJleHAiOjE3NzQxMDI4MTN9', '2026-03-21 22:20:13', 7, 1, NULL, '223.74.60.135', '2026-03-01 00:48:16', '2026-03-14 22:20:13', '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-14 22:20:13\",\"last_activity\":\"2026-03-14 22:20:13\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-14 22:20:13\",\"last_activity\":\"2026-03-14 22:20:13\"}]');
INSERT INTO `b_users` VALUES (4, '6666', '2625228169@qq.com', NULL, '$2y$10$cvmarlmOyyh0pZmNpZn2LeAEVveublaPt2QfK22mBGf/oH2789LyG', '11', 'QWE', 'eyJ1c2VyX2lkIjo0LCJ0eXBlIjoyLCJleHAiOjE3NzM4MzM3MjZ9', '2026-03-18 19:35:26', 10, 1, NULL, '34.143.229.197', '2026-03-06 14:46:54', '2026-03-11 19:35:26', 'd4bdb37a26509bbc496ede416e5756cc', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.0.8257.400', 1, '{\"device_id\":\"d4bdb37a26509bbc496ede416e5756cc\",\"device_name\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/123.0.0.0 Safari\\/537.36 QQBrowser\\/21.0.8257.400\",\"login_time\":\"2026-03-11 19:35:26\",\"last_activity\":\"2026-03-11 19:35:26\"}', '[{\"device_id\":\"d4bdb37a26509bbc496ede416e5756cc\",\"device_name\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/123.0.0.0 Safari\\/537.36 QQBrowser\\/21.0.8257.400\",\"login_time\":\"2026-03-11 19:35:26\",\"last_activity\":\"2026-03-11 19:35:26\"}]');
INSERT INTO `b_users` VALUES (5, 'Ceshi3', '123456@gmail.com', '13145678910', '$2y$10$YIm6OTfuUhj5VxYfVWoSu.ONne..7NVIKVMYCx0zajHhzHeZqeQNG', '勇敢', '果断', 'eyJ1c2VyX2lkIjo1LCJ0eXBlIjoyLCJleHAiOjE3NzM1NDc2MTB9', '2026-03-15 12:06:50', 11, 1, NULL, '34.143.229.197', '2026-03-08 12:06:11', '2026-03-08 12:06:50', NULL, NULL, 1, NULL, NULL);

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
) ENGINE = InnoDB AUTO_INCREMENT = 58 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端任务记录表-接单执行审核全流程' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `c_task_records` VALUES (30, 18, 7, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，中评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7615062955545169202', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/98033c0934fcc4c81b672ee081b08a74.webp\"]', 3, NULL, 100, '2026-03-11 12:40:00', '2026-03-11 12:40:38', '2026-03-11 12:51:01');
INSERT INTO `c_task_records` VALUES (31, 2, 5, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.bilibili.com/video/BV1ZDPmztE5q/?spm_id_from=333.1007.tianma.1-2-2.click', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/274c37d8add4a0aec3c10f82cdfe845a.webp\"]', 3, NULL, 100, '2026-03-11 15:39:15', '2026-03-11 15:39:37', '2026-03-11 15:50:01');
INSERT INTO `c_task_records` VALUES (32, 2, 6, 3, 2, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，中评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.bilibili.com/video/BV1ZDPmztE5q/?spm_id_from=333.1007.tianma.1-2-2.click', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/91d5fa557e80f20e4ecf2eacf7bd82c8.webp\"]', 3, NULL, 80, '2026-03-11 15:47:54', '2026-03-11 15:48:19', '2026-03-11 15:59:02');
INSERT INTO `c_task_records` VALUES (33, 2, 50, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', 'https://www.bilibili.com/video/BV1ZDPmztE5q/?spm_id_from=333.1007.tianma.1-2-2.click', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/1179eaa301990019066fc8156b8f8868.webp\"]', 3, NULL, 100, '2026-03-11 15:54:12', '2026-03-11 15:54:39', '2026-03-11 16:05:02');
INSERT INTO `c_task_records` VALUES (34, 18, 6, 3, 2, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"新测试，单任务，中评评论18，测试高级团长邀请。\", \"image_url\": \"\"}', '111', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/cf50a34dc36cdbd8fca421608db07ebc.webp\"]', 3, NULL, 80, '2026-03-11 16:57:55', '2026-03-11 16:58:35', '2026-03-11 17:09:01');
INSERT INTO `c_task_records` VALUES (35, 5, 51, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"http:\\/\\/134.122.136.221:4667\\/img\\/a9b76843e779d5727ecf6b4269287206.jpg\"]', 3, NULL, 100, '2026-03-12 10:34:50', '2026-03-12 10:39:13', '2026-03-12 10:49:48');
INSERT INTO `c_task_records` VALUES (36, 5, 52, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"http:\\/\\/134.122.136.221:4667\\/img\\/a9b76843e779d5727ecf6b4269287206.jpg\"]', 3, NULL, 100, '2026-03-12 10:51:29', '2026-03-12 10:51:33', '2026-03-12 10:58:39');
INSERT INTO `c_task_records` VALUES (37, 5, 53, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"http:\\/\\/134.122.136.221:4667\\/img\\/a9b76843e779d5727ecf6b4269287206.jpg\"]', 3, NULL, 100, '2026-03-12 11:03:33', '2026-03-12 11:03:40', '2026-03-12 11:07:31');
INSERT INTO `c_task_records` VALUES (38, 5, 54, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"http:\\/\\/134.122.136.221:4667\\/img\\/a9b76843e779d5727ecf6b4269287206.jpg\"]', 3, NULL, 100, '2026-03-12 11:08:52', '2026-03-12 11:08:59', '2026-03-12 11:10:03');
INSERT INTO `c_task_records` VALUES (39, 19, 55, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"http:\\/\\/134.122.136.221:4667\\/img\\/a9b76843e779d5727ecf6b4269287206.jpg\"]', 3, NULL, 100, '2026-03-12 11:17:15', '2026-03-12 11:17:25', '2026-03-12 11:19:54');
INSERT INTO `c_task_records` VALUES (40, 19, 56, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"http:\\/\\/134.122.136.221:4667\\/img\\/a9b76843e779d5727ecf6b4269287206.jpg\"]', 3, NULL, 100, '2026-03-12 11:25:11', '2026-03-12 11:25:18', '2026-03-12 11:26:32');
INSERT INTO `c_task_records` VALUES (41, 19, 57, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"http:\\/\\/134.122.136.221:4667\\/img\\/a9b76843e779d5727ecf6b4269287206.jpg\"]', 3, NULL, 100, '2026-03-12 11:28:54', '2026-03-12 11:29:01', '2026-03-12 11:30:13');
INSERT INTO `c_task_records` VALUES (42, 25, 58, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"http:\\/\\/134.122.136.221:4667\\/img\\/a9b76843e779d5727ecf6b4269287206.jpg\"]', 3, NULL, 100, '2026-03-12 11:30:51', '2026-03-12 11:31:03', '2026-03-12 11:32:04');
INSERT INTO `c_task_records` VALUES (43, 26, 59, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"http:\\/\\/134.122.136.221:4667\\/img\\/a9b76843e779d5727ecf6b4269287206.jpg\"]', 3, NULL, 100, '2026-03-12 11:35:59', '2026-03-12 11:36:15', '2026-03-12 11:37:36');
INSERT INTO `c_task_records` VALUES (44, 27, 60, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"http:\\/\\/134.122.136.221:4667\\/img\\/a9b76843e779d5727ecf6b4269287206.jpg\"]', 3, NULL, 100, '2026-03-12 14:31:54', '2026-03-12 14:32:24', '2026-03-12 14:42:45');
INSERT INTO `c_task_records` VALUES (45, 27, 61, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"http:\\/\\/134.122.136.221:4667\\/img\\/a9b76843e779d5727ecf6b4269287206.jpg\"]', 3, NULL, 100, '2026-03-12 14:50:45', '2026-03-12 14:50:56', '2026-03-12 14:51:39');
INSERT INTO `c_task_records` VALUES (46, 26, 62, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"http:\\/\\/134.122.136.221:4667\\/img\\/a9b76843e779d5727ecf6b4269287206.jpg\"]', 3, NULL, 100, '2026-03-12 14:53:06', '2026-03-12 14:53:23', '2026-03-12 14:53:44');
INSERT INTO `c_task_records` VALUES (47, 20, 63, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"http:\\/\\/134.122.136.221:4667\\/img\\/a9b76843e779d5727ecf6b4269287206.jpg\"]', 3, NULL, 100, '2026-03-12 14:55:18', '2026-03-12 14:55:30', '2026-03-12 14:55:49');
INSERT INTO `c_task_records` VALUES (48, 5, 64, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"http:\\/\\/134.122.136.221:4667\\/img\\/a9b76843e779d5727ecf6b4269287206.jpg\"]', 3, NULL, 100, '2026-03-12 14:57:27', '2026-03-12 14:58:48', '2026-03-12 14:59:04');
INSERT INTO `c_task_records` VALUES (49, 26, 65, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"http:\\/\\/54.179.253.64:28806\\/img\\/344ccc2b0873c9f91547ebce99c6434a.jpg\"]', 3, NULL, 100, '2026-03-13 11:15:29', '2026-03-13 11:16:00', '2026-03-13 11:17:15');
INSERT INTO `c_task_records` VALUES (50, 5, 66, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/edaceeb86d3e9cac2c50c5a32088bcf5.jpg\"]', 3, NULL, 100, '2026-03-14 20:59:29', '2026-03-14 20:59:41', '2026-03-14 21:07:06');
INSERT INTO `c_task_records` VALUES (51, 5, 67, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/edaceeb86d3e9cac2c50c5a32088bcf5.jpg\"]', 3, NULL, 100, '2026-03-14 20:59:47', '2026-03-14 20:59:55', '2026-03-14 21:09:08');
INSERT INTO `c_task_records` VALUES (52, 5, 68, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/edaceeb86d3e9cac2c50c5a32088bcf5.jpg\"]', 3, NULL, 100, '2026-03-14 21:00:19', '2026-03-14 21:00:25', '2026-03-14 21:09:08');
INSERT INTO `c_task_records` VALUES (53, 5, 69, 3, 2, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金1\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/edaceeb86d3e9cac2c50c5a32088bcf5.jpg\"]', 3, NULL, 80, '2026-03-14 21:00:41', '2026-03-14 21:00:46', '2026-03-14 21:09:08');
INSERT INTO `c_task_records` VALUES (54, 5, 70, 3, 4, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"阶段1上评评论\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/edaceeb86d3e9cac2c50c5a32088bcf5.jpg\"]', 3, NULL, 100, '2026-03-14 21:00:51', '2026-03-14 21:00:57', '2026-03-14 21:09:08');
INSERT INTO `c_task_records` VALUES (55, 5, 72, 3, 5, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"阶段1上评评论\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/edaceeb86d3e9cac2c50c5a32088bcf5.jpg\"]', 3, NULL, 130, '2026-03-14 21:01:21', '2026-03-14 21:01:27', '2026-03-14 21:09:08');
INSERT INTO `c_task_records` VALUES (56, 5, 74, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金1\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/edaceeb86d3e9cac2c50c5a32088bcf5.jpg\"]', 3, NULL, 100, '2026-03-14 21:19:17', '2026-03-14 21:19:23', '2026-03-14 21:21:07');
INSERT INTO `c_task_records` VALUES (57, 26, 75, 3, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金1\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/edaceeb86d3e9cac2c50c5a32088bcf5.jpg\"]', 3, NULL, 100, '2026-03-14 21:22:03', '2026-03-14 21:22:19', '2026-03-14 21:24:48');

-- ----------------------------
-- Table structure for c_task_statistics
-- ----------------------------
DROP TABLE IF EXISTS `c_task_statistics`;
CREATE TABLE `c_task_statistics`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '统计ID',
  `c_user_id` bigint UNSIGNED NOT NULL COMMENT 'C端用户ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（冗余字段）',
  `flow_type` tinyint NOT NULL COMMENT '流水类型：1=收入，2=支出',
  `amount` bigint NOT NULL DEFAULT 0 COMMENT '变动金额（单位：分，正数）',
  `before_balance` bigint NOT NULL DEFAULT 0 COMMENT '变动前余额（单位：分）',
  `after_balance` bigint NOT NULL DEFAULT 0 COMMENT '变动后余额（单位：分）',
  `related_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关联类型：task_publish=任务发布，recharge=充值，account_rental=账号租赁，refund=退款',
  `related_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '关联ID（任务ID、订单ID等）',
  `task_types` tinyint UNSIGNED NULL DEFAULT NULL COMMENT '任务类型：1=上评评论，2=中评评论，3=放大镜搜索词，4=上中评评论，5=中下评评论，6=出租订单，7=求租订单',
  `task_types_text` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务类型文本描述',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '流水的详细说明记录',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_c_user_id`(`c_user_id` ASC) USING BTREE,
  INDEX `idx_flow_type`(`flow_type` ASC) USING BTREE,
  INDEX `idx_related`(`related_type` ASC, `related_id` ASC) USING BTREE,
  INDEX `idx_task_types`(`task_types` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 41 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端任务统计表-记录C端用户所有金额变动' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of c_task_statistics
-- ----------------------------
INSERT INTO `c_task_statistics` VALUES (21, 5, 'test', 1, 240, 4080, 4320, 'commission', 66, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：66', '2026-03-14 21:07:06');
INSERT INTO `c_task_statistics` VALUES (22, 5, 'test', 1, 240, 4320, 4560, 'commission', 67, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：67', '2026-03-14 21:09:08');
INSERT INTO `c_task_statistics` VALUES (23, 5, 'test', 1, 240, 4560, 4800, 'commission', 68, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：68', '2026-03-14 21:09:08');
INSERT INTO `c_task_statistics` VALUES (24, 5, 'test', 1, 160, 4800, 4960, 'commission', 69, 2, '中评评论', '自动审核通过任务获得佣金，任务ID：69', '2026-03-14 21:09:08');
INSERT INTO `c_task_statistics` VALUES (25, 5, 'test', 1, 240, 4960, 5200, 'commission', 70, 4, '上中评评论', '自动审核通过任务获得佣金，任务ID：70', '2026-03-14 21:09:08');
INSERT INTO `c_task_statistics` VALUES (26, 5, 'test', 1, 240, 5200, 5440, 'commission', 72, 5, '中下评评论', '自动审核通过任务获得佣金，任务ID：72', '2026-03-14 21:09:08');
INSERT INTO `c_task_statistics` VALUES (27, 5, 'test', 2, 1000, 5440, 4440, 'withdraw', 0, NULL, NULL, '提现申请 ¥10.00，手续费 ¥0.30，实到 ¥9.70，收款方式：alipay，审核中', '2026-03-14 21:12:40');
INSERT INTO `c_task_statistics` VALUES (28, 5, 'test', 1, 240, 4440, 4680, 'commission', 74, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：74', '2026-03-14 21:21:07');
INSERT INTO `c_task_statistics` VALUES (29, 26, 'test8', 1, 100, 300, 400, 'commission', 75, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：75', '2026-03-14 21:24:48');
INSERT INTO `c_task_statistics` VALUES (30, 20, 'test2', 1, 50, 250, 300, 'agent_commission', 75, 1, '上评评论', '下级用户 test8是高级团长 完成任务，获得高级团长佣金，任务ID：75', '2026-03-14 21:24:48');
INSERT INTO `c_task_statistics` VALUES (31, 5, 'test', 1, 240, 4680, 4920, 'second_agent_commission', 75, 1, '上评评论', '下级用户 test2 的团队成员完成任务，获得二级团长佣金，任务ID：75', '2026-03-14 21:24:48');
INSERT INTO `c_task_statistics` VALUES (32, 5, 'test', 2, 0, 4920, 4920, 'withdraw', 8, NULL, NULL, '提现审核通过：¥10.00', '2026-03-14 21:30:25');
INSERT INTO `c_task_statistics` VALUES (33, 5, 'test', 2, 300, 4920, 4620, 'withdraw', 0, NULL, NULL, '提现申请 ¥3.00，手续费 ¥0.09，实到 ¥2.91，收款方式：alipay，审核中', '2026-03-14 21:35:04');
INSERT INTO `c_task_statistics` VALUES (34, 5, 'test', 2, 0, 29120, 29120, 'withdraw', 9, NULL, NULL, '提现审核通过：¥3.00', '2026-03-14 22:18:13');
INSERT INTO `c_task_statistics` VALUES (35, 26, 'test8', 1, 17500, 400, 17900, 'rental_order_settlement', 2, 6, '出租订单', '租赁订单结算收益（订单#2）', '2026-03-14 22:31:31');
INSERT INTO `c_task_statistics` VALUES (36, 20, 'test2', 1, 0, 1550, 1550, 'agent_commission', 2, 6, '出租订单', '租赁订单团长佣金（订单#2）', '2026-03-14 22:31:31');
INSERT INTO `c_task_statistics` VALUES (37, 5, 'test', 1, 0, 29120, 29120, 'second_agent_commission', 2, 6, '出租订单', '租赁订单二级代理佣金（订单#2）', '2026-03-14 22:31:31');
INSERT INTO `c_task_statistics` VALUES (38, 26, 'test8', 1, 1400, 17900, 19300, 'rental_order_settlement', 3, 6, '出租订单', '租赁订单结算收益（订单#3）', '2026-03-14 22:33:28');
INSERT INTO `c_task_statistics` VALUES (39, 20, 'test2', 1, 0, 1650, 1650, 'agent_commission', 3, 6, '出租订单', '租赁订单团长佣金（订单#3）', '2026-03-14 22:33:28');
INSERT INTO `c_task_statistics` VALUES (40, 5, 'test', 1, 0, 29120, 29120, 'second_agent_commission', 3, 6, '出租订单', '租赁订单二级代理佣金（订单#3）', '2026-03-14 22:33:28');

-- ----------------------------
-- Table structure for c_user_agent_upgrade_history
-- ----------------------------
DROP TABLE IF EXISTS `c_user_agent_upgrade_history`;
CREATE TABLE `c_user_agent_upgrade_history`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `c_user_id` int UNSIGNED NOT NULL COMMENT 'C端用户ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `from_level` tinyint UNSIGNED NOT NULL COMMENT '从哪个等级',
  `to_level` tinyint UNSIGNED NOT NULL COMMENT '到哪个等级',
  `admin_id` int UNSIGNED NOT NULL COMMENT '操作管理员ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_c_user_id`(`c_user_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'C端用户代理等级跃迁历史表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of c_user_agent_upgrade_history
-- ----------------------------
INSERT INTO `c_user_agent_upgrade_history` VALUES (5, 5, 'test', 0, 1, 1, '2026-03-09 21:24:51');
INSERT INTO `c_user_agent_upgrade_history` VALUES (6, 5, 'test', 1, 2, 1, '2026-03-09 21:24:53');
INSERT INTO `c_user_agent_upgrade_history` VALUES (7, 1, 'taskadmin', 0, 1, 1, '2026-03-12 10:14:05');
INSERT INTO `c_user_agent_upgrade_history` VALUES (8, 1, 'taskadmin', 1, 3, 1, '2026-03-12 10:14:13');
INSERT INTO `c_user_agent_upgrade_history` VALUES (9, 6, 'tasktest', 2, 3, 1, '2026-03-12 10:14:39');
INSERT INTO `c_user_agent_upgrade_history` VALUES (10, 2, 'Ceshi', 0, 3, 1, '2026-03-12 10:14:47');
INSERT INTO `c_user_agent_upgrade_history` VALUES (11, 5, 'test', 2, 3, 1, '2026-03-12 10:21:56');
INSERT INTO `c_user_agent_upgrade_history` VALUES (12, 19, 'test1', 0, 1, 1, '2026-03-12 11:15:15');
INSERT INTO `c_user_agent_upgrade_history` VALUES (13, 20, 'test2', 0, 2, 1, '2026-03-12 11:15:20');
INSERT INTO `c_user_agent_upgrade_history` VALUES (14, 26, 'test8', 0, 1, 1, '2026-03-12 14:30:44');

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
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端用户每日统计表-限制驳回次数' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `c_user_daily_stats` VALUES (11, 18, '2026-03-11', 2, 2, 2, 0, '2026-03-11 12:40:00', '2026-03-11 17:09:01');
INSERT INTO `c_user_daily_stats` VALUES (12, 2, '2026-03-11', 3, 3, 3, 0, '2026-03-11 15:39:15', '2026-03-11 16:05:02');
INSERT INTO `c_user_daily_stats` VALUES (13, 5, '2026-03-12', 5, 5, 5, 0, '2026-03-12 10:34:50', '2026-03-12 14:59:04');
INSERT INTO `c_user_daily_stats` VALUES (14, 19, '2026-03-12', 3, 3, 3, 0, '2026-03-12 11:17:15', '2026-03-12 11:30:13');
INSERT INTO `c_user_daily_stats` VALUES (15, 25, '2026-03-12', 1, 1, 1, 0, '2026-03-12 11:30:51', '2026-03-12 11:32:04');
INSERT INTO `c_user_daily_stats` VALUES (16, 26, '2026-03-12', 2, 2, 2, 0, '2026-03-12 11:35:58', '2026-03-12 14:53:44');
INSERT INTO `c_user_daily_stats` VALUES (17, 27, '2026-03-12', 2, 2, 2, 0, '2026-03-12 14:31:54', '2026-03-12 14:51:39');
INSERT INTO `c_user_daily_stats` VALUES (18, 20, '2026-03-12', 1, 1, 1, 0, '2026-03-12 14:55:18', '2026-03-12 14:55:49');
INSERT INTO `c_user_daily_stats` VALUES (19, 26, '2026-03-13', 1, 1, 1, 0, '2026-03-13 11:15:29', '2026-03-13 11:17:15');
INSERT INTO `c_user_daily_stats` VALUES (20, 5, '2026-03-14', 7, 7, 7, 0, '2026-03-14 20:59:29', '2026-03-14 21:21:07');
INSERT INTO `c_user_daily_stats` VALUES (21, 26, '2026-03-14', 1, 1, 1, 0, '2026-03-14 21:22:03', '2026-03-14 21:24:48');

-- ----------------------------
-- Table structure for c_users
-- ----------------------------
DROP TABLE IF EXISTS `c_users`;
CREATE TABLE `c_users`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'C端用户ID',
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（必填，登录账号）',
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮箱（选填）',
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
  `blocked_status` tinyint NOT NULL DEFAULT 0 COMMENT '封禁状态：0=不禁止，1=禁止接单，2=禁止登陆',
  `blocked_start_time` datetime NULL DEFAULT NULL COMMENT '封禁开始时间',
  `blocked_duration` int NULL DEFAULT NULL COMMENT '封禁时长（单位：小时）',
  `blocked_end_time` datetime NULL DEFAULT NULL COMMENT '自动解禁时间',
  `device_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前登录设备ID',
  `device_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前登录设备名称',
  `max_devices` int NOT NULL DEFAULT 1 COMMENT '最大允许登录设备数，0表示无限制',
  `last_login_device` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '最后登录设备信息（JSON格式）',
  `device_list` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '已登录设备列表（JSON格式）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_invite_code`(`invite_code` ASC) USING BTREE,
  UNIQUE INDEX `uk_phone`(`phone` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  INDEX `idx_is_agent`(`is_agent` ASC) USING BTREE,
  INDEX `idx_token`(`token`(255) ASC) USING BTREE,
  INDEX `idx_wallet_id`(`wallet_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_blocked_status`(`blocked_status` ASC) USING BTREE,
  INDEX `idx_blocked_end_time`(`blocked_end_time` ASC) USING BTREE,
  INDEX `idx_device_id`(`device_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端用户表-消费者端' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of c_users
-- ----------------------------
INSERT INTO `c_users` VALUES (1, 'taskadmin', 'taskadmin@qq.com', NULL, '$2y$10$9gww7TqOTzSA9SqchkFEgeYftRKlJ4ciYWL6IiD8DPUbQv8/PnCGe', 'W6XMFJ', NULL, 3, 'eyJ1c2VyX2lkIjoxLCJ0eXBlIjoxLCJleHAiOjE3NzI3NzM1OTN9', '2026-03-06 13:06:33', 3, 1, NULL, '120.237.23.202', '2026-02-27 13:06:22', '2026-03-14 01:09:33', 1, '2026-03-14 01:09:33', 1, '2026-03-14 02:09:33', NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (2, 'Ceshi', '12345678@qq.com', '13112345678', '$2y$10$hkD.XBnEsk7iKbrYdpuxyOmrn.vME26Z1gzkXkBEXaUQMey5b3MAm', '6YHUBA', NULL, 3, 'eyJ1c2VyX2lkIjoyLCJ0eXBlIjoxLCJleHAiOjE3NzM5MDY1NjV9', '2026-03-19 15:49:25', 4, 1, NULL, '34.143.229.197', '2026-02-27 17:24:33', '2026-03-12 15:49:25', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:49:25\",\"last_activity\":\"2026-03-12 15:49:25\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:49:25\",\"last_activity\":\"2026-03-12 15:49:25\"}]');
INSERT INTO `c_users` VALUES (3, 'Ceshi2', '123456789@qq.com', '13212345678', '$2y$10$Cvl7CIY5Oj2gPcKSvNE2mONLRs14Rr1ndstVn2FHJlco8GmXxS586', 'MCVFM9', NULL, 0, 'eyJ1c2VyX2lkIjozLCJ0eXBlIjoxLCJleHAiOjE3NzI3OTMxODh9', '2026-03-06 18:33:08', 5, 1, NULL, '34.143.229.197', '2026-02-27 17:26:28', '2026-02-27 18:33:08', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (4, 'Ceshi3', '123455677@qq.com', '13312345678', '$2y$10$qydW3B1EXlxJou5CUfPMaOvssOD/K8GugvQh.BeeX/KGBpPGC3awq', 'CZBBF5', NULL, 0, 'eyJ1c2VyX2lkIjo0LCJ0eXBlIjoxLCJleHAiOjE3NzI3ODk0Njh9', '2026-03-06 17:31:08', 6, 1, NULL, '34.143.229.197', '2026-02-27 17:31:08', '2026-02-27 17:31:08', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (5, 'test', 'test@qq.com', '15900000011', '$2y$10$hkD.XBnEsk7iKbrYdpuxyOmrn.vME26Z1gzkXkBEXaUQMey5b3MAm', 'TX5ECJ', NULL, 3, 'eyJ1c2VyX2lkIjo1LCJ0eXBlIjoxLCJleHAiOjE3NzQxMDAwOTJ9', '2026-03-21 21:34:52', 8, 1, NULL, '223.74.60.135', '2026-03-01 00:53:23', '2026-03-14 21:34:52', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-14 21:34:52\",\"last_activity\":\"2026-03-14 21:34:52\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-14 21:34:52\",\"last_activity\":\"2026-03-14 21:34:52\"}]');
INSERT INTO `c_users` VALUES (6, 'tasktest', '', '13794719208', '$2y$10$B7twShdr0plATEq85mgnn.5qiIX7mxnWcMP4OX02L9La01U3PoUCi', 'Z2AYEM', 1, 3, 'eyJ1c2VyX2lkIjo2LCJ0eXBlIjoxLCJleHAiOjE3NzI5ODY0OTh9', '2026-03-09 00:14:58', 9, 1, NULL, '223.74.60.135', '2026-03-02 00:12:06', '2026-03-12 10:14:39', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (18, 'xiaoya', NULL, '13049610316', '$2y$10$s1KchbOeEqAqEGP1DjV15O4ZLf5yOKvNAE0.yphtXxvtwNo0Z6upG', 'KZPAUU', 5, 0, 'eyJ1c2VyX2lkIjoxOCwidHlwZSI6MSwiZXhwIjoxNzczODI5NjA0fQ==', '2026-03-18 18:26:44', 23, 1, NULL, '223.74.60.185', '2026-03-11 12:23:27', '2026-03-11 18:26:44', 0, NULL, NULL, NULL, 'e35dcb4f242a10445c9e5218ab3e8956', 'iPhone', 1, '{\"device_id\":\"e35dcb4f242a10445c9e5218ab3e8956\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-11 18:26:44\",\"last_activity\":\"2026-03-11 18:26:44\"}', '[{\"device_id\":\"e35dcb4f242a10445c9e5218ab3e8956\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-11 18:26:44\",\"last_activity\":\"2026-03-11 18:26:44\"}]');
INSERT INTO `c_users` VALUES (19, 'test1', 'test1@example.com', '13800138001', '$2y$12$BcNzzO08Ioin60d4mXd4UeY7V8bahMDqUYhkHuFHCR3vh690fXKhu', 'Z2GJ43', 5, 1, 'eyJ1c2VyX2lkIjoxOSwidHlwZSI6MSwiZXhwIjoxNzczOTA2MjkyfQ==', '2026-03-19 15:44:52', 24, 1, NULL, '::1', '2026-03-12 10:23:37', '2026-03-12 15:44:52', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:44:52\",\"last_activity\":\"2026-03-12 15:44:52\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:44:52\",\"last_activity\":\"2026-03-12 15:44:52\"}]');
INSERT INTO `c_users` VALUES (20, 'test2', 'test2@example.com', '13800138002', '$2y$12$zgG9QJ4V5vLg9NJ0n8Wc2uj7Uoo1dh3q33mBwRf/xm.q0ovFfrPcu', '4Q5A5X', 5, 2, 'eyJ1c2VyX2lkIjoyMCwidHlwZSI6MSwiZXhwIjoxNzczOTEwNzc4fQ==', '2026-03-19 16:59:38', 25, 1, NULL, '::1', '2026-03-12 10:23:57', '2026-03-12 16:59:38', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 16:59:38\",\"last_activity\":\"2026-03-12 16:59:38\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 16:59:38\",\"last_activity\":\"2026-03-12 16:59:38\"}]');
INSERT INTO `c_users` VALUES (21, 'test3', 'test3@example.com', '13800138003', '$2y$12$8z7vXjSjouSHHcO33xpoX..Px3DQVrcNAixczIfbfXhy.1mo0r5yW', 'RHA6SE', 5, 0, 'eyJ1c2VyX2lkIjoyMSwidHlwZSI6MSwiZXhwIjoxNzczOTA2MzM5fQ==', '2026-03-19 15:45:39', 26, 1, NULL, '::1', '2026-03-12 10:24:12', '2026-03-12 15:45:39', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:45:39\",\"last_activity\":\"2026-03-12 15:45:39\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:45:39\",\"last_activity\":\"2026-03-12 15:45:39\"}]');
INSERT INTO `c_users` VALUES (22, 'test4', 'test4@example.com', '13800138004', '$2y$12$nyojdrP1YvXOE7Zkrva3.Os8fn0goB671mqPJmODF8piW8aRqGinm', '2A5VU3', 5, 0, 'eyJ1c2VyX2lkIjoyMiwidHlwZSI6MSwiZXhwIjoxNzczOTA2MzUzfQ==', '2026-03-19 15:45:53', 27, 1, NULL, '::1', '2026-03-12 10:24:22', '2026-03-12 15:45:53', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:45:53\",\"last_activity\":\"2026-03-12 15:45:53\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:45:53\",\"last_activity\":\"2026-03-12 15:45:53\"}]');
INSERT INTO `c_users` VALUES (23, 'test5', 'test5@example.com', '13800138005', '$2y$12$n.eutQbVaWv91iQeFltN2ueUb9Ff.Fzw1dwk/h2pyKfbgh/itcHcO', 'F4NGGC', 18, 0, 'eyJ1c2VyX2lkIjoyMywidHlwZSI6MSwiZXhwIjoxNzczOTA2MzgxfQ==', '2026-03-19 15:46:21', 28, 1, NULL, '::1', '2026-03-12 10:24:47', '2026-03-12 15:46:21', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:46:21\",\"last_activity\":\"2026-03-12 15:46:21\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:46:21\",\"last_activity\":\"2026-03-12 15:46:21\"}]');
INSERT INTO `c_users` VALUES (24, 'test6', 'test6@example.com', '13800138006', '$2y$12$huLJYXF6k4LW9fCO0FC2meaOkLsNE24UJDSclYEv/Y8d9RiUWYuW.', 'N369ZM', 18, 0, 'eyJ1c2VyX2lkIjoyNCwidHlwZSI6MSwiZXhwIjoxNzczOTA2NDQ0fQ==', '2026-03-19 15:47:24', 29, 1, NULL, '::1', '2026-03-12 10:24:57', '2026-03-12 15:47:24', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:47:24\",\"last_activity\":\"2026-03-12 15:47:24\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:47:24\",\"last_activity\":\"2026-03-12 15:47:24\"}]');
INSERT INTO `c_users` VALUES (25, 'test7', 'test7@example.com', '13800138007', '$2y$12$/7d7wzdvWDXCDp1jEdYA7e5.PKI.WGYsYdK2YJhNqyk7/OjQ9UH6y', '2KV5T3', 19, 0, 'eyJ1c2VyX2lkIjoyNSwidHlwZSI6MSwiZXhwIjoxNzczOTA2NDY0fQ==', '2026-03-19 15:47:44', 30, 1, NULL, '::1', '2026-03-12 11:27:35', '2026-03-12 15:47:44', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:47:44\",\"last_activity\":\"2026-03-12 15:47:44\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:47:44\",\"last_activity\":\"2026-03-12 15:47:44\"}]');
INSERT INTO `c_users` VALUES (26, 'test8', 'test8@example.com', '13800138008', '$2y$12$TDV0yL1wMv72SmF9MPUMwuaVhcOIz3TFcKYiRURK6n2lXuZ.ARTz2', 'F256G7', 20, 1, 'eyJ1c2VyX2lkIjoyNiwidHlwZSI6MSwiZXhwIjoxNzc0MTAzNDE1fQ==', '2026-03-21 22:30:15', 31, 1, NULL, '::1', '2026-03-12 11:27:56', '2026-03-14 22:30:15', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-14 22:30:15\",\"last_activity\":\"2026-03-14 22:30:15\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-14 22:30:15\",\"last_activity\":\"2026-03-14 22:30:15\"}]');
INSERT INTO `c_users` VALUES (27, 'test9', 'test9@example.com', '13800138009', '$2y$12$bh6PAgcrXwmNXRk38eFG8.upZkPqMjtWdNVWvagfrXSN0.R7wxAp2', 'ZNFZBV', 26, 0, 'eyJ1c2VyX2lkIjoyNywidHlwZSI6MSwiZXhwIjoxNzczOTA2NTAyfQ==', '2026-03-19 15:48:22', 32, 1, NULL, '::1', '2026-03-12 14:31:10', '2026-03-12 15:48:22', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:48:22\",\"last_activity\":\"2026-03-12 15:48:22\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:48:22\",\"last_activity\":\"2026-03-12 15:48:22\"}]');

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
  `view_status` tinyint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_b_user_id`(`b_user_id` ASC) USING BTREE,
  INDEX `idx_task_id`(`task_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_deadline`(`deadline` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '放大镜任务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of magnifying_glass_tasks
-- ----------------------------
INSERT INTO `magnifying_glass_tasks` VALUES (1, 3, NULL, 3, 'https://www.bilibili.com/video/BV1qeZuBPE3i/?spm_id_from=333.1007.tianma.1-3-3.click&vd_source=786a0003ba5bc5348f314ee587d01658', 1780243200, '[{\"at_user\": \"@超哥超车\", \"comment\": \"蓝词搜索@超哥超车\", \"image_url\": \"\"}, {\"at_user\": \"@超哥超车\", \"comment\": \"蓝词搜索@超哥超车\", \"image_url\": \"\"}]', 2, 0, 0, 0, 5.00, 10.00, 2, '2026-03-06 20:28:07', '2026-03-09 21:13:11', NULL, '放大镜搜索词', 1);
INSERT INTO `magnifying_glass_tasks` VALUES (2, 3, NULL, 3, 'https://www.bilibili.com/video/BV1qeZuBPE3i/?spm_id_from=333.1007.tianma.1-3-3.click&vd_source=786a0003ba5bc5348f314ee587d01658', 1780243200, '[{\"at_user\": \"@咕噜\", \"comment\": \"蓝词搜索@咕噜\", \"image_url\": \"\"}, {\"at_user\": \"@超哥超车\", \"comment\": \"蓝词搜索@超哥超车\", \"image_url\": \"\"}, {\"at_user\": \"@乔哥\", \"comment\": \"蓝词搜索@乔哥\", \"image_url\": \"\"}]', 3, 0, 0, 0, 5.00, 15.00, 2, '2026-03-06 22:40:41', '2026-03-11 13:53:01', NULL, '放大镜搜索词', 1);
INSERT INTO `magnifying_glass_tasks` VALUES (3, 3, NULL, 3, 'https://www.bilibili.com/video/BV1xPZAB8ExF/?spm_id_from=333.1007.tianma.1-1-1.click', 1772851124, '[{\"at_user\": \"\", \"comment\": \"蓝词搜索：@超哥\", \"image_url\": \"\"}]', 5, 0, 0, 0, 5.00, 25.00, 2, '2026-03-07 10:28:44', '2026-03-09 21:13:10', NULL, '放大镜搜索词', 1);
INSERT INTO `magnifying_glass_tasks` VALUES (4, 2, NULL, 3, '123456', 1772950514, '[{\"at_user\": \"\", \"comment\": \"小野\", \"image_url\": \"\"}]', 1, 0, 0, 0, 5.00, 5.00, 2, '2026-03-08 13:45:14', '2026-03-11 22:52:11', NULL, '放大镜搜索词', 1);
INSERT INTO `magnifying_glass_tasks` VALUES (5, 3, NULL, 3, 'https://example.com/video.mp4', 1796058000, '[{\"at_user\": \"@超哥超车\", \"comment\": \"蓝词搜索@超哥超车\", \"image_url\": \"\"}]', 2, 0, 0, 0, 5.00, 10.00, 2, '2026-03-11 23:56:02', '2026-03-13 22:51:08', NULL, '放大镜搜索词', 1);
INSERT INTO `magnifying_glass_tasks` VALUES (6, 3, NULL, 3, 'https://example.com/video.mp4', 1796058000, '[{\"at_user\": \"@超哥超车\", \"comment\": \"蓝词搜索@超哥超车\", \"image_url\": \"\"}]', 2, 0, 0, 0, 5.00, 10.00, 2, '2026-03-12 16:45:26', '2026-03-13 22:51:06', NULL, '放大镜搜索词', 1);
INSERT INTO `magnifying_glass_tasks` VALUES (7, 3, NULL, 3, 'https://example.com/video.mp4', 1796058000, '[{\"at_user\": \"@超哥超车\", \"comment\": \"蓝词搜索@超哥超车\", \"image_url\": \"\"}]', 2, 0, 0, 0, 5.00, 10.00, 2, '2026-03-12 16:47:08', '2026-03-13 22:51:05', NULL, '放大镜搜索词', 1);
INSERT INTO `magnifying_glass_tasks` VALUES (8, 3, NULL, 3, 'https://example.com/video.mp4', 1796058000, '[{\"at_user\": \"@超哥超车\", \"comment\": \"蓝词搜索@超哥超车\", \"image_url\": \"\"}]', 2, 0, 0, 0, 5.00, 10.00, 2, '2026-03-13 11:11:22', '2026-03-13 22:51:05', NULL, '放大镜搜索词', 1);
INSERT INTO `magnifying_glass_tasks` VALUES (9, 3, NULL, 3, 'https://example.com/video.mp4', 1796058000, '[{\"at_user\": \"@超哥超车\", \"comment\": \"蓝词搜索@超哥超车\", \"image_url\": \"\"}]', 2, 0, 0, 0, 5.00, 10.00, 2, '2026-03-13 11:13:36', '2026-03-13 22:51:01', NULL, '放大镜搜索词', 1);
INSERT INTO `magnifying_glass_tasks` VALUES (10, 3, NULL, 3, 'https://example.com/video.mp4', 1796058000, '[{\"at_user\": \"@超哥超车\", \"comment\": \"蓝词搜索@超哥超车\", \"image_url\": \"\"}]', 2, 0, 0, 0, 5.00, 10.00, 2, '2026-03-14 20:23:29', '2026-03-14 20:27:39', NULL, '放大镜搜索词', 1);

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
) ENGINE = InnoDB AUTO_INCREMENT = 85 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统通知表-通知模板' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `notifications` VALUES (47, '充值审核通过', '您的充值申请已审核通过，金额：¥1,000.00 已到账。感谢您的使用！', 3, 5, 2, 1, NULL, '2026-03-09 20:33:00');
INSERT INTO `notifications` VALUES (48, '充值审核通过', '您的充值申请已审核通过，金额：¥200.00 已到账。感谢您的使用！', 3, 3, 2, 1, NULL, '2026-03-09 21:29:10');
INSERT INTO `notifications` VALUES (49, '任务已到期下架', '您发布的任务「上评评论」已到期自动下架。\n任务进度：0/3（0%）\n截止时间：2026-03-11 11:52:44\n', 3, 1, 2, 1, NULL, '2026-03-11 11:53:01');
INSERT INTO `notifications` VALUES (50, '任务已到期下架', '您发布的任务「上评评论」已到期自动下架。\n任务进度：0/1（0%）\n截止时间：2026-03-11 12:07:14\n', 3, 1, 2, 1, NULL, '2026-03-11 12:08:01');
INSERT INTO `notifications` VALUES (51, '任务已到期下架', '您发布的任务「中评评论」已到期自动下架。\n任务进度：0/3（0%）\n截止时间：2026-03-11 12:08:24\n', 3, 1, 2, 1, NULL, '2026-03-11 12:09:01');
INSERT INTO `notifications` VALUES (52, '充值审核通过', '您的充值申请已审核通过，金额：¥200.00 已到账。感谢您的使用！', 3, 3, 2, 1, NULL, '2026-03-13 22:54:19');
INSERT INTO `notifications` VALUES (53, '充值审核通过', '您的充值申请已审核通过，金额：¥200.00 已到账。感谢您的使用！', 3, 3, 2, 1, NULL, '2026-03-13 22:54:20');
INSERT INTO `notifications` VALUES (54, '充值审核通过', '您的充值申请已审核通过，金额：¥200.00 已到账。感谢您的使用！', 3, 3, 2, 1, NULL, '2026-03-13 22:54:22');
INSERT INTO `notifications` VALUES (55, '充值审核通过', '您的充值申请已审核通过，金额：¥200.00 已到账。感谢您的使用！', 3, 3, 2, 1, NULL, '2026-03-14 16:44:32');
INSERT INTO `notifications` VALUES (56, '提现审核通过', '您的提现申请已审核通过，提现金额：¥1.00，手续费：¥0.03，实际到账：¥0.97。\n\n收款方式：alipay\n收款账号：15900000001', 3, 2, 1, 1, NULL, '2026-03-14 16:56:20');
INSERT INTO `notifications` VALUES (57, '提现审核通过', '您的提现申请已审核通过，提现金额：¥1.00，手续费：¥0.03，实际到账：¥0.97。\n\n收款方式：alipay\n收款账号：15900000001', 3, 5, 1, 1, NULL, '2026-03-14 16:56:22');
INSERT INTO `notifications` VALUES (58, '提现审核通过', '您的提现申请已审核通过，提现金额：¥1.00，手续费：¥0.03，实际到账：¥0.97。\n\n收款方式：alipay\n收款账号：15900000001', 3, 27, 1, 1, NULL, '2026-03-14 16:56:24');
INSERT INTO `notifications` VALUES (59, '提现审核通过', '您的提现申请已审核通过，提现金额：¥1.00，手续费：¥0.03，实际到账：¥0.97。\n\n收款方式：alipay\n收款账号：15900000001', 3, 26, 1, 1, NULL, '2026-03-14 16:56:26');
INSERT INTO `notifications` VALUES (60, '提现审核通过', '您的提现申请已审核通过，提现金额：¥10.00，手续费：¥0.30，实际到账：¥9.70。\n\n收款方式：alipay\n收款账号：15900000001', 3, 5, 1, 1, NULL, '2026-03-14 16:56:28');
INSERT INTO `notifications` VALUES (61, '提现审核通过', '您的提现申请已审核通过，提现金额：¥1.00，手续费：¥0.03，实际到账：¥0.97。\n\n收款方式：alipay\n收款账号：15900000001', 3, 20, 1, 1, NULL, '2026-03-14 16:56:30');
INSERT INTO `notifications` VALUES (62, '提现审核未通过', '很抱歉，您的提现申请未通过审核。\n\n拒绝原因：测试拒绝的交易记录\n\n如有疑问，请联系客服。', 3, 5, 1, 1, NULL, '2026-03-14 16:56:50');
INSERT INTO `notifications` VALUES (63, '收到新的租赁订单', '您的出租「测试租赁系统的新功能，佣金结算」收到新订单，租期7天，等待客服处理', 3, 5, 1, 1, NULL, '2026-03-14 20:24:49');
INSERT INTO `notifications` VALUES (64, '租赁订单支付成功', '您租赁的「测试租赁系统的新功能，佣金结算」已支付成功，等待客服处理', 3, 3, 2, 1, NULL, '2026-03-14 20:24:49');
INSERT INTO `notifications` VALUES (65, '充值审核通过', '您的充值申请已审核通过，金额：¥200.00 已到账。感谢您的使用！', 3, 3, 2, 1, NULL, '2026-03-14 20:25:32');
INSERT INTO `notifications` VALUES (66, '提现审核通过', '您的提现申请已审核通过，提现金额：¥10.00，手续费：¥0.30，实际到账：¥9.70。\n\n收款方式：alipay\n收款账号：15900000001', 3, 5, 1, 1, NULL, '2026-03-14 21:30:25');
INSERT INTO `notifications` VALUES (67, '租赁订单已开始', '您租用的订单 #1 已开始执行，租期 7 天，到期时间：2026-03-21 21:30:28', 3, 3, 2, 1, NULL, '2026-03-14 21:30:28');
INSERT INTO `notifications` VALUES (68, '租赁订单已开始', '您出租的订单 #1 已开始执行，租期 7 天，到期时间：2026-03-21 21:30:28', 3, 5, 1, 1, NULL, '2026-03-14 21:30:28');
INSERT INTO `notifications` VALUES (69, '租赁订单已完成', '您出租的订单 #1 已完成，收益 ¥245.00 已到账', 3, 5, 1, 1, NULL, '2026-03-14 21:40:59');
INSERT INTO `notifications` VALUES (70, '租赁订单已完成', '您租用的订单 #1 已到期完成，感谢使用', 3, 3, 2, 1, NULL, '2026-03-14 21:40:59');
INSERT INTO `notifications` VALUES (71, '提现审核通过', '您的提现申请已审核通过，提现金额：¥3.00，手续费：¥0.09，实际到账：¥2.91。\n\n收款方式：alipay\n收款账号：15900000001', 3, 5, 1, 1, NULL, '2026-03-14 22:18:13');
INSERT INTO `notifications` VALUES (72, '收到新的应征申请', '您的求租「测试求租发布」收到了新的应征，请前往查看审核', 3, 3, 2, 1, NULL, '2026-03-14 22:22:55');
INSERT INTO `notifications` VALUES (73, '收到新的租赁订单', '您的出租「测试租赁系统的新功能，佣金结算」收到新订单，租期5天，等待客服处理', 3, 26, 1, 1, NULL, '2026-03-14 22:23:22');
INSERT INTO `notifications` VALUES (74, '租赁订单支付成功', '您租赁的「测试租赁系统的新功能，佣金结算」已支付成功，等待客服处理', 3, 3, 2, 1, NULL, '2026-03-14 22:23:22');
INSERT INTO `notifications` VALUES (75, '应征审核通过', '您应征的求租「测试求租发布」已通过审核，订单已生成，等待客服处理', 3, 26, 1, 1, NULL, '2026-03-14 22:24:31');
INSERT INTO `notifications` VALUES (76, '应征已审核', '您的求租「测试求租发布」已选中应征方，订单已创建', 3, 3, 2, 1, NULL, '2026-03-14 22:24:31');
INSERT INTO `notifications` VALUES (77, '租赁订单已开始', '您租用的订单 #3 已开始执行，租期 15 天，到期时间：2026-03-29 22:26:01', 3, 3, 2, 1, NULL, '2026-03-14 22:26:01');
INSERT INTO `notifications` VALUES (78, '租赁订单已开始', '您出租的订单 #3 已开始执行，租期 15 天，到期时间：2026-03-29 22:26:01', 3, 26, 1, 1, NULL, '2026-03-14 22:26:01');
INSERT INTO `notifications` VALUES (79, '租赁订单已开始', '您租用的订单 #2 已开始执行，租期 5 天，到期时间：2026-03-19 22:26:03', 3, 3, 2, 1, NULL, '2026-03-14 22:26:03');
INSERT INTO `notifications` VALUES (80, '租赁订单已开始', '您出租的订单 #2 已开始执行，租期 5 天，到期时间：2026-03-19 22:26:03', 3, 26, 1, 1, NULL, '2026-03-14 22:26:03');
INSERT INTO `notifications` VALUES (81, '租赁订单已完成', '您出租的订单 #2 已完成，收益 ¥175.00 已到账', 3, 26, 1, 1, NULL, '2026-03-14 22:31:31');
INSERT INTO `notifications` VALUES (82, '租赁订单已完成', '您租用的订单 #2 已到期完成，感谢使用', 3, 3, 2, 1, NULL, '2026-03-14 22:31:31');
INSERT INTO `notifications` VALUES (83, '租赁订单已完成', '您出租的订单 #3 已完成，收益 ¥14.00 已到账', 3, 26, 1, 1, NULL, '2026-03-14 22:33:28');
INSERT INTO `notifications` VALUES (84, '租赁订单已完成', '您租用的订单 #3 已到期完成，感谢使用', 3, 3, 2, 1, NULL, '2026-03-14 22:33:28');

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
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '充值申请表-需要管理员审核' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `recharge_requests` VALUES (8, 5, 'Ceshi3', 2, 11, 100000, 'alipay', 'https://api.kktaskpaas.com/img/d3fd6fa1daf6e4a5867af591b59bbbbe.jpg', 81, 1, NULL, NULL, '2026-03-09 20:33:00', '2026-03-08 12:35:07');
INSERT INTO `recharge_requests` VALUES (9, 5, 'Ceshi3', 2, 11, 100000, 'alipay', 'https://api.kktaskpaas.com/img/cbb0c3bcc0e18d29b03c28fc57850e36.jpg', 82, 1, NULL, NULL, '2026-03-08 13:01:11', '2026-03-08 12:44:28');
INSERT INTO `recharge_requests` VALUES (10, 3, 'task', 2, 7, 20000, 'alipay', 'http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg', 90, 1, NULL, NULL, '2026-03-09 21:29:10', '2026-03-09 21:19:27');
INSERT INTO `recharge_requests` VALUES (11, 3, 'task', 2, 7, 20000, 'alipay', 'http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg', 104, 1, NULL, NULL, '2026-03-13 22:54:20', '2026-03-11 22:39:40');
INSERT INTO `recharge_requests` VALUES (12, 3, 'task', 2, 7, 20000, 'alipay', 'http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg', 105, 1, NULL, NULL, '2026-03-13 22:54:22', '2026-03-11 22:59:27');
INSERT INTO `recharge_requests` VALUES (13, 3, 'task', 2, 7, 20000, 'alipay', 'http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg', 156, 1, NULL, NULL, '2026-03-13 22:54:19', '2026-03-12 15:52:31');
INSERT INTO `recharge_requests` VALUES (14, 3, 'task', 2, 7, 20000, 'alipay', 'http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg', 169, 1, NULL, NULL, '2026-03-14 16:44:32', '2026-03-14 16:40:58');
INSERT INTO `recharge_requests` VALUES (15, 3, 'task', 2, 7, 20000, 'alipay', 'http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg', 178, 1, NULL, NULL, '2026-03-14 20:25:32', '2026-03-14 20:21:03');

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '求租应征表-我有符合要求的账号' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rental_applications
-- ----------------------------
INSERT INTO `rental_applications` VALUES (4, 6, 26, 1, 1, '{\"days\": 5, \"description\": \"我要日日你114514\", \"screenshots\": [\"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\", \"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"]}', 1, '', '2026-03-14 22:24:31', '2026-03-14 22:22:55', '2026-03-14 22:24:31');

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
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '求租信息表-账号需求市场' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rental_demands
-- ----------------------------
INSERT INTO `rental_demands` VALUES (6, 3, 2, 7, '测试求租发布', 2000, 15, '2026-04-01 21:35:00', '{\"deblocking\": \"true\", \"phone_number\": \"13912340001\", \"phone_message\": \"true\", \"basic_information\": \"账号正常，及时回复消息\"}', 2, 0, '2026-03-14 22:20:28', '2026-03-14 22:24:31');

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
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '出租信息表-账号出租市场' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rental_offers
-- ----------------------------
INSERT INTO `rental_offers` VALUES (9, 5, 1, '测试租赁系统的新功能，佣金结算', 5000, 1, 30, 0, '{\"email\": \"true\", \"images\": [\"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"], \"qq_number\": \"true\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"测试租赁系统的新功能，佣金结算，卖方分成60%，普通团长10%，高级团长20%\", \"phone_number\": \"true\", \"other_require\": \"true\", \"phone_message\": \"true\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}', 0, 0, '2026-03-14 20:24:00', '2026-03-14 20:24:49');
INSERT INTO `rental_offers` VALUES (10, 3, 2, '测试租赁系统的新功能，佣金结算', 5000, 1, 30, 0, '{\"email\": \"true\", \"images\": [\"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"], \"qq_number\": \"true\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"测试租赁系统的新功能，佣金结算，卖方分成60%，普通团长10%，高级团长20%\", \"phone_number\": \"true\", \"other_require\": \"true\", \"phone_message\": \"true\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}', 1, 0, '2026-03-14 22:20:23', '2026-03-14 22:20:23');
INSERT INTO `rental_offers` VALUES (11, 26, 1, '测试租赁系统的新功能，佣金结算', 5000, 1, 30, 0, '{\"email\": \"true\", \"images\": [\"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"], \"qq_number\": \"true\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"测试租赁系统的新功能，佣金结算，卖方分成60%，普通团长10%，高级团长20%\", \"phone_number\": \"true\", \"other_require\": \"true\", \"phone_message\": \"true\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}', 0, 0, '2026-03-14 22:21:22', '2026-03-14 22:23:22');

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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '租赁订单表-成交订单记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rental_orders
-- ----------------------------
INSERT INTO `rental_orders` VALUES (1, 0, 9, 3, 'b', 7, '{\"notes\": \"需要高权重账号\", \"usage\": \"用于直播带货\", \"contact\": \"微信xxx\"}', 5, 'c', 8, '{\"email\": \"true\", \"images\": [\"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"], \"qq_number\": \"true\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"测试租赁系统的新功能，佣金结算，卖方分成60%，普通团长10%，高级团长20%\", \"phone_number\": \"true\", \"other_require\": \"true\", \"phone_message\": \"true\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}', NULL, 0, 35000, 10500, 24500, 7, 0, '{\"end_time\": 1773495300, \"max_days\": 30, \"min_days\": 1, \"start_time\": 1773495028, \"offer_title\": \"测试租赁系统的新功能，佣金结算\", \"price_per_day\": 5000}', 3, '2026-03-14 20:24:49', '2026-03-14 21:40:59');
INSERT INTO `rental_orders` VALUES (2, 0, 11, 3, 'b', 7, '{\"notes\": \"需要高权重账号\", \"usage\": \"用于直播带货\", \"contact\": \"微信xxx\"}', 26, 'c', 31, '{\"email\": \"true\", \"images\": [\"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"], \"qq_number\": \"true\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"测试租赁系统的新功能，佣金结算，卖方分成60%，普通团长10%，高级团长20%\", \"phone_number\": \"true\", \"other_require\": \"true\", \"phone_message\": \"true\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}', 20, 1250, 25000, 6250, 17500, 5, 0, '{\"end_time\": 1773498600, \"max_days\": 30, \"min_days\": 1, \"start_time\": 1773498363, \"offer_title\": \"测试租赁系统的新功能，佣金结算\", \"price_per_day\": 5000}', 3, '2026-03-14 22:23:22', '2026-03-14 22:31:31');
INSERT INTO `rental_orders` VALUES (3, 1, 6, 3, 'b', 5, '{\"deblocking\": \"true\", \"phone_number\": \"13912340001\", \"phone_message\": \"true\", \"basic_information\": \"账号正常，及时回复消息\"}', 26, 'c', 31, '{\"days\": 5, \"description\": \"我要日日你114514\", \"screenshots\": [\"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\", \"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"]}', 20, 100, 30000, 500, 1400, 15, 1, '{\"end_time\": 1773498600, \"max_days\": 30, \"min_days\": 1, \"start_time\": 1773498363, \"demand_title\": \"测试求租发布\", \"price_per_day\": 2000, \"application_id\": 4}', 3, '2026-03-14 22:24:31', '2026-03-14 22:33:28');

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '工单消息表-客服聊天记录' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '租赁工单表-售后纠纷处理' ROW_FORMAT = DYNAMIC;

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
  `parent_level` int NULL DEFAULT NULL COMMENT '导航面板级别：1=一级，2=二级',
  `section_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '对应div显示的id',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 34 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统权限模板表（导航栏面板）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_permission_template
-- ----------------------------
INSERT INTO `system_permission_template` VALUES (1, '统计面板', 'dashboard', '系统运营概览', NULL, 'ri-dashboard-3-line', 'dashboard', 1, 1, '2026-03-06 16:44:05', '2026-03-14 00:37:36', 1, 'dashboardSection');
INSERT INTO `system_permission_template` VALUES (2, 'B端用户', 'b-users', 'B端用户管理', NULL, 'ri-building-4-line', 'b-users', 2, 1, '2026-03-06 16:44:05', '2026-03-14 00:38:06', 1, 'b-usersSection');
INSERT INTO `system_permission_template` VALUES (3, 'C端用户', 'c-users', 'C端用户管理', NULL, 'ri-user-3-line', 'c-users', 3, 1, '2026-03-06 16:44:05', '2026-03-14 00:38:11', 1, 'c-usersSection');
INSERT INTO `system_permission_template` VALUES (4, '系统用户', 'system-users', '系统用户管理', NULL, 'ri-admin-line', 'system-users', 3, 1, '2026-03-06 16:44:05', '2026-03-14 16:50:44', 1, 'system-usersSection');
INSERT INTO `system_permission_template` VALUES (5, '角色管理', 'system-roles', '角色权限管理', NULL, 'ri-shield-keyhole-line', 'system-roles', 6, 1, '2026-03-06 16:44:05', '2026-03-14 16:51:22', 1, 'system-rolesSection');
INSERT INTO `system_permission_template` VALUES (6, '权限管理', 'system-permissions', '权限模板管理', NULL, 'ri-lock-line', 'system-permissions', 6, 1, '2026-03-06 16:44:05', '2026-03-14 00:41:36', 1, 'system-permissionsSection');
INSERT INTO `system_permission_template` VALUES (7, '任务模板', 'templates', '任务模板管理', NULL, 'ri-file-list-3-line', 'templates', 7, 1, '2026-03-06 16:44:05', '2026-03-14 00:38:31', 1, 'templatesSection');
INSERT INTO `system_permission_template` VALUES (8, '任务市场', 'market', '任务市场监控', NULL, 'ri-store-2-line', 'market', 8, 1, '2026-03-06 16:44:05', '2026-03-14 00:38:34', 1, 'marketSection');
INSERT INTO `system_permission_template` VALUES (9, '任务审核', 'task-review', '任务审核管理', NULL, 'ri-check-double-line', 'task-review', 4, 1, '2026-03-06 16:44:05', '2026-03-14 16:49:52', 1, 'task-reviewSection');
INSERT INTO `system_permission_template` VALUES (10, '放大镜任务', 'magnifier', '放大镜任务管理', NULL, 'ri-search-line', 'magnifier', 10, 1, '2026-03-06 16:44:05', '2026-03-14 00:41:45', 1, 'magnifierSection');
INSERT INTO `system_permission_template` VALUES (11, '钱包记录', 'wallet-logs', '钱包资金记录', NULL, 'ri-wallet-3-line', 'wallet-logs', 3, 1, '2026-03-06 16:44:05', '2026-03-14 16:30:04', 1, 'wallet-logsSection');
INSERT INTO `system_permission_template` VALUES (12, '充值审核', 'recharge', '充值审核管理', NULL, 'ri-money-dollar-circle-line', 'recharge', 4, 1, '2026-03-06 16:44:05', '2026-03-14 16:49:58', 1, 'rechargeSection');
INSERT INTO `system_permission_template` VALUES (13, '提现审核', 'withdraw', '提现审核管理', NULL, 'ri-hand-coin-line', 'withdraw', 4, 1, '2026-03-06 16:44:05', '2026-03-14 16:50:00', 1, 'withdrawSection');
INSERT INTO `system_permission_template` VALUES (14, '团长审核', 'agent', '团长申请审核', NULL, 'ri-vip-crown-line', 'agent', 5, 1, '2026-03-06 16:44:05', '2026-03-14 16:50:10', 1, 'agentSection');
INSERT INTO `system_permission_template` VALUES (15, '租赁处理', 'rental-orders', '租赁订单处理', NULL, 'ri-home-smile-2-line', 'rental-orders', 15, 1, '2026-03-06 16:44:05', '2026-03-14 00:39:02', 1, 'rental-ordersSection');
INSERT INTO `system_permission_template` VALUES (16, '工单管理', 'rental-tickets', '租赁工单管理', NULL, 'ri-customer-service-2-line', 'rental-tickets', 16, 1, '2026-03-06 16:44:05', '2026-03-14 00:39:09', 1, 'rental-ticketsSection');
INSERT INTO `system_permission_template` VALUES (17, '网站配置', 'system-config', '网站系统配置', NULL, 'ri-settings-4-line', 'system-config', 17, 1, '2026-03-06 16:44:05', '2026-03-14 00:39:15', 1, 'system-configSection');
INSERT INTO `system_permission_template` VALUES (18, '系统通知', 'notifications', '系统通知管理', NULL, 'ri-notification-3-line', 'notifications', 18, 1, '2026-03-06 16:44:05', '2026-03-14 00:40:29', 1, 'notificationsSection');
INSERT INTO `system_permission_template` VALUES (19, '团长迁跃升级', 'agent-upgrade', 'C端用户代理等级跃迁管理', NULL, 'ri-arrow-up-circle-line', 'agent', 5, 1, '2026-03-08 14:01:49', '2026-03-14 16:50:07', 1, 'agentUpgradeSection');
INSERT INTO `system_permission_template` VALUES (20, '提示通知列表', 'notification-logs', '系统通知检测日志', NULL, 'ri-file-list-line', 'notification-logs', 19, 1, '2026-03-08 14:01:49', '2026-03-14 00:40:43', 1, 'notification-logsSection');
INSERT INTO `system_permission_template` VALUES (21, '登录设备配置', 'login-devices-config', '用户登录设备数量配置', NULL, 'ri-lock-unlock-line', 'login-devices-config', 20, 1, '2026-03-10 12:55:46', '2026-03-14 00:39:26', 1, 'login-devices-configSection');
INSERT INTO `system_permission_template` VALUES (22, '派单用户交易流水', 'b-statisticsSection', 'B端用户交易流水管理', NULL, 'ri-wallet-2-line', 'b-statistics', 3, 1, '2026-03-10 12:00:00', '2026-03-14 01:08:13', 1, 'b-statisticsSection');
INSERT INTO `system_permission_template` VALUES (23, '接单用户交易流水', 'c-statisticsSection', 'C端用户交易流水管理', NULL, 'ri-wallet-2-line', 'c-statistics', 3, 1, '2026-03-13 19:01:24', '2026-03-14 01:08:17', 1, 'c-statisticsSection');
INSERT INTO `system_permission_template` VALUES (30, '派单交易流水', 'b-statistics-flows', 'B端用户交易流水记录', 22, 'ri-list-check', 'b-statistics-flows', 1, 1, '2026-03-13 17:36:18', '2026-03-14 01:06:06', 2, 'b-statisticsSection');
INSERT INTO `system_permission_template` VALUES (31, '派单数据统计', 'b-statistics-summary', 'B端用户交易数据统计', 22, 'ri-bar-chart-line', 'b-statistics-summary', 2, 1, '2026-03-13 17:36:18', '2026-03-14 00:48:30', 2, 'bStatisticsSummary');
INSERT INTO `system_permission_template` VALUES (32, '接单交易流水', 'c-statistics-flows', 'C端用户交易流水记录', 23, 'ri-list-check', 'c-statistics-flows', 1, 1, '2026-03-13 19:05:00', '2026-03-14 00:48:35', 2, 'cUsersStatisticsTable');
INSERT INTO `system_permission_template` VALUES (33, '接单数据统计', 'c-statistics-summary', 'C端数据统计管理', 23, 'ri-wallet-2-line', 'c-statistics-summary', 2, 1, '2026-03-13 19:05:56', '2026-03-14 00:48:38', 2, 'cStatisticsSummary');

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
) ENGINE = InnoDB AUTO_INCREMENT = 250 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '角色权限模板关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_role_permission_template
-- ----------------------------
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
INSERT INTO `system_role_permission_template` VALUES (90, 7, 1, '2026-03-07 10:58:18');
INSERT INTO `system_role_permission_template` VALUES (132, 5, 8, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (133, 5, 9, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (134, 5, 10, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (135, 5, 11, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (136, 5, 12, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (137, 5, 13, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (138, 5, 14, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (139, 5, 15, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (140, 5, 16, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (141, 5, 18, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (142, 5, 20, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (223, 1, 1, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (224, 1, 2, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (225, 1, 3, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (226, 1, 22, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (227, 1, 30, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (228, 1, 31, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (229, 1, 23, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (230, 1, 32, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (231, 1, 33, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (232, 1, 4, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (233, 1, 5, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (234, 1, 6, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (235, 1, 7, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (236, 1, 8, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (237, 1, 9, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (238, 1, 10, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (239, 1, 11, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (240, 1, 12, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (241, 1, 13, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (242, 1, 14, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (243, 1, 15, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (244, 1, 16, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (245, 1, 17, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (246, 1, 18, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (247, 1, 20, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (248, 1, 21, '2026-03-14 01:11:02');
INSERT INTO `system_role_permission_template` VALUES (249, 1, 19, '2026-03-14 01:11:02');

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
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮箱',
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
  INDEX `idx_role_id`(`role_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '后台管理用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_users
-- ----------------------------
INSERT INTO `system_users` VALUES (1, 'task', '25d55ad283aa400af464c76d713c07ad', 'admin@example.com', '13800138000', 1, 'eyJ1c2VyX2lkIjoxLCJ0eXBlIjozLCJleHAiOjE3NzQwNjU2NjN9', '2026-03-21 12:01:03', 1, '2026-03-14 12:01:03', '2026-03-06 15:32:33', '2026-03-14 12:01:03');
INSERT INTO `system_users` VALUES (2, 'kefu', '2569d419bfea999ff13fd1f7f4498b89', 'kefu@qq.com', '15900000000', 5, '96e5c379ab22bc8165c9e5ccc37262ac', '2026-03-07 10:17:08', 1, '2026-03-06 18:17:08', '2026-03-06 18:09:15', '2026-03-11 12:31:19');
INSERT INTO `system_users` VALUES (3, 'shenji', 'e99a18c428cb38d5f260853678922e03', '', '15900000001', 7, '54de1ef7302bae1f7259845cef6d2ff8', '2026-03-07 22:51:52', 1, '2026-03-06 22:51:52', '2026-03-06 18:16:16', '2026-03-06 22:51:52');
INSERT INTO `system_users` VALUES (5, 'xiaoya', '2569d419bfea999ff13fd1f7f4498b89', '', '13049610316', 5, 'eyJ1c2VyX2lkIjo1LCJ0eXBlIjozLCJleHAiOjE3NzM4MjIzMDR9', '2026-03-18 16:25:04', 1, '2026-03-11 16:25:04', '2026-03-11 12:37:27', '2026-03-11 16:25:04');

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
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '任务模板表-平台配置' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 85 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户通知表-每个用户收到的通知' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `user_notifications` VALUES (18, 18, 5, 1, 1, '2026-03-10 15:13:25', '2026-03-03 11:39:01');
INSERT INTO `user_notifications` VALUES (19, 19, 5, 1, 1, '2026-03-10 15:13:25', '2026-03-03 11:59:01');
INSERT INTO `user_notifications` VALUES (20, 20, 5, 1, 1, '2026-03-10 15:13:25', '2026-03-03 12:15:01');
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
INSERT INTO `user_notifications` VALUES (31, 31, 5, 1, 1, '2026-03-10 15:13:25', '2026-03-05 21:10:02');
INSERT INTO `user_notifications` VALUES (32, 32, 3, 2, 1, '2026-03-07 11:37:18', '2026-03-05 21:30:01');
INSERT INTO `user_notifications` VALUES (33, 33, 1, 2, 1, '2026-03-06 11:24:26', '2026-03-06 11:16:02');
INSERT INTO `user_notifications` VALUES (34, 34, 5, 1, 1, '2026-03-10 15:13:25', '2026-03-06 11:17:01');
INSERT INTO `user_notifications` VALUES (35, 35, 1, 2, 1, '2026-03-06 13:23:56', '2026-03-06 11:56:01');
INSERT INTO `user_notifications` VALUES (36, 36, 1, 2, 1, '2026-03-06 13:23:53', '2026-03-06 13:17:01');
INSERT INTO `user_notifications` VALUES (37, 37, 2, 2, 1, '2026-03-07 06:22:48', '2026-03-06 15:12:02');
INSERT INTO `user_notifications` VALUES (38, 38, 1, 2, 1, '2026-03-07 12:43:56', '2026-03-07 11:04:01');
INSERT INTO `user_notifications` VALUES (39, 39, 1, 2, 1, '2026-03-07 12:43:56', '2026-03-07 11:13:02');
INSERT INTO `user_notifications` VALUES (40, 40, 1, 2, 1, '2026-03-07 12:43:56', '2026-03-07 11:23:01');
INSERT INTO `user_notifications` VALUES (41, 41, 5, 2, 0, NULL, '2026-03-08 13:01:11');
INSERT INTO `user_notifications` VALUES (42, 42, 5, 1, 1, '2026-03-10 15:13:25', '2026-03-08 13:49:01');
INSERT INTO `user_notifications` VALUES (43, 43, 2, 2, 0, NULL, '2026-03-08 14:07:01');
INSERT INTO `user_notifications` VALUES (44, 44, 1, 2, 1, '2026-03-08 15:00:54', '2026-03-08 14:09:01');
INSERT INTO `user_notifications` VALUES (45, 45, 1, 2, 1, '2026-03-08 15:00:54', '2026-03-08 14:17:01');
INSERT INTO `user_notifications` VALUES (46, 46, 1, 2, 1, '2026-03-08 15:00:54', '2026-03-08 14:17:01');
INSERT INTO `user_notifications` VALUES (47, 47, 5, 2, 0, NULL, '2026-03-09 20:33:00');
INSERT INTO `user_notifications` VALUES (48, 48, 3, 2, 0, NULL, '2026-03-09 21:29:10');
INSERT INTO `user_notifications` VALUES (49, 49, 1, 2, 1, '2026-03-11 11:56:11', '2026-03-11 11:53:01');
INSERT INTO `user_notifications` VALUES (50, 50, 1, 2, 1, '2026-03-11 12:54:13', '2026-03-11 12:08:01');
INSERT INTO `user_notifications` VALUES (51, 51, 1, 2, 1, '2026-03-11 12:54:16', '2026-03-11 12:09:01');
INSERT INTO `user_notifications` VALUES (52, 52, 3, 2, 0, NULL, '2026-03-13 22:54:19');
INSERT INTO `user_notifications` VALUES (53, 53, 3, 2, 0, NULL, '2026-03-13 22:54:20');
INSERT INTO `user_notifications` VALUES (54, 54, 3, 2, 0, NULL, '2026-03-13 22:54:22');
INSERT INTO `user_notifications` VALUES (55, 55, 3, 2, 0, NULL, '2026-03-14 16:44:32');
INSERT INTO `user_notifications` VALUES (56, 56, 2, 1, 0, NULL, '2026-03-14 16:56:20');
INSERT INTO `user_notifications` VALUES (57, 57, 5, 1, 0, NULL, '2026-03-14 16:56:22');
INSERT INTO `user_notifications` VALUES (58, 58, 27, 1, 0, NULL, '2026-03-14 16:56:24');
INSERT INTO `user_notifications` VALUES (59, 59, 26, 1, 0, NULL, '2026-03-14 16:56:26');
INSERT INTO `user_notifications` VALUES (60, 60, 5, 1, 0, NULL, '2026-03-14 16:56:28');
INSERT INTO `user_notifications` VALUES (61, 61, 20, 1, 0, NULL, '2026-03-14 16:56:30');
INSERT INTO `user_notifications` VALUES (62, 62, 5, 1, 0, NULL, '2026-03-14 16:56:50');
INSERT INTO `user_notifications` VALUES (63, 63, 5, 1, 0, NULL, '2026-03-14 20:24:49');
INSERT INTO `user_notifications` VALUES (64, 64, 3, 2, 0, NULL, '2026-03-14 20:24:49');
INSERT INTO `user_notifications` VALUES (65, 65, 3, 2, 0, NULL, '2026-03-14 20:25:32');
INSERT INTO `user_notifications` VALUES (66, 66, 5, 1, 0, NULL, '2026-03-14 21:30:25');
INSERT INTO `user_notifications` VALUES (67, 67, 3, 2, 0, NULL, '2026-03-14 21:30:28');
INSERT INTO `user_notifications` VALUES (68, 68, 5, 1, 0, NULL, '2026-03-14 21:30:28');
INSERT INTO `user_notifications` VALUES (69, 69, 5, 1, 0, NULL, '2026-03-14 21:40:59');
INSERT INTO `user_notifications` VALUES (70, 70, 3, 2, 0, NULL, '2026-03-14 21:40:59');
INSERT INTO `user_notifications` VALUES (71, 71, 5, 1, 0, NULL, '2026-03-14 22:18:13');
INSERT INTO `user_notifications` VALUES (72, 72, 3, 2, 0, NULL, '2026-03-14 22:22:55');
INSERT INTO `user_notifications` VALUES (73, 73, 26, 1, 0, NULL, '2026-03-14 22:23:22');
INSERT INTO `user_notifications` VALUES (74, 74, 3, 2, 0, NULL, '2026-03-14 22:23:22');
INSERT INTO `user_notifications` VALUES (75, 75, 26, 1, 0, NULL, '2026-03-14 22:24:31');
INSERT INTO `user_notifications` VALUES (76, 76, 3, 2, 0, NULL, '2026-03-14 22:24:31');
INSERT INTO `user_notifications` VALUES (77, 77, 3, 2, 0, NULL, '2026-03-14 22:26:01');
INSERT INTO `user_notifications` VALUES (78, 78, 26, 1, 0, NULL, '2026-03-14 22:26:01');
INSERT INTO `user_notifications` VALUES (79, 79, 3, 2, 0, NULL, '2026-03-14 22:26:03');
INSERT INTO `user_notifications` VALUES (80, 80, 26, 1, 0, NULL, '2026-03-14 22:26:03');
INSERT INTO `user_notifications` VALUES (81, 81, 26, 1, 0, NULL, '2026-03-14 22:31:31');
INSERT INTO `user_notifications` VALUES (82, 82, 3, 2, 0, NULL, '2026-03-14 22:31:31');
INSERT INTO `user_notifications` VALUES (83, 83, 26, 1, 0, NULL, '2026-03-14 22:33:28');
INSERT INTO `user_notifications` VALUES (84, 84, 3, 2, 0, NULL, '2026-03-14 22:33:28');

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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付密码表-钱包支付密码管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wallet_password
-- ----------------------------
INSERT INTO `wallet_password` VALUES (1, 8, 5, 1, '123456', '2026-03-10 17:02:05', '2026-03-10 17:02:05');

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
) ENGINE = InnoDB AUTO_INCREMENT = 33 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '钱包表-三端共用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wallets
-- ----------------------------
INSERT INTO `wallets` VALUES (1, 207300, '2026-02-27 11:49:20', '2026-03-11 11:58:24');
INSERT INTO `wallets` VALUES (2, 205600, '2026-02-27 12:02:50', '2026-03-08 13:45:14');
INSERT INTO `wallets` VALUES (3, 0, '2026-02-27 13:06:22', '2026-02-27 13:06:22');
INSERT INTO `wallets` VALUES (4, 180, '2026-02-27 17:24:33', '2026-03-12 15:49:30');
INSERT INTO `wallets` VALUES (5, 0, '2026-02-27 17:26:27', '2026-02-27 17:26:27');
INSERT INTO `wallets` VALUES (6, 0, '2026-02-27 17:31:08', '2026-02-27 17:31:08');
INSERT INTO `wallets` VALUES (7, 171200, '2026-03-01 00:48:16', '2026-03-14 22:23:22');
INSERT INTO `wallets` VALUES (8, 29120, '2026-03-01 00:53:23', '2026-03-14 21:40:59');
INSERT INTO `wallets` VALUES (9, 0, '2026-03-02 00:12:06', '2026-03-02 00:12:06');
INSERT INTO `wallets` VALUES (10, 0, '2026-03-06 14:46:54', '2026-03-06 14:46:54');
INSERT INTO `wallets` VALUES (11, 200000, '2026-03-08 12:06:11', '2026-03-09 20:33:00');
INSERT INTO `wallets` VALUES (23, 180, '2026-03-11 12:23:27', '2026-03-11 17:09:01');
INSERT INTO `wallets` VALUES (24, 350, '2026-03-12 10:23:36', '2026-03-12 11:32:04');
INSERT INTO `wallets` VALUES (25, 1650, '2026-03-12 10:23:56', '2026-03-14 22:33:28');
INSERT INTO `wallets` VALUES (26, 0, '2026-03-12 10:24:12', '2026-03-12 10:24:12');
INSERT INTO `wallets` VALUES (27, 0, '2026-03-12 10:24:22', '2026-03-12 10:24:22');
INSERT INTO `wallets` VALUES (28, 0, '2026-03-12 10:24:46', '2026-03-12 10:24:46');
INSERT INTO `wallets` VALUES (29, 0, '2026-03-12 10:24:57', '2026-03-12 10:24:57');
INSERT INTO `wallets` VALUES (30, 100, '2026-03-12 11:27:35', '2026-03-12 11:32:04');
INSERT INTO `wallets` VALUES (31, 19300, '2026-03-12 11:27:56', '2026-03-14 22:33:28');
INSERT INTO `wallets` VALUES (32, 100, '2026-03-12 14:31:10', '2026-03-12 15:48:30');

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
  `task_types` tinyint UNSIGNED NULL DEFAULT NULL COMMENT '任务类型：1=上评评论，2=中评评论，3=放大镜搜索词，4=上中评评论，5=中下评评论，6=出租订单，7=求租订单',
  `task_types_text` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务类型文本描述',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '备注说明（扣费或收入原因）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_wallet_id`(`wallet_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_user_type`(`user_type` ASC) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_related`(`related_type` ASC, `related_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_task_types`(`task_types` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 213 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '钱包流水表-记录所有收支' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wallets_log
-- ----------------------------
INSERT INTO `wallets_log` VALUES (1, 2, 2, 'Ceshi1', 2, 1, 0, 0, 0, 'recharge', 1, NULL, NULL, '充值 ¥1,000.00（alipay），审核中', '2026-02-27 12:49:30');
INSERT INTO `wallets_log` VALUES (2, 1, 1, 'Ceshi', 2, 1, 0, 0, 0, 'recharge', 2, NULL, NULL, '充值 ¥1,000.00（alipay），审核中', '2026-02-27 12:49:46');
INSERT INTO `wallets_log` VALUES (3, 1, 1, 'Ceshi', 2, 1, 100000, 0, 100000, 'recharge', 2, NULL, NULL, '充值到账：¥1,000.00', '2026-02-27 12:49:56');
INSERT INTO `wallets_log` VALUES (4, 2, 2, 'Ceshi1', 2, 1, 100000, 0, 100000, 'recharge', 1, NULL, NULL, '充值到账：¥1,000.00', '2026-02-27 12:49:58');
INSERT INTO `wallets_log` VALUES (5, 2, 2, 'Ceshi1', 2, 1, 0, 100000, 100000, 'recharge', 3, NULL, NULL, '充值 ¥1,000.00（alipay），审核中', '2026-02-27 13:17:34');
INSERT INTO `wallets_log` VALUES (6, 1, 1, 'Ceshi', 2, 1, 0, 100000, 100000, 'recharge', 4, NULL, NULL, '充值 ¥1,000.00（alipay），审核中', '2026-02-27 13:18:09');
INSERT INTO `wallets_log` VALUES (7, 2, 2, 'Ceshi1', 2, 2, 5000, 100000, 95000, 'rental_freeze', 1, NULL, NULL, '求租信息冻结预算（5000分/天×1天）：抖音日租', '2026-02-27 13:47:33');
INSERT INTO `wallets_log` VALUES (8, 2, 2, 'Ceshi1', 2, 1, 0, 95000, 95000, 'recharge', 5, NULL, NULL, '充值 ¥100.00（alipay），审核中', '2026-02-27 14:22:20');
INSERT INTO `wallets_log` VALUES (9, 2, 2, 'Ceshi1', 2, 1, 10000, 95000, 105000, 'recharge', 5, NULL, NULL, '充值到账：¥100.00', '2026-02-27 14:23:06');
INSERT INTO `wallets_log` VALUES (10, 1, 1, 'Ceshi', 2, 1, 100000, 100000, 200000, 'recharge', 4, NULL, NULL, '充值到账：¥1,000.00', '2026-02-27 14:23:08');
INSERT INTO `wallets_log` VALUES (11, 2, 2, 'Ceshi1', 2, 1, 100000, 105000, 205000, 'recharge', 3, NULL, NULL, '充值到账：¥1,000.00', '2026-02-27 14:23:13');
INSERT INTO `wallets_log` VALUES (12, 2, 2, 'Ceshi1', 2, 2, 600, 205000, 204400, 'task', 1, NULL, NULL, '发布任务【上评评论】2个任务，扣除 ¥6.00', '2026-02-27 18:25:58');
INSERT INTO `wallets_log` VALUES (13, 2, 2, 'Ceshi1', 2, 2, 400, 204400, 204000, 'task', 2, NULL, NULL, '发布任务【中评评论】2个任务，扣除 ¥4.00', '2026-02-27 18:31:19');
INSERT INTO `wallets_log` VALUES (14, 1, 1, 'Ceshi', 2, 1, 0, 200000, 200000, 'recharge', 6, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-02-28 23:20:05');
INSERT INTO `wallets_log` VALUES (15, 1, 1, 'Ceshi', 2, 1, 20000, 200000, 220000, 'recharge', 6, NULL, NULL, '充值到账：¥200.00', '2026-02-28 23:20:14');
INSERT INTO `wallets_log` VALUES (16, 2, 2, 'Ceshi1', 2, 2, 300, 204000, 203700, 'task', 3, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-02-28 23:34:35');
INSERT INTO `wallets_log` VALUES (17, 2, 2, 'Ceshi1', 2, 1, 5000, 203700, 208700, 'rental_unfreeze', 1, NULL, NULL, '求租到期退回预算（5000分/天×1天）：抖音日租', '2026-03-01 00:00:04');
INSERT INTO `wallets_log` VALUES (18, 1, 1, 'Ceshi', 2, 2, 300, 220000, 219700, 'task', 4, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-01 00:34:05');
INSERT INTO `wallets_log` VALUES (19, 7, 3, 'task', 2, 1, 0, 0, 0, 'recharge', 7, NULL, NULL, '充值 ¥2,000.00（alipay），审核中', '2026-03-01 00:51:42');
INSERT INTO `wallets_log` VALUES (20, 7, 3, 'task', 2, 1, 200000, 0, 200000, 'recharge', 7, NULL, NULL, '充值到账：¥2,000.00', '2026-03-01 00:51:51');
INSERT INTO `wallets_log` VALUES (21, 7, 3, 'task', 2, 2, 10000, 200000, 190000, 'rental_freeze', 2, NULL, NULL, '求租信息冻结预算（5000分/天×2天）：测试求租发布', '2026-03-01 00:52:02');
INSERT INTO `wallets_log` VALUES (22, 7, 3, 'task', 2, 2, 300, 190000, 189700, 'task', 5, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-03 11:02:13');
INSERT INTO `wallets_log` VALUES (23, 7, 3, 'task', 2, 2, 600, 189700, 189100, 'task', 6, NULL, NULL, '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-03 11:48:04');
INSERT INTO `wallets_log` VALUES (24, 7, 3, 'task', 2, 2, 300, 189100, 188800, 'task', 7, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-03 12:03:50');
INSERT INTO `wallets_log` VALUES (25, 7, 3, 'task', 2, 2, 1000, 188800, 187800, 'rental_freeze', 3, NULL, NULL, '求租信息冻结预算（1000分/天×1天）：更新求租信息模块。发布测试', '2026-03-03 20:53:18');
INSERT INTO `wallets_log` VALUES (26, 7, 3, 'task', 2, 2, 20000, 187800, 167800, 'rental_freeze', 4, NULL, NULL, '求租信息冻结预算（2000分/天×10天）：测试发布求租信息更新。抖音', '2026-03-03 21:08:53');
INSERT INTO `wallets_log` VALUES (27, 7, 3, 'task', 2, 2, 1000, 167800, 166800, 'rental_freeze', 8, NULL, NULL, '求租信息冻结预算（1000分/天×1天）：发布求租信息更新。抖音', '2026-03-03 21:25:27');
INSERT INTO `wallets_log` VALUES (28, 7, 3, 'task', 2, 2, 600, 166800, 166200, 'task', 8, NULL, NULL, '发布任务【上评评论】2个任务，扣除 ¥6.00', '2026-03-04 00:37:44');
INSERT INTO `wallets_log` VALUES (29, 7, 3, 'task', 2, 2, 900, 166200, 165300, 'task', 9, NULL, NULL, '发布任务【上中评评论】4个任务，扣除 ¥9.00', '2026-03-04 01:00:08');
INSERT INTO `wallets_log` VALUES (30, 1, 1, 'Ceshi', 2, 2, 200, 219700, 219500, 'task', 11, NULL, NULL, '发布任务【中评评论】1个任务，扣除 ¥2.00', '2026-03-04 15:12:11');
INSERT INTO `wallets_log` VALUES (31, 1, 1, 'Ceshi', 2, 2, 900, 219500, 218600, 'task', 12, NULL, NULL, '发布任务【上中评评论】4个任务，扣除 ¥9.00', '2026-03-04 15:50:29');
INSERT INTO `wallets_log` VALUES (32, 8, 5, 'test', 1, 1, 100, 0, 100, 'commission', 4, NULL, NULL, '自动审核通过任务获得佣金，任务ID：4', '2026-03-04 17:33:01');
INSERT INTO `wallets_log` VALUES (33, 1, 1, 'Ceshi', 2, 2, 3000, 218600, 215600, 'task', 9, NULL, NULL, '发布任务【上评评论】10个任务，扣除 ¥30.00', '2026-03-04 20:03:07');
INSERT INTO `wallets_log` VALUES (34, 7, 3, 'task', 2, 2, 600, 165300, 164700, 'task', 15, NULL, NULL, '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-05 00:31:33');
INSERT INTO `wallets_log` VALUES (35, 1, 1, 'Ceshi', 2, 2, 900, 215600, 214700, 'task', 16, NULL, NULL, '发布任务【上评评论】3个任务，扣除 ¥9.00', '2026-03-05 11:53:47');
INSERT INTO `wallets_log` VALUES (36, 1, 1, 'Ceshi', 2, 2, 300, 214700, 214400, 'task', 17, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-05 12:19:22');
INSERT INTO `wallets_log` VALUES (37, 7, 3, 'task', 2, 2, 300, 164700, 164400, 'task', 18, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-05 20:59:37');
INSERT INTO `wallets_log` VALUES (38, 1, 1, 'Ceshi', 2, 2, 900, 214400, 213500, 'task', 19, NULL, NULL, '发布任务【上评评论】3个任务，扣除 ¥9.00', '2026-03-06 11:05:46');
INSERT INTO `wallets_log` VALUES (39, 1, 1, 'Ceshi', 2, 2, 500, 213500, 213000, 'task', 20, NULL, NULL, '发布任务【放大镜搜索词】1个任务，扣除 ¥5.00', '2026-03-06 11:25:44');
INSERT INTO `wallets_log` VALUES (40, 1, 1, 'Ceshi', 2, 2, 500, 213000, 212500, 'task', 21, NULL, NULL, '发布任务【放大镜搜索词】1个任务，扣除 ¥5.00', '2026-03-06 13:06:31');
INSERT INTO `wallets_log` VALUES (41, 2, 2, 'Ceshi1', 2, 2, 2000, 208700, 206700, 'task', 22, NULL, NULL, '发布任务【中评评论】10个任务，扣除 ¥20.00', '2026-03-06 15:01:15');
INSERT INTO `wallets_log` VALUES (42, 8, 5, 'test', 1, 1, 80, 100, 180, 'commission', 22, NULL, NULL, '自动审核通过任务获得佣金，任务ID：22', '2026-03-06 15:15:01');
INSERT INTO `wallets_log` VALUES (43, 7, 3, 'task', 2, 2, 1500, 164400, 162900, 'task', 2, NULL, NULL, '发布放大镜任务【放大镜搜索词】3个任务，扣除 ¥15.00', '2026-03-06 22:40:41');
INSERT INTO `wallets_log` VALUES (44, 7, 3, 'task', 2, 2, 2500, 162900, 160400, 'task', 3, NULL, NULL, '发布放大镜任务【放大镜搜索词】5个任务，扣除 ¥25.00', '2026-03-07 10:28:44');
INSERT INTO `wallets_log` VALUES (45, 1, 1, 'Ceshi', 2, 2, 900, 212500, 211600, 'task', 23, NULL, NULL, '发布任务【上中评评论】4个任务，扣除 ¥9.00', '2026-03-07 10:33:03');
INSERT INTO `wallets_log` VALUES (46, 8, 5, 'test', 1, 1, 100, 180, 280, 'commission', 23, NULL, NULL, '完成任务获得佣金，任务ID：23', '2026-03-07 10:38:37');
INSERT INTO `wallets_log` VALUES (47, 1, 1, 'Ceshi', 2, 2, 500, 211600, 211100, 'task', 25, NULL, NULL, '发布任务【放大镜搜索词】1个任务，扣除 ¥5.00', '2026-03-07 10:42:36');
INSERT INTO `wallets_log` VALUES (48, 1, 1, 'Ceshi', 2, 2, 500, 211100, 210600, 'task', 26, NULL, NULL, '发布任务【放大镜搜索词】1个任务，扣除 ¥5.00', '2026-03-07 10:52:23');
INSERT INTO `wallets_log` VALUES (49, 7, 3, 'task', 2, 2, 300, 160400, 160100, 'task', 27, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 11:24:54');
INSERT INTO `wallets_log` VALUES (50, 8, 5, 'test', 1, 1, 100, 280, 380, 'commission', 27, NULL, NULL, '自动审核通过任务获得佣金，任务ID：27', '2026-03-07 11:36:01');
INSERT INTO `wallets_log` VALUES (51, 7, 3, 'task', 2, 2, 300, 160100, 159800, 'task', 28, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 11:39:29');
INSERT INTO `wallets_log` VALUES (52, 8, 5, 'test', 1, 1, 100, 380, 480, 'commission', 28, NULL, NULL, '自动审核通过任务获得佣金，任务ID：28', '2026-03-07 11:51:01');
INSERT INTO `wallets_log` VALUES (53, 7, 3, 'task', 2, 2, 300, 159800, 159500, 'task', 29, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 12:08:09');
INSERT INTO `wallets_log` VALUES (54, 8, 5, 'test', 1, 1, 100, 480, 580, 'commission', 29, NULL, NULL, '自动审核通过任务获得佣金，任务ID：29', '2026-03-07 12:19:01');
INSERT INTO `wallets_log` VALUES (55, 7, 3, 'task', 2, 2, 300, 159500, 159200, 'task', 30, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 12:23:44');
INSERT INTO `wallets_log` VALUES (56, 8, 5, 'test', 1, 1, 100, 580, 680, 'commission', 30, NULL, NULL, '自动审核通过任务获得佣金，任务ID：30', '2026-03-07 12:34:01');
INSERT INTO `wallets_log` VALUES (57, 7, 3, 'task', 2, 2, 300, 159200, 158900, 'task', 31, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 12:52:23');
INSERT INTO `wallets_log` VALUES (58, 8, 5, 'test', 1, 1, 100, 680, 780, 'commission', 31, NULL, NULL, '自动审核通过任务获得佣金，任务ID：31', '2026-03-07 13:03:01');
INSERT INTO `wallets_log` VALUES (59, 7, 3, 'task', 2, 2, 300, 158900, 158600, 'task', 32, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 13:10:06');
INSERT INTO `wallets_log` VALUES (60, 8, 5, 'test', 1, 1, 100, 780, 880, 'commission', 32, NULL, NULL, '自动审核通过任务获得佣金，任务ID：32', '2026-03-07 13:21:01');
INSERT INTO `wallets_log` VALUES (61, 7, 3, 'task', 2, 2, 300, 158600, 158300, 'task', 33, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 13:40:53');
INSERT INTO `wallets_log` VALUES (62, 8, 5, 'test', 1, 1, 100, 880, 980, 'commission', 33, NULL, NULL, '自动审核通过任务获得佣金，任务ID：33', '2026-03-07 13:52:01');
INSERT INTO `wallets_log` VALUES (63, 7, 3, 'task', 2, 2, 300, 158300, 158000, 'task', 34, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 13:58:39');
INSERT INTO `wallets_log` VALUES (64, 8, 5, 'test', 1, 1, 100, 980, 1080, 'commission', 34, NULL, NULL, '完成任务获得佣金，任务ID：34', '2026-03-07 14:00:18');
INSERT INTO `wallets_log` VALUES (65, 7, 3, 'task', 2, 2, 300, 158000, 157700, 'task', 35, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 14:06:14');
INSERT INTO `wallets_log` VALUES (66, 8, 5, 'test', 1, 1, 100, 1080, 1180, 'commission', 35, NULL, NULL, '自动审核通过任务获得佣金，任务ID：35', '2026-03-07 14:17:01');
INSERT INTO `wallets_log` VALUES (67, 7, 3, 'task', 2, 2, 300, 157700, 157400, 'task', 36, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 14:22:14');
INSERT INTO `wallets_log` VALUES (68, 8, 5, 'test', 1, 1, 100, 1180, 1280, 'commission', 36, NULL, NULL, '自动审核通过任务获得佣金，任务ID：36', '2026-03-07 14:33:01');
INSERT INTO `wallets_log` VALUES (69, 7, 3, 'task', 2, 2, 300, 157400, 157100, 'task', 37, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 14:34:59');
INSERT INTO `wallets_log` VALUES (70, 8, 5, 'test', 1, 1, 100, 1280, 1380, 'commission', 37, NULL, NULL, '自动审核通过任务获得佣金，任务ID：37', '2026-03-07 14:46:01');
INSERT INTO `wallets_log` VALUES (71, 7, 3, 'task', 2, 2, 300, 157100, 156800, 'task', 38, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 14:46:27');
INSERT INTO `wallets_log` VALUES (72, 8, 5, 'test', 1, 1, 100, 1380, 1480, 'commission', 38, NULL, NULL, '自动审核通过任务获得佣金，任务ID：38', '2026-03-07 14:58:01');
INSERT INTO `wallets_log` VALUES (73, 7, 3, 'task', 2, 2, 300, 156800, 156500, 'task', 39, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 15:04:27');
INSERT INTO `wallets_log` VALUES (74, 8, 5, 'test', 1, 1, 100, 1480, 1580, 'commission', 39, NULL, NULL, '自动审核通过任务获得佣金，任务ID：39', '2026-03-07 15:21:01');
INSERT INTO `wallets_log` VALUES (75, 7, 3, 'task', 2, 2, 300, 156500, 156200, 'task', 40, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 15:58:47');
INSERT INTO `wallets_log` VALUES (76, 8, 5, 'test', 1, 1, 100, 1580, 1680, 'commission', 40, NULL, NULL, '自动审核通过任务获得佣金，任务ID：40', '2026-03-07 16:09:01');
INSERT INTO `wallets_log` VALUES (77, 7, 3, 'task', 2, 2, 300, 156200, 155900, 'task', 41, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 17:30:09');
INSERT INTO `wallets_log` VALUES (78, 8, 5, 'test', 1, 1, 100, 1680, 1780, 'commission', 41, NULL, NULL, '完成任务获得佣金，任务ID：41', '2026-03-07 17:34:54');
INSERT INTO `wallets_log` VALUES (79, 7, 3, 'task', 2, 2, 300, 155900, 155600, 'task', 42, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 22:53:01');
INSERT INTO `wallets_log` VALUES (80, 8, 5, 'test', 1, 1, 100, 1780, 1880, 'commission', 42, NULL, NULL, '自动审核通过任务获得佣金，任务ID：42', '2026-03-07 23:12:01');
INSERT INTO `wallets_log` VALUES (81, 11, 5, 'Ceshi3', 2, 1, 0, 0, 0, 'recharge', 8, NULL, NULL, '充值 ¥1,000.00（alipay），审核中', '2026-03-08 12:35:07');
INSERT INTO `wallets_log` VALUES (82, 11, 5, 'Ceshi3', 2, 1, 0, 0, 0, 'recharge', 9, NULL, NULL, '充值 ¥1,000.00（alipay），审核中', '2026-03-08 12:44:28');
INSERT INTO `wallets_log` VALUES (83, 11, 5, 'Ceshi3', 2, 1, 100000, 0, 100000, 'recharge', 9, NULL, NULL, '充值到账：¥1,000.00', '2026-03-08 13:01:11');
INSERT INTO `wallets_log` VALUES (84, 2, 2, 'Ceshi1', 2, 2, 600, 206700, 206100, 'task', 43, NULL, NULL, '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-08 13:36:57');
INSERT INTO `wallets_log` VALUES (85, 1, 1, 'Ceshi', 2, 2, 900, 210600, 209700, 'task', 44, NULL, NULL, '发布任务【上评评论】3个任务，扣除 ¥9.00', '2026-03-08 13:38:15');
INSERT INTO `wallets_log` VALUES (86, 2, 2, 'Ceshi1', 2, 2, 500, 206100, 205600, 'task', 4, NULL, NULL, '发布放大镜任务【放大镜搜索词】1个任务，扣除 ¥5.00', '2026-03-08 13:45:14');
INSERT INTO `wallets_log` VALUES (87, 1, 1, 'Ceshi', 2, 2, 600, 209700, 209100, 'task', 45, NULL, NULL, '发布任务【中下评评论】2个任务，扣除 ¥6.00', '2026-03-08 13:46:30');
INSERT INTO `wallets_log` VALUES (88, 8, 5, 'test', 1, 1, 100, 1880, 1980, 'commission', 44, NULL, NULL, '自动审核通过任务获得佣金，任务ID：44', '2026-03-08 14:09:01');
INSERT INTO `wallets_log` VALUES (89, 11, 5, 'Ceshi3', 2, 1, 100000, 100000, 200000, 'recharge', 8, NULL, NULL, '充值到账：¥1,000.00', '2026-03-09 20:33:00');
INSERT INTO `wallets_log` VALUES (90, 7, 3, 'task', 2, 1, 0, 155600, 155600, 'recharge', 10, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-03-09 21:19:27');
INSERT INTO `wallets_log` VALUES (91, 7, 3, 'task', 2, 1, 20000, 155600, 175600, 'recharge', 10, NULL, NULL, '充值到账：¥200.00', '2026-03-09 21:29:10');
INSERT INTO `wallets_log` VALUES (92, 1, 1, 'Ceshi', 2, 2, 900, 209100, 208200, 'task', 47, NULL, NULL, '发布任务【上评评论】3个任务，扣除 ¥9.00', '2026-03-11 11:42:44');
INSERT INTO `wallets_log` VALUES (93, 1, 1, 'Ceshi', 2, 2, 300, 208200, 207900, 'task', 48, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-11 11:57:14');
INSERT INTO `wallets_log` VALUES (94, 1, 1, 'Ceshi', 2, 2, 600, 207900, 207300, 'task', 49, NULL, NULL, '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-11 11:58:24');
INSERT INTO `wallets_log` VALUES (95, 23, 18, 'xiaoya', 1, 1, 100, 0, 100, 'commission', 7, NULL, NULL, '自动审核通过任务获得佣金，任务ID：7', '2026-03-11 12:51:01');
INSERT INTO `wallets_log` VALUES (96, 8, 5, 'test', 1, 1, 50, 1980, 2030, 'agent_commission', 7, NULL, NULL, '下级用户 xiaoya 完成任务，获得一级团长佣金，任务ID：7', '2026-03-11 12:51:01');
INSERT INTO `wallets_log` VALUES (97, 8, 5, 'test', 1, 2, 1000, 2030, 1030, 'withdraw', 1, NULL, NULL, '提现申请 ¥10.00，手续费 ¥0.30，实到 ¥9.70，收款方式：alipay，审核中', '2026-03-11 15:24:50');
INSERT INTO `wallets_log` VALUES (98, 4, 2, 'Ceshi', 1, 1, 100, 0, 100, 'commission', 5, NULL, NULL, '自动审核通过任务获得佣金，任务ID：5', '2026-03-11 15:50:01');
INSERT INTO `wallets_log` VALUES (99, 7, 3, 'task', 2, 2, 300, 175600, 175300, 'task', 50, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-11 15:51:37');
INSERT INTO `wallets_log` VALUES (100, 4, 2, 'Ceshi', 1, 1, 80, 100, 180, 'commission', 6, NULL, NULL, '自动审核通过任务获得佣金，任务ID：6', '2026-03-11 15:59:02');
INSERT INTO `wallets_log` VALUES (101, 4, 2, 'Ceshi', 1, 1, 100, 180, 280, 'commission', 50, NULL, NULL, '自动审核通过任务获得佣金，任务ID：50', '2026-03-11 16:05:02');
INSERT INTO `wallets_log` VALUES (102, 23, 18, 'xiaoya', 1, 1, 80, 100, 180, 'commission', 6, NULL, NULL, '自动审核通过任务获得佣金，任务ID：6', '2026-03-11 17:09:01');
INSERT INTO `wallets_log` VALUES (103, 8, 5, 'test', 1, 1, 30, 1030, 1060, 'agent_commission', 6, NULL, NULL, '下级用户 xiaoya 完成任务，获得一级团长佣金，任务ID：6', '2026-03-11 17:09:01');
INSERT INTO `wallets_log` VALUES (104, 7, 3, 'task', 2, 1, 0, 175300, 175300, 'recharge', 11, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-03-11 22:39:40');
INSERT INTO `wallets_log` VALUES (105, 7, 3, 'task', 2, 1, 0, 175300, 175300, 'recharge', 12, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-03-11 22:59:27');
INSERT INTO `wallets_log` VALUES (106, 7, 3, 'task', 2, 2, 1000, 175300, 174300, 'task', 5, NULL, NULL, '发布放大镜任务【放大镜搜索词】2个任务，扣除 ¥10.00', '2026-03-11 23:56:02');
INSERT INTO `wallets_log` VALUES (107, 7, 3, 'task', 2, 2, 300, 174300, 174000, 'task', 51, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 10:27:10');
INSERT INTO `wallets_log` VALUES (108, 7, 3, 'task', 2, 2, 300, 174000, 173700, 'task', 52, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 10:31:44');
INSERT INTO `wallets_log` VALUES (109, 7, 3, 'task', 2, 2, 300, 173700, 173400, 'task', 53, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 10:31:46');
INSERT INTO `wallets_log` VALUES (110, 7, 3, 'task', 2, 2, 300, 173400, 173100, 'task', 54, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 10:31:49');
INSERT INTO `wallets_log` VALUES (111, 7, 3, 'task', 2, 2, 300, 173100, 172800, 'task', 55, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 10:31:52');
INSERT INTO `wallets_log` VALUES (112, 7, 3, 'task', 2, 2, 300, 172800, 172500, 'task', 56, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 10:32:10');
INSERT INTO `wallets_log` VALUES (113, 8, 5, 'test', 1, 1, 240, 1060, 1300, 'commission', 51, NULL, NULL, '自动审核通过任务获得佣金，任务ID：51', '2026-03-12 10:49:48');
INSERT INTO `wallets_log` VALUES (114, 8, 5, 'test', 1, 1, 240, 1300, 1540, 'commission', 52, NULL, NULL, '自动审核通过任务获得佣金，任务ID：52', '2026-03-12 10:58:39');
INSERT INTO `wallets_log` VALUES (115, 8, 5, 'test', 1, 1, 240, 1540, 1780, 'commission', 53, NULL, NULL, '自动审核通过任务获得佣金，任务ID：53', '2026-03-12 11:07:31');
INSERT INTO `wallets_log` VALUES (116, 8, 5, 'test', 1, 1, 240, 1780, 2020, 'commission', 54, NULL, NULL, '自动审核通过任务获得佣金，任务ID：54', '2026-03-12 11:10:03');
INSERT INTO `wallets_log` VALUES (117, 24, 19, 'test1', 1, 1, 100, 0, 100, 'commission', 55, NULL, NULL, '自动审核通过任务获得佣金，任务ID：55', '2026-03-12 11:19:54');
INSERT INTO `wallets_log` VALUES (118, 8, 5, 'test', 1, 1, 240, 2020, 2260, 'agent_commission', 55, NULL, NULL, '下级用户 test1 完成任务，获得一级团长佣金，任务ID：55', '2026-03-12 11:19:54');
INSERT INTO `wallets_log` VALUES (119, 24, 19, 'test1', 1, 1, 100, 100, 200, 'commission', 56, NULL, NULL, '自动审核通过任务获得佣金，任务ID：56', '2026-03-12 11:26:32');
INSERT INTO `wallets_log` VALUES (120, 8, 5, 'test', 1, 1, 240, 2260, 2500, 'agent_commission', 56, NULL, NULL, '下级用户 test1是大团团长 完成任务，获得一级团长佣金，任务ID：56', '2026-03-12 11:26:32');
INSERT INTO `wallets_log` VALUES (121, 7, 3, 'task', 2, 2, 300, 172500, 172200, 'task', 57, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 11:28:02');
INSERT INTO `wallets_log` VALUES (122, 7, 3, 'task', 2, 2, 300, 172200, 171900, 'task', 58, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 11:28:03');
INSERT INTO `wallets_log` VALUES (123, 7, 3, 'task', 2, 2, 300, 171900, 171600, 'task', 59, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 11:28:05');
INSERT INTO `wallets_log` VALUES (124, 24, 19, 'test1', 1, 1, 100, 200, 300, 'commission', 57, NULL, NULL, '自动审核通过任务获得佣金，任务ID：57', '2026-03-12 11:30:13');
INSERT INTO `wallets_log` VALUES (125, 8, 5, 'test', 1, 1, 240, 2500, 2740, 'agent_commission', 57, NULL, NULL, '下级用户 test1是大团团长 完成任务，获得一级团长佣金，任务ID：57', '2026-03-12 11:30:13');
INSERT INTO `wallets_log` VALUES (126, 30, 25, 'test7', 1, 1, 100, 0, 100, 'commission', 58, NULL, NULL, '自动审核通过任务获得佣金，任务ID：58', '2026-03-12 11:32:04');
INSERT INTO `wallets_log` VALUES (127, 24, 19, 'test1', 1, 1, 50, 300, 350, 'agent_commission', 58, NULL, NULL, '下级用户 test7是普通团长 完成任务，获得普通团长佣金，任务ID：58', '2026-03-12 11:32:04');
INSERT INTO `wallets_log` VALUES (128, 8, 5, 'test', 1, 1, 240, 2740, 2980, 'second_agent_commission', 58, NULL, NULL, '下级用户 test1 的团队成员完成任务，获得二级团长佣金，任务ID：58', '2026-03-12 11:32:04');
INSERT INTO `wallets_log` VALUES (129, 31, 26, 'test8', 1, 1, 100, 0, 100, 'commission', 59, NULL, NULL, '自动审核通过任务获得佣金，任务ID：59', '2026-03-12 11:37:36');
INSERT INTO `wallets_log` VALUES (130, 25, 20, 'test2', 1, 1, 50, 0, 50, 'agent_commission', 59, NULL, NULL, '下级用户 test8是高级团长 完成任务，获得高级团长佣金，任务ID：59', '2026-03-12 11:37:36');
INSERT INTO `wallets_log` VALUES (131, 8, 5, 'test', 1, 1, 240, 2980, 3220, 'second_agent_commission', 59, NULL, NULL, '下级用户 test2 的团队成员完成任务，获得二级团长佣金，任务ID：59', '2026-03-12 11:37:36');
INSERT INTO `wallets_log` VALUES (132, 7, 3, 'task', 2, 2, 300, 171600, 171300, 'task', 60, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 14:31:30');
INSERT INTO `wallets_log` VALUES (133, 32, 27, 'test89', 1, 1, 100, 0, 100, 'commission', 60, NULL, NULL, '自动审核通过任务获得佣金，任务ID：60', '2026-03-12 14:42:45');
INSERT INTO `wallets_log` VALUES (134, 31, 26, 'test8', 1, 1, 50, 100, 150, 'agent_commission', 60, NULL, NULL, '下级用户 test89是普通团长 完成任务，获得普通团长佣金，任务ID：60', '2026-03-12 14:42:45');
INSERT INTO `wallets_log` VALUES (135, 25, 20, 'test2', 1, 1, 50, 50, 100, 'second_agent_commission', 60, NULL, NULL, '下级用户 test8 的团队成员完成任务，获得二级团长佣金，任务ID：60', '2026-03-12 14:42:45');
INSERT INTO `wallets_log` VALUES (136, 7, 3, 'task', 2, 2, 300, 171300, 171000, 'task', 61, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 14:48:57');
INSERT INTO `wallets_log` VALUES (137, 7, 3, 'task', 2, 2, 300, 171000, 170700, 'task', 62, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 14:48:59');
INSERT INTO `wallets_log` VALUES (138, 7, 3, 'task', 2, 2, 300, 170700, 170400, 'task', 63, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 14:49:00');
INSERT INTO `wallets_log` VALUES (139, 7, 3, 'task', 2, 2, 300, 170400, 170100, 'task', 64, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 14:49:01');
INSERT INTO `wallets_log` VALUES (140, 7, 3, 'task', 2, 2, 300, 170100, 169800, 'task', 65, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 14:49:02');
INSERT INTO `wallets_log` VALUES (141, 32, 27, 'test9', 1, 1, 100, 100, 200, 'commission', 61, NULL, NULL, '完成任务获得佣金，任务ID：61', '2026-03-12 14:51:39');
INSERT INTO `wallets_log` VALUES (142, 31, 26, 'test8', 1, 1, 50, 150, 200, 'agent_commission', 61, NULL, NULL, '下级用户 test9 完成任务，获得一级团长佣金，任务ID：61', '2026-03-12 14:51:39');
INSERT INTO `wallets_log` VALUES (143, 25, 20, 'test2', 1, 1, 50, 100, 150, 'second_agent_commission', 61, NULL, NULL, '下级用户 test8 的团队成员完成任务，获得二级团长佣金，任务ID：61', '2026-03-12 14:51:39');
INSERT INTO `wallets_log` VALUES (144, 31, 26, 'test8', 1, 1, 100, 200, 300, 'commission', 62, NULL, NULL, '完成任务获得佣金，任务ID：62', '2026-03-12 14:53:44');
INSERT INTO `wallets_log` VALUES (145, 25, 20, 'test2', 1, 1, 50, 150, 200, 'agent_commission', 62, NULL, NULL, '下级用户 test8 完成任务，获得一级团长佣金，任务ID：62', '2026-03-12 14:53:44');
INSERT INTO `wallets_log` VALUES (146, 8, 5, 'test', 1, 1, 240, 3220, 3460, 'second_agent_commission', 62, NULL, NULL, '下级用户 test2 的团队成员完成任务，获得二级团长佣金，任务ID：62', '2026-03-12 14:53:44');
INSERT INTO `wallets_log` VALUES (147, 25, 20, 'test2', 1, 1, 100, 200, 300, 'commission', 63, NULL, NULL, '完成任务获得佣金，任务ID：63', '2026-03-12 14:55:49');
INSERT INTO `wallets_log` VALUES (148, 8, 5, 'test', 1, 1, 240, 3460, 3700, 'agent_commission', 63, NULL, NULL, '下级用户 test2 完成任务，获得一级团长佣金，任务ID：63', '2026-03-12 14:55:49');
INSERT INTO `wallets_log` VALUES (149, 8, 5, 'test', 1, 1, 240, 3700, 3940, 'commission', 64, NULL, NULL, '完成任务获得佣金，任务ID：64', '2026-03-12 14:59:04');
INSERT INTO `wallets_log` VALUES (150, 8, 5, 'test', 1, 2, 1000, 3940, 2940, 'withdraw', 2, NULL, NULL, '提现申请 ¥10.00，手续费 ¥0.30，实到 ¥9.70，收款方式：alipay，审核中', '2026-03-12 14:59:54');
INSERT INTO `wallets_log` VALUES (151, 25, 20, 'test2', 1, 2, 100, 300, 200, 'withdraw', 3, NULL, NULL, '提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中', '2026-03-12 15:00:49');
INSERT INTO `wallets_log` VALUES (152, 31, 26, 'test8', 1, 2, 100, 300, 200, 'withdraw', 4, NULL, NULL, '提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中', '2026-03-12 15:01:26');
INSERT INTO `wallets_log` VALUES (153, 32, 27, 'test9', 1, 2, 100, 200, 100, 'withdraw', 5, NULL, NULL, '提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中', '2026-03-12 15:48:30');
INSERT INTO `wallets_log` VALUES (154, 8, 5, 'test', 1, 2, 100, 2940, 2840, 'withdraw', 6, NULL, NULL, '提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中', '2026-03-12 15:49:08');
INSERT INTO `wallets_log` VALUES (155, 4, 2, 'Ceshi', 1, 2, 100, 280, 180, 'withdraw', 7, NULL, NULL, '提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中', '2026-03-12 15:49:30');
INSERT INTO `wallets_log` VALUES (156, 7, 3, 'task', 2, 1, 0, 169800, 169800, 'recharge', 13, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-03-12 15:52:31');
INSERT INTO `wallets_log` VALUES (157, 7, 3, 'task', 2, 2, 1000, 169800, 168800, 'task', 6, NULL, NULL, '发布放大镜任务【放大镜搜索词】2个任务，扣除 ¥10.00', '2026-03-12 16:45:26');
INSERT INTO `wallets_log` VALUES (158, 7, 3, 'task', 2, 2, 1000, 168800, 167800, 'task', 7, NULL, NULL, '发布放大镜任务【放大镜搜索词】2个任务，扣除 ¥10.00', '2026-03-12 16:47:08');
INSERT INTO `wallets_log` VALUES (159, 7, 3, 'task', 2, 2, 1000, 167800, 166800, 'task', 8, NULL, NULL, '发布放大镜任务【放大镜搜索词】2个任务，扣除 ¥10.00', '2026-03-13 11:11:22');
INSERT INTO `wallets_log` VALUES (160, 7, 3, 'task', 2, 2, 1000, 166800, 165800, 'task', 9, 3, '放大镜搜索词', '发布放大镜任务【放大镜搜索词】2个任务，扣除 ¥10.00', '2026-03-13 11:13:36');
INSERT INTO `wallets_log` VALUES (161, 7, 3, 'task', 2, 2, 300, 165800, 165500, 'task', 66, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-13 11:14:06');
INSERT INTO `wallets_log` VALUES (162, 31, 26, 'test8', 1, 1, 100, 200, 300, 'commission', 65, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：65', '2026-03-13 11:17:15');
INSERT INTO `wallets_log` VALUES (163, 25, 20, 'test2', 1, 1, 50, 200, 250, 'agent_commission', 65, 1, '上评评论', '下级用户 test8是高级团长 完成任务，获得高级团长佣金，任务ID：65', '2026-03-13 11:17:15');
INSERT INTO `wallets_log` VALUES (164, 8, 5, 'test', 1, 1, 240, 2840, 3080, 'second_agent_commission', 65, 1, '上评评论', '下级用户 test2 的团队成员完成任务，获得二级团长佣金，任务ID：65', '2026-03-13 11:17:15');
INSERT INTO `wallets_log` VALUES (165, 7, 3, 'task', 2, 2, 300, 165500, 165200, 'task', 67, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-13 11:24:10');
INSERT INTO `wallets_log` VALUES (166, 7, 3, 'task', 2, 1, 20000, 165200, 185200, 'recharge', 13, NULL, NULL, '充值到账：¥200.00', '2026-03-13 22:54:19');
INSERT INTO `wallets_log` VALUES (167, 7, 3, 'task', 2, 1, 20000, 185200, 205200, 'recharge', 11, NULL, NULL, '充值到账：¥200.00', '2026-03-13 22:54:20');
INSERT INTO `wallets_log` VALUES (168, 7, 3, 'task', 2, 1, 20000, 205200, 225200, 'recharge', 12, NULL, NULL, '充值到账：¥200.00', '2026-03-13 22:54:22');
INSERT INTO `wallets_log` VALUES (169, 7, 3, 'task', 2, 1, 0, 225200, 225200, 'recharge', 14, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-03-14 16:40:58');
INSERT INTO `wallets_log` VALUES (170, 7, 3, 'task', 2, 1, 20000, 225200, 245200, 'recharge', 14, NULL, NULL, '充值到账：¥200.00', '2026-03-14 16:44:32');
INSERT INTO `wallets_log` VALUES (171, 4, 2, 'Ceshi', 1, 2, 0, 180, 180, 'withdraw', 7, NULL, NULL, '提现审核通过：¥1.00', '2026-03-14 16:56:20');
INSERT INTO `wallets_log` VALUES (172, 8, 5, 'test', 1, 2, 0, 3080, 3080, 'withdraw', 6, NULL, NULL, '提现审核通过：¥1.00', '2026-03-14 16:56:22');
INSERT INTO `wallets_log` VALUES (173, 32, 27, 'test9', 1, 2, 0, 100, 100, 'withdraw', 5, NULL, NULL, '提现审核通过：¥1.00', '2026-03-14 16:56:24');
INSERT INTO `wallets_log` VALUES (174, 31, 26, 'test8', 1, 2, 0, 300, 300, 'withdraw', 4, NULL, NULL, '提现审核通过：¥1.00', '2026-03-14 16:56:26');
INSERT INTO `wallets_log` VALUES (175, 8, 5, 'test', 1, 2, 0, 3080, 3080, 'withdraw', 2, NULL, NULL, '提现审核通过：¥10.00', '2026-03-14 16:56:28');
INSERT INTO `wallets_log` VALUES (176, 25, 20, 'test2', 1, 2, 0, 250, 250, 'withdraw', 3, NULL, NULL, '提现审核通过：¥1.00', '2026-03-14 16:56:30');
INSERT INTO `wallets_log` VALUES (177, 8, 5, 'test', 1, 1, 1000, 3080, 4080, 'withdraw', 1, NULL, NULL, '提现申请被拒绝，退款：¥10.00', '2026-03-14 16:56:50');
INSERT INTO `wallets_log` VALUES (178, 7, 3, 'task', 2, 1, 0, 245200, 245200, 'recharge', 15, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-03-14 20:21:03');
INSERT INTO `wallets_log` VALUES (179, 7, 3, 'task', 2, 2, 300, 245200, 244900, 'task', 68, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-14 20:21:11');
INSERT INTO `wallets_log` VALUES (180, 7, 3, 'task', 2, 2, 600, 244900, 244300, 'task', 69, 2, '中评评论', '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-14 20:22:05');
INSERT INTO `wallets_log` VALUES (181, 7, 3, 'task', 2, 2, 900, 244300, 243400, 'task', 70, 4, '上中评评论', '发布任务【上中评评论】4个任务，扣除 ¥9.00', '2026-03-14 20:22:55');
INSERT INTO `wallets_log` VALUES (182, 7, 3, 'task', 2, 2, 600, 243400, 242800, 'task', 72, 5, '中下评评论', '发布任务【中下评评论】2个任务，扣除 ¥6.00', '2026-03-14 20:23:08');
INSERT INTO `wallets_log` VALUES (183, 7, 3, 'task', 2, 2, 1000, 242800, 241800, 'task', 10, 3, '放大镜搜索词', '发布放大镜任务【放大镜搜索词】2个任务，扣除 ¥10.00', '2026-03-14 20:23:29');
INSERT INTO `wallets_log` VALUES (184, 7, 3, 'task', 2, 2, 35000, 241800, 206800, 'rental_order_pay', 1, 6, '出租订单', '租赁订单支付：测试租赁系统的新功能，佣金结算（7天）', '2026-03-14 20:24:49');
INSERT INTO `wallets_log` VALUES (185, 8, 5, 'test', 1, 2, 0, 0, 0, 'rental_order_pending', 1, 6, '出租订单', '租赁订单已创建，待客服处理：测试租赁系统的新功能，佣金结算（7天，预计收益：24500）', '2026-03-14 20:24:49');
INSERT INTO `wallets_log` VALUES (186, 7, 3, 'task', 2, 1, 20000, 206800, 226800, 'recharge', 15, NULL, NULL, '充值到账：¥200.00', '2026-03-14 20:25:32');
INSERT INTO `wallets_log` VALUES (187, 8, 5, 'test', 1, 1, 240, 4080, 4320, 'commission', 66, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：66', '2026-03-14 21:07:06');
INSERT INTO `wallets_log` VALUES (188, 8, 5, 'test', 1, 1, 240, 4320, 4560, 'commission', 67, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：67', '2026-03-14 21:09:08');
INSERT INTO `wallets_log` VALUES (189, 8, 5, 'test', 1, 1, 240, 4560, 4800, 'commission', 68, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：68', '2026-03-14 21:09:08');
INSERT INTO `wallets_log` VALUES (190, 8, 5, 'test', 1, 1, 160, 4800, 4960, 'commission', 69, 2, '中评评论', '自动审核通过任务获得佣金，任务ID：69', '2026-03-14 21:09:08');
INSERT INTO `wallets_log` VALUES (191, 8, 5, 'test', 1, 1, 240, 4960, 5200, 'commission', 70, 4, '上中评评论', '自动审核通过任务获得佣金，任务ID：70', '2026-03-14 21:09:08');
INSERT INTO `wallets_log` VALUES (192, 8, 5, 'test', 1, 1, 240, 5200, 5440, 'commission', 72, 5, '中下评评论', '自动审核通过任务获得佣金，任务ID：72', '2026-03-14 21:09:08');
INSERT INTO `wallets_log` VALUES (193, 8, 5, 'test', 1, 2, 1000, 5440, 4440, 'withdraw', 0, NULL, NULL, '提现申请 ¥10.00，手续费 ¥0.30，实到 ¥9.70，收款方式：alipay，审核中', '2026-03-14 21:12:40');
INSERT INTO `wallets_log` VALUES (194, 7, 3, 'task', 2, 2, 300, 226800, 226500, 'task', 74, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-14 21:19:09');
INSERT INTO `wallets_log` VALUES (195, 8, 5, 'test', 1, 1, 240, 4440, 4680, 'commission', 74, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：74', '2026-03-14 21:21:07');
INSERT INTO `wallets_log` VALUES (196, 7, 3, 'task', 2, 2, 300, 226500, 226200, 'task', 75, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-14 21:21:45');
INSERT INTO `wallets_log` VALUES (197, 31, 26, 'test8', 1, 1, 100, 300, 400, 'commission', 75, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：75', '2026-03-14 21:24:48');
INSERT INTO `wallets_log` VALUES (198, 25, 20, 'test2', 1, 1, 50, 250, 300, 'agent_commission', 75, 1, '上评评论', '下级用户 test8是高级团长 完成任务，获得高级团长佣金，任务ID：75', '2026-03-14 21:24:48');
INSERT INTO `wallets_log` VALUES (199, 8, 5, 'test', 1, 1, 240, 4680, 4920, 'second_agent_commission', 75, 1, '上评评论', '下级用户 test2 的团队成员完成任务，获得二级团长佣金，任务ID：75', '2026-03-14 21:24:48');
INSERT INTO `wallets_log` VALUES (200, 8, 5, 'test', 1, 2, 0, 4920, 4920, 'withdraw', 8, NULL, NULL, '提现审核通过：¥10.00', '2026-03-14 21:30:25');
INSERT INTO `wallets_log` VALUES (201, 8, 5, 'test', 1, 2, 300, 4920, 4620, 'withdraw', 0, NULL, NULL, '提现申请 ¥3.00，手续费 ¥0.09，实到 ¥2.91，收款方式：alipay，审核中', '2026-03-14 21:35:04');
INSERT INTO `wallets_log` VALUES (202, 8, 5, 'test', 1, 1, 24500, 4620, 29120, 'rental_order_settlement', 1, NULL, NULL, '租赁订单结算收益（订单#1）', '2026-03-14 21:40:59');
INSERT INTO `wallets_log` VALUES (203, 8, 5, 'test', 1, 2, 0, 29120, 29120, 'withdraw', 9, NULL, NULL, '提现审核通过：¥3.00', '2026-03-14 22:18:13');
INSERT INTO `wallets_log` VALUES (204, 7, 3, 'task', 2, 2, 30000, 226200, 196200, 'rental_freeze', 6, NULL, NULL, '求租信息冻结预算（2000分/天×15天）：测试求租发布', '2026-03-14 22:20:28');
INSERT INTO `wallets_log` VALUES (205, 7, 3, 'task', 2, 2, 25000, 196200, 171200, 'rental_order_pay', 2, 6, '出租订单', '租赁订单支付：测试租赁系统的新功能，佣金结算（5天）', '2026-03-14 22:23:22');
INSERT INTO `wallets_log` VALUES (206, 31, 26, 'test8', 1, 2, 0, 0, 0, 'rental_order_pending', 2, 6, '出租订单', '租赁订单已创建，待客服处理：测试租赁系统的新功能，佣金结算（5天，预计收益：17500）', '2026-03-14 22:23:22');
INSERT INTO `wallets_log` VALUES (207, 5, 3, 'Ceshi2', 2, 2, 0, 0, 0, 'rental_order_pay', 3, NULL, NULL, '求租订单已创建：测试求租发布（冻结金额转入订单：2000）', '2026-03-14 22:24:31');
INSERT INTO `wallets_log` VALUES (208, 31, 26, 'test8', 1, 2, 0, 0, 0, 'rental_order_pending', 3, NULL, NULL, '租赁订单已创建，待客服处理：测试求租发布（预计收益：1400）', '2026-03-14 22:24:31');
INSERT INTO `wallets_log` VALUES (209, 31, 26, 'test8', 1, 1, 17500, 400, 17900, 'rental_order_settlement', 2, NULL, NULL, '租赁订单结算收益（订单#2）', '2026-03-14 22:31:31');
INSERT INTO `wallets_log` VALUES (210, 25, 20, 'test2', 1, 1, 1250, 300, 1550, 'rental_agent_commission', 2, NULL, NULL, '租赁订单团长佣金（订单#2）', '2026-03-14 22:31:31');
INSERT INTO `wallets_log` VALUES (211, 31, 26, 'test8', 1, 1, 1400, 17900, 19300, 'rental_order_settlement', 3, NULL, NULL, '租赁订单结算收益（订单#3）', '2026-03-14 22:33:28');
INSERT INTO `wallets_log` VALUES (212, 25, 20, 'test2', 1, 1, 100, 1550, 1650, 'rental_agent_commission', 3, NULL, NULL, '租赁订单团长佣金（订单#3）', '2026-03-14 22:33:28');

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
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '提现申请表-需要管理员审核' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of withdraw_requests
-- ----------------------------
INSERT INTO `withdraw_requests` VALUES (1, 5, 'test', 1, 8, 1000, 0.0300, 30, 970, 'alipay', '15900000000', '张三', 97, 2, '测试拒绝的交易记录', NULL, NULL, '2026-03-14 16:56:50', '2026-03-11 15:24:50');
INSERT INTO `withdraw_requests` VALUES (2, 5, 'test', 1, 8, 1000, 0.0300, 30, 970, 'alipay', '15900000001', '张三', 150, 1, NULL, '', NULL, '2026-03-14 16:56:28', '2026-03-12 14:59:54');
INSERT INTO `withdraw_requests` VALUES (3, 20, 'test2', 1, 25, 100, 0.0300, 3, 97, 'alipay', '15900000001', '张三', 151, 1, NULL, '', NULL, '2026-03-14 16:56:30', '2026-03-12 15:00:49');
INSERT INTO `withdraw_requests` VALUES (4, 26, 'test8', 1, 31, 100, 0.0300, 3, 97, 'alipay', '15900000001', '张三', 152, 1, NULL, '', NULL, '2026-03-14 16:56:26', '2026-03-12 15:01:26');
INSERT INTO `withdraw_requests` VALUES (5, 27, 'test9', 1, 32, 100, 0.0300, 3, 97, 'alipay', '15900000001', '张三', 153, 1, NULL, '', NULL, '2026-03-14 16:56:24', '2026-03-12 15:48:30');
INSERT INTO `withdraw_requests` VALUES (6, 5, 'test', 1, 8, 100, 0.0300, 3, 97, 'alipay', '15900000001', '张三', 154, 1, NULL, '', NULL, '2026-03-14 16:56:22', '2026-03-12 15:49:08');
INSERT INTO `withdraw_requests` VALUES (7, 2, 'Ceshi', 1, 4, 100, 0.0300, 3, 97, 'alipay', '15900000001', '张三', 155, 1, NULL, '', NULL, '2026-03-14 16:56:20', '2026-03-12 15:49:30');
INSERT INTO `withdraw_requests` VALUES (8, 5, 'test', 1, 8, 1000, 0.0300, 30, 970, 'alipay', '15900000001', '张三', 27, 1, NULL, '', NULL, '2026-03-14 21:30:25', '2026-03-14 21:12:40');
INSERT INTO `withdraw_requests` VALUES (9, 5, 'test', 1, 8, 300, 0.0300, 9, 291, 'alipay', '15900000001', '张三', 33, 1, NULL, 'https://api.kktaskpaas.com/img/f38757d726a112f8181ec05fa8a9570a.jpg', NULL, '2026-03-14 22:18:13', '2026-03-14 21:35:04');

SET FOREIGN_KEY_CHECKS = 1;
