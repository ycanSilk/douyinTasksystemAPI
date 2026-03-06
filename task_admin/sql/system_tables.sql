/*
系统核心表创建SQL
包含：system_permission_template、system_role_permission_template、system_roles、system_users
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

SET FOREIGN_KEY_CHECKS = 1;

-- 插入默认角色数据
INSERT IGNORE INTO `system_roles` (`name`, `description`, `status`) VALUES
('超级管理员', '系统最高权限角色', 1);

-- 插入默认导航面板数据
INSERT INTO `system_permission_template` (`name`, `code`, `icon`, `sort_order`, `status`, `description`) VALUES
('统计面板', 'dashboard', 'ri-dashboard-line', 1, 1, '运营概览和数据统计'),
('B端用户管理', 'b-users', 'ri-group-line', 2, 1, '管理B端用户账号'),
('C端用户管理', 'c-users', 'ri-user-line', 3, 1, '管理C端用户账号'),
('充值审核', 'recharge', 'ri-money-cny-circle-line', 4, 1, '审核用户充值申请'),
('提现审核', 'withdraw', 'ri-wallet-line', 5, 1, '审核用户提现申请'),
('任务模板管理', 'templates', 'ri-file-list-line', 6, 1, '管理任务模板'),
('任务市场管理', 'market', 'ri-store-line', 7, 1, '监控任务市场'),
('钱包记录管理', 'wallet-logs', 'ri-bank-card-line', 8, 1, '管理钱包资金记录'),
('团长审核', 'agent', 'ri-user-star-line', 9, 1, '审核团长申请'),
('租赁处理', 'rental-orders', 'ri-home-line', 10, 1, '处理租赁订单'),
('工单管理', 'rental-tickets', 'ri-clipboard-line', 11, 1, '管理工单'),
('网站配置', 'system-config', 'ri-settings-line', 12, 1, '管理网站系统配置'),
('任务审核', 'task-review', 'ri-check-double-line', 13, 1, '审核B端任务'),
('系统通知', 'notifications', 'ri-notification-line', 14, 1, '管理系统通知'),
('系统用户管理', 'system-users', 'ri-admin-line', 15, 1, '管理系统用户'),
('角色管理', 'system-roles', 'ri-shield-keyhole-line', 16, 1, '管理系统角色'),
('权限管理', 'system-permissions', 'ri-lock-unlock-line', 17, 1, '管理系统权限'),
('放大镜任务', 'magnifier', 'ri-search-line', 18, 1, '管理放大镜任务');

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '放大镜任务表' ROW_FORMAT = DYNAMIC;

-- 创建超级管理员用户（用户名：supertask，密码：12346578）
INSERT IGNORE INTO `system_users` (`username`, `password_hash`, `email`, `phone`, `role_id`, `status`)
VALUES
('supertask', '25d55ad283aa400af464c76d713c07ad', 'admin@example.com', '13800138000', 1, 1);

-- 为超级管理员角色分配所有权限模板
INSERT IGNORE INTO `system_role_permission_template` (`role_id`, `template_id`) 
SELECT 1, id FROM `system_permission_template`;



