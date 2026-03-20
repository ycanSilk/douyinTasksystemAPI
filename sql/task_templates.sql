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

 Date: 20/03/2026 23:03:58
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for task_templates
-- ----------------------------
DROP TABLE IF EXISTS `task_templates`;
CREATE TABLE `task_templates`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '模板ID',
  `type` tinyint NOT NULL DEFAULT 0 COMMENT '任务类型：0=单任务，1=组合任务',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务标题',
  `price` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '单价（元，单任务用）',
  `description1` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '描述信息1',
  `description2` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '描述信息2',
  `stage1_title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '阶段1标题（组合任务用）',
  `stage1_price` decimal(18, 2) NULL DEFAULT NULL COMMENT '阶段1单价（组合任务用）',
  `stage2_title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '阶段2标题（组合任务用）',
  `stage2_price` decimal(18, 2) NULL DEFAULT NULL COMMENT '阶段2单价（组合任务用）',
  `default_stage1_count` int NULL DEFAULT 1 COMMENT '默认阶段1数量（组合任务用）',
  `default_stage2_count` int NULL DEFAULT 3 COMMENT '默认阶段2数量（组合任务用）',
  `c_user_commission` int NOT NULL DEFAULT 0 COMMENT '普通用户佣金（分）',
  `agent_commission` int NOT NULL DEFAULT 0 COMMENT '普通团长佣金（分）',
  `senior_agent_commission` int NOT NULL DEFAULT 0 COMMENT '高级团长佣金（分）',
  `stage1_c_user_commission` int NULL DEFAULT NULL COMMENT '组合任务阶段1-普通用户佣金（分）',
  `stage1_agent_commission` int NULL DEFAULT NULL COMMENT '组合任务阶段1-普通团长佣金（分）',
  `stage1_senior_agent_commission` int NULL DEFAULT NULL COMMENT '组合任务阶段1-高级团长佣金（分）',
  `stage2_c_user_commission` int NULL DEFAULT NULL COMMENT '组合任务阶段2-普通用户佣金（分）',
  `stage2_agent_commission` int NULL DEFAULT NULL COMMENT '组合任务阶段2-普通团长佣金（分）',
  `stage2_senior_agent_commission` int NULL DEFAULT NULL COMMENT '组合任务阶段2-高级团长佣金（分）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=启用，0=禁用',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '任务模板表-平台配置' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of task_templates
-- ----------------------------
INSERT INTO `task_templates` VALUES (1, 0, '上评评论', 3.00, '发布上评评论', '', NULL, NULL, NULL, NULL, 1, 0, 100, 50, 50, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (2, 0, '中评评论', 2.00, '发布中评评论', '', NULL, NULL, NULL, NULL, 3, 0, 80, 30, 30, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (3, 0, '放大镜搜索词', 5.00, '抖音平台规则问题，本产品属于概率出现蓝词，搜索词搜索次数就越多，出现概率越大', '', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (4, 1, '上中评评论', 9.00, '组合评论：上评+中评(1+3)', '', '上评评论', 3.00, '中评评论', 2.00, 1, 3, 0, 0, 0, 100, 50, 50, 80, 30, 30, 1, '2026-02-15 14:51:45');
INSERT INTO `task_templates` VALUES (5, 1, '上中评快捷派单', 7.00, '上中评快捷派单', '快捷派单，上评+中评（1+2），第二条中评带@', '上中评快捷派单-上评评论', 3.00, '上中评快捷派单-中评评论', 2.00, 1, 3, 0, 0, 0, 100, 60, 70, 90, 30, 40, 1, '2026-03-19 22:35:53');
INSERT INTO `task_templates` VALUES (6, 1, '中下评快捷派单', 6.00, '快捷派单：中评+下评(1+1)，下评带@', '-', '中评评论', 3.00, '下评评论', 3.00, 1, 1, 0, 0, 0, 130, 45, 43, 130, 45, 45, 1, '2026-02-15 14:51:45');

SET FOREIGN_KEY_CHECKS = 1;
