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

 Date: 18/03/2026 17:13:10
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

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
) ENGINE = InnoDB AUTO_INCREMENT = 50 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '钱包表-三端共用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wallets
-- ----------------------------
INSERT INTO `wallets` VALUES (33, 111, 1, 0, 'test', '2026-03-18 12:09:36', '2026-03-18 15:29:24');
INSERT INTO `wallets` VALUES (34, 112, 1, 0, 'ces1', '2026-03-18 12:10:57', '2026-03-18 15:29:24');
INSERT INTO `wallets` VALUES (35, 113, 1, 0, 'ces2', '2026-03-18 12:14:08', '2026-03-18 15:29:24');
INSERT INTO `wallets` VALUES (36, 114, 1, 0, 'ces3', '2026-03-18 12:15:41', '2026-03-18 15:29:24');
INSERT INTO `wallets` VALUES (37, 115, 1, 0, 'ces4', '2026-03-18 12:16:03', '2026-03-18 15:29:24');
INSERT INTO `wallets` VALUES (38, 116, 1, 0, 'ces5', '2026-03-18 12:16:12', '2026-03-18 15:29:24');
INSERT INTO `wallets` VALUES (39, 117, 1, 200, 'ces6', '2026-03-18 12:16:40', '2026-03-18 16:37:20');
INSERT INTO `wallets` VALUES (40, 118, 1, 0, 'ces7', '2026-03-18 12:17:08', '2026-03-18 15:29:24');
INSERT INTO `wallets` VALUES (41, 119, 1, 0, 'ces8', '2026-03-18 12:17:55', '2026-03-18 15:29:24');
INSERT INTO `wallets` VALUES (42, 120, 1, 0, 'ces9', '2026-03-18 12:18:03', '2026-03-18 15:29:24');
INSERT INTO `wallets` VALUES (43, 121, 1, 0, 'ces10', '2026-03-18 12:19:03', '2026-03-18 15:29:24');
INSERT INTO `wallets` VALUES (44, 6, 2, 997900, 'task', '2026-03-18 12:33:36', '2026-03-18 15:59:32');
INSERT INTO `wallets` VALUES (45, 122, 1, 0, 'ces11', '2026-03-18 15:16:36', '2026-03-18 15:29:24');
INSERT INTO `wallets` VALUES (46, 123, 1, 0, 'ces12', '2026-03-18 15:18:01', '2026-03-18 15:29:24');
INSERT INTO `wallets` VALUES (47, 124, 1, 0, 'ces13', '2026-03-18 15:47:37', '2026-03-18 15:47:37');
INSERT INTO `wallets` VALUES (48, 125, 1, 0, 'ces14', '2026-03-18 15:48:38', '2026-03-18 15:48:38');
INSERT INTO `wallets` VALUES (49, 126, 1, 0, 'ces15', '2026-03-18 15:57:02', '2026-03-18 15:57:02');

SET FOREIGN_KEY_CHECKS = 1;
