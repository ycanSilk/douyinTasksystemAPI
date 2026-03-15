/*
 * 更新任务统计表结构 - 添加 record_status 字段
 * 用于存储记录的任务类型当前状态
 */

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 为 b_task_statistics 表添加 record_status 和 record_status_text 字段
-- ----------------------------
ALTER TABLE `b_task_statistics`
ADD COLUMN `record_status` tinyint UNSIGNED NULL DEFAULT 0 COMMENT '记录状态：0=待处理，1=进行中，2=待审核，3=已完成，4=待支付,5=已过期,6=已驳回,7=已暂停，8=已取消,9=已退款' AFTER `task_types_text`,
ADD COLUMN `record_status_text` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '记录状态文本' AFTER `record_status`;

-- ----------------------------
-- 为 c_task_statistics 表添加 record_status 和 record_status_text 字段
-- ----------------------------
ALTER TABLE `c_task_statistics`
ADD COLUMN `record_status` tinyint UNSIGNED NULL DEFAULT 0 COMMENT '记录状态：0=待处理，1=进行中，2=待审核，3=已完成，4=待支付,5=已过期,6=已驳回,7=已暂停，8=已取消,9=已退款' AFTER `task_types_text`,
ADD COLUMN `record_status_text` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '记录状态文本' AFTER `record_status`;

SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------
-- 说明
-- ----------------------------
-- record_status 字段说明：
-- 0 = 待处理：任务或订单尚未开始处理
-- 1 = 进行中：任务或订单正在处理中
-- 2 = 已完成：任务或订单已处理完成
-- 3 = 待支付：任务或订单等待支付
-- 4 = 已取消：任务或订单已取消
-- 5 = 已过期：任务或订单已过期
-- 6 = 已驳回：任务或订单已被驳回
-- 7 = 已暂停：任务或订单已暂停
-- 
-- record_status_text 字段说明：
-- 存储 record_status 对应的文本描述，例如 "待处理"、"进行中" 等
-- 
-- 可以根据实际业务需求调整状态值的含义
