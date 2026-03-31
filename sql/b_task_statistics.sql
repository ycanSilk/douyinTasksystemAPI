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

 Date: 31/03/2026 20:33:15
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for b_task_statistics
-- ----------------------------
DROP TABLE IF EXISTS `b_task_statistics`;
CREATE TABLE `b_task_statistics`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '统计ID',
  `b_user_id` bigint UNSIGNED NOT NULL COMMENT 'B端用户ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（冗余字段）',
  `flow_type` tinyint NOT NULL COMMENT '流水类型：1=收入，2=支出',
  `amount` bigint NOT NULL DEFAULT 0 COMMENT '变动金额（单位：分，正数）',
  `before_balance` bigint NOT NULL DEFAULT 0 COMMENT '变动前余额（单位：分）',
  `after_balance` bigint NOT NULL DEFAULT 0 COMMENT '变动后余额（单位：分）',
  `related_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关联类型：task_publish=任务发布，recharge=充值，account_rental=账号租赁，refund=退款',
  `related_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '关联ID（任务ID、订单ID等）',
  `task_types` tinyint UNSIGNED NULL DEFAULT NULL COMMENT '任务类型：1=上评评论，2=中评评论，3=放大镜搜索词，4=上中评评论，5=中下评评论，6=出租订单，7=求租订单',
  `task_types_text` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务类型文本描述',
  `record_status` tinyint UNSIGNED NULL DEFAULT 0 COMMENT '记录状态：0=待处理，1=进行中，2=待审核，3=已完成，4=待支付,5=已过期,6=已驳回,7=已暂停，8=已取消，9=已退款,10=已支付',
  `record_status_text` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '记录状态文本',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '流水的详细说明记录',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_b_user_id`(`b_user_id` ASC) USING BTREE,
  INDEX `idx_flow_type`(`flow_type` ASC) USING BTREE,
  INDEX `idx_related`(`related_type` ASC, `related_id` ASC) USING BTREE,
  INDEX `idx_task_types`(`task_types` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'B端任务统计表-记录B端用户所有金额变动' ROW_FORMAT = DYNAMIC;

SET FOREIGN_KEY_CHECKS = 1;
