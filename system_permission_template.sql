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

 Date: 14/03/2026 00:42:47
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

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
INSERT INTO `system_permission_template` VALUES (4, '系统用户', 'system-users', '系统用户管理', NULL, 'ri-admin-line', 'system-users', 4, 1, '2026-03-06 16:44:05', '2026-03-14 00:41:23', 1, 'system-usersSection');
INSERT INTO `system_permission_template` VALUES (5, '角色管理', 'system-roles', '角色权限管理', NULL, 'ri-shield-keyhole-line', 'system-roles', 5, 1, '2026-03-06 16:44:05', '2026-03-14 00:41:30', 1, 'system-rolesSection');
INSERT INTO `system_permission_template` VALUES (6, '权限管理', 'system-permissions', '权限模板管理', NULL, 'ri-lock-line', 'system-permissions', 6, 1, '2026-03-06 16:44:05', '2026-03-14 00:41:36', 1, 'system-permissionsSection');
INSERT INTO `system_permission_template` VALUES (7, '任务模板', 'templates', '任务模板管理', NULL, 'ri-file-list-3-line', 'templates', 7, 1, '2026-03-06 16:44:05', '2026-03-14 00:38:31', 1, 'templatesSection');
INSERT INTO `system_permission_template` VALUES (8, '任务市场', 'market', '任务市场监控', NULL, 'ri-store-2-line', 'market', 8, 1, '2026-03-06 16:44:05', '2026-03-14 00:38:34', 1, 'marketSection');
INSERT INTO `system_permission_template` VALUES (9, '任务审核', 'task-review', '任务审核管理', NULL, 'ri-check-double-line', 'task-review', 9, 1, '2026-03-06 16:44:05', '2026-03-14 00:40:22', 1, 'task-reviewSection');
INSERT INTO `system_permission_template` VALUES (10, '放大镜任务', 'magnifier', '放大镜任务管理', NULL, 'ri-search-line', 'magnifier', 10, 1, '2026-03-06 16:44:05', '2026-03-14 00:41:45', 1, 'magnifierSection');
INSERT INTO `system_permission_template` VALUES (11, '钱包记录', 'wallet-logs', '钱包资金记录', NULL, 'ri-wallet-3-line', 'wallet-logs', 11, 1, '2026-03-06 16:44:05', '2026-03-14 00:40:07', 1, 'wallet-logsSection');
INSERT INTO `system_permission_template` VALUES (12, '充值审核', 'recharge', '充值审核管理', NULL, 'ri-money-dollar-circle-line', 'recharge', 12, 1, '2026-03-06 16:44:05', '2026-03-14 00:41:54', 1, 'rechargeSection');
INSERT INTO `system_permission_template` VALUES (13, '提现审核', 'withdraw', '提现审核管理', NULL, 'ri-hand-coin-line', 'withdraw', 13, 1, '2026-03-06 16:44:05', '2026-03-14 00:41:59', 1, 'withdrawSection');
INSERT INTO `system_permission_template` VALUES (14, '团长审核', 'agent', '团长申请审核', NULL, 'ri-vip-crown-line', 'agent', 14, 1, '2026-03-06 16:44:05', '2026-03-14 00:38:48', 1, 'agentSection');
INSERT INTO `system_permission_template` VALUES (15, '租赁处理', 'rental-orders', '租赁订单处理', NULL, 'ri-home-smile-2-line', 'rental-orders', 15, 1, '2026-03-06 16:44:05', '2026-03-14 00:39:02', 1, 'rental-ordersSection');
INSERT INTO `system_permission_template` VALUES (16, '工单管理', 'rental-tickets', '租赁工单管理', NULL, 'ri-customer-service-2-line', 'rental-tickets', 16, 1, '2026-03-06 16:44:05', '2026-03-14 00:39:09', 1, 'rental-ticketsSection');
INSERT INTO `system_permission_template` VALUES (17, '网站配置', 'system-config', '网站系统配置', NULL, 'ri-settings-4-line', 'system-config', 17, 1, '2026-03-06 16:44:05', '2026-03-14 00:39:15', 1, 'system-configSection');
INSERT INTO `system_permission_template` VALUES (18, '系统通知', 'notifications', '系统通知管理', NULL, 'ri-notification-3-line', 'notifications', 18, 1, '2026-03-06 16:44:05', '2026-03-14 00:40:29', 1, 'notificationsSection');
INSERT INTO `system_permission_template` VALUES (19, '团长迁跃升级', 'agent-upgrade', 'C端用户代理等级跃迁管理', NULL, 'ri-arrow-up-circle-line', 'agent', 22, 1, '2026-03-08 14:01:49', '2026-03-14 00:36:42', 1, 'agentUpgradeSection');
INSERT INTO `system_permission_template` VALUES (20, '提示通知列表', 'notification-logs', '系统通知检测日志', NULL, 'ri-file-list-line', 'notification-logs', 19, 1, '2026-03-08 14:01:49', '2026-03-14 00:40:43', 1, 'notification-logsSection');
INSERT INTO `system_permission_template` VALUES (21, '登录设备配置', 'login-devices-config', '用户登录设备数量配置', NULL, 'ri-lock-unlock-line', 'login-devices-config', 20, 1, '2026-03-10 12:55:46', '2026-03-14 00:39:26', 1, 'login-devices-configSection');
INSERT INTO `system_permission_template` VALUES (22, 'B端用户交易流水', 'b-statistics', 'B端用户交易流水管理', NULL, 'ri-wallet-2-line', 'b-statistics', 12, 1, '2026-03-10 12:00:00', '2026-03-14 00:42:19', 1, 'b-statisticsSection');
INSERT INTO `system_permission_template` VALUES (23, 'C端用户交易流水', 'c-statistics', 'C端用户交易流水管理', NULL, 'ri-wallet-2-line', 'c-statistics', 21, 1, '2026-03-13 19:01:24', '2026-03-14 00:42:25', 1, 'c-statisticsSection');
INSERT INTO `system_permission_template` VALUES (30, '用户交易流水', 'b-statistics-flows', 'B端用户交易流水记录', 22, 'ri-list-check', 'b-statistics-flows', 1, 1, '2026-03-13 17:36:18', '2026-03-13 22:48:53', 2, 'b-statisticsSection');
INSERT INTO `system_permission_template` VALUES (31, '数据统计', 'b-statistics-summary', 'B端用户交易数据统计', 22, 'ri-bar-chart-line', 'b-statistics-summary', 2, 1, '2026-03-13 17:36:18', '2026-03-13 22:48:55', 2, 'b-statisticsSection');
INSERT INTO `system_permission_template` VALUES (32, 'C端交易流水', 'c-statistics-flows', 'C端用户交易流水记录', 23, 'ri-list-check', 'c-statistics-flows', 1, 1, '2026-03-13 19:05:00', '2026-03-13 22:48:57', 2, 'c-statisticsSection');
INSERT INTO `system_permission_template` VALUES (33, 'C端数据统计', 'c-statistics-summary', 'C端数据统计管理', 23, 'ri-wallet-2-line', 'c-statistics-summary', 2, 1, '2026-03-13 19:05:56', '2026-03-13 22:49:00', 2, 'c-statisticsSection');

SET FOREIGN_KEY_CHECKS = 1;
