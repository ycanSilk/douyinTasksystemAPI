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

 Date: 14/03/2026 14:25:32
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for b_task_statistics
-- ----------------------------
DROP TABLE IF EXISTS `b_task_statistics`;
CREATE TABLE `b_task_statistics`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '统计ID',
  `b_user_id` bigint UNSIGNED NOT NULL COMMENT 'B端用户ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（冗余字段）',
  `flow_type` tinyint NOT NULL COMMENT '流水类型：1=收入，2=支出',
  `amount` bigint NOT NULL DEFAULT 0 COMMENT '变动金额（单位：分，正数）',
  `before_balance` bigint NOT NULL DEFAULT 0 COMMENT '变动前余额（单位：分）',
  `after_balance` bigint NOT NULL DEFAULT 0 COMMENT '变动后余额（单位：分）',
  `related_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关联类型：task_publish=任务发布，recharge=充值，account_rental=账号租赁，refund=退款',
  `related_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '关联ID（任务ID、订单ID等）',
  `task_types` tinyint UNSIGNED NULL DEFAULT NULL COMMENT '任务类型：1=上评评论，2=中评评论，3=放大镜搜索词，4=上中评评论，5=中下评评论，6=出租订单，7=求租订单',
  `task_types_text` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务类型文本描述',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '流水的详细说明记录',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_b_user_id`(`b_user_id` ASC) USING BTREE,
  INDEX `idx_flow_type`(`flow_type` ASC) USING BTREE,
  INDEX `idx_related`(`related_type` ASC, `related_id` ASC) USING BTREE,
  INDEX `idx_task_types`(`task_types` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端任务统计表-记录B端用户所有金额变动' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of b_task_statistics
-- ----------------------------
INSERT INTO `b_task_statistics` VALUES (1, 1, 'user1', 1, 10000, 0, 10000, 'recharge', NULL, NULL, NULL, '用户充值', '2026-03-13 14:45:35');
INSERT INTO `b_task_statistics` VALUES (2, 1, 'user1', 2, 2000, 10000, 8000, 'task_publish', 1, 1, '上评评论', '发布上评评论任务', '2026-03-13 14:45:35');
INSERT INTO `b_task_statistics` VALUES (3, 1, 'user1', 2, 1500, 8000, 6500, 'account_rental', 1, 6, '出租订单', '租赁账号', '2026-03-13 14:45:35');
INSERT INTO `b_task_statistics` VALUES (4, 1, 'user1', 1, 5000, 6500, 11500, 'recharge', NULL, NULL, NULL, '用户充值', '2026-03-12 14:45:35');
INSERT INTO `b_task_statistics` VALUES (5, 1, 'user1', 2, 3000, 11500, 8500, 'task_publish', 2, 3, '放大镜搜索词', '发布放大镜搜索词任务', '2026-03-12 14:45:35');
INSERT INTO `b_task_statistics` VALUES (6, 1, 'user1', 2, 2500, 8500, 6000, 'task_publish', 3, 2, '中评评论', '发布中评评论任务', '2026-03-06 14:45:35');
INSERT INTO `b_task_statistics` VALUES (7, 1, 'user1', 1, 1000, 6000, 7000, 'refund', 1, NULL, NULL, '退款', '2026-03-06 14:45:35');
INSERT INTO `b_task_statistics` VALUES (8, 1, 'user1', 2, 4000, 7000, 3000, 'task_publish', 4, 4, '上中评评论', '发布上中评评论任务', '2026-02-11 14:45:35');
INSERT INTO `b_task_statistics` VALUES (9, 2, 'user2', 1, 8000, 0, 8000, 'recharge', NULL, NULL, NULL, '用户充值', '2026-03-13 14:45:35');
INSERT INTO `b_task_statistics` VALUES (10, 2, 'user2', 2, 1800, 8000, 6200, 'task_publish', 5, 5, '中下评评论', '发布中下评评论任务', '2026-03-13 14:45:35');
INSERT INTO `b_task_statistics` VALUES (11, 2, 'user2', 2, 2200, 6200, 4000, 'account_rental', 2, 6, '出租订单', '租赁账号', '2026-03-12 14:45:35');
INSERT INTO `b_task_statistics` VALUES (12, 2, 'user2', 1, 6000, 4000, 10000, 'recharge', NULL, NULL, NULL, '用户充值', '2026-03-06 14:45:35');
INSERT INTO `b_task_statistics` VALUES (13, 2, 'user2', 2, 3500, 10000, 6500, 'task_publish', 6, 3, '放大镜搜索词', '发布放大镜搜索词任务', '2026-03-06 14:45:35');
INSERT INTO `b_task_statistics` VALUES (14, 3, 'user3', 1, 12000, 0, 12000, 'recharge', NULL, NULL, NULL, '用户充值', '2026-03-13 14:45:35');
INSERT INTO `b_task_statistics` VALUES (15, 3, 'user3', 2, 2500, 12000, 9500, 'task_publish', 7, 1, '上评评论', '发布上评评论任务', '2026-03-13 14:45:35');
INSERT INTO `b_task_statistics` VALUES (16, 3, 'user3', 2, 1200, 9500, 8300, 'account_rental', 3, 7, '求租订单', '求租账号', '2026-03-13 14:45:35');
INSERT INTO `b_task_statistics` VALUES (17, 3, 'user3', 2, 3000, 8300, 5300, 'task_publish', 8, 4, '上中评评论', '发布上中评评论任务', '2026-03-12 14:45:35');
INSERT INTO `b_task_statistics` VALUES (18, 4, 'user4', 1, 9000, 0, 9000, 'recharge', NULL, NULL, NULL, '用户充值', '2026-03-13 14:45:35');
INSERT INTO `b_task_statistics` VALUES (19, 4, 'user4', 2, 2100, 9000, 6900, 'task_publish', 9, 2, '中评评论', '发布中评评论任务', '2026-03-13 14:45:35');
INSERT INTO `b_task_statistics` VALUES (20, 4, 'user4', 2, 1800, 6900, 5100, 'task_publish', 10, 5, '中下评评论', '发布中下评评论任务', '2026-03-13 14:45:35');

SET FOREIGN_KEY_CHECKS = 1;
