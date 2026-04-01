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

 Date: 01/04/2026 12:38:40
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
) ENGINE = InnoDB AUTO_INCREMENT = 98 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '团队收益明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of team_revenue_statistics_breakdown
-- ----------------------------
INSERT INTO `team_revenue_statistics_breakdown` VALUES (72, 133, 'test', 1, 134, 'ces1', 240.00, 240.00, 0.00, 240.00, '1', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-03-31 20:45:19');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (73, 134, 'ces1', 2, 153, 'aaa1', 100.00, 100.00, 0.00, 100.00, '21', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:09:57');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (74, 134, 'ces1', 2, 153, 'aaa1', 100.00, 100.00, 100.00, 200.00, '20', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:10:03');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (75, 134, 'ces1', 2, 153, 'aaa1', 100.00, 100.00, 200.00, 300.00, '19', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:10:08');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (76, 147, 'qqq10', 1, 154, 'aaa2', 100.00, 100.00, 0.00, 100.00, '16', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:13:39');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (77, 134, 'ces1', 2, 154, 'aaa2', 100.00, 100.00, 300.00, 400.00, '16', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:13:39');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (78, 147, 'qqq10', 1, 154, 'aaa2', 100.00, 100.00, 100.00, 200.00, '18', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:15:50');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (79, 134, 'ces1', 2, 154, 'aaa2', 100.00, 100.00, 400.00, 500.00, '18', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:15:50');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (80, 147, 'qqq10', 1, 154, 'aaa2', 100.00, 100.00, 200.00, 300.00, '17', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:15:54');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (81, 134, 'ces1', 2, 154, 'aaa2', 100.00, 100.00, 500.00, 600.00, '17', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:15:54');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (82, 147, 'qqq10', 1, 155, 'aaa3', 100.00, 100.00, 300.00, 400.00, '15', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:18:23');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (83, 134, 'ces1', 2, 155, 'aaa3', 100.00, 100.00, 600.00, 700.00, '15', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:18:23');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (84, 147, 'qqq10', 1, 155, 'aaa3', 100.00, 100.00, 400.00, 500.00, '14', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:18:27');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (85, 134, 'ces1', 2, 155, 'aaa3', 100.00, 100.00, 700.00, 800.00, '14', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:18:27');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (86, 147, 'qqq10', 1, 155, 'aaa3', 100.00, 100.00, 500.00, 600.00, '13', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:18:32');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (87, 134, 'ces1', 2, 155, 'aaa3', 100.00, 100.00, 800.00, 900.00, '13', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:18:32');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (88, 138, 'qqq1', 1, 156, 'bbb1', 100.00, 100.00, 0.00, 100.00, '25', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:22:07');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (89, 133, 'test', 2, 156, 'bbb1', 100.00, 100.00, 240.00, 340.00, '25', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:22:07');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (90, 138, 'qqq1', 1, 156, 'bbb1', 100.00, 100.00, 100.00, 200.00, '24', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:22:11');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (91, 133, 'test', 2, 156, 'bbb1', 100.00, 100.00, 340.00, 440.00, '24', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:22:11');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (92, 138, 'qqq1', 1, 157, 'bbb2', 100.00, 100.00, 200.00, 300.00, '22', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:30:53');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (93, 133, 'test', 2, 157, 'bbb2', 100.00, 100.00, 440.00, 540.00, '22', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:30:53');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (94, 138, 'qqq1', 1, 157, 'bbb2', 100.00, 100.00, 300.00, 400.00, '23', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:30:53');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (95, 133, 'test', 2, 157, 'bbb2', 100.00, 100.00, 540.00, 640.00, '23', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:30:53');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (96, 138, 'qqq1', 1, 157, 'bbb2', 100.00, 100.00, 400.00, 500.00, '12', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:39:11');
INSERT INTO `team_revenue_statistics_breakdown` VALUES (97, 133, 'test', 2, 157, 'bbb2', 100.00, 100.00, 640.00, 740.00, '12', 1, '任务收益', 0, '上评评论', 0, '上评评论', NULL, NULL, '2026-04-01 10:39:11');

SET FOREIGN_KEY_CHECKS = 1;
