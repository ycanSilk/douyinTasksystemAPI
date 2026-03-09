-- 更新bt_task_platform数据库结构，添加封禁相关字段
-- 为c_users表添加封禁相关字段
ALTER TABLE c_users
ADD COLUMN blocked_status TINYINT NOT NULL DEFAULT 0 COMMENT '封禁状态：0=不禁止，1=禁止接单，2=禁止登陆',
ADD COLUMN blocked_start_time DATETIME NULL COMMENT '封禁开始时间',
ADD COLUMN blocked_duration INT NULL COMMENT '封禁时长（单位：小时）',
ADD COLUMN blocked_end_time DATETIME NULL COMMENT '自动解禁时间',
ADD INDEX idx_blocked_status (blocked_status) USING BTREE,
ADD INDEX idx_blocked_end_time (blocked_end_time) USING BTREE;

-- 为app_config表添加通知相关配置
INSERT IGNORE INTO app_config (config_key, config_value, config_type, config_group, description, updated_at)
VALUES 
('notification_enabled', '1', 'boolean', 'notification', '是否启用消息通知', CURRENT_TIMESTAMP),
('notification_sound_enabled', '1', 'boolean', 'notification', '是否启用通知提示音', CURRENT_TIMESTAMP),
('notification_check_interval', '60', 'int', 'notification', '通知检测间隔（秒）', CURRENT_TIMESTAMP),
('notification_max_unread', '50', 'int', 'notification', '最大未读通知数量', CURRENT_TIMESTAMP),
('notification_types', 'recharge,withdraw,agent,magnifier,rental,ticket,system', 'array', 'notification', '启用的通知类型', CURRENT_TIMESTAMP);

-- 创建通知相关表（如果不存在）
CREATE TABLE IF NOT EXISTS `admin_system_notification` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `type` enum('recharge','withdraw','agent','magnifier','rental','ticket','system') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知类型',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知内容',
  `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '状态：0-未读，1-已读',
  `priority` tinyint(1) NOT NULL DEFAULT 0 COMMENT '优先级：0-普通，1-重要',
  `data` json NULL COMMENT '附加数据',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_type_status`(`type` ASC, `status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统通知表' ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `admin_system_notification_config` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知类型编码',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知类型名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '通知类型描述',
  `enabled` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否启用：0-禁用，1-启用',
  `detection_interval` int UNSIGNED NOT NULL DEFAULT 60 COMMENT '检测间隔（秒）',
  `judgment_condition` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '通知判断条件',
  `priority` tinyint(1) NOT NULL DEFAULT 0 COMMENT '默认优先级：0-普通，1-重要',
  `notification_template` json NULL COMMENT '通知模板',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_code`(`code` ASC) USING BTREE,
  INDEX `idx_enabled`(`enabled` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '通知配置表' ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `admin_system_notification_log` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `detection_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '检测时间',
  `has_new_notification` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否有新通知：0-无，1-有',
  `notification_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '本次检测新增通知数量',
  `detection_result` json NULL COMMENT '检测结果详情',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_detection_time`(`detection_time` ASC) USING BTREE,
  INDEX `idx_has_new_notification`(`has_new_notification` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '通知检测日志表' ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `admin_system_notification_magnifier_count` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `current_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '当前任务数量',
  `previous_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '上次任务数量',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `last_viewed_count` int NOT NULL DEFAULT 0 COMMENT '上次查看时的任务数量',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_updated_at`(`updated_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '放大镜任务数量记录表' ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `admin_system_notification_timer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `last_detection_time` datetime NOT NULL,
  `next_detection_time` datetime NOT NULL,
  `detection_interval` int NOT NULL DEFAULT 60,
  `status` tinyint NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '消息通知检测计时器倒计时' ROW_FORMAT = Dynamic;

-- 插入通知配置数据
INSERT IGNORE INTO `admin_system_notification_config` (`code`, `name`, `description`, `enabled`, `detection_interval`, `judgment_condition`, `priority`, `notification_template`, `created_at`, `updated_at`)
VALUES
('recharge', '充值审核', '检测充值申请待审核数量', 1, 60, 'count > 0', 1, '{"title": "充值审核提醒", "content": "有{count}条充值申请待审核"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('withdraw', '提现审核', '检测提现申请待审核数量', 1, 60, 'count > 0', 1, '{"title": "提现审核提醒", "content": "有{count}条提现申请待审核"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('agent', '团长审核', '检测团长申请待审核数量', 1, 60, 'count > 0', 1, '{"title": "团长审核提醒", "content": "有{count}条团长申请待审核"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('magnifier', '放大镜任务', '检测放大镜任务数量变化', 1, 60, 'count > 0', 0, '{"title": "放大镜任务提醒", "content": "有{count}个新的放大镜任务"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('rental', '租赁处理', '检测待客服处理的租赁订单', 1, 60, 'count > 0', 1, '{"title": "租赁处理提醒", "content": "有{count}个租赁订单待处理"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('ticket', '工单管理', '检测工单待处理数量', 1, 60, 'count > 0', 1, '{"title": "工单提醒", "content": "有{count}个工单待处理"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('system', '系统通知', '系统级别的通知', 1, 3600, 'true', 0, '{"title": "系统通知", "content": "{content}"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 初始化通知计时器
INSERT IGNORE INTO `admin_system_notification_timer` (`last_detection_time`, `next_detection_time`, `detection_interval`, `status`, `created_at`, `updated_at`)
VALUES (NOW(), DATE_ADD(NOW(), INTERVAL 60 SECOND), 60, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 初始化放大镜任务数量记录
INSERT IGNORE INTO `admin_system_notification_magnifier_count` (`current_count`, `previous_count`, `last_viewed_count`, `updated_at`)
VALUES (0, 0, 0, CURRENT_TIMESTAMP);
