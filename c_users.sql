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

 Date: 17/03/2026 08:53:44
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

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
INSERT INTO `c_users` VALUES (1, 'taskadmin', 'taskadmin@qq.com', NULL, '$2y$10$9gww7TqOTzSA9SqchkFEgeYftRKlJ4ciYWL6IiD8DPUbQv8/PnCGe', 'W6XMFJ', NULL, NULL, 3, 'eyJ1c2VyX2lkIjoxLCJ0eXBlIjoxLCJleHAiOjE3NzI3NzM1OTN9', '2026-03-06 13:06:33', 3, 1, NULL, '120.237.23.202', '2026-02-27 13:06:22', '2026-03-14 01:09:33', 1, '2026-03-14 01:09:33', 1, '2026-03-14 02:09:33', NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (2, 'Ceshi', '12345678@qq.com', '13112345678', '$2y$10$hkD.XBnEsk7iKbrYdpuxyOmrn.vME26Z1gzkXkBEXaUQMey5b3MAm', '6YHUBA', NULL, NULL, 3, 'eyJ1c2VyX2lkIjoyLCJ0eXBlIjoxLCJleHAiOjE3NzQxOTYyNjN9', '2026-03-23 00:17:43', 4, 1, NULL, '34.143.229.197', '2026-02-27 17:24:33', '2026-03-16 00:17:43', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-16 00:17:43\",\"last_activity\":\"2026-03-16 00:17:43\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-16 00:17:43\",\"last_activity\":\"2026-03-16 00:17:43\"}]');
INSERT INTO `c_users` VALUES (3, 'Ceshi2', '123456789@qq.com', '13212345678', '$2y$10$Cvl7CIY5Oj2gPcKSvNE2mONLRs14Rr1ndstVn2FHJlco8GmXxS586', 'MCVFM9', NULL, NULL, 0, 'eyJ1c2VyX2lkIjozLCJ0eXBlIjoxLCJleHAiOjE3NzI3OTMxODh9', '2026-03-06 18:33:08', 5, 1, NULL, '34.143.229.197', '2026-02-27 17:26:28', '2026-02-27 18:33:08', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (4, 'Ceshi3', '123455677@qq.com', '13312345678', '$2y$10$qydW3B1EXlxJou5CUfPMaOvssOD/K8GugvQh.BeeX/KGBpPGC3awq', 'CZBBF5', NULL, NULL, 0, 'eyJ1c2VyX2lkIjo0LCJ0eXBlIjoxLCJleHAiOjE3NzI3ODk0Njh9', '2026-03-06 17:31:08', 6, 1, NULL, '34.143.229.197', '2026-02-27 17:31:08', '2026-02-27 17:31:08', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (5, 'test', 'test@qq.com', '15900000011', '$2y$10$hkD.XBnEsk7iKbrYdpuxyOmrn.vME26Z1gzkXkBEXaUQMey5b3MAm', 'TX5ECJ', NULL, NULL, 3, 'eyJ1c2VyX2lkIjo1LCJ0eXBlIjoxLCJleHAiOjE3NzQyMzE0ODB9', '2026-03-23 10:04:40', 8, 1, NULL, '223.74.60.135', '2026-03-01 00:53:23', '2026-03-16 10:04:40', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-16 10:04:40\",\"last_activity\":\"2026-03-16 10:04:40\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-16 10:04:40\",\"last_activity\":\"2026-03-16 10:04:40\"}]');
INSERT INTO `c_users` VALUES (6, 'tasktest', '', '13794719208', '$2y$10$B7twShdr0plATEq85mgnn.5qiIX7mxnWcMP4OX02L9La01U3PoUCi', 'Z2AYEM', 1, NULL, 3, 'eyJ1c2VyX2lkIjo2LCJ0eXBlIjoxLCJleHAiOjE3NzI5ODY0OTh9', '2026-03-09 00:14:58', 9, 1, NULL, '223.74.60.135', '2026-03-02 00:12:06', '2026-03-12 10:14:39', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (18, 'xiaoya', NULL, '13049610316', '$2y$10$s1KchbOeEqAqEGP1DjV15O4ZLf5yOKvNAE0.yphtXxvtwNo0Z6upG', 'KZPAUU', 5, NULL, 0, 'eyJ1c2VyX2lkIjoxOCwidHlwZSI6MSwiZXhwIjoxNzczODI5NjA0fQ==', '2026-03-18 18:26:44', 23, 1, NULL, '223.74.60.185', '2026-03-11 12:23:27', '2026-03-11 18:26:44', 0, NULL, NULL, NULL, 'e35dcb4f242a10445c9e5218ab3e8956', 'iPhone', 1, '{\"device_id\":\"e35dcb4f242a10445c9e5218ab3e8956\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-11 18:26:44\",\"last_activity\":\"2026-03-11 18:26:44\"}', '[{\"device_id\":\"e35dcb4f242a10445c9e5218ab3e8956\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-11 18:26:44\",\"last_activity\":\"2026-03-11 18:26:44\"}]');
INSERT INTO `c_users` VALUES (19, 'test1', 'test1@example.com', '13800138001', '$2y$12$BcNzzO08Ioin60d4mXd4UeY7V8bahMDqUYhkHuFHCR3vh690fXKhu', 'Z2GJ43', 5, NULL, 1, 'eyJ1c2VyX2lkIjoxOSwidHlwZSI6MSwiZXhwIjoxNzczOTA2MjkyfQ==', '2026-03-19 15:44:52', 24, 1, NULL, '::1', '2026-03-12 10:23:37', '2026-03-12 15:44:52', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:44:52\",\"last_activity\":\"2026-03-12 15:44:52\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:44:52\",\"last_activity\":\"2026-03-12 15:44:52\"}]');
INSERT INTO `c_users` VALUES (20, 'test2', 'test2@example.com', '13800138002', '$2y$12$zgG9QJ4V5vLg9NJ0n8Wc2uj7Uoo1dh3q33mBwRf/xm.q0ovFfrPcu', '4Q5A5X', 5, NULL, 2, 'eyJ1c2VyX2lkIjoyMCwidHlwZSI6MSwiZXhwIjoxNzc0MjcxODk5fQ==', '2026-03-23 21:18:19', 25, 1, NULL, '::1', '2026-03-12 10:23:57', '2026-03-16 21:18:19', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-16 21:18:19\",\"last_activity\":\"2026-03-16 21:18:19\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-16 21:18:19\",\"last_activity\":\"2026-03-16 21:18:19\"}]');
INSERT INTO `c_users` VALUES (21, 'test3', 'test3@example.com', '13800138003', '$2y$12$8z7vXjSjouSHHcO33xpoX..Px3DQVrcNAixczIfbfXhy.1mo0r5yW', 'RHA6SE', 5, NULL, 0, 'eyJ1c2VyX2lkIjoyMSwidHlwZSI6MSwiZXhwIjoxNzczOTA2MzM5fQ==', '2026-03-19 15:45:39', 26, 1, NULL, '::1', '2026-03-12 10:24:12', '2026-03-12 15:45:39', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:45:39\",\"last_activity\":\"2026-03-12 15:45:39\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:45:39\",\"last_activity\":\"2026-03-12 15:45:39\"}]');
INSERT INTO `c_users` VALUES (22, 'test4', 'test4@example.com', '13800138004', '$2y$12$nyojdrP1YvXOE7Zkrva3.Os8fn0goB671mqPJmODF8piW8aRqGinm', '2A5VU3', 5, NULL, 0, 'eyJ1c2VyX2lkIjoyMiwidHlwZSI6MSwiZXhwIjoxNzczOTA2MzUzfQ==', '2026-03-19 15:45:53', 27, 1, NULL, '::1', '2026-03-12 10:24:22', '2026-03-12 15:45:53', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:45:53\",\"last_activity\":\"2026-03-12 15:45:53\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:45:53\",\"last_activity\":\"2026-03-12 15:45:53\"}]');
INSERT INTO `c_users` VALUES (23, 'test5', 'test5@example.com', '13800138005', '$2y$12$n.eutQbVaWv91iQeFltN2ueUb9Ff.Fzw1dwk/h2pyKfbgh/itcHcO', 'F4NGGC', 18, NULL, 0, 'eyJ1c2VyX2lkIjoyMywidHlwZSI6MSwiZXhwIjoxNzczOTA2MzgxfQ==', '2026-03-19 15:46:21', 28, 1, NULL, '::1', '2026-03-12 10:24:47', '2026-03-12 15:46:21', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:46:21\",\"last_activity\":\"2026-03-12 15:46:21\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:46:21\",\"last_activity\":\"2026-03-12 15:46:21\"}]');
INSERT INTO `c_users` VALUES (24, 'test6', 'test6@example.com', '13800138006', '$2y$12$huLJYXF6k4LW9fCO0FC2meaOkLsNE24UJDSclYEv/Y8d9RiUWYuW.', 'N369ZM', 18, NULL, 0, 'eyJ1c2VyX2lkIjoyNCwidHlwZSI6MSwiZXhwIjoxNzczOTA2NDQ0fQ==', '2026-03-19 15:47:24', 29, 1, NULL, '::1', '2026-03-12 10:24:57', '2026-03-12 15:47:24', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:47:24\",\"last_activity\":\"2026-03-12 15:47:24\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:47:24\",\"last_activity\":\"2026-03-12 15:47:24\"}]');
INSERT INTO `c_users` VALUES (25, 'test7', 'test7@example.com', '13800138007', '$2y$12$/7d7wzdvWDXCDp1jEdYA7e5.PKI.WGYsYdK2YJhNqyk7/OjQ9UH6y', '2KV5T3', 19, NULL, 0, 'eyJ1c2VyX2lkIjoyNSwidHlwZSI6MSwiZXhwIjoxNzczOTA2NDY0fQ==', '2026-03-19 15:47:44', 30, 1, NULL, '::1', '2026-03-12 11:27:35', '2026-03-12 15:47:44', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:47:44\",\"last_activity\":\"2026-03-12 15:47:44\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:47:44\",\"last_activity\":\"2026-03-12 15:47:44\"}]');
INSERT INTO `c_users` VALUES (26, 'test8', 'test8@example.com', '13800138008', '$2y$12$TDV0yL1wMv72SmF9MPUMwuaVhcOIz3TFcKYiRURK6n2lXuZ.ARTz2', 'F256G7', 20, NULL, 1, 'eyJ1c2VyX2lkIjoyNiwidHlwZSI6MSwiZXhwIjoxNzc0MjM3MDUwfQ==', '2026-03-23 11:37:30', 31, 1, NULL, '::1', '2026-03-12 11:27:56', '2026-03-16 11:37:30', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-16 11:37:30\",\"last_activity\":\"2026-03-16 11:37:30\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-16 11:37:30\",\"last_activity\":\"2026-03-16 11:37:30\"}]');
INSERT INTO `c_users` VALUES (27, 'test9', 'test9@example.com', '13800138009', '$2y$12$bh6PAgcrXwmNXRk38eFG8.upZkPqMjtWdNVWvagfrXSN0.R7wxAp2', 'ZNFZBV', 26, NULL, 0, 'eyJ1c2VyX2lkIjoyNywidHlwZSI6MSwiZXhwIjoxNzczOTA2NTAyfQ==', '2026-03-19 15:48:22', 32, 1, NULL, '::1', '2026-03-12 14:31:10', '2026-03-12 15:48:22', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:48:22\",\"last_activity\":\"2026-03-12 15:48:22\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-12 15:48:22\",\"last_activity\":\"2026-03-12 15:48:22\"}]');

SET FOREIGN_KEY_CHECKS = 1;
