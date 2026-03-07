-- 系统通知表
CREATE TABLE `admin_system_notification` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `type` ENUM('recharge', 'withdraw', 'agent', 'magnifier', 'rental', 'ticket', 'system') NOT NULL COMMENT '通知类型',
  `title` VARCHAR(100) NOT NULL COMMENT '通知标题',
  `content` TEXT NOT NULL COMMENT '通知内容',
  `status` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '状态：0-未读，1-已读',
  `priority` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '优先级：0-普通，1-重要',
  `data` JSON DEFAULT NULL COMMENT '附加数据',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_type_status` (`type`, `status`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统通知表';

-- 通知检测日志表
CREATE TABLE `admin_system_notification_log` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `detection_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '检测时间',
  `has_new_notification` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否有新通知：0-无，1-有',
  `notification_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '本次检测新增通知数量',
  `detection_result` JSON DEFAULT NULL COMMENT '检测结果详情',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  INDEX `idx_detection_time` (`detection_time`),
  INDEX `idx_has_new_notification` (`has_new_notification`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通知检测日志表';

-- 通知配置表
CREATE TABLE `admin_system_notification_config` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(50) NOT NULL COMMENT '通知类型编码',
  `name` VARCHAR(100) NOT NULL COMMENT '通知类型名称',
  `description` TEXT DEFAULT NULL COMMENT '通知类型描述',
  `enabled` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否启用：0-禁用，1-启用',
  `detection_interval` INT UNSIGNED NOT NULL DEFAULT 60 COMMENT '检测间隔（秒）',
  `judgment_condition` TEXT DEFAULT NULL COMMENT '通知判断条件',
  `priority` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '默认优先级：0-普通，1-重要',
  `notification_template` JSON DEFAULT NULL COMMENT '通知模板',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_code` (`code`),
  INDEX `idx_enabled` (`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通知配置表';

-- 插入默认配置数据
INSERT INTO `admin_system_notification_config` (`code`, `name`, `description`, `enabled`, `detection_interval`, `judgment_condition`, `priority`, `notification_template`) VALUES
('recharge', '充值审核', '检测充值申请待审核数量', 1, 60, 'count > 0', 1, '{"title": "充值审核提醒", "content": "有{count}条充值申请待审核"}'),
('withdraw', '提现审核', '检测提现申请待审核数量', 1, 60, 'count > 0', 1, '{"title": "提现审核提醒", "content": "有{count}条提现申请待审核"}'),
('agent', '团长审核', '检测团长申请待审核数量', 1, 60, 'count > 0', 1, '{"title": "团长审核提醒", "content": "有{count}条团长申请待审核"}'),
('magnifier', '放大镜任务', '检测放大镜任务数量变化', 1, 60, 'count > 0', 0, '{"title": "放大镜任务提醒", "content": "有{count}个新的放大镜任务"}'),
('rental', '租赁处理', '检测待客服处理的租赁订单', 1, 60, 'count > 0', 1, '{"title": "租赁处理提醒", "content": "有{count}个租赁订单待处理"}'),
('ticket', '工单管理', '检测工单待处理数量', 1, 60, 'count > 0', 1, '{"title": "工单提醒", "content": "有{count}个工单待处理"}'),
('system', '系统通知', '系统级别的通知', 1, 3600, 'true', 0, '{"title": "系统通知", "content": "{content}"}');
