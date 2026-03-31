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

 Date: 31/03/2026 18:56:25
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
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '任务模板表-平台配置' ROW_FORMAT = DYNAMIC;

SET FOREIGN_KEY_CHECKS = 1;
