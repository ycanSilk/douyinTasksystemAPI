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

 Date: 18/03/2026 15:22:48
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for wallets
-- ----------------------------
DROP TABLE IF EXISTS `wallets`;
CREATE TABLE `wallets`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '钱包ID',
  `balance` bigint NOT NULL DEFAULT 0 COMMENT '余额（单位：分，100=1元）',
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_balance`(`balance` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 47 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '钱包表-三端共用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wallets
-- ----------------------------
INSERT INTO `wallets` VALUES (33, 0, 'test', '2026-03-18 12:09:36', '2026-03-18 14:11:42');
INSERT INTO `wallets` VALUES (34, 0, 'ces1', '2026-03-18 12:10:57', '2026-03-18 14:11:48');
INSERT INTO `wallets` VALUES (35, 0, 'ces2', '2026-03-18 12:14:08', '2026-03-18 14:11:51');
INSERT INTO `wallets` VALUES (36, 0, 'ces3', '2026-03-18 12:15:41', '2026-03-18 14:11:54');
INSERT INTO `wallets` VALUES (37, 0, 'ces4', '2026-03-18 12:16:03', '2026-03-18 14:12:01');
INSERT INTO `wallets` VALUES (38, 0, 'ces5', '2026-03-18 12:16:12', '2026-03-18 14:12:03');
INSERT INTO `wallets` VALUES (39, 0, 'ces6', '2026-03-18 12:16:40', '2026-03-18 14:12:05');
INSERT INTO `wallets` VALUES (40, 0, 'ces7', '2026-03-18 12:17:08', '2026-03-18 14:12:08');
INSERT INTO `wallets` VALUES (41, 0, 'ces8', '2026-03-18 12:17:55', '2026-03-18 14:12:10');
INSERT INTO `wallets` VALUES (42, 0, 'ces9', '2026-03-18 12:18:03', '2026-03-18 14:12:15');
INSERT INTO `wallets` VALUES (43, 0, 'ces10', '2026-03-18 12:19:03', '2026-03-18 14:12:18');
INSERT INTO `wallets` VALUES (44, 0, 'ces11', '2026-03-18 12:33:36', '2026-03-18 14:12:21');
INSERT INTO `wallets` VALUES (45, 0, 'ces11', '2026-03-18 15:16:36', '2026-03-18 15:16:36');
INSERT INTO `wallets` VALUES (46, 0, 'ces12', '2026-03-18 15:18:01', '2026-03-18 15:18:01');

SET FOREIGN_KEY_CHECKS = 1;
