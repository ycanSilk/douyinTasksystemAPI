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
-- Table structure for rental_orders
-- ----------------------------
DROP TABLE IF EXISTS `rental_orders`;
CREATE TABLE `rental_orders`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `source_type` tinyint NOT NULL COMMENT '来源类型：0=出租信息成交，1=求租信息成交',
  `source_id` bigint UNSIGNED NOT NULL COMMENT '来源ID（offer_id或demand_id）',
  `buyer_user_id` bigint UNSIGNED NOT NULL COMMENT '买方（租用方）用户ID',
  `buyer_user_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '买方类型：b=B端，c=C端',
  `buyer_wallet_id` bigint UNSIGNED NOT NULL COMMENT '买方钱包ID',
  `buyer_info_json` json NULL COMMENT '买方详细信息（求租需求/下单备注等）',
  `seller_user_id` bigint UNSIGNED NOT NULL COMMENT '卖方（出租方）用户ID',
  `seller_user_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '卖方类型：b=B端，c=C端',
  `seller_wallet_id` bigint UNSIGNED NOT NULL COMMENT '卖方钱包ID',
  `seller_info_json` json NULL COMMENT '卖方详细信息（账号信息/应征资料等）',
  `agent_user_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '团长用户ID',
  `agent_amount` bigint NOT NULL DEFAULT 0 COMMENT '团长佣金金额（分）',
  `total_amount` bigint NOT NULL COMMENT '订单总金额（单位：分）',
  `platform_amount` bigint NOT NULL DEFAULT 0 COMMENT '平台抽成金额（单位：分）',
  `seller_amount` bigint NOT NULL DEFAULT 0 COMMENT '卖方实得金额（单位：分）',
  `days` int UNSIGNED NOT NULL COMMENT '租赁天数',
  `allow_renew` tinyint NOT NULL DEFAULT 0 COMMENT '是否允许续租：0=不允许，1=允许',
  `order_json` json NULL COMMENT '订单额外数据（价格快照等）',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态：0=待支付，1=已支付/待客服，2=进行中，3=已完成，4=已取消',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_source`(`source_type` ASC, `source_id` ASC) USING BTREE,
  INDEX `idx_buyer`(`buyer_user_id` ASC, `buyer_user_type` ASC) USING BTREE,
  INDEX `idx_seller`(`seller_user_id` ASC, `seller_user_type` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '租赁订单表-成交订单记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rental_orders
-- ----------------------------
INSERT INTO `rental_orders` VALUES (4, 0, 12, 6, 'b', 44, '{\"notes\": \"需要高权重账号\", \"usage\": \"用于直播带货\", \"contact\": \"微信xxx\"}', 112, 'c', 34, '{\"email\": \"true\", \"images\": [\"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"], \"qq_number\": \"true\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"测试租赁系统的新功能，佣金结算，卖方分成60%，普通团长10%，高级团长20%\", \"phone_number\": \"true\", \"other_require\": \"true\", \"phone_message\": \"true\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}', 111, 500, 10000, 2500, 7000, 10, 0, '{\"end_time\": 1773848400, \"max_days\": 30, \"min_days\": 1, \"start_time\": 1772984400, \"offer_title\": \"测试租赁系统的新功能，佣金结算\", \"price_per_day\": 1000}', 3, '2026-03-09 22:31:41', '2026-03-18 23:42:12');
INSERT INTO `rental_orders` VALUES (5, 0, 13, 6, 'b', 44, '{\"notes\": \"需要高权重账号\", \"usage\": \"用于直播带货\", \"contact\": \"微信xxx\"}', 112, 'c', 34, '{\"email\": \"true\", \"images\": [\"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"], \"qq_number\": \"true\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"测试租赁系统的新功能，佣金结算，卖方分成60%，普通团长10%，高级团长20%\", \"phone_number\": \"true\", \"other_require\": \"true\", \"phone_message\": \"true\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}', 111, 500, 10000, 2500, 7000, 10, 0, '{\"end_time\": 1773849121, \"max_days\": 30, \"min_days\": 1, \"start_time\": 1773416400, \"offer_title\": \"测试租赁系统的新功能，佣金结算\", \"rented_days\": 6, \"price_per_day\": 1000, \"refund_amount\": 4000, \"seller_amount\": 6000, \"terminated_at\": 1773849121, \"remaining_days\": 4, \"original_end_time\": 1774712430}', 4, '2026-03-13 23:40:18', '2026-03-18 23:52:01');

SET FOREIGN_KEY_CHECKS = 1;
