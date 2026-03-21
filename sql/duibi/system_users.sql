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

 Date: 21/03/2026 12:58:01
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

SET FOREIGN_KEY_CHECKS = 1;
