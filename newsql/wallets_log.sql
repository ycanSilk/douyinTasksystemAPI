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

 Date: 14/03/2026 22:54:07
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
) ENGINE = InnoDB AUTO_INCREMENT = 213 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '钱包流水表-记录所有收支' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wallets_log
-- ----------------------------
INSERT INTO `wallets_log` VALUES (1, 2, 2, 'Ceshi1', 2, 1, 0, 0, 0, 'recharge', 1, NULL, NULL, '充值 ¥1,000.00（alipay），审核中', '2026-02-27 12:49:30');
INSERT INTO `wallets_log` VALUES (2, 1, 1, 'Ceshi', 2, 1, 0, 0, 0, 'recharge', 2, NULL, NULL, '充值 ¥1,000.00（alipay），审核中', '2026-02-27 12:49:46');
INSERT INTO `wallets_log` VALUES (3, 1, 1, 'Ceshi', 2, 1, 100000, 0, 100000, 'recharge', 2, NULL, NULL, '充值到账：¥1,000.00', '2026-02-27 12:49:56');
INSERT INTO `wallets_log` VALUES (4, 2, 2, 'Ceshi1', 2, 1, 100000, 0, 100000, 'recharge', 1, NULL, NULL, '充值到账：¥1,000.00', '2026-02-27 12:49:58');
INSERT INTO `wallets_log` VALUES (5, 2, 2, 'Ceshi1', 2, 1, 0, 100000, 100000, 'recharge', 3, NULL, NULL, '充值 ¥1,000.00（alipay），审核中', '2026-02-27 13:17:34');
INSERT INTO `wallets_log` VALUES (6, 1, 1, 'Ceshi', 2, 1, 0, 100000, 100000, 'recharge', 4, NULL, NULL, '充值 ¥1,000.00（alipay），审核中', '2026-02-27 13:18:09');
INSERT INTO `wallets_log` VALUES (7, 2, 2, 'Ceshi1', 2, 2, 5000, 100000, 95000, 'rental_freeze', 1, NULL, NULL, '求租信息冻结预算（5000分/天×1天）：抖音日租', '2026-02-27 13:47:33');
INSERT INTO `wallets_log` VALUES (8, 2, 2, 'Ceshi1', 2, 1, 0, 95000, 95000, 'recharge', 5, NULL, NULL, '充值 ¥100.00（alipay），审核中', '2026-02-27 14:22:20');
INSERT INTO `wallets_log` VALUES (9, 2, 2, 'Ceshi1', 2, 1, 10000, 95000, 105000, 'recharge', 5, NULL, NULL, '充值到账：¥100.00', '2026-02-27 14:23:06');
INSERT INTO `wallets_log` VALUES (10, 1, 1, 'Ceshi', 2, 1, 100000, 100000, 200000, 'recharge', 4, NULL, NULL, '充值到账：¥1,000.00', '2026-02-27 14:23:08');
INSERT INTO `wallets_log` VALUES (11, 2, 2, 'Ceshi1', 2, 1, 100000, 105000, 205000, 'recharge', 3, NULL, NULL, '充值到账：¥1,000.00', '2026-02-27 14:23:13');
INSERT INTO `wallets_log` VALUES (12, 2, 2, 'Ceshi1', 2, 2, 600, 205000, 204400, 'task', 1, NULL, NULL, '发布任务【上评评论】2个任务，扣除 ¥6.00', '2026-02-27 18:25:58');
INSERT INTO `wallets_log` VALUES (13, 2, 2, 'Ceshi1', 2, 2, 400, 204400, 204000, 'task', 2, NULL, NULL, '发布任务【中评评论】2个任务，扣除 ¥4.00', '2026-02-27 18:31:19');
INSERT INTO `wallets_log` VALUES (14, 1, 1, 'Ceshi', 2, 1, 0, 200000, 200000, 'recharge', 6, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-02-28 23:20:05');
INSERT INTO `wallets_log` VALUES (15, 1, 1, 'Ceshi', 2, 1, 20000, 200000, 220000, 'recharge', 6, NULL, NULL, '充值到账：¥200.00', '2026-02-28 23:20:14');
INSERT INTO `wallets_log` VALUES (16, 2, 2, 'Ceshi1', 2, 2, 300, 204000, 203700, 'task', 3, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-02-28 23:34:35');
INSERT INTO `wallets_log` VALUES (17, 2, 2, 'Ceshi1', 2, 1, 5000, 203700, 208700, 'rental_unfreeze', 1, NULL, NULL, '求租到期退回预算（5000分/天×1天）：抖音日租', '2026-03-01 00:00:04');
INSERT INTO `wallets_log` VALUES (18, 1, 1, 'Ceshi', 2, 2, 300, 220000, 219700, 'task', 4, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-01 00:34:05');
INSERT INTO `wallets_log` VALUES (19, 7, 3, 'task', 2, 1, 0, 0, 0, 'recharge', 7, NULL, NULL, '充值 ¥2,000.00（alipay），审核中', '2026-03-01 00:51:42');
INSERT INTO `wallets_log` VALUES (20, 7, 3, 'task', 2, 1, 200000, 0, 200000, 'recharge', 7, NULL, NULL, '充值到账：¥2,000.00', '2026-03-01 00:51:51');
INSERT INTO `wallets_log` VALUES (21, 7, 3, 'task', 2, 2, 10000, 200000, 190000, 'rental_freeze', 2, NULL, NULL, '求租信息冻结预算（5000分/天×2天）：测试求租发布', '2026-03-01 00:52:02');
INSERT INTO `wallets_log` VALUES (22, 7, 3, 'task', 2, 2, 300, 190000, 189700, 'task', 5, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-03 11:02:13');
INSERT INTO `wallets_log` VALUES (23, 7, 3, 'task', 2, 2, 600, 189700, 189100, 'task', 6, NULL, NULL, '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-03 11:48:04');
INSERT INTO `wallets_log` VALUES (24, 7, 3, 'task', 2, 2, 300, 189100, 188800, 'task', 7, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-03 12:03:50');
INSERT INTO `wallets_log` VALUES (25, 7, 3, 'task', 2, 2, 1000, 188800, 187800, 'rental_freeze', 3, NULL, NULL, '求租信息冻结预算（1000分/天×1天）：更新求租信息模块。发布测试', '2026-03-03 20:53:18');
INSERT INTO `wallets_log` VALUES (26, 7, 3, 'task', 2, 2, 20000, 187800, 167800, 'rental_freeze', 4, NULL, NULL, '求租信息冻结预算（2000分/天×10天）：测试发布求租信息更新。抖音', '2026-03-03 21:08:53');
INSERT INTO `wallets_log` VALUES (27, 7, 3, 'task', 2, 2, 1000, 167800, 166800, 'rental_freeze', 8, NULL, NULL, '求租信息冻结预算（1000分/天×1天）：发布求租信息更新。抖音', '2026-03-03 21:25:27');
INSERT INTO `wallets_log` VALUES (28, 7, 3, 'task', 2, 2, 600, 166800, 166200, 'task', 8, NULL, NULL, '发布任务【上评评论】2个任务，扣除 ¥6.00', '2026-03-04 00:37:44');
INSERT INTO `wallets_log` VALUES (29, 7, 3, 'task', 2, 2, 900, 166200, 165300, 'task', 9, NULL, NULL, '发布任务【上中评评论】4个任务，扣除 ¥9.00', '2026-03-04 01:00:08');
INSERT INTO `wallets_log` VALUES (30, 1, 1, 'Ceshi', 2, 2, 200, 219700, 219500, 'task', 11, NULL, NULL, '发布任务【中评评论】1个任务，扣除 ¥2.00', '2026-03-04 15:12:11');
INSERT INTO `wallets_log` VALUES (31, 1, 1, 'Ceshi', 2, 2, 900, 219500, 218600, 'task', 12, NULL, NULL, '发布任务【上中评评论】4个任务，扣除 ¥9.00', '2026-03-04 15:50:29');
INSERT INTO `wallets_log` VALUES (32, 8, 5, 'test', 1, 1, 100, 0, 100, 'commission', 4, NULL, NULL, '自动审核通过任务获得佣金，任务ID：4', '2026-03-04 17:33:01');
INSERT INTO `wallets_log` VALUES (33, 1, 1, 'Ceshi', 2, 2, 3000, 218600, 215600, 'task', 9, NULL, NULL, '发布任务【上评评论】10个任务，扣除 ¥30.00', '2026-03-04 20:03:07');
INSERT INTO `wallets_log` VALUES (34, 7, 3, 'task', 2, 2, 600, 165300, 164700, 'task', 15, NULL, NULL, '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-05 00:31:33');
INSERT INTO `wallets_log` VALUES (35, 1, 1, 'Ceshi', 2, 2, 900, 215600, 214700, 'task', 16, NULL, NULL, '发布任务【上评评论】3个任务，扣除 ¥9.00', '2026-03-05 11:53:47');
INSERT INTO `wallets_log` VALUES (36, 1, 1, 'Ceshi', 2, 2, 300, 214700, 214400, 'task', 17, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-05 12:19:22');
INSERT INTO `wallets_log` VALUES (37, 7, 3, 'task', 2, 2, 300, 164700, 164400, 'task', 18, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-05 20:59:37');
INSERT INTO `wallets_log` VALUES (38, 1, 1, 'Ceshi', 2, 2, 900, 214400, 213500, 'task', 19, NULL, NULL, '发布任务【上评评论】3个任务，扣除 ¥9.00', '2026-03-06 11:05:46');
INSERT INTO `wallets_log` VALUES (39, 1, 1, 'Ceshi', 2, 2, 500, 213500, 213000, 'task', 20, NULL, NULL, '发布任务【放大镜搜索词】1个任务，扣除 ¥5.00', '2026-03-06 11:25:44');
INSERT INTO `wallets_log` VALUES (40, 1, 1, 'Ceshi', 2, 2, 500, 213000, 212500, 'task', 21, NULL, NULL, '发布任务【放大镜搜索词】1个任务，扣除 ¥5.00', '2026-03-06 13:06:31');
INSERT INTO `wallets_log` VALUES (41, 2, 2, 'Ceshi1', 2, 2, 2000, 208700, 206700, 'task', 22, NULL, NULL, '发布任务【中评评论】10个任务，扣除 ¥20.00', '2026-03-06 15:01:15');
INSERT INTO `wallets_log` VALUES (42, 8, 5, 'test', 1, 1, 80, 100, 180, 'commission', 22, NULL, NULL, '自动审核通过任务获得佣金，任务ID：22', '2026-03-06 15:15:01');
INSERT INTO `wallets_log` VALUES (43, 7, 3, 'task', 2, 2, 1500, 164400, 162900, 'task', 2, NULL, NULL, '发布放大镜任务【放大镜搜索词】3个任务，扣除 ¥15.00', '2026-03-06 22:40:41');
INSERT INTO `wallets_log` VALUES (44, 7, 3, 'task', 2, 2, 2500, 162900, 160400, 'task', 3, NULL, NULL, '发布放大镜任务【放大镜搜索词】5个任务，扣除 ¥25.00', '2026-03-07 10:28:44');
INSERT INTO `wallets_log` VALUES (45, 1, 1, 'Ceshi', 2, 2, 900, 212500, 211600, 'task', 23, NULL, NULL, '发布任务【上中评评论】4个任务，扣除 ¥9.00', '2026-03-07 10:33:03');
INSERT INTO `wallets_log` VALUES (46, 8, 5, 'test', 1, 1, 100, 180, 280, 'commission', 23, NULL, NULL, '完成任务获得佣金，任务ID：23', '2026-03-07 10:38:37');
INSERT INTO `wallets_log` VALUES (47, 1, 1, 'Ceshi', 2, 2, 500, 211600, 211100, 'task', 25, NULL, NULL, '发布任务【放大镜搜索词】1个任务，扣除 ¥5.00', '2026-03-07 10:42:36');
INSERT INTO `wallets_log` VALUES (48, 1, 1, 'Ceshi', 2, 2, 500, 211100, 210600, 'task', 26, NULL, NULL, '发布任务【放大镜搜索词】1个任务，扣除 ¥5.00', '2026-03-07 10:52:23');
INSERT INTO `wallets_log` VALUES (49, 7, 3, 'task', 2, 2, 300, 160400, 160100, 'task', 27, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 11:24:54');
INSERT INTO `wallets_log` VALUES (50, 8, 5, 'test', 1, 1, 100, 280, 380, 'commission', 27, NULL, NULL, '自动审核通过任务获得佣金，任务ID：27', '2026-03-07 11:36:01');
INSERT INTO `wallets_log` VALUES (51, 7, 3, 'task', 2, 2, 300, 160100, 159800, 'task', 28, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 11:39:29');
INSERT INTO `wallets_log` VALUES (52, 8, 5, 'test', 1, 1, 100, 380, 480, 'commission', 28, NULL, NULL, '自动审核通过任务获得佣金，任务ID：28', '2026-03-07 11:51:01');
INSERT INTO `wallets_log` VALUES (53, 7, 3, 'task', 2, 2, 300, 159800, 159500, 'task', 29, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 12:08:09');
INSERT INTO `wallets_log` VALUES (54, 8, 5, 'test', 1, 1, 100, 480, 580, 'commission', 29, NULL, NULL, '自动审核通过任务获得佣金，任务ID：29', '2026-03-07 12:19:01');
INSERT INTO `wallets_log` VALUES (55, 7, 3, 'task', 2, 2, 300, 159500, 159200, 'task', 30, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 12:23:44');
INSERT INTO `wallets_log` VALUES (56, 8, 5, 'test', 1, 1, 100, 580, 680, 'commission', 30, NULL, NULL, '自动审核通过任务获得佣金，任务ID：30', '2026-03-07 12:34:01');
INSERT INTO `wallets_log` VALUES (57, 7, 3, 'task', 2, 2, 300, 159200, 158900, 'task', 31, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 12:52:23');
INSERT INTO `wallets_log` VALUES (58, 8, 5, 'test', 1, 1, 100, 680, 780, 'commission', 31, NULL, NULL, '自动审核通过任务获得佣金，任务ID：31', '2026-03-07 13:03:01');
INSERT INTO `wallets_log` VALUES (59, 7, 3, 'task', 2, 2, 300, 158900, 158600, 'task', 32, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 13:10:06');
INSERT INTO `wallets_log` VALUES (60, 8, 5, 'test', 1, 1, 100, 780, 880, 'commission', 32, NULL, NULL, '自动审核通过任务获得佣金，任务ID：32', '2026-03-07 13:21:01');
INSERT INTO `wallets_log` VALUES (61, 7, 3, 'task', 2, 2, 300, 158600, 158300, 'task', 33, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 13:40:53');
INSERT INTO `wallets_log` VALUES (62, 8, 5, 'test', 1, 1, 100, 880, 980, 'commission', 33, NULL, NULL, '自动审核通过任务获得佣金，任务ID：33', '2026-03-07 13:52:01');
INSERT INTO `wallets_log` VALUES (63, 7, 3, 'task', 2, 2, 300, 158300, 158000, 'task', 34, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 13:58:39');
INSERT INTO `wallets_log` VALUES (64, 8, 5, 'test', 1, 1, 100, 980, 1080, 'commission', 34, NULL, NULL, '完成任务获得佣金，任务ID：34', '2026-03-07 14:00:18');
INSERT INTO `wallets_log` VALUES (65, 7, 3, 'task', 2, 2, 300, 158000, 157700, 'task', 35, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 14:06:14');
INSERT INTO `wallets_log` VALUES (66, 8, 5, 'test', 1, 1, 100, 1080, 1180, 'commission', 35, NULL, NULL, '自动审核通过任务获得佣金，任务ID：35', '2026-03-07 14:17:01');
INSERT INTO `wallets_log` VALUES (67, 7, 3, 'task', 2, 2, 300, 157700, 157400, 'task', 36, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 14:22:14');
INSERT INTO `wallets_log` VALUES (68, 8, 5, 'test', 1, 1, 100, 1180, 1280, 'commission', 36, NULL, NULL, '自动审核通过任务获得佣金，任务ID：36', '2026-03-07 14:33:01');
INSERT INTO `wallets_log` VALUES (69, 7, 3, 'task', 2, 2, 300, 157400, 157100, 'task', 37, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 14:34:59');
INSERT INTO `wallets_log` VALUES (70, 8, 5, 'test', 1, 1, 100, 1280, 1380, 'commission', 37, NULL, NULL, '自动审核通过任务获得佣金，任务ID：37', '2026-03-07 14:46:01');
INSERT INTO `wallets_log` VALUES (71, 7, 3, 'task', 2, 2, 300, 157100, 156800, 'task', 38, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 14:46:27');
INSERT INTO `wallets_log` VALUES (72, 8, 5, 'test', 1, 1, 100, 1380, 1480, 'commission', 38, NULL, NULL, '自动审核通过任务获得佣金，任务ID：38', '2026-03-07 14:58:01');
INSERT INTO `wallets_log` VALUES (73, 7, 3, 'task', 2, 2, 300, 156800, 156500, 'task', 39, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 15:04:27');
INSERT INTO `wallets_log` VALUES (74, 8, 5, 'test', 1, 1, 100, 1480, 1580, 'commission', 39, NULL, NULL, '自动审核通过任务获得佣金，任务ID：39', '2026-03-07 15:21:01');
INSERT INTO `wallets_log` VALUES (75, 7, 3, 'task', 2, 2, 300, 156500, 156200, 'task', 40, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 15:58:47');
INSERT INTO `wallets_log` VALUES (76, 8, 5, 'test', 1, 1, 100, 1580, 1680, 'commission', 40, NULL, NULL, '自动审核通过任务获得佣金，任务ID：40', '2026-03-07 16:09:01');
INSERT INTO `wallets_log` VALUES (77, 7, 3, 'task', 2, 2, 300, 156200, 155900, 'task', 41, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 17:30:09');
INSERT INTO `wallets_log` VALUES (78, 8, 5, 'test', 1, 1, 100, 1680, 1780, 'commission', 41, NULL, NULL, '完成任务获得佣金，任务ID：41', '2026-03-07 17:34:54');
INSERT INTO `wallets_log` VALUES (79, 7, 3, 'task', 2, 2, 300, 155900, 155600, 'task', 42, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-07 22:53:01');
INSERT INTO `wallets_log` VALUES (80, 8, 5, 'test', 1, 1, 100, 1780, 1880, 'commission', 42, NULL, NULL, '自动审核通过任务获得佣金，任务ID：42', '2026-03-07 23:12:01');
INSERT INTO `wallets_log` VALUES (81, 11, 5, 'Ceshi3', 2, 1, 0, 0, 0, 'recharge', 8, NULL, NULL, '充值 ¥1,000.00（alipay），审核中', '2026-03-08 12:35:07');
INSERT INTO `wallets_log` VALUES (82, 11, 5, 'Ceshi3', 2, 1, 0, 0, 0, 'recharge', 9, NULL, NULL, '充值 ¥1,000.00（alipay），审核中', '2026-03-08 12:44:28');
INSERT INTO `wallets_log` VALUES (83, 11, 5, 'Ceshi3', 2, 1, 100000, 0, 100000, 'recharge', 9, NULL, NULL, '充值到账：¥1,000.00', '2026-03-08 13:01:11');
INSERT INTO `wallets_log` VALUES (84, 2, 2, 'Ceshi1', 2, 2, 600, 206700, 206100, 'task', 43, NULL, NULL, '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-08 13:36:57');
INSERT INTO `wallets_log` VALUES (85, 1, 1, 'Ceshi', 2, 2, 900, 210600, 209700, 'task', 44, NULL, NULL, '发布任务【上评评论】3个任务，扣除 ¥9.00', '2026-03-08 13:38:15');
INSERT INTO `wallets_log` VALUES (86, 2, 2, 'Ceshi1', 2, 2, 500, 206100, 205600, 'task', 4, NULL, NULL, '发布放大镜任务【放大镜搜索词】1个任务，扣除 ¥5.00', '2026-03-08 13:45:14');
INSERT INTO `wallets_log` VALUES (87, 1, 1, 'Ceshi', 2, 2, 600, 209700, 209100, 'task', 45, NULL, NULL, '发布任务【中下评评论】2个任务，扣除 ¥6.00', '2026-03-08 13:46:30');
INSERT INTO `wallets_log` VALUES (88, 8, 5, 'test', 1, 1, 100, 1880, 1980, 'commission', 44, NULL, NULL, '自动审核通过任务获得佣金，任务ID：44', '2026-03-08 14:09:01');
INSERT INTO `wallets_log` VALUES (89, 11, 5, 'Ceshi3', 2, 1, 100000, 100000, 200000, 'recharge', 8, NULL, NULL, '充值到账：¥1,000.00', '2026-03-09 20:33:00');
INSERT INTO `wallets_log` VALUES (90, 7, 3, 'task', 2, 1, 0, 155600, 155600, 'recharge', 10, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-03-09 21:19:27');
INSERT INTO `wallets_log` VALUES (91, 7, 3, 'task', 2, 1, 20000, 155600, 175600, 'recharge', 10, NULL, NULL, '充值到账：¥200.00', '2026-03-09 21:29:10');
INSERT INTO `wallets_log` VALUES (92, 1, 1, 'Ceshi', 2, 2, 900, 209100, 208200, 'task', 47, NULL, NULL, '发布任务【上评评论】3个任务，扣除 ¥9.00', '2026-03-11 11:42:44');
INSERT INTO `wallets_log` VALUES (93, 1, 1, 'Ceshi', 2, 2, 300, 208200, 207900, 'task', 48, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-11 11:57:14');
INSERT INTO `wallets_log` VALUES (94, 1, 1, 'Ceshi', 2, 2, 600, 207900, 207300, 'task', 49, NULL, NULL, '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-11 11:58:24');
INSERT INTO `wallets_log` VALUES (95, 23, 18, 'xiaoya', 1, 1, 100, 0, 100, 'commission', 7, NULL, NULL, '自动审核通过任务获得佣金，任务ID：7', '2026-03-11 12:51:01');
INSERT INTO `wallets_log` VALUES (96, 8, 5, 'test', 1, 1, 50, 1980, 2030, 'agent_commission', 7, NULL, NULL, '下级用户 xiaoya 完成任务，获得一级团长佣金，任务ID：7', '2026-03-11 12:51:01');
INSERT INTO `wallets_log` VALUES (97, 8, 5, 'test', 1, 2, 1000, 2030, 1030, 'withdraw', 1, NULL, NULL, '提现申请 ¥10.00，手续费 ¥0.30，实到 ¥9.70，收款方式：alipay，审核中', '2026-03-11 15:24:50');
INSERT INTO `wallets_log` VALUES (98, 4, 2, 'Ceshi', 1, 1, 100, 0, 100, 'commission', 5, NULL, NULL, '自动审核通过任务获得佣金，任务ID：5', '2026-03-11 15:50:01');
INSERT INTO `wallets_log` VALUES (99, 7, 3, 'task', 2, 2, 300, 175600, 175300, 'task', 50, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-11 15:51:37');
INSERT INTO `wallets_log` VALUES (100, 4, 2, 'Ceshi', 1, 1, 80, 100, 180, 'commission', 6, NULL, NULL, '自动审核通过任务获得佣金，任务ID：6', '2026-03-11 15:59:02');
INSERT INTO `wallets_log` VALUES (101, 4, 2, 'Ceshi', 1, 1, 100, 180, 280, 'commission', 50, NULL, NULL, '自动审核通过任务获得佣金，任务ID：50', '2026-03-11 16:05:02');
INSERT INTO `wallets_log` VALUES (102, 23, 18, 'xiaoya', 1, 1, 80, 100, 180, 'commission', 6, NULL, NULL, '自动审核通过任务获得佣金，任务ID：6', '2026-03-11 17:09:01');
INSERT INTO `wallets_log` VALUES (103, 8, 5, 'test', 1, 1, 30, 1030, 1060, 'agent_commission', 6, NULL, NULL, '下级用户 xiaoya 完成任务，获得一级团长佣金，任务ID：6', '2026-03-11 17:09:01');
INSERT INTO `wallets_log` VALUES (104, 7, 3, 'task', 2, 1, 0, 175300, 175300, 'recharge', 11, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-03-11 22:39:40');
INSERT INTO `wallets_log` VALUES (105, 7, 3, 'task', 2, 1, 0, 175300, 175300, 'recharge', 12, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-03-11 22:59:27');
INSERT INTO `wallets_log` VALUES (106, 7, 3, 'task', 2, 2, 1000, 175300, 174300, 'task', 5, NULL, NULL, '发布放大镜任务【放大镜搜索词】2个任务，扣除 ¥10.00', '2026-03-11 23:56:02');
INSERT INTO `wallets_log` VALUES (107, 7, 3, 'task', 2, 2, 300, 174300, 174000, 'task', 51, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 10:27:10');
INSERT INTO `wallets_log` VALUES (108, 7, 3, 'task', 2, 2, 300, 174000, 173700, 'task', 52, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 10:31:44');
INSERT INTO `wallets_log` VALUES (109, 7, 3, 'task', 2, 2, 300, 173700, 173400, 'task', 53, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 10:31:46');
INSERT INTO `wallets_log` VALUES (110, 7, 3, 'task', 2, 2, 300, 173400, 173100, 'task', 54, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 10:31:49');
INSERT INTO `wallets_log` VALUES (111, 7, 3, 'task', 2, 2, 300, 173100, 172800, 'task', 55, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 10:31:52');
INSERT INTO `wallets_log` VALUES (112, 7, 3, 'task', 2, 2, 300, 172800, 172500, 'task', 56, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 10:32:10');
INSERT INTO `wallets_log` VALUES (113, 8, 5, 'test', 1, 1, 240, 1060, 1300, 'commission', 51, NULL, NULL, '自动审核通过任务获得佣金，任务ID：51', '2026-03-12 10:49:48');
INSERT INTO `wallets_log` VALUES (114, 8, 5, 'test', 1, 1, 240, 1300, 1540, 'commission', 52, NULL, NULL, '自动审核通过任务获得佣金，任务ID：52', '2026-03-12 10:58:39');
INSERT INTO `wallets_log` VALUES (115, 8, 5, 'test', 1, 1, 240, 1540, 1780, 'commission', 53, NULL, NULL, '自动审核通过任务获得佣金，任务ID：53', '2026-03-12 11:07:31');
INSERT INTO `wallets_log` VALUES (116, 8, 5, 'test', 1, 1, 240, 1780, 2020, 'commission', 54, NULL, NULL, '自动审核通过任务获得佣金，任务ID：54', '2026-03-12 11:10:03');
INSERT INTO `wallets_log` VALUES (117, 24, 19, 'test1', 1, 1, 100, 0, 100, 'commission', 55, NULL, NULL, '自动审核通过任务获得佣金，任务ID：55', '2026-03-12 11:19:54');
INSERT INTO `wallets_log` VALUES (118, 8, 5, 'test', 1, 1, 240, 2020, 2260, 'agent_commission', 55, NULL, NULL, '下级用户 test1 完成任务，获得一级团长佣金，任务ID：55', '2026-03-12 11:19:54');
INSERT INTO `wallets_log` VALUES (119, 24, 19, 'test1', 1, 1, 100, 100, 200, 'commission', 56, NULL, NULL, '自动审核通过任务获得佣金，任务ID：56', '2026-03-12 11:26:32');
INSERT INTO `wallets_log` VALUES (120, 8, 5, 'test', 1, 1, 240, 2260, 2500, 'agent_commission', 56, NULL, NULL, '下级用户 test1是大团团长 完成任务，获得一级团长佣金，任务ID：56', '2026-03-12 11:26:32');
INSERT INTO `wallets_log` VALUES (121, 7, 3, 'task', 2, 2, 300, 172500, 172200, 'task', 57, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 11:28:02');
INSERT INTO `wallets_log` VALUES (122, 7, 3, 'task', 2, 2, 300, 172200, 171900, 'task', 58, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 11:28:03');
INSERT INTO `wallets_log` VALUES (123, 7, 3, 'task', 2, 2, 300, 171900, 171600, 'task', 59, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 11:28:05');
INSERT INTO `wallets_log` VALUES (124, 24, 19, 'test1', 1, 1, 100, 200, 300, 'commission', 57, NULL, NULL, '自动审核通过任务获得佣金，任务ID：57', '2026-03-12 11:30:13');
INSERT INTO `wallets_log` VALUES (125, 8, 5, 'test', 1, 1, 240, 2500, 2740, 'agent_commission', 57, NULL, NULL, '下级用户 test1是大团团长 完成任务，获得一级团长佣金，任务ID：57', '2026-03-12 11:30:13');
INSERT INTO `wallets_log` VALUES (126, 30, 25, 'test7', 1, 1, 100, 0, 100, 'commission', 58, NULL, NULL, '自动审核通过任务获得佣金，任务ID：58', '2026-03-12 11:32:04');
INSERT INTO `wallets_log` VALUES (127, 24, 19, 'test1', 1, 1, 50, 300, 350, 'agent_commission', 58, NULL, NULL, '下级用户 test7是普通团长 完成任务，获得普通团长佣金，任务ID：58', '2026-03-12 11:32:04');
INSERT INTO `wallets_log` VALUES (128, 8, 5, 'test', 1, 1, 240, 2740, 2980, 'second_agent_commission', 58, NULL, NULL, '下级用户 test1 的团队成员完成任务，获得二级团长佣金，任务ID：58', '2026-03-12 11:32:04');
INSERT INTO `wallets_log` VALUES (129, 31, 26, 'test8', 1, 1, 100, 0, 100, 'commission', 59, NULL, NULL, '自动审核通过任务获得佣金，任务ID：59', '2026-03-12 11:37:36');
INSERT INTO `wallets_log` VALUES (130, 25, 20, 'test2', 1, 1, 50, 0, 50, 'agent_commission', 59, NULL, NULL, '下级用户 test8是高级团长 完成任务，获得高级团长佣金，任务ID：59', '2026-03-12 11:37:36');
INSERT INTO `wallets_log` VALUES (131, 8, 5, 'test', 1, 1, 240, 2980, 3220, 'second_agent_commission', 59, NULL, NULL, '下级用户 test2 的团队成员完成任务，获得二级团长佣金，任务ID：59', '2026-03-12 11:37:36');
INSERT INTO `wallets_log` VALUES (132, 7, 3, 'task', 2, 2, 300, 171600, 171300, 'task', 60, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 14:31:30');
INSERT INTO `wallets_log` VALUES (133, 32, 27, 'test89', 1, 1, 100, 0, 100, 'commission', 60, NULL, NULL, '自动审核通过任务获得佣金，任务ID：60', '2026-03-12 14:42:45');
INSERT INTO `wallets_log` VALUES (134, 31, 26, 'test8', 1, 1, 50, 100, 150, 'agent_commission', 60, NULL, NULL, '下级用户 test89是普通团长 完成任务，获得普通团长佣金，任务ID：60', '2026-03-12 14:42:45');
INSERT INTO `wallets_log` VALUES (135, 25, 20, 'test2', 1, 1, 50, 50, 100, 'second_agent_commission', 60, NULL, NULL, '下级用户 test8 的团队成员完成任务，获得二级团长佣金，任务ID：60', '2026-03-12 14:42:45');
INSERT INTO `wallets_log` VALUES (136, 7, 3, 'task', 2, 2, 300, 171300, 171000, 'task', 61, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 14:48:57');
INSERT INTO `wallets_log` VALUES (137, 7, 3, 'task', 2, 2, 300, 171000, 170700, 'task', 62, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 14:48:59');
INSERT INTO `wallets_log` VALUES (138, 7, 3, 'task', 2, 2, 300, 170700, 170400, 'task', 63, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 14:49:00');
INSERT INTO `wallets_log` VALUES (139, 7, 3, 'task', 2, 2, 300, 170400, 170100, 'task', 64, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 14:49:01');
INSERT INTO `wallets_log` VALUES (140, 7, 3, 'task', 2, 2, 300, 170100, 169800, 'task', 65, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-12 14:49:02');
INSERT INTO `wallets_log` VALUES (141, 32, 27, 'test9', 1, 1, 100, 100, 200, 'commission', 61, NULL, NULL, '完成任务获得佣金，任务ID：61', '2026-03-12 14:51:39');
INSERT INTO `wallets_log` VALUES (142, 31, 26, 'test8', 1, 1, 50, 150, 200, 'agent_commission', 61, NULL, NULL, '下级用户 test9 完成任务，获得一级团长佣金，任务ID：61', '2026-03-12 14:51:39');
INSERT INTO `wallets_log` VALUES (143, 25, 20, 'test2', 1, 1, 50, 100, 150, 'second_agent_commission', 61, NULL, NULL, '下级用户 test8 的团队成员完成任务，获得二级团长佣金，任务ID：61', '2026-03-12 14:51:39');
INSERT INTO `wallets_log` VALUES (144, 31, 26, 'test8', 1, 1, 100, 200, 300, 'commission', 62, NULL, NULL, '完成任务获得佣金，任务ID：62', '2026-03-12 14:53:44');
INSERT INTO `wallets_log` VALUES (145, 25, 20, 'test2', 1, 1, 50, 150, 200, 'agent_commission', 62, NULL, NULL, '下级用户 test8 完成任务，获得一级团长佣金，任务ID：62', '2026-03-12 14:53:44');
INSERT INTO `wallets_log` VALUES (146, 8, 5, 'test', 1, 1, 240, 3220, 3460, 'second_agent_commission', 62, NULL, NULL, '下级用户 test2 的团队成员完成任务，获得二级团长佣金，任务ID：62', '2026-03-12 14:53:44');
INSERT INTO `wallets_log` VALUES (147, 25, 20, 'test2', 1, 1, 100, 200, 300, 'commission', 63, NULL, NULL, '完成任务获得佣金，任务ID：63', '2026-03-12 14:55:49');
INSERT INTO `wallets_log` VALUES (148, 8, 5, 'test', 1, 1, 240, 3460, 3700, 'agent_commission', 63, NULL, NULL, '下级用户 test2 完成任务，获得一级团长佣金，任务ID：63', '2026-03-12 14:55:49');
INSERT INTO `wallets_log` VALUES (149, 8, 5, 'test', 1, 1, 240, 3700, 3940, 'commission', 64, NULL, NULL, '完成任务获得佣金，任务ID：64', '2026-03-12 14:59:04');
INSERT INTO `wallets_log` VALUES (150, 8, 5, 'test', 1, 2, 1000, 3940, 2940, 'withdraw', 2, NULL, NULL, '提现申请 ¥10.00，手续费 ¥0.30，实到 ¥9.70，收款方式：alipay，审核中', '2026-03-12 14:59:54');
INSERT INTO `wallets_log` VALUES (151, 25, 20, 'test2', 1, 2, 100, 300, 200, 'withdraw', 3, NULL, NULL, '提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中', '2026-03-12 15:00:49');
INSERT INTO `wallets_log` VALUES (152, 31, 26, 'test8', 1, 2, 100, 300, 200, 'withdraw', 4, NULL, NULL, '提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中', '2026-03-12 15:01:26');
INSERT INTO `wallets_log` VALUES (153, 32, 27, 'test9', 1, 2, 100, 200, 100, 'withdraw', 5, NULL, NULL, '提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中', '2026-03-12 15:48:30');
INSERT INTO `wallets_log` VALUES (154, 8, 5, 'test', 1, 2, 100, 2940, 2840, 'withdraw', 6, NULL, NULL, '提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中', '2026-03-12 15:49:08');
INSERT INTO `wallets_log` VALUES (155, 4, 2, 'Ceshi', 1, 2, 100, 280, 180, 'withdraw', 7, NULL, NULL, '提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中', '2026-03-12 15:49:30');
INSERT INTO `wallets_log` VALUES (156, 7, 3, 'task', 2, 1, 0, 169800, 169800, 'recharge', 13, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-03-12 15:52:31');
INSERT INTO `wallets_log` VALUES (157, 7, 3, 'task', 2, 2, 1000, 169800, 168800, 'task', 6, NULL, NULL, '发布放大镜任务【放大镜搜索词】2个任务，扣除 ¥10.00', '2026-03-12 16:45:26');
INSERT INTO `wallets_log` VALUES (158, 7, 3, 'task', 2, 2, 1000, 168800, 167800, 'task', 7, NULL, NULL, '发布放大镜任务【放大镜搜索词】2个任务，扣除 ¥10.00', '2026-03-12 16:47:08');
INSERT INTO `wallets_log` VALUES (159, 7, 3, 'task', 2, 2, 1000, 167800, 166800, 'task', 8, NULL, NULL, '发布放大镜任务【放大镜搜索词】2个任务，扣除 ¥10.00', '2026-03-13 11:11:22');
INSERT INTO `wallets_log` VALUES (160, 7, 3, 'task', 2, 2, 1000, 166800, 165800, 'task', 9, 3, '放大镜搜索词', '发布放大镜任务【放大镜搜索词】2个任务，扣除 ¥10.00', '2026-03-13 11:13:36');
INSERT INTO `wallets_log` VALUES (161, 7, 3, 'task', 2, 2, 300, 165800, 165500, 'task', 66, NULL, NULL, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-13 11:14:06');
INSERT INTO `wallets_log` VALUES (162, 31, 26, 'test8', 1, 1, 100, 200, 300, 'commission', 65, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：65', '2026-03-13 11:17:15');
INSERT INTO `wallets_log` VALUES (163, 25, 20, 'test2', 1, 1, 50, 200, 250, 'agent_commission', 65, 1, '上评评论', '下级用户 test8是高级团长 完成任务，获得高级团长佣金，任务ID：65', '2026-03-13 11:17:15');
INSERT INTO `wallets_log` VALUES (164, 8, 5, 'test', 1, 1, 240, 2840, 3080, 'second_agent_commission', 65, 1, '上评评论', '下级用户 test2 的团队成员完成任务，获得二级团长佣金，任务ID：65', '2026-03-13 11:17:15');
INSERT INTO `wallets_log` VALUES (165, 7, 3, 'task', 2, 2, 300, 165500, 165200, 'task', 67, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-13 11:24:10');
INSERT INTO `wallets_log` VALUES (166, 7, 3, 'task', 2, 1, 20000, 165200, 185200, 'recharge', 13, NULL, NULL, '充值到账：¥200.00', '2026-03-13 22:54:19');
INSERT INTO `wallets_log` VALUES (167, 7, 3, 'task', 2, 1, 20000, 185200, 205200, 'recharge', 11, NULL, NULL, '充值到账：¥200.00', '2026-03-13 22:54:20');
INSERT INTO `wallets_log` VALUES (168, 7, 3, 'task', 2, 1, 20000, 205200, 225200, 'recharge', 12, NULL, NULL, '充值到账：¥200.00', '2026-03-13 22:54:22');
INSERT INTO `wallets_log` VALUES (169, 7, 3, 'task', 2, 1, 0, 225200, 225200, 'recharge', 14, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-03-14 16:40:58');
INSERT INTO `wallets_log` VALUES (170, 7, 3, 'task', 2, 1, 20000, 225200, 245200, 'recharge', 14, NULL, NULL, '充值到账：¥200.00', '2026-03-14 16:44:32');
INSERT INTO `wallets_log` VALUES (171, 4, 2, 'Ceshi', 1, 2, 0, 180, 180, 'withdraw', 7, NULL, NULL, '提现审核通过：¥1.00', '2026-03-14 16:56:20');
INSERT INTO `wallets_log` VALUES (172, 8, 5, 'test', 1, 2, 0, 3080, 3080, 'withdraw', 6, NULL, NULL, '提现审核通过：¥1.00', '2026-03-14 16:56:22');
INSERT INTO `wallets_log` VALUES (173, 32, 27, 'test9', 1, 2, 0, 100, 100, 'withdraw', 5, NULL, NULL, '提现审核通过：¥1.00', '2026-03-14 16:56:24');
INSERT INTO `wallets_log` VALUES (174, 31, 26, 'test8', 1, 2, 0, 300, 300, 'withdraw', 4, NULL, NULL, '提现审核通过：¥1.00', '2026-03-14 16:56:26');
INSERT INTO `wallets_log` VALUES (175, 8, 5, 'test', 1, 2, 0, 3080, 3080, 'withdraw', 2, NULL, NULL, '提现审核通过：¥10.00', '2026-03-14 16:56:28');
INSERT INTO `wallets_log` VALUES (176, 25, 20, 'test2', 1, 2, 0, 250, 250, 'withdraw', 3, NULL, NULL, '提现审核通过：¥1.00', '2026-03-14 16:56:30');
INSERT INTO `wallets_log` VALUES (177, 8, 5, 'test', 1, 1, 1000, 3080, 4080, 'withdraw', 1, NULL, NULL, '提现申请被拒绝，退款：¥10.00', '2026-03-14 16:56:50');
INSERT INTO `wallets_log` VALUES (178, 7, 3, 'task', 2, 1, 0, 245200, 245200, 'recharge', 15, NULL, NULL, '充值 ¥200.00（alipay），审核中', '2026-03-14 20:21:03');
INSERT INTO `wallets_log` VALUES (179, 7, 3, 'task', 2, 2, 300, 245200, 244900, 'task', 68, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-14 20:21:11');
INSERT INTO `wallets_log` VALUES (180, 7, 3, 'task', 2, 2, 600, 244900, 244300, 'task', 69, 2, '中评评论', '发布任务【中评评论】3个任务，扣除 ¥6.00', '2026-03-14 20:22:05');
INSERT INTO `wallets_log` VALUES (181, 7, 3, 'task', 2, 2, 900, 244300, 243400, 'task', 70, 4, '上中评评论', '发布任务【上中评评论】4个任务，扣除 ¥9.00', '2026-03-14 20:22:55');
INSERT INTO `wallets_log` VALUES (182, 7, 3, 'task', 2, 2, 600, 243400, 242800, 'task', 72, 5, '中下评评论', '发布任务【中下评评论】2个任务，扣除 ¥6.00', '2026-03-14 20:23:08');
INSERT INTO `wallets_log` VALUES (183, 7, 3, 'task', 2, 2, 1000, 242800, 241800, 'task', 10, 3, '放大镜搜索词', '发布放大镜任务【放大镜搜索词】2个任务，扣除 ¥10.00', '2026-03-14 20:23:29');
INSERT INTO `wallets_log` VALUES (184, 7, 3, 'task', 2, 2, 35000, 241800, 206800, 'rental_order_pay', 1, 6, '出租订单', '租赁订单支付：测试租赁系统的新功能，佣金结算（7天）', '2026-03-14 20:24:49');
INSERT INTO `wallets_log` VALUES (185, 8, 5, 'test', 1, 2, 0, 0, 0, 'rental_order_pending', 1, 6, '出租订单', '租赁订单已创建，待客服处理：测试租赁系统的新功能，佣金结算（7天，预计收益：24500）', '2026-03-14 20:24:49');
INSERT INTO `wallets_log` VALUES (186, 7, 3, 'task', 2, 1, 20000, 206800, 226800, 'recharge', 15, NULL, NULL, '充值到账：¥200.00', '2026-03-14 20:25:32');
INSERT INTO `wallets_log` VALUES (187, 8, 5, 'test', 1, 1, 240, 4080, 4320, 'commission', 66, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：66', '2026-03-14 21:07:06');
INSERT INTO `wallets_log` VALUES (188, 8, 5, 'test', 1, 1, 240, 4320, 4560, 'commission', 67, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：67', '2026-03-14 21:09:08');
INSERT INTO `wallets_log` VALUES (189, 8, 5, 'test', 1, 1, 240, 4560, 4800, 'commission', 68, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：68', '2026-03-14 21:09:08');
INSERT INTO `wallets_log` VALUES (190, 8, 5, 'test', 1, 1, 160, 4800, 4960, 'commission', 69, 2, '中评评论', '自动审核通过任务获得佣金，任务ID：69', '2026-03-14 21:09:08');
INSERT INTO `wallets_log` VALUES (191, 8, 5, 'test', 1, 1, 240, 4960, 5200, 'commission', 70, 4, '上中评评论', '自动审核通过任务获得佣金，任务ID：70', '2026-03-14 21:09:08');
INSERT INTO `wallets_log` VALUES (192, 8, 5, 'test', 1, 1, 240, 5200, 5440, 'commission', 72, 5, '中下评评论', '自动审核通过任务获得佣金，任务ID：72', '2026-03-14 21:09:08');
INSERT INTO `wallets_log` VALUES (193, 8, 5, 'test', 1, 2, 1000, 5440, 4440, 'withdraw', 0, NULL, NULL, '提现申请 ¥10.00，手续费 ¥0.30，实到 ¥9.70，收款方式：alipay，审核中', '2026-03-14 21:12:40');
INSERT INTO `wallets_log` VALUES (194, 7, 3, 'task', 2, 2, 300, 226800, 226500, 'task', 74, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-14 21:19:09');
INSERT INTO `wallets_log` VALUES (195, 8, 5, 'test', 1, 1, 240, 4440, 4680, 'commission', 74, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：74', '2026-03-14 21:21:07');
INSERT INTO `wallets_log` VALUES (196, 7, 3, 'task', 2, 2, 300, 226500, 226200, 'task', 75, 1, '上评评论', '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-14 21:21:45');
INSERT INTO `wallets_log` VALUES (197, 31, 26, 'test8', 1, 1, 100, 300, 400, 'commission', 75, 1, '上评评论', '自动审核通过任务获得佣金，任务ID：75', '2026-03-14 21:24:48');
INSERT INTO `wallets_log` VALUES (198, 25, 20, 'test2', 1, 1, 50, 250, 300, 'agent_commission', 75, 1, '上评评论', '下级用户 test8是高级团长 完成任务，获得高级团长佣金，任务ID：75', '2026-03-14 21:24:48');
INSERT INTO `wallets_log` VALUES (199, 8, 5, 'test', 1, 1, 240, 4680, 4920, 'second_agent_commission', 75, 1, '上评评论', '下级用户 test2 的团队成员完成任务，获得二级团长佣金，任务ID：75', '2026-03-14 21:24:48');
INSERT INTO `wallets_log` VALUES (200, 8, 5, 'test', 1, 2, 0, 4920, 4920, 'withdraw', 8, NULL, NULL, '提现审核通过：¥10.00', '2026-03-14 21:30:25');
INSERT INTO `wallets_log` VALUES (201, 8, 5, 'test', 1, 2, 300, 4920, 4620, 'withdraw', 0, NULL, NULL, '提现申请 ¥3.00，手续费 ¥0.09，实到 ¥2.91，收款方式：alipay，审核中', '2026-03-14 21:35:04');
INSERT INTO `wallets_log` VALUES (202, 8, 5, 'test', 1, 1, 24500, 4620, 29120, 'rental_order_settlement', 1, NULL, NULL, '租赁订单结算收益（订单#1）', '2026-03-14 21:40:59');
INSERT INTO `wallets_log` VALUES (203, 8, 5, 'test', 1, 2, 0, 29120, 29120, 'withdraw', 9, NULL, NULL, '提现审核通过：¥3.00', '2026-03-14 22:18:13');
INSERT INTO `wallets_log` VALUES (204, 7, 3, 'task', 2, 2, 30000, 226200, 196200, 'rental_freeze', 6, NULL, NULL, '求租信息冻结预算（2000分/天×15天）：测试求租发布', '2026-03-14 22:20:28');
INSERT INTO `wallets_log` VALUES (205, 7, 3, 'task', 2, 2, 25000, 196200, 171200, 'rental_order_pay', 2, 6, '出租订单', '租赁订单支付：测试租赁系统的新功能，佣金结算（5天）', '2026-03-14 22:23:22');
INSERT INTO `wallets_log` VALUES (206, 31, 26, 'test8', 1, 2, 0, 0, 0, 'rental_order_pending', 2, 6, '出租订单', '租赁订单已创建，待客服处理：测试租赁系统的新功能，佣金结算（5天，预计收益：17500）', '2026-03-14 22:23:22');
INSERT INTO `wallets_log` VALUES (207, 5, 3, 'Ceshi2', 2, 2, 0, 0, 0, 'rental_order_pay', 3, NULL, NULL, '求租订单已创建：测试求租发布（冻结金额转入订单：2000）', '2026-03-14 22:24:31');
INSERT INTO `wallets_log` VALUES (208, 31, 26, 'test8', 1, 2, 0, 0, 0, 'rental_order_pending', 3, NULL, NULL, '租赁订单已创建，待客服处理：测试求租发布（预计收益：1400）', '2026-03-14 22:24:31');
INSERT INTO `wallets_log` VALUES (209, 31, 26, 'test8', 1, 1, 17500, 400, 17900, 'rental_order_settlement', 2, NULL, NULL, '租赁订单结算收益（订单#2）', '2026-03-14 22:31:31');
INSERT INTO `wallets_log` VALUES (210, 25, 20, 'test2', 1, 1, 1250, 300, 1550, 'rental_agent_commission', 2, NULL, NULL, '租赁订单团长佣金（订单#2）', '2026-03-14 22:31:31');
INSERT INTO `wallets_log` VALUES (211, 31, 26, 'test8', 1, 1, 1400, 17900, 19300, 'rental_order_settlement', 3, NULL, NULL, '租赁订单结算收益（订单#3）', '2026-03-14 22:33:28');
INSERT INTO `wallets_log` VALUES (212, 25, 20, 'test2', 1, 1, 100, 1550, 1650, 'rental_agent_commission', 3, NULL, NULL, '租赁订单团长佣金（订单#3）', '2026-03-14 22:33:28');

SET FOREIGN_KEY_CHECKS = 1;
