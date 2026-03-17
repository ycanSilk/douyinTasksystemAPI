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

 Date: 16/03/2026 23:04:34
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for system_roles
-- ----------------------------
DROP TABLE IF EXISTS `system_roles`;
CREATE TABLE `system_roles`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色名称',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '角色描述',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=启用，0=禁用',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_name`(`name` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '后台管理角色表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_roles
-- ----------------------------
INSERT INTO `system_roles` VALUES (1, '超级管理员', '拥有最高权限', 1, '2026-03-06 15:03:35', '2026-03-06 15:03:35');
INSERT INTO `system_roles` VALUES (2, '管理员', '拥有大部分管理权限', 1, '2026-03-06 15:03:35', '2026-03-06 15:03:35');
INSERT INTO `system_roles` VALUES (3, '运营', '系统运维权限', 1, '2026-03-06 15:03:35', '2026-03-06 17:56:48');
INSERT INTO `system_roles` VALUES (4, '财务', '财务管理权限', 1, '2026-03-06 15:03:35', '2026-03-06 15:03:35');
INSERT INTO `system_roles` VALUES (5, '客服', '客户服务权限', 1, '2026-03-06 15:03:35', '2026-03-06 15:03:35');
INSERT INTO `system_roles` VALUES (7, '审计', '给投资方、股东查看平台流水', 1, '2026-03-06 18:15:28', '2026-03-06 18:15:28');

SET FOREIGN_KEY_CHECKS = 1;
