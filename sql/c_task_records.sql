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

 Date: 25/03/2026 14:57:35
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for c_task_records
-- ----------------------------
DROP TABLE IF EXISTS `c_task_records`;
CREATE TABLE `c_task_records`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `c_user_id` bigint UNSIGNED NOT NULL COMMENT 'C端用户ID',
  `b_task_id` bigint UNSIGNED NOT NULL COMMENT 'B端任务ID',
  `b_user_id` bigint UNSIGNED NOT NULL COMMENT 'B端用户ID（发布者）',
  `template_id` int UNSIGNED NOT NULL COMMENT '任务模板ID',
  `video_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '视频链接',
  `recommend_mark` json NULL COMMENT '分配的推荐评论（comment和image_url）',
  `comment_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户提交的评论链接',
  `screenshot_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户提交的截图',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=进行中(doing)，2=待审核(reviewing)，3=已通过(approved)，4=已驳回(rejected)',
  `reject_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '驳回原因',
  `reward_amount` bigint NOT NULL DEFAULT 0 COMMENT '奖励金额（单位：分）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '接单时间',
  `submitted_at` datetime NULL DEFAULT NULL COMMENT '提交时间',
  `reviewed_at` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `task_stage` tinyint NULL DEFAULT NULL COMMENT '当前任务阶段，0=单任务，1=1阶段，2=2阶段',
  `task_stage_text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前任务阶段的文本',
  `update_at` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_c_user_b_task`(`c_user_id` ASC, `b_task_id` ASC) USING BTREE,
  INDEX `idx_c_user_id`(`c_user_id` ASC) USING BTREE,
  INDEX `idx_b_task_id`(`b_task_id` ASC) USING BTREE,
  INDEX `idx_b_user_id`(`b_user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 130 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'C端任务记录表-接单执行审核全流程' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of c_task_records
-- ----------------------------
INSERT INTO `c_task_records` VALUES (122, 134, 237, 9, 7, '5.12 复制打开抖音，看看【陈二狗说漫的作品】动画界最高的山最长的河，自它诞生后，所有的猫叫To... https://v.douyin.com/bOawNaOE3QA/ 12/25 UYz:/ b@A.TY', '{\"at_user\": \"\", \"comment\": \"这是新手任务\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 100, '2026-03-24 23:19:17', NULL, NULL, 0, '新手任务', NULL);
INSERT INTO `c_task_records` VALUES (123, 134, 238, 9, 7, '5.87 复制打开抖音，看看【全网最尊重地球online的主播的作品】3月17日 锐评地球online# 地球onlin... https://v.douyin.com/JlJMtdPurPc/ r@R.KJ 04/06 Uyt:/', '{\"at_user\": \"\", \"comment\": \"这是新手任务测试提交任务\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 100, '2026-03-25 00:04:06', NULL, NULL, 0, '新手任务', '2026-03-25 00:05:51');
INSERT INTO `c_task_records` VALUES (124, 134, 239, 9, 7, '5.87 复制打开抖音，看看【全网最尊重地球online的主播的作品】3月17日 锐评地球online# 地球onlin... https://v.douyin.com/JlJMtdPurPc/ r@R.KJ 04/06 Uyt:/', '{\"at_user\": \"\", \"comment\": \"这是新手任务测试提交任务\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 100, '2026-03-25 00:08:21', NULL, NULL, 0, '新手任务', '2026-03-25 00:08:38');
INSERT INTO `c_task_records` VALUES (125, 134, 240, 9, 7, '5.87 复制打开抖音，看看【全网最尊重地球online的主播的作品】3月17日 锐评地球online# 地球onlin... https://v.douyin.com/JlJMtdPurPc/ r@R.KJ 04/06 Uyt:/', '{\"at_user\": \"\", \"comment\": \"这是新手任务测试提交任务\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 100, '2026-03-25 00:11:50', NULL, NULL, 0, '新手任务', '2026-03-25 00:12:06');
INSERT INTO `c_task_records` VALUES (126, 134, 241, 9, 7, '5.87 复制打开抖音，看看【全网最尊重地球online的主播的作品】3月17日 锐评地球online# 地球onlin... https://v.douyin.com/JlJMtdPurPc/ r@R.KJ 04/06 Uyt:/', '{\"at_user\": \"\", \"comment\": \"这是新手任务测试提交任务\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 100, '2026-03-25 00:16:11', NULL, NULL, 0, '新手任务', '2026-03-25 00:16:29');
INSERT INTO `c_task_records` VALUES (127, 134, 242, 10, 1, '5.87 复制打开抖音，看看【全网最尊重地球online的主播的作品】3月17日 锐评地球online# 地球onlin... https://v.douyin.com/JlJMtdPurPc/ r@R.KJ 04/06 Uyt:/', '{\"comment\": \"这是新手任务测试提交任务\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 100, '2026-03-25 11:29:12', NULL, NULL, 0, '上评评论', '2026-03-25 14:28:32');
INSERT INTO `c_task_records` VALUES (128, 134, 243, 10, 1, '5.87 复制打开抖音，看看【全网最尊重地球online的主播的作品】3月17日 锐评地球online# 地球onlin... https://v.douyin.com/JlJMtdPurPc/ r@R.KJ 04/06 Uyt:/', '{\"comment\": \"这是新手任务测试提交任务\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 100, '2026-03-25 14:35:53', NULL, NULL, 0, '上评评论', '2026-03-25 14:36:11');
INSERT INTO `c_task_records` VALUES (129, 134, 244, 10, 1, '5.87 复制打开抖音，看看【全网最尊重地球online的主播的作品】3月17日 锐评地球online# 地球onlin... https://v.douyin.com/JlJMtdPurPc/ r@R.KJ 04/06 Uyt:/', '{\"comment\": \"这是新手任务测试提交任务\", \"image_url\": \"\"}', '6Uejz-:/ Y@m.da 12/31 复制打开抖音，查看【予欢】发布作品的评论：这是新手任务测试提交任务', '[\"https:\\/\\/api.kktaskpaas.com\\/img\\/9baa9a9efa8f8af5101110484aa5cc81.png\"]', 2, NULL, 100, '2026-03-25 14:40:59', '2026-03-25 14:41:16', NULL, 0, '上评评论', NULL);

SET FOREIGN_KEY_CHECKS = 1;
