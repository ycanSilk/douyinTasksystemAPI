/*
测试数据插入脚本 - b_task_statistics表

插入20条测试数据，覆盖：
- 4个用户（ID: 1, 2, 3, 4）
- 4个周期（今天、昨天、7天前、30天前）
- 不同的流水类型（收入、支出）
- 不同的关联类型（任务发布、充值、账号租赁、退款）
- 不同的任务类型（上评评论、中评评论、放大镜搜索词、上中评评论、中下评评论、出租订单、求租订单）
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 清空表数据（可选）
-- TRUNCATE TABLE b_task_statistics;

-- 插入测试数据
INSERT INTO `b_task_statistics` (`b_user_id`, `username`, `flow_type`, `amount`, `before_balance`, `after_balance`, `related_type`, `related_id`, `task_types`, `task_types_text`, `remark`, `created_at`) VALUES

-- 用户1 - 今天
(1, 'user1', 1, 10000, 0, 10000, 'recharge', NULL, NULL, NULL, '用户充值', NOW()),
(1, 'user1', 2, 2000, 10000, 8000, 'task_publish', 1, 1, '上评评论', '发布上评评论任务', NOW()),
(1, 'user1', 2, 1500, 8000, 6500, 'account_rental', 1, 6, '出租订单', '租赁账号', NOW()),

-- 用户1 - 昨天
(1, 'user1', 1, 5000, 6500, 11500, 'recharge', NULL, NULL, NULL, '用户充值', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(1, 'user1', 2, 3000, 11500, 8500, 'task_publish', 2, 3, '放大镜搜索词', '发布放大镜搜索词任务', DATE_SUB(NOW(), INTERVAL 1 DAY)),

-- 用户1 - 7天前
(1, 'user1', 2, 2500, 8500, 6000, 'task_publish', 3, 2, '中评评论', '发布中评评论任务', DATE_SUB(NOW(), INTERVAL 7 DAY)),
(1, 'user1', 1, 1000, 6000, 7000, 'refund', 1, NULL, NULL, '退款', DATE_SUB(NOW(), INTERVAL 7 DAY)),

-- 用户1 - 30天前
(1, 'user1', 2, 4000, 7000, 3000, 'task_publish', 4, 4, '上中评评论', '发布上中评评论任务', DATE_SUB(NOW(), INTERVAL 30 DAY)),

-- 用户2 - 今天
(2, 'user2', 1, 8000, 0, 8000, 'recharge', NULL, NULL, NULL, '用户充值', NOW()),
(2, 'user2', 2, 1800, 8000, 6200, 'task_publish', 5, 5, '中下评评论', '发布中下评评论任务', NOW()),

-- 用户2 - 昨天
(2, 'user2', 2, 2200, 6200, 4000, 'account_rental', 2, 6, '出租订单', '租赁账号', DATE_SUB(NOW(), INTERVAL 1 DAY)),

-- 用户2 - 7天前
(2, 'user2', 1, 6000, 4000, 10000, 'recharge', NULL, NULL, NULL, '用户充值', DATE_SUB(NOW(), INTERVAL 7 DAY)),
(2, 'user2', 2, 3500, 10000, 6500, 'task_publish', 6, 3, '放大镜搜索词', '发布放大镜搜索词任务', DATE_SUB(NOW(), INTERVAL 7 DAY)),

-- 用户3 - 今天
(3, 'user3', 1, 12000, 0, 12000, 'recharge', NULL, NULL, NULL, '用户充值', NOW()),
(3, 'user3', 2, 2500, 12000, 9500, 'task_publish', 7, 1, '上评评论', '发布上评评论任务', NOW()),
(3, 'user3', 2, 1200, 9500, 8300, 'account_rental', 3, 7, '求租订单', '求租账号', NOW()),

-- 用户3 - 昨天
(3, 'user3', 2, 3000, 8300, 5300, 'task_publish', 8, 4, '上中评评论', '发布上中评评论任务', DATE_SUB(NOW(), INTERVAL 1 DAY)),

-- 用户4 - 今天
(4, 'user4', 1, 9000, 0, 9000, 'recharge', NULL, NULL, NULL, '用户充值', NOW()),
(4, 'user4', 2, 2100, 9000, 6900, 'task_publish', 9, 2, '中评评论', '发布中评评论任务', NOW()),
(4, 'user4', 2, 1800, 6900, 5100, 'task_publish', 10, 5, '中下评评论', '发布中下评评论任务', NOW());

SET FOREIGN_KEY_CHECKS = 1;