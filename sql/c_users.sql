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

 Date: 18/03/2026 17:10:35
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
) ENGINE = InnoDB AUTO_INCREMENT = 127 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端用户表-消费者端' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of c_users
-- ----------------------------
INSERT INTO `c_users` VALUES (111, 'test', 'test@example.com', '13800138000', '$2y$12$DFyU5213olotZCSKYb0LNe5hxhgaFZRk5GqwSE1.Kru/4bcDsKx0O', '4UJXKG', NULL, NULL, 3, 'eyJ1c2VyX2lkIjoxMTEsInR5cGUiOjEsImV4cCI6MTc3NDQyOTU5NH0=', '2026-03-25 17:06:34', 33, 1, NULL, '::1', '2026-03-18 12:09:37', '2026-03-18 17:06:34', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-18 17:06:34\",\"last_activity\":\"2026-03-18 17:06:34\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-18 17:06:34\",\"last_activity\":\"2026-03-18 17:06:34\"}]');
INSERT INTO `c_users` VALUES (112, 'ces1', 'ces1@example.com', '13800138001', '$2y$12$xa0gKHSPdmYDstMmuNJkB.zt7ZCp9pw6ZKvlakpKq4lUFiocqvomi', 'NK5BNB', 111, NULL, 0, 'eyJ1c2VyX2lkIjoxMTIsInR5cGUiOjEsImV4cCI6MTc3NDQyOTU0OH0=', '2026-03-25 17:05:48', 34, 1, NULL, '::1', '2026-03-18 12:10:57', '2026-03-18 17:05:48', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-18 17:05:48\",\"last_activity\":\"2026-03-18 17:05:48\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-18 17:05:48\",\"last_activity\":\"2026-03-18 17:05:48\"}]');
INSERT INTO `c_users` VALUES (113, 'ces2', 'ces2@example.com', '13800138002', '$2y$12$bJBWoxb0swahT3Bn.kJJu.a/8tumpqWFgKqxwrOfDlqqH0F3Oa6cG', 'P6JQF5', 112, NULL, 0, 'eyJ1c2VyX2lkIjoxMTMsInR5cGUiOjEsImV4cCI6MTc3NDQyOTU3OH0=', '2026-03-25 17:06:18', 35, 1, NULL, '::1', '2026-03-18 12:14:08', '2026-03-18 17:06:18', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-18 17:06:18\",\"last_activity\":\"2026-03-18 17:06:18\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-18 17:06:18\",\"last_activity\":\"2026-03-18 17:06:18\"}]');
INSERT INTO `c_users` VALUES (114, 'ces3', 'ces3@example.com', '13800138003', '$2y$12$BpwWPv5dNcHp1a7p34P9oeJaKWfgCMXttYc5rQYLLSuz21rwp6k3G', 'MY545E', 112, NULL, 0, 'eyJ1c2VyX2lkIjoxMTQsInR5cGUiOjEsImV4cCI6MTc3NDQxMjE0MX0=', '2026-03-25 12:15:41', 36, 1, NULL, '::1', '2026-03-18 12:15:41', '2026-03-18 12:15:41', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (115, 'ces4', 'ces4@example.com', '13800138004', '$2y$12$2CvZ5xCLGE0j.0nS0kCDVOI6TPS.OKc3NYUsMsX0UGXGhxxmzELD.', 'DRB7PR', 111, NULL, 0, 'eyJ1c2VyX2lkIjoxMTUsInR5cGUiOjEsImV4cCI6MTc3NDQxMjE2M30=', '2026-03-25 12:16:03', 37, 1, NULL, '::1', '2026-03-18 12:16:03', '2026-03-18 12:16:03', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (116, 'ces5', 'ces5@example.com', '13800138005', '$2y$12$3/sRKXH2s8r9Xy821ZMNCuspQq2v/1L4g9gVAvX.5m5Ndgj.RtEH.', '59K96R', 111, NULL, 0, 'eyJ1c2VyX2lkIjoxMTYsInR5cGUiOjEsImV4cCI6MTc3NDQxMjE3Mn0=', '2026-03-25 12:16:12', 38, 1, NULL, '::1', '2026-03-18 12:16:12', '2026-03-18 12:16:12', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (117, 'ces6', 'ces6@example.com', '13800138006', '$2y$12$dS4ZMcTazlVpKLYBZPDu2uwu3wayCZH/Za4iBrszBqtmQ6Clpu9OO', 'DJ4KS7', 113, NULL, 0, 'eyJ1c2VyX2lkIjoxMTcsInR5cGUiOjEsImV4cCI6MTc3NDQyNjAyMH0=', '2026-03-25 16:07:00', 39, 1, NULL, '::1', '2026-03-18 12:16:40', '2026-03-18 16:07:00', 0, NULL, NULL, NULL, '123213213', 'windows', 1, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-18 16:07:00\",\"last_activity\":\"2026-03-18 16:07:00\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-18 16:07:00\",\"last_activity\":\"2026-03-18 16:07:00\"}]');
INSERT INTO `c_users` VALUES (118, 'ces7', 'ces7@example.com', '13800138007', '$2y$12$Gsy8ZRXbtUx7o.3QNHoABOufqh4dk/zWjBLfpIRNnGeT.0x.OK/kO', 'F4D5ZA', 113, NULL, 0, 'eyJ1c2VyX2lkIjoxMTgsInR5cGUiOjEsImV4cCI6MTc3NDQxMjIyOX0=', '2026-03-25 12:17:09', 40, 1, NULL, '::1', '2026-03-18 12:17:09', '2026-03-18 12:17:09', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (119, 'ces8', 'ces8@example.com', '13800138008', '$2y$12$r6I6lUeAadjQNDRen1xgyuY/EkgISpam4tJ2yKc8IRMTnorpA5UFO', '944UPZ', 114, NULL, 0, 'eyJ1c2VyX2lkIjoxMTksInR5cGUiOjEsImV4cCI6MTc3NDQxMjI3NX0=', '2026-03-25 12:17:55', 41, 1, NULL, '::1', '2026-03-18 12:17:55', '2026-03-18 12:17:55', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (120, 'ces9', 'ces9@example.com', '13800138009', '$2y$12$WALPWrj75PVC1l8kLMZ/V.y7DCLkdtUX0IGvY.1RMuGyiLoEPPluq', '7NJTHV', 114, NULL, 0, 'eyJ1c2VyX2lkIjoxMjAsInR5cGUiOjEsImV4cCI6MTc3NDQxMjI4M30=', '2026-03-25 12:18:03', 42, 1, NULL, '::1', '2026-03-18 12:18:03', '2026-03-18 12:18:03', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (121, 'ces10', 'ces10@example.com', '13800138010', '$2y$12$nv.mhZEpzDCextGL4liSFOCkPrM6tIB88RJBiz6irrWCvSV1HFjyi', 'V8WE2X', 117, NULL, 0, 'eyJ1c2VyX2lkIjoxMjEsInR5cGUiOjEsImV4cCI6MTc3NDQxMjM0M30=', '2026-03-25 12:19:03', 43, 1, NULL, '::1', '2026-03-18 12:19:03', '2026-03-18 12:19:03', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (122, 'ces11', 'ces11@example.com', '13800138011', '$2y$12$7tlIf1IH//gt9CkagR90VO3Usy3YTj./6LvxiT8UVaC5MByFkYUWq', 'QQKXD8', 115, NULL, 0, 'eyJ1c2VyX2lkIjoxMjIsInR5cGUiOjEsImV4cCI6MTc3NDQyMjk5Nn0=', '2026-03-25 15:16:36', 45, 1, NULL, '::1', '2026-03-18 15:16:36', '2026-03-18 15:16:36', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (123, 'ces12', 'ces12@example.com', '13800138012', '$2y$12$suN8qUp8N5ge/VKn63fg3eIuuxalGNdyC3rPaM.KWsSfw8c2YkPtq', 'BSEA3C', 115, NULL, 0, 'eyJ1c2VyX2lkIjoxMjMsInR5cGUiOjEsImV4cCI6MTc3NDQyMzA4MX0=', '2026-03-25 15:18:01', 46, 1, NULL, '::1', '2026-03-18 15:18:01', '2026-03-18 15:18:01', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (124, 'ces13', 'ces13@example.com', '13800138013', '$2y$12$U2K7c9XUBiK2gYwiON/Q0.hJGOYbBqV1T5Ongl4Q.B.tILExnCw2W', 'YHEPXK', 112, NULL, 0, 'eyJ1c2VyX2lkIjoxMjQsInR5cGUiOjEsImV4cCI6MTc3NDQyNDg1N30=', '2026-03-25 15:47:37', 47, 1, NULL, '::1', '2026-03-18 15:47:37', '2026-03-18 15:47:37', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (125, 'ces14', 'ces14@example.com', '13800138014', '$2y$12$i767mbbh2aCZUBTrkI.YVeCTccEjDw1cBf8xn9Zu2wymu5uKYi2gK', '42Y984', 124, NULL, 0, 'eyJ1c2VyX2lkIjoxMjUsInR5cGUiOjEsImV4cCI6MTc3NDQyNDkxOH0=', '2026-03-25 15:48:38', 48, 1, NULL, '::1', '2026-03-18 15:48:38', '2026-03-18 15:48:38', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO `c_users` VALUES (126, 'ces15', 'ces15@example.com', '13800138015', '$2y$12$sLEUxyGVMxMa26Bg5hI6qenSfN7idOtzV7NkuG0QLO/TssA6oyCH.', '2T957T', 115, NULL, 0, 'eyJ1c2VyX2lkIjoxMjYsInR5cGUiOjEsImV4cCI6MTc3NDQyNTQyMn0=', '2026-03-25 15:57:02', 49, 1, NULL, '::1', '2026-03-18 15:57:02', '2026-03-18 15:57:02', 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);

SET FOREIGN_KEY_CHECKS = 1;
