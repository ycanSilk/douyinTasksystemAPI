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

 Date: 21/03/2026 14:51:48
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
) ENGINE = InnoDB AUTO_INCREMENT = 123 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '一级邀请二级邀请关系表' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
