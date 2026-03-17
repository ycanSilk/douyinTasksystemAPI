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

 Date: 16/03/2026 23:04:41
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for system_role_permission_template
-- ----------------------------
DROP TABLE IF EXISTS `system_role_permission_template`;
CREATE TABLE `system_role_permission_template`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `role_id` bigint UNSIGNED NOT NULL COMMENT '角色ID',
  `template_id` bigint UNSIGNED NOT NULL COMMENT '模板ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_template`(`role_id` ASC, `template_id` ASC) USING BTREE,
  INDEX `idx_role_id`(`role_id` ASC) USING BTREE,
  INDEX `idx_template_id`(`template_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 442 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '角色权限模板关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_role_permission_template
-- ----------------------------
INSERT INTO `system_role_permission_template` VALUES (32, 6, 1, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (33, 6, 2, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (34, 6, 3, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (35, 6, 4, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (36, 6, 5, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (37, 6, 6, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (38, 6, 7, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (39, 6, 8, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (40, 6, 9, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (41, 6, 10, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (42, 6, 11, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (43, 6, 12, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (44, 6, 13, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (45, 6, 14, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (46, 6, 15, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (47, 6, 16, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (48, 6, 17, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (49, 6, 18, '2026-03-06 17:04:23');
INSERT INTO `system_role_permission_template` VALUES (59, 2, 1, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (60, 2, 2, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (61, 2, 3, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (62, 2, 7, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (63, 2, 8, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (64, 2, 9, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (65, 2, 10, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (66, 2, 11, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (67, 2, 12, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (68, 2, 13, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (69, 2, 14, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (70, 2, 15, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (71, 2, 16, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (72, 2, 18, '2026-03-06 17:34:51');
INSERT INTO `system_role_permission_template` VALUES (73, 4, 1, '2026-03-06 17:58:30');
INSERT INTO `system_role_permission_template` VALUES (74, 4, 11, '2026-03-06 17:58:30');
INSERT INTO `system_role_permission_template` VALUES (75, 4, 12, '2026-03-06 17:58:30');
INSERT INTO `system_role_permission_template` VALUES (76, 4, 13, '2026-03-06 17:58:30');
INSERT INTO `system_role_permission_template` VALUES (77, 3, 1, '2026-03-06 17:58:54');
INSERT INTO `system_role_permission_template` VALUES (78, 3, 2, '2026-03-06 17:58:54');
INSERT INTO `system_role_permission_template` VALUES (79, 3, 3, '2026-03-06 17:58:54');
INSERT INTO `system_role_permission_template` VALUES (90, 7, 1, '2026-03-07 10:58:18');
INSERT INTO `system_role_permission_template` VALUES (132, 5, 8, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (133, 5, 9, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (134, 5, 10, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (135, 5, 11, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (136, 5, 12, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (137, 5, 13, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (138, 5, 14, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (139, 5, 15, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (140, 5, 16, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (141, 5, 18, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (142, 5, 20, '2026-03-11 12:38:08');
INSERT INTO `system_role_permission_template` VALUES (418, 1, 4, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (419, 1, 11, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (420, 1, 22, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (421, 1, 30, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (422, 1, 31, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (423, 1, 23, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (424, 1, 32, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (425, 1, 33, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (426, 1, 9, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (427, 1, 12, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (428, 1, 13, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (429, 1, 14, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (430, 1, 19, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (431, 1, 5, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (432, 1, 6, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (433, 1, 7, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (434, 1, 8, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (435, 1, 10, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (436, 1, 15, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (437, 1, 16, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (438, 1, 17, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (439, 1, 18, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (440, 1, 20, '2026-03-16 23:02:00');
INSERT INTO `system_role_permission_template` VALUES (441, 1, 21, '2026-03-16 23:02:00');

SET FOREIGN_KEY_CHECKS = 1;
