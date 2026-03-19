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

 Date: 18/03/2026 17:13:03
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for wallets_log
-- ----------------------------
DROP TABLE IF EXISTS `wallets_log`;
CREATE TABLE `wallets_log`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '流水ID',
  `wallet_id` bigint UNSIGNED NOT NULL COMMENT '钱包ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '用户ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（冗余字段）',
  `user_type` tinyint NOT NULL COMMENT '用户类型：1=C端，2=B端，3=Admin端',
  `type` tinyint NOT NULL COMMENT '流水类型：1=收入，2=支出',
  `amount` bigint NOT NULL DEFAULT 0 COMMENT '变动金额（单位：分，正数）',
  `before_balance` bigint NOT NULL DEFAULT 0 COMMENT '变动前余额（单位：分）',
  `after_balance` bigint NOT NULL DEFAULT 0 COMMENT '变动后余额（单位：分）',
  `related_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关联类型：task=任务，recharge=充值，withdraw=提现，refund=退款',
  `related_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '关联ID（任务ID、订单ID等）',
  `task_types` tinyint UNSIGNED NULL DEFAULT NULL COMMENT '任务类型：1=上评评论，2=中评评论，3=放大镜搜索词，4=上中评评论，5=中下评评论，6=出租订单，7=求租订单',
  `task_types_text` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务类型文本描述',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '备注说明（扣费或收入原因）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_wallet_id`(`wallet_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_user_type`(`user_type` ASC) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_related`(`related_type` ASC, `related_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_task_types`(`task_types` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 268 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '钱包流水表-记录所有收支' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wallets_log
-- ----------------------------
INSERT INTO `wallets_log` VALUES (257, 44, 6, 'task', 2, 1, 0, 0, 0, 'recharge', 18, NULL, NULL, '充值 ¥10,000.00（alipay），审核中', '2026-03-18 15:55:03');
INSERT INTO `wallets_log` VALUES (258, 44, 6, 'task', 2, 1, 1000000, 0, 1000000, 'recharge', 18, NULL, NULL, '充值到账：¥10,000.00', '2026-03-18 15:55:15');
INSERT INTO `wallets_log` VALUES (259, 44, 6, 'task', 2, 2, 300, 1000000, 999700, 'task', 92, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-18 15:58:38');
INSERT INTO `wallets_log` VALUES (260, 44, 6, 'task', 2, 2, 300, 999700, 999400, 'task', 93, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-18 15:58:41');
INSERT INTO `wallets_log` VALUES (261, 44, 6, 'task', 2, 2, 300, 999400, 999100, 'task', 94, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-18 15:58:42');
INSERT INTO `wallets_log` VALUES (262, 44, 6, 'task', 2, 2, 300, 999100, 998800, 'task', 95, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-18 15:58:43');
INSERT INTO `wallets_log` VALUES (263, 44, 6, 'task', 2, 2, 300, 998800, 998500, 'task', 96, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-18 15:58:45');
INSERT INTO `wallets_log` VALUES (264, 44, 6, 'task', 2, 2, 300, 998500, 998200, 'task', 97, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-18 15:59:31');
INSERT INTO `wallets_log` VALUES (265, 44, 6, 'task', 2, 2, 300, 998200, 997900, 'task', 98, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-18 15:59:32');
INSERT INTO `wallets_log` VALUES (266, 39, 117, 'ces6', 1, 1, 100, 0, 100, 'commission', 98, 1, '上评评论', '完成任务获得佣金，任务ID：98', '2026-03-18 16:13:15');
INSERT INTO `wallets_log` VALUES (267, 39, 117, 'ces6', 1, 1, 100, 100, 200, 'commission', 97, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：97', '2026-03-18 16:37:20');

SET FOREIGN_KEY_CHECKS = 1;
