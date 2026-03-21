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

 Date: 21/03/2026 16:56:26
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
) ENGINE = InnoDB AUTO_INCREMENT = 762 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '放大镜任务数量记录表' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `admin_system_notification_magnifier_count` VALUES (712, 0, 0, '2026-03-14 22:47:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (713, 0, 0, '2026-03-14 22:48:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (714, 0, 0, '2026-03-14 22:49:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (715, 0, 0, '2026-03-14 22:50:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (716, 0, 0, '2026-03-14 22:51:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (717, 0, 0, '2026-03-14 22:52:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (718, 0, 0, '2026-03-14 22:53:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (719, 0, 0, '2026-03-14 22:54:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (720, 0, 0, '2026-03-14 22:55:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (721, 0, 0, '2026-03-14 22:56:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (722, 0, 0, '2026-03-14 22:57:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (723, 0, 0, '2026-03-14 22:58:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (724, 0, 0, '2026-03-14 22:59:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (725, 0, 0, '2026-03-14 23:00:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (726, 0, 0, '2026-03-14 23:01:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (727, 0, 0, '2026-03-14 23:02:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (728, 0, 0, '2026-03-14 23:03:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (729, 0, 0, '2026-03-14 23:04:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (730, 0, 0, '2026-03-14 23:05:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (731, 0, 0, '2026-03-14 23:06:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (732, 0, 0, '2026-03-14 23:07:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (733, 0, 0, '2026-03-14 23:08:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (734, 0, 0, '2026-03-14 23:09:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (735, 0, 0, '2026-03-14 23:10:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (736, 0, 0, '2026-03-14 23:11:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (737, 0, 0, '2026-03-14 23:12:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (738, 0, 0, '2026-03-14 23:13:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (739, 0, 0, '2026-03-14 23:14:49', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (740, 0, 0, '2026-03-14 23:14:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (741, 0, 0, '2026-03-14 23:15:53', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (742, 0, 0, '2026-03-14 23:16:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (743, 0, 0, '2026-03-14 23:17:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (744, 0, 0, '2026-03-14 23:18:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (745, 0, 0, '2026-03-14 23:19:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (746, 0, 0, '2026-03-14 23:20:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (747, 0, 0, '2026-03-14 23:21:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (748, 0, 0, '2026-03-14 23:22:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (749, 0, 0, '2026-03-14 23:23:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (750, 0, 0, '2026-03-14 23:24:53', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (751, 0, 0, '2026-03-14 23:25:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (752, 0, 0, '2026-03-14 23:26:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (753, 0, 0, '2026-03-14 23:27:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (754, 0, 0, '2026-03-14 23:28:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (755, 0, 0, '2026-03-14 23:29:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (756, 0, 0, '2026-03-14 23:30:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (757, 0, 0, '2026-03-14 23:31:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (758, 0, 0, '2026-03-14 23:32:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (759, 0, 0, '2026-03-14 23:33:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (760, 0, 0, '2026-03-14 23:34:52', 0);
INSERT INTO `admin_system_notification_magnifier_count` VALUES (761, 0, 0, '2026-03-14 23:35:53', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '团长申请表-C端用户申请成为团长' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 44 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '网站配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of app_config
-- ----------------------------
INSERT INTO `app_config` VALUES (1, 'website', 'https://api.kktaskpaas.com/', 'string', 'general', '网站地址', '2026-02-28 21:29:30');
INSERT INTO `app_config` VALUES (2, 'upload_path', './img', 'string', 'general', '上传文件路径', '2026-02-15 14:51:56');
INSERT INTO `app_config` VALUES (3, 'platform_fee_rate', '0.25', 'float', 'general', '平台抽成比例（0.25 = 25%）', '2026-02-15 14:51:56');
INSERT INTO `app_config` VALUES (4, 'task_submit_timeout', '3600', 'int', 'task', '任务提交超时时间（秒）', '2026-03-18 14:02:48');
INSERT INTO `app_config` VALUES (7, 'c_withdraw_min_amount', '1', 'int', 'withdraw', 'C端每次提现最低金额（元）', '2026-02-23 20:53:03');
INSERT INTO `app_config` VALUES (8, 'c_withdraw_max_amount', '500', 'int', 'withdraw', 'C端每次提现最高金额（元）', '2026-02-15 14:51:56');
INSERT INTO `app_config` VALUES (9, 'c_withdraw_amount_multiple', '1', 'int', 'withdraw', 'C端提现金额必须是此数的整数倍', '2026-02-23 20:53:12');
INSERT INTO `app_config` VALUES (10, 'c_withdraw_daily_limit', '1000', 'int', 'withdraw', 'C端每天提现总额限制（元）', '2026-02-15 14:51:56');
INSERT INTO `app_config` VALUES (11, 'c_withdraw_allowed_weekdays', '1-2-3-4-5-6-0', 'array', 'withdraw', '允许提现的星期几（0=周日,1-6=周一至周六，多个用逗号分隔）', '2026-03-15 00:20:12');
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
INSERT INTO `app_config` VALUES (43, 'normal_user_commission_ratio', '0.1', 'float', 'general', '普通用户团队收益比例（默认10%）', '2026-03-18 17:28:44');

-- ----------------------------
-- Table structure for b_newbie_tasks
-- ----------------------------
DROP TABLE IF EXISTS `b_newbie_tasks`;
CREATE TABLE `b_newbie_tasks`  (
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
) ENGINE = InnoDB AUTO_INCREMENT = 221 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端发布任务表-商家派单' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of b_newbie_tasks
-- ----------------------------

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
  `record_status` tinyint UNSIGNED NULL DEFAULT 0 COMMENT '记录状态：0=待处理，1=进行中，2=待审核，3=已完成，4=待支付,5=已过期,6=已驳回,7=已暂停，8=已取消，9=已退款,10=已支付',
  `record_status_text` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '记录状态文本',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '流水的详细说明记录',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_b_user_id`(`b_user_id` ASC) USING BTREE,
  INDEX `idx_flow_type`(`flow_type` ASC) USING BTREE,
  INDEX `idx_related`(`related_type` ASC, `related_id` ASC) USING BTREE,
  INDEX `idx_task_types`(`task_types` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 106 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端任务统计表-记录B端用户所有金额变动' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of b_task_statistics
-- ----------------------------
INSERT INTO `b_task_statistics` VALUES (101, 8, 'task', 1, 20000, 0, 0, 'recharge', 0, NULL, NULL, 2, '充值申请记录，当前状态待审核', '充值 ¥200.00（alipay），审核中', '2026-03-21 14:36:51');
INSERT INTO `b_task_statistics` VALUES (102, 8, 'task', 1, 20000, 0, 20000, 'recharge', 19, NULL, NULL, 3, '充值审核记录，当前状态已审核通过，已完成', '充值到账：¥200.00', '2026-03-21 14:37:14');
INSERT INTO `b_task_statistics` VALUES (103, 8, 'task', 2, 600, 20000, 19400, 'task_publish', 218, 2, '中评评论', 0, '任务发布记录，当前状态已发布，待领取', '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-21 14:43:12');
INSERT INTO `b_task_statistics` VALUES (104, 8, 'task', 2, 600, 19400, 18800, 'task_publish', 219, 2, '中评评论', 0, '任务发布记录，当前状态已发布，待领取', '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-21 15:01:42');
INSERT INTO `b_task_statistics` VALUES (105, 8, 'task', 2, 600, 18800, 18200, 'task_publish', 220, 2, '中评评论', 0, '任务发布记录，当前状态已发布，待领取', '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-21 15:13:47');

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
) ENGINE = InnoDB AUTO_INCREMENT = 221 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端发布任务表-商家派单' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of b_tasks
-- ----------------------------
INSERT INTO `b_tasks` VALUES (218, 8, NULL, 0, 1, NULL, 2, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}, {\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}, {\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 3, 0, 0, 0, 2.00, 6.00, 1, '2026-03-21 14:43:12', '2026-03-21 14:43:12', NULL);
INSERT INTO `b_tasks` VALUES (219, 8, NULL, 0, 1, NULL, 2, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}, {\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}, {\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 3, 0, 0, 0, 2.00, 6.00, 1, '2026-03-21 15:01:42', '2026-03-21 15:01:42', NULL);
INSERT INTO `b_tasks` VALUES (220, 8, NULL, 0, 1, NULL, 2, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1796058061, '[{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}, {\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}, {\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}]', 3, 0, 1, 1, 2.00, 6.00, 1, '2026-03-21 15:13:47', '2026-03-21 15:25:52', NULL);

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
  `wallet_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '关联钱包ID',
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
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端用户表-商家端' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of b_users
-- ----------------------------
INSERT INTO `b_users` VALUES (8, 'task', 'task@qq.com', NULL, '$2y$12$97VWJscwBK3xd/l1BM468.LpXgoa68yhaHgUjR/n9Nhvplu.4SQgC', '小白团队', 'xiaobai', 'eyJ1c2VyX2lkIjo4LCJ0eXBlIjoyLCJleHAiOjE3NzQ2Nzk3MTd9', '2026-03-28 14:35:17', 56, 1, NULL, '127.0.0.1', '2026-03-21 14:34:12', '2026-03-21 14:35:18', '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-21 14:35:17\",\"last_activity\":\"2026-03-21 14:35:17\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-21 14:35:17\",\"last_activity\":\"2026-03-21 14:35:17\"}]');

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
  `task_stage` tinyint NULL DEFAULT NULL COMMENT '当前任务阶段，0=单任务，1=1阶段，2=2阶段',
  `task_stage_text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前任务阶段的文本',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_c_user_b_task`(`c_user_id` ASC, `b_task_id` ASC) USING BTREE,
  INDEX `idx_c_user_id`(`c_user_id` ASC) USING BTREE,
  INDEX `idx_b_task_id`(`b_task_id` ASC) USING BTREE,
  INDEX `idx_b_user_id`(`b_user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 96 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端任务记录表-接单执行审核全流程' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of c_task_records
-- ----------------------------
INSERT INTO `c_task_records` VALUES (94, 127, 220, 8, 2, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"http:\\/\\/134.122.136.221:4667\\/img\\/a9b76843e779d5727ecf6b4269287206.jpg\"]', 2, NULL, 100, '2026-03-21 15:21:18', '2026-03-21 15:21:33', NULL, 0, '中评评论');
INSERT INTO `c_task_records` VALUES (95, 128, 220, 8, 2, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试大团团长的任务奖励和佣金\", \"image_url\": \"\"}', NULL, NULL, 1, NULL, 100, '2026-03-21 15:25:52', NULL, NULL, 0, '中评评论');

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
  `related_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关联类型：task_publish=任务发布，recharge=充值，account_rental=账号租赁，refund=退款，agent_commission=一级代理佣金，second_agent_commission=二级代理佣金',
  `related_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '关联ID（任务ID、订单ID等）',
  `task_types` tinyint UNSIGNED NULL DEFAULT NULL COMMENT '任务类型：1=上评评论，2=中评评论，3=放大镜搜索词，4=上中评评论，5=中下评评论，6=出租订单，7=求租订单',
  `task_types_text` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务类型文本描述',
  `record_status` tinyint UNSIGNED NULL DEFAULT 0 COMMENT '记录状态：0=待处理，1=进行中，2=待审核，3=已完成，4=待支付,5=已过期,6=已驳回,7=已暂停，8=已取消，9=已退款,10=已支付',
  `record_status_text` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '记录状态文本',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '流水的详细说明记录',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `task_stage` tinyint NULL DEFAULT NULL COMMENT '当前任务所处阶段：0=单任务，1=1阶段，2=2阶段',
  `task_stage_text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前任务所处阶段文本。',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_c_user_id`(`c_user_id` ASC) USING BTREE,
  INDEX `idx_flow_type`(`flow_type` ASC) USING BTREE,
  INDEX `idx_related`(`related_type` ASC, `related_id` ASC) USING BTREE,
  INDEX `idx_task_types`(`task_types` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 121 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端任务统计表-记录C端用户所有金额变动' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of c_task_statistics
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'C端用户代理等级跃迁历史表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of c_user_agent_upgrade_history
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 34 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端用户每日统计表-限制驳回次数' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of c_user_daily_stats
-- ----------------------------
INSERT INTO `c_user_daily_stats` VALUES (32, 127, '2026-03-21', 1, 1, 0, 0, '2026-03-21 15:21:12', '2026-03-21 15:21:33');
INSERT INTO `c_user_daily_stats` VALUES (33, 128, '2026-03-21', 1, 0, 0, 0, '2026-03-21 15:25:52', '2026-03-21 15:25:52');

-- ----------------------------
-- Table structure for c_user_relations
-- ----------------------------
DROP TABLE IF EXISTS `c_user_relations`;
CREATE TABLE `c_user_relations`  (
  `id` int(10) UNSIGNED ZEROFILL NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '被邀请人ID（当前注册用户）',
  `agent_id` bigint UNSIGNED NOT NULL COMMENT '上级代理ID（邀请码用户,代理等级分直接、间接）',
  `level` tinyint NOT NULL COMMENT '1=一级代理（直接上级）, 2=二级代理（间接上级）',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `unique_user_agent`(`user_id` ASC, `agent_id` ASC, `level` ASC) USING BTREE,
  INDEX `agent_id`(`agent_id` ASC) USING BTREE,
  CONSTRAINT `c_user_relations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `c_users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `c_user_relations_ibfk_2` FOREIGN KEY (`agent_id`) REFERENCES `c_users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 123 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '一级邀请二级邀请关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of c_user_relations
-- ----------------------------
INSERT INTO `c_user_relations` VALUES (0000000001, 6, 5, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000002, 18, 5, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000003, 19, 18, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000004, 20, 5, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000005, 21, 23, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000006, 22, 5, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000007, 23, 5, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000008, 24, 5, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000009, 25, 22, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000010, 26, 22, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000011, 27, 22, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000012, 28, 26, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000013, 29, 26, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000014, 30, 26, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000015, 31, 26, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000016, 32, 5, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000017, 33, 26, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000018, 34, 5, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000019, 35, 22, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000020, 36, 26, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000021, 37, 23, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000022, 38, 23, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000023, 39, 23, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000024, 40, 26, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000025, 41, 26, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000026, 42, 22, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000027, 43, 42, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000028, 44, 42, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000029, 45, 42, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000030, 46, 42, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000031, 47, 42, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000032, 48, 42, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000033, 49, 5, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000034, 50, 42, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000035, 51, 42, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000036, 52, 35, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000037, 53, 35, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000038, 54, 42, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000039, 55, 35, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000040, 56, 55, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000041, 57, 35, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000042, 58, 35, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000043, 59, 42, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000044, 60, 35, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000045, 61, 26, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000046, 62, 35, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000047, 63, 35, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000048, 64, 26, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000049, 65, 42, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000050, 66, 42, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000051, 67, 35, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000052, 68, 42, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000053, 69, 18, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000054, 70, 18, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000055, 71, 27, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000056, 72, 26, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000057, 73, 35, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000058, 74, 22, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000059, 75, 26, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000060, 76, 27, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000061, 77, 76, 1, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000062, 6, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000063, 18, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000064, 19, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000065, 20, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000066, 21, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000067, 22, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000068, 23, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000069, 24, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000070, 25, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000071, 26, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000072, 27, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000073, 28, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000074, 29, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000075, 30, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000076, 31, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000077, 32, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000078, 33, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000079, 34, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000080, 35, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000081, 36, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000082, 37, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000083, 38, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000084, 39, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000085, 40, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000086, 41, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000087, 42, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000088, 43, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000089, 44, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000090, 45, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000091, 46, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000092, 47, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000093, 48, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000094, 49, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000095, 50, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000096, 51, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000097, 52, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000098, 53, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000099, 54, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000100, 55, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000101, 56, 35, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000102, 57, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000103, 58, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000104, 59, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000105, 60, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000106, 61, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000107, 62, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000108, 63, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000109, 64, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000110, 65, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000111, 66, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000112, 67, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000113, 68, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000114, 69, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000115, 70, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000116, 71, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000117, 72, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000118, 73, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000119, 74, 5, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000120, 75, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000121, 76, 22, 2, '2026-03-21 13:02:00');
INSERT INTO `c_user_relations` VALUES (0000000122, 77, 27, 2, '2026-03-21 13:02:00');

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
  `parent_username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '上级用户名',
  `is_agent` tinyint NOT NULL DEFAULT 0 COMMENT '代理身份：0=普通用户，1=普通团长，2=高级团长，3=大团团长',
  `token` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前有效Token（base64格式）',
  `token_expired_at` datetime NULL DEFAULT NULL COMMENT 'Token过期时间',
  `wallet_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '关联钱包ID',
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
) ENGINE = InnoDB AUTO_INCREMENT = 129 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端用户表-消费者端' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of c_users
-- ----------------------------
INSERT INTO `c_users` VALUES (1, 'taskadmin', 'taskadmin@qq.com', NULL, '$2y$10$9gww7TqOTzSA9SqchkFEgeYftRKlJ4ciYWL6IiD8DPUbQv8/PnCGe', 'W6XMFJ', NULL, NULL, 0, 'eyJ1c2VyX2lkIjoxLCJ0eXBlIjoxLCJleHAiOjE3NzI3NzM1OTN9', '2026-03-06 13:06:33', 3, 1, NULL, '120.237.23.202', '2026-02-27 13:06:22', '2026-02-27 13:06:33', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (2, 'Ceshi', '12345678@qq.com', '13112345678', '$2y$10$hkD.XBnEsk7iKbrYdpuxyOmrn.vME26Z1gzkXkBEXaUQMey5b3MAm', '6YHUBA', NULL, NULL, 0, 'eyJ1c2VyX2lkIjoyLCJ0eXBlIjoxLCJleHAiOjE3NzQxNTk0Mzh9', '2026-03-22 14:03:58', 4, 1, NULL, '34.143.229.197', '2026-02-27 17:24:33', '2026-03-15 14:03:58', 0, NULL, NULL, NULL, '35aa9b33da8a7c5e4f350928f43ad299', 'Win32 Mozilla/5.0', 1, '{\"device_id\":\"35aa9b33da8a7c5e4f350928f43ad299\",\"device_name\":\"Win32 Mozilla/5.0\",\"login_time\":\"2026-03-15 14:03:58\",\"last_activity\":\"2026-03-15 14:03:58\"}', '[{\"device_id\":\"35aa9b33da8a7c5e4f350928f43ad299\",\"device_name\":\"Win32 Mozilla/5.0\",\"login_time\":\"2026-03-15 14:03:58\",\"last_activity\":\"2026-03-15 14:03:58\"}]');
INSERT INTO `c_users` VALUES (3, 'Ceshi2', '123456789@qq.com', '13212345678', '$2y$10$Cvl7CIY5Oj2gPcKSvNE2mONLRs14Rr1ndstVn2FHJlco8GmXxS586', 'MCVFM9', NULL, NULL, 0, 'eyJ1c2VyX2lkIjozLCJ0eXBlIjoxLCJleHAiOjE3NzI3OTMxODh9', '2026-03-06 18:33:08', 5, 1, NULL, '34.143.229.197', '2026-02-27 17:26:28', '2026-02-27 18:33:08', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (4, 'Ceshi3', '123455677@qq.com', '13312345678', '$2y$10$qydW3B1EXlxJou5CUfPMaOvssOD/K8GugvQh.BeeX/KGBpPGC3awq', 'CZBBF5', NULL, NULL, 0, 'eyJ1c2VyX2lkIjo0LCJ0eXBlIjoxLCJleHAiOjE3NzI3ODk0Njh9', '2026-03-06 17:31:08', 6, 1, NULL, '34.143.229.197', '2026-02-27 17:31:08', '2026-02-27 17:31:08', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (5, 'test', 'test@qq.com', '15900000011', '$2y$10$hkD.XBnEsk7iKbrYdpuxyOmrn.vME26Z1gzkXkBEXaUQMey5b3MAm', 'TX5ECJ', NULL, NULL, 2, NULL, NULL, 8, 1, NULL, '223.74.60.135', '2026-03-01 00:53:23', '2026-03-21 10:08:37', 0, NULL, NULL, NULL, '35aa9b33da8a7c5e4f350928f43ad299', 'Win32 Mozilla/5.0', 1, '{\"device_id\":\"35aa9b33da8a7c5e4f350928f43ad299\",\"device_name\":\"Win32 Mozilla/5.0\",\"login_time\":\"2026-03-21 10:07:42\",\"last_activity\":\"2026-03-21 10:07:42\"}', '[{\"device_id\":\"35aa9b33da8a7c5e4f350928f43ad299\",\"device_name\":\"Win32 Mozilla/5.0\",\"login_time\":\"2026-03-21 10:07:42\",\"last_activity\":\"2026-03-21 10:07:42\"}]');
INSERT INTO `c_users` VALUES (6, 'tasktest', '', '13794719208', '$2y$10$hkD.XBnEsk7iKbrYdpuxyOmrn.vME26Z1gzkXkBEXaUQMey5b3MAm', 'Z2AYEM', 5, NULL, 2, 'eyJ1c2VyX2lkIjo2LCJ0eXBlIjoxLCJleHAiOjE3NzQxMTAxMDF9', '2026-03-22 00:21:41', 9, 1, NULL, '223.74.60.135', '2026-03-02 00:12:06', '2026-03-15 00:21:41', 0, NULL, NULL, NULL, 'f989d1cf067071e57e5afa61e6587acc', 'Win32 Mozilla/5.0', 1, '{\"device_id\":\"f989d1cf067071e57e5afa61e6587acc\",\"device_name\":\"Win32 Mozilla/5.0\",\"login_time\":\"2026-03-15 00:21:41\",\"last_activity\":\"2026-03-15 00:21:41\"}', '[{\"device_id\":\"f989d1cf067071e57e5afa61e6587acc\",\"device_name\":\"Win32 Mozilla/5.0\",\"login_time\":\"2026-03-15 00:21:41\",\"last_activity\":\"2026-03-15 00:21:41\"}]');
INSERT INTO `c_users` VALUES (18, 'xiaoya', NULL, '13049610316', '$2y$10$s1KchbOeEqAqEGP1DjV15O4ZLf5yOKvNAE0.yphtXxvtwNo0Z6upG', 'KZPAUU', 5, NULL, 3, 'eyJ1c2VyX2lkIjoxOCwidHlwZSI6MSwiZXhwIjoxNzc0NDI1NTY0fQ==', '2026-03-25 15:59:24', 23, 1, NULL, '223.74.60.185', '2026-03-11 12:23:27', '2026-03-18 15:59:24', 0, NULL, NULL, NULL, 'd4bdb37a26509bbc496ede416e5756cc', 'Win32 Mozilla/5.0', 1, '{\"device_id\":\"d4bdb37a26509bbc496ede416e5756cc\",\"device_name\":\"Win32 Mozilla/5.0\",\"login_time\":\"2026-03-18 15:59:24\",\"last_activity\":\"2026-03-18 15:59:24\"}', '[{\"device_id\":\"d4bdb37a26509bbc496ede416e5756cc\",\"device_name\":\"Win32 Mozilla/5.0\",\"login_time\":\"2026-03-18 15:59:24\",\"last_activity\":\"2026-03-18 15:59:24\"}]');
INSERT INTO `c_users` VALUES (19, 'Kenwan', 'null@qq.com', '13257620552', '$2y$10$CH2SlVv03LLAM75gqjtHyOXjhqa3KYePjrarJm9EbMN4BqwaSfPSS', 'H8P2UG', 18, NULL, 0, 'eyJ1c2VyX2lkIjoxOSwidHlwZSI6MSwiZXhwIjoxNzc0MTU4NTU5fQ==', '2026-03-22 13:49:19', 24, 1, NULL, '34.143.229.197', '2026-03-13 12:47:21', '2026-03-15 13:49:19', 0, NULL, NULL, NULL, 'f5b3907aa145671fab0e3be584658d45', 'Win32 Mozilla/5.0', 1, '{\"device_id\":\"f5b3907aa145671fab0e3be584658d45\",\"device_name\":\"Win32 Mozilla/5.0\",\"login_time\":\"2026-03-15 13:49:19\",\"last_activity\":\"2026-03-15 13:49:19\"}', '[{\"device_id\":\"f5b3907aa145671fab0e3be584658d45\",\"device_name\":\"Win32 Mozilla/5.0\",\"login_time\":\"2026-03-15 13:49:19\",\"last_activity\":\"2026-03-15 13:49:19\"}]');
INSERT INTO `c_users` VALUES (20, '716716888', NULL, '17888643125', '$2y$10$aXFU.lAniJe8.z.kkuipVOrY0ANjku.pWnrkPSdH3rRMohQhRaeAC', 'BTKW7A', 5, NULL, 0, 'eyJ1c2VyX2lkIjoyMCwidHlwZSI6MSwiZXhwIjoxNzc0MTU0NjkzfQ==', '2026-03-22 12:44:53', 25, 1, NULL, '34.143.229.197', '2026-03-15 12:42:31', '2026-03-15 12:44:53', 0, NULL, NULL, NULL, '64825d714400faca673529a3a42d6c68', 'iPhone', 1, '{\"device_id\":\"64825d714400faca673529a3a42d6c68\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-15 12:44:53\",\"last_activity\":\"2026-03-15 12:44:53\"}', '[{\"device_id\":\"64825d714400faca673529a3a42d6c68\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-15 12:44:53\",\"last_activity\":\"2026-03-15 12:44:53\"}]');
INSERT INTO `c_users` VALUES (21, 'LF0730', NULL, '15073009153', '$2y$10$Md/wGNlek9OCSMNT2aAsMeXZPdMtEWIHGWQYkViCQmM5gZ/YkOacu', 'K9mPx2', 23, NULL, 0, 'eyJ1c2VyX2lkIjoyMSwidHlwZSI6MSwiZXhwIjoxNzc0NDk5MzY4fQ==', '2026-03-26 12:29:28', 27, 1, NULL, '34.143.229.197', '2026-03-15 13:52:44', '2026-03-19 12:29:28', 0, NULL, NULL, NULL, '2eb3df2e815b5b652db08c1395f5ae55', 'zh-cn', 1, '{\"device_id\":\"2eb3df2e815b5b652db08c1395f5ae55\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-19 12:29:28\",\"last_activity\":\"2026-03-19 12:29:28\"}', '[{\"device_id\":\"2eb3df2e815b5b652db08c1395f5ae55\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-19 12:29:28\",\"last_activity\":\"2026-03-19 12:29:28\"}]');
INSERT INTO `c_users` VALUES (22, 'SGYMQ', NULL, '13829805453', '$2y$10$fSqelh523k5n9fG1/5rLpOGGhUeeyKaOabXOs7TCH6Njh5THanNzu', 'NB4FJA', 5, NULL, 3, 'eyJ1c2VyX2lkIjoyMiwidHlwZSI6MSwiZXhwIjoxNzc0NDI4NTM0fQ==', '2026-03-25 16:48:54', 28, 1, NULL, '34.143.229.197', '2026-03-15 14:22:08', '2026-03-18 16:48:54', 0, NULL, NULL, NULL, 'b12ab4ddf1ac35fbc4f576c372eb044b', 'zh-CN', 1, '{\"device_id\":\"b12ab4ddf1ac35fbc4f576c372eb044b\",\"device_name\":\"zh-CN\",\"login_time\":\"2026-03-18 16:48:54\",\"last_activity\":\"2026-03-18 16:48:54\"}', '[{\"device_id\":\"b12ab4ddf1ac35fbc4f576c372eb044b\",\"device_name\":\"zh-CN\",\"login_time\":\"2026-03-18 16:48:54\",\"last_activity\":\"2026-03-18 16:48:54\"}]');
INSERT INTO `c_users` VALUES (23, '840112512512', NULL, '18874021967', '$2y$10$3psNbu8YCwiJAd6LEAiwkOqNpQi05j/8svaS0.AmQbAh6wKL03bJy', 'VUZJWG', 5, NULL, 2, 'eyJ1c2VyX2lkIjoyMywidHlwZSI6MSwiZXhwIjoxNzc0NDk1MTE3fQ==', '2026-03-26 11:18:37', 29, 1, NULL, '34.143.229.197', '2026-03-15 15:05:50', '2026-03-19 11:18:37', 0, NULL, NULL, NULL, 'd1be6d4ad0e3b046a4567609b19fa91c', 'PHM110 Build/AP3A.240617.008', 1, '{\"device_id\":\"d1be6d4ad0e3b046a4567609b19fa91c\",\"device_name\":\"PHM110 Build/AP3A.240617.008\",\"login_time\":\"2026-03-19 11:18:37\",\"last_activity\":\"2026-03-19 11:18:37\"}', '[{\"device_id\":\"d1be6d4ad0e3b046a4567609b19fa91c\",\"device_name\":\"PHM110 Build/AP3A.240617.008\",\"login_time\":\"2026-03-19 11:18:37\",\"last_activity\":\"2026-03-19 11:18:37\"}]');
INSERT INTO `c_users` VALUES (24, 'jwf888', NULL, '13028828678', '$2y$10$oVRphofDmt.d9BcaRjDvC.mLDYExLji8fZrDgdGXMQkm0t1z.ETlu', 'RNFJJA', 5, NULL, 0, 'eyJ1c2VyX2lkIjoyNCwidHlwZSI6MSwiZXhwIjoxNzc0MTY0Nzg2fQ==', '2026-03-22 15:33:06', 30, 1, NULL, '34.143.229.197', '2026-03-15 15:33:06', '2026-03-15 15:33:06', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (25, 'na0430', NULL, '19317932440', '$2y$10$OZ9DMKAV0VkFua2xH3dWiO2TyBVw09Cqr3wFjGCp4wVxzHKiXOc7G', 'ZJZ353', 22, NULL, 0, 'eyJ1c2VyX2lkIjoyNSwidHlwZSI6MSwiZXhwIjoxNzc0NTc4NTMwfQ==', '2026-03-27 10:28:50', 31, 1, NULL, '34.143.229.197', '2026-03-15 16:48:38', '2026-03-20 10:28:50', 0, NULL, NULL, NULL, '4853be6bddae5ebf3f90622fbd512067', 'iPhone', 1, '{\"device_id\":\"4853be6bddae5ebf3f90622fbd512067\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-20 10:28:50\",\"last_activity\":\"2026-03-20 10:28:50\"}', '[{\"device_id\":\"4853be6bddae5ebf3f90622fbd512067\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-20 10:28:50\",\"last_activity\":\"2026-03-20 10:28:50\"}]');
INSERT INTO `c_users` VALUES (26, '1158799864', NULL, '15156763788', '$2y$10$xvpzk1I7FQqXIX2b8/WMgO2mzZFmT7BPjqWKv4nzdsA4lTQln2dMS', 'VH6XZ2', 22, NULL, 1, 'eyJ1c2VyX2lkIjoyNiwidHlwZSI6MSwiZXhwIjoxNzc0MTgxODk0fQ==', '2026-03-22 20:18:14', 32, 1, NULL, '34.143.229.197', '2026-03-15 16:55:20', '2026-03-16 13:16:57', 0, NULL, NULL, NULL, '98a8be506cb34dc8a88a530d6c4acac8', 'zh-cn', 1, '{\"device_id\":\"98a8be506cb34dc8a88a530d6c4acac8\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-15 20:18:14\",\"last_activity\":\"2026-03-15 20:18:14\"}', '[{\"device_id\":\"98a8be506cb34dc8a88a530d6c4acac8\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-15 20:18:14\",\"last_activity\":\"2026-03-15 20:18:14\"}]');
INSERT INTO `c_users` VALUES (27, 'mjj20100316', NULL, '15299266549', '$2y$10$L2GnFMnZCpxbRqk6pj.OFuEohsPxwqScmDXJKW8/4GvJVCX218luK', 'CDXGAJ', 22, NULL, 1, 'eyJ1c2VyX2lkIjoyNywidHlwZSI6MSwiZXhwIjoxNzc0NjA0Mjc0fQ==', '2026-03-27 17:37:54', 34, 1, NULL, '34.143.229.197', '2026-03-15 17:22:13', '2026-03-20 17:37:54', 0, NULL, NULL, NULL, 'a89a07780467e385548347bbeebad032', 'zh-cn', 1, '{\"device_id\":\"a89a07780467e385548347bbeebad032\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-20 17:37:54\",\"last_activity\":\"2026-03-20 17:37:54\"}', '[{\"device_id\":\"a89a07780467e385548347bbeebad032\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-20 17:37:54\",\"last_activity\":\"2026-03-20 17:37:54\"}]');
INSERT INTO `c_users` VALUES (28, 'swen', NULL, '18815550392', '$2y$10$9le9FjJ4mkeXV4yeyoykUuhhEQfma36m20oXrY8bLqYKfm2imVqHG', '3U3UMU', 26, NULL, 0, 'eyJ1c2VyX2lkIjoyOCwidHlwZSI6MSwiZXhwIjoxNzc0MzUzNTk5fQ==', '2026-03-24 19:59:59', 35, 1, NULL, '34.143.229.197', '2026-03-15 18:16:34', '2026-03-17 19:59:59', 0, NULL, NULL, NULL, 'cfe6393ee7b76ae5b2cf900ab73a043a', 'zh-cn', 1, '{\"device_id\":\"cfe6393ee7b76ae5b2cf900ab73a043a\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-17 19:59:59\",\"last_activity\":\"2026-03-17 19:59:59\"}', '[{\"device_id\":\"cfe6393ee7b76ae5b2cf900ab73a043a\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-17 19:59:59\",\"last_activity\":\"2026-03-17 19:59:59\"}]');
INSERT INTO `c_users` VALUES (29, 'zxcvbnm', NULL, '15055076758', '$2y$10$dKFOhn4H4B944b41xhSbGuk9WtduJNv7U7IbnNLhaFoj2nwUrn37O', 'U3J84E', 26, NULL, 0, 'eyJ1c2VyX2lkIjoyOSwidHlwZSI6MSwiZXhwIjoxNzc0MTc3OTg4fQ==', '2026-03-22 19:13:08', 36, 1, NULL, '34.143.229.197', '2026-03-15 19:12:49', '2026-03-15 19:13:08', 0, NULL, NULL, NULL, 'de33f3516f1e5a7110427e2a6453a9f0', '23127PN0CC Build/BP2A.250605.031.A3', 1, '{\"device_id\":\"de33f3516f1e5a7110427e2a6453a9f0\",\"device_name\":\"23127PN0CC Build/BP2A.250605.031.A3\",\"login_time\":\"2026-03-15 19:13:08\",\"last_activity\":\"2026-03-15 19:13:08\"}', '[{\"device_id\":\"de33f3516f1e5a7110427e2a6453a9f0\",\"device_name\":\"23127PN0CC Build/BP2A.250605.031.A3\",\"login_time\":\"2026-03-15 19:13:08\",\"last_activity\":\"2026-03-15 19:13:08\"}]');
INSERT INTO `c_users` VALUES (30, 'songjuan520', NULL, '15004147008', '$2y$10$Rb60hv6x3cXVcnjL4dG7yuBizsDEqkvHwWGGM3DBPYSOfaLhxtFJi', 'KRCZ3C', 26, NULL, 0, 'eyJ1c2VyX2lkIjozMCwidHlwZSI6MSwiZXhwIjoxNzc0NTIzODY5fQ==', '2026-03-26 19:17:49', 37, 1, NULL, '34.143.229.197', '2026-03-15 19:17:41', '2026-03-19 19:17:49', 0, NULL, NULL, NULL, '35fcd434ed3e3e84d13ed13d40628633', 'iPhone', 1, '{\"device_id\":\"35fcd434ed3e3e84d13ed13d40628633\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-19 19:17:49\",\"last_activity\":\"2026-03-19 19:17:49\"}', '[{\"device_id\":\"35fcd434ed3e3e84d13ed13d40628633\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-19 19:17:49\",\"last_activity\":\"2026-03-19 19:17:49\"}]');
INSERT INTO `c_users` VALUES (31, 'w621718', NULL, '13614243021', '$2y$10$EXH9oa35iZo2UeWHD1bhtusjFttP0i5dx1jRIK1NC7y9o4tlk7W3y', '8NGJWH', 26, NULL, 0, 'eyJ1c2VyX2lkIjozMSwidHlwZSI6MSwiZXhwIjoxNzc0MTgwMjk4fQ==', '2026-03-22 19:51:38', 38, 1, NULL, '34.143.229.197', '2026-03-15 19:19:35', '2026-03-15 19:51:38', 0, NULL, NULL, NULL, '5a6ad8e85fc8535d2c085b6d3ae48ef0', 'zh-cn', 1, '{\"device_id\":\"5a6ad8e85fc8535d2c085b6d3ae48ef0\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-15 19:51:38\",\"last_activity\":\"2026-03-15 19:51:38\"}', '[{\"device_id\":\"5a6ad8e85fc8535d2c085b6d3ae48ef0\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-15 19:51:38\",\"last_activity\":\"2026-03-15 19:51:38\"}]');
INSERT INTO `c_users` VALUES (32, 'yangyang', 'null@qq.com', '19213916686', '$2y$10$rE/LYC9bdiWGbLynHr.YF.1.AeYZG9ONfTPZwYW55Zrfi791t5ebm', 'VK9NTZ', 5, NULL, 2, 'eyJ1c2VyX2lkIjozMiwidHlwZSI6MSwiZXhwIjoxNzc0MTg0NTY3fQ==', '2026-03-22 21:02:47', 39, 1, NULL, '34.143.229.197', '2026-03-15 19:23:26', '2026-03-15 21:02:47', 0, NULL, NULL, NULL, '2ec303deaf8a31d0a0e9b6e019c48f76', 'iPhone', 1, '{\"device_id\":\"2ec303deaf8a31d0a0e9b6e019c48f76\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-15 21:02:47\",\"last_activity\":\"2026-03-15 21:02:47\"}', '[{\"device_id\":\"2ec303deaf8a31d0a0e9b6e019c48f76\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-15 21:02:47\",\"last_activity\":\"2026-03-15 21:02:47\"}]');
INSERT INTO `c_users` VALUES (33, '2580', NULL, '17356743965', '$2y$10$3Acok1Ww3RevQWOTesc93OUsBda1m9q7HtQkwqaDoNiVF4QoT5TDq', '35E6AJ', 26, NULL, 0, 'eyJ1c2VyX2lkIjozMywidHlwZSI6MSwiZXhwIjoxNzc0MTgwMjIxfQ==', '2026-03-22 19:50:21', 40, 1, NULL, '34.143.229.197', '2026-03-15 19:27:09', '2026-03-15 19:50:21', 0, NULL, NULL, NULL, '0963e7723014ffa869eaf749289a5c21', 'zh-cn', 1, '{\"device_id\":\"0963e7723014ffa869eaf749289a5c21\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-15 19:50:21\",\"last_activity\":\"2026-03-15 19:50:21\"}', '[{\"device_id\":\"0963e7723014ffa869eaf749289a5c21\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-15 19:50:21\",\"last_activity\":\"2026-03-15 19:50:21\"}]');
INSERT INTO `c_users` VALUES (34, '123456w', NULL, '16663908886', '$2y$10$E6vuf7sf29iExVP6cW.99OECpt2GM5nih4JV7asOV1LiJYf/8tvnu', 'PHE8XZ', 5, NULL, 0, 'eyJ1c2VyX2lkIjozNCwidHlwZSI6MSwiZXhwIjoxNzc0MTc4OTUzfQ==', '2026-03-22 19:29:13', 41, 1, NULL, '34.143.229.197', '2026-03-15 19:29:13', '2026-03-15 19:29:13', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (35, 'YUAN520', NULL, '13517552165', '$2y$10$ocPsCw50bfE5nOxor0nPae6cskd7qXzyCxl/0Qd76zBh.7CVV0BvC', '2RUDMW', 22, NULL, 1, 'eyJ1c2VyX2lkIjozNSwidHlwZSI6MSwiZXhwIjoxNzc0MTc4OTg2fQ==', '2026-03-22 19:29:46', 42, 1, NULL, '34.143.229.197', '2026-03-15 19:29:22', '2026-03-16 13:16:21', 0, NULL, NULL, NULL, '1c38ecbe464d98c1313590c7141af431', 'zh-cn', 1, '{\"device_id\":\"1c38ecbe464d98c1313590c7141af431\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-15 19:29:46\",\"last_activity\":\"2026-03-15 19:29:46\"}', '[{\"device_id\":\"1c38ecbe464d98c1313590c7141af431\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-15 19:29:46\",\"last_activity\":\"2026-03-15 19:29:46\"}]');
INSERT INTO `c_users` VALUES (36, 'guizhang8582', NULL, '18086605146', '$2y$10$8AOamGp8W91eubiDGTC7.OwAtXZ/Y1g/lCTPfhPBR3MYW.yD9/u5.', '3PWSPZ', 26, NULL, 0, 'eyJ1c2VyX2lkIjozNiwidHlwZSI6MSwiZXhwIjoxNzc0NDQzODEzfQ==', '2026-03-25 21:03:33', 43, 1, NULL, '34.143.229.197', '2026-03-15 19:57:09', '2026-03-18 21:03:33', 0, NULL, NULL, NULL, 'f052eb27f9c3c385f675ecede1ce9be3', 'zh-cn', 1, '{\"device_id\":\"f052eb27f9c3c385f675ecede1ce9be3\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-18 21:03:33\",\"last_activity\":\"2026-03-18 21:03:33\"}', '[{\"device_id\":\"f052eb27f9c3c385f675ecede1ce9be3\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-18 21:03:33\",\"last_activity\":\"2026-03-18 21:03:33\"}]');
INSERT INTO `c_users` VALUES (37, '18607307586', NULL, '19330092578', '$2y$10$7TbPk/rrhg3mu1FGe8qji..psn5K567.LaLHxpg1gKzW8BdaPaz9K', 'Z7CFWX', 23, NULL, 0, 'eyJ1c2VyX2lkIjozNywidHlwZSI6MSwiZXhwIjoxNzc0MzA5MjQ3fQ==', '2026-03-24 07:40:47', 44, 1, NULL, '34.143.229.197', '2026-03-15 20:01:16', '2026-03-17 07:40:47', 0, NULL, NULL, NULL, 'ef8a49385ea03949b5fea3cc27f6e646', 'V2163A Build/UP1A.231005.007', 1, '{\"device_id\":\"ef8a49385ea03949b5fea3cc27f6e646\",\"device_name\":\"V2163A Build/UP1A.231005.007\",\"login_time\":\"2026-03-17 07:40:47\",\"last_activity\":\"2026-03-17 07:40:47\"}', '[{\"device_id\":\"ef8a49385ea03949b5fea3cc27f6e646\",\"device_name\":\"V2163A Build/UP1A.231005.007\",\"login_time\":\"2026-03-17 07:40:47\",\"last_activity\":\"2026-03-17 07:40:47\"}]');
INSERT INTO `c_users` VALUES (38, '78111000', NULL, '15574958487', '$2y$10$/K/mxikIXG6FlR.WXB.cAufzyxbFlfjp5n2Mc6aknakVUK2idekIq', 'EX6WGE', 23, NULL, 0, 'eyJ1c2VyX2lkIjozOCwidHlwZSI6MSwiZXhwIjoxNzc0MTgwODgxfQ==', '2026-03-22 20:01:21', 45, 1, NULL, '34.143.229.197', '2026-03-15 20:01:21', '2026-03-15 20:01:21', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (39, '781101zwr', NULL, '18890355487', '$2y$10$AlXyuZXdWnto073fVn04e.lVDiPxOq.MwQbjvu7lstBv6dMo6cOFu', 'B2NWQZ', 23, NULL, 0, 'eyJ1c2VyX2lkIjozOSwidHlwZSI6MSwiZXhwIjoxNzc0MjY0NDcwfQ==', '2026-03-23 19:14:30', 46, 1, NULL, '34.143.229.197', '2026-03-15 20:12:49', '2026-03-16 19:14:30', 0, NULL, NULL, NULL, 'd1be6d4ad0e3b046a4567609b19fa91c', 'PHM110 Build/AP3A.240617.008', 1, '{\"device_id\":\"d1be6d4ad0e3b046a4567609b19fa91c\",\"device_name\":\"PHM110 Build/AP3A.240617.008\",\"login_time\":\"2026-03-16 19:14:30\",\"last_activity\":\"2026-03-16 19:14:30\"}', '[{\"device_id\":\"d1be6d4ad0e3b046a4567609b19fa91c\",\"device_name\":\"PHM110 Build/AP3A.240617.008\",\"login_time\":\"2026-03-16 19:14:30\",\"last_activity\":\"2026-03-16 19:14:30\"}]');
INSERT INTO `c_users` VALUES (40, '147369123789', NULL, '13606603489', '$2y$10$wc75wbH0Nmlt/VlBK.1/MOUrX4y2wdw1YX7NownX60y/8V0bM8Dy.', 'H8GV5C', 26, NULL, 0, 'eyJ1c2VyX2lkIjo0MCwidHlwZSI6MSwiZXhwIjoxNzc0NDQzMzc2fQ==', '2026-03-25 20:56:16', 47, 1, NULL, '34.143.229.197', '2026-03-15 20:17:13', '2026-03-18 20:56:16', 0, NULL, NULL, NULL, 'd69e8f4f2c6cfd212a9ac488166c71ef', 'VNE-AN00) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/116.0.5845.114 HonorBrowser/3.2.2.303  Mobile Safari/537.36', 1, '{\"device_id\":\"d69e8f4f2c6cfd212a9ac488166c71ef\",\"device_name\":\"VNE-AN00) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/116.0.5845.114 HonorBrowser/3.2.2.303  Mobile Safari/537.36\",\"login_time\":\"2026-03-18 20:56:16\",\"last_activity\":\"2026-03-18 20:56:16\"}', '[{\"device_id\":\"d69e8f4f2c6cfd212a9ac488166c71ef\",\"device_name\":\"VNE-AN00) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/116.0.5845.114 HonorBrowser/3.2.2.303  Mobile Safari/537.36\",\"login_time\":\"2026-03-18 20:56:16\",\"last_activity\":\"2026-03-18 20:56:16\"}]');
INSERT INTO `c_users` VALUES (41, 'asd123', NULL, '18040549884', '$2y$10$p4UB0b9nMa6yygK98S6XC.7tl.dKYjG/tVOWL3d/JIFjk4AXIRw2W', 'Q25X6Q', 26, NULL, 0, 'eyJ1c2VyX2lkIjo0MSwidHlwZSI6MSwiZXhwIjoxNzc0MjQ3ODA3fQ==', '2026-03-23 14:36:47', 48, 1, NULL, '34.143.229.197', '2026-03-15 20:17:50', '2026-03-16 14:36:47', 0, NULL, NULL, NULL, '9f4515da7362f02b2cc2e7e8263ec246', 'Android Device', 1, '{\"device_id\":\"9f4515da7362f02b2cc2e7e8263ec246\",\"device_name\":\"Android Device\",\"login_time\":\"2026-03-16 14:36:47\",\"last_activity\":\"2026-03-16 14:36:47\"}', '[{\"device_id\":\"9f4515da7362f02b2cc2e7e8263ec246\",\"device_name\":\"Android Device\",\"login_time\":\"2026-03-16 14:36:47\",\"last_activity\":\"2026-03-16 14:36:47\"}]');
INSERT INTO `c_users` VALUES (42, 'xy25', NULL, '18133310097', '$2y$10$24fQ1EXyHeSQE4VQaI9jIed.GJMWjlJOhiv/qbVOOe07bx39XFhOq', 'UU4BBN', 22, NULL, 1, 'eyJ1c2VyX2lkIjo0MiwidHlwZSI6MSwiZXhwIjoxNzc0NTEwMzk0fQ==', '2026-03-26 15:33:14', 49, 1, NULL, '34.143.229.197', '2026-03-15 21:13:31', '2026-03-19 15:33:14', 0, NULL, NULL, NULL, 'c03fa369f1dbaea87c135ee34d15ed79', 'iPhone', 1, '{\"device_id\":\"c03fa369f1dbaea87c135ee34d15ed79\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-19 15:33:14\",\"last_activity\":\"2026-03-19 15:33:14\"}', '[{\"device_id\":\"c03fa369f1dbaea87c135ee34d15ed79\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-19 15:33:14\",\"last_activity\":\"2026-03-19 15:33:14\"}]');
INSERT INTO `c_users` VALUES (43, '140823tt', NULL, '13616896925', '$2y$10$8OaA8A2h.8o2HNtxWmbx0OlcO53MmeYuWTpg5ShG1Cefha8F3s/la', 'XJP8KH', 42, NULL, 0, 'eyJ1c2VyX2lkIjo0MywidHlwZSI6MSwiZXhwIjoxNzc0MjI4NDc3fQ==', '2026-03-23 09:14:37', 50, 1, NULL, '34.143.229.197', '2026-03-16 08:59:30', '2026-03-16 09:14:37', 0, NULL, NULL, NULL, '43568f89bb2f3eca2cee5a0ec2f3806b', '24129PN74C Build/BP2A.250605.031.A3', 1, '{\"device_id\":\"43568f89bb2f3eca2cee5a0ec2f3806b\",\"device_name\":\"24129PN74C Build/BP2A.250605.031.A3\",\"login_time\":\"2026-03-16 09:14:37\",\"last_activity\":\"2026-03-16 09:14:37\"}', '[{\"device_id\":\"43568f89bb2f3eca2cee5a0ec2f3806b\",\"device_name\":\"24129PN74C Build/BP2A.250605.031.A3\",\"login_time\":\"2026-03-16 09:14:37\",\"last_activity\":\"2026-03-16 09:14:37\"}]');
INSERT INTO `c_users` VALUES (44, 'zhaoyang188', NULL, '18537013122', '$2y$10$3Xsg4546cDZEScTNJiYVCeZrv0jtCXiCcF1tFDeRWyyXIe3mWmuRu', 'QBQN5F', 42, NULL, 0, 'eyJ1c2VyX2lkIjo0NCwidHlwZSI6MSwiZXhwIjoxNzc0MjI3NzEzfQ==', '2026-03-23 09:01:53', 51, 1, NULL, '34.143.229.197', '2026-03-16 09:00:06', '2026-03-16 09:01:53', 0, NULL, NULL, NULL, '95135d7f01da6850f6d649301c6b6da7', 'NOH-AN00 Build/HUAWEINOH-AN00', 1, '{\"device_id\":\"95135d7f01da6850f6d649301c6b6da7\",\"device_name\":\"NOH-AN00 Build/HUAWEINOH-AN00\",\"login_time\":\"2026-03-16 09:01:53\",\"last_activity\":\"2026-03-16 09:01:53\"}', '[{\"device_id\":\"95135d7f01da6850f6d649301c6b6da7\",\"device_name\":\"NOH-AN00 Build/HUAWEINOH-AN00\",\"login_time\":\"2026-03-16 09:01:53\",\"last_activity\":\"2026-03-16 09:01:53\"}]');
INSERT INTO `c_users` VALUES (45, 'mr111222', NULL, '17205604105', '$2y$10$gbeLDSchSevyh2MbG0M4cOVJNBiurp2fpzVnCttrW1/hUgFGJxpte', 'UWKW55', 42, NULL, 0, 'eyJ1c2VyX2lkIjo0NSwidHlwZSI6MSwiZXhwIjoxNzc0MjI3OTQwfQ==', '2026-03-23 09:05:40', 52, 1, NULL, '34.143.229.197', '2026-03-16 09:05:18', '2026-03-16 09:05:40', 0, NULL, NULL, NULL, 'e39d645804d36326119cbcfa9abf3612', 'iPhone', 1, '{\"device_id\":\"e39d645804d36326119cbcfa9abf3612\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-16 09:05:40\",\"last_activity\":\"2026-03-16 09:05:40\"}', '[{\"device_id\":\"e39d645804d36326119cbcfa9abf3612\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-16 09:05:40\",\"last_activity\":\"2026-03-16 09:05:40\"}]');
INSERT INTO `c_users` VALUES (46, 'yuguo', NULL, '15256160583', '$2y$10$XGoOhyaen65eJlTdro6es.fUdhcd8jFpZ25c4BFo0OQDlvvUrKluu', 'AJ3ZTK', 42, NULL, 0, 'eyJ1c2VyX2lkIjo0NiwidHlwZSI6MSwiZXhwIjoxNzc0MjMxNjk5fQ==', '2026-03-23 10:08:19', 53, 1, NULL, '34.143.229.197', '2026-03-16 10:00:40', '2026-03-16 10:08:19', 0, NULL, NULL, NULL, '4853be6bddae5ebf3f90622fbd512067', 'iPhone', 1, '{\"device_id\":\"4853be6bddae5ebf3f90622fbd512067\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-16 10:08:19\",\"last_activity\":\"2026-03-16 10:08:19\"}', '[{\"device_id\":\"4853be6bddae5ebf3f90622fbd512067\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-16 10:08:19\",\"last_activity\":\"2026-03-16 10:08:19\"}]');
INSERT INTO `c_users` VALUES (47, 'sun123456', NULL, '18712285095', '$2y$10$9HkQzpuwj212HYB8V6Fi0eIWKNE4E8G9s1wQZdjskaxYBuppeLWmu', 'BNQJJU', 42, NULL, 0, 'eyJ1c2VyX2lkIjo0NywidHlwZSI6MSwiZXhwIjoxNzc0MzE3MjU2fQ==', '2026-03-24 09:54:16', 54, 1, NULL, '34.143.229.197', '2026-03-16 10:31:15', '2026-03-17 09:54:16', 0, NULL, NULL, NULL, 'fd2f8f85ec7839ddbb0432c337bb01ce', 'PFTM10 Build/UKQ1.230924.001', 1, '{\"device_id\":\"fd2f8f85ec7839ddbb0432c337bb01ce\",\"device_name\":\"PFTM10 Build/UKQ1.230924.001\",\"login_time\":\"2026-03-17 09:54:16\",\"last_activity\":\"2026-03-17 09:54:16\"}', '[{\"device_id\":\"fd2f8f85ec7839ddbb0432c337bb01ce\",\"device_name\":\"PFTM10 Build/UKQ1.230924.001\",\"login_time\":\"2026-03-17 09:54:16\",\"last_activity\":\"2026-03-17 09:54:16\"}]');
INSERT INTO `c_users` VALUES (48, '162401', NULL, '19156778998', '$2y$10$7iM5QH7tqU09Qn2.bRd96uP0bu7MgF5lypl6XIQWkzquglA5Mv1W6', 'SXMMMV', 42, NULL, 0, 'eyJ1c2VyX2lkIjo0OCwidHlwZSI6MSwiZXhwIjoxNzc0MzY4MzY3fQ==', '2026-03-25 00:06:07', 55, 1, NULL, '34.143.229.197', '2026-03-16 11:15:09', '2026-03-18 00:06:07', 0, NULL, NULL, NULL, '8755a0926385767ca0c5adf9a4779a38', 'M2104K10AC Build/TP1A.220624.014', 1, '{\"device_id\":\"8755a0926385767ca0c5adf9a4779a38\",\"device_name\":\"M2104K10AC Build/TP1A.220624.014\",\"login_time\":\"2026-03-18 00:06:07\",\"last_activity\":\"2026-03-18 00:06:07\"}', '[{\"device_id\":\"8755a0926385767ca0c5adf9a4779a38\",\"device_name\":\"M2104K10AC Build/TP1A.220624.014\",\"login_time\":\"2026-03-18 00:06:07\",\"last_activity\":\"2026-03-18 00:06:07\"}]');
INSERT INTO `c_users` VALUES (127, 'ces1', 'ces1@example.com', '13800138100', '$2y$12$UQt8vHCdl6jKVJxPIUCC/esnA5o5Vhl.W7HWn2oJHJdVKJBy9t9Pq', 'CJEVXU', NULL, NULL, 0, 'eyJ1c2VyX2lkIjoxMjcsInR5cGUiOjEsImV4cCI6MTc3NDY4MjQ1OH0=', '2026-03-28 15:20:58', 57, 1, NULL, '127.0.0.1', '2026-03-21 14:35:13', '2026-03-21 15:20:58', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-21 15:20:58\",\"last_activity\":\"2026-03-21 15:20:58\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-21 15:20:58\",\"last_activity\":\"2026-03-21 15:20:58\"}]');
INSERT INTO `c_users` VALUES (128, 'ces2', 'ces2@example.com', '13800138102', '$2y$12$TQVfvualMMDcc6VnzngvTuTDyPHZyOKTNiCEHYponlUHe1DASvuq2', 'K9UJSR', NULL, NULL, 0, 'eyJ1c2VyX2lkIjoxMjgsInR5cGUiOjEsImV4cCI6MTc3NDY4Mjc0MX0=', '2026-03-28 15:25:41', 58, 1, NULL, '127.0.0.1', '2026-03-21 15:25:36', '2026-03-21 15:25:41', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-21 15:25:41\",\"last_activity\":\"2026-03-21 15:25:41\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-21 15:25:41\",\"last_activity\":\"2026-03-21 15:25:41\"}]');

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
) ENGINE = InnoDB AUTO_INCREMENT = 125 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统通知表-通知模板' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of notifications
-- ----------------------------
INSERT INTO `notifications` VALUES (93, '充值审核通过', '您的充值申请已审核通过，金额：¥10,000.00 已到账。感谢您的使用！', 3, 6, 2, 1, NULL, '2026-03-18 15:55:15');
INSERT INTO `notifications` VALUES (94, '收到新的租赁订单', '您的出租「测试租赁系统的新功能，佣金结算」收到新订单，租期10天，等待客服处理', 3, 112, 1, 1, NULL, '2026-03-18 22:31:41');
INSERT INTO `notifications` VALUES (95, '租赁订单支付成功', '您租赁的「测试租赁系统的新功能，佣金结算」已支付成功，等待客服处理', 3, 6, 2, 1, NULL, '2026-03-18 22:31:41');
INSERT INTO `notifications` VALUES (96, '租赁订单已开始', '您租用的订单 #4 已开始执行，租期 10 天，到期时间：2026-03-28 23:34:21', 3, 6, 2, 1, NULL, '2026-03-18 23:34:21');
INSERT INTO `notifications` VALUES (97, '租赁订单已开始', '您出租的订单 #4 已开始执行，租期 10 天，到期时间：2026-03-28 23:34:21', 3, 112, 1, 1, NULL, '2026-03-18 23:34:21');
INSERT INTO `notifications` VALUES (98, '收到新的租赁订单', '您的出租「测试租赁系统的新功能，佣金结算」收到新订单，租期10天，等待客服处理', 3, 112, 1, 1, NULL, '2026-03-18 23:40:18');
INSERT INTO `notifications` VALUES (99, '租赁订单支付成功', '您租赁的「测试租赁系统的新功能，佣金结算」已支付成功，等待客服处理', 3, 6, 2, 1, NULL, '2026-03-18 23:40:18');
INSERT INTO `notifications` VALUES (100, '租赁订单已开始', '您租用的订单 #5 已开始执行，租期 10 天，到期时间：2026-03-28 23:40:30', 3, 6, 2, 1, NULL, '2026-03-18 23:40:30');
INSERT INTO `notifications` VALUES (101, '租赁订单已开始', '您出租的订单 #5 已开始执行，租期 10 天，到期时间：2026-03-28 23:40:30', 3, 112, 1, 1, NULL, '2026-03-18 23:40:30');
INSERT INTO `notifications` VALUES (102, '租赁订单已完成', '您出租的订单 #4 已完成，收益 ¥70.00 已到账', 3, 112, 1, 1, NULL, '2026-03-18 23:42:12');
INSERT INTO `notifications` VALUES (103, '租赁订单已完成', '您租用的订单 #4 已到期完成，感谢使用', 3, 6, 2, 1, NULL, '2026-03-18 23:42:12');
INSERT INTO `notifications` VALUES (104, '租赁订单已终止并退款', '您租用的订单 #5 已被客服终止，已退款 ¥40.00 至您的钱包。', 3, 6, 2, 1, NULL, '2026-03-18 23:52:01');
INSERT INTO `notifications` VALUES (105, '租赁订单已终止并结算', '您出租的订单 #5 已被客服终止，已结算 ¥60.00 至您的钱包，已退款 ¥40.00 给买家。', 3, 112, 1, 1, NULL, '2026-03-18 23:52:01');
INSERT INTO `notifications` VALUES (106, '收到新的租赁订单', '您的出租「测试租赁系统的新功能，佣金结算」收到新订单，租期10天，等待客服处理', 3, 112, 1, 1, NULL, '2026-03-19 00:17:29');
INSERT INTO `notifications` VALUES (107, '租赁订单支付成功', '您租赁的「测试租赁系统的新功能，佣金结算」已支付成功，等待客服处理', 3, 6, 2, 1, NULL, '2026-03-19 00:17:29');
INSERT INTO `notifications` VALUES (108, '收到新的租赁订单', '您的出租「测试租赁系统的新功能，佣金结算」收到新订单，租期10天，等待客服处理', 3, 113, 1, 1, NULL, '2026-03-19 00:18:31');
INSERT INTO `notifications` VALUES (109, '租赁订单支付成功', '您租赁的「测试租赁系统的新功能，佣金结算」已支付成功，等待客服处理', 3, 6, 2, 1, NULL, '2026-03-19 00:18:31');
INSERT INTO `notifications` VALUES (110, '收到新的租赁订单', '您的出租「测试租赁系统的新功能，佣金结算」收到新订单，租期10天，等待客服处理', 3, 112, 1, 1, NULL, '2026-03-19 00:18:37');
INSERT INTO `notifications` VALUES (111, '租赁订单支付成功', '您租赁的「测试租赁系统的新功能，佣金结算」已支付成功，等待客服处理', 3, 6, 2, 1, NULL, '2026-03-19 00:18:37');
INSERT INTO `notifications` VALUES (112, '租赁订单已开始', '您租用的订单 #6 已开始执行，租期 10 天，到期时间：2026-03-29 00:21:14', 3, 6, 2, 1, NULL, '2026-03-19 00:21:14');
INSERT INTO `notifications` VALUES (113, '租赁订单已开始', '您出租的订单 #6 已开始执行，租期 10 天，到期时间：2026-03-29 00:21:14', 3, 112, 1, 1, NULL, '2026-03-19 00:21:14');
INSERT INTO `notifications` VALUES (114, '租赁订单已开始', '您租用的订单 #7 已开始执行，租期 10 天，到期时间：2026-03-29 00:21:15', 3, 6, 2, 1, NULL, '2026-03-19 00:21:15');
INSERT INTO `notifications` VALUES (115, '租赁订单已开始', '您出租的订单 #7 已开始执行，租期 10 天，到期时间：2026-03-29 00:21:15', 3, 113, 1, 1, NULL, '2026-03-19 00:21:15');
INSERT INTO `notifications` VALUES (116, '租赁订单已开始', '您租用的订单 #8 已开始执行，租期 10 天，到期时间：2026-03-29 00:21:17', 3, 6, 2, 1, NULL, '2026-03-19 00:21:17');
INSERT INTO `notifications` VALUES (117, '租赁订单已开始', '您出租的订单 #8 已开始执行，租期 10 天，到期时间：2026-03-29 00:21:17', 3, 112, 1, 1, NULL, '2026-03-19 00:21:17');
INSERT INTO `notifications` VALUES (118, '租赁订单已完成', '您出租的订单 #6 已完成，收益 ¥70.00 已到账', 3, 112, 1, 1, NULL, '2026-03-19 00:24:48');
INSERT INTO `notifications` VALUES (119, '租赁订单已完成', '您租用的订单 #6 已到期完成，感谢使用', 3, 6, 2, 1, NULL, '2026-03-19 00:24:48');
INSERT INTO `notifications` VALUES (120, '租赁订单已完成', '您出租的订单 #7 已完成，收益 ¥70.00 已到账', 3, 113, 1, 1, NULL, '2026-03-19 00:24:48');
INSERT INTO `notifications` VALUES (121, '租赁订单已完成', '您租用的订单 #7 已到期完成，感谢使用', 3, 6, 2, 1, NULL, '2026-03-19 00:24:48');
INSERT INTO `notifications` VALUES (122, '租赁订单已完成', '您出租的订单 #8 已完成，收益 ¥70.00 已到账', 3, 112, 1, 1, NULL, '2026-03-19 00:24:48');
INSERT INTO `notifications` VALUES (123, '租赁订单已完成', '您租用的订单 #8 已到期完成，感谢使用', 3, 6, 2, 1, NULL, '2026-03-19 00:24:48');
INSERT INTO `notifications` VALUES (124, '充值审核通过', '您的充值申请已审核通过，金额：¥200.00 已到账。感谢您的使用！', 3, 8, 2, 1, NULL, '2026-03-21 14:37:14');

-- ----------------------------
-- Table structure for quick_task_info_config
-- ----------------------------
DROP TABLE IF EXISTS `quick_task_info_config`;
CREATE TABLE `quick_task_info_config`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `b_user_id` bigint UNSIGNED NOT NULL COMMENT 'B端用户ID',
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `config_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '配置信息（JSON格式）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_b_user_id`(`b_user_id` ASC) USING BTREE,
  INDEX `idx_username`(`username` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_updated_at`(`updated_at` ASC) USING BTREE,
  CONSTRAINT `fk_quick_task_config_b_user` FOREIGN KEY (`b_user_id`) REFERENCES `b_users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端用户快捷派单配置信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of quick_task_info_config
-- ----------------------------
INSERT INTO `quick_task_info_config` VALUES (3, 8, 'task', NULL, '2026-03-21 14:34:12', '2026-03-21 14:34:12');

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
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '充值申请表-需要管理员审核' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of recharge_requests
-- ----------------------------
INSERT INTO `recharge_requests` VALUES (19, 8, 'task', 2, 56, 20000, 'alipay', 'http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg', 359, 1, NULL, NULL, '2026-03-21 14:37:14', '2026-03-21 14:36:51');

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
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '出租信息表-账号出租市场' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '租赁订单表-成交订单记录' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '租赁工单表-售后纠纷处理' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 37 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统权限模板表（导航栏面板）' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `system_permission_template` VALUES (34, '团队收益统计', 'team-revenue', '团队收益统计管理', NULL, 'ri-team-line', 'team-revenue', 6, 1, '2026-03-16 21:35:18', '2026-03-16 21:44:40', 1, 'team-revenueSection');
INSERT INTO `system_permission_template` VALUES (35, '团队收益概览', 'team-revenue-overview', '团队收益统计概览', 34, 'ri-pie-chart-line', 'team-revenue-overview', 1, 1, '2026-03-16 21:35:18', '2026-03-16 21:35:18', 2, 'teamRevenueContainer');
INSERT INTO `system_permission_template` VALUES (36, '团队收益明细', 'team-revenue-details', '团队收益详细记录', 34, 'ri-list-check', 'team-revenue-details', 2, 1, '2026-03-16 21:35:18', '2026-03-16 21:35:18', 2, 'teamRevenueDetailsContainer');

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
) ENGINE = InnoDB AUTO_INCREMENT = 501 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '角色权限模板关联表' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `system_role_permission_template` VALUES (418, 1, 4, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (419, 1, 11, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (420, 1, 22, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (421, 1, 30, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (422, 1, 31, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (423, 1, 23, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (424, 1, 32, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (425, 1, 33, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (426, 1, 9, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (427, 1, 12, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (428, 1, 13, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (429, 1, 14, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (430, 1, 19, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (431, 1, 5, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (432, 1, 6, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (433, 1, 7, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (434, 1, 8, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (435, 1, 10, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (436, 1, 15, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (437, 1, 16, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (438, 1, 17, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (439, 1, 18, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (440, 1, 20, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (441, 1, 21, '2026-03-16 23:02:00');

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
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '后台管理用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_users
-- ----------------------------
INSERT INTO `system_users` VALUES (1, 'task', '25d55ad283aa400af464c76d713c07ad', 'admin@example.com', '13800138000', 1, 'eyJ1c2VyX2lkIjoxLCJ0eXBlIjozLCJleHAiOjE3NzQ2Nzk4MjR9', '2026-03-28 14:37:04', 1, '2026-03-21 14:37:04', '2026-03-06 15:32:33', '2026-03-21 14:37:04');
INSERT INTO `system_users` VALUES (2, 'kefu', '2569d419bfea999ff13fd1f7f4498b89', 'kefu@qq.com', '15900000000', 5, '96e5c379ab22bc8165c9e5ccc37262ac', '2026-03-07 10:17:08', 1, '2026-03-06 18:17:08', '2026-03-06 18:09:15', '2026-03-11 12:31:19');
INSERT INTO `system_users` VALUES (3, 'shenji', 'e99a18c428cb38d5f260853678922e03', '', '15900000001', 7, 'eyJ1c2VyX2lkIjozLCJ0eXBlIjozLCJleHAiOjE3NzQyNzgxOTZ9', '2026-03-23 23:03:16', 1, '2026-03-16 23:03:16', '2026-03-06 18:16:16', '2026-03-16 23:03:16');
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
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '任务模板表-平台配置' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of task_templates
-- ----------------------------
INSERT INTO `task_templates` VALUES (1, 0, '上评评论', 3.00, '发布上评评论', '', NULL, NULL, NULL, NULL, 1, 3, 100, 50, 70, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (2, 0, '中评评论', 2.00, '发布中评评论', '', NULL, NULL, NULL, NULL, 3, 3, 100, 30, 50, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (3, 0, '放大镜搜索词', 5.00, '抖音平台规则问题，本产品属于概率出现蓝词，搜索词搜索次数就越多，出现概率越大', '', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (4, 1, '上中评评论', 9.00, '组合评论：上评+中评(1+3)', '', '上评评论', 3.00, '中评评论', 2.00, 1, 3, 0, 0, 0, 100, 50, 70, 100, 30, 50, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (5, 1, '上中评快捷派单', 7.00, '上中评快捷派单', '快捷派单，上评+中评（1+2），第二条中评带@', '上中评快捷派单-上评评论', 3.00, '上中评快捷派单-中评评论', 2.00, 1, 3, 0, 0, 0, 100, 50, 100, 80, 30, 50, 1, '2026-03-19 22:35:53');
INSERT INTO `task_templates` VALUES (6, 1, '中下评快捷派单', 6.00, '快捷派单：中评+下评(1+1)，下评带@', '-', '中评评论', 3.00, '下评评论', 3.00, 1, 1, 0, 0, 0, 150, 50, 100, 150, 50, 100, 1, '2026-02-15 14:51:45');

-- ----------------------------
-- Table structure for team_revenue_statistics_breakdown
-- ----------------------------
DROP TABLE IF EXISTS `team_revenue_statistics_breakdown`;
CREATE TABLE `team_revenue_statistics_breakdown`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `agent_id` bigint UNSIGNED NOT NULL COMMENT '代理用户ID（获得团队收益的人）',
  `agent_username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '代理用户名',
  `agent_level` tinyint NOT NULL COMMENT '代理层级：1=一级下线（直接邀请），2=二级下线（间接邀请）',
  `downline_user_id` bigint UNSIGNED NOT NULL COMMENT '下线用户ID（完成任务的人）',
  `downline_username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '下线用户名',
  `downline_user_amount` decimal(10, 2) NOT NULL COMMENT '下线完成任务获得的金额',
  `team_revenue_amount` decimal(10, 2) NOT NULL COMMENT '本次发放给代理的团队收益金额',
  `agent_before_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '变更前代理团队收益总额',
  `agent_after_amount` decimal(10, 2) NOT NULL COMMENT '变更后代理团队收益总额',
  `related_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '关联ID（任务ID或订单ID）',
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
) ENGINE = InnoDB AUTO_INCREMENT = 47 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '团队收益明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of team_revenue_statistics_breakdown
-- ----------------------------

-- ----------------------------
-- Table structure for team_revenue_statistics_summary
-- ----------------------------
DROP TABLE IF EXISTS `team_revenue_statistics_summary`;
CREATE TABLE `team_revenue_statistics_summary`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '用户ID（代理）',
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `total_team_revenue` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '总团队收益',
  `level1_team_revenue` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '一级下线贡献收益（agent_level=1）',
  `level2_team_revenue` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '二级下线贡献收益（agent_level=2）',
  `level1_downline_count` int NOT NULL DEFAULT 0 COMMENT '一级下线人数（直接邀请）',
  `level2_downline_count` int NOT NULL DEFAULT 0 COMMENT '二级下线人数（间接邀请）',
  `total_downline_count` int NOT NULL DEFAULT 0 COMMENT '总下线人数（去重）',
  `level1_active_count` int NOT NULL DEFAULT 0 COMMENT '活跃一级下线人数',
  `level2_active_count` int NOT NULL DEFAULT 0 COMMENT '活跃二级下线人数',
  `total_active_count` int NOT NULL DEFAULT 0 COMMENT '总活跃下线人数',
  `task_revenue_count` int NOT NULL DEFAULT 0 COMMENT '任务收益笔数',
  `order_revenue_count` int NOT NULL DEFAULT 0 COMMENT '订单收益笔数',
  `task_revenue_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '任务收益总额',
  `order_revenue_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '订单收益总额',
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
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '团队收益汇总表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of team_revenue_statistics_summary
-- ----------------------------

-- ----------------------------
-- Table structure for termination_rental_orders
-- ----------------------------
DROP TABLE IF EXISTS `termination_rental_orders`;
CREATE TABLE `termination_rental_orders`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '终止订单ID',
  `rental_order_id` bigint UNSIGNED NOT NULL COMMENT '原租赁订单ID',
  `termination_type` tinyint NOT NULL COMMENT '终止类型：1=终止租赁不退款，2=终止租赁并退款',
  `buyer_user_id` bigint UNSIGNED NOT NULL COMMENT '买方（租用方）用户ID',
  `buyer_user_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '买方类型：b=B端，c=C端',
  `seller_user_id` bigint UNSIGNED NOT NULL COMMENT '卖方（出租方）用户ID',
  `seller_user_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '卖方类型：b=B端，c=C端',
  `total_amount` bigint NOT NULL COMMENT '订单总金额（单位：分）',
  `refund_amount` bigint NOT NULL DEFAULT 0 COMMENT '退款金额（单位：分）',
  `seller_amount` bigint NOT NULL DEFAULT 0 COMMENT '卖方实得金额（单位：分）',
  `rented_days` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '已租赁天数',
  `remaining_days` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '剩余天数',
  `terminated_at` datetime NOT NULL COMMENT '终止时间',
  `admin_user_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '操作管理员ID',
  `order_json` json NULL COMMENT '订单额外数据（价格快照等）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_rental_order_id`(`rental_order_id` ASC) USING BTREE,
  INDEX `idx_buyer`(`buyer_user_id` ASC, `buyer_user_type` ASC) USING BTREE,
  INDEX `idx_seller`(`seller_user_id` ASC, `seller_user_type` ASC) USING BTREE,
  INDEX `idx_terminated_at`(`terminated_at` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '终止租赁订单表-记录终止租赁的相关数据' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of termination_rental_orders
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 125 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户通知表-每个用户收到的通知' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_notifications
-- ----------------------------
INSERT INTO `user_notifications` VALUES (124, 124, 8, 2, 0, NULL, '2026-03-21 14:37:14');

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

-- ----------------------------
-- Table structure for wallets
-- ----------------------------
DROP TABLE IF EXISTS `wallets`;
CREATE TABLE `wallets`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '钱包ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '关联用户ID',
  `user_type` tinyint NOT NULL DEFAULT 1 COMMENT '用户类型：1=C端，2=B端',
  `balance` bigint NOT NULL DEFAULT 0 COMMENT '余额（单位：分，100=1元）',
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_balance`(`balance` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_user_type`(`user_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 59 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '钱包表-三端共用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wallets
-- ----------------------------
INSERT INTO `wallets` VALUES (56, 8, 2, 18200, 'task', '2026-03-21 14:34:12', '2026-03-21 15:13:47');
INSERT INTO `wallets` VALUES (57, 127, 1, 0, 'ces1', '2026-03-21 14:35:13', '2026-03-21 14:35:13');
INSERT INTO `wallets` VALUES (58, 128, 1, 0, 'ces2', '2026-03-21 15:25:36', '2026-03-21 15:25:36');

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
) ENGINE = InnoDB AUTO_INCREMENT = 364 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '钱包流水表-记录所有收支' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wallets_log
-- ----------------------------
INSERT INTO `wallets_log` VALUES (359, 56, 8, 'task', 2, 1, 0, 0, 0, 'recharge', 19, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-03-21 14:36:51');
INSERT INTO `wallets_log` VALUES (360, 56, 8, 'task', 2, 1, 20000, 0, 20000, 'recharge', 19, NULL, NULL, '充值到账：¥200.00', '2026-03-21 14:37:14');
INSERT INTO `wallets_log` VALUES (361, 56, 8, 'task', 2, 2, 600, 20000, 19400, 'task', 218, 2, '中评评论', '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-21 14:43:12');
INSERT INTO `wallets_log` VALUES (362, 56, 8, 'task', 2, 2, 600, 19400, 18800, 'task', 219, 2, '中评评论', '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-21 15:01:42');
INSERT INTO `wallets_log` VALUES (363, 56, 8, 'task', 2, 2, 600, 18800, 18200, 'task', 220, 2, '中评评论', '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-21 15:13:47');

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
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '提现申请表-需要管理员审核' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of withdraw_requests
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
