/*
 Navicat Premium Dump SQL

 Source Server         : task
 Source Server Type    : MySQL
 Source Server Version : 80036 (8.0.36)
 Source Host           : 54.179.253.64:3306
 Source Schema         : task_platform

 Target Server Type    : MySQL
 Target Server Version : 80036 (8.0.36)
 File Encoding         : 65001

 Date: 31/03/2026 17:23:40
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
) ENGINE = InnoDB AUTO_INCREMENT = 33 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '钱包表-三端共用' ROW_FORMAT = DYNAMIC;

SET FOREIGN_KEY_CHECKS = 1;
