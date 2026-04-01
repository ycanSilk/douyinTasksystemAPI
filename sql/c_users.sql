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

 Date: 01/04/2026 11:06:51
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
  `extended_data` json NULL COMMENT '扩展数据（JSON格式，用于后续版本迭代）',
  `cooling_time_limit` tinyint NULL DEFAULT NULL COMMENT '接取任务冷却时间限制开启：0=不开启，1=开启',
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
) ENGINE = InnoDB AUTO_INCREMENT = 158 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端用户表-消费者端' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of c_users
-- ----------------------------
INSERT INTO `c_users` VALUES (133, 'test', 'test@example.com', '13800138000', '$2y$12$NAI8i16QQEo2B5NIEFqfD.3f/zfvVViafBcts5VXa39Ilm08TYVE.', 'SXWV3S', NULL, NULL, 3, 'eyJ1c2VyX2lkIjoxMzMsInR5cGUiOjEsImV4cCI6MTc3NTQwMDYxMX0=', '2026-04-05 22:50:11', 63, 1, NULL, '127.0.0.1', '2026-03-23 11:13:29', '2026-03-29 22:50:11', 0, NULL, NULL, NULL, '35aa9b33da8a7c5e4f350928f43ad299', 'Win32 Mozilla/5.0', 3, '{\"device_id\":\"35aa9b33da8a7c5e4f350928f43ad299\",\"device_name\":\"Win32 Mozilla\\/5.0\",\"login_time\":\"2026-03-29 22:50:11\",\"last_activity\":\"2026-03-29 22:50:11\"}', '[{\"device_id\":\"35aa9b33da8a7c5e4f350928f43ad299\",\"device_name\":\"Win32 Mozilla\\/5.0\",\"login_time\":\"2026-03-29 22:50:11\",\"last_activity\":\"2026-03-29 22:50:11\"}]', NULL, NULL);
INSERT INTO `c_users` VALUES (134, 'ces1', 'ces1@example.com', '13800138001', '$2y$12$907LXQIJ3rIem766i63PVeFXNIzsOfu/9CG4WxJWaAtUsFV5OVe5y', 'DBDW9M', 133, NULL, 3, 'eyJ1c2VyX2lkIjoxMzQsInR5cGUiOjEsImV4cCI6MTc3NTYxNjg0MX0=', '2026-04-08 10:54:01', 64, 1, NULL, '127.0.0.1', '2026-03-23 11:41:42', '2026-04-01 10:54:01', 0, NULL, 0, NULL, '123213213', 'windows', 3, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-04-01 10:54:01\",\"last_activity\":\"2026-04-01 10:54:01\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-04-01 10:54:01\",\"last_activity\":\"2026-04-01 10:54:01\"}]', NULL, 0);
INSERT INTO `c_users` VALUES (135, 'ces2', 'ces2@example.com', '13800138002', '$2y$12$COOibeTyWehsoFMS.WpWUu0plcR4GIZDZr.7piRB5r3PWn1p6inaa', '23TUE5', 133, NULL, 0, NULL, NULL, 65, 1, NULL, '127.0.0.1', '2026-03-23 11:44:37', '2026-03-26 21:32:56', 0, NULL, NULL, NULL, 'f989d1cf067071e57e5afa61e6587acc', 'Win32 Mozilla/5.0', 3, '{\"device_id\":\"f989d1cf067071e57e5afa61e6587acc\",\"device_name\":\"Win32 Mozilla\\/5.0\",\"login_time\":\"2026-03-26 13:13:18\",\"last_activity\":\"2026-03-26 13:13:18\"}', '[{\"device_id\":\"f989d1cf067071e57e5afa61e6587acc\",\"device_name\":\"Win32 Mozilla\\/5.0\",\"login_time\":\"2026-03-26 13:13:18\",\"last_activity\":\"2026-03-26 13:13:18\"}]', NULL, NULL);
INSERT INTO `c_users` VALUES (136, 'ces3', 'ces3@example.com', '13800138003', '$2y$12$NQdrvSy1khELqTRa1ykVOOK3V2Anzagy8wkFUPfSj9dT1DhHTG9sC', 'AEQZFJ', 133, NULL, 0, NULL, NULL, 66, 1, NULL, '127.0.0.1', '2026-03-23 11:45:36', '2026-03-26 21:32:59', 0, NULL, NULL, NULL, 'f989d1cf067071e57e5afa61e6587acc', 'iPhone', 3, '{\"device_id\":\"f989d1cf067071e57e5afa61e6587acc\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-26 13:29:36\",\"last_activity\":\"2026-03-26 13:29:36\"}', '[{\"device_id\":\"f989d1cf067071e57e5afa61e6587acc\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-26 13:29:36\",\"last_activity\":\"2026-03-26 13:29:36\"}]', NULL, NULL);
INSERT INTO `c_users` VALUES (137, 'test2', 'test2@example.com', '13800139002', '$2y$12$OdsIugjxCNYTA2f7ZqJn5OQZQ7/ZO1oXUPBo2vNteJMjtUkJwCJHG', 'DJ486V', 133, NULL, 0, 'eyJ1c2VyX2lkIjoxMzcsInR5cGUiOjEsImV4cCI6MTc3NDg3MDkxOH0=', '2026-03-30 19:41:58', 70, 1, NULL, '127.0.0.1', '2026-03-23 13:42:38', '2026-03-23 19:41:58', 0, NULL, NULL, NULL, '123213213', 'windows', 3, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-23 19:41:58\",\"last_activity\":\"2026-03-23 19:41:58\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-23 19:41:58\",\"last_activity\":\"2026-03-23 19:41:58\"}]', NULL, NULL);
INSERT INTO `c_users` VALUES (138, 'qqq1', 'qqq1@example.com', '15900138001', '$2y$12$vdcu6d2ZPjWDiJu0VKYb0ecWd/VvnjeyrhbgZ03ozlDjWLtJ0qwkm', 'SQESR5', 133, NULL, 1, NULL, NULL, 72, 1, NULL, '127.0.0.1', '2026-03-25 20:23:24', '2026-04-01 10:20:03', 0, NULL, NULL, NULL, '3ade4f8b8229bb80fde6d860ed714adf', 'iPhone', 3, '{\"device_id\":\"3ade4f8b8229bb80fde6d860ed714adf\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-25 20:31:42\",\"last_activity\":\"2026-03-25 20:31:42\"}', '[{\"device_id\":\"3ade4f8b8229bb80fde6d860ed714adf\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-25 20:31:42\",\"last_activity\":\"2026-03-25 20:31:42\"}]', NULL, NULL);
INSERT INTO `c_users` VALUES (139, 'qqq2', 'qqq2@example.com', '15900138002', '$2y$12$6BpTWEQN.J/q0yUq7CxyR.neojLsVbjn4OzqO6s52YI2ueEilkF2m', '9Z5784', 133, NULL, 0, 'eyJ1c2VyX2lkIjoxMzksInR5cGUiOjEsImV4cCI6MTc3NTA0NjIxMX0=', '2026-04-01 20:23:31', 73, 1, NULL, '127.0.0.1', '2026-03-25 20:23:31', '2026-03-25 20:23:31', 0, NULL, NULL, NULL, NULL, NULL, 3, NULL, NULL, NULL, NULL);
INSERT INTO `c_users` VALUES (140, 'qqq3', 'qqq3@example.com', '15900138003', '$2y$12$O24opMgLI5AzJaLLyBKfnel4VBVeGWC9f4PQgT9nVHmzMGef66axe', 'RQF6SV', 133, NULL, 0, 'eyJ1c2VyX2lkIjoxNDAsInR5cGUiOjEsImV4cCI6MTc3NTA0NjIyMH0=', '2026-04-01 20:23:40', 74, 1, NULL, '127.0.0.1', '2026-03-25 20:23:39', '2026-03-25 20:23:40', 0, NULL, NULL, NULL, NULL, NULL, 3, NULL, NULL, NULL, NULL);
INSERT INTO `c_users` VALUES (141, 'qqq4', 'qqq4@example.com', '15900138004', '$2y$12$5l7VH2orsnr8OZR/Eif.kOTW8SYXsXVI41fHE2D1VXNRFekbA63na', 'AEJFMX', 133, NULL, 0, 'eyJ1c2VyX2lkIjoxNDEsInR5cGUiOjEsImV4cCI6MTc3NTA0NjIzMH0=', '2026-04-01 20:23:50', 75, 1, NULL, '127.0.0.1', '2026-03-25 20:23:50', '2026-03-25 20:23:50', 0, NULL, NULL, NULL, NULL, NULL, 3, NULL, NULL, NULL, NULL);
INSERT INTO `c_users` VALUES (142, 'qqq5', 'qqq5@example.com', '15900138005', '$2y$12$iQzPQHP4C.J8zNOJ1xEEQOOBWlfQ.YBjEewsZMIRTdane6iZhwKMu', 'PGSJ93', 133, NULL, 0, 'eyJ1c2VyX2lkIjoxNDIsInR5cGUiOjEsImV4cCI6MTc3NTEwNzc5Mn0=', '2026-04-02 13:29:52', 76, 1, NULL, '127.0.0.1', '2026-03-25 20:23:59', '2026-03-26 13:30:09', 0, NULL, NULL, NULL, 'f989d1cf067071e57e5afa61e6587acc', 'iPhone', 3, '{\"device_id\":\"f989d1cf067071e57e5afa61e6587acc\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-26 13:29:52\",\"last_activity\":\"2026-03-26 13:29:52\"}', '[{\"device_id\":\"f989d1cf067071e57e5afa61e6587acc\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-26 13:29:52\",\"last_activity\":\"2026-03-26 13:29:52\"}]', NULL, NULL);
INSERT INTO `c_users` VALUES (143, 'qqq6', 'qqq6@example.com', '15900138006', '$2y$12$tPJySMN9qeRZle/Ft2zuluCiupzTrNgob9aSmmCxFnocFp4BcZOXO', 'JZYXWQ', 133, NULL, 0, NULL, NULL, 77, 1, NULL, '127.0.0.1', '2026-03-25 20:34:10', '2026-03-25 20:36:32', 0, NULL, NULL, NULL, '3ade4f8b8229bb80fde6d860ed714adf', 'iPhone', 3, '{\"device_id\":\"3ade4f8b8229bb80fde6d860ed714adf\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-25 20:34:41\",\"last_activity\":\"2026-03-25 20:34:41\"}', '[{\"device_id\":\"3ade4f8b8229bb80fde6d860ed714adf\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-25 20:34:41\",\"last_activity\":\"2026-03-25 20:34:41\"}]', NULL, NULL);
INSERT INTO `c_users` VALUES (144, 'qqq7', 'qqq7@example.com', '15900138007', '$2y$12$BIHHXGbKdqpQ7Bae98.jvu.lsmlAyyjFsXoTe81dIJbfl0HlDAMye', 'E9EJ37', 134, NULL, 0, NULL, NULL, 78, 1, NULL, '127.0.0.1', '2026-03-25 20:36:22', '2026-03-25 20:48:19', 0, NULL, NULL, NULL, '3ade4f8b8229bb80fde6d860ed714adf', 'iPhone', 3, '{\"device_id\":\"3ade4f8b8229bb80fde6d860ed714adf\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-25 20:36:40\",\"last_activity\":\"2026-03-25 20:36:40\"}', '[{\"device_id\":\"3ade4f8b8229bb80fde6d860ed714adf\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-25 20:36:40\",\"last_activity\":\"2026-03-25 20:36:40\"}]', NULL, NULL);
INSERT INTO `c_users` VALUES (145, 'qqq8', 'qqq8@example.com', '15900138008', '$2y$12$ltIdQoY../1QI55ulRZ4sOxXe7OvEPKaXpMZ8FiuVvULv32whOali', '9DYDMY', 134, NULL, 0, 'eyJ1c2VyX2lkIjoxNDUsInR5cGUiOjEsImV4cCI6MTc3NTA0ODQyOH0=', '2026-04-01 21:00:28', 79, 1, NULL, '127.0.0.1', '2026-03-25 20:55:34', '2026-03-25 21:06:10', 0, NULL, NULL, NULL, '3ade4f8b8229bb80fde6d860ed714adf', 'iPhone', 3, '{\"device_id\":\"3ade4f8b8229bb80fde6d860ed714adf\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-25 21:00:28\",\"last_activity\":\"2026-03-25 21:00:28\"}', '[{\"device_id\":\"3ade4f8b8229bb80fde6d860ed714adf\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-25 21:00:28\",\"last_activity\":\"2026-03-25 21:00:28\"}]', NULL, NULL);
INSERT INTO `c_users` VALUES (146, 'qqq9', 'qqq9@example.com', '15900138009', '$2y$12$Ls0nM1ncTMgmaVArT1lvKOh3CKR3/k1shzxsQ5Ra6MDU1vGojFiLS', 'R4MUKA', 134, NULL, 0, 'eyJ1c2VyX2lkIjoxNDYsInR5cGUiOjEsImV4cCI6MTc3NTA0ODE1NX0=', '2026-04-01 20:55:55', 80, 1, NULL, '127.0.0.1', '2026-03-25 20:55:55', '2026-03-25 20:55:55', 0, NULL, NULL, NULL, NULL, NULL, 3, NULL, NULL, NULL, NULL);
INSERT INTO `c_users` VALUES (147, 'qqq10', 'qqq10@example.com', '15900138010', '$2y$12$bqNfaufvApZwID6PM9GeEe2BFtE.fKa74Nkn9rfqZF8Vx0pvfWSxS', '82PCE8', 134, NULL, 2, 'eyJ1c2VyX2lkIjoxNDcsInR5cGUiOjEsImV4cCI6MTc3NTEwMzc0Nn0=', '2026-04-02 12:22:26', 81, 1, NULL, '127.0.0.1', '2026-03-25 20:56:13', '2026-04-01 10:11:39', 0, NULL, NULL, NULL, '123213213', 'windows', 3, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-26 12:22:26\",\"last_activity\":\"2026-03-26 12:22:26\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-03-26 12:22:26\",\"last_activity\":\"2026-03-26 12:22:26\"}]', NULL, NULL);
INSERT INTO `c_users` VALUES (148, 'qqq11', 'qqq11@example.com', '15900138011', '$2y$12$n.mroSzpGwsC72ouSbpcburqtdCOBeV2OFk7krXFWHZY/XCruzoBS', 'YETV2B', 134, NULL, 0, 'eyJ1c2VyX2lkIjoxNDgsInR5cGUiOjEsImV4cCI6MTc3NTA0ODE4MH0=', '2026-04-01 20:56:20', 82, 1, NULL, '127.0.0.1', '2026-03-25 20:56:20', '2026-03-25 20:56:20', 0, NULL, NULL, NULL, NULL, NULL, 3, NULL, NULL, NULL, NULL);
INSERT INTO `c_users` VALUES (149, 'qqq12', 'qqq12@example.com', '15900138012', '$2y$12$JpGx7LLurEnFh.xgZaTc1uqaHk3XLQhyT1aUy6HKWRR3S7rhOibpi', 'SDQPZ9', 134, NULL, 0, 'eyJ1c2VyX2lkIjoxNDksInR5cGUiOjEsImV4cCI6MTc3NTA0ODE4N30=', '2026-04-01 20:56:27', 83, 1, NULL, '127.0.0.1', '2026-03-25 20:56:27', '2026-03-25 20:56:27', 0, NULL, NULL, NULL, NULL, NULL, 3, NULL, NULL, NULL, NULL);
INSERT INTO `c_users` VALUES (150, 'qqq13', 'qqq13@example.com', '15900138013', '$2y$12$4QmHIEqkmyVu1WlmEfXpjeGGP7AzVL7HBrkMs3h8pQUBRmwZk2yay', 'D4SPMS', 134, NULL, 0, 'eyJ1c2VyX2lkIjoxNTAsInR5cGUiOjEsImV4cCI6MTc3NTA1MzkzNH0=', '2026-04-01 22:32:14', 84, 1, NULL, '127.0.0.1', '2026-03-25 20:56:36', '2026-03-25 22:53:10', 0, NULL, NULL, NULL, '3ade4f8b8229bb80fde6d860ed714adf', 'iPhone', 3, '{\"device_id\":\"3ade4f8b8229bb80fde6d860ed714adf\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-25 22:32:14\",\"last_activity\":\"2026-03-25 22:32:14\"}', '[{\"device_id\":\"3ade4f8b8229bb80fde6d860ed714adf\",\"device_name\":\"iPhone\",\"login_time\":\"2026-03-25 22:32:14\",\"last_activity\":\"2026-03-25 22:32:14\"}]', NULL, NULL);
INSERT INTO `c_users` VALUES (151, 'ces111', NULL, '13794719208', '$2y$12$drdr4YIY.jzizC6opfQruOtDohk1cYbs367VuKpjAXuodt60ZW9QO', 'A7S9EZ', NULL, NULL, 0, 'eyJ1c2VyX2lkIjoxNTEsInR5cGUiOjEsImV4cCI6MTc3NTEzNzg2M30=', '2026-04-02 21:51:03', 85, 1, NULL, '127.0.0.1', '2026-03-26 21:51:03', '2026-03-26 21:51:03', 0, NULL, NULL, NULL, NULL, NULL, 3, NULL, NULL, NULL, NULL);
INSERT INTO `c_users` VALUES (153, 'aaa1', 'aaa1@example.com', '15900001111', '$2y$12$vHvID4MwI.p77U9Uet1g1OAnG.TwBTSL38DVcM955L2uby58XPUI.', 'PA4BQC', 147, NULL, 0, 'eyJ1c2VyX2lkIjoxNTMsInR5cGUiOjEsImV4cCI6MTc3NTYxNDA5OH0=', '2026-04-08 10:08:18', 87, 1, NULL, '127.0.0.1', '2026-04-01 10:03:56', '2026-04-01 10:08:18', 0, NULL, NULL, NULL, '123213213', 'windows', 3, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-04-01 10:08:18\",\"last_activity\":\"2026-04-01 10:08:18\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-04-01 10:08:18\",\"last_activity\":\"2026-04-01 10:08:18\"}]', NULL, 0);
INSERT INTO `c_users` VALUES (154, 'aaa2', 'aaa2@example.com', '15900001112', '$2y$12$y46twGBDbvq4CKmN0nkst./UV1NPYmWqOW75.nwcq1ZsMHCq254TS', 'XG45T2', 147, NULL, 0, 'eyJ1c2VyX2lkIjoxNTQsInR5cGUiOjEsImV4cCI6MTc3NTYxNDMxNn0=', '2026-04-08 10:11:56', 88, 1, NULL, '127.0.0.1', '2026-04-01 10:04:07', '2026-04-01 10:11:56', 0, NULL, NULL, NULL, '123213213', 'windows', 3, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-04-01 10:11:56\",\"last_activity\":\"2026-04-01 10:11:56\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-04-01 10:11:56\",\"last_activity\":\"2026-04-01 10:11:56\"}]', NULL, 0);
INSERT INTO `c_users` VALUES (155, 'aaa3', 'aaa3@example.com', '15900001113', '$2y$12$aQXi3Kypp7s2jVk0sqgMZuy/xO7e5sIv8gy/rYf795TvsB5WGOq2O', 'JK7NRV', 147, NULL, 0, 'eyJ1c2VyX2lkIjoxNTUsInR5cGUiOjEsImV4cCI6MTc3NTYxNDYwNX0=', '2026-04-08 10:16:45', 89, 1, NULL, '127.0.0.1', '2026-04-01 10:04:14', '2026-04-01 10:16:45', 0, NULL, NULL, NULL, '123213213', 'windows', 3, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-04-01 10:16:45\",\"last_activity\":\"2026-04-01 10:16:45\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-04-01 10:16:45\",\"last_activity\":\"2026-04-01 10:16:45\"}]', NULL, 0);
INSERT INTO `c_users` VALUES (156, 'bbb1', 'bbb1@example.com', '15900001114', '$2y$12$wRnGAIoaew67d2LL8GPL5e8hD38pr72J2adb5waj3U43GOY6oHS4G', 'EFMDAW', 138, NULL, 0, 'eyJ1c2VyX2lkIjoxNTYsInR5cGUiOjEsImV4cCI6MTc3NTYxNDg1MH0=', '2026-04-08 10:20:50', 90, 1, NULL, '127.0.0.1', '2026-04-01 10:20:29', '2026-04-01 10:21:41', 0, NULL, NULL, NULL, '123213213', 'windows', 3, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-04-01 10:20:50\",\"last_activity\":\"2026-04-01 10:20:50\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-04-01 10:20:50\",\"last_activity\":\"2026-04-01 10:20:50\"}]', NULL, 0);
INSERT INTO `c_users` VALUES (157, 'bbb2', 'bbb2@example.com', '15900001115', '$2y$12$qk5KSYHGqk9u5EUhbjOWG.Twr8l1KTzWNlgLvEvHOiUI5Lw6Y9iU6', '3CGMUY', 138, NULL, 0, 'eyJ1c2VyX2lkIjoxNTcsInR5cGUiOjEsImV4cCI6MTc3NTYxNDk0Mn0=', '2026-04-08 10:22:22', 91, 1, NULL, '127.0.0.1', '2026-04-01 10:20:36', '2026-04-01 10:22:22', 0, NULL, NULL, NULL, '123213213', 'windows', 3, '{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-04-01 10:22:22\",\"last_activity\":\"2026-04-01 10:22:22\"}', '[{\"device_id\":\"123213213\",\"device_name\":\"windows\",\"login_time\":\"2026-04-01 10:22:22\",\"last_activity\":\"2026-04-01 10:22:22\"}]', NULL, 0);

SET FOREIGN_KEY_CHECKS = 1;
