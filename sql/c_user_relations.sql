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

 Date: 01/04/2026 11:07:04
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for c_user_relations
-- ----------------------------
DROP TABLE IF EXISTS `c_user_relations`;
CREATE TABLE `c_user_relations`  (
  `id` int(10) UNSIGNED ZEROFILL NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '被邀请人ID（当前注册用户）',
  `agent_id` bigint UNSIGNED NOT NULL COMMENT '上级代理ID（邀请码用户,代理等级分直接、间接）',
  `level` tinyint NOT NULL COMMENT '1=一级代理（直接上级）, 2=二级代理（间接上级）',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `unique_user_agent`(`user_id` ASC, `agent_id` ASC, `level` ASC) USING BTREE,
  INDEX `agent_id`(`agent_id` ASC) USING BTREE,
  CONSTRAINT `c_user_relations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `c_users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `c_user_relations_ibfk_2` FOREIGN KEY (`agent_id`) REFERENCES `c_users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 158 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '一级邀请二级邀请关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of c_user_relations
-- ----------------------------
INSERT INTO `c_user_relations` VALUES (0000000123, 134, 133, 1, '2026-03-23 11:41:42');
INSERT INTO `c_user_relations` VALUES (0000000124, 135, 133, 1, '2026-03-23 11:44:37');
INSERT INTO `c_user_relations` VALUES (0000000125, 136, 133, 1, '2026-03-23 11:45:36');
INSERT INTO `c_user_relations` VALUES (0000000126, 137, 133, 1, '2026-03-23 13:42:38');
INSERT INTO `c_user_relations` VALUES (0000000127, 138, 133, 1, '2026-03-25 20:23:24');
INSERT INTO `c_user_relations` VALUES (0000000128, 139, 133, 1, '2026-03-25 20:23:31');
INSERT INTO `c_user_relations` VALUES (0000000129, 140, 133, 1, '2026-03-25 20:23:40');
INSERT INTO `c_user_relations` VALUES (0000000130, 141, 133, 1, '2026-03-25 20:23:50');
INSERT INTO `c_user_relations` VALUES (0000000131, 142, 133, 1, '2026-03-25 20:23:59');
INSERT INTO `c_user_relations` VALUES (0000000132, 143, 133, 1, '2026-03-25 20:34:10');
INSERT INTO `c_user_relations` VALUES (0000000133, 144, 134, 1, '2026-03-25 20:36:22');
INSERT INTO `c_user_relations` VALUES (0000000134, 144, 133, 2, '2026-03-25 20:36:22');
INSERT INTO `c_user_relations` VALUES (0000000135, 145, 134, 1, '2026-03-25 20:55:34');
INSERT INTO `c_user_relations` VALUES (0000000136, 145, 133, 2, '2026-03-25 20:55:34');
INSERT INTO `c_user_relations` VALUES (0000000137, 146, 134, 1, '2026-03-25 20:55:55');
INSERT INTO `c_user_relations` VALUES (0000000138, 146, 133, 2, '2026-03-25 20:55:55');
INSERT INTO `c_user_relations` VALUES (0000000139, 147, 134, 1, '2026-03-25 20:56:13');
INSERT INTO `c_user_relations` VALUES (0000000140, 147, 133, 2, '2026-03-25 20:56:13');
INSERT INTO `c_user_relations` VALUES (0000000141, 148, 134, 1, '2026-03-25 20:56:20');
INSERT INTO `c_user_relations` VALUES (0000000142, 148, 133, 2, '2026-03-25 20:56:20');
INSERT INTO `c_user_relations` VALUES (0000000143, 149, 134, 1, '2026-03-25 20:56:27');
INSERT INTO `c_user_relations` VALUES (0000000144, 149, 133, 2, '2026-03-25 20:56:27');
INSERT INTO `c_user_relations` VALUES (0000000145, 150, 134, 1, '2026-03-25 20:56:36');
INSERT INTO `c_user_relations` VALUES (0000000146, 150, 133, 2, '2026-03-25 20:56:36');
INSERT INTO `c_user_relations` VALUES (0000000148, 153, 147, 1, '2026-04-01 10:03:56');
INSERT INTO `c_user_relations` VALUES (0000000149, 153, 134, 2, '2026-04-01 10:03:56');
INSERT INTO `c_user_relations` VALUES (0000000150, 154, 147, 1, '2026-04-01 10:04:07');
INSERT INTO `c_user_relations` VALUES (0000000151, 154, 134, 2, '2026-04-01 10:04:07');
INSERT INTO `c_user_relations` VALUES (0000000152, 155, 147, 1, '2026-04-01 10:04:14');
INSERT INTO `c_user_relations` VALUES (0000000153, 155, 134, 2, '2026-04-01 10:04:14');
INSERT INTO `c_user_relations` VALUES (0000000154, 156, 138, 1, '2026-04-01 10:20:29');
INSERT INTO `c_user_relations` VALUES (0000000155, 156, 133, 2, '2026-04-01 10:20:29');
INSERT INTO `c_user_relations` VALUES (0000000156, 157, 138, 1, '2026-04-01 10:20:36');
INSERT INTO `c_user_relations` VALUES (0000000157, 157, 133, 2, '2026-04-01 10:20:36');

SET FOREIGN_KEY_CHECKS = 1;
