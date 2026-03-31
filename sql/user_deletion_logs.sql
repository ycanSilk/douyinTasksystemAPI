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

 Date: 31/03/2026 17:30:00
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for user_deletion_logs
-- ----------------------------
DROP TABLE IF EXISTS `user_deletion_logs`;
CREATE TABLE `user_deletion_logs`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '被注销用户ID',
  `user_type` tinyint NOT NULL DEFAULT 1 COMMENT '用户类型：1=C端，2=B端，3=Admin端',
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户名',
  `wallet_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '关联钱包ID',
  `wallet_balance_before` bigint NOT NULL DEFAULT 0 COMMENT '注销前钱包余额（单位：分）',
  `operator_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '操作人ID（管理员ID）',
  `operator_type` tinyint NOT NULL DEFAULT 3 COMMENT '操作人类型：1=C端，2=B端，3=Admin端',
  `operator_username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作人用户名',
  `operation_ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作IP地址',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '注销状态：1=成功，0=失败',
  `error_code` int NULL DEFAULT NULL COMMENT '错误码（失败时记录）',
  `error_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '错误信息（失败时记录）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_user_type`(`user_type` ASC) USING BTREE,
  INDEX `idx_operator_id`(`operator_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户注销日志记录表' ROW_FORMAT = DYNAMIC;

SET FOREIGN_KEY_CHECKS = 1;
