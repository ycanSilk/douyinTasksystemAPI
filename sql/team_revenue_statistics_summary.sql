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

 Date: 18/03/2026 19:33:44
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for team_revenue_statistics_summary
-- ----------------------------
DROP TABLE IF EXISTS `team_revenue_statistics_summary`;
CREATE TABLE `team_revenue_statistics_summary`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '用户ID（代理）',
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `total_team_revenue` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '总团队收益',
  `level1_team_revenue` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '一级下线贡献收益（agent_level=1）',
  `level2_team_revenue` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '二级下线贡献收益（agent_level=2）',
  `level1_downline_count` int NOT NULL DEFAULT 0 COMMENT '一级下线人数（直接邀请）',
  `level2_downline_count` int NOT NULL DEFAULT 0 COMMENT '二级下线人数（间接邀请）',
  `total_downline_count` int NOT NULL DEFAULT 0 COMMENT '总下线人数（去重）',
  `level1_active_count` int NOT NULL DEFAULT 0 COMMENT '活跃一级下线人数',
  `level2_active_count` int NOT NULL DEFAULT 0 COMMENT '活跃二级下线人数',
  `total_active_count` int NOT NULL DEFAULT 0 COMMENT '总活跃下线人数',
  `task_revenue_count` int NOT NULL DEFAULT 0 COMMENT '任务收益笔数',
  `order_revenue_count` int NOT NULL DEFAULT 0 COMMENT '订单收益笔数',
  `task_revenue_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '任务收益总额',
  `order_revenue_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '订单收益总额',
  `level1_revenue_count` int NOT NULL DEFAULT 0 COMMENT '一级下线收益笔数',
  `level2_revenue_count` int NOT NULL DEFAULT 0 COMMENT '二级下线收益笔数',
  `last_revenue_time` datetime NULL DEFAULT NULL COMMENT '最后收益时间',
  `last_level1_revenue_time` datetime NULL DEFAULT NULL COMMENT '最后一级下线收益时间',
  `last_level2_revenue_time` datetime NULL DEFAULT NULL COMMENT '最后二级下线收益时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_total_team_revenue`(`total_team_revenue` ASC) USING BTREE,
  INDEX `idx_level1_revenue`(`level1_team_revenue` ASC) USING BTREE,
  INDEX `idx_level2_revenue`(`level2_team_revenue` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '团队收益汇总表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of team_revenue_statistics_summary
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
