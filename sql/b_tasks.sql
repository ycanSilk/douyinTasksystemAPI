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

 Date: 04/04/2026 23:14:33
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for b_tasks
-- ----------------------------
DROP TABLE IF EXISTS `b_tasks`;
CREATE TABLE `b_tasks`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `b_user_id` bigint UNSIGNED NOT NULL COMMENT 'B端用户ID',
  `combo_task_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '组合任务标识（同一组合任务共享）',
  `stage` tinyint NOT NULL DEFAULT 0 COMMENT '阶段：0=单任务，1=阶段1，2=阶段2',
  `stage_status` tinyint NOT NULL DEFAULT 1 COMMENT '阶段状态：0=未开放，1=已开放，2=已完成',
  `parent_task_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '父任务ID（阶段2指向阶段1）',
  `template_id` int UNSIGNED NOT NULL COMMENT '任务模板ID',
  `video_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '视频链接（阶段2创建时为空，等阶段1完成后分配）',
  `deadline` int UNSIGNED NOT NULL COMMENT '到期时间（10位时间戳-秒级）',
  `recommend_marks` json NULL COMMENT '推荐评论（JSON数组）',
  `task_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '任务总数量（评论数组长度）',
  `task_done` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '已完成数量（已通过审核）',
  `task_doing` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '进行中数量（C端正在做）',
  `task_reviewing` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '待审核数量（已提交待审核）',
  `unit_price` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '单价（元，从模板获取）',
  `total_price` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '总价（元，单价*数量）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=进行中，2=已完成，3=已取消，0=已过期',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `completed_at` datetime NULL DEFAULT NULL COMMENT '完成时间（任务完成时记录）',
  `is_republish` int NULL DEFAULT NULL COMMENT '是否重新发布任务了：0=不是，1=是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_b_user_id`(`b_user_id` ASC) USING BTREE,
  INDEX `idx_combo_task_id`(`combo_task_id` ASC) USING BTREE,
  INDEX `idx_stage`(`stage` ASC) USING BTREE,
  INDEX `idx_stage_status`(`stage_status` ASC) USING BTREE,
  INDEX `idx_parent_task_id`(`parent_task_id` ASC) USING BTREE,
  INDEX `idx_template_id`(`template_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_deadline`(`deadline` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_completed_at`(`completed_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 217 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端发布任务表-商家派单' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of b_tasks
-- ----------------------------
INSERT INTO `b_tasks` VALUES (213, 9, 'COMBO_1775314642_9_1', 1, 2, NULL, 6, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1775314000, '[{\"comment\": \"阶段1上评评论\", \"image_url\": \"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"}]', 1, 1, 0, 0, 3.00, 3.00, 2, '2026-04-04 22:57:22', '2026-04-04 23:03:12', '2026-04-04 22:58:48', NULL);
INSERT INTO `b_tasks` VALUES (214, 9, 'COMBO_1775314642_9_1', 2, 1, 213, 6, 'https://啊发射点发射点发生大bbbb8', 1775314000, '[{\"comment\": \"阶段2中评回复1\", \"image_url\": \"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"}]', 1, 0, 0, 0, 3.00, 3.00, 0, '2026-04-04 22:57:22', '2026-04-04 23:03:14', NULL, NULL);
INSERT INTO `b_tasks` VALUES (215, 9, 'COMBO_1775314642_9_1', 2, 1, 213, 6, 'https://啊发射点发射点发生大bbbb8', 1796008061, '[{\"comment\": \"阶段2中评回复1\", \"image_url\": \"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"}]', 1, 1, 0, 0, 3.00, 3.00, 0, '2026-04-04 23:04:18', '2026-04-04 23:04:48', NULL, NULL);
INSERT INTO `b_tasks` VALUES (216, 9, 'COMBO_1775314642_9_1', 2, 1, 213, 6, 'https://啊发射点发射点发生大bbbb8', 1796008061, '[{\"comment\": \"阶段2中评回复1\", \"image_url\": \"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"}]', 1, 0, 0, 0, 3.00, 3.00, 1, '2026-04-04 23:04:52', '2026-04-04 23:04:52', NULL, NULL);

SET FOREIGN_KEY_CHECKS = 1;
