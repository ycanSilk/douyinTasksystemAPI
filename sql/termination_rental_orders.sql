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

 Date: 18/03/2026 23:54:31
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for termination_rental_orders
-- ----------------------------
DROP TABLE IF EXISTS `termination_rental_orders`;
CREATE TABLE `termination_rental_orders`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '终止订单ID',
  `rental_order_id` bigint UNSIGNED NOT NULL COMMENT '原租赁订单ID',
  `termination_type` tinyint NOT NULL COMMENT '终止类型：1=终止租赁不退款，2=终止租赁并退款',
  `buyer_user_id` bigint UNSIGNED NOT NULL COMMENT '买方（租用方）用户ID',
  `buyer_user_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '买方类型：b=B端，c=C端',
  `seller_user_id` bigint UNSIGNED NOT NULL COMMENT '卖方（出租方）用户ID',
  `seller_user_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '卖方类型：b=B端，c=C端',
  `total_amount` bigint NOT NULL COMMENT '订单总金额（单位：分）',
  `refund_amount` bigint NOT NULL DEFAULT 0 COMMENT '退款金额（单位：分）',
  `seller_amount` bigint NOT NULL DEFAULT 0 COMMENT '卖方实得金额（单位：分）',
  `rented_days` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '已租赁天数',
  `remaining_days` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '剩余天数',
  `terminated_at` datetime NOT NULL COMMENT '终止时间',
  `admin_user_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '操作管理员ID',
  `order_json` json NULL COMMENT '订单额外数据（价格快照等）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_rental_order_id`(`rental_order_id` ASC) USING BTREE,
  INDEX `idx_buyer`(`buyer_user_id` ASC, `buyer_user_type` ASC) USING BTREE,
  INDEX `idx_seller`(`seller_user_id` ASC, `seller_user_type` ASC) USING BTREE,
  INDEX `idx_terminated_at`(`terminated_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '终止租赁订单表-记录终止租赁的相关数据' ROW_FORMAT = DYNAMIC;

SET FOREIGN_KEY_CHECKS = 1;