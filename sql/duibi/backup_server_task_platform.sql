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

 Date: 21/03/2026 10:56:30
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
) ENGINE = InnoDB AUTO_INCREMENT = 39 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统通知表' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `admin_system_notification` VALUES (29, 'withdraw', '提现审核提醒', '有1条提现申请待审核', 1, 1, '{\"count\": 1}', '2026-03-11 22:24:29', '2026-03-14 13:47:56');
INSERT INTO `admin_system_notification` VALUES (30, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-11 22:24:29', '2026-03-14 13:47:56');
INSERT INTO `admin_system_notification` VALUES (31, 'recharge', '充值审核提醒', '有1条充值申请待审核', 1, 1, '{\"count\": 1}', '2026-03-11 22:40:29', '2026-03-14 13:47:56');
INSERT INTO `admin_system_notification` VALUES (32, 'magnifier', '放大镜任务提醒', '有1个新的放大镜任务', 1, 0, '{\"count\": 1}', '2026-03-12 16:56:26', '2026-03-14 13:47:56');
INSERT INTO `admin_system_notification` VALUES (33, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-14 13:48:26', '2026-03-15 20:35:24');
INSERT INTO `admin_system_notification` VALUES (34, 'recharge', '充值审核提醒', '有1条充值申请待审核', 1, 1, '{\"count\": 1}', '2026-03-14 13:50:26', '2026-03-15 20:35:24');
INSERT INTO `admin_system_notification` VALUES (35, 'magnifier', '放大镜任务提醒', '有1个新的放大镜任务', 1, 0, '{\"count\": 1}', '2026-03-14 14:21:26', '2026-03-15 20:35:24');
INSERT INTO `admin_system_notification` VALUES (36, 'withdraw', '提现审核提醒', '有1条提现申请待审核', 1, 1, '{\"count\": 1}', '2026-03-14 22:30:27', '2026-03-15 20:35:24');
INSERT INTO `admin_system_notification` VALUES (37, 'system', '系统通知', '{content}', 1, 0, '{\"count\": 0}', '2026-03-15 20:35:57', '2026-03-16 19:11:21');
INSERT INTO `admin_system_notification` VALUES (38, 'recharge', '充值审核提醒', '有1条充值申请待审核', 1, 1, '{\"count\": 1}', '2026-03-15 23:33:57', '2026-03-16 19:11:19');

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
) ENGINE = InnoDB AUTO_INCREMENT = 30 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '通知检测日志表' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `admin_system_notification_log` VALUES (23, '2026-03-12 16:56:26', 1, 1, '{\"agent\": 0, \"system\": 0, \"recharge\": 2, \"withdraw\": 1, \"magnifier\": 1}', '2026-03-12 16:56:26');
INSERT INTO `admin_system_notification_log` VALUES (24, '2026-03-14 13:48:26', 1, 1, '{\"agent\": 0, \"system\": 0, \"recharge\": 0, \"withdraw\": 0, \"magnifier\": 0}', '2026-03-14 13:48:26');
INSERT INTO `admin_system_notification_log` VALUES (25, '2026-03-14 13:50:26', 1, 1, '{\"agent\": 0, \"system\": 0, \"recharge\": 1, \"withdraw\": 0, \"magnifier\": 0}', '2026-03-14 13:50:26');
INSERT INTO `admin_system_notification_log` VALUES (26, '2026-03-14 14:21:26', 1, 1, '{\"agent\": 0, \"system\": 0, \"recharge\": 0, \"withdraw\": 0, \"magnifier\": 1}', '2026-03-14 14:21:26');
INSERT INTO `admin_system_notification_log` VALUES (27, '2026-03-14 22:30:27', 1, 1, '{\"agent\": 0, \"system\": 0, \"recharge\": 1, \"withdraw\": 1, \"magnifier\": 2}', '2026-03-14 22:30:27');
INSERT INTO `admin_system_notification_log` VALUES (28, '2026-03-15 20:35:57', 1, 1, '{\"agent\": 0, \"rental\": 0, \"system\": 0, \"recharge\": 0, \"withdraw\": 0, \"magnifier\": 0}', '2026-03-15 20:35:57');
INSERT INTO `admin_system_notification_log` VALUES (29, '2026-03-15 23:33:57', 1, 1, '{\"agent\": 0, \"rental\": 0, \"system\": 0, \"recharge\": 1, \"withdraw\": 0, \"magnifier\": 0}', '2026-03-15 23:33:57');

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
) ENGINE = InnoDB AUTO_INCREMENT = 6569 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '放大镜任务数量记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of admin_system_notification_magnifier_count
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '团长申请表-C端用户申请成为团长' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of agent_applications
-- ----------------------------
INSERT INTO `agent_applications` VALUES (1, 5, 'test', 'TX5ECJ', 1, 5, 0, 1, NULL, 1, '2026-03-09 21:24:51', '2026-03-09 21:24:51', '2026-03-09 21:24:51');
INSERT INTO `agent_applications` VALUES (2, 5, 'test', 'TX5ECJ', 2, 15, 0, 1, NULL, 1, '2026-03-09 21:24:53', '2026-03-09 21:24:53', '2026-03-09 21:24:53');
INSERT INTO `agent_applications` VALUES (3, 5, 'test', 'TX5ECJ', 2, 15, 0, 1, NULL, 1, '2026-03-14 23:46:01', '2026-03-14 23:46:01', '2026-03-14 23:46:01');
INSERT INTO `agent_applications` VALUES (4, 18, 'xiaoya', 'KZPAUU', 1, 5, 0, 1, NULL, 1, '2026-03-15 13:39:04', '2026-03-15 13:39:04', '2026-03-15 13:39:04');
INSERT INTO `agent_applications` VALUES (5, 22, 'SGYMQ', 'NB4FJA', 2, 15, 0, 1, NULL, 1, '2026-03-15 14:35:25', '2026-03-15 14:35:25', '2026-03-15 14:35:25');
INSERT INTO `agent_applications` VALUES (6, 42, 'xy25', 'UU4BBN', 1, 5, 0, 1, NULL, 1, '2026-03-16 13:16:01', '2026-03-16 13:16:01', '2026-03-16 13:16:01');
INSERT INTO `agent_applications` VALUES (7, 35, 'YUAN520', '2RUDMW', 1, 5, 0, 1, NULL, 1, '2026-03-16 13:16:21', '2026-03-16 13:16:21', '2026-03-16 13:16:21');
INSERT INTO `agent_applications` VALUES (8, 26, '1158799864', 'VH6XZ2', 1, 5, 0, 1, NULL, 1, '2026-03-16 13:16:57', '2026-03-16 13:16:57', '2026-03-16 13:16:57');
INSERT INTO `agent_applications` VALUES (9, 27, 'mjj20100316', 'CDXGAJ', 1, 5, 0, 1, NULL, 1, '2026-03-17 21:38:33', '2026-03-17 21:38:33', '2026-03-17 21:38:33');
INSERT INTO `agent_applications` VALUES (10, 18, 'xiaoya', 'KZPAUU', 2, 15, 0, 1, NULL, 1, '2026-03-17 21:46:47', '2026-03-17 21:46:47', '2026-03-17 21:46:47');

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
) ENGINE = InnoDB AUTO_INCREMENT = 45 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '网站配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of app_config
-- ----------------------------
INSERT INTO `app_config` VALUES (1, 'website', 'https://api.kktaskpaas.com/', 'string', 'general', '网站地址', '2026-02-28 21:29:30');
INSERT INTO `app_config` VALUES (2, 'upload_path', './img', 'string', 'general', '上传文件路径', '2026-02-15 14:51:56');
INSERT INTO `app_config` VALUES (3, 'platform_fee_rate', '0.25', 'float', 'general', '平台抽成比例（0.25 = 25%）', '2026-02-15 14:51:56');
INSERT INTO `app_config` VALUES (4, 'task_submit_timeout', '600', 'int', 'task', '任务提交超时时间（秒）', '2026-03-15 16:40:25');
INSERT INTO `app_config` VALUES (7, 'c_withdraw_min_amount', '1', 'int', 'withdraw', 'C端每次提现最低金额（元）', '2026-02-23 20:53:03');
INSERT INTO `app_config` VALUES (8, 'c_withdraw_max_amount', '500', 'int', 'withdraw', 'C端每次提现最高金额（元）', '2026-02-15 14:51:56');
INSERT INTO `app_config` VALUES (9, 'c_withdraw_amount_multiple', '1', 'int', 'withdraw', 'C端提现金额必须是此数的整数倍', '2026-02-23 20:53:12');
INSERT INTO `app_config` VALUES (10, 'c_withdraw_daily_limit', '1000', 'int', 'withdraw', 'C端每天提现总额限制（元）', '2026-02-15 14:51:56');
INSERT INTO `app_config` VALUES (11, 'c_withdraw_allowed_weekdays', '1-2-3-4-5-6-0', 'array', 'withdraw', '允许提现的星期几（0=周日,1-6=周一至周六，多个用逗号分隔）', '2026-03-15 00:21:16');
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
INSERT INTO `app_config` VALUES (37, 'notification_enabled', '1', 'boolean', 'notification', '是否启用消息通知', '2026-03-09 20:16:21');
INSERT INTO `app_config` VALUES (38, 'notification_sound_enabled', '1', 'boolean', 'notification', '是否启用通知提示音', '2026-03-09 20:16:21');
INSERT INTO `app_config` VALUES (39, 'notification_check_interval', '60', 'int', 'notification', '通知检测间隔（秒）', '2026-03-09 20:16:21');
INSERT INTO `app_config` VALUES (40, 'notification_max_unread', '50', 'int', 'notification', '最大未读通知数量', '2026-03-09 20:16:21');
INSERT INTO `app_config` VALUES (41, 'notification_types', 'recharge,withdraw,agent,magnifier,rental,ticket,system', 'array', 'notification', '启用的通知类型', '2026-03-09 20:16:21');
INSERT INTO `app_config` VALUES (42, 'large_group_agent', '0.8', 'float', 'agent', '大团团长佣金比例', '2026-03-21 10:29:58');

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
) ENGINE = InnoDB AUTO_INCREMENT = 128 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端任务统计表-记录B端用户所有金额变动' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of b_task_statistics
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 172 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端发布任务表-商家派单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of b_tasks
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端用户表-商家端' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of b_users
-- ----------------------------
INSERT INTO `b_users` VALUES (1, 'Ceshi', '271010169@qq.com', NULL, '$2y$10$SV7dHV/yam2IcgV5SmbbKur8TrpohySzBEQ032nQouiOnaBgmTWp6', 'Meili', 'Meili', 'eyJ1c2VyX2lkIjoxLCJ0eXBlIjoyLCJleHAiOjE3NzQ0MjUzNTV9', '2026-03-25 15:55:55', 1, 1, NULL, '34.143.229.197', '2026-02-27 11:49:20', '2026-03-18 15:55:55', 'server-side-device-id', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.0.8267.400', 1, '{\"device_id\":\"server-side-device-id\",\"device_name\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/123.0.0.0 Safari\\/537.36 QQBrowser\\/21.0.8267.400\",\"login_time\":\"2026-03-18 15:55:55\",\"last_activity\":\"2026-03-18 15:55:55\"}', '[{\"device_id\":\"server-side-device-id\",\"device_name\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/123.0.0.0 Safari\\/537.36 QQBrowser\\/21.0.8267.400\",\"login_time\":\"2026-03-18 15:55:55\",\"last_activity\":\"2026-03-18 15:55:55\"}]');
INSERT INTO `b_users` VALUES (2, 'Ceshi1', '459312160@qq.com', NULL, '$2y$10$F0HHwcgbu5Qh.xkir2UCcul4OHQPBYXwr970M4kIFVmdeZaDeh6ca', 'Meili', 'Meili', 'eyJ1c2VyX2lkIjoyLCJ0eXBlIjoyLCJleHAiOjE3NzQzNTA5MDF9', '2026-03-24 19:15:01', 2, 1, NULL, '34.143.229.197', '2026-02-27 12:02:50', '2026-03-17 19:15:01', 'server-side-device-id', 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1', 1, '{\"device_id\":\"server-side-device-id\",\"device_name\":\"Mozilla\\/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit\\/605.1.15 (KHTML, like Gecko) Version\\/16.0 Mobile\\/15E148 Safari\\/604.1\",\"login_time\":\"2026-03-17 19:15:01\",\"last_activity\":\"2026-03-17 19:15:01\"}', '[{\"device_id\":\"server-side-device-id\",\"device_name\":\"Mozilla\\/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit\\/605.1.15 (KHTML, like Gecko) Version\\/16.0 Mobile\\/15E148 Safari\\/604.1\",\"login_time\":\"2026-03-17 19:15:01\",\"last_activity\":\"2026-03-17 19:15:01\"}]');
INSERT INTO `b_users` VALUES (3, 'task', 'task@qq.com', NULL, '$2y$10$hkD.XBnEsk7iKbrYdpuxyOmrn.vME26Z1gzkXkBEXaUQMey5b3MAm', 'task', 'task', NULL, NULL, 7, 1, NULL, '223.74.60.135', '2026-03-01 00:48:16', '2026-03-16 09:52:19', 'server-side-device-id', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 1, '{\"device_id\":\"server-side-device-id\",\"device_name\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/146.0.0.0 Safari\\/537.36\",\"login_time\":\"2026-03-16 09:51:25\",\"last_activity\":\"2026-03-16 09:51:25\"}', '[{\"device_id\":\"server-side-device-id\",\"device_name\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/146.0.0.0 Safari\\/537.36\",\"login_time\":\"2026-03-16 09:51:25\",\"last_activity\":\"2026-03-16 09:51:25\"}]');
INSERT INTO `b_users` VALUES (4, '6666', '2625228169@qq.com', NULL, '$2y$10$cvmarlmOyyh0pZmNpZn2LeAEVveublaPt2QfK22mBGf/oH2789LyG', '11', 'QWE', NULL, NULL, 10, 1, NULL, '34.143.229.197', '2026-03-06 14:46:54', '2026-03-12 14:21:06', 'server-side-device-id', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.0.8257.400', 1, '{\"device_id\":\"server-side-device-id\",\"device_name\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/123.0.0.0 Safari\\/537.36 QQBrowser\\/21.0.8257.400\",\"login_time\":\"2026-03-12 13:57:51\",\"last_activity\":\"2026-03-12 13:57:51\"}', '[{\"device_id\":\"server-side-device-id\",\"device_name\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/123.0.0.0 Safari\\/537.36 QQBrowser\\/21.0.8257.400\",\"login_time\":\"2026-03-12 13:57:51\",\"last_activity\":\"2026-03-12 13:57:51\"}]');
INSERT INTO `b_users` VALUES (5, 'Ceshi3', '123456@gmail.com', '13145678910', '$2y$10$YIm6OTfuUhj5VxYfVWoSu.ONne..7NVIKVMYCx0zajHhzHeZqeQNG', '勇敢', '果断', 'eyJ1c2VyX2lkIjo1LCJ0eXBlIjoyLCJleHAiOjE3NzQwNjQ1NzN9', '2026-03-21 11:42:53', 11, 1, NULL, '34.143.229.197', '2026-03-08 12:06:11', '2026-03-14 11:42:53', 'b312730f2b9ca3edb2aa36e5cb717af5', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.2 Mobile/15E148 Safari/604.1', 1, '{\"device_id\":\"b312730f2b9ca3edb2aa36e5cb717af5\",\"device_name\":\"Mozilla\\/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit\\/605.1.15 (KHTML, like Gecko) Version\\/26.2 Mobile\\/15E148 Safari\\/604.1\",\"login_time\":\"2026-03-14 11:42:53\",\"last_activity\":\"2026-03-14 11:42:53\"}', '[{\"device_id\":\"b312730f2b9ca3edb2aa36e5cb717af5\",\"device_name\":\"Mozilla\\/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit\\/605.1.15 (KHTML, like Gecko) Version\\/26.2 Mobile\\/15E148 Safari\\/604.1\",\"login_time\":\"2026-03-14 11:42:53\",\"last_activity\":\"2026-03-14 11:42:53\"}]');
INSERT INTO `b_users` VALUES (6, 'hy123456', 'a123456789@qq.com', NULL, '$2y$10$iIBm8c5lUBBKsgQN1TcK/.mZrf/OXrjCzl9Wgtf6RmXRtJK9oB50G', 'hy', 'hy', 'eyJ1c2VyX2lkIjo2LCJ0eXBlIjoyLCJleHAiOjE3NzQxNTcyOTV9', '2026-03-22 13:28:15', 26, 1, NULL, '34.143.229.197', '2026-03-15 13:28:02', '2026-03-15 13:28:15', 'f19e165dbde9b16042e7affbca7e89d7', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.5845.97 Safari/537.36 SE 2.X MetaSr 1.0', 1, '{\"device_id\":\"f19e165dbde9b16042e7affbca7e89d7\",\"device_name\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/116.0.5845.97 Safari\\/537.36 SE 2.X MetaSr 1.0\",\"login_time\":\"2026-03-15 13:28:15\",\"last_activity\":\"2026-03-15 13:28:15\"}', '[{\"device_id\":\"f19e165dbde9b16042e7affbca7e89d7\",\"device_name\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/116.0.5845.97 Safari\\/537.36 SE 2.X MetaSr 1.0\",\"login_time\":\"2026-03-15 13:28:15\",\"last_activity\":\"2026-03-15 13:28:15\"}]');
INSERT INTO `b_users` VALUES (7, '3492391483', '3492391483@qq.com', '18933740929', '$2y$10$TgsFsVdCxmiX04o.goeYwOyJn/gcbgypSygxd.xPCD6sRA/1JnDti', 'uu', '八万', 'eyJ1c2VyX2lkIjo3LCJ0eXBlIjoyLCJleHAiOjE3NzQxNzExNjN9', '2026-03-22 17:19:23', 33, 1, NULL, '34.143.229.197', '2026-03-15 17:03:56', '2026-03-15 17:19:23', 'server-side-device-id', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.3 Mobile/15E148 Safari/604.1', 1, '{\"device_id\":\"server-side-device-id\",\"device_name\":\"Mozilla\\/5.0 (iPhone; CPU iPhone OS 18_3_1 like Mac OS X) AppleWebKit\\/605.1.15 (KHTML, like Gecko) Version\\/18.3 Mobile\\/15E148 Safari\\/604.1\",\"login_time\":\"2026-03-15 17:19:23\",\"last_activity\":\"2026-03-15 17:19:23\"}', '[{\"device_id\":\"server-side-device-id\",\"device_name\":\"Mozilla\\/5.0 (iPhone; CPU iPhone OS 18_3_1 like Mac OS X) AppleWebKit\\/605.1.15 (KHTML, like Gecko) Version\\/18.3 Mobile\\/15E148 Safari\\/604.1\",\"login_time\":\"2026-03-15 17:19:23\",\"last_activity\":\"2026-03-15 17:19:23\"}]');
INSERT INTO `b_users` VALUES (8, 'Ceshi0', '6666@qq.com', '13265498700', '$2y$10$cn83iH57qYPvpNj1LQoN/ejc3T09tDvcFJia4nOvfm/XyzhSPq53m', '中华', '中华', 'eyJ1c2VyX2lkIjo4LCJ0eXBlIjoyLCJleHAiOjE3NzQzNjIxOTJ9', '2026-03-24 22:23:12', 74, 1, NULL, '34.143.229.197', '2026-03-17 19:27:19', '2026-03-17 22:23:12', 'f5b3907aa145671fab0e3be584658d45', 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.5845.97 Safari/537.36 SE 2.X MetaSr 1.0', 1, '{\"device_id\":\"f5b3907aa145671fab0e3be584658d45\",\"device_name\":\"Mozilla\\/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/116.0.5845.97 Safari\\/537.36 SE 2.X MetaSr 1.0\",\"login_time\":\"2026-03-17 22:23:12\",\"last_activity\":\"2026-03-17 22:23:12\"}', '[{\"device_id\":\"f5b3907aa145671fab0e3be584658d45\",\"device_name\":\"Mozilla\\/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/116.0.5845.97 Safari\\/537.36 SE 2.X MetaSr 1.0\",\"login_time\":\"2026-03-17 22:23:12\",\"last_activity\":\"2026-03-17 22:23:12\"}]');

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
) ENGINE = InnoDB AUTO_INCREMENT = 284 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端任务记录表-接单执行审核全流程' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of c_task_records
-- ----------------------------

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
  `record_status` tinyint UNSIGNED NULL DEFAULT 0 COMMENT '记录状态：0=待处理，1=进行中，2=待审核，3=已完成，4=待支付,5=已过期,6=已驳回,7=已暂停，8=已取消,9=已退款',
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
) ENGINE = InnoDB AUTO_INCREMENT = 242 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端任务统计表-记录C端用户所有金额变动' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'C端用户代理等级跃迁历史表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of c_user_agent_upgrade_history
-- ----------------------------
INSERT INTO `c_user_agent_upgrade_history` VALUES (5, 5, 'test', 0, 1, 1, '2026-03-09 21:24:51');
INSERT INTO `c_user_agent_upgrade_history` VALUES (6, 5, 'test', 1, 2, 1, '2026-03-09 21:24:53');
INSERT INTO `c_user_agent_upgrade_history` VALUES (7, 5, 'test', 2, 3, 1, '2026-03-14 23:46:01');
INSERT INTO `c_user_agent_upgrade_history` VALUES (8, 18, 'xiaoya', 0, 1, 1, '2026-03-15 13:39:04');
INSERT INTO `c_user_agent_upgrade_history` VALUES (9, 22, 'SGYMQ', 0, 3, 1, '2026-03-15 14:35:25');
INSERT INTO `c_user_agent_upgrade_history` VALUES (10, 42, 'xy25', 0, 1, 1, '2026-03-16 13:16:01');
INSERT INTO `c_user_agent_upgrade_history` VALUES (11, 35, 'YUAN520', 0, 1, 1, '2026-03-16 13:16:21');
INSERT INTO `c_user_agent_upgrade_history` VALUES (12, 26, '1158799864', 0, 1, 1, '2026-03-16 13:16:57');
INSERT INTO `c_user_agent_upgrade_history` VALUES (13, 27, 'mjj20100316', 0, 1, 1, '2026-03-17 21:38:33');
INSERT INTO `c_user_agent_upgrade_history` VALUES (14, 18, 'xiaoya', 1, 3, 1, '2026-03-17 21:46:47');

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
) ENGINE = InnoDB AUTO_INCREMENT = 75 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端用户每日统计表-限制驳回次数' ROW_FORMAT = Dynamic;

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
INSERT INTO `c_user_daily_stats` VALUES (13, 18, '2026-03-13', 5, 4, 3, 1, '2026-03-13 12:44:14', '2026-03-13 13:45:14');
INSERT INTO `c_user_daily_stats` VALUES (14, 19, '2026-03-13', 2, 1, 1, 0, '2026-03-13 12:49:56', '2026-03-13 13:56:01');
INSERT INTO `c_user_daily_stats` VALUES (15, 5, '2026-03-13', 2, 0, 0, 0, '2026-03-13 21:24:08', '2026-03-13 22:25:14');
INSERT INTO `c_user_daily_stats` VALUES (16, 19, '2026-03-14', 2, 2, 2, 0, '2026-03-14 07:45:16', '2026-03-14 08:45:01');
INSERT INTO `c_user_daily_stats` VALUES (17, 5, '2026-03-14', 17, 16, 15, 1, '2026-03-14 09:29:22', '2026-03-14 23:40:44');
INSERT INTO `c_user_daily_stats` VALUES (18, 6, '2026-03-14', 3, 3, 3, 0, '2026-03-14 23:47:59', '2026-03-14 23:50:01');
INSERT INTO `c_user_daily_stats` VALUES (19, 5, '2026-03-15', 4, 3, 2, 1, '2026-03-15 10:54:21', '2026-03-15 12:14:28');
INSERT INTO `c_user_daily_stats` VALUES (20, 19, '2026-03-15', 1, 0, 0, 0, '2026-03-15 14:06:24', '2026-03-15 14:06:24');
INSERT INTO `c_user_daily_stats` VALUES (21, 21, '2026-03-15', 14, 10, 8, 2, '2026-03-15 14:08:20', '2026-03-15 20:52:32');
INSERT INTO `c_user_daily_stats` VALUES (22, 22, '2026-03-15', 4, 3, 2, 1, '2026-03-15 14:23:31', '2026-03-15 21:33:43');
INSERT INTO `c_user_daily_stats` VALUES (23, 23, '2026-03-15', 7, 4, 2, 2, '2026-03-15 16:07:12', '2026-03-15 21:47:01');
INSERT INTO `c_user_daily_stats` VALUES (24, 26, '2026-03-15', 4, 0, 0, 0, '2026-03-15 16:56:00', '2026-03-15 23:00:36');
INSERT INTO `c_user_daily_stats` VALUES (25, 25, '2026-03-15', 9, 9, 5, 4, '2026-03-15 17:04:24', '2026-03-15 18:38:01');
INSERT INTO `c_user_daily_stats` VALUES (26, 27, '2026-03-15', 3, 3, 0, 3, '2026-03-15 17:23:48', '2026-03-15 17:36:42');
INSERT INTO `c_user_daily_stats` VALUES (27, 18, '2026-03-15', 2, 2, 1, 1, '2026-03-15 17:49:28', '2026-03-15 18:40:19');
INSERT INTO `c_user_daily_stats` VALUES (28, 28, '2026-03-15', 5, 3, 3, 0, '2026-03-15 18:24:54', '2026-03-15 21:13:14');
INSERT INTO `c_user_daily_stats` VALUES (29, 35, '2026-03-15', 1, 1, 0, 1, '2026-03-15 19:34:33', '2026-03-15 19:48:04');
INSERT INTO `c_user_daily_stats` VALUES (30, 30, '2026-03-15', 7, 6, 2, 4, '2026-03-15 19:47:12', '2026-03-15 20:28:01');
INSERT INTO `c_user_daily_stats` VALUES (31, 33, '2026-03-15', 2, 0, 0, 0, '2026-03-15 19:51:20', '2026-03-15 20:28:53');
INSERT INTO `c_user_daily_stats` VALUES (32, 31, '2026-03-15', 8, 3, 2, 1, '2026-03-15 19:51:57', '2026-03-15 21:54:10');
INSERT INTO `c_user_daily_stats` VALUES (33, 36, '2026-03-15', 7, 6, 5, 1, '2026-03-15 19:58:12', '2026-03-15 21:50:45');
INSERT INTO `c_user_daily_stats` VALUES (34, 37, '2026-03-15', 2, 0, 0, 0, '2026-03-15 20:02:14', '2026-03-15 20:16:43');
INSERT INTO `c_user_daily_stats` VALUES (35, 39, '2026-03-15', 1, 0, 0, 0, '2026-03-15 20:14:40', '2026-03-15 20:14:40');
INSERT INTO `c_user_daily_stats` VALUES (36, 41, '2026-03-15', 1, 1, 0, 1, '2026-03-15 20:26:08', '2026-03-15 20:30:10');
INSERT INTO `c_user_daily_stats` VALUES (37, 32, '2026-03-15', 1, 0, 0, 0, '2026-03-15 20:52:09', '2026-03-15 20:52:09');
INSERT INTO `c_user_daily_stats` VALUES (38, 42, '2026-03-15', 4, 1, 1, 0, '2026-03-15 21:38:15', '2026-03-15 22:20:42');
INSERT INTO `c_user_daily_stats` VALUES (39, 30, '2026-03-16', 1, 1, 1, 0, '2026-03-16 00:27:41', '2026-03-16 00:40:02');
INSERT INTO `c_user_daily_stats` VALUES (40, 37, '2026-03-16', 3, 3, 3, 0, '2026-03-16 07:23:10', '2026-03-16 07:48:01');
INSERT INTO `c_user_daily_stats` VALUES (41, 5, '2026-03-16', 1, 1, 1, 0, '2026-03-16 09:50:14', '2026-03-16 09:51:35');
INSERT INTO `c_user_daily_stats` VALUES (42, 30, '2026-03-17', 4, 4, 1, 3, '2026-03-17 09:38:31', '2026-03-17 10:05:06');
INSERT INTO `c_user_daily_stats` VALUES (43, 47, '2026-03-17', 1, 0, 0, 0, '2026-03-17 09:54:25', '2026-03-17 09:54:25');
INSERT INTO `c_user_daily_stats` VALUES (44, 22, '2026-03-17', 12, 4, 3, 1, '2026-03-17 09:57:48', '2026-03-17 22:39:43');
INSERT INTO `c_user_daily_stats` VALUES (45, 31, '2026-03-17', 1, 0, 0, 0, '2026-03-17 10:05:38', '2026-03-17 10:05:38');
INSERT INTO `c_user_daily_stats` VALUES (46, 5, '2026-03-17', 5, 4, 0, 4, '2026-03-17 10:06:12', '2026-03-17 22:22:11');
INSERT INTO `c_user_daily_stats` VALUES (47, 28, '2026-03-17', 2, 0, 0, 0, '2026-03-17 10:12:59', '2026-03-17 20:00:24');
INSERT INTO `c_user_daily_stats` VALUES (48, 42, '2026-03-17', 5, 0, 0, 0, '2026-03-17 10:19:08', '2026-03-17 20:29:12');
INSERT INTO `c_user_daily_stats` VALUES (49, 36, '2026-03-17', 3, 3, 0, 3, '2026-03-17 10:23:20', '2026-03-17 10:31:14');
INSERT INTO `c_user_daily_stats` VALUES (50, 55, '2026-03-17', 1, 0, 0, 0, '2026-03-17 11:35:45', '2026-03-17 11:35:45');
INSERT INTO `c_user_daily_stats` VALUES (51, 56, '2026-03-17', 1, 0, 0, 0, '2026-03-17 11:44:20', '2026-03-17 11:44:20');
INSERT INTO `c_user_daily_stats` VALUES (52, 50, '2026-03-17', 1, 1, 1, 0, '2026-03-17 12:09:15', '2026-03-17 12:27:01');
INSERT INTO `c_user_daily_stats` VALUES (53, 35, '2026-03-17', 6, 0, 0, 0, '2026-03-17 12:47:50', '2026-03-17 21:41:08');
INSERT INTO `c_user_daily_stats` VALUES (54, 57, '2026-03-17', 1, 0, 0, 0, '2026-03-17 13:16:14', '2026-03-17 13:16:14');
INSERT INTO `c_user_daily_stats` VALUES (55, 58, '2026-03-17', 7, 7, 7, 0, '2026-03-17 13:57:23', '2026-03-17 14:48:02');
INSERT INTO `c_user_daily_stats` VALUES (56, 60, '2026-03-17', 3, 2, 2, 0, '2026-03-17 15:09:46', '2026-03-17 15:30:02');
INSERT INTO `c_user_daily_stats` VALUES (57, 62, '2026-03-17', 12, 12, 7, 5, '2026-03-17 15:28:33', '2026-03-17 19:09:12');
INSERT INTO `c_user_daily_stats` VALUES (58, 63, '2026-03-17', 12, 10, 9, 1, '2026-03-17 16:28:05', '2026-03-17 22:04:42');
INSERT INTO `c_user_daily_stats` VALUES (59, 40, '2026-03-17', 7, 7, 2, 5, '2026-03-17 17:13:01', '2026-03-17 18:31:01');
INSERT INTO `c_user_daily_stats` VALUES (60, 64, '2026-03-17', 7, 7, 3, 4, '2026-03-17 18:35:39', '2026-03-17 18:58:36');
INSERT INTO `c_user_daily_stats` VALUES (61, 65, '2026-03-17', 4, 1, 0, 1, '2026-03-17 19:04:15', '2026-03-17 20:16:27');
INSERT INTO `c_user_daily_stats` VALUES (62, 66, '2026-03-17', 1, 0, 0, 0, '2026-03-17 19:22:07', '2026-03-17 19:22:07');
INSERT INTO `c_user_daily_stats` VALUES (63, 27, '2026-03-17', 6, 4, 2, 2, '2026-03-17 19:32:43', '2026-03-17 21:15:02');
INSERT INTO `c_user_daily_stats` VALUES (64, 48, '2026-03-17', 3, 0, 0, 0, '2026-03-17 19:40:00', '2026-03-17 20:03:48');
INSERT INTO `c_user_daily_stats` VALUES (65, 67, '2026-03-17', 1, 0, 0, 0, '2026-03-17 19:57:21', '2026-03-17 19:57:21');
INSERT INTO `c_user_daily_stats` VALUES (66, 68, '2026-03-17', 1, 0, 0, 0, '2026-03-17 20:04:33', '2026-03-17 20:04:33');
INSERT INTO `c_user_daily_stats` VALUES (67, 18, '2026-03-17', 2, 1, 1, 0, '2026-03-17 20:10:45', '2026-03-17 22:15:35');
INSERT INTO `c_user_daily_stats` VALUES (68, 25, '2026-03-17', 5, 2, 1, 1, '2026-03-17 20:18:02', '2026-03-17 21:07:42');
INSERT INTO `c_user_daily_stats` VALUES (69, 69, '2026-03-17', 3, 0, 0, 0, '2026-03-17 21:09:38', '2026-03-17 21:34:49');
INSERT INTO `c_user_daily_stats` VALUES (70, 71, '2026-03-17', 1, 0, 0, 0, '2026-03-17 22:20:41', '2026-03-17 22:20:41');
INSERT INTO `c_user_daily_stats` VALUES (71, 53, '2026-03-17', 3, 3, 3, 0, '2026-03-17 22:54:11', '2026-03-17 23:22:01');
INSERT INTO `c_user_daily_stats` VALUES (72, 72, '2026-03-17', 2, 2, 2, 0, '2026-03-17 23:38:41', '2026-03-17 23:58:02');
INSERT INTO `c_user_daily_stats` VALUES (73, 62, '2026-03-18', 2, 0, 0, 0, '2026-03-18 00:00:36', '2026-03-18 00:12:52');
INSERT INTO `c_user_daily_stats` VALUES (74, 48, '2026-03-18', 1, 0, 0, 0, '2026-03-18 00:06:12', '2026-03-18 00:06:12');

-- ----------------------------
-- Table structure for c_user_relations
-- ----------------------------
DROP TABLE IF EXISTS `c_user_relations`;
CREATE TABLE `c_user_relations`  (
  `id` int(10) UNSIGNED ZEROFILL NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `agent_id` bigint UNSIGNED NOT NULL,
  `level` tinyint NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `unique_user_agent`(`user_id` ASC, `agent_id` ASC, `level` ASC) USING BTREE,
  INDEX `agent_id`(`agent_id` ASC) USING BTREE,
  CONSTRAINT `c_user_relations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `c_users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `c_user_relations_ibfk_2` FOREIGN KEY (`agent_id`) REFERENCES `c_users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 46 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '一级邀请二级邀请关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of c_user_relations
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 78 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端用户表-消费者端' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of c_users
-- ----------------------------
INSERT INTO `c_users` VALUES (1, 'taskadmin', 'taskadmin@qq.com', NULL, '$2y$10$9gww7TqOTzSA9SqchkFEgeYftRKlJ4ciYWL6IiD8DPUbQv8/PnCGe', 'W6XMFJ', NULL, NULL, 0, 'eyJ1c2VyX2lkIjoxLCJ0eXBlIjoxLCJleHAiOjE3NzI3NzM1OTN9', '2026-03-06 13:06:33', 3, 1, NULL, '120.237.23.202', '2026-02-27 13:06:22', '2026-02-27 13:06:33', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (2, 'Ceshi', '12345678@qq.com', '13112345678', '$2y$10$hkD.XBnEsk7iKbrYdpuxyOmrn.vME26Z1gzkXkBEXaUQMey5b3MAm', '6YHUBA', NULL, NULL, 0, 'eyJ1c2VyX2lkIjoyLCJ0eXBlIjoxLCJleHAiOjE3NzQxNTk0Mzh9', '2026-03-22 14:03:58', 4, 1, NULL, '34.143.229.197', '2026-02-27 17:24:33', '2026-03-15 14:03:58', 0, NULL, NULL, NULL, '35aa9b33da8a7c5e4f350928f43ad299', 'Win32 Mozilla/5.0', 1, '{\"device_id\":\"35aa9b33da8a7c5e4f350928f43ad299\",\"device_name\":\"Win32 Mozilla\\/5.0\",\"login_time\":\"2026-03-15 14:03:58\",\"last_activity\":\"2026-03-15 14:03:58\"}', '[{\"device_id\":\"35aa9b33da8a7c5e4f350928f43ad299\",\"device_name\":\"Win32 Mozilla\\/5.0\",\"login_time\":\"2026-03-15 14:03:58\",\"last_activity\":\"2026-03-15 14:03:58\"}]');
INSERT INTO `c_users` VALUES (3, 'Ceshi2', '123456789@qq.com', '13212345678', '$2y$10$Cvl7CIY5Oj2gPcKSvNE2mONLRs14Rr1ndstVn2FHJlco8GmXxS586', 'MCVFM9', NULL, NULL, 0, 'eyJ1c2VyX2lkIjozLCJ0eXBlIjoxLCJleHAiOjE3NzI3OTMxODh9', '2026-03-06 18:33:08', 5, 1, NULL, '34.143.229.197', '2026-02-27 17:26:28', '2026-02-27 18:33:08', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (4, 'Ceshi3', '123455677@qq.com', '13312345678', '$2y$10$qydW3B1EXlxJou5CUfPMaOvssOD/K8GugvQh.BeeX/KGBpPGC3awq', 'CZBBF5', NULL, NULL, 0, 'eyJ1c2VyX2lkIjo0LCJ0eXBlIjoxLCJleHAiOjE3NzI3ODk0Njh9', '2026-03-06 17:31:08', 6, 1, NULL, '34.143.229.197', '2026-02-27 17:31:08', '2026-02-27 17:31:08', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (5, 'test', 'test@qq.com', '15900000011', '$2y$10$hkD.XBnEsk7iKbrYdpuxyOmrn.vME26Z1gzkXkBEXaUQMey5b3MAm', 'TX5ECJ', NULL, NULL, 2, NULL, NULL, 8, 1, NULL, '223.74.60.135', '2026-03-01 00:53:23', '2026-03-21 10:08:37', 0, NULL, NULL, NULL, '35aa9b33da8a7c5e4f350928f43ad299', 'Win32 Mozilla/5.0', 1, '{\"device_id\":\"35aa9b33da8a7c5e4f350928f43ad299\",\"device_name\":\"Win32 Mozilla\\/5.0\",\"login_time\":\"2026-03-21 10:07:42\",\"last_activity\":\"2026-03-21 10:07:42\"}', '[{\"device_id\":\"35aa9b33da8a7c5e4f350928f43ad299\",\"device_name\":\"Win32 Mozilla\\/5.0\",\"login_time\":\"2026-03-21 10:07:42\",\"last_activity\":\"2026-03-21 10:07:42\"}]');
INSERT INTO `c_users` VALUES (6, 'tasktest', '', '13794719208', '$2y$10$hkD.XBnEsk7iKbrYdpuxyOmrn.vME26Z1gzkXkBEXaUQMey5b3MAm', 'Z2AYEM', 5, NULL, 2, 'eyJ1c2VyX2lkIjo2LCJ0eXBlIjoxLCJleHAiOjE3NzQxMTAxMDF9', '2026-03-22 00:21:41', 9, 1, NULL, '223.74.60.135', '2026-03-02 00:12:06', '2026-03-15 00:21:41', 0, NULL, NULL, NULL, 'f989d1cf067071e57e5afa61e6587acc', 'Win32 Mozilla/5.0', 1, '{\"device_id\":\"f989d1cf067071e57e5afa61e6587acc\",\"device_name\":\"Win32 Mozilla\\/5.0\",\"login_time\":\"2026-03-15 00:21:41\",\"last_activity\":\"2026-03-15 00:21:41\"}', '[{\"device_id\":\"f989d1cf067071e57e5afa61e6587acc\",\"device_name\":\"Win32 Mozilla\\/5.0\",\"login_time\":\"2026-03-15 00:21:41\",\"last_activity\":\"2026-03-15 00:21:41\"}]');
INSERT INTO `c_users` VALUES (18, 'xiaoya', NULL, '13049610316', '$2y$10$s1KchbOeEqAqEGP1DjV15O4ZLf5yOKvNAE0.yphtXxvtwNo0Z6upG', 'KZPAUU', 5, NULL, 3, 'eyJ1c2VyX2lkIjoxOCwidHlwZSI6MSwiZXhwIjoxNzc0NDI1NTY0fQ==', '2026-03-25 15:59:24', 23, 1, NULL, '223.74.60.185', '2026-03-11 12:23:27', '2026-03-18 15:59:24', 0, NULL, NULL, NULL, 'd4bdb37a26509bbc496ede416e5756cc', 'Win32 Mozilla/5.0', 1, '{\"device_id\":\"d4bdb37a26509bbc496ede416e5756cc\",\"device_name\":\"Win32 Mozilla\\/5.0\",\"login_time\":\"2026-03-18 15:59:24\",\"last_activity\":\"2026-03-18 15:59:24\"}', '[{\"device_id\":\"d4bdb37a26509bbc496ede416e5756cc\",\"device_name\":\"Win32 Mozilla\\/5.0\",\"login_time\":\"2026-03-18 15:59:24\",\"last_activity\":\"2026-03-18 15:59:24\"}]');
INSERT INTO `c_users` VALUES (19, 'Kenwan', 'null@qq.com', '13257620552', '$2y$10$CH2SlVv03LLAM75gqjtHyOXjhqa3KYePjrarJm9EbMN4BqwaSfPSS', 'H8P2UG', 18, NULL, 0, 'eyJ1c2VyX2lkIjoxOSwidHlwZSI6MSwiZXhwIjoxNzc0MTU4NTU5fQ==', '2026-03-22 13:49:19', 24, 1, NULL, '34.143.229.197', '2026-03-13 12:47:21', '2026-03-15 13:49:19', 0, NULL, NULL, NULL, 'f5b3907aa145671fab0e3be584658d45', 'Win32 Mozilla/5.0', 1, '{\"device_id\":\"f5b3907aa145671fab0e3be584658d45\",\"device_name\":\"Win32 Mozilla\\/5.0\",\"login_time\":\"2026-03-15 13:49:19\",\"last_activity\":\"2026-03-15 13:49:19\"}', '[{\"device_id\":\"f5b3907aa145671fab0e3be584658d45\",\"device_name\":\"Win32 Mozilla\\/5.0\",\"login_time\":\"2026-03-15 13:49:19\",\"last_activity\":\"2026-03-15 13:49:19\"}]');
INSERT INTO `c_users` VALUES (20, '716716888', NULL, '17888643125', '$2y$10$aXFU.lAniJe8.z.kkuipVOrY0ANjku.pWnrkPSdH3rRMohQhRaeAC', 'BTKW7A', 5, NULL, 0, 'eyJ1c2VyX2lkIjoyMCwidHlwZSI6MSwiZXhwIjoxNzc0MTU0NjkzfQ==', '2026-03-22 12:44:53', 25, 1, NULL, '34.143.229.197', '2026-03-15 12:42:31', '2026-03-15 12:44:53', 0, NULL, NULL, NULL, '64825d714400faca673529a3a42d6c68', 'iPhone', 1, '{\"device_id\":\"64825d714400faca673529a3a42d6c68\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-15 12:44:53\",\"last_activity\":\"2026-03-15 12:44:53\"}', '[{\"device_id\":\"64825d714400faca673529a3a42d6c68\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-15 12:44:53\",\"last_activity\":\"2026-03-15 12:44:53\"}]');
INSERT INTO `c_users` VALUES (21, 'LF0730', NULL, '15073009153', '$2y$10$Md/wGNlek9OCSMNT2aAsMeXZPdMtEWIHGWQYkViCQmM5gZ/YkOacu', 'K9mPx2', 23, NULL, 0, 'eyJ1c2VyX2lkIjoyMSwidHlwZSI6MSwiZXhwIjoxNzc0NDk5MzY4fQ==', '2026-03-26 12:29:28', 27, 1, NULL, '34.143.229.197', '2026-03-15 13:52:44', '2026-03-19 12:29:28', 0, NULL, NULL, NULL, '2eb3df2e815b5b652db08c1395f5ae55', 'zh-cn', 1, '{\"device_id\":\"2eb3df2e815b5b652db08c1395f5ae55\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-19 12:29:28\",\"last_activity\":\"2026-03-19 12:29:28\"}', '[{\"device_id\":\"2eb3df2e815b5b652db08c1395f5ae55\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-19 12:29:28\",\"last_activity\":\"2026-03-19 12:29:28\"}]');
INSERT INTO `c_users` VALUES (22, 'SGYMQ', NULL, '13829805453', '$2y$10$fSqelh523k5n9fG1/5rLpOGGhUeeyKaOabXOs7TCH6Njh5THanNzu', 'NB4FJA', 5, NULL, 3, 'eyJ1c2VyX2lkIjoyMiwidHlwZSI6MSwiZXhwIjoxNzc0NDI4NTM0fQ==', '2026-03-25 16:48:54', 28, 1, NULL, '34.143.229.197', '2026-03-15 14:22:08', '2026-03-18 16:48:54', 0, NULL, NULL, NULL, 'b12ab4ddf1ac35fbc4f576c372eb044b', 'zh-CN', 1, '{\"device_id\":\"b12ab4ddf1ac35fbc4f576c372eb044b\",\"device_name\":\"zh-CN\",\"login_time\":\"2026-03-18 16:48:54\",\"last_activity\":\"2026-03-18 16:48:54\"}', '[{\"device_id\":\"b12ab4ddf1ac35fbc4f576c372eb044b\",\"device_name\":\"zh-CN\",\"login_time\":\"2026-03-18 16:48:54\",\"last_activity\":\"2026-03-18 16:48:54\"}]');
INSERT INTO `c_users` VALUES (23, '840112512512', NULL, '18874021967', '$2y$10$3psNbu8YCwiJAd6LEAiwkOqNpQi05j/8svaS0.AmQbAh6wKL03bJy', 'VUZJWG', 5, NULL, 2, 'eyJ1c2VyX2lkIjoyMywidHlwZSI6MSwiZXhwIjoxNzc0NDk1MTE3fQ==', '2026-03-26 11:18:37', 29, 1, NULL, '34.143.229.197', '2026-03-15 15:05:50', '2026-03-19 11:18:37', 0, NULL, NULL, NULL, 'd1be6d4ad0e3b046a4567609b19fa91c', 'PHM110 Build/AP3A.240617.008', 1, '{\"device_id\":\"d1be6d4ad0e3b046a4567609b19fa91c\",\"device_name\":\"PHM110 Build\\/AP3A.240617.008\",\"login_time\":\"2026-03-19 11:18:37\",\"last_activity\":\"2026-03-19 11:18:37\"}', '[{\"device_id\":\"d1be6d4ad0e3b046a4567609b19fa91c\",\"device_name\":\"PHM110 Build\\/AP3A.240617.008\",\"login_time\":\"2026-03-19 11:18:37\",\"last_activity\":\"2026-03-19 11:18:37\"}]');
INSERT INTO `c_users` VALUES (24, 'jwf888', NULL, '13028828678', '$2y$10$oVRphofDmt.d9BcaRjDvC.mLDYExLji8fZrDgdGXMQkm0t1z.ETlu', 'RNFJJA', 5, NULL, 0, 'eyJ1c2VyX2lkIjoyNCwidHlwZSI6MSwiZXhwIjoxNzc0MTY0Nzg2fQ==', '2026-03-22 15:33:06', 30, 1, NULL, '34.143.229.197', '2026-03-15 15:33:06', '2026-03-15 15:33:06', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (25, 'na0430', NULL, '19317932440', '$2y$10$OZ9DMKAV0VkFua2xH3dWiO2TyBVw09Cqr3wFjGCp4wVxzHKiXOc7G', 'ZJZ353', 22, NULL, 0, 'eyJ1c2VyX2lkIjoyNSwidHlwZSI6MSwiZXhwIjoxNzc0NTc4NTMwfQ==', '2026-03-27 10:28:50', 31, 1, NULL, '34.143.229.197', '2026-03-15 16:48:38', '2026-03-20 10:28:50', 0, NULL, NULL, NULL, '4853be6bddae5ebf3f90622fbd512067', 'iPhone', 1, '{\"device_id\":\"4853be6bddae5ebf3f90622fbd512067\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-20 10:28:50\",\"last_activity\":\"2026-03-20 10:28:50\"}', '[{\"device_id\":\"4853be6bddae5ebf3f90622fbd512067\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-20 10:28:50\",\"last_activity\":\"2026-03-20 10:28:50\"}]');
INSERT INTO `c_users` VALUES (26, '1158799864', NULL, '15156763788', '$2y$10$xvpzk1I7FQqXIX2b8/WMgO2mzZFmT7BPjqWKv4nzdsA4lTQln2dMS', 'VH6XZ2', 22, NULL, 1, 'eyJ1c2VyX2lkIjoyNiwidHlwZSI6MSwiZXhwIjoxNzc0MTgxODk0fQ==', '2026-03-22 20:18:14', 32, 1, NULL, '34.143.229.197', '2026-03-15 16:55:20', '2026-03-16 13:16:57', 0, NULL, NULL, NULL, '98a8be506cb34dc8a88a530d6c4acac8', 'zh-cn', 1, '{\"device_id\":\"98a8be506cb34dc8a88a530d6c4acac8\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-15 20:18:14\",\"last_activity\":\"2026-03-15 20:18:14\"}', '[{\"device_id\":\"98a8be506cb34dc8a88a530d6c4acac8\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-15 20:18:14\",\"last_activity\":\"2026-03-15 20:18:14\"}]');
INSERT INTO `c_users` VALUES (27, 'mjj20100316', NULL, '15299266549', '$2y$10$L2GnFMnZCpxbRqk6pj.OFuEohsPxwqScmDXJKW8/4GvJVCX218luK', 'CDXGAJ', 22, NULL, 1, 'eyJ1c2VyX2lkIjoyNywidHlwZSI6MSwiZXhwIjoxNzc0NjA0Mjc0fQ==', '2026-03-27 17:37:54', 34, 1, NULL, '34.143.229.197', '2026-03-15 17:22:13', '2026-03-20 17:37:54', 0, NULL, NULL, NULL, 'a89a07780467e385548347bbeebad032', 'zh-cn', 1, '{\"device_id\":\"a89a07780467e385548347bbeebad032\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-20 17:37:54\",\"last_activity\":\"2026-03-20 17:37:54\"}', '[{\"device_id\":\"a89a07780467e385548347bbeebad032\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-20 17:37:54\",\"last_activity\":\"2026-03-20 17:37:54\"}]');
INSERT INTO `c_users` VALUES (28, 'swen', NULL, '18815550392', '$2y$10$9le9FjJ4mkeXV4yeyoykUuhhEQfma36m20oXrY8bLqYKfm2imVqHG', '3U3UMU', 26, NULL, 0, 'eyJ1c2VyX2lkIjoyOCwidHlwZSI6MSwiZXhwIjoxNzc0MzUzNTk5fQ==', '2026-03-24 19:59:59', 35, 1, NULL, '34.143.229.197', '2026-03-15 18:16:34', '2026-03-17 19:59:59', 0, NULL, NULL, NULL, 'cfe6393ee7b76ae5b2cf900ab73a043a', 'zh-cn', 1, '{\"device_id\":\"cfe6393ee7b76ae5b2cf900ab73a043a\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-17 19:59:59\",\"last_activity\":\"2026-03-17 19:59:59\"}', '[{\"device_id\":\"cfe6393ee7b76ae5b2cf900ab73a043a\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-17 19:59:59\",\"last_activity\":\"2026-03-17 19:59:59\"}]');
INSERT INTO `c_users` VALUES (29, 'zxcvbnm', NULL, '15055076758', '$2y$10$dKFOhn4H4B944b41xhSbGuk9WtduJNv7U7IbnNLhaFoj2nwUrn37O', 'U3J84E', 26, NULL, 0, 'eyJ1c2VyX2lkIjoyOSwidHlwZSI6MSwiZXhwIjoxNzc0MTc3OTg4fQ==', '2026-03-22 19:13:08', 36, 1, NULL, '34.143.229.197', '2026-03-15 19:12:49', '2026-03-15 19:13:08', 0, NULL, NULL, NULL, 'de33f3516f1e5a7110427e2a6453a9f0', '23127PN0CC Build/BP2A.250605.031.A3', 1, '{\"device_id\":\"de33f3516f1e5a7110427e2a6453a9f0\",\"device_name\":\"23127PN0CC Build\\/BP2A.250605.031.A3\",\"login_time\":\"2026-03-15 19:13:08\",\"last_activity\":\"2026-03-15 19:13:08\"}', '[{\"device_id\":\"de33f3516f1e5a7110427e2a6453a9f0\",\"device_name\":\"23127PN0CC Build\\/BP2A.250605.031.A3\",\"login_time\":\"2026-03-15 19:13:08\",\"last_activity\":\"2026-03-15 19:13:08\"}]');
INSERT INTO `c_users` VALUES (30, 'songjuan520', NULL, '15004147008', '$2y$10$Rb60hv6x3cXVcnjL4dG7yuBizsDEqkvHwWGGM3DBPYSOfaLhxtFJi', 'KRCZ3C', 26, NULL, 0, 'eyJ1c2VyX2lkIjozMCwidHlwZSI6MSwiZXhwIjoxNzc0NTIzODY5fQ==', '2026-03-26 19:17:49', 37, 1, NULL, '34.143.229.197', '2026-03-15 19:17:41', '2026-03-19 19:17:49', 0, NULL, NULL, NULL, '35fcd434ed3e3e84d13ed13d40628633', 'iPhone', 1, '{\"device_id\":\"35fcd434ed3e3e84d13ed13d40628633\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-19 19:17:49\",\"last_activity\":\"2026-03-19 19:17:49\"}', '[{\"device_id\":\"35fcd434ed3e3e84d13ed13d40628633\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-19 19:17:49\",\"last_activity\":\"2026-03-19 19:17:49\"}]');
INSERT INTO `c_users` VALUES (31, 'w621718', NULL, '13614243021', '$2y$10$EXH9oa35iZo2UeWHD1bhtusjFttP0i5dx1jRIK1NC7y9o4tlk7W3y', '8NGJWH', 26, NULL, 0, 'eyJ1c2VyX2lkIjozMSwidHlwZSI6MSwiZXhwIjoxNzc0MTgwMjk4fQ==', '2026-03-22 19:51:38', 38, 1, NULL, '34.143.229.197', '2026-03-15 19:19:35', '2026-03-15 19:51:38', 0, NULL, NULL, NULL, '5a6ad8e85fc8535d2c085b6d3ae48ef0', 'zh-cn', 1, '{\"device_id\":\"5a6ad8e85fc8535d2c085b6d3ae48ef0\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-15 19:51:38\",\"last_activity\":\"2026-03-15 19:51:38\"}', '[{\"device_id\":\"5a6ad8e85fc8535d2c085b6d3ae48ef0\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-15 19:51:38\",\"last_activity\":\"2026-03-15 19:51:38\"}]');
INSERT INTO `c_users` VALUES (32, 'yangyang', 'null@qq.com', '19213916686', '$2y$10$rE/LYC9bdiWGbLynHr.YF.1.AeYZG9ONfTPZwYW55Zrfi791t5ebm', 'VK9NTZ', 5, NULL, 2, 'eyJ1c2VyX2lkIjozMiwidHlwZSI6MSwiZXhwIjoxNzc0MTg0NTY3fQ==', '2026-03-22 21:02:47', 39, 1, NULL, '34.143.229.197', '2026-03-15 19:23:26', '2026-03-15 21:02:47', 0, NULL, NULL, NULL, '2ec303deaf8a31d0a0e9b6e019c48f76', 'iPhone', 1, '{\"device_id\":\"2ec303deaf8a31d0a0e9b6e019c48f76\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-15 21:02:47\",\"last_activity\":\"2026-03-15 21:02:47\"}', '[{\"device_id\":\"2ec303deaf8a31d0a0e9b6e019c48f76\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-15 21:02:47\",\"last_activity\":\"2026-03-15 21:02:47\"}]');
INSERT INTO `c_users` VALUES (33, '2580', NULL, '17356743965', '$2y$10$3Acok1Ww3RevQWOTesc93OUsBda1m9q7HtQkwqaDoNiVF4QoT5TDq', '35E6AJ', 26, NULL, 0, 'eyJ1c2VyX2lkIjozMywidHlwZSI6MSwiZXhwIjoxNzc0MTgwMjIxfQ==', '2026-03-22 19:50:21', 40, 1, NULL, '34.143.229.197', '2026-03-15 19:27:09', '2026-03-15 19:50:21', 0, NULL, NULL, NULL, '0963e7723014ffa869eaf749289a5c21', 'zh-cn', 1, '{\"device_id\":\"0963e7723014ffa869eaf749289a5c21\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-15 19:50:21\",\"last_activity\":\"2026-03-15 19:50:21\"}', '[{\"device_id\":\"0963e7723014ffa869eaf749289a5c21\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-15 19:50:21\",\"last_activity\":\"2026-03-15 19:50:21\"}]');
INSERT INTO `c_users` VALUES (34, '123456w', NULL, '16663908886', '$2y$10$E6vuf7sf29iExVP6cW.99OECpt2GM5nih4JV7asOV1LiJYf/8tvnu', 'PHE8XZ', 5, NULL, 0, 'eyJ1c2VyX2lkIjozNCwidHlwZSI6MSwiZXhwIjoxNzc0MTc4OTUzfQ==', '2026-03-22 19:29:13', 41, 1, NULL, '34.143.229.197', '2026-03-15 19:29:13', '2026-03-15 19:29:13', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (35, 'YUAN520', NULL, '13517552165', '$2y$10$ocPsCw50bfE5nOxor0nPae6cskd7qXzyCxl/0Qd76zBh.7CVV0BvC', '2RUDMW', 22, NULL, 1, 'eyJ1c2VyX2lkIjozNSwidHlwZSI6MSwiZXhwIjoxNzc0MTc4OTg2fQ==', '2026-03-22 19:29:46', 42, 1, NULL, '34.143.229.197', '2026-03-15 19:29:22', '2026-03-16 13:16:21', 0, NULL, NULL, NULL, '1c38ecbe464d98c1313590c7141af431', 'zh-cn', 1, '{\"device_id\":\"1c38ecbe464d98c1313590c7141af431\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-15 19:29:46\",\"last_activity\":\"2026-03-15 19:29:46\"}', '[{\"device_id\":\"1c38ecbe464d98c1313590c7141af431\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-15 19:29:46\",\"last_activity\":\"2026-03-15 19:29:46\"}]');
INSERT INTO `c_users` VALUES (36, 'guizhang8582', NULL, '18086605146', '$2y$10$8AOamGp8W91eubiDGTC7.OwAtXZ/Y1g/lCTPfhPBR3MYW.yD9/u5.', '3PWSPZ', 26, NULL, 0, 'eyJ1c2VyX2lkIjozNiwidHlwZSI6MSwiZXhwIjoxNzc0NDQzODEzfQ==', '2026-03-25 21:03:33', 43, 1, NULL, '34.143.229.197', '2026-03-15 19:57:09', '2026-03-18 21:03:33', 0, NULL, NULL, NULL, 'f052eb27f9c3c385f675ecede1ce9be3', 'zh-cn', 1, '{\"device_id\":\"f052eb27f9c3c385f675ecede1ce9be3\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-18 21:03:33\",\"last_activity\":\"2026-03-18 21:03:33\"}', '[{\"device_id\":\"f052eb27f9c3c385f675ecede1ce9be3\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-18 21:03:33\",\"last_activity\":\"2026-03-18 21:03:33\"}]');
INSERT INTO `c_users` VALUES (37, '18607307586', NULL, '19330092578', '$2y$10$7TbPk/rrhg3mu1FGe8qji..psn5K567.LaLHxpg1gKzW8BdaPaz9K', 'Z7CFWX', 23, NULL, 0, 'eyJ1c2VyX2lkIjozNywidHlwZSI6MSwiZXhwIjoxNzc0MzA5MjQ3fQ==', '2026-03-24 07:40:47', 44, 1, NULL, '34.143.229.197', '2026-03-15 20:01:16', '2026-03-17 07:40:47', 0, NULL, NULL, NULL, 'ef8a49385ea03949b5fea3cc27f6e646', 'V2163A Build/UP1A.231005.007', 1, '{\"device_id\":\"ef8a49385ea03949b5fea3cc27f6e646\",\"device_name\":\"V2163A Build\\/UP1A.231005.007\",\"login_time\":\"2026-03-17 07:40:47\",\"last_activity\":\"2026-03-17 07:40:47\"}', '[{\"device_id\":\"ef8a49385ea03949b5fea3cc27f6e646\",\"device_name\":\"V2163A Build\\/UP1A.231005.007\",\"login_time\":\"2026-03-17 07:40:47\",\"last_activity\":\"2026-03-17 07:40:47\"}]');
INSERT INTO `c_users` VALUES (38, '78111000', NULL, '15574958487', '$2y$10$/K/mxikIXG6FlR.WXB.cAufzyxbFlfjp5n2Mc6aknakVUK2idekIq', 'EX6WGE', 23, NULL, 0, 'eyJ1c2VyX2lkIjozOCwidHlwZSI6MSwiZXhwIjoxNzc0MTgwODgxfQ==', '2026-03-22 20:01:21', 45, 1, NULL, '34.143.229.197', '2026-03-15 20:01:21', '2026-03-15 20:01:21', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (39, '781101zwr', NULL, '18890355487', '$2y$10$AlXyuZXdWnto073fVn04e.lVDiPxOq.MwQbjvu7lstBv6dMo6cOFu', 'B2NWQZ', 23, NULL, 0, 'eyJ1c2VyX2lkIjozOSwidHlwZSI6MSwiZXhwIjoxNzc0MjY0NDcwfQ==', '2026-03-23 19:14:30', 46, 1, NULL, '34.143.229.197', '2026-03-15 20:12:49', '2026-03-16 19:14:30', 0, NULL, NULL, NULL, 'd1be6d4ad0e3b046a4567609b19fa91c', 'PHM110 Build/AP3A.240617.008', 1, '{\"device_id\":\"d1be6d4ad0e3b046a4567609b19fa91c\",\"device_name\":\"PHM110 Build\\/AP3A.240617.008\",\"login_time\":\"2026-03-16 19:14:30\",\"last_activity\":\"2026-03-16 19:14:30\"}', '[{\"device_id\":\"d1be6d4ad0e3b046a4567609b19fa91c\",\"device_name\":\"PHM110 Build\\/AP3A.240617.008\",\"login_time\":\"2026-03-16 19:14:30\",\"last_activity\":\"2026-03-16 19:14:30\"}]');
INSERT INTO `c_users` VALUES (40, '147369123789', NULL, '13606603489', '$2y$10$wc75wbH0Nmlt/VlBK.1/MOUrX4y2wdw1YX7NownX60y/8V0bM8Dy.', 'H8GV5C', 26, NULL, 0, 'eyJ1c2VyX2lkIjo0MCwidHlwZSI6MSwiZXhwIjoxNzc0NDQzMzc2fQ==', '2026-03-25 20:56:16', 47, 1, NULL, '34.143.229.197', '2026-03-15 20:17:13', '2026-03-18 20:56:16', 0, NULL, NULL, NULL, 'd69e8f4f2c6cfd212a9ac488166c71ef', 'VNE-AN00) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/116.0.5845.114 HonorBrowser/3.2.2.303  Mobile Safari/537.36', 1, '{\"device_id\":\"d69e8f4f2c6cfd212a9ac488166c71ef\",\"device_name\":\"VNE-AN00) AppleWebKit\\/537.36 (KHTML, like Gecko) Version\\/4.0 Chrome\\/116.0.5845.114 HonorBrowser\\/3.2.2.303  Mobile Safari\\/537.36\",\"login_time\":\"2026-03-18 20:56:16\",\"last_activity\":\"2026-03-18 20:56:16\"}', '[{\"device_id\":\"d69e8f4f2c6cfd212a9ac488166c71ef\",\"device_name\":\"VNE-AN00) AppleWebKit\\/537.36 (KHTML, like Gecko) Version\\/4.0 Chrome\\/116.0.5845.114 HonorBrowser\\/3.2.2.303  Mobile Safari\\/537.36\",\"login_time\":\"2026-03-18 20:56:16\",\"last_activity\":\"2026-03-18 20:56:16\"}]');
INSERT INTO `c_users` VALUES (41, 'asd123', NULL, '18040549884', '$2y$10$p4UB0b9nMa6yygK98S6XC.7tl.dKYjG/tVOWL3d/JIFjk4AXIRw2W', 'Q25X6Q', 26, NULL, 0, 'eyJ1c2VyX2lkIjo0MSwidHlwZSI6MSwiZXhwIjoxNzc0MjQ3ODA3fQ==', '2026-03-23 14:36:47', 48, 1, NULL, '34.143.229.197', '2026-03-15 20:17:50', '2026-03-16 14:36:47', 0, NULL, NULL, NULL, '9f4515da7362f02b2cc2e7e8263ec246', 'Android Device', 1, '{\"device_id\":\"9f4515da7362f02b2cc2e7e8263ec246\",\"device_name\":\"Android Device\",\"login_time\":\"2026-03-16 14:36:47\",\"last_activity\":\"2026-03-16 14:36:47\"}', '[{\"device_id\":\"9f4515da7362f02b2cc2e7e8263ec246\",\"device_name\":\"Android Device\",\"login_time\":\"2026-03-16 14:36:47\",\"last_activity\":\"2026-03-16 14:36:47\"}]');
INSERT INTO `c_users` VALUES (42, 'xy25', NULL, '18133310097', '$2y$10$24fQ1EXyHeSQE4VQaI9jIed.GJMWjlJOhiv/qbVOOe07bx39XFhOq', 'UU4BBN', 22, NULL, 1, 'eyJ1c2VyX2lkIjo0MiwidHlwZSI6MSwiZXhwIjoxNzc0NTEwMzk0fQ==', '2026-03-26 15:33:14', 49, 1, NULL, '34.143.229.197', '2026-03-15 21:13:31', '2026-03-19 15:33:14', 0, NULL, NULL, NULL, 'c03fa369f1dbaea87c135ee34d15ed79', 'iPhone', 1, '{\"device_id\":\"c03fa369f1dbaea87c135ee34d15ed79\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-19 15:33:14\",\"last_activity\":\"2026-03-19 15:33:14\"}', '[{\"device_id\":\"c03fa369f1dbaea87c135ee34d15ed79\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-19 15:33:14\",\"last_activity\":\"2026-03-19 15:33:14\"}]');
INSERT INTO `c_users` VALUES (43, '140823tt', NULL, '13616896925', '$2y$10$8OaA8A2h.8o2HNtxWmbx0OlcO53MmeYuWTpg5ShG1Cefha8F3s/la', 'XJP8KH', 42, NULL, 0, 'eyJ1c2VyX2lkIjo0MywidHlwZSI6MSwiZXhwIjoxNzc0MjI4NDc3fQ==', '2026-03-23 09:14:37', 50, 1, NULL, '34.143.229.197', '2026-03-16 08:59:30', '2026-03-16 09:14:37', 0, NULL, NULL, NULL, '43568f89bb2f3eca2cee5a0ec2f3806b', '24129PN74C Build/BP2A.250605.031.A3', 1, '{\"device_id\":\"43568f89bb2f3eca2cee5a0ec2f3806b\",\"device_name\":\"24129PN74C Build\\/BP2A.250605.031.A3\",\"login_time\":\"2026-03-16 09:14:37\",\"last_activity\":\"2026-03-16 09:14:37\"}', '[{\"device_id\":\"43568f89bb2f3eca2cee5a0ec2f3806b\",\"device_name\":\"24129PN74C Build\\/BP2A.250605.031.A3\",\"login_time\":\"2026-03-16 09:14:37\",\"last_activity\":\"2026-03-16 09:14:37\"}]');
INSERT INTO `c_users` VALUES (44, 'zhaoyang188', NULL, '18537013122', '$2y$10$3Xsg4546cDZEScTNJiYVCeZrv0jtCXiCcF1tFDeRWyyXIe3mWmuRu', 'QBQN5F', 42, NULL, 0, 'eyJ1c2VyX2lkIjo0NCwidHlwZSI6MSwiZXhwIjoxNzc0MjI3NzEzfQ==', '2026-03-23 09:01:53', 51, 1, NULL, '34.143.229.197', '2026-03-16 09:00:06', '2026-03-16 09:01:53', 0, NULL, NULL, NULL, '95135d7f01da6850f6d649301c6b6da7', 'NOH-AN00 Build/HUAWEINOH-AN00', 1, '{\"device_id\":\"95135d7f01da6850f6d649301c6b6da7\",\"device_name\":\"NOH-AN00 Build\\/HUAWEINOH-AN00\",\"login_time\":\"2026-03-16 09:01:53\",\"last_activity\":\"2026-03-16 09:01:53\"}', '[{\"device_id\":\"95135d7f01da6850f6d649301c6b6da7\",\"device_name\":\"NOH-AN00 Build\\/HUAWEINOH-AN00\",\"login_time\":\"2026-03-16 09:01:53\",\"last_activity\":\"2026-03-16 09:01:53\"}]');
INSERT INTO `c_users` VALUES (45, 'mr111222', NULL, '17205604105', '$2y$10$gbeLDSchSevyh2MbG0M4cOVJNBiurp2fpzVnCttrW1/hUgFGJxpte', 'UWKW55', 42, NULL, 0, 'eyJ1c2VyX2lkIjo0NSwidHlwZSI6MSwiZXhwIjoxNzc0MjI3OTQwfQ==', '2026-03-23 09:05:40', 52, 1, NULL, '34.143.229.197', '2026-03-16 09:05:18', '2026-03-16 09:05:40', 0, NULL, NULL, NULL, 'e39d645804d36326119cbcfa9abf3612', 'iPhone', 1, '{\"device_id\":\"e39d645804d36326119cbcfa9abf3612\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-16 09:05:40\",\"last_activity\":\"2026-03-16 09:05:40\"}', '[{\"device_id\":\"e39d645804d36326119cbcfa9abf3612\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-16 09:05:40\",\"last_activity\":\"2026-03-16 09:05:40\"}]');
INSERT INTO `c_users` VALUES (46, 'yuguo', NULL, '15256160583', '$2y$10$XGoOhyaen65eJlTdro6es.fUdhcd8jFpZ25c4BFo0OQDlvvUrKluu', 'AJ3ZTK', 42, NULL, 0, 'eyJ1c2VyX2lkIjo0NiwidHlwZSI6MSwiZXhwIjoxNzc0MjMxNjk5fQ==', '2026-03-23 10:08:19', 53, 1, NULL, '34.143.229.197', '2026-03-16 10:00:40', '2026-03-16 10:08:19', 0, NULL, NULL, NULL, '4853be6bddae5ebf3f90622fbd512067', 'iPhone', 1, '{\"device_id\":\"4853be6bddae5ebf3f90622fbd512067\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-16 10:08:19\",\"last_activity\":\"2026-03-16 10:08:19\"}', '[{\"device_id\":\"4853be6bddae5ebf3f90622fbd512067\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-16 10:08:19\",\"last_activity\":\"2026-03-16 10:08:19\"}]');
INSERT INTO `c_users` VALUES (47, 'sun123456', NULL, '18712285095', '$2y$10$9HkQzpuwj212HYB8V6Fi0eIWKNE4E8G9s1wQZdjskaxYBuppeLWmu', 'BNQJJU', 42, NULL, 0, 'eyJ1c2VyX2lkIjo0NywidHlwZSI6MSwiZXhwIjoxNzc0MzE3MjU2fQ==', '2026-03-24 09:54:16', 54, 1, NULL, '34.143.229.197', '2026-03-16 10:31:15', '2026-03-17 09:54:16', 0, NULL, NULL, NULL, 'fd2f8f85ec7839ddbb0432c337bb01ce', 'PFTM10 Build/UKQ1.230924.001', 1, '{\"device_id\":\"fd2f8f85ec7839ddbb0432c337bb01ce\",\"device_name\":\"PFTM10 Build\\/UKQ1.230924.001\",\"login_time\":\"2026-03-17 09:54:16\",\"last_activity\":\"2026-03-17 09:54:16\"}', '[{\"device_id\":\"fd2f8f85ec7839ddbb0432c337bb01ce\",\"device_name\":\"PFTM10 Build\\/UKQ1.230924.001\",\"login_time\":\"2026-03-17 09:54:16\",\"last_activity\":\"2026-03-17 09:54:16\"}]');
INSERT INTO `c_users` VALUES (48, '162401', NULL, '19156778998', '$2y$10$7iM5QH7tqU09Qn2.bRd96uP0bu7MgF5lypl6XIQWkzquglA5Mv1W6', 'SXMMMV', 42, NULL, 0, 'eyJ1c2VyX2lkIjo0OCwidHlwZSI6MSwiZXhwIjoxNzc0MzY4MzY3fQ==', '2026-03-25 00:06:07', 55, 1, NULL, '34.143.229.197', '2026-03-16 11:15:09', '2026-03-18 00:06:07', 0, NULL, NULL, NULL, '8755a0926385767ca0c5adf9a4779a38', 'M2104K10AC Build/TP1A.220624.014', 1, '{\"device_id\":\"8755a0926385767ca0c5adf9a4779a38\",\"device_name\":\"M2104K10AC Build\\/TP1A.220624.014\",\"login_time\":\"2026-03-18 00:06:07\",\"last_activity\":\"2026-03-18 00:06:07\"}', '[{\"device_id\":\"8755a0926385767ca0c5adf9a4779a38\",\"device_name\":\"M2104K10AC Build\\/TP1A.220624.014\",\"login_time\":\"2026-03-18 00:06:07\",\"last_activity\":\"2026-03-18 00:06:07\"}]');
INSERT INTO `c_users` VALUES (49, '123456QWER', NULL, '15239761214', '$2y$10$SX.KS.cr5wLk8wJUoMUvwOeC6hoz04hx0n2kLNN6Y2YVEikg1AksC', 'XE547E', 5, NULL, 0, 'eyJ1c2VyX2lkIjo0OSwidHlwZSI6MSwiZXhwIjoxNzc0MjM5MzAzfQ==', '2026-03-23 12:15:03', 56, 1, NULL, '34.143.229.197', '2026-03-16 12:14:37', '2026-03-16 12:15:03', 0, NULL, NULL, NULL, 'fe19e30a3b7bc45b697b409f66387dac', 'zh-cn', 1, '{\"device_id\":\"fe19e30a3b7bc45b697b409f66387dac\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-16 12:15:03\",\"last_activity\":\"2026-03-16 12:15:03\"}', '[{\"device_id\":\"fe19e30a3b7bc45b697b409f66387dac\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-16 12:15:03\",\"last_activity\":\"2026-03-16 12:15:03\"}]');
INSERT INTO `c_users` VALUES (50, 'sun92', NULL, '19032811085', '$2y$10$6tAeve/ZgW5Mh3s0rRXntOKELl9AfIpq.EUGgk7pZVwKpk3KGS7Be', '688T6T', 42, NULL, 0, 'eyJ1c2VyX2lkIjo1MCwidHlwZSI6MSwiZXhwIjoxNzc0MzI2MDgwfQ==', '2026-03-24 12:21:20', 57, 1, NULL, '34.143.229.197', '2026-03-16 13:46:56', '2026-03-17 12:21:20', 0, NULL, NULL, NULL, '64825d714400faca673529a3a42d6c68', 'iPhone', 1, '{\"device_id\":\"64825d714400faca673529a3a42d6c68\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-17 12:21:20\",\"last_activity\":\"2026-03-17 12:21:20\"}', '[{\"device_id\":\"64825d714400faca673529a3a42d6c68\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-17 12:21:20\",\"last_activity\":\"2026-03-17 12:21:20\"}]');
INSERT INTO `c_users` VALUES (51, 'yzq07', NULL, '18756733218', '$2y$10$QncMpTIXMDgXGG4MYcb5suSxkol9pzjl5My7NLDYfAJh9OLBdTpwS', '4VH9K9', 42, NULL, 0, NULL, NULL, 58, 1, NULL, '34.143.229.197', '2026-03-16 14:27:48', '2026-03-17 09:54:57', 0, NULL, NULL, NULL, '540f452594aacbc9c0033275fc4624ac', 'iPhone', 1, '{\"device_id\":\"540f452594aacbc9c0033275fc4624ac\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-17 09:54:40\",\"last_activity\":\"2026-03-17 09:54:40\"}', '[{\"device_id\":\"540f452594aacbc9c0033275fc4624ac\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-17 09:54:40\",\"last_activity\":\"2026-03-17 09:54:40\"}]');
INSERT INTO `c_users` VALUES (52, 'dxy11137150', NULL, '15594179367', '$2y$10$Z0yPLw2euWU9HFqo6pYpmuWqfCIuXXYiMUIPwkL0zzhytZYnWM60a', '7QRGB7', 35, NULL, 0, 'eyJ1c2VyX2lkIjo1MiwidHlwZSI6MSwiZXhwIjoxNzc0MjcxODI3fQ==', '2026-03-23 21:17:07', 59, 1, NULL, '34.143.229.197', '2026-03-16 21:10:50', '2026-03-16 21:17:07', 0, NULL, NULL, NULL, '3177ef380a9523c6c9a213abc3b23dd3', 'V2444A) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.6778.200 Mobile Safari/537.36 VivoBrowser/28.3.4.0', 1, '{\"device_id\":\"3177ef380a9523c6c9a213abc3b23dd3\",\"device_name\":\"V2444A) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/131.0.6778.200 Mobile Safari\\/537.36 VivoBrowser\\/28.3.4.0\",\"login_time\":\"2026-03-16 21:17:07\",\"last_activity\":\"2026-03-16 21:17:07\"}', '[{\"device_id\":\"3177ef380a9523c6c9a213abc3b23dd3\",\"device_name\":\"V2444A) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/131.0.6778.200 Mobile Safari\\/537.36 VivoBrowser\\/28.3.4.0\",\"login_time\":\"2026-03-16 21:17:07\",\"last_activity\":\"2026-03-16 21:17:07\"}]');
INSERT INTO `c_users` VALUES (53, 'jjyhhhxsw', NULL, '13259792935', '$2y$10$7TNFL00/Yh2bjUChavIhheFcNQSkuoBSMwCcpiyy4FnHD1DYD3fFu', 'PYW3ND', 35, NULL, 0, 'eyJ1c2VyX2lkIjo1MywidHlwZSI6MSwiZXhwIjoxNzc0Mjc0Nzg4fQ==', '2026-03-23 22:06:28', 60, 1, NULL, '34.143.229.197', '2026-03-16 22:04:48', '2026-03-16 22:06:28', 0, NULL, NULL, NULL, 'ad80f5910cedb2f6ebe0951fc0572243', 'zh-cn', 1, '{\"device_id\":\"ad80f5910cedb2f6ebe0951fc0572243\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-16 22:06:28\",\"last_activity\":\"2026-03-16 22:06:28\"}', '[{\"device_id\":\"ad80f5910cedb2f6ebe0951fc0572243\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-16 22:06:28\",\"last_activity\":\"2026-03-16 22:06:28\"}]');
INSERT INTO `c_users` VALUES (54, 'tan0013579', NULL, '15905677210', '$2y$10$uWbkLnRVNOQ3VkDF89b3X.2A8arDFpfHAKxF2FLAbXCI.VJLtTgwC', 'RG4B8H', 42, NULL, 0, 'eyJ1c2VyX2lkIjo1NCwidHlwZSI6MSwiZXhwIjoxNzc0MzIwNTg3fQ==', '2026-03-24 10:49:47', 61, 1, NULL, '34.143.229.197', '2026-03-17 10:39:59', '2026-03-17 10:49:47', 0, NULL, NULL, NULL, '3184f4e389429e0b76859b0675b06ab1', 'PEQM00 Build/TP1A.220905.001', 1, '{\"device_id\":\"3184f4e389429e0b76859b0675b06ab1\",\"device_name\":\"PEQM00 Build\\/TP1A.220905.001\",\"login_time\":\"2026-03-17 10:49:47\",\"last_activity\":\"2026-03-17 10:49:47\"}', '[{\"device_id\":\"3184f4e389429e0b76859b0675b06ab1\",\"device_name\":\"PEQM00 Build\\/TP1A.220905.001\",\"login_time\":\"2026-03-17 10:49:47\",\"last_activity\":\"2026-03-17 10:49:47\"}]');
INSERT INTO `c_users` VALUES (55, '17658290569', NULL, '17658290569', '$2y$10$Vg8JkBKHOQ11bxXy8W.Lqu4EoGB7kARg/QA9PVe.N68OmlBXNXRia', 'KVM336', 35, NULL, 0, 'eyJ1c2VyX2lkIjo1NSwidHlwZSI6MSwiZXhwIjoxNzc0MzIzMjQyfQ==', '2026-03-24 11:34:02', 62, 1, NULL, '34.143.229.197', '2026-03-17 11:33:22', '2026-03-17 11:34:02', 0, NULL, NULL, NULL, '79835847440f93253cd9ead292a2e94f', 'iPhone', 1, '{\"device_id\":\"79835847440f93253cd9ead292a2e94f\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-17 11:34:02\",\"last_activity\":\"2026-03-17 11:34:02\"}', '[{\"device_id\":\"79835847440f93253cd9ead292a2e94f\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-17 11:34:02\",\"last_activity\":\"2026-03-17 11:34:02\"}]');
INSERT INTO `c_users` VALUES (56, 'KaiKai', NULL, '19931979291', '$2y$10$qTjUWU8.Zq5gvo0xRmZpuOAW/eePPoLCt81O7SJvK1uK6jxHmszf2', 'FK2JCM', 55, NULL, 0, 'eyJ1c2VyX2lkIjo1NiwidHlwZSI6MSwiZXhwIjoxNzc0MzIzODUwfQ==', '2026-03-24 11:44:10', 63, 1, NULL, '34.143.229.197', '2026-03-17 11:43:52', '2026-03-17 11:44:10', 0, NULL, NULL, NULL, '94ac84ff7057e3bcb743c1e96e61d1cc', 'zh-cn', 1, '{\"device_id\":\"94ac84ff7057e3bcb743c1e96e61d1cc\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-17 11:44:10\",\"last_activity\":\"2026-03-17 11:44:10\"}', '[{\"device_id\":\"94ac84ff7057e3bcb743c1e96e61d1cc\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-17 11:44:10\",\"last_activity\":\"2026-03-17 11:44:10\"}]');
INSERT INTO `c_users` VALUES (57, 'xjh111', NULL, '19963824136', '$2y$10$CHzBbi8Dg9wZ0IbSZDT1Gu4pstM2RiPoO5cdB8/D22.EXtphn7yrK', 'YPV6HR', 35, NULL, 0, 'eyJ1c2VyX2lkIjo1NywidHlwZSI6MSwiZXhwIjoxNzc0MzU4ODY2fQ==', '2026-03-24 21:27:46', 64, 1, NULL, '34.143.229.197', '2026-03-17 13:11:14', '2026-03-17 21:27:46', 0, NULL, NULL, NULL, '4853be6bddae5ebf3f90622fbd512067', 'iPhone', 1, '{\"device_id\":\"4853be6bddae5ebf3f90622fbd512067\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-17 21:27:46\",\"last_activity\":\"2026-03-17 21:27:46\"}', '[{\"device_id\":\"4853be6bddae5ebf3f90622fbd512067\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-17 21:27:46\",\"last_activity\":\"2026-03-17 21:27:46\"}]');
INSERT INTO `c_users` VALUES (58, 'Yjx123', NULL, '18148243395', '$2y$10$MRUzTZSdca4MsM0hENV3xeULgLc4OmFCw20sFpCD8Y0mzWoyh0aNG', 'TGEQKD', 35, NULL, 0, 'eyJ1c2VyX2lkIjo1OCwidHlwZSI6MSwiZXhwIjoxNzc0MzMxODI5fQ==', '2026-03-24 13:57:09', 65, 1, NULL, '34.143.229.197', '2026-03-17 13:56:17', '2026-03-17 13:57:09', 0, NULL, NULL, NULL, 'df13b9f6f15d490902c36ebe7b178e70', 'HarmonyOS', 1, '{\"device_id\":\"df13b9f6f15d490902c36ebe7b178e70\",\"device_name\":\"HarmonyOS\",\"login_time\":\"2026-03-17 13:57:09\",\"last_activity\":\"2026-03-17 13:57:09\"}', '[{\"device_id\":\"df13b9f6f15d490902c36ebe7b178e70\",\"device_name\":\"HarmonyOS\",\"login_time\":\"2026-03-17 13:57:09\",\"last_activity\":\"2026-03-17 13:57:09\"}]');
INSERT INTO `c_users` VALUES (59, '3365yan', NULL, '19810868596', '$2y$10$ZDLYXL8x1Ud0.CY8zHWFtul7oqJhJqcnKQHsPIyz7vjcNTSWNFisW', 'TU7RQV', 42, NULL, 0, 'eyJ1c2VyX2lkIjo1OSwidHlwZSI6MSwiZXhwIjoxNzc0MzMyNTE5fQ==', '2026-03-24 14:08:39', 66, 1, NULL, '34.143.229.197', '2026-03-17 14:08:06', '2026-03-17 14:08:39', 0, NULL, NULL, NULL, 'ff5302ce362ad11c44beed55a6d2dc3e', '24115RA8EC Build/BP2A.250605.031.A3', 1, '{\"device_id\":\"ff5302ce362ad11c44beed55a6d2dc3e\",\"device_name\":\"24115RA8EC Build\\/BP2A.250605.031.A3\",\"login_time\":\"2026-03-17 14:08:39\",\"last_activity\":\"2026-03-17 14:08:39\"}', '[{\"device_id\":\"ff5302ce362ad11c44beed55a6d2dc3e\",\"device_name\":\"24115RA8EC Build\\/BP2A.250605.031.A3\",\"login_time\":\"2026-03-17 14:08:39\",\"last_activity\":\"2026-03-17 14:08:39\"}]');
INSERT INTO `c_users` VALUES (60, 'Fang194312', NULL, '13190552488', '$2y$10$rb8/I42aihJHnYshGw5zx.VZjyaAdoa4gdHZ2R0k1B5uvMX0KTupS', '355QD9', 35, NULL, 0, 'eyJ1c2VyX2lkIjo2MCwidHlwZSI6MSwiZXhwIjoxNzc0MzM3MTA1fQ==', '2026-03-24 15:25:05', 67, 1, NULL, '34.143.229.197', '2026-03-17 15:08:27', '2026-03-17 15:25:05', 0, NULL, NULL, NULL, '413984d7bc59720af6fe45dda99a45e1', 'iPhone', 1, '{\"device_id\":\"413984d7bc59720af6fe45dda99a45e1\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-17 15:25:05\",\"last_activity\":\"2026-03-17 15:25:05\"}', '[{\"device_id\":\"413984d7bc59720af6fe45dda99a45e1\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-17 15:25:05\",\"last_activity\":\"2026-03-17 15:25:05\"}]');
INSERT INTO `c_users` VALUES (61, '1971506019', NULL, '17352604434', '$2y$10$XFTsNACSdCTnr24y8ushX.IjbiTBbeCGTOVuIrT26BmlBwQz07LzW', 'UU2WXA', 26, NULL, 0, 'eyJ1c2VyX2lkIjo2MSwidHlwZSI6MSwiZXhwIjoxNzc0MzM2MTg2fQ==', '2026-03-24 15:09:46', 68, 1, NULL, '34.143.229.197', '2026-03-17 15:09:20', '2026-03-17 15:09:46', 0, NULL, NULL, NULL, 'b40ce9e3ae02cd24112da6c1e091fbb3', 'iPhone', 1, '{\"device_id\":\"b40ce9e3ae02cd24112da6c1e091fbb3\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-17 15:09:46\",\"last_activity\":\"2026-03-17 15:09:46\"}', '[{\"device_id\":\"b40ce9e3ae02cd24112da6c1e091fbb3\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-17 15:09:46\",\"last_activity\":\"2026-03-17 15:09:46\"}]');
INSERT INTO `c_users` VALUES (62, 'liang520', NULL, '15849349985', '$2y$10$dfmNPLRepPy0cI5YPwFccetoQ/dbK3x76u0VymU4v4RAUWGkOE9PC', 'M2UJBZ', 35, NULL, 0, 'eyJ1c2VyX2lkIjo2MiwidHlwZSI6MSwiZXhwIjoxNzc0NDk4NzU0fQ==', '2026-03-26 12:19:14', 69, 1, NULL, '34.143.229.197', '2026-03-17 15:14:48', '2026-03-19 12:19:14', 0, NULL, NULL, NULL, '70b6be4bce932c7d664c3bbe64a40f18', 'zh-cn', 1, '{\"device_id\":\"70b6be4bce932c7d664c3bbe64a40f18\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-19 12:19:14\",\"last_activity\":\"2026-03-19 12:19:14\"}', '[{\"device_id\":\"70b6be4bce932c7d664c3bbe64a40f18\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-19 12:19:14\",\"last_activity\":\"2026-03-19 12:19:14\"}]');
INSERT INTO `c_users` VALUES (63, '123456yjx', NULL, '18247167915', '$2y$10$3PPbewalVftBiwHF2qsPDODL4H42mIB3r.Co.6i7eV1v1JJWvb.Um', '49ERHA', 35, NULL, 0, 'eyJ1c2VyX2lkIjo2MywidHlwZSI6MSwiZXhwIjoxNzc0MzQwODc1fQ==', '2026-03-24 16:27:55', 70, 1, NULL, '34.143.229.197', '2026-03-17 16:27:11', '2026-03-17 16:27:55', 0, NULL, NULL, NULL, 'b3c52bf7a9d9374d322ab42fe7baae29', 'zh-cn', 1, '{\"device_id\":\"b3c52bf7a9d9374d322ab42fe7baae29\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-17 16:27:55\",\"last_activity\":\"2026-03-17 16:27:55\"}', '[{\"device_id\":\"b3c52bf7a9d9374d322ab42fe7baae29\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-17 16:27:55\",\"last_activity\":\"2026-03-17 16:27:55\"}]');
INSERT INTO `c_users` VALUES (64, '987321147258', NULL, '15858297756', '$2y$10$HHcA481k12ix3S/Z0xvH/Oj0QW9Se7XaP6dIBnaxTPUnH3QLZXJkW', 'WJCTT8', 26, NULL, 0, 'eyJ1c2VyX2lkIjo2NCwidHlwZSI6MSwiZXhwIjoxNzc0MzQ4NTMxfQ==', '2026-03-24 18:35:31', 71, 1, NULL, '34.143.229.197', '2026-03-17 18:35:00', '2026-03-17 18:35:31', 0, NULL, NULL, NULL, '33f627951e5d209b0bd4042c3296048b', 'zh-cn', 1, '{\"device_id\":\"33f627951e5d209b0bd4042c3296048b\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-17 18:35:31\",\"last_activity\":\"2026-03-17 18:35:31\"}', '[{\"device_id\":\"33f627951e5d209b0bd4042c3296048b\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-17 18:35:31\",\"last_activity\":\"2026-03-17 18:35:31\"}]');
INSERT INTO `c_users` VALUES (65, 'a18124206924', NULL, '18124206924', '$2y$10$v4Is/NhIBl5yUabnJ9.Xium4GFB01iJcj3fZwi48SAv6zjkJTcbAC', 'HFUXEH', 42, NULL, 0, 'eyJ1c2VyX2lkIjo2NSwidHlwZSI6MSwiZXhwIjoxNzc0MzUyMzA3fQ==', '2026-03-24 19:38:27', 72, 1, NULL, '34.143.229.197', '2026-03-17 19:03:33', '2026-03-17 19:38:27', 0, NULL, NULL, NULL, '7c7d38934402b09866fbfc8deef2acf9', '24069RA21C Build/UKQ1.240116.001', 1, '{\"device_id\":\"7c7d38934402b09866fbfc8deef2acf9\",\"device_name\":\"24069RA21C Build\\/UKQ1.240116.001\",\"login_time\":\"2026-03-17 19:38:27\",\"last_activity\":\"2026-03-17 19:38:27\"}', '[{\"device_id\":\"7c7d38934402b09866fbfc8deef2acf9\",\"device_name\":\"24069RA21C Build\\/UKQ1.240116.001\",\"login_time\":\"2026-03-17 19:38:27\",\"last_activity\":\"2026-03-17 19:38:27\"}]');
INSERT INTO `c_users` VALUES (66, 'zhujinlin', NULL, '13389091698', '$2y$10$YSywh.GGx6qIwQF0vQWTNeDpuMdiOpdZZYFcsthWptHLgdxANz/lS', 'CRZR62', 42, NULL, 0, NULL, NULL, 73, 1, NULL, '34.143.229.197', '2026-03-17 19:20:48', '2026-03-17 19:24:24', 0, NULL, NULL, NULL, '01d46b780d68dde4a5085dd7ffa5d845', 'zh-cn', 1, '{\"device_id\":\"01d46b780d68dde4a5085dd7ffa5d845\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-17 19:21:08\",\"last_activity\":\"2026-03-17 19:21:08\"}', '[{\"device_id\":\"01d46b780d68dde4a5085dd7ffa5d845\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-17 19:21:08\",\"last_activity\":\"2026-03-17 19:21:08\"}]');
INSERT INTO `c_users` VALUES (67, 'mslm', NULL, '15894179061', '$2y$10$ncwi0milEYkieUCZrs4uKurZ85oXReqIHwdyag4I9hcfYWfc7GDxa', '8MHECH', 35, NULL, 0, 'eyJ1c2VyX2lkIjo2NywidHlwZSI6MSwiZXhwIjoxNzc0MzUzODA1fQ==', '2026-03-24 20:03:25', 75, 1, NULL, '34.143.229.197', '2026-03-17 19:56:11', '2026-03-17 20:03:25', 0, NULL, NULL, NULL, '835557f01e03d1702484641d52083a7b', 'zh-cn', 1, '{\"device_id\":\"835557f01e03d1702484641d52083a7b\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-17 20:03:25\",\"last_activity\":\"2026-03-17 20:03:25\"}', '[{\"device_id\":\"835557f01e03d1702484641d52083a7b\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-17 20:03:25\",\"last_activity\":\"2026-03-17 20:03:25\"}]');
INSERT INTO `c_users` VALUES (68, 'WR19901005', NULL, '19156751488', '$2y$10$vsgzdNokirn8XuKitwijB.WFevWQwT/.7H6kGuIe14oQTYoyP0/tq', 'Z2QWUB', 42, NULL, 0, 'eyJ1c2VyX2lkIjo2OCwidHlwZSI6MSwiZXhwIjoxNzc0MzUzODQ4fQ==', '2026-03-24 20:04:08', 76, 1, NULL, '34.143.229.197', '2026-03-17 20:03:37', '2026-03-17 20:04:08', 0, NULL, NULL, NULL, 'cd77364482e31f03d7000fcd505d6d2a', 'V1829A) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.6778.200 Mobile Safari/537.36 VivoBrowser/28.3.4.0', 1, '{\"device_id\":\"cd77364482e31f03d7000fcd505d6d2a\",\"device_name\":\"V1829A) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/131.0.6778.200 Mobile Safari\\/537.36 VivoBrowser\\/28.3.4.0\",\"login_time\":\"2026-03-17 20:04:08\",\"last_activity\":\"2026-03-17 20:04:08\"}', '[{\"device_id\":\"cd77364482e31f03d7000fcd505d6d2a\",\"device_name\":\"V1829A) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/131.0.6778.200 Mobile Safari\\/537.36 VivoBrowser\\/28.3.4.0\",\"login_time\":\"2026-03-17 20:04:08\",\"last_activity\":\"2026-03-17 20:04:08\"}]');
INSERT INTO `c_users` VALUES (69, 'a467685513', NULL, '17302060224', '$2y$10$7Oulejqnt39/BFBv8QlyAuxcXRQh6k3ePpTT3O8vDlw2yrymWZdKe', '3UGUAB', 18, NULL, 0, 'eyJ1c2VyX2lkIjo2OSwidHlwZSI6MSwiZXhwIjoxNzc0MzU4NzkzfQ==', '2026-03-24 21:26:33', 77, 1, NULL, '34.143.229.197', '2026-03-17 21:08:46', '2026-03-17 21:26:33', 0, NULL, NULL, NULL, 'c9d88d0a50bbce7b3877d3724145770a', 'Win32 Mozilla/5.0', 1, '{\"device_id\":\"c9d88d0a50bbce7b3877d3724145770a\",\"device_name\":\"Win32 Mozilla\\/5.0\",\"login_time\":\"2026-03-17 21:26:33\",\"last_activity\":\"2026-03-17 21:26:33\"}', '[{\"device_id\":\"c9d88d0a50bbce7b3877d3724145770a\",\"device_name\":\"Win32 Mozilla\\/5.0\",\"login_time\":\"2026-03-17 21:26:33\",\"last_activity\":\"2026-03-17 21:26:33\"}]');
INSERT INTO `c_users` VALUES (70, '1234', NULL, '19902798625', '$2y$10$iAi5HyVjxBGffA/62sl6T.knuj.deRTevtUTE4KyZrxJf2srPmyyW', 'NKX8T2', 18, NULL, 0, 'eyJ1c2VyX2lkIjo3MCwidHlwZSI6MSwiZXhwIjoxNzc0MzU5NDQ2fQ==', '2026-03-24 21:37:26', 78, 1, NULL, '34.143.229.197', '2026-03-17 21:37:06', '2026-03-17 21:37:26', 0, NULL, NULL, NULL, 'caaf0b56c6e57b19ffd482145f50a855', 'iPhone', 1, '{\"device_id\":\"caaf0b56c6e57b19ffd482145f50a855\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-17 21:37:26\",\"last_activity\":\"2026-03-17 21:37:26\"}', '[{\"device_id\":\"caaf0b56c6e57b19ffd482145f50a855\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-17 21:37:26\",\"last_activity\":\"2026-03-17 21:37:26\"}]');
INSERT INTO `c_users` VALUES (71, 'amir', NULL, '18116905408', '$2y$10$xGYz3md5Xn0pT7I2WMBW6e7G2I6cHjS2CceHKORH6S3H965mRB1/C', 'XPB26G', 27, NULL, 0, 'eyJ1c2VyX2lkIjo3MSwidHlwZSI6MSwiZXhwIjoxNzc0MzYxOTQwfQ==', '2026-03-24 22:19:00', 79, 1, NULL, '34.143.229.197', '2026-03-17 22:18:28', '2026-03-17 22:19:00', 0, NULL, NULL, NULL, '110363acf7469c7c6eb0d99f718afac2', 'iPhone', 1, '{\"device_id\":\"110363acf7469c7c6eb0d99f718afac2\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-17 22:19:00\",\"last_activity\":\"2026-03-17 22:19:00\"}', '[{\"device_id\":\"110363acf7469c7c6eb0d99f718afac2\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-17 22:19:00\",\"last_activity\":\"2026-03-17 22:19:00\"}]');
INSERT INTO `c_users` VALUES (72, 'zhang', NULL, '19276445680', '$2y$10$Mpb2Tk/3QhNJVh2OcQQ3T.Ep9p/qNsksadvUS3MWYyheBjDpUmcj6', 'G99FCK', 26, NULL, 0, 'eyJ1c2VyX2lkIjo3MiwidHlwZSI6MSwiZXhwIjoxNzc0MzY2NzAxfQ==', '2026-03-24 23:38:21', 80, 1, NULL, '34.143.229.197', '2026-03-17 23:37:39', '2026-03-17 23:38:21', 0, NULL, NULL, NULL, '5c8bebd895a3f6ab38fe801e4413e81e', 'M2007J1SC Build/TKQ1.221114.001', 1, '{\"device_id\":\"5c8bebd895a3f6ab38fe801e4413e81e\",\"device_name\":\"M2007J1SC Build\\/TKQ1.221114.001\",\"login_time\":\"2026-03-17 23:38:21\",\"last_activity\":\"2026-03-17 23:38:21\"}', '[{\"device_id\":\"5c8bebd895a3f6ab38fe801e4413e81e\",\"device_name\":\"M2007J1SC Build\\/TKQ1.221114.001\",\"login_time\":\"2026-03-17 23:38:21\",\"last_activity\":\"2026-03-17 23:38:21\"}]');
INSERT INTO `c_users` VALUES (73, 'gj123456', NULL, '17804818493', '$2y$10$vUVJ3emu2B4sCgn98QOymO.e35ag.7C.eR28Tbe2g.OCZ5ii3Pg42', 'NANGHJ', 35, NULL, 0, 'eyJ1c2VyX2lkIjo3MywidHlwZSI6MSwiZXhwIjoxNzc0NDI5MzI3fQ==', '2026-03-25 17:02:07', 81, 1, NULL, '34.143.229.197', '2026-03-18 16:59:39', '2026-03-18 17:02:07', 0, NULL, NULL, NULL, '5989da83627b9b4eaecc246196148e14', 'zh-cn', 1, '{\"device_id\":\"5989da83627b9b4eaecc246196148e14\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-18 17:02:07\",\"last_activity\":\"2026-03-18 17:02:07\"}', '[{\"device_id\":\"5989da83627b9b4eaecc246196148e14\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-18 17:02:07\",\"last_activity\":\"2026-03-18 17:02:07\"}]');
INSERT INTO `c_users` VALUES (74, 'Almas0205', NULL, '15299042767', '$2y$10$zaPeFZ8JFBKsQprDEHG4kupbOjBHzMPKRUOU90xVEeo7p11XrICpi', 'BJKTCD', 22, NULL, 0, 'eyJ1c2VyX2lkIjo3NCwidHlwZSI6MSwiZXhwIjoxNzc0NTM5OTYwfQ==', '2026-03-26 23:46:00', 82, 1, NULL, '34.143.229.197', '2026-03-19 23:44:25', '2026-03-19 23:46:00', 0, NULL, NULL, NULL, '110363acf7469c7c6eb0d99f718afac2', 'iPhone', 1, '{\"device_id\":\"110363acf7469c7c6eb0d99f718afac2\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-19 23:46:00\",\"last_activity\":\"2026-03-19 23:46:00\"}', '[{\"device_id\":\"110363acf7469c7c6eb0d99f718afac2\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-19 23:46:00\",\"last_activity\":\"2026-03-19 23:46:00\"}]');
INSERT INTO `c_users` VALUES (75, 'love1314', NULL, '15326742207', '$2y$10$L8ZCkCmFe7iOSV1uO0DbOO3XireyimyZvM8Ahiew3I.N3LnSeIW22', '4UBNR4', 26, NULL, 0, 'eyJ1c2VyX2lkIjo3NSwidHlwZSI6MSwiZXhwIjoxNzc0NTkxOTUzfQ==', '2026-03-27 14:12:33', 83, 1, NULL, '34.143.229.197', '2026-03-20 14:04:11', '2026-03-20 14:12:33', 0, NULL, NULL, NULL, '6d1259d3505a1388c294348555f7e077', 'V2162A Build/UP1A.231005.007', 1, '{\"device_id\":\"6d1259d3505a1388c294348555f7e077\",\"device_name\":\"V2162A Build\\/UP1A.231005.007\",\"login_time\":\"2026-03-20 14:12:33\",\"last_activity\":\"2026-03-20 14:12:33\"}', '[{\"device_id\":\"6d1259d3505a1388c294348555f7e077\",\"device_name\":\"V2162A Build\\/UP1A.231005.007\",\"login_time\":\"2026-03-20 14:12:33\",\"last_activity\":\"2026-03-20 14:12:33\"}]');
INSERT INTO `c_users` VALUES (76, 'rifat503', NULL, '17399469223', '$2y$10$.Uh0nub8Q0isszsQpPm/NuxSaInuDD4gxXXKWXteNhUq7DQrdOqsS', 'G9VM9H', 27, NULL, 0, 'eyJ1c2VyX2lkIjo3NiwidHlwZSI6MSwiZXhwIjoxNzc0NjA5MzQ0fQ==', '2026-03-27 19:02:24', 84, 1, NULL, '34.143.229.197', '2026-03-20 18:31:22', '2026-03-20 19:02:24', 0, NULL, NULL, NULL, '087cef291cdce72cf407d0c459435608', 'zh-cn', 1, '{\"device_id\":\"087cef291cdce72cf407d0c459435608\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-20 19:02:24\",\"last_activity\":\"2026-03-20 19:02:24\"}', '[{\"device_id\":\"087cef291cdce72cf407d0c459435608\",\"device_name\":\"zh-cn\",\"login_time\":\"2026-03-20 19:02:24\",\"last_activity\":\"2026-03-20 19:02:24\"}]');
INSERT INTO `c_users` VALUES (77, 'zibi1314', NULL, '15099381048', '$2y$10$IBJvUC5IlLEHiWTamfZ14eJSiS55OkqcgeekxZ8C/NBnYGi7FfWPq', 'H4S5PB', 76, NULL, 0, 'eyJ1c2VyX2lkIjo3NywidHlwZSI6MSwiZXhwIjoxNzc0NjA5ODkzfQ==', '2026-03-27 19:11:33', 85, 1, NULL, '34.143.229.197', '2026-03-20 19:11:08', '2026-03-20 19:11:33', 0, NULL, NULL, NULL, '1a4a681b157f8440a6140c7201cd9bdc', 'SP200', 1, '{\"device_id\":\"1a4a681b157f8440a6140c7201cd9bdc\",\"device_name\":\"SP200\",\"login_time\":\"2026-03-20 19:11:33\",\"last_activity\":\"2026-03-20 19:11:33\"}', '[{\"device_id\":\"1a4a681b157f8440a6140c7201cd9bdc\",\"device_name\":\"SP200\",\"login_time\":\"2026-03-20 19:11:33\",\"last_activity\":\"2026-03-20 19:11:33\"}]');

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
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '放大镜任务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of magnifying_glass_tasks
-- ----------------------------
INSERT INTO `magnifying_glass_tasks` VALUES (15, 1, NULL, 3, '5.82 复制打开抖音，看看【唐小美的作品】大家除了上班以外，还有什么副业# 副业  https://v.douyin.com/iKQS67FFM6o/ 06/26 u@f.oq yGv:/', 1773713449, '[{\"at_user\": \"\", \"comment\": \"啊梅有团\", \"image_url\": \"\"}]', 1, 0, 0, 0, 5.00, 5.00, 2, '2026-03-17 09:40:49', '2026-03-17 09:40:49', NULL, '放大镜搜索词', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 198 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统通知表-通知模板' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notifications
-- ----------------------------

-- ----------------------------
-- Table structure for quick_task_info_config
-- ----------------------------
DROP TABLE IF EXISTS `quick_task_info_config`;
CREATE TABLE `quick_task_info_config`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `b_user_id` bigint UNSIGNED NOT NULL,
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `config_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_b_user_id`(`b_user_id` ASC) USING BTREE,
  INDEX `idx_username`(`username` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_updated_at`(`updated_at` ASC) USING BTREE,
  CONSTRAINT `fk_quick_task_config_b_user` FOREIGN KEY (`b_user_id`) REFERENCES `b_users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端用户快捷派单配置信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of quick_task_info_config
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '充值申请表-需要管理员审核' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of recharge_requests
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '求租信息表-账号需求市场' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '出租信息表-账号出租市场' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '后台管理用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_users
-- ----------------------------
INSERT INTO `system_users` VALUES (1, 'task', '767a5ecfa4c238cfe5757ca396edff54', 'admin@example.com', '13800138000', 1, 'eyJ1c2VyX2lkIjoxLCJ0eXBlIjozLCJleHAiOjE3NzQyNDM4MzR9', '2026-03-23 13:30:34', 1, '2026-03-16 13:30:34', '2026-03-06 15:32:33', '2026-03-16 13:30:34');
INSERT INTO `system_users` VALUES (2, 'kefu', '2569d419bfea999ff13fd1f7f4498b89', 'kefu@qq.com', '15900000000', 5, '96e5c379ab22bc8165c9e5ccc37262ac', '2026-03-07 10:17:08', 1, '2026-03-06 18:17:08', '2026-03-06 18:09:15', '2026-03-11 12:31:19');
INSERT INTO `system_users` VALUES (3, 'shenji', 'e99a18c428cb38d5f260853678922e03', '', '15900000001', 7, '54de1ef7302bae1f7259845cef6d2ff8', '2026-03-07 22:51:52', 1, '2026-03-06 22:51:52', '2026-03-06 18:16:16', '2026-03-06 22:51:52');
INSERT INTO `system_users` VALUES (5, 'xiaoya', '2569d419bfea999ff13fd1f7f4498b89', '', '13049610316', 5, 'eyJ1c2VyX2lkIjo1LCJ0eXBlIjozLCJleHAiOjE3NzQ0MjUzNjd9', '2026-03-25 15:56:07', 1, '2026-03-18 15:56:07', '2026-03-11 12:37:27', '2026-03-18 15:56:07');
INSERT INTO `system_users` VALUES (6, 'taskadmin', '767a5ecfa4c238cfe5757ca396edff54', NULL, '', 1, 'eyJ1c2VyX2lkIjo2LCJ0eXBlIjozLCJleHAiOjE3NzQyNjQxMjV9', '2026-03-23 19:08:45', 1, '2026-03-16 19:08:45', '2026-03-15 17:03:04', '2026-03-16 19:08:45');
INSERT INTO `system_users` VALUES (7, 'taskdong', '9a361ed860ec2617da5af72079594a21', NULL, '', 7, 'eyJ1c2VyX2lkIjo3LCJ0eXBlIjozLCJleHAiOjE3NzQxNzc3NTl9', '2026-03-22 19:09:19', 1, '2026-03-15 19:09:19', '2026-03-15 19:08:23', '2026-03-15 19:09:19');

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
INSERT INTO `task_templates` VALUES (1, 0, '上评评论', 3.00, '发布上评评论', '可带图发评论，一次最多10条', NULL, NULL, NULL, NULL, 1, 3, 100, 50, 50, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (2, 0, '中评评论', 2.00, '发布中评评论', '可带图发评论，无次数限制', NULL, NULL, NULL, NULL, 3, 3, 80, 30, 30, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (3, 0, '放大镜搜索词', 5.00, '抖音平台规则问题，本产品属于概率出现蓝词，搜索词搜索次数就越多，出现概率越大', '', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (4, 1, '上中评评论', 9.00, '组合评论：上评+中评(1+3)', '可带图发评论，中评无次数限制', '上评评论', 3.00, '中评回复', 2.00, 1, 3, 100, 50, 50, 100, 50, 50, 80, 30, 30, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (5, 1, '中下评评论', 6.00, '组合评论：中评+下评(1+1)', '可带图发评论，下评无次数限制', '中评评论', 3.00, '下评回复', 3.00, 1, 1, 0, 0, 0, 130, 45, 43, 130, 45, 45, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (6, 1, '中下评快捷派单', 6.00, '快捷派单：中评+下评(1+1)，下评带@', '-', '中评评论', 3.00, '下评评论', 3.00, 1, 1, 0, 0, 0, 130, 45, 43, 130, 45, 45, 1, '2026-03-21 10:29:58');

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '终止租赁订单表-记录终止租赁的相关数据' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 198 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户通知表-每个用户收到的通知' ROW_FORMAT = Dynamic;

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
INSERT INTO `user_notifications` VALUES (43, 43, 2, 2, 1, '2026-03-14 12:41:33', '2026-03-08 14:07:01');
INSERT INTO `user_notifications` VALUES (44, 44, 1, 2, 1, '2026-03-08 15:00:54', '2026-03-08 14:09:01');
INSERT INTO `user_notifications` VALUES (45, 45, 1, 2, 1, '2026-03-08 15:00:54', '2026-03-08 14:17:01');
INSERT INTO `user_notifications` VALUES (46, 46, 1, 2, 1, '2026-03-08 15:00:54', '2026-03-08 14:17:01');
INSERT INTO `user_notifications` VALUES (47, 47, 5, 2, 0, NULL, '2026-03-09 20:33:00');
INSERT INTO `user_notifications` VALUES (48, 48, 3, 2, 1, '2026-03-15 11:12:27', '2026-03-09 21:29:10');
INSERT INTO `user_notifications` VALUES (49, 49, 1, 2, 1, '2026-03-11 11:56:11', '2026-03-11 11:53:01');
INSERT INTO `user_notifications` VALUES (50, 50, 1, 2, 1, '2026-03-11 12:54:13', '2026-03-11 12:08:01');
INSERT INTO `user_notifications` VALUES (51, 51, 1, 2, 1, '2026-03-11 12:54:16', '2026-03-11 12:09:01');
INSERT INTO `user_notifications` VALUES (52, 52, 19, 1, 0, NULL, '2026-03-13 13:00:01');
INSERT INTO `user_notifications` VALUES (53, 53, 1, 2, 1, '2026-03-13 13:31:56', '2026-03-13 13:17:01');
INSERT INTO `user_notifications` VALUES (54, 54, 18, 1, 0, NULL, '2026-03-13 13:35:01');
INSERT INTO `user_notifications` VALUES (55, 55, 1, 2, 1, '2026-03-13 13:59:02', '2026-03-13 13:42:02');
INSERT INTO `user_notifications` VALUES (56, 56, 1, 2, 1, '2026-03-13 13:59:02', '2026-03-13 13:55:02');
INSERT INTO `user_notifications` VALUES (57, 57, 1, 2, 1, '2026-03-13 13:59:02', '2026-03-13 13:55:02');
INSERT INTO `user_notifications` VALUES (58, 58, 5, 1, 0, NULL, '2026-03-13 22:25:02');
INSERT INTO `user_notifications` VALUES (59, 59, 5, 1, 0, NULL, '2026-03-13 23:26:02');
INSERT INTO `user_notifications` VALUES (60, 60, 3, 2, 1, '2026-03-15 11:12:27', '2026-03-14 11:59:02');
INSERT INTO `user_notifications` VALUES (61, 61, 3, 2, 1, '2026-03-15 11:12:27', '2026-03-14 12:04:01');
INSERT INTO `user_notifications` VALUES (62, 62, 3, 2, 1, '2026-03-15 11:12:27', '2026-03-14 12:04:01');
INSERT INTO `user_notifications` VALUES (63, 63, 5, 1, 0, NULL, '2026-03-14 13:41:52');
INSERT INTO `user_notifications` VALUES (64, 64, 3, 2, 1, '2026-03-15 11:12:27', '2026-03-14 13:48:19');
INSERT INTO `user_notifications` VALUES (65, 65, 3, 2, 1, '2026-03-15 11:12:27', '2026-03-14 13:48:21');
INSERT INTO `user_notifications` VALUES (66, 66, 1, 2, 1, '2026-03-14 13:50:52', '2026-03-14 13:50:30');
INSERT INTO `user_notifications` VALUES (67, 67, 2, 2, 1, '2026-03-14 14:17:38', '2026-03-14 14:17:02');
INSERT INTO `user_notifications` VALUES (68, 68, 2, 2, 1, '2026-03-14 14:17:38', '2026-03-14 14:17:02');
INSERT INTO `user_notifications` VALUES (69, 69, 5, 1, 0, NULL, '2026-03-14 14:52:26');
INSERT INTO `user_notifications` VALUES (70, 70, 1, 2, 1, '2026-03-14 15:06:41', '2026-03-14 14:58:30');
INSERT INTO `user_notifications` VALUES (71, 71, 3, 2, 1, '2026-03-15 11:12:27', '2026-03-14 22:29:06');
INSERT INTO `user_notifications` VALUES (72, 72, 5, 1, 0, NULL, '2026-03-14 22:54:02');
INSERT INTO `user_notifications` VALUES (73, 73, 5, 1, 0, NULL, '2026-03-14 23:27:36');
INSERT INTO `user_notifications` VALUES (74, 74, 3, 2, 1, '2026-03-15 11:12:27', '2026-03-14 23:30:10');
INSERT INTO `user_notifications` VALUES (75, 75, 3, 2, 0, NULL, '2026-03-15 11:24:01');
INSERT INTO `user_notifications` VALUES (76, 76, 1, 2, 1, '2026-03-15 12:41:14', '2026-03-15 12:17:02');
INSERT INTO `user_notifications` VALUES (77, 77, 2, 2, 1, '2026-03-15 12:33:41', '2026-03-15 12:22:01');
INSERT INTO `user_notifications` VALUES (78, 78, 2, 2, 1, '2026-03-15 13:28:34', '2026-03-15 12:34:01');
INSERT INTO `user_notifications` VALUES (79, 79, 2, 2, 1, '2026-03-15 13:28:34', '2026-03-15 12:34:01');
INSERT INTO `user_notifications` VALUES (80, 80, 5, 1, 0, NULL, '2026-03-15 13:15:02');
INSERT INTO `user_notifications` VALUES (81, 81, 1, 2, 1, '2026-03-15 14:01:40', '2026-03-15 13:45:56');
INSERT INTO `user_notifications` VALUES (82, 82, 19, 1, 0, NULL, '2026-03-15 15:07:01');
INSERT INTO `user_notifications` VALUES (83, 83, 21, 1, 0, NULL, '2026-03-15 15:35:01');
INSERT INTO `user_notifications` VALUES (84, 84, 23, 1, 0, NULL, '2026-03-15 16:41:01');
INSERT INTO `user_notifications` VALUES (85, 85, 21, 1, 0, NULL, '2026-03-15 16:47:01');
INSERT INTO `user_notifications` VALUES (86, 86, 26, 1, 0, NULL, '2026-03-15 17:06:02');
INSERT INTO `user_notifications` VALUES (87, 87, 7, 2, 1, '2026-03-15 17:23:18', '2026-03-15 17:07:55');
INSERT INTO `user_notifications` VALUES (88, 88, 7, 2, 1, '2026-03-15 17:23:18', '2026-03-15 17:22:01');
INSERT INTO `user_notifications` VALUES (89, 89, 7, 2, 1, '2026-03-15 17:35:03', '2026-03-15 17:33:01');
INSERT INTO `user_notifications` VALUES (90, 90, 7, 2, 1, '2026-03-15 17:34:55', '2026-03-15 17:33:01');
INSERT INTO `user_notifications` VALUES (91, 91, 7, 2, 1, '2026-03-15 22:05:39', '2026-03-15 18:10:01');
INSERT INTO `user_notifications` VALUES (92, 92, 21, 1, 0, NULL, '2026-03-15 18:27:01');
INSERT INTO `user_notifications` VALUES (93, 93, 1, 2, 1, '2026-03-15 18:59:17', '2026-03-15 18:50:02');
INSERT INTO `user_notifications` VALUES (94, 94, 21, 1, 0, NULL, '2026-03-15 18:56:02');
INSERT INTO `user_notifications` VALUES (95, 95, 30, 1, 0, NULL, '2026-03-15 19:58:02');
INSERT INTO `user_notifications` VALUES (96, 96, 33, 1, 0, NULL, '2026-03-15 20:02:02');
INSERT INTO `user_notifications` VALUES (97, 97, 31, 1, 0, NULL, '2026-03-15 20:02:02');
INSERT INTO `user_notifications` VALUES (98, 98, 37, 1, 0, NULL, '2026-03-15 20:13:01');
INSERT INTO `user_notifications` VALUES (99, 99, 1, 2, 1, '2026-03-15 20:21:01', '2026-03-15 20:20:01');
INSERT INTO `user_notifications` VALUES (100, 100, 31, 1, 0, NULL, '2026-03-15 20:20:01');
INSERT INTO `user_notifications` VALUES (101, 101, 23, 1, 0, NULL, '2026-03-15 20:25:02');
INSERT INTO `user_notifications` VALUES (102, 102, 39, 1, 0, NULL, '2026-03-15 20:25:02');
INSERT INTO `user_notifications` VALUES (103, 103, 37, 1, 0, NULL, '2026-03-15 20:27:01');
INSERT INTO `user_notifications` VALUES (104, 104, 26, 1, 0, NULL, '2026-03-15 20:30:02');
INSERT INTO `user_notifications` VALUES (105, 105, 36, 1, 1, '2026-03-16 09:19:31', '2026-03-15 20:35:02');
INSERT INTO `user_notifications` VALUES (106, 106, 33, 1, 0, NULL, '2026-03-15 20:39:02');
INSERT INTO `user_notifications` VALUES (107, 107, 31, 1, 0, NULL, '2026-03-15 20:40:01');
INSERT INTO `user_notifications` VALUES (108, 108, 26, 1, 0, NULL, '2026-03-15 20:45:01');
INSERT INTO `user_notifications` VALUES (109, 109, 31, 1, 0, NULL, '2026-03-15 20:53:01');
INSERT INTO `user_notifications` VALUES (110, 110, 32, 1, 0, NULL, '2026-03-15 21:03:01');
INSERT INTO `user_notifications` VALUES (111, 111, 31, 1, 0, NULL, '2026-03-15 21:04:01');
INSERT INTO `user_notifications` VALUES (112, 112, 28, 1, 0, NULL, '2026-03-15 21:09:01');
INSERT INTO `user_notifications` VALUES (113, 113, 28, 1, 0, NULL, '2026-03-15 21:24:01');
INSERT INTO `user_notifications` VALUES (114, 114, 1, 2, 1, '2026-03-15 21:29:10', '2026-03-15 21:28:02');
INSERT INTO `user_notifications` VALUES (115, 115, 22, 1, 0, NULL, '2026-03-15 21:44:01');
INSERT INTO `user_notifications` VALUES (116, 116, 23, 1, 0, NULL, '2026-03-15 21:48:01');
INSERT INTO `user_notifications` VALUES (117, 117, 42, 1, 0, NULL, '2026-03-15 21:49:02');
INSERT INTO `user_notifications` VALUES (118, 118, 42, 1, 0, NULL, '2026-03-15 22:01:01');
INSERT INTO `user_notifications` VALUES (119, 119, 42, 1, 0, NULL, '2026-03-15 22:30:01');
INSERT INTO `user_notifications` VALUES (120, 120, 7, 2, 1, '2026-03-15 22:35:30', '2026-03-15 22:32:01');
INSERT INTO `user_notifications` VALUES (121, 121, 7, 2, 1, '2026-03-15 22:35:30', '2026-03-15 22:32:01');
INSERT INTO `user_notifications` VALUES (122, 122, 7, 2, 1, '2026-03-15 22:35:30', '2026-03-15 22:34:01');
INSERT INTO `user_notifications` VALUES (123, 123, 26, 1, 0, NULL, '2026-03-15 23:11:02');
INSERT INTO `user_notifications` VALUES (124, 124, 3, 2, 0, NULL, '2026-03-15 23:34:24');
INSERT INTO `user_notifications` VALUES (125, 125, 7, 2, 0, NULL, '2026-03-16 00:16:01');
INSERT INTO `user_notifications` VALUES (126, 126, 7, 2, 0, NULL, '2026-03-16 00:16:01');
INSERT INTO `user_notifications` VALUES (127, 127, 1, 2, 1, '2026-03-16 14:19:19', '2026-03-16 03:21:02');
INSERT INTO `user_notifications` VALUES (128, 128, 1, 2, 1, '2026-03-16 14:19:19', '2026-03-16 03:37:01');
INSERT INTO `user_notifications` VALUES (129, 129, 1, 2, 1, '2026-03-16 14:19:19', '2026-03-16 04:49:01');
INSERT INTO `user_notifications` VALUES (130, 130, 1, 2, 1, '2026-03-16 14:19:19', '2026-03-16 07:52:01');
INSERT INTO `user_notifications` VALUES (131, 131, 1, 2, 1, '2026-03-16 14:19:19', '2026-03-16 08:44:01');
INSERT INTO `user_notifications` VALUES (132, 132, 3, 2, 0, NULL, '2026-03-16 09:22:02');
INSERT INTO `user_notifications` VALUES (133, 133, 37, 1, 1, '2026-03-16 17:24:42', '2026-03-16 12:37:08');
INSERT INTO `user_notifications` VALUES (134, 134, 1, 2, 1, '2026-03-17 09:41:22', '2026-03-17 09:08:02');
INSERT INTO `user_notifications` VALUES (135, 135, 2, 2, 1, '2026-03-17 10:27:29', '2026-03-17 09:52:00');
INSERT INTO `user_notifications` VALUES (136, 136, 47, 1, 0, NULL, '2026-03-17 10:05:01');
INSERT INTO `user_notifications` VALUES (137, 137, 1, 2, 1, '2026-03-17 10:31:28', '2026-03-17 10:07:01');
INSERT INTO `user_notifications` VALUES (138, 138, 22, 1, 1, '2026-03-17 15:02:46', '2026-03-17 10:08:01');
INSERT INTO `user_notifications` VALUES (139, 139, 31, 1, 0, NULL, '2026-03-17 10:16:01');
INSERT INTO `user_notifications` VALUES (140, 140, 5, 1, 0, NULL, '2026-03-17 10:17:01');
INSERT INTO `user_notifications` VALUES (141, 141, 28, 1, 0, NULL, '2026-03-17 10:23:01');
INSERT INTO `user_notifications` VALUES (142, 142, 42, 1, 0, NULL, '2026-03-17 10:30:01');
INSERT INTO `user_notifications` VALUES (143, 143, 22, 1, 1, '2026-03-17 15:02:46', '2026-03-17 10:35:02');
INSERT INTO `user_notifications` VALUES (144, 144, 42, 1, 0, NULL, '2026-03-17 10:48:02');
INSERT INTO `user_notifications` VALUES (145, 145, 55, 1, 0, NULL, '2026-03-17 11:46:01');
INSERT INTO `user_notifications` VALUES (146, 146, 56, 1, 0, NULL, '2026-03-17 11:55:01');
INSERT INTO `user_notifications` VALUES (147, 147, 42, 1, 0, NULL, '2026-03-17 12:26:01');
INSERT INTO `user_notifications` VALUES (148, 148, 35, 1, 0, NULL, '2026-03-17 12:58:01');
INSERT INTO `user_notifications` VALUES (149, 149, 57, 1, 0, NULL, '2026-03-17 13:27:01');
INSERT INTO `user_notifications` VALUES (150, 150, 35, 1, 0, NULL, '2026-03-17 14:04:01');
INSERT INTO `user_notifications` VALUES (151, 151, 60, 1, 0, NULL, '2026-03-17 15:40:01');
INSERT INTO `user_notifications` VALUES (152, 152, 35, 1, 0, NULL, '2026-03-17 16:19:01');
INSERT INTO `user_notifications` VALUES (153, 153, 22, 1, 0, NULL, '2026-03-17 18:06:02');
INSERT INTO `user_notifications` VALUES (154, 154, 22, 1, 0, NULL, '2026-03-17 18:26:01');
INSERT INTO `user_notifications` VALUES (155, 155, 65, 1, 0, NULL, '2026-03-17 19:15:01');
INSERT INTO `user_notifications` VALUES (156, 156, 8, 2, 1, '2026-03-17 19:40:42', '2026-03-17 19:29:48');
INSERT INTO `user_notifications` VALUES (157, 157, 66, 1, 0, NULL, '2026-03-17 19:33:01');
INSERT INTO `user_notifications` VALUES (158, 158, 65, 1, 0, NULL, '2026-03-17 19:39:02');
INSERT INTO `user_notifications` VALUES (159, 159, 48, 1, 0, NULL, '2026-03-17 19:50:02');
INSERT INTO `user_notifications` VALUES (160, 160, 48, 1, 0, NULL, '2026-03-17 20:03:01');
INSERT INTO `user_notifications` VALUES (161, 161, 63, 1, 0, NULL, '2026-03-17 20:07:01');
INSERT INTO `user_notifications` VALUES (162, 162, 67, 1, 0, NULL, '2026-03-17 20:08:01');
INSERT INTO `user_notifications` VALUES (163, 163, 28, 1, 0, NULL, '2026-03-17 20:11:01');
INSERT INTO `user_notifications` VALUES (164, 164, 48, 1, 0, NULL, '2026-03-17 20:14:01');
INSERT INTO `user_notifications` VALUES (165, 165, 68, 1, 0, NULL, '2026-03-17 20:15:01');
INSERT INTO `user_notifications` VALUES (166, 166, 35, 1, 0, NULL, '2026-03-17 20:24:02');
INSERT INTO `user_notifications` VALUES (167, 167, 42, 1, 0, NULL, '2026-03-17 20:27:01');
INSERT INTO `user_notifications` VALUES (168, 168, 65, 1, 0, NULL, '2026-03-17 20:27:01');
INSERT INTO `user_notifications` VALUES (169, 169, 25, 1, 0, NULL, '2026-03-17 20:29:01');
INSERT INTO `user_notifications` VALUES (170, 170, 42, 1, 0, NULL, '2026-03-17 20:40:02');
INSERT INTO `user_notifications` VALUES (171, 171, 25, 1, 0, NULL, '2026-03-17 20:58:01');
INSERT INTO `user_notifications` VALUES (172, 172, 27, 1, 0, NULL, '2026-03-17 21:00:01');
INSERT INTO `user_notifications` VALUES (173, 173, 25, 1, 0, NULL, '2026-03-17 21:15:02');
INSERT INTO `user_notifications` VALUES (174, 174, 27, 1, 0, NULL, '2026-03-17 21:19:01');
INSERT INTO `user_notifications` VALUES (175, 175, 69, 1, 0, NULL, '2026-03-17 21:20:02');
INSERT INTO `user_notifications` VALUES (176, 176, 35, 1, 0, NULL, '2026-03-17 21:28:01');
INSERT INTO `user_notifications` VALUES (177, 177, 69, 1, 0, NULL, '2026-03-17 21:32:01');
INSERT INTO `user_notifications` VALUES (178, 178, 22, 1, 0, NULL, '2026-03-17 21:32:01');
INSERT INTO `user_notifications` VALUES (179, 179, 1, 2, 1, '2026-03-17 21:42:20', '2026-03-17 21:40:01');
INSERT INTO `user_notifications` VALUES (180, 180, 69, 1, 0, NULL, '2026-03-17 21:45:02');
INSERT INTO `user_notifications` VALUES (181, 181, 35, 1, 0, NULL, '2026-03-17 21:52:02');
INSERT INTO `user_notifications` VALUES (182, 182, 63, 1, 0, NULL, '2026-03-17 22:15:01');
INSERT INTO `user_notifications` VALUES (183, 183, 22, 1, 0, NULL, '2026-03-17 22:16:01');
INSERT INTO `user_notifications` VALUES (184, 184, 18, 1, 0, NULL, '2026-03-17 22:26:02');
INSERT INTO `user_notifications` VALUES (185, 185, 71, 1, 0, NULL, '2026-03-17 22:31:01');
INSERT INTO `user_notifications` VALUES (186, 186, 22, 1, 0, NULL, '2026-03-17 22:39:01');
INSERT INTO `user_notifications` VALUES (187, 187, 22, 1, 0, NULL, '2026-03-17 22:50:01');
INSERT INTO `user_notifications` VALUES (188, 188, 62, 1, 0, NULL, '2026-03-18 00:11:02');
INSERT INTO `user_notifications` VALUES (189, 189, 48, 1, 0, NULL, '2026-03-18 00:17:01');
INSERT INTO `user_notifications` VALUES (190, 190, 62, 1, 0, NULL, '2026-03-18 00:23:02');
INSERT INTO `user_notifications` VALUES (191, 191, 1, 2, 0, NULL, '2026-03-18 14:07:01');
INSERT INTO `user_notifications` VALUES (192, 192, 1, 2, 0, NULL, '2026-03-18 14:07:01');
INSERT INTO `user_notifications` VALUES (193, 193, 2, 2, 0, NULL, '2026-03-18 14:07:01');
INSERT INTO `user_notifications` VALUES (194, 194, 2, 2, 0, NULL, '2026-03-18 14:07:01');
INSERT INTO `user_notifications` VALUES (195, 195, 2, 2, 0, NULL, '2026-03-18 14:07:01');
INSERT INTO `user_notifications` VALUES (196, 196, 2, 2, 0, NULL, '2026-03-18 14:07:02');
INSERT INTO `user_notifications` VALUES (197, 197, 2, 2, 0, NULL, '2026-03-18 14:07:02');

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付密码表-钱包支付密码管理' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of wallet_password
-- ----------------------------
INSERT INTO `wallet_password` VALUES (1, 8, 5, 1, '123456', '2026-03-10 17:02:05', '2026-03-10 17:02:05');
INSERT INTO `wallet_password` VALUES (2, 26, 6, 2, '123456', '2026-03-15 13:47:50', '2026-03-15 13:47:50');
INSERT INTO `wallet_password` VALUES (3, 31, 25, 1, '430430', '2026-03-15 18:00:15', '2026-03-15 18:00:15');
INSERT INTO `wallet_password` VALUES (4, 50, 43, 1, '900806', '2026-03-16 09:00:43', '2026-03-16 09:00:43');

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
) ENGINE = InnoDB AUTO_INCREMENT = 86 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '钱包表-三端共用' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of wallets
-- ----------------------------
INSERT INTO `wallets` VALUES (1, 0, '2026-02-27 11:49:20', '2026-03-18 17:03:19');
INSERT INTO `wallets` VALUES (2, 0, '2026-02-27 12:02:50', '2026-03-18 17:03:20');
INSERT INTO `wallets` VALUES (3, 0, '2026-02-27 13:06:22', '2026-02-27 13:06:22');
INSERT INTO `wallets` VALUES (4, 0, '2026-02-27 17:24:33', '2026-03-16 18:41:57');
INSERT INTO `wallets` VALUES (5, 0, '2026-02-27 17:26:27', '2026-02-27 17:26:27');
INSERT INTO `wallets` VALUES (6, 0, '2026-02-27 17:31:08', '2026-02-27 17:31:08');
INSERT INTO `wallets` VALUES (7, 0, '2026-03-01 00:48:16', '2026-03-16 18:42:00');
INSERT INTO `wallets` VALUES (8, 0, '2026-03-01 00:53:23', '2026-03-18 17:03:23');
INSERT INTO `wallets` VALUES (9, 0, '2026-03-02 00:12:06', '2026-03-16 18:42:05');
INSERT INTO `wallets` VALUES (10, 0, '2026-03-06 14:46:54', '2026-03-06 14:46:54');
INSERT INTO `wallets` VALUES (11, 0, '2026-03-08 12:06:11', '2026-03-16 18:42:07');
INSERT INTO `wallets` VALUES (23, 0, '2026-03-11 12:23:27', '2026-03-18 17:03:25');
INSERT INTO `wallets` VALUES (24, 0, '2026-03-13 12:47:21', '2026-03-16 18:42:55');
INSERT INTO `wallets` VALUES (25, 0, '2026-03-15 12:42:31', '2026-03-15 12:42:31');
INSERT INTO `wallets` VALUES (26, 0, '2026-03-15 13:28:02', '2026-03-15 13:28:02');
INSERT INTO `wallets` VALUES (27, 0, '2026-03-15 13:52:44', '2026-03-16 18:42:49');
INSERT INTO `wallets` VALUES (28, 0, '2026-03-15 14:22:08', '2026-03-18 17:03:29');
INSERT INTO `wallets` VALUES (29, 0, '2026-03-15 15:05:50', '2026-03-16 18:42:43');
INSERT INTO `wallets` VALUES (30, 0, '2026-03-15 15:33:06', '2026-03-15 15:33:06');
INSERT INTO `wallets` VALUES (31, 0, '2026-03-15 16:48:38', '2026-03-18 17:03:31');
INSERT INTO `wallets` VALUES (32, 0, '2026-03-15 16:55:20', '2026-03-18 17:03:32');
INSERT INTO `wallets` VALUES (33, 0, '2026-03-15 17:03:56', '2026-03-16 18:42:33');
INSERT INTO `wallets` VALUES (34, 0, '2026-03-15 17:22:13', '2026-03-18 17:03:34');
INSERT INTO `wallets` VALUES (35, 0, '2026-03-15 18:16:34', '2026-03-16 18:42:30');
INSERT INTO `wallets` VALUES (36, 0, '2026-03-15 19:12:49', '2026-03-15 19:12:49');
INSERT INTO `wallets` VALUES (37, 0, '2026-03-15 19:17:41', '2026-03-18 17:03:36');
INSERT INTO `wallets` VALUES (38, 0, '2026-03-15 19:19:35', '2026-03-16 18:42:24');
INSERT INTO `wallets` VALUES (39, 0, '2026-03-15 19:23:26', '2026-03-15 19:23:26');
INSERT INTO `wallets` VALUES (40, 0, '2026-03-15 19:27:09', '2026-03-15 19:27:09');
INSERT INTO `wallets` VALUES (41, 0, '2026-03-15 19:29:13', '2026-03-15 19:29:13');
INSERT INTO `wallets` VALUES (42, 0, '2026-03-15 19:29:22', '2026-03-18 17:03:38');
INSERT INTO `wallets` VALUES (43, 0, '2026-03-15 19:57:09', '2026-03-16 18:42:22');
INSERT INTO `wallets` VALUES (44, 0, '2026-03-15 20:01:16', '2026-03-16 18:42:19');
INSERT INTO `wallets` VALUES (45, 0, '2026-03-15 20:01:21', '2026-03-15 20:01:21');
INSERT INTO `wallets` VALUES (46, 0, '2026-03-15 20:12:49', '2026-03-15 20:12:49');
INSERT INTO `wallets` VALUES (47, 0, '2026-03-15 20:17:13', '2026-03-18 17:03:43');
INSERT INTO `wallets` VALUES (48, 0, '2026-03-15 20:17:50', '2026-03-15 20:17:50');
INSERT INTO `wallets` VALUES (49, 0, '2026-03-15 21:13:31', '2026-03-18 17:03:45');
INSERT INTO `wallets` VALUES (50, 0, '2026-03-16 08:59:30', '2026-03-16 08:59:30');
INSERT INTO `wallets` VALUES (51, 0, '2026-03-16 09:00:06', '2026-03-16 09:00:06');
INSERT INTO `wallets` VALUES (52, 0, '2026-03-16 09:05:18', '2026-03-16 09:05:18');
INSERT INTO `wallets` VALUES (53, 0, '2026-03-16 10:00:40', '2026-03-16 10:00:40');
INSERT INTO `wallets` VALUES (54, 0, '2026-03-16 10:31:15', '2026-03-16 10:31:15');
INSERT INTO `wallets` VALUES (55, 0, '2026-03-16 11:15:09', '2026-03-16 11:15:09');
INSERT INTO `wallets` VALUES (56, 0, '2026-03-16 12:14:37', '2026-03-16 12:14:37');
INSERT INTO `wallets` VALUES (57, 0, '2026-03-16 13:46:56', '2026-03-18 17:03:47');
INSERT INTO `wallets` VALUES (58, 0, '2026-03-16 14:27:48', '2026-03-16 14:27:48');
INSERT INTO `wallets` VALUES (59, 0, '2026-03-16 21:10:50', '2026-03-16 21:10:50');
INSERT INTO `wallets` VALUES (60, 0, '2026-03-16 22:04:48', '2026-03-18 17:03:49');
INSERT INTO `wallets` VALUES (61, 0, '2026-03-17 10:39:59', '2026-03-17 10:39:59');
INSERT INTO `wallets` VALUES (62, 0, '2026-03-17 11:33:22', '2026-03-17 11:33:22');
INSERT INTO `wallets` VALUES (63, 0, '2026-03-17 11:43:52', '2026-03-17 11:43:52');
INSERT INTO `wallets` VALUES (64, 0, '2026-03-17 13:11:14', '2026-03-17 13:11:14');
INSERT INTO `wallets` VALUES (65, 0, '2026-03-17 13:56:17', '2026-03-18 17:03:50');
INSERT INTO `wallets` VALUES (66, 0, '2026-03-17 14:08:06', '2026-03-17 14:08:06');
INSERT INTO `wallets` VALUES (67, 0, '2026-03-17 15:08:27', '2026-03-18 17:03:52');
INSERT INTO `wallets` VALUES (68, 0, '2026-03-17 15:09:20', '2026-03-17 15:09:20');
INSERT INTO `wallets` VALUES (69, 0, '2026-03-17 15:14:48', '2026-03-18 17:03:56');
INSERT INTO `wallets` VALUES (70, 0, '2026-03-17 16:27:11', '2026-03-18 17:03:59');
INSERT INTO `wallets` VALUES (71, 0, '2026-03-17 18:35:00', '2026-03-18 17:04:01');
INSERT INTO `wallets` VALUES (72, 0, '2026-03-17 19:03:33', '2026-03-17 19:03:33');
INSERT INTO `wallets` VALUES (73, 0, '2026-03-17 19:20:48', '2026-03-17 19:20:48');
INSERT INTO `wallets` VALUES (74, 0, '2026-03-17 19:27:19', '2026-03-18 17:04:03');
INSERT INTO `wallets` VALUES (75, 0, '2026-03-17 19:56:11', '2026-03-17 19:56:11');
INSERT INTO `wallets` VALUES (76, 0, '2026-03-17 20:03:37', '2026-03-17 20:03:37');
INSERT INTO `wallets` VALUES (77, 0, '2026-03-17 21:08:46', '2026-03-17 21:08:46');
INSERT INTO `wallets` VALUES (78, 0, '2026-03-17 21:37:06', '2026-03-17 21:37:06');
INSERT INTO `wallets` VALUES (79, 0, '2026-03-17 22:18:28', '2026-03-17 22:18:28');
INSERT INTO `wallets` VALUES (80, 0, '2026-03-17 23:37:39', '2026-03-18 17:04:05');
INSERT INTO `wallets` VALUES (81, 0, '2026-03-18 16:59:39', '2026-03-18 16:59:39');
INSERT INTO `wallets` VALUES (82, 0, '2026-03-19 23:44:25', '2026-03-19 23:44:25');
INSERT INTO `wallets` VALUES (83, 0, '2026-03-20 14:04:11', '2026-03-20 14:04:11');
INSERT INTO `wallets` VALUES (84, 0, '2026-03-20 18:31:21', '2026-03-20 18:31:21');
INSERT INTO `wallets` VALUES (85, 0, '2026-03-20 19:11:08', '2026-03-20 19:11:08');

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
) ENGINE = InnoDB AUTO_INCREMENT = 511 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '钱包流水表-记录所有收支' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wallets_log
-- ----------------------------
INSERT INTO `wallets_log` VALUES (337, 1, 1, 'Ceshi', 2, 1, 0, 0, 0, 'recharge', 21, NULL, NULL, '充值 ¥500.00（alipay），审核中', '2026-03-17 09:07:44');
INSERT INTO `wallets_log` VALUES (338, 1, 1, 'Ceshi', 2, 1, 50000, 0, 50000, 'recharge', 21, NULL, NULL, '充值到账：¥500.00', '2026-03-17 09:08:02');
INSERT INTO `wallets_log` VALUES (339, 1, 1, 'Ceshi', 2, 2, 900, 50000, 49100, 'task', 137, 1, '上评评论', '发布任务【上评评论】3个任务，扣除 ¥9.00', '2026-03-17 09:09:50');
INSERT INTO `wallets_log` VALUES (340, 1, 1, 'Ceshi', 2, 2, 900, 49100, 48200, 'task', 138, 1, '上评评论', '发布任务【上评评论】3个任务，扣除 ¥9.00', '2026-03-17 09:36:13');
INSERT INTO `wallets_log` VALUES (341, 1, 1, 'Ceshi', 2, 2, 600, 48200, 47600, 'task', 139, 2, '中评评论', '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-17 09:39:20');
INSERT INTO `wallets_log` VALUES (342, 1, 1, 'Ceshi', 2, 2, 500, 47600, 47100, 'task', 15, 3, '放大镜搜索词', '发布放大镜任务【放大镜搜索词】1个任务，扣除 ¥5.00', '2026-03-17 09:40:49');
INSERT INTO `wallets_log` VALUES (343, 37, 30, 'songjuan520', 1, 1, 100, 0, 100, 'commission', 138, 1, '上评评论', '完成任务获得佣金，任务ID：138', '2026-03-17 09:42:27');
INSERT INTO `wallets_log` VALUES (344, 32, 26, '1158799864', 1, 1, 50, 0, 50, 'agent_commission', 138, 1, '上评评论', '下级用户 songjuan520 完成任务，获得一级团长佣金，任务ID：138', '2026-03-17 09:42:27');
INSERT INTO `wallets_log` VALUES (345, 28, 22, 'SGYMQ', 1, 1, 240, 0, 240, 'second_agent_commission', 138, 1, '上评评论', '下级用户 1158799864 的团队成员完成任务，获得二级团长佣金，任务ID：138', '2026-03-17 09:42:27');
INSERT INTO `wallets_log` VALUES (346, 2, 2, 'Ceshi1', 2, 1, 0, 0, 0, 'recharge', 22, NULL, NULL, '充值 ¥500.00（alipay），审核中', '2026-03-17 09:51:49');
INSERT INTO `wallets_log` VALUES (347, 2, 2, 'Ceshi1', 2, 1, 50000, 0, 50000, 'recharge', 22, NULL, NULL, '充值到账：¥500.00', '2026-03-17 09:52:00');
INSERT INTO `wallets_log` VALUES (348, 2, 2, 'Ceshi1', 2, 2, 900, 50000, 49100, 'task', 140, 1, '上评评论', '发布任务【上评评论】3个任务，扣除 ¥9.00', '2026-03-17 09:56:23');
INSERT INTO `wallets_log` VALUES (349, 1, 1, 'Ceshi', 2, 1, 600, 47100, 47700, 'refund', 138, 0, '', '任务过期退款【上评评论】，未完成 2 个任务，退款 ¥6.00', '2026-03-17 10:07:01');
INSERT INTO `wallets_log` VALUES (350, 1, 1, 'Ceshi', 2, 2, 1500, 47700, 46200, 'task', 141, 1, '上评评论', '发布任务【上评评论】5个任务，扣除 ¥15.00', '2026-03-17 10:33:02');
INSERT INTO `wallets_log` VALUES (351, 1, 1, 'Ceshi', 2, 2, 300, 46200, 45900, 'task', 142, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-17 11:37:22');
INSERT INTO `wallets_log` VALUES (352, 1, 1, 'Ceshi', 2, 2, 300, 45900, 45600, 'task', 143, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-17 11:38:12');
INSERT INTO `wallets_log` VALUES (353, 1, 1, 'Ceshi', 2, 2, 300, 45600, 45300, 'task', 144, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-17 11:39:04');
INSERT INTO `wallets_log` VALUES (354, 1, 1, 'Ceshi', 2, 2, 300, 45300, 45000, 'task', 145, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-17 11:39:05');
INSERT INTO `wallets_log` VALUES (355, 1, 1, 'Ceshi', 2, 2, 300, 45000, 44700, 'task', 146, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-17 11:40:54');
INSERT INTO `wallets_log` VALUES (356, 1, 1, 'Ceshi', 2, 2, 300, 44700, 44400, 'task', 147, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-17 11:42:17');
INSERT INTO `wallets_log` VALUES (357, 57, 50, 'sun92', 1, 1, 100, 0, 100, 'commission', 147, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：147', '2026-03-17 12:27:01');
INSERT INTO `wallets_log` VALUES (358, 49, 42, 'xy25', 1, 1, 50, 0, 50, 'agent_commission', 147, 1, '上评评论', '下级用户 sun92是普通团长 完成任务，获得普通团长佣金，任务ID：147', '2026-03-17 12:27:01');
INSERT INTO `wallets_log` VALUES (359, 28, 22, 'SGYMQ', 1, 1, 240, 240, 480, 'second_agent_commission', 147, 1, '上评评论', '下级用户 xy25 的团队成员完成任务，获得二级团长佣金，任务ID：147', '2026-03-17 12:27:01');
INSERT INTO `wallets_log` VALUES (360, 65, 58, 'Yjx123', 1, 1, 100, 0, 100, 'commission', 146, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：146', '2026-03-17 14:11:01');
INSERT INTO `wallets_log` VALUES (361, 42, 35, 'YUAN520', 1, 1, 50, 0, 50, 'agent_commission', 146, 1, '上评评论', '下级用户 Yjx123是普通团长 完成任务，获得普通团长佣金，任务ID：146', '2026-03-17 14:11:01');
INSERT INTO `wallets_log` VALUES (362, 28, 22, 'SGYMQ', 1, 1, 240, 480, 720, 'second_agent_commission', 146, 1, '上评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：146', '2026-03-17 14:11:01');
INSERT INTO `wallets_log` VALUES (363, 65, 58, 'Yjx123', 1, 1, 100, 100, 200, 'commission', 143, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：143', '2026-03-17 14:12:02');
INSERT INTO `wallets_log` VALUES (364, 42, 35, 'YUAN520', 1, 1, 50, 50, 100, 'agent_commission', 143, 1, '上评评论', '下级用户 Yjx123是普通团长 完成任务，获得普通团长佣金，任务ID：143', '2026-03-17 14:12:02');
INSERT INTO `wallets_log` VALUES (365, 28, 22, 'SGYMQ', 1, 1, 240, 720, 960, 'second_agent_commission', 143, 1, '上评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：143', '2026-03-17 14:12:02');
INSERT INTO `wallets_log` VALUES (366, 65, 58, 'Yjx123', 1, 1, 100, 200, 300, 'commission', 137, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：137', '2026-03-17 14:14:01');
INSERT INTO `wallets_log` VALUES (367, 42, 35, 'YUAN520', 1, 1, 50, 100, 150, 'agent_commission', 137, 1, '上评评论', '下级用户 Yjx123是普通团长 完成任务，获得普通团长佣金，任务ID：137', '2026-03-17 14:14:01');
INSERT INTO `wallets_log` VALUES (368, 28, 22, 'SGYMQ', 1, 1, 240, 960, 1200, 'second_agent_commission', 137, 1, '上评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：137', '2026-03-17 14:14:01');
INSERT INTO `wallets_log` VALUES (369, 65, 58, 'Yjx123', 1, 1, 100, 300, 400, 'commission', 145, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：145', '2026-03-17 14:32:01');
INSERT INTO `wallets_log` VALUES (370, 42, 35, 'YUAN520', 1, 1, 50, 150, 200, 'agent_commission', 145, 1, '上评评论', '下级用户 Yjx123是普通团长 完成任务，获得普通团长佣金，任务ID：145', '2026-03-17 14:32:01');
INSERT INTO `wallets_log` VALUES (371, 28, 22, 'SGYMQ', 1, 1, 240, 1200, 1440, 'second_agent_commission', 145, 1, '上评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：145', '2026-03-17 14:32:01');
INSERT INTO `wallets_log` VALUES (372, 65, 58, 'Yjx123', 1, 1, 100, 400, 500, 'commission', 142, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：142', '2026-03-17 14:42:02');
INSERT INTO `wallets_log` VALUES (373, 42, 35, 'YUAN520', 1, 1, 50, 200, 250, 'agent_commission', 142, 1, '上评评论', '下级用户 Yjx123是普通团长 完成任务，获得普通团长佣金，任务ID：142', '2026-03-17 14:42:02');
INSERT INTO `wallets_log` VALUES (374, 28, 22, 'SGYMQ', 1, 1, 240, 1440, 1680, 'second_agent_commission', 142, 1, '上评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：142', '2026-03-17 14:42:02');
INSERT INTO `wallets_log` VALUES (375, 65, 58, 'Yjx123', 1, 1, 100, 500, 600, 'commission', 144, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：144', '2026-03-17 14:47:01');
INSERT INTO `wallets_log` VALUES (376, 42, 35, 'YUAN520', 1, 1, 50, 250, 300, 'agent_commission', 144, 1, '上评评论', '下级用户 Yjx123是普通团长 完成任务，获得普通团长佣金，任务ID：144', '2026-03-17 14:47:01');
INSERT INTO `wallets_log` VALUES (377, 28, 22, 'SGYMQ', 1, 1, 240, 1680, 1920, 'second_agent_commission', 144, 1, '上评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：144', '2026-03-17 14:47:01');
INSERT INTO `wallets_log` VALUES (378, 65, 58, 'Yjx123', 1, 1, 100, 600, 700, 'commission', 140, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：140', '2026-03-17 14:48:02');
INSERT INTO `wallets_log` VALUES (379, 42, 35, 'YUAN520', 1, 1, 50, 300, 350, 'agent_commission', 140, 1, '上评评论', '下级用户 Yjx123是普通团长 完成任务，获得普通团长佣金，任务ID：140', '2026-03-17 14:48:02');
INSERT INTO `wallets_log` VALUES (380, 28, 22, 'SGYMQ', 1, 1, 240, 1920, 2160, 'second_agent_commission', 140, 1, '上评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：140', '2026-03-17 14:48:02');
INSERT INTO `wallets_log` VALUES (381, 67, 60, 'Fang194312', 1, 1, 100, 0, 100, 'commission', 141, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：141', '2026-03-17 15:27:02');
INSERT INTO `wallets_log` VALUES (382, 42, 35, 'YUAN520', 1, 1, 50, 350, 400, 'agent_commission', 141, 1, '上评评论', '下级用户 Fang194312是普通团长 完成任务，获得普通团长佣金，任务ID：141', '2026-03-17 15:27:02');
INSERT INTO `wallets_log` VALUES (383, 28, 22, 'SGYMQ', 1, 1, 240, 2160, 2400, 'second_agent_commission', 141, 1, '上评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：141', '2026-03-17 15:27:02');
INSERT INTO `wallets_log` VALUES (384, 67, 60, 'Fang194312', 1, 1, 100, 100, 200, 'commission', 137, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：137', '2026-03-17 15:30:02');
INSERT INTO `wallets_log` VALUES (385, 42, 35, 'YUAN520', 1, 1, 50, 400, 450, 'agent_commission', 137, 1, '上评评论', '下级用户 Fang194312是普通团长 完成任务，获得普通团长佣金，任务ID：137', '2026-03-17 15:30:02');
INSERT INTO `wallets_log` VALUES (386, 28, 22, 'SGYMQ', 1, 1, 240, 2400, 2640, 'second_agent_commission', 137, 1, '上评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：137', '2026-03-17 15:30:02');
INSERT INTO `wallets_log` VALUES (387, 69, 62, 'liang520', 1, 1, 100, 0, 100, 'commission', 141, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：141', '2026-03-17 15:44:01');
INSERT INTO `wallets_log` VALUES (388, 42, 35, 'YUAN520', 1, 1, 50, 450, 500, 'agent_commission', 141, 1, '上评评论', '下级用户 liang520是普通团长 完成任务，获得普通团长佣金，任务ID：141', '2026-03-17 15:44:01');
INSERT INTO `wallets_log` VALUES (389, 28, 22, 'SGYMQ', 1, 1, 240, 2640, 2880, 'second_agent_commission', 141, 1, '上评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：141', '2026-03-17 15:44:01');
INSERT INTO `wallets_log` VALUES (390, 69, 62, 'liang520', 1, 1, 100, 100, 200, 'commission', 140, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：140', '2026-03-17 16:12:02');
INSERT INTO `wallets_log` VALUES (391, 42, 35, 'YUAN520', 1, 1, 50, 500, 550, 'agent_commission', 140, 1, '上评评论', '下级用户 liang520是普通团长 完成任务，获得普通团长佣金，任务ID：140', '2026-03-17 16:12:02');
INSERT INTO `wallets_log` VALUES (392, 28, 22, 'SGYMQ', 1, 1, 240, 2880, 3120, 'second_agent_commission', 140, 1, '上评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：140', '2026-03-17 16:12:02');
INSERT INTO `wallets_log` VALUES (393, 69, 62, 'liang520', 1, 1, 80, 200, 280, 'commission', 139, 2, '中评评论', '自动审核通过任务获得佣金，任务ID：139', '2026-03-17 16:31:01');
INSERT INTO `wallets_log` VALUES (394, 42, 35, 'YUAN520', 1, 1, 30, 550, 580, 'agent_commission', 139, 2, '中评评论', '下级用户 liang520是普通团长 完成任务，获得普通团长佣金，任务ID：139', '2026-03-17 16:31:01');
INSERT INTO `wallets_log` VALUES (395, 28, 22, 'SGYMQ', 1, 1, 160, 3120, 3280, 'second_agent_commission', 139, 2, '中评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：139', '2026-03-17 16:31:01');
INSERT INTO `wallets_log` VALUES (396, 69, 62, 'liang520', 1, 1, 100, 280, 380, 'commission', 137, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：137', '2026-03-17 16:34:01');
INSERT INTO `wallets_log` VALUES (397, 42, 35, 'YUAN520', 1, 1, 50, 580, 630, 'agent_commission', 137, 1, '上评评论', '下级用户 liang520是普通团长 完成任务，获得普通团长佣金，任务ID：137', '2026-03-17 16:34:01');
INSERT INTO `wallets_log` VALUES (398, 28, 22, 'SGYMQ', 1, 1, 240, 3280, 3520, 'second_agent_commission', 137, 1, '上评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：137', '2026-03-17 16:34:01');
INSERT INTO `wallets_log` VALUES (399, 70, 63, '123456yjx', 1, 1, 100, 0, 100, 'commission', 141, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：141', '2026-03-17 16:40:01');
INSERT INTO `wallets_log` VALUES (400, 42, 35, 'YUAN520', 1, 1, 50, 630, 680, 'agent_commission', 141, 1, '上评评论', '下级用户 123456yjx是普通团长 完成任务，获得普通团长佣金，任务ID：141', '2026-03-17 16:40:01');
INSERT INTO `wallets_log` VALUES (401, 28, 22, 'SGYMQ', 1, 1, 240, 3520, 3760, 'second_agent_commission', 141, 1, '上评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：141', '2026-03-17 16:40:01');
INSERT INTO `wallets_log` VALUES (402, 70, 63, '123456yjx', 1, 1, 100, 100, 200, 'commission', 140, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：140', '2026-03-17 16:41:02');
INSERT INTO `wallets_log` VALUES (403, 42, 35, 'YUAN520', 1, 1, 50, 680, 730, 'agent_commission', 140, 1, '上评评论', '下级用户 123456yjx是普通团长 完成任务，获得普通团长佣金，任务ID：140', '2026-03-17 16:41:02');
INSERT INTO `wallets_log` VALUES (404, 28, 22, 'SGYMQ', 1, 1, 240, 3760, 4000, 'second_agent_commission', 140, 1, '上评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：140', '2026-03-17 16:41:02');
INSERT INTO `wallets_log` VALUES (405, 47, 40, '147369123789', 1, 1, 100, 0, 100, 'commission', 141, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：141', '2026-03-17 17:29:01');
INSERT INTO `wallets_log` VALUES (406, 32, 26, '1158799864', 1, 1, 50, 50, 100, 'agent_commission', 141, 1, '上评评论', '下级用户 147369123789是普通团长 完成任务，获得普通团长佣金，任务ID：141', '2026-03-17 17:29:01');
INSERT INTO `wallets_log` VALUES (407, 28, 22, 'SGYMQ', 1, 1, 240, 4000, 4240, 'second_agent_commission', 141, 1, '上评评论', '下级用户 1158799864 的团队成员完成任务，获得二级团长佣金，任务ID：141', '2026-03-17 17:29:01');
INSERT INTO `wallets_log` VALUES (408, 1, 1, 'Ceshi', 2, 2, 300, 44400, 44100, 'task', 148, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-17 18:09:52');
INSERT INTO `wallets_log` VALUES (409, 1, 1, 'Ceshi', 2, 2, 300, 44100, 43800, 'task', 149, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-17 18:10:16');
INSERT INTO `wallets_log` VALUES (410, 1, 1, 'Ceshi', 2, 2, 300, 43800, 43500, 'task', 150, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-17 18:11:00');
INSERT INTO `wallets_log` VALUES (411, 1, 1, 'Ceshi', 2, 2, 600, 43500, 42900, 'task', 151, 2, '中评评论', '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-17 18:12:16');
INSERT INTO `wallets_log` VALUES (412, 1, 1, 'Ceshi', 2, 2, 600, 42900, 42300, 'task', 152, 2, '中评评论', '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-17 18:13:25');
INSERT INTO `wallets_log` VALUES (413, 1, 1, 'Ceshi', 2, 2, 600, 42300, 41700, 'task', 153, 2, '中评评论', '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-17 18:14:18');
INSERT INTO `wallets_log` VALUES (414, 1, 1, 'Ceshi', 2, 2, 300, 41700, 41400, 'task', 154, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-17 18:15:38');
INSERT INTO `wallets_log` VALUES (415, 47, 40, '147369123789', 1, 1, 80, 100, 180, 'commission', 153, 2, '中评评论', '自动审核通过任务获得佣金，任务ID：153', '2026-03-17 18:31:01');
INSERT INTO `wallets_log` VALUES (416, 32, 26, '1158799864', 1, 1, 30, 100, 130, 'agent_commission', 153, 2, '中评评论', '下级用户 147369123789是普通团长 完成任务，获得普通团长佣金，任务ID：153', '2026-03-17 18:31:01');
INSERT INTO `wallets_log` VALUES (417, 28, 22, 'SGYMQ', 1, 1, 160, 4240, 4400, 'second_agent_commission', 153, 2, '中评评论', '下级用户 1158799864 的团队成员完成任务，获得二级团长佣金，任务ID：153', '2026-03-17 18:31:01');
INSERT INTO `wallets_log` VALUES (418, 71, 64, '987321147258', 1, 1, 100, 0, 100, 'commission', 154, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：154', '2026-03-17 18:49:01');
INSERT INTO `wallets_log` VALUES (419, 32, 26, '1158799864', 1, 1, 50, 130, 180, 'agent_commission', 154, 1, '上评评论', '下级用户 987321147258是普通团长 完成任务，获得普通团长佣金，任务ID：154', '2026-03-17 18:49:01');
INSERT INTO `wallets_log` VALUES (420, 28, 22, 'SGYMQ', 1, 1, 240, 4400, 4640, 'second_agent_commission', 154, 1, '上评评论', '下级用户 1158799864 的团队成员完成任务，获得二级团长佣金，任务ID：154', '2026-03-17 18:49:01');
INSERT INTO `wallets_log` VALUES (421, 69, 62, 'liang520', 1, 1, 80, 380, 460, 'commission', 153, 2, '中评评论', '自动审核通过任务获得佣金，任务ID：153', '2026-03-17 18:52:01');
INSERT INTO `wallets_log` VALUES (422, 42, 35, 'YUAN520', 1, 1, 30, 730, 760, 'agent_commission', 153, 2, '中评评论', '下级用户 liang520是普通团长 完成任务，获得普通团长佣金，任务ID：153', '2026-03-17 18:52:01');
INSERT INTO `wallets_log` VALUES (423, 28, 22, 'SGYMQ', 1, 1, 160, 4640, 4800, 'second_agent_commission', 153, 2, '中评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：153', '2026-03-17 18:52:01');
INSERT INTO `wallets_log` VALUES (424, 69, 62, 'liang520', 1, 1, 80, 460, 540, 'commission', 152, 2, '中评评论', '自动审核通过任务获得佣金，任务ID：152', '2026-03-17 18:53:01');
INSERT INTO `wallets_log` VALUES (425, 42, 35, 'YUAN520', 1, 1, 30, 760, 790, 'agent_commission', 152, 2, '中评评论', '下级用户 liang520是普通团长 完成任务，获得普通团长佣金，任务ID：152', '2026-03-17 18:53:01');
INSERT INTO `wallets_log` VALUES (426, 28, 22, 'SGYMQ', 1, 1, 160, 4800, 4960, 'second_agent_commission', 152, 2, '中评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：152', '2026-03-17 18:53:01');
INSERT INTO `wallets_log` VALUES (427, 71, 64, '987321147258', 1, 1, 100, 100, 200, 'commission', 141, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：141', '2026-03-17 18:53:01');
INSERT INTO `wallets_log` VALUES (428, 32, 26, '1158799864', 1, 1, 50, 180, 230, 'agent_commission', 141, 1, '上评评论', '下级用户 987321147258是普通团长 完成任务，获得普通团长佣金，任务ID：141', '2026-03-17 18:53:01');
INSERT INTO `wallets_log` VALUES (429, 28, 22, 'SGYMQ', 1, 1, 240, 4960, 5200, 'second_agent_commission', 141, 1, '上评评论', '下级用户 1158799864 的团队成员完成任务，获得二级团长佣金，任务ID：141', '2026-03-17 18:53:01');
INSERT INTO `wallets_log` VALUES (430, 69, 62, 'liang520', 1, 1, 80, 540, 620, 'commission', 151, 2, '中评评论', '自动审核通过任务获得佣金，任务ID：151', '2026-03-17 18:54:02');
INSERT INTO `wallets_log` VALUES (431, 42, 35, 'YUAN520', 1, 1, 30, 790, 820, 'agent_commission', 151, 2, '中评评论', '下级用户 liang520是普通团长 完成任务，获得普通团长佣金，任务ID：151', '2026-03-17 18:54:02');
INSERT INTO `wallets_log` VALUES (432, 28, 22, 'SGYMQ', 1, 1, 160, 5200, 5360, 'second_agent_commission', 151, 2, '中评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：151', '2026-03-17 18:54:02');
INSERT INTO `wallets_log` VALUES (433, 71, 64, '987321147258', 1, 1, 80, 200, 280, 'commission', 139, 2, '中评评论', '自动审核通过任务获得佣金，任务ID：139', '2026-03-17 18:54:02');
INSERT INTO `wallets_log` VALUES (434, 32, 26, '1158799864', 1, 1, 30, 230, 260, 'agent_commission', 139, 2, '中评评论', '下级用户 987321147258是普通团长 完成任务，获得普通团长佣金，任务ID：139', '2026-03-17 18:54:02');
INSERT INTO `wallets_log` VALUES (435, 28, 22, 'SGYMQ', 1, 1, 160, 5360, 5520, 'second_agent_commission', 139, 2, '中评评论', '下级用户 1158799864 的团队成员完成任务，获得二级团长佣金，任务ID：139', '2026-03-17 18:54:02');
INSERT INTO `wallets_log` VALUES (436, 2, 2, 'Ceshi1', 2, 2, 300, 49100, 48800, 'task', 155, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-17 19:01:04');
INSERT INTO `wallets_log` VALUES (437, 2, 2, 'Ceshi1', 2, 2, 600, 48800, 48200, 'task', 156, 2, '中评评论', '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-17 19:02:40');
INSERT INTO `wallets_log` VALUES (438, 74, 8, 'Ceshi0', 2, 1, 0, 0, 0, 'recharge', 23, NULL, NULL, '充值 ¥500.00（alipay），审核中', '2026-03-17 19:28:43');
INSERT INTO `wallets_log` VALUES (439, 74, 8, 'Ceshi0', 2, 1, 50000, 0, 50000, 'recharge', 23, NULL, NULL, '充值到账：¥500.00', '2026-03-17 19:29:48');
INSERT INTO `wallets_log` VALUES (440, 2, 2, 'Ceshi1', 2, 2, 300, 48200, 47900, 'task', 157, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-17 19:32:43');
INSERT INTO `wallets_log` VALUES (441, 2, 2, 'Ceshi1', 2, 2, 600, 47900, 47300, 'task', 158, 2, '中评评论', '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-17 19:34:16');
INSERT INTO `wallets_log` VALUES (442, 74, 8, 'Ceshi0', 2, 2, 700, 50000, 49300, 'task', 159, 4, '上中评评论', '发布任务【上中评评论】3个任务，扣除 ¥7.00', '2026-03-17 19:34:16');
INSERT INTO `wallets_log` VALUES (443, 2, 2, 'Ceshi1', 2, 2, 900, 47300, 46400, 'task', 161, 4, '上中评评论', '发布任务【上中评评论】4个任务，扣除 ¥9.00', '2026-03-17 19:35:39');
INSERT INTO `wallets_log` VALUES (444, 74, 8, 'Ceshi0', 2, 2, 600, 49300, 48700, 'task', 163, 5, '中下评评论', '发布任务【中下评评论】2个任务，扣除 ¥6.00', '2026-03-17 19:37:41');
INSERT INTO `wallets_log` VALUES (445, 2, 2, 'Ceshi1', 2, 2, 300, 46400, 46100, 'task', 165, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-17 19:47:58');
INSERT INTO `wallets_log` VALUES (446, 74, 8, 'Ceshi0', 2, 2, 600, 48700, 48100, 'task', 166, 5, '中下评评论', '发布任务【中下评评论】2个任务，扣除 ¥6.00', '2026-03-17 19:48:36');
INSERT INTO `wallets_log` VALUES (447, 2, 2, 'Ceshi1', 2, 2, 600, 46100, 45500, 'task', 168, 2, '中评评论', '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-17 19:48:47');
INSERT INTO `wallets_log` VALUES (448, 70, 63, '123456yjx', 1, 1, 130, 200, 330, 'commission', 166, 5, '中下评评论', '自动审核通过任务获得佣金，任务ID：166', '2026-03-17 20:03:01');
INSERT INTO `wallets_log` VALUES (449, 42, 35, 'YUAN520', 1, 1, 45, 820, 865, 'agent_commission', 166, 5, '中下评评论', '下级用户 123456yjx是普通团长 完成任务，获得普通团长佣金，任务ID：166', '2026-03-17 20:03:01');
INSERT INTO `wallets_log` VALUES (450, 28, 22, 'SGYMQ', 1, 1, 240, 5520, 5760, 'second_agent_commission', 166, 5, '中下评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：166', '2026-03-17 20:03:01');
INSERT INTO `wallets_log` VALUES (451, 70, 63, '123456yjx', 1, 1, 130, 330, 460, 'commission', 163, 5, '中下评评论', '自动审核通过任务获得佣金，任务ID：163', '2026-03-17 20:04:01');
INSERT INTO `wallets_log` VALUES (452, 42, 35, 'YUAN520', 1, 1, 45, 865, 910, 'agent_commission', 163, 5, '中下评评论', '下级用户 123456yjx是普通团长 完成任务，获得普通团长佣金，任务ID：163', '2026-03-17 20:04:01');
INSERT INTO `wallets_log` VALUES (453, 28, 22, 'SGYMQ', 1, 1, 240, 5760, 6000, 'second_agent_commission', 163, 5, '中下评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：163', '2026-03-17 20:04:01');
INSERT INTO `wallets_log` VALUES (454, 70, 63, '123456yjx', 1, 1, 100, 460, 560, 'commission', 159, 4, '上中评评论', '自动审核通过任务获得佣金，任务ID：159', '2026-03-17 20:05:01');
INSERT INTO `wallets_log` VALUES (455, 42, 35, 'YUAN520', 1, 1, 50, 910, 960, 'agent_commission', 159, 4, '上中评评论', '下级用户 123456yjx是普通团长 完成任务，获得普通团长佣金，任务ID：159', '2026-03-17 20:05:01');
INSERT INTO `wallets_log` VALUES (456, 28, 22, 'SGYMQ', 1, 1, 240, 6000, 6240, 'second_agent_commission', 159, 4, '上中评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：159', '2026-03-17 20:05:01');
INSERT INTO `wallets_log` VALUES (457, 70, 63, '123456yjx', 1, 1, 100, 560, 660, 'commission', 155, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：155', '2026-03-17 20:06:02');
INSERT INTO `wallets_log` VALUES (458, 42, 35, 'YUAN520', 1, 1, 50, 960, 1010, 'agent_commission', 155, 1, '上评评论', '下级用户 123456yjx是普通团长 完成任务，获得普通团长佣金，任务ID：155', '2026-03-17 20:06:02');
INSERT INTO `wallets_log` VALUES (459, 28, 22, 'SGYMQ', 1, 1, 240, 6240, 6480, 'second_agent_commission', 155, 1, '上评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：155', '2026-03-17 20:06:02');
INSERT INTO `wallets_log` VALUES (460, 23, 18, 'xiaoya', 1, 1, 80, 0, 80, 'commission', 151, 2, '中评评论', '完成任务获得佣金，任务ID：151', '2026-03-17 20:13:08');
INSERT INTO `wallets_log` VALUES (461, 8, 5, 'test', 1, 1, 30, 0, 30, 'agent_commission', 151, 2, '中评评论', '下级用户 xiaoya 完成任务，获得一级团长佣金，任务ID：151', '2026-03-17 20:13:08');
INSERT INTO `wallets_log` VALUES (462, 34, 27, 'mjj20100316', 1, 1, 130, 0, 130, 'commission', 167, 5, '中下评评论', '自动审核通过任务获得佣金，任务ID：167', '2026-03-17 20:56:02');
INSERT INTO `wallets_log` VALUES (463, 28, 22, 'SGYMQ', 1, 1, 240, 6480, 6720, 'agent_commission', 167, 5, '中下评评论', '下级用户 mjj20100316是大团团长 完成任务，获得一级团长佣金，任务ID：167', '2026-03-17 20:56:02');
INSERT INTO `wallets_log` VALUES (464, 8, 5, 'test', 1, 1, 45, 30, 75, 'second_agent_commission', 167, 5, '中下评评论', '下级用户 SGYMQ 的团队成员完成任务，获得二级团长佣金，任务ID：167', '2026-03-17 20:56:02');
INSERT INTO `wallets_log` VALUES (465, 31, 25, 'na0430', 1, 1, 100, 0, 100, 'commission', 165, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：165', '2026-03-17 20:58:01');
INSERT INTO `wallets_log` VALUES (466, 28, 22, 'SGYMQ', 1, 1, 240, 6720, 6960, 'agent_commission', 165, 1, '上评评论', '下级用户 na0430是大团团长 完成任务，获得一级团长佣金，任务ID：165', '2026-03-17 20:58:01');
INSERT INTO `wallets_log` VALUES (467, 8, 5, 'test', 1, 1, 50, 75, 125, 'second_agent_commission', 165, 1, '上评评论', '下级用户 SGYMQ 的团队成员完成任务，获得二级团长佣金，任务ID：165', '2026-03-17 20:58:01');
INSERT INTO `wallets_log` VALUES (468, 70, 63, '123456yjx', 1, 1, 100, 660, 760, 'commission', 157, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：157', '2026-03-17 21:02:01');
INSERT INTO `wallets_log` VALUES (469, 42, 35, 'YUAN520', 1, 1, 50, 1010, 1060, 'agent_commission', 157, 1, '上评评论', '下级用户 123456yjx是普通团长 完成任务，获得普通团长佣金，任务ID：157', '2026-03-17 21:02:01');
INSERT INTO `wallets_log` VALUES (470, 28, 22, 'SGYMQ', 1, 1, 240, 6960, 7200, 'second_agent_commission', 157, 1, '上评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：157', '2026-03-17 21:02:01');
INSERT INTO `wallets_log` VALUES (471, 70, 63, '123456yjx', 1, 1, 100, 760, 860, 'commission', 148, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：148', '2026-03-17 21:03:01');
INSERT INTO `wallets_log` VALUES (472, 42, 35, 'YUAN520', 1, 1, 50, 1060, 1110, 'agent_commission', 148, 1, '上评评论', '下级用户 123456yjx是普通团长 完成任务，获得普通团长佣金，任务ID：148', '2026-03-17 21:03:01');
INSERT INTO `wallets_log` VALUES (473, 28, 22, 'SGYMQ', 1, 1, 240, 7200, 7440, 'second_agent_commission', 148, 1, '上评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：148', '2026-03-17 21:03:01');
INSERT INTO `wallets_log` VALUES (474, 70, 63, '123456yjx', 1, 1, 100, 860, 960, 'commission', 161, 4, '上中评评论', '自动审核通过任务获得佣金，任务ID：161', '2026-03-17 21:05:02');
INSERT INTO `wallets_log` VALUES (475, 42, 35, 'YUAN520', 1, 1, 50, 1110, 1160, 'agent_commission', 161, 4, '上中评评论', '下级用户 123456yjx是普通团长 完成任务，获得普通团长佣金，任务ID：161', '2026-03-17 21:05:02');
INSERT INTO `wallets_log` VALUES (476, 28, 22, 'SGYMQ', 1, 1, 240, 7440, 7680, 'second_agent_commission', 161, 4, '上中评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：161', '2026-03-17 21:05:02');
INSERT INTO `wallets_log` VALUES (477, 34, 27, 'mjj20100316', 1, 1, 80, 130, 210, 'commission', 160, 4, '上中评评论', '自动审核通过任务获得佣金，任务ID：160', '2026-03-17 21:15:02');
INSERT INTO `wallets_log` VALUES (478, 28, 22, 'SGYMQ', 1, 1, 160, 7680, 7840, 'agent_commission', 160, 4, '上中评评论', '下级用户 mjj20100316是大团团长 完成任务，获得一级团长佣金，任务ID：160', '2026-03-17 21:15:02');
INSERT INTO `wallets_log` VALUES (479, 8, 5, 'test', 1, 1, 30, 125, 155, 'second_agent_commission', 160, 4, '上中评评论', '下级用户 SGYMQ 的团队成员完成任务，获得二级团长佣金，任务ID：160', '2026-03-17 21:15:02');
INSERT INTO `wallets_log` VALUES (480, 28, 22, 'SGYMQ', 1, 1, 240, 7840, 8080, 'commission', 149, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：149', '2026-03-17 21:23:02');
INSERT INTO `wallets_log` VALUES (481, 8, 5, 'test', 1, 1, 50, 155, 205, 'agent_commission', 149, 1, '上评评论', '下级用户 SGYMQ是高级团长 完成任务，获得高级团长佣金，任务ID：149', '2026-03-17 21:23:02');
INSERT INTO `wallets_log` VALUES (482, 28, 22, 'SGYMQ', 1, 1, 240, 8080, 8320, 'commission', 150, 1, '上评评论', '完成任务获得佣金，任务ID：150', '2026-03-17 21:24:09');
INSERT INTO `wallets_log` VALUES (483, 8, 5, 'test', 1, 1, 50, 205, 255, 'agent_commission', 150, 1, '上评评论', '下级用户 SGYMQ 完成任务，获得一级团长佣金，任务ID：150', '2026-03-17 21:24:09');
INSERT INTO `wallets_log` VALUES (484, 1, 1, 'Ceshi', 2, 1, 200, 41400, 41600, 'refund', 139, 0, '', '任务过期退款【中评评论】，未完成 1 个任务，退款 ¥2.00', '2026-03-17 21:40:01');
INSERT INTO `wallets_log` VALUES (485, 1, 1, 'Ceshi', 2, 2, 300, 41600, 41300, 'task', 169, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-17 22:08:06');
INSERT INTO `wallets_log` VALUES (486, 2, 2, 'Ceshi1', 2, 2, 900, 45500, 44600, 'task', 170, 4, '上中评评论', '发布任务【上中评评论】4个任务，扣除 ¥9.00', '2026-03-17 22:25:56');
INSERT INTO `wallets_log` VALUES (487, 28, 22, 'SGYMQ', 1, 1, 240, 8320, 8560, 'commission', 170, 4, '上中评评论', '完成任务获得佣金，任务ID：170', '2026-03-17 22:29:29');
INSERT INTO `wallets_log` VALUES (488, 8, 5, 'test', 1, 1, 50, 255, 305, 'agent_commission', 170, 4, '上中评评论', '下级用户 SGYMQ 完成任务，获得一级团长佣金，任务ID：170', '2026-03-17 22:29:29');
INSERT INTO `wallets_log` VALUES (489, 60, 53, 'jjyhhhxsw', 1, 1, 100, 0, 100, 'commission', 169, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：169', '2026-03-17 23:08:01');
INSERT INTO `wallets_log` VALUES (490, 42, 35, 'YUAN520', 1, 1, 50, 1160, 1210, 'agent_commission', 169, 1, '上评评论', '下级用户 jjyhhhxsw是普通团长 完成任务，获得普通团长佣金，任务ID：169', '2026-03-17 23:08:01');
INSERT INTO `wallets_log` VALUES (491, 28, 22, 'SGYMQ', 1, 1, 240, 8560, 8800, 'second_agent_commission', 169, 1, '上评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：169', '2026-03-17 23:08:01');
INSERT INTO `wallets_log` VALUES (492, 60, 53, 'jjyhhhxsw', 1, 1, 130, 100, 230, 'commission', 164, 5, '中下评评论', '自动审核通过任务获得佣金，任务ID：164', '2026-03-17 23:16:01');
INSERT INTO `wallets_log` VALUES (493, 42, 35, 'YUAN520', 1, 1, 45, 1210, 1255, 'agent_commission', 164, 5, '中下评评论', '下级用户 jjyhhhxsw是普通团长 完成任务，获得普通团长佣金，任务ID：164', '2026-03-17 23:16:01');
INSERT INTO `wallets_log` VALUES (494, 28, 22, 'SGYMQ', 1, 1, 240, 8800, 9040, 'second_agent_commission', 164, 5, '中下评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：164', '2026-03-17 23:16:01');
INSERT INTO `wallets_log` VALUES (495, 60, 53, 'jjyhhhxsw', 1, 1, 80, 230, 310, 'commission', 168, 2, '中评评论', '自动审核通过任务获得佣金，任务ID：168', '2026-03-17 23:22:01');
INSERT INTO `wallets_log` VALUES (496, 42, 35, 'YUAN520', 1, 1, 30, 1255, 1285, 'agent_commission', 168, 2, '中评评论', '下级用户 jjyhhhxsw是普通团长 完成任务，获得普通团长佣金，任务ID：168', '2026-03-17 23:22:01');
INSERT INTO `wallets_log` VALUES (497, 28, 22, 'SGYMQ', 1, 1, 160, 9040, 9200, 'second_agent_commission', 168, 2, '中评评论', '下级用户 YUAN520 的团队成员完成任务，获得二级团长佣金，任务ID：168', '2026-03-17 23:22:01');
INSERT INTO `wallets_log` VALUES (498, 80, 72, 'zhang', 1, 1, 80, 0, 80, 'commission', 171, 4, '上中评评论', '自动审核通过任务获得佣金，任务ID：171', '2026-03-17 23:53:01');
INSERT INTO `wallets_log` VALUES (499, 32, 26, '1158799864', 1, 1, 30, 260, 290, 'agent_commission', 171, 4, '上中评评论', '下级用户 zhang是普通团长 完成任务，获得普通团长佣金，任务ID：171', '2026-03-17 23:53:01');
INSERT INTO `wallets_log` VALUES (500, 28, 22, 'SGYMQ', 1, 1, 160, 9200, 9360, 'second_agent_commission', 171, 4, '上中评评论', '下级用户 1158799864 的团队成员完成任务，获得二级团长佣金，任务ID：171', '2026-03-17 23:53:01');
INSERT INTO `wallets_log` VALUES (501, 80, 72, 'zhang', 1, 1, 80, 80, 160, 'commission', 153, 2, '中评评论', '自动审核通过任务获得佣金，任务ID：153', '2026-03-17 23:58:02');
INSERT INTO `wallets_log` VALUES (502, 32, 26, '1158799864', 1, 1, 30, 290, 320, 'agent_commission', 153, 2, '中评评论', '下级用户 zhang是普通团长 完成任务，获得普通团长佣金，任务ID：153', '2026-03-17 23:58:02');
INSERT INTO `wallets_log` VALUES (503, 28, 22, 'SGYMQ', 1, 1, 160, 9360, 9520, 'second_agent_commission', 153, 2, '中评评论', '下级用户 1158799864 的团队成员完成任务，获得二级团长佣金，任务ID：153', '2026-03-17 23:58:02');
INSERT INTO `wallets_log` VALUES (504, 1, 1, 'Ceshi', 2, 1, 200, 41300, 41500, 'refund', 151, 0, '', '任务过期退款【中评评论】，未完成 1 个任务，退款 ¥2.00', '2026-03-18 14:07:01');
INSERT INTO `wallets_log` VALUES (505, 1, 1, 'Ceshi', 2, 1, 400, 41500, 41900, 'refund', 152, 0, '', '任务过期退款【中评评论】，未完成 2 个任务，退款 ¥4.00', '2026-03-18 14:07:01');
INSERT INTO `wallets_log` VALUES (506, 2, 2, 'Ceshi1', 2, 1, 600, 44600, 45200, 'refund', 156, 0, '', '任务过期退款【中评评论】，未完成 3 个任务，退款 ¥6.00', '2026-03-18 14:07:01');
INSERT INTO `wallets_log` VALUES (507, 2, 2, 'Ceshi1', 2, 1, 600, 45200, 45800, 'refund', 158, 0, '', '任务过期退款【中评评论】，未完成 3 个任务，退款 ¥6.00', '2026-03-18 14:07:01');
INSERT INTO `wallets_log` VALUES (508, 2, 2, 'Ceshi1', 2, 1, 600, 45800, 46400, 'refund', 162, 0, '', '任务过期退款【上中评评论】，未完成 3 个任务，退款 ¥6.00', '2026-03-18 14:07:01');
INSERT INTO `wallets_log` VALUES (509, 2, 2, 'Ceshi1', 2, 1, 400, 46400, 46800, 'refund', 168, 0, '', '任务过期退款【中评评论】，未完成 2 个任务，退款 ¥4.00', '2026-03-18 14:07:01');
INSERT INTO `wallets_log` VALUES (510, 2, 2, 'Ceshi1', 2, 1, 400, 46800, 47200, 'refund', 171, 0, '', '任务过期退款【上中评评论】，未完成 2 个任务，退款 ¥4.00', '2026-03-18 14:07:01');

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '提现申请表-需要管理员审核' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of withdraw_requests
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
