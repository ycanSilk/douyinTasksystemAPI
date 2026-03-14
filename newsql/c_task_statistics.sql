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

 Date: 14/03/2026 22:51:30
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
) ENGINE = InnoDB AUTO_INCREMENT = 41 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端任务统计表-记录C端用户所有金额变动' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of c_task_statistics
-- ----------------------------
INSERT INTO `c_task_statistics` VALUES (21, 5, 'test', 1, 240, 4080, 4320, 'commission', 66, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：66', '2026-03-14 21:07:06');
INSERT INTO `c_task_statistics` VALUES (22, 5, 'test', 1, 240, 4320, 4560, 'commission', 67, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：67', '2026-03-14 21:09:08');
INSERT INTO `c_task_statistics` VALUES (23, 5, 'test', 1, 240, 4560, 4800, 'commission', 68, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：68', '2026-03-14 21:09:08');
INSERT INTO `c_task_statistics` VALUES (24, 5, 'test', 1, 160, 4800, 4960, 'commission', 69, 2, '中评评论', '自动审核通过任务获得佣金，任务ID：69', '2026-03-14 21:09:08');
INSERT INTO `c_task_statistics` VALUES (25, 5, 'test', 1, 240, 4960, 5200, 'commission', 70, 4, '上中评评论', '自动审核通过任务获得佣金，任务ID：70', '2026-03-14 21:09:08');
INSERT INTO `c_task_statistics` VALUES (26, 5, 'test', 1, 240, 5200, 5440, 'commission', 72, 5, '中下评评论', '自动审核通过任务获得佣金，任务ID：72', '2026-03-14 21:09:08');
INSERT INTO `c_task_statistics` VALUES (27, 5, 'test', 2, 1000, 5440, 4440, 'withdraw', 0, NULL, NULL, '提现申请 ¥10.00，手续费 ¥0.30，实到 ¥9.70，收款方式：alipay，审核中', '2026-03-14 21:12:40');
INSERT INTO `c_task_statistics` VALUES (28, 5, 'test', 1, 240, 4440, 4680, 'commission', 74, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：74', '2026-03-14 21:21:07');
INSERT INTO `c_task_statistics` VALUES (29, 26, 'test8', 1, 100, 300, 400, 'commission', 75, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：75', '2026-03-14 21:24:48');
INSERT INTO `c_task_statistics` VALUES (30, 20, 'test2', 1, 50, 250, 300, 'agent_commission', 75, 1, '上评评论', '下级用户 test8是高级团长 完成任务，获得高级团长佣金，任务ID：75', '2026-03-14 21:24:48');
INSERT INTO `c_task_statistics` VALUES (31, 5, 'test', 1, 240, 4680, 4920, 'second_agent_commission', 75, 1, '上评评论', '下级用户 test2 的团队成员完成任务，获得二级团长佣金，任务ID：75', '2026-03-14 21:24:48');
INSERT INTO `c_task_statistics` VALUES (32, 5, 'test', 2, 0, 4920, 4920, 'withdraw', 8, NULL, NULL, '提现审核通过：¥10.00', '2026-03-14 21:30:25');
INSERT INTO `c_task_statistics` VALUES (33, 5, 'test', 2, 300, 4920, 4620, 'withdraw', 0, NULL, NULL, '提现申请 ¥3.00，手续费 ¥0.09，实到 ¥2.91，收款方式：alipay，审核中', '2026-03-14 21:35:04');
INSERT INTO `c_task_statistics` VALUES (34, 5, 'test', 2, 0, 29120, 29120, 'withdraw', 9, NULL, NULL, '提现审核通过：¥3.00', '2026-03-14 22:18:13');
INSERT INTO `c_task_statistics` VALUES (35, 26, 'test8', 1, 17500, 400, 17900, 'rental_order_settlement', 2, 6, '出租订单', '租赁订单结算收益（订单#2）', '2026-03-14 22:31:31');
INSERT INTO `c_task_statistics` VALUES (36, 20, 'test2', 1, 0, 1550, 1550, 'agent_commission', 2, 6, '出租订单', '租赁订单团长佣金（订单#2）', '2026-03-14 22:31:31');
INSERT INTO `c_task_statistics` VALUES (37, 5, 'test', 1, 0, 29120, 29120, 'second_agent_commission', 2, 6, '出租订单', '租赁订单二级代理佣金（订单#2）', '2026-03-14 22:31:31');
INSERT INTO `c_task_statistics` VALUES (38, 26, 'test8', 1, 1400, 17900, 19300, 'rental_order_settlement', 3, 6, '出租订单', '租赁订单结算收益（订单#3）', '2026-03-14 22:33:28');
INSERT INTO `c_task_statistics` VALUES (39, 20, 'test2', 1, 0, 1650, 1650, 'agent_commission', 3, 6, '出租订单', '租赁订单团长佣金（订单#3）', '2026-03-14 22:33:28');
INSERT INTO `c_task_statistics` VALUES (40, 5, 'test', 1, 0, 29120, 29120, 'second_agent_commission', 3, 6, '出租订单', '租赁订单二级代理佣金（订单#3）', '2026-03-14 22:33:28');

SET FOREIGN_KEY_CHECKS = 1;
