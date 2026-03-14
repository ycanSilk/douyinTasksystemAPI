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
-- Table structure for c_task_statistics
-- ----------------------------
DROP TABLE IF EXISTS `c_task_statistics`;
CREATE TABLE `c_task_statistics`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '统计ID',
  `c_user_id` bigint UNSIGNED NOT NULL COMMENT 'C端用户ID',
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
  INDEX `idx_c_user_id`(`c_user_id` ASC) USING BTREE,
  INDEX `idx_flow_type`(`flow_type` ASC) USING BTREE,
  INDEX `idx_related`(`related_type` ASC, `related_id` ASC) USING BTREE,
  INDEX `idx_task_types`(`task_types` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端任务统计表-记录C端用户所有金额变动' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of c_task_statistics
-- ----------------------------
INSERT INTO `c_task_statistics` VALUES (1, 1, 'c_user1', 1, 5000, 0, 5000, 'task_publish', 1, 1, '上评评论', '完成上评评论任务', '2026-03-13 14:45:35');
INSERT INTO `c_task_statistics` VALUES (2, 1, 'c_user1', 2, 1000, 5000, 4000, 'recharge', NULL, NULL, NULL, '用户提现', '2026-03-13 14:45:35');
INSERT INTO `c_task_statistics` VALUES (3, 1, 'c_user1', 1, 3000, 4000, 7000, 'task_publish', 2, 3, '放大镜搜索词', '完成放大镜搜索词任务', '2026-03-12 14:45:35');
INSERT INTO `c_task_statistics` VALUES (4, 1, 'c_user1', 1, 2000, 7000, 9000, 'account_rental', 1, 7, '求租订单', '完成求租订单任务', '2026-03-12 14:45:35');
INSERT INTO `c_task_statistics` VALUES (5, 1, 'c_user1', 2, 1500, 9000, 7500, 'recharge', NULL, NULL, NULL, '用户提现', '2026-03-06 14:45:35');
INSERT INTO `c_task_statistics` VALUES (6, 2, 'c_user2', 1, 4000, 0, 4000, 'task_publish', 3, 2, '中评评论', '完成中评评论任务', '2026-03-13 14:45:35');
INSERT INTO `c_task_statistics` VALUES (7, 2, 'c_user2', 1, 6000, 4000, 10000, 'task_publish', 4, 4, '上中评评论', '完成上中评评论任务', '2026-03-13 14:45:35');
INSERT INTO `c_task_statistics` VALUES (8, 2, 'c_user2', 2, 2000, 10000, 8000, 'recharge', NULL, NULL, NULL, '用户提现', '2026-03-12 14:45:35');
INSERT INTO `c_task_statistics` VALUES (9, 3, 'c_user3', 1, 3500, 0, 3500, 'task_publish', 5, 5, '中下评评论', '完成中下评评论任务', '2026-03-13 14:45:35');
INSERT INTO `c_task_statistics` VALUES (10, 3, 'c_user3', 1, 2500, 3500, 6000, 'account_rental', 2, 6, '出租订单', '完成出租订单任务', '2026-03-13 14:45:35');
INSERT INTO `c_task_statistics` VALUES (11, 3, 'c_user3', 1, 4000, 6000, 10000, 'task_publish', 6, 1, '上评评论', '完成上评评论任务', '2026-03-12 14:45:35');
INSERT INTO `c_task_statistics` VALUES (12, 4, 'c_user4', 1, 5500, 0, 5500, 'task_publish', 7, 3, '放大镜搜索词', '完成放大镜搜索词任务', '2026-03-13 14:45:35');
INSERT INTO `c_task_statistics` VALUES (13, 4, 'c_user4', 1, 3000, 5500, 8500, 'task_publish', 8, 2, '中评评论', '完成中评评论任务', '2026-03-13 14:45:35');
INSERT INTO `c_task_statistics` VALUES (14, 4, 'c_user4', 2, 2500, 8500, 6000, 'recharge', NULL, NULL, NULL, '用户提现', '2026-03-12 14:45:35');
INSERT INTO `c_task_statistics` VALUES (15, 5, 'c_user5', 1, 6000, 0, 6000, 'task_publish', 9, 4, '上中评评论', '完成上中评评论任务', '2026-03-13 14:45:35');
INSERT INTO `c_task_statistics` VALUES (16, 5, 'c_user5', 1, 4000, 6000, 10000, 'account_rental', 3, 7, '求租订单', '完成求租订单任务', '2026-03-13 14:45:35');
INSERT INTO `c_task_statistics` VALUES (17, 5, 'c_user5', 1, 3000, 10000, 13000, 'task_publish', 10, 5, '中下评评论', '完成中下评评论任务', '2026-03-12 14:45:35');
INSERT INTO `c_task_statistics` VALUES (18, 6, 'c_user6', 1, 4500, 0, 4500, 'task_publish', 11, 1, '上评评论', '完成上评评论任务', '2026-03-13 14:45:35');
INSERT INTO `c_task_statistics` VALUES (19, 6, 'c_user6', 1, 2500, 4500, 7000, 'task_publish', 12, 3, '放大镜搜索词', '完成放大镜搜索词任务', '2026-03-13 14:45:35');
INSERT INTO `c_task_statistics` VALUES (20, 6, 'c_user6', 2, 3000, 7000, 4000, 'recharge', NULL, NULL, NULL, '用户提现', '2026-03-12 14:45:35');

SET FOREIGN_KEY_CHECKS = 1;