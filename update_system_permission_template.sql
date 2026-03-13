-- 更新system_permission_template表，添加B端用户交易流水导航栏面板
INSERT INTO `system_permission_template` (`name`, `code`, `icon`, `parent_id`, `sort_order`, `status`, `url`, `created_at`, `updated_at`)
VALUES ('B端用户交易流水', 'b-statistics', 'ri-bank-card-line', 0, 99, 1, 'assets/html/b-statistics.html', NOW(), NOW());

