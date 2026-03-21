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

 Date: 21/03/2026 16:57:45
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for c_user_daily_stats
-- ----------------------------
DROP TABLE IF EXISTS `c_user_daily_stats`;
CREATE TABLE `c_user_daily_stats`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `c_user_id` bigint UNSIGNED NOT NULL COMMENT 'C端用户ID',
  `stat_date` date NOT NULL COMMENT '统计日期',
  `accept_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '当日接单次数',
  `submit_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '当日提交次数',
  `approved_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '当日通过次数',
  `rejected_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '当日驳回次数',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_date`(`c_user_id` ASC, `stat_date` ASC) USING BTREE,
  INDEX `idx_c_user_id`(`c_user_id` ASC) USING BTREE,
  INDEX `idx_stat_date`(`stat_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 34 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端用户每日统计表-限制驳回次数' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of c_user_daily_stats
-- ----------------------------
INSERT INTO `c_user_daily_stats` VALUES (32, 127, '2026-03-21', 1, 1, 0, 0, '2026-03-21 15:21:12', '2026-03-21 15:21:33');
INSERT INTO `c_user_daily_stats` VALUES (33, 128, '2026-03-21', 1, 0, 0, 0, '2026-03-21 15:25:52', '2026-03-21 15:25:52');

SET FOREIGN_KEY_CHECKS = 1;
