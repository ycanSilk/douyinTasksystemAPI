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

 Date: 18/03/2026 17:10:48
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for c_user_relations
-- ----------------------------
DROP TABLE IF EXISTS `c_user_relations`;
CREATE TABLE `c_user_relations`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '被邀请人ID（当前注册用户）',
  `agent_id` bigint UNSIGNED NOT NULL COMMENT '上级代理ID（邀请码用户,代理等级分直接、间接）',
  `level` tinyint NOT NULL COMMENT '1=一级代理（直接上级）, 2=二级代理（间接上级）',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `unique_user_agent`(`user_id` ASC, `agent_id` ASC, `level` ASC) USING BTREE,
  INDEX `agent_id`(`agent_id` ASC) USING BTREE,
  CONSTRAINT `c_user_relations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `c_users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `c_user_relations_ibfk_2` FOREIGN KEY (`agent_id`) REFERENCES `c_users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 46 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of c_user_relations
-- ----------------------------
INSERT INTO `c_user_relations` VALUES (19, 112, 111, 1, '2026-03-18 12:10:57');
INSERT INTO `c_user_relations` VALUES (20, 113, 112, 1, '2026-03-18 12:14:08');
INSERT INTO `c_user_relations` VALUES (21, 113, 111, 2, '2026-03-18 12:14:08');
INSERT INTO `c_user_relations` VALUES (22, 114, 112, 1, '2026-03-18 12:15:41');
INSERT INTO `c_user_relations` VALUES (23, 114, 111, 2, '2026-03-18 12:15:41');
INSERT INTO `c_user_relations` VALUES (24, 115, 111, 1, '2026-03-18 12:16:03');
INSERT INTO `c_user_relations` VALUES (25, 116, 111, 1, '2026-03-18 12:16:12');
INSERT INTO `c_user_relations` VALUES (26, 117, 113, 1, '2026-03-18 12:16:40');
INSERT INTO `c_user_relations` VALUES (27, 117, 112, 2, '2026-03-18 12:16:40');
INSERT INTO `c_user_relations` VALUES (28, 118, 113, 1, '2026-03-18 12:17:09');
INSERT INTO `c_user_relations` VALUES (29, 118, 112, 2, '2026-03-18 12:17:09');
INSERT INTO `c_user_relations` VALUES (30, 119, 114, 1, '2026-03-18 12:17:55');
INSERT INTO `c_user_relations` VALUES (31, 119, 112, 2, '2026-03-18 12:17:55');
INSERT INTO `c_user_relations` VALUES (32, 120, 114, 1, '2026-03-18 12:18:03');
INSERT INTO `c_user_relations` VALUES (33, 120, 112, 2, '2026-03-18 12:18:03');
INSERT INTO `c_user_relations` VALUES (34, 121, 117, 1, '2026-03-18 12:19:03');
INSERT INTO `c_user_relations` VALUES (35, 121, 113, 2, '2026-03-18 12:19:03');
INSERT INTO `c_user_relations` VALUES (36, 122, 115, 1, '2026-03-18 15:16:36');
INSERT INTO `c_user_relations` VALUES (37, 122, 111, 2, '2026-03-18 15:16:36');
INSERT INTO `c_user_relations` VALUES (38, 123, 115, 1, '2026-03-18 15:18:01');
INSERT INTO `c_user_relations` VALUES (39, 123, 111, 2, '2026-03-18 15:18:01');
INSERT INTO `c_user_relations` VALUES (40, 124, 112, 1, '2026-03-18 15:47:37');
INSERT INTO `c_user_relations` VALUES (41, 124, 111, 2, '2026-03-18 15:47:37');
INSERT INTO `c_user_relations` VALUES (42, 125, 124, 1, '2026-03-18 15:48:38');
INSERT INTO `c_user_relations` VALUES (43, 125, 112, 2, '2026-03-18 15:48:38');
INSERT INTO `c_user_relations` VALUES (44, 126, 115, 1, '2026-03-18 15:57:02');
INSERT INTO `c_user_relations` VALUES (45, 126, 111, 2, '2026-03-18 15:57:02');

SET FOREIGN_KEY_CHECKS = 1;
