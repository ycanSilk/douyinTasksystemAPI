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

 Date: 18/03/2026 22:14:59
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for team_revenue_statistics_breakdown
-- ----------------------------
DROP TABLE IF EXISTS `team_revenue_statistics_breakdown`;
CREATE TABLE `team_revenue_statistics_breakdown`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `agent_id` bigint UNSIGNED NOT NULL COMMENT '代理用户ID（获得团队收益的人）',
  `agent_username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '代理用户名',
  `agent_level` tinyint NOT NULL COMMENT '代理层级：1=一级下线（直接邀请），2=二级下线（间接邀请）',
  `downline_user_id` bigint UNSIGNED NOT NULL COMMENT '下线用户ID（完成任务的人）',
  `downline_username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '下线用户名',
  `downline_user_amount` decimal(10, 2) NOT NULL COMMENT '下线完成任务获得的金额',
  `team_revenue_amount` decimal(10, 2) NOT NULL COMMENT '本次发放给代理的团队收益金额',
  `agent_before_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '变更前代理团队收益总额',
  `agent_after_amount` decimal(10, 2) NOT NULL COMMENT '变更后代理团队收益总额',
  `related_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '关联ID（任务ID或订单ID）',
  `revenue_source` tinyint NOT NULL COMMENT '收益来源：1=任务收益，2=账号出租收益',
  `revenue_source_text` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收益来源文本',
  `task_type` tinyint NULL DEFAULT NULL COMMENT '任务类型（来源为任务时有效）',
  `task_type_text` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务类型文本',
  `task_stage` tinyint NULL DEFAULT NULL COMMENT '任务阶段（来源为任务时有效）',
  `task_stage_text` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务阶段文本',
  `order_type` tinyint NULL DEFAULT NULL COMMENT '订单类型：1=出租订单，2=求租订单（来源为订单时有效）',
  `order_type_text` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '订单类型文本',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_agent_id`(`agent_id` ASC) USING BTREE,
  INDEX `idx_agent_level`(`agent_level` ASC) USING BTREE,
  INDEX `idx_downline_user_id`(`downline_user_id` ASC) USING BTREE,
  INDEX `idx_related_id`(`related_id` ASC) USING BTREE,
  INDEX `idx_revenue_source`(`revenue_source` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_agent_id_level`(`agent_id` ASC, `agent_level` ASC) USING BTREE COMMENT '复合索引，优化按代理和层级查询'
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '团队收益明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of team_revenue_statistics_breakdown
-- ----------------------------
INSERT INTO `team_revenue_statistics_breakdown` VALUES (24, 113, 'ces2', 1, 117, 'ces6', 100.00, 100.00, 0.00, 100.00, '101', 1, '任务收益', 1, '上评评论', 0, '上评评论', NULL, NULL, '2026-03-18 19:58:45');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (25, 112, 'ces1', 2, 117, 'ces6', 100.00, 100.00, 0.00, 100.00, '101', 1, '任务收益', 1, '上评评论', 0, '上评评论', NULL, NULL, '2026-03-18 19:58:45');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (26, 113, 'ces2', 1, 117, 'ces6', 100.00, 100.00, 100.00, 200.00, '100', 1, '任务收益', 1, '上评评论', 0, '上评评论', NULL, NULL, '2026-03-18 20:08:08');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (27, 112, 'ces1', 2, 117, 'ces6', 100.00, 100.00, 100.00, 200.00, '100', 1, '任务收益', 1, '上评评论', 0, '上评评论', NULL, NULL, '2026-03-18 20:08:08');

SET FOREIGN_KEY_CHECKS = 1;
