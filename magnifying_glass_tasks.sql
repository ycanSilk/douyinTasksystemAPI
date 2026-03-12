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

 Date: 11/03/2026 23:58:39
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for magnifying_glass_tasks
-- ----------------------------
DROP TABLE IF EXISTS `magnifying_glass_tasks`;
CREATE TABLE `magnifying_glass_tasks`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `b_user_id` bigint UNSIGNED NOT NULL COMMENT 'B端用户ID',
  `task_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '父任务ID',
  `template_id` int UNSIGNED NOT NULL DEFAULT 3 COMMENT '任务模板ID，固定为3',
  `video_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '视频链接',
  `deadline` int UNSIGNED NOT NULL COMMENT '到期时间（10位时间戳-秒级）',
  `recommend_marks` json NULL COMMENT '推荐标记（JSON数组）',
  `task_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '任务总数量',
  `task_done` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '已完成数量',
  `task_doing` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '进行中数量',
  `task_reviewing` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '待审核数量',
  `unit_price` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '单价（元）',
  `total_price` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '总价（元）',
  `status` tinyint NOT NULL DEFAULT 2 COMMENT '状态：0=已发布，1=进行中，2=已完成，3=已取消',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `completed_at` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务标题',
  `view_status` tinyint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_b_user_id`(`b_user_id` ASC) USING BTREE,
  INDEX `idx_task_id`(`task_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_deadline`(`deadline` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '放大镜任务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of magnifying_glass_tasks
-- ----------------------------
INSERT INTO `magnifying_glass_tasks` VALUES (1, 3, NULL, 3, 'https://www.bilibili.com/video/BV1qeZuBPE3i/?spm_id_from=333.1007.tianma.1-3-3.click&vd_source=786a0003ba5bc5348f314ee587d01658', 1780243200, '[{\"at_user\": \"@超哥超车\", \"comment\": \"蓝词搜索@超哥超车\", \"image_url\": \"\"}, {\"at_user\": \"@超哥超车\", \"comment\": \"蓝词搜索@超哥超车\", \"image_url\": \"\"}]', 2, 0, 0, 0, 5.00, 10.00, 2, '2026-03-06 20:28:07', '2026-03-09 21:13:11', NULL, '放大镜搜索词', 1);
INSERT INTO `magnifying_glass_tasks` VALUES (2, 3, NULL, 3, 'https://www.bilibili.com/video/BV1qeZuBPE3i/?spm_id_from=333.1007.tianma.1-3-3.click&vd_source=786a0003ba5bc5348f314ee587d01658', 1780243200, '[{\"at_user\": \"@咕噜\", \"comment\": \"蓝词搜索@咕噜\", \"image_url\": \"\"}, {\"at_user\": \"@超哥超车\", \"comment\": \"蓝词搜索@超哥超车\", \"image_url\": \"\"}, {\"at_user\": \"@乔哥\", \"comment\": \"蓝词搜索@乔哥\", \"image_url\": \"\"}]', 3, 0, 0, 0, 5.00, 15.00, 2, '2026-03-06 22:40:41', '2026-03-11 13:53:01', NULL, '放大镜搜索词', 1);
INSERT INTO `magnifying_glass_tasks` VALUES (3, 3, NULL, 3, 'https://www.bilibili.com/video/BV1xPZAB8ExF/?spm_id_from=333.1007.tianma.1-1-1.click', 1772851124, '[{\"at_user\": \"\", \"comment\": \"蓝词搜索：@超哥\", \"image_url\": \"\"}]', 5, 0, 0, 0, 5.00, 25.00, 2, '2026-03-07 10:28:44', '2026-03-09 21:13:10', NULL, '放大镜搜索词', 1);
INSERT INTO `magnifying_glass_tasks` VALUES (4, 2, NULL, 3, '123456', 1772950514, '[{\"at_user\": \"\", \"comment\": \"小野\", \"image_url\": \"\"}]', 1, 0, 0, 0, 5.00, 5.00, 2, '2026-03-08 13:45:14', '2026-03-11 22:52:11', NULL, '放大镜搜索词', 1);
INSERT INTO `magnifying_glass_tasks` VALUES (5, 3, NULL, 3, 'https://example.com/video.mp4', 1796058000, '[{\"at_user\": \"@超哥超车\", \"comment\": \"蓝词搜索@超哥超车\", \"image_url\": \"\"}]', 2, 0, 0, 0, 5.00, 10.00, 2, '2026-03-11 23:56:02', '2026-03-11 23:56:02', NULL, '放大镜搜索词', 0);

SET FOREIGN_KEY_CHECKS = 1;
