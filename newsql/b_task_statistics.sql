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

 Date: 14/03/2026 22:51:22
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
) ENGINE = InnoDB AUTO_INCREMENT = 36 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端任务统计表-记录B端用户所有金额变动' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of b_task_statistics
-- ----------------------------
INSERT INTO `b_task_statistics` VALUES (21, 3, 'task', 1, 0, 225200, 225200, 'recharge', 14, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-03-14 16:40:58');
INSERT INTO `b_task_statistics` VALUES (22, 3, 'task', 1, 20000, 225200, 245200, 'recharge', 14, 1, '充值', '充值到账：¥200.00', '2026-03-14 16:44:32');
INSERT INTO `b_task_statistics` VALUES (23, 3, 'task', 1, 20000, 245200, 245200, 'recharge', 0, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-03-14 20:21:03');
INSERT INTO `b_task_statistics` VALUES (24, 3, 'task', 2, 300, 245200, 244900, 'task_publish', 68, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-14 20:21:11');
INSERT INTO `b_task_statistics` VALUES (25, 3, 'task', 2, 600, 244900, 244300, 'task_publish', 69, 2, '中评评论', '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-14 20:22:05');
INSERT INTO `b_task_statistics` VALUES (26, 3, 'task', 2, 900, 244300, 243400, 'task_publish', 70, 4, '上中评评论', '发布任务【上中评评论】4个任务，扣除 ¥9.00', '2026-03-14 20:22:55');
INSERT INTO `b_task_statistics` VALUES (27, 3, 'task', 2, 600, 243400, 242800, 'task_publish', 72, 5, '中下评评论', '发布任务【中下评评论】2个任务，扣除 ¥6.00', '2026-03-14 20:23:08');
INSERT INTO `b_task_statistics` VALUES (28, 3, 'task', 2, 1000, 242800, 241800, 'task_publish', 10, 3, '放大镜搜索词', '发布放大镜任务【放大镜搜索词】2个任务，扣除 ¥10.00', '2026-03-14 20:23:29');
INSERT INTO `b_task_statistics` VALUES (29, 3, 'task', 2, 35000, 241800, 206800, 'account_rental', 1, 6, '出租订单', '租赁订单支付：测试租赁系统的新功能，佣金结算（7天）', '2026-03-14 20:24:49');
INSERT INTO `b_task_statistics` VALUES (30, 3, 'task', 1, 20000, 206800, 226800, 'recharge', 15, NULL, NULL, '充值到账：¥200.00', '2026-03-14 20:25:32');
INSERT INTO `b_task_statistics` VALUES (31, 3, 'task', 2, 300, 226800, 226500, 'task_publish', 74, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-14 21:19:09');
INSERT INTO `b_task_statistics` VALUES (32, 3, 'task', 2, 300, 226500, 226200, 'task_publish', 75, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-14 21:21:45');
INSERT INTO `b_task_statistics` VALUES (33, 3, 'task', 2, 25000, 196200, 171200, 'account_rental', 2, 6, '出租订单', '租赁订单支付：测试租赁系统的新功能，佣金结算（5天）', '2026-03-14 22:23:22');
INSERT INTO `b_task_statistics` VALUES (34, 3, 'task', 2, 25000, 171200, 171200, 'rental_order', 2, 7, '求租订单', '租赁订单支付（订单#2）', '2026-03-14 22:31:31');
INSERT INTO `b_task_statistics` VALUES (35, 3, 'task', 2, 30000, 0, 0, 'rental_order', 3, 7, '求租订单', '租赁订单支付（订单#3）', '2026-03-14 22:33:28');

SET FOREIGN_KEY_CHECKS = 1;
