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

 Date: 14/03/2026 22:52:39
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

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

SET FOREIGN_KEY_CHECKS = 1;
