-- 创建系统权限模板表
CREATE TABLE IF NOT EXISTS `system_permission_template` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL COMMENT '导航名称',
  `code` varchar(50) NOT NULL COMMENT '导航代码',
  `icon` varchar(50) NOT NULL COMMENT '图标类名',
  `sort_order` int(11) NOT NULL DEFAULT '0' COMMENT '排序值',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态 1:启用 0:禁用',
  `description` varchar(255) DEFAULT NULL COMMENT '描述',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统权限模板表';

-- 创建角色权限模板关联表
CREATE TABLE IF NOT EXISTS `system_role_permission_template` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) NOT NULL COMMENT '角色ID',
  `template_id` int(11) NOT NULL COMMENT '权限模板ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_template` (`role_id`,`template_id`),
  KEY `role_id` (`role_id`),
  KEY `template_id` (`template_id`),
  CONSTRAINT `system_role_permission_template_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `system_roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `system_role_permission_template_ibfk_2` FOREIGN KEY (`template_id`) REFERENCES `system_permission_template` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色权限模板关联表';

-- 插入默认导航面板数据
INSERT INTO `system_permission_template` (`name`, `code`, `icon`, `sort_order`, `status`, `description`) VALUES
('统计面板', 'dashboard', 'ri-dashboard-line', 1, 1, '运营概览和数据统计'),
('B端用户管理', 'b-users', 'ri-group-line', 2, 1, '管理B端用户账号'),
('C端用户管理', 'c-users', 'ri-user-line', 3, 1, '管理C端用户账号'),
('充值审核', 'recharge', 'ri-money-cny-circle-line', 4, 1, '审核用户充值申请'),
('提现审核', 'withdraw', 'ri-wallet-line', 5, 1, '审核用户提现申请'),
('任务模板管理', 'templates', 'ri-file-list-line', 6, 1, '管理任务模板'),
('任务市场管理', 'market', 'ri-store-line', 7, 1, '监控任务市场'),
('钱包记录管理', 'wallet-logs', 'ri-bank-card-line', 8, 1, '管理钱包资金记录'),
('团长审核', 'agent', 'ri-user-star-line', 9, 1, '审核团长申请'),
('租赁处理', 'rental-orders', 'ri-home-line', 10, 1, '处理租赁订单'),
('工单管理', 'rental-tickets', 'ri-clipboard-line', 11, 1, '管理工单'),
('网站配置', 'system-config', 'ri-settings-line', 12, 1, '管理网站系统配置'),
('任务审核', 'task-review', 'ri-check-double-line', 13, 1, '审核B端任务'),
('系统通知', 'notifications', 'ri-notification-line', 14, 1, '管理系统通知'),
('系统用户管理', 'system-users', 'ri-admin-line', 15, 1, '管理系统用户'),
('角色管理', 'system-roles', 'ri-shield-keyhole-line', 16, 1, '管理系统角色'),
('权限管理', 'system-permissions', 'ri-lock-unlock-line', 17, 1, '管理系统权限'),
('放大镜任务', 'magnifier', 'ri-search-line', 18, 1, '管理放大镜任务');

-- 为超级管理员角色分配所有权限
-- 假设超级管理员角色ID为1
INSERT INTO `system_role_permission_template` (`role_id`, `template_id`) 
SELECT 1, id FROM `system_permission_template`;