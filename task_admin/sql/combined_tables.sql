/*
合并后的SQL文件
包含：system_permission_template、system_role_permission_template、system_roles、system_users、magnifying_glass_tasks
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
INSERT INTO `system_users` VALUES (1, 'task', '25d55ad283aa400af464c76d713c07ad', 'admin@example.com', '13800138000', 1, 'c476dc982c23641e0d571ce7cde824b2', '2026-03-07 12:48:40', 1, '2026-03-06 20:48:40', '2026-03-06 15:32:33', '2026-03-06 20:48:40');
INSERT INTO `system_users` VALUES (2, 'kefu', 'e99a18c428cb38d5f260853678922e03', 'kefu@qq.com', '15900000000', 5, '96e5c379ab22bc8165c9e5ccc37262ac', '2026-03-07 10:17:08', 1, '2026-03-06 18:17:08', '2026-03-06 18:09:15', '2026-03-06 18:17:08');
INSERT INTO `system_users` VALUES (3, 'shenji', 'e99a18c428cb38d5f260853678922e03', '', '15900000001', 7, 'ec2c29a16573e99bcd5d0b5ddad61474', '2026-03-07 10:16:30', 1, '2026-03-06 18:16:30', '2026-03-06 18:16:16', '2026-03-06 18:16:30');

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
) ENGINE = InnoDB AUTO_INCREMENT = 90 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '角色权限模板关联表' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `system_role_permission_template` VALUES (89, 7, 1, '2026-03-06 18:15:46');

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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '放大镜任务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of magnifying_glass_tasks
-- ----------------------------
INSERT INTO `magnifying_glass_tasks` VALUES (1, 3, NULL, 3, 'https://www.bilibili.com/video/BV1qeZuBPE3i/?spm_id_from=333.1007.tianma.1-3-3.click&vd_source=786a0003ba5bc5348f314ee587d01658', 1780243200, '[{"at_user": "@超哥超车", "comment": "蓝词搜索@超哥超车", "image_url": ""}, {"at_user": "@超哥超车", "comment": "蓝词搜索@超哥超车", "image_url": ""}]', 2, 0, 0, 0, 5.00, 10.00, 2, '2026-03-06 20:28:07', '2026-03-06 20:28:07', NULL, '放大镜搜索词');

SET FOREIGN_KEY_CHECKS = 1;