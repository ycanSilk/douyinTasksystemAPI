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

 Date: 17/03/2026 15:29:01
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for c_user_relations
-- ----------------------------
DROP TABLE IF EXISTS `c_user_relations`;
CREATE TABLE `c_user_relations`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `agent_id` bigint UNSIGNED NOT NULL,
  `level` tinyint NOT NULL COMMENT '1=一级代理, 2=二级代理',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `unique_user_agent`(`user_id` ASC, `agent_id` ASC, `level` ASC) USING BTREE,
  INDEX `agent_id`(`agent_id` ASC) USING BTREE,
  CONSTRAINT `c_user_relations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `c_users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `c_user_relations_ibfk_2` FOREIGN KEY (`agent_id`) REFERENCES `c_users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of c_user_relations
-- ----------------------------
INSERT INTO `c_user_relations` VALUES (1, 101, 100, 1, '2026-03-17 11:52:31');
INSERT INTO `c_user_relations` VALUES (2, 102, 100, 1, '2026-03-17 11:52:31');
INSERT INTO `c_user_relations` VALUES (3, 103, 101, 1, '2026-03-17 11:52:31');
INSERT INTO `c_user_relations` VALUES (4, 104, 101, 1, '2026-03-17 11:52:31');
INSERT INTO `c_user_relations` VALUES (5, 105, 102, 1, '2026-03-17 11:52:31');
INSERT INTO `c_user_relations` VALUES (6, 106, 103, 1, '2026-03-17 11:52:31');
INSERT INTO `c_user_relations` VALUES (7, 107, 103, 1, '2026-03-17 11:52:31');
INSERT INTO `c_user_relations` VALUES (8, 108, 104, 1, '2026-03-17 11:52:31');
INSERT INTO `c_user_relations` VALUES (9, 109, 105, 1, '2026-03-17 11:52:31');
INSERT INTO `c_user_relations` VALUES (10, 110, 105, 1, '2026-03-17 11:52:31');
INSERT INTO `c_user_relations` VALUES (11, 103, 100, 2, '2026-03-17 11:52:31');
INSERT INTO `c_user_relations` VALUES (12, 104, 100, 2, '2026-03-17 11:52:31');
INSERT INTO `c_user_relations` VALUES (13, 105, 100, 2, '2026-03-17 11:52:31');
INSERT INTO `c_user_relations` VALUES (14, 106, 101, 2, '2026-03-17 11:52:31');
INSERT INTO `c_user_relations` VALUES (15, 107, 101, 2, '2026-03-17 11:52:31');
INSERT INTO `c_user_relations` VALUES (16, 108, 101, 2, '2026-03-17 11:52:31');
INSERT INTO `c_user_relations` VALUES (17, 109, 102, 2, '2026-03-17 11:52:31');
INSERT INTO `c_user_relations` VALUES (18, 110, 102, 2, '2026-03-17 11:52:31');

SET FOREIGN_KEY_CHECKS = 1;
