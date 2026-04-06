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

 Date: 06/04/2026 22:44:17
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for notifications
-- ----------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '通知ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知内容',
  `target_type` tinyint NOT NULL DEFAULT 0 COMMENT '目标类型：0=全体，1=C端全体，2=B端全体，3=指定用户',
  `target_user_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '目标用户ID（target_type=3时使用）',
  `target_user_type` tinyint NULL DEFAULT NULL COMMENT '目标用户类型（target_type=3时使用，1=C端，2=B端）',
  `sender_type` tinyint NOT NULL DEFAULT 3 COMMENT '发送者类型：1=系统自动，3=Admin',
  `sender_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '发送者ID（Admin ID，预留字段）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_target_type`(`target_type` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 137 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统通知表-通知模板' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of notifications
-- ----------------------------
INSERT INTO `notifications` VALUES (93, '充值审核通过', '您的充值申请已审核通过，金额：¥10,000.00 已到账。感谢您的使用！', 3, 6, 2, 1, NULL, '2026-03-18 15:55:15');
INSERT INTO `notifications` VALUES (94, '收到新的租赁订单', '您的出租「测试租赁系统的新功能，佣金结算」收到新订单，租期10天，等待客服处理', 3, 112, 1, 1, NULL, '2026-03-18 22:31:41');
INSERT INTO `notifications` VALUES (95, '租赁订单支付成功', '您租赁的「测试租赁系统的新功能，佣金结算」已支付成功，等待客服处理', 3, 6, 2, 1, NULL, '2026-03-18 22:31:41');
INSERT INTO `notifications` VALUES (96, '租赁订单已开始', '您租用的订单 #4 已开始执行，租期 10 天，到期时间：2026-03-28 23:34:21', 3, 6, 2, 1, NULL, '2026-03-18 23:34:21');
INSERT INTO `notifications` VALUES (97, '租赁订单已开始', '您出租的订单 #4 已开始执行，租期 10 天，到期时间：2026-03-28 23:34:21', 3, 112, 1, 1, NULL, '2026-03-18 23:34:21');
INSERT INTO `notifications` VALUES (98, '收到新的租赁订单', '您的出租「测试租赁系统的新功能，佣金结算」收到新订单，租期10天，等待客服处理', 3, 112, 1, 1, NULL, '2026-03-18 23:40:18');
INSERT INTO `notifications` VALUES (99, '租赁订单支付成功', '您租赁的「测试租赁系统的新功能，佣金结算」已支付成功，等待客服处理', 3, 6, 2, 1, NULL, '2026-03-18 23:40:18');
INSERT INTO `notifications` VALUES (100, '租赁订单已开始', '您租用的订单 #5 已开始执行，租期 10 天，到期时间：2026-03-28 23:40:30', 3, 6, 2, 1, NULL, '2026-03-18 23:40:30');
INSERT INTO `notifications` VALUES (101, '租赁订单已开始', '您出租的订单 #5 已开始执行，租期 10 天，到期时间：2026-03-28 23:40:30', 3, 112, 1, 1, NULL, '2026-03-18 23:40:30');
INSERT INTO `notifications` VALUES (102, '租赁订单已完成', '您出租的订单 #4 已完成，收益 ¥70.00 已到账', 3, 112, 1, 1, NULL, '2026-03-18 23:42:12');
INSERT INTO `notifications` VALUES (103, '租赁订单已完成', '您租用的订单 #4 已到期完成，感谢使用', 3, 6, 2, 1, NULL, '2026-03-18 23:42:12');
INSERT INTO `notifications` VALUES (104, '租赁订单已终止并退款', '您租用的订单 #5 已被客服终止，已退款 ¥40.00 至您的钱包。', 3, 6, 2, 1, NULL, '2026-03-18 23:52:01');
INSERT INTO `notifications` VALUES (105, '租赁订单已终止并结算', '您出租的订单 #5 已被客服终止，已结算 ¥60.00 至您的钱包，已退款 ¥40.00 给买家。', 3, 112, 1, 1, NULL, '2026-03-18 23:52:01');
INSERT INTO `notifications` VALUES (106, '收到新的租赁订单', '您的出租「测试租赁系统的新功能，佣金结算」收到新订单，租期10天，等待客服处理', 3, 112, 1, 1, NULL, '2026-03-19 00:17:29');
INSERT INTO `notifications` VALUES (107, '租赁订单支付成功', '您租赁的「测试租赁系统的新功能，佣金结算」已支付成功，等待客服处理', 3, 6, 2, 1, NULL, '2026-03-19 00:17:29');
INSERT INTO `notifications` VALUES (108, '收到新的租赁订单', '您的出租「测试租赁系统的新功能，佣金结算」收到新订单，租期10天，等待客服处理', 3, 113, 1, 1, NULL, '2026-03-19 00:18:31');
INSERT INTO `notifications` VALUES (109, '租赁订单支付成功', '您租赁的「测试租赁系统的新功能，佣金结算」已支付成功，等待客服处理', 3, 6, 2, 1, NULL, '2026-03-19 00:18:31');
INSERT INTO `notifications` VALUES (110, '收到新的租赁订单', '您的出租「测试租赁系统的新功能，佣金结算」收到新订单，租期10天，等待客服处理', 3, 112, 1, 1, NULL, '2026-03-19 00:18:37');
INSERT INTO `notifications` VALUES (111, '租赁订单支付成功', '您租赁的「测试租赁系统的新功能，佣金结算」已支付成功，等待客服处理', 3, 6, 2, 1, NULL, '2026-03-19 00:18:37');
INSERT INTO `notifications` VALUES (112, '租赁订单已开始', '您租用的订单 #6 已开始执行，租期 10 天，到期时间：2026-03-29 00:21:14', 3, 6, 2, 1, NULL, '2026-03-19 00:21:14');
INSERT INTO `notifications` VALUES (113, '租赁订单已开始', '您出租的订单 #6 已开始执行，租期 10 天，到期时间：2026-03-29 00:21:14', 3, 112, 1, 1, NULL, '2026-03-19 00:21:14');
INSERT INTO `notifications` VALUES (114, '租赁订单已开始', '您租用的订单 #7 已开始执行，租期 10 天，到期时间：2026-03-29 00:21:15', 3, 6, 2, 1, NULL, '2026-03-19 00:21:15');
INSERT INTO `notifications` VALUES (115, '租赁订单已开始', '您出租的订单 #7 已开始执行，租期 10 天，到期时间：2026-03-29 00:21:15', 3, 113, 1, 1, NULL, '2026-03-19 00:21:15');
INSERT INTO `notifications` VALUES (116, '租赁订单已开始', '您租用的订单 #8 已开始执行，租期 10 天，到期时间：2026-03-29 00:21:17', 3, 6, 2, 1, NULL, '2026-03-19 00:21:17');
INSERT INTO `notifications` VALUES (117, '租赁订单已开始', '您出租的订单 #8 已开始执行，租期 10 天，到期时间：2026-03-29 00:21:17', 3, 112, 1, 1, NULL, '2026-03-19 00:21:17');
INSERT INTO `notifications` VALUES (118, '租赁订单已完成', '您出租的订单 #6 已完成，收益 ¥70.00 已到账', 3, 112, 1, 1, NULL, '2026-03-19 00:24:48');
INSERT INTO `notifications` VALUES (119, '租赁订单已完成', '您租用的订单 #6 已到期完成，感谢使用', 3, 6, 2, 1, NULL, '2026-03-19 00:24:48');
INSERT INTO `notifications` VALUES (120, '租赁订单已完成', '您出租的订单 #7 已完成，收益 ¥70.00 已到账', 3, 113, 1, 1, NULL, '2026-03-19 00:24:48');
INSERT INTO `notifications` VALUES (121, '租赁订单已完成', '您租用的订单 #7 已到期完成，感谢使用', 3, 6, 2, 1, NULL, '2026-03-19 00:24:48');
INSERT INTO `notifications` VALUES (122, '租赁订单已完成', '您出租的订单 #8 已完成，收益 ¥70.00 已到账', 3, 112, 1, 1, NULL, '2026-03-19 00:24:48');
INSERT INTO `notifications` VALUES (123, '租赁订单已完成', '您租用的订单 #8 已到期完成，感谢使用', 3, 6, 2, 1, NULL, '2026-03-19 00:24:48');
INSERT INTO `notifications` VALUES (124, '充值审核通过', '您的充值申请已审核通过，金额：¥200.00 已到账。感谢您的使用！', 3, 8, 2, 1, NULL, '2026-03-21 14:37:14');
INSERT INTO `notifications` VALUES (125, '充值审核通过', '您的充值申请已审核通过，金额：¥10,000.00 已到账。感谢您的使用！', 3, 9, 2, 1, NULL, '2026-03-23 13:39:43');
INSERT INTO `notifications` VALUES (126, '任务已超时', '您接取的任务「上评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-03-23 19:46:27\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。', 3, 137, 1, 1, NULL, '2026-03-23 19:55:27');
INSERT INTO `notifications` VALUES (127, '任务已超时', '您接取的任务「上评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-03-23 19:57:43\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。', 3, 137, 1, 1, NULL, '2026-03-23 19:58:07');
INSERT INTO `notifications` VALUES (128, '任务已超时', '您接取的任务「上评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-03-23 20:12:00\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。', 3, 137, 1, 1, NULL, '2026-03-23 20:12:23');
INSERT INTO `notifications` VALUES (129, '任务已超时', '您接取的任务「上评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-03-23 20:15:03\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。', 3, 137, 1, 1, NULL, '2026-03-23 20:41:10');
INSERT INTO `notifications` VALUES (130, '任务已超时', '您接取的任务「上评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-03-23 20:41:25\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。', 3, 137, 1, 1, NULL, '2026-03-23 20:47:18');
INSERT INTO `notifications` VALUES (131, '任务已超时', '您接取的任务「上评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-03-23 20:52:08\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。', 3, 137, 1, 1, NULL, '2026-03-23 20:52:26');
INSERT INTO `notifications` VALUES (132, '恭喜！团长申请已通过', '恭喜您！您的团长申请已审核通过。\n\n现在您可以享受以下权益：\n• 推广邀请码，获得下线用户\n• 下线完成任务时，您可获得佣金分成\n\n邀请码：DBDW9M', 3, 134, 1, 1, NULL, '2026-03-25 20:30:04');
INSERT INTO `notifications` VALUES (133, '恭喜！高级团长申请已通过', '恭喜您！您的高级团长申请已审核通过。\n\n高级团长权益已生效，佣金将按高级团长标准结算。\n\n邀请码：DBDW9M', 3, 134, 1, 1, NULL, '2026-03-25 21:02:09');
INSERT INTO `notifications` VALUES (134, '1111', '测试1111', 3, 134, 1, 1, NULL, '2026-04-03 19:05:59');
INSERT INTO `notifications` VALUES (135, '测试测试测试测试测试测试测试测试', '测试测试测试测试测试测试测试测试测试测试测试测试测试测试', 3, 134, 1, 3, NULL, '2026-04-03 19:10:53');
INSERT INTO `notifications` VALUES (136, '恭喜！高级团长申请已通过', '恭喜您！您的高级团长申请已审核通过。\n\n高级团长权益已生效，佣金将按高级团长标准结算。\n\n邀请码：DBDW9M', 3, 134, 1, 1, NULL, '2026-04-03 19:12:21');

SET FOREIGN_KEY_CHECKS = 1;
