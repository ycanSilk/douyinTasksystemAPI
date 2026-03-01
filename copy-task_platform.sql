-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- 主机： localhost
-- 生成日期： 2026-03-01 11:33:24
-- 服务器版本： 8.0.36
-- PHP 版本： 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 数据库： `task_platform`
--

-- --------------------------------------------------------

--
-- 表的结构 `agent_applications`
--

CREATE TABLE `agent_applications` (
  `id` bigint UNSIGNED NOT NULL COMMENT '申请ID',
  `c_user_id` bigint UNSIGNED NOT NULL COMMENT 'C端用户ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（冗余字段）',
  `invite_code` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邀请码（冗余字段）',
  `apply_type` tinyint NOT NULL DEFAULT '1' COMMENT '申请类型：1=普通团长，2=高级团长',
  `valid_invites` int UNSIGNED NOT NULL DEFAULT '0' COMMENT '有效邀请人数（申请时的快照）',
  `total_invites` int UNSIGNED NOT NULL DEFAULT '0' COMMENT '总邀请人数（申请时的快照）',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '审核状态：0=待审核，1=审核通过，2=审核拒绝',
  `reject_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '拒绝原因',
  `admin_id` bigint UNSIGNED DEFAULT NULL COMMENT '审核管理员ID',
  `reviewed_at` datetime DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='团长申请表-C端用户申请成为团长';

-- --------------------------------------------------------

--
-- 表的结构 `app_config`
--

CREATE TABLE `app_config` (
  `id` int UNSIGNED NOT NULL COMMENT '配置ID',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置键名',
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置值',
  `config_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'string' COMMENT '配置类型：string, int, float, boolean, json, array',
  `config_group` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'general' COMMENT '配置分组：general, withdraw, task, rental等',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '配置描述',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='网站配置表';

--
-- 转存表中的数据 `app_config`
--

INSERT INTO `app_config` (`id`, `config_key`, `config_value`, `config_type`, `config_group`, `description`, `updated_at`) VALUES
(1, 'website', 'https://api.kktaskpaas.com/', 'string', 'general', '网站地址', '2026-02-28 21:29:30'),
(2, 'upload_path', './img', 'string', 'general', '上传文件路径', '2026-02-15 14:51:56'),
(3, 'platform_fee_rate', '0.25', 'float', 'general', '平台抽成比例（0.25 = 25%）', '2026-02-15 14:51:56'),
(4, 'task_submit_timeout', '600', 'int', 'task', '任务提交超时时间（秒）', '2026-02-15 14:51:56'),
(7, 'c_withdraw_min_amount', '1', 'int', 'withdraw', 'C端每次提现最低金额（元）', '2026-02-23 20:53:03'),
(8, 'c_withdraw_max_amount', '500', 'int', 'withdraw', 'C端每次提现最高金额（元）', '2026-02-15 14:51:56'),
(9, 'c_withdraw_amount_multiple', '1', 'int', 'withdraw', 'C端提现金额必须是此数的整数倍', '2026-02-23 20:53:12'),
(10, 'c_withdraw_daily_limit', '1000', 'int', 'withdraw', 'C端每天提现总额限制（元）', '2026-02-15 14:51:56'),
(11, 'c_withdraw_allowed_weekdays', '0,1,2,3,4,5,6', 'array', 'withdraw', '允许提现的星期几（0=周日,1-6=周一至周六，多个用逗号分隔）', '2026-02-24 15:34:06'),
(12, 'b_withdraw_min_amount', '100', 'int', 'withdraw', 'B端每次提现最低金额（元）', '2026-02-15 14:51:56'),
(13, 'b_withdraw_max_amount', '5000', 'int', 'withdraw', 'B端每次提现最高金额（元）', '2026-02-15 14:51:56'),
(14, 'b_withdraw_daily_limit', '10000', 'int', 'withdraw', 'B端每天提现总额限制（元）', '2026-02-15 14:51:56'),
(15, 'rental_platform_rate', '25', 'int', 'rental', '租赁订单平台抽成比例（%）', '2026-02-15 14:51:56'),
(16, 'rental_platform_fee_rate', '0.25', 'float', 'rental', '租赁系统平台抽成比例（小数形式，兼容旧代码）', '2026-02-15 14:51:56'),
(17, 'c_withdraw_fee_rate', '0.03', 'float', 'withdraw', 'C端提现手续费比例（0.03=3%）', '2026-02-21 17:33:08'),
(18, 'senior_agent_required_active_users', '30', 'int', 'task', '申请高级团长需要的有效活跃用户数', '2026-02-26 11:25:04'),
(19, 'senior_agent_active_user_task_count', '10', 'int', 'task', '有效活跃用户需完成的任务数', '2026-02-26 11:25:25'),
(20, 'senior_agent_active_user_hours', '48', 'int', 'task', '有效活跃用户注册后需在多少小时内完成任务', '2026-02-26 11:25:30'),
(21, 'senior_agent_max_count', '100', 'int', 'task', '高级团长数量上限', '2026-02-26 11:25:39'),
(23, 'agent_required_active_users', '5', 'int', 'task', '申请普通团长需要的有效活跃用户数', '2026-02-25 10:50:57'),
(24, 'agent_active_user_task_count', '5', 'int', 'task', '普通团长有效活跃用户需完成的任务数', '2026-02-26 11:24:36'),
(25, 'agent_active_user_hours', '24', 'int', 'task', '普通团长有效活跃用户注册后需在多少小时内完成任务', '2026-02-24 15:09:12'),
(26, 'agent_incentive_enabled', '1', 'int', 'incentive', '团长激励活动开关', '2026-02-21 19:31:16'),
(27, 'agent_incentive_end_time', '2099-12-31 23:59:59', 'string', 'incentive', '团长激励活动终止时间', '2026-02-21 19:24:37'),
(28, 'agent_incentive_amount', '1000', 'int', 'incentive', '团长激励金额（分）', '2026-02-26 11:26:41'),
(29, 'agent_incentive_min_withdraw', '10000', 'int', 'incentive', '触发激励最低提现金额（分）', '2026-02-26 11:26:36'),
(30, 'agent_incentive_limit_enabled', '1', 'int', 'incentive', '人数限制开关', '2026-02-23 21:06:59'),
(31, 'agent_incentive_limit_count', '5', 'int', 'incentive', '每个团长最多激励次数', '2026-02-24 15:52:44'),
(32, 'rental_seller_rate', '70', 'int', 'rental', '租赁卖方分成比例（%）', '2026-02-26 11:26:20'),
(33, 'rental_agent_rate', '5', 'int', 'rental', '租赁普通团长分成比例（%）', '2026-02-26 11:26:09'),
(34, 'rental_senior_agent_rate', '5', 'int', 'rental', '租赁高级团长分成比例（%）', '2026-02-26 11:26:13'),
(35, 'commission_c_user', '0', 'int', 'task', 'C端用户佣金比例（%）', '2026-02-26 11:25:53'),
(36, 'commission_agent', '0', 'int', 'task', '团长（代理）佣金比例（%）', '2026-02-25 15:03:32');

-- --------------------------------------------------------

--
-- 表的结构 `b_tasks`
--

CREATE TABLE `b_tasks` (
  `id` bigint UNSIGNED NOT NULL COMMENT '任务ID',
  `b_user_id` bigint UNSIGNED NOT NULL COMMENT 'B端用户ID',
  `combo_task_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '组合任务标识（同一组合任务共享）',
  `stage` tinyint NOT NULL DEFAULT '0' COMMENT '阶段：0=单任务，1=阶段1，2=阶段2',
  `stage_status` tinyint NOT NULL DEFAULT '1' COMMENT '阶段状态：0=未开放，1=已开放，2=已完成',
  `parent_task_id` bigint UNSIGNED DEFAULT NULL COMMENT '父任务ID（阶段2指向阶段1）',
  `template_id` int UNSIGNED NOT NULL COMMENT '任务模板ID',
  `video_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '视频链接（阶段2创建时为空，等阶段1完成后分配）',
  `deadline` int UNSIGNED NOT NULL COMMENT '到期时间（10位时间戳-秒级）',
  `recommend_marks` json DEFAULT NULL COMMENT '推荐评论（JSON数组）',
  `task_count` int UNSIGNED NOT NULL DEFAULT '0' COMMENT '任务总数量（评论数组长度）',
  `task_done` int UNSIGNED NOT NULL DEFAULT '0' COMMENT '已完成数量（已通过审核）',
  `task_doing` int UNSIGNED NOT NULL DEFAULT '0' COMMENT '进行中数量（C端正在做）',
  `task_reviewing` int UNSIGNED NOT NULL DEFAULT '0' COMMENT '待审核数量（已提交待审核）',
  `unit_price` decimal(18,2) NOT NULL DEFAULT '0.00' COMMENT '单价（元，从模板获取）',
  `total_price` decimal(18,2) NOT NULL DEFAULT '0.00' COMMENT '总价（元，单价*数量）',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：1=进行中，2=已完成，3=已取消，0=已过期',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `completed_at` datetime DEFAULT NULL COMMENT '完成时间（任务完成时记录）'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='B端发布任务表-商家派单';

--
-- 转存表中的数据 `b_tasks`
--

INSERT INTO `b_tasks` (`id`, `b_user_id`, `combo_task_id`, `stage`, `stage_status`, `parent_task_id`, `template_id`, `video_url`, `deadline`, `recommend_marks`, `task_count`, `task_done`, `task_doing`, `task_reviewing`, `unit_price`, `total_price`, `status`, `created_at`, `updated_at`, `completed_at`) VALUES
(1, 2, NULL, 0, 1, NULL, 1, '5.89 复制打开抖音，看看【辉总不累的作品】  https://v.douyin.com/jmtVNF6KEQQ/ 04/19 d@N.Wm zGI:/', 1772189758, '[{\"at_user\": \"\", \"comment\": \"还好遇见梅姐，每天肚子都吃得饱饱的😋\", \"image_url\": \"http://54.179.253.64:28806/img/6c031bd126d19509ddceb060e2c1d77f.jpg\"}, {\"at_user\": \"\", \"comment\": \"还好遇见梅姐，每天肚子都吃得饱饱的😋\", \"image_url\": \"http://54.179.253.64:28806/img/5f66e00f02b672e9ecb1cf1140586079.jpg\"}]', 2, 0, 0, 0, 3.00, 6.00, 0, '2026-02-27 18:25:58', '2026-02-27 18:56:02', NULL),
(2, 2, NULL, 0, 1, NULL, 2, '9:/Y.. 07/31 o@Q.Kj 复制打开抖音，查看【辉总不累】发布作品的评论：死磕，做到极致。➝➝o7wgJAyHg49ŠŠ', 1772190077, '[{\"at_user\": \"\", \"comment\": \"有你真好，梅姐\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"123456789224\", \"image_url\": \"\"}]', 2, 0, 0, 0, 2.00, 4.00, 0, '2026-02-27 18:31:19', '2026-02-27 19:02:01', NULL),
(3, 2, NULL, 0, 1, NULL, 1, '5-- 02/02 i@p.QX 复制打开抖音，查看【让我再次去思念】发布作品的评论：又几有道理喔，怪唔知得啲:/ 师奶咁钟意用荷花做微信头像...^^5iKugrrLi49※※', 1772293474, '[{\"at_user\": \"\", \"comment\": \"那天人山人海，没好意思去拜就走了😅 但听说真的超准！\", \"image_url\": \"\"}]', 1, 0, 0, 0, 3.00, 3.00, 0, '2026-02-28 23:34:35', '2026-02-28 23:45:01', NULL),
(4, 1, NULL, 0, 1, NULL, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', 1773072000, '[{\"comment\": \"测试上评评论\", \"image_url\": \"\"}]', 1, 0, 0, 1, 3.00, 3.00, 1, '2026-03-01 00:34:05', '2026-03-01 01:00:51', NULL);

-- --------------------------------------------------------

--
-- 表的结构 `b_users`
--

CREATE TABLE `b_users` (
  `id` bigint UNSIGNED NOT NULL COMMENT 'B端用户ID',
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（必填，登录账号）',
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邮箱（必填）',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '手机号（选填）',
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码哈希',
  `organization_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '组织名称',
  `organization_leader` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '组织负责人名称',
  `token` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '当前有效Token（base64格式）',
  `token_expired_at` datetime DEFAULT NULL COMMENT 'Token过期时间',
  `wallet_id` bigint UNSIGNED NOT NULL COMMENT '关联钱包ID',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：1=正常，0=禁用',
  `reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '禁用原因',
  `create_ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '注册IP地址（支持IPv6）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='B端用户表-商家端';

--
-- 转存表中的数据 `b_users`
--

INSERT INTO `b_users` (`id`, `username`, `email`, `phone`, `password_hash`, `organization_name`, `organization_leader`, `token`, `token_expired_at`, `wallet_id`, `status`, `reason`, `create_ip`, `created_at`, `updated_at`) VALUES
(1, 'Ceshi', '271010169@qq.com', NULL, '$2y$10$SV7dHV/yam2IcgV5SmbbKur8TrpohySzBEQ032nQouiOnaBgmTWp6', 'Meili', 'Meili', 'eyJ1c2VyX2lkIjoxLCJ0eXBlIjoyLCJleHAiOjE3NzI5MDI5MTB9', '2026-03-08 01:01:50', 1, 1, NULL, '34.143.229.197', '2026-02-27 11:49:20', '2026-03-01 01:01:50'),
(2, 'Ceshi1', '459312160@qq.com', NULL, '$2y$10$F0HHwcgbu5Qh.xkir2UCcul4OHQPBYXwr970M4kIFVmdeZaDeh6ca', 'Meili', 'Meili', 'eyJ1c2VyX2lkIjoyLCJ0eXBlIjoyLCJleHAiOjE3NzI4OTc1MjZ9', '2026-03-07 23:32:06', 2, 1, NULL, '34.143.229.197', '2026-02-27 12:02:50', '2026-02-28 23:32:06'),
(3, 'task', 'task@qq.com', NULL, '$2y$10$0PP6e.WnVHlu89mCdThwjemgzakVTpxzv021Cib9Yf/HULOolAhfK', 'task', 'task', 'eyJ1c2VyX2lkIjozLCJ0eXBlIjoyLCJleHAiOjE3NzI5MDMyMjZ9', '2026-03-08 01:07:06', 7, 1, NULL, '223.74.60.135', '2026-03-01 00:48:16', '2026-03-01 01:07:06');

-- --------------------------------------------------------

--
-- 表的结构 `c_task_records`
--

CREATE TABLE `c_task_records` (
  `id` bigint UNSIGNED NOT NULL COMMENT '记录ID',
  `c_user_id` bigint UNSIGNED NOT NULL COMMENT 'C端用户ID',
  `b_task_id` bigint UNSIGNED NOT NULL COMMENT 'B端任务ID',
  `b_user_id` bigint UNSIGNED NOT NULL COMMENT 'B端用户ID（发布者）',
  `template_id` int UNSIGNED NOT NULL COMMENT '任务模板ID',
  `video_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '视频链接',
  `recommend_mark` json DEFAULT NULL COMMENT '分配的推荐评论（comment和image_url）',
  `comment_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户提交的评论链接',
  `screenshot_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户提交的截图',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：1=进行中(doing)，2=待审核(reviewing)，3=已通过(approved)，4=已驳回(rejected)',
  `reject_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '驳回原因',
  `reward_amount` bigint NOT NULL DEFAULT '0' COMMENT '奖励金额（单位：分）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '接单时间',
  `submitted_at` datetime DEFAULT NULL COMMENT '提交时间',
  `reviewed_at` datetime DEFAULT NULL COMMENT '审核时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='C端任务记录表-接单执行审核全流程';

--
-- 转存表中的数据 `c_task_records`
--

INSERT INTO `c_task_records` (`id`, `c_user_id`, `b_task_id`, `b_user_id`, `template_id`, `video_url`, `recommend_mark`, `comment_url`, `screenshot_url`, `status`, `reject_reason`, `reward_amount`, `created_at`, `submitted_at`, `reviewed_at`) VALUES
(1, 2, 2, 2, 2, '9:/Y.. 07/31 o@Q.Kj 复制打开抖音，查看【辉总不累】发布作品的评论：死磕，做到极致。➝➝o7wgJAyHg49ŠŠ', '{\"at_user\": \"\", \"comment\": \"123456789224\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 80, '2026-02-27 18:31:47', NULL, NULL),
(2, 3, 2, 2, 2, '9:/Y.. 07/31 o@Q.Kj 复制打开抖音，查看【辉总不累】发布作品的评论：死磕，做到极致。➝➝o7wgJAyHg49ŠŠ', '{\"at_user\": \"\", \"comment\": \"有你真好，梅姐\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 80, '2026-02-27 18:36:54', NULL, NULL),
(3, 2, 4, 1, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试上评评论\", \"image_url\": \"\"}', NULL, NULL, 5, NULL, 100, '2026-03-01 00:36:33', NULL, NULL),
(4, 5, 4, 1, 1, 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '{\"comment\": \"测试上评评论\", \"image_url\": \"\"}', 'https://www.douyin.com/jingxuan?modal_id=7577335582393699638', '[\"\"]', 2, NULL, 100, '2026-03-01 01:00:34', '2026-03-01 01:00:51', NULL);

-- --------------------------------------------------------

--
-- 表的结构 `c_users`
--

CREATE TABLE `c_users` (
  `id` bigint UNSIGNED NOT NULL COMMENT 'C端用户ID',
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（必填，登录账号）',
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邮箱（必填）',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '手机号（选填）',
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码哈希',
  `invite_code` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邀请码（6位数字字母组合，唯一）',
  `parent_id` bigint UNSIGNED DEFAULT NULL COMMENT '上级用户ID（邀请人ID）',
  `is_agent` tinyint NOT NULL DEFAULT '0' COMMENT '代理身份：0=未激活团长，1=团长',
  `token` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '当前有效Token（base64格式）',
  `token_expired_at` datetime DEFAULT NULL COMMENT 'Token过期时间',
  `wallet_id` bigint UNSIGNED NOT NULL COMMENT '关联钱包ID',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：1=正常，0=禁用',
  `reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '禁用原因',
  `create_ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '注册IP地址（支持IPv6）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='C端用户表-消费者端';

--
-- 转存表中的数据 `c_users`
--

INSERT INTO `c_users` (`id`, `username`, `email`, `phone`, `password_hash`, `invite_code`, `parent_id`, `is_agent`, `token`, `token_expired_at`, `wallet_id`, `status`, `reason`, `create_ip`, `created_at`, `updated_at`) VALUES
(1, 'taskadmin', 'taskadmin@qq.com', NULL, '$2y$10$9gww7TqOTzSA9SqchkFEgeYftRKlJ4ciYWL6IiD8DPUbQv8/PnCGe', 'W6XMFJ', NULL, 0, 'eyJ1c2VyX2lkIjoxLCJ0eXBlIjoxLCJleHAiOjE3NzI3NzM1OTN9', '2026-03-06 13:06:33', 3, 1, NULL, '120.237.23.202', '2026-02-27 13:06:22', '2026-02-27 13:06:33'),
(2, 'Ceshi', '12345678@qq.com', '13112345678', '$2y$10$lvlxvu.NzhAs6m7ID2fNg.lSn.cl/hytp6/1XIAEVeA3RRYtmmH4u', '6YHUBA', NULL, 0, 'eyJ1c2VyX2lkIjoyLCJ0eXBlIjoxLCJleHAiOjE3NzI5MDI3MTZ9', '2026-03-08 00:58:36', 4, 1, NULL, '34.143.229.197', '2026-02-27 17:24:33', '2026-03-01 00:58:36'),
(3, 'Ceshi2', '123456789@qq.com', '13212345678', '$2y$10$Cvl7CIY5Oj2gPcKSvNE2mONLRs14Rr1ndstVn2FHJlco8GmXxS586', 'MCVFM9', NULL, 0, 'eyJ1c2VyX2lkIjozLCJ0eXBlIjoxLCJleHAiOjE3NzI3OTMxODh9', '2026-03-06 18:33:08', 5, 1, NULL, '34.143.229.197', '2026-02-27 17:26:28', '2026-02-27 18:33:08'),
(4, 'Ceshi3', '123455677@qq.com', '13312345678', '$2y$10$qydW3B1EXlxJou5CUfPMaOvssOD/K8GugvQh.BeeX/KGBpPGC3awq', 'CZBBF5', NULL, 0, 'eyJ1c2VyX2lkIjo0LCJ0eXBlIjoxLCJleHAiOjE3NzI3ODk0Njh9', '2026-03-06 17:31:08', 6, 1, NULL, '34.143.229.197', '2026-02-27 17:31:08', '2026-02-27 17:31:08'),
(5, 'test', 'test@qq.com', '15900000011', '$2y$10$ssuf1ILBW1q1Wg9AQZg5tuUFOy1x5ZVcfN0YBqdY4cpVXPZrANPAC', 'TX5ECJ', NULL, 0, 'eyJ1c2VyX2lkIjo1LCJ0eXBlIjoxLCJleHAiOjE3NzI5MDI4MTh9', '2026-03-08 01:00:18', 8, 1, NULL, '223.74.60.135', '2026-03-01 00:53:23', '2026-03-01 01:00:18');

-- --------------------------------------------------------

--
-- 表的结构 `c_user_daily_stats`
--

CREATE TABLE `c_user_daily_stats` (
  `id` bigint UNSIGNED NOT NULL COMMENT '主键ID',
  `c_user_id` bigint UNSIGNED NOT NULL COMMENT 'C端用户ID',
  `stat_date` date NOT NULL COMMENT '统计日期',
  `accept_count` int UNSIGNED NOT NULL DEFAULT '0' COMMENT '当日接单次数',
  `submit_count` int UNSIGNED NOT NULL DEFAULT '0' COMMENT '当日提交次数',
  `approved_count` int UNSIGNED NOT NULL DEFAULT '0' COMMENT '当日通过次数',
  `rejected_count` int UNSIGNED NOT NULL DEFAULT '0' COMMENT '当日驳回次数',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='C端用户每日统计表-限制驳回次数';

--
-- 转存表中的数据 `c_user_daily_stats`
--

INSERT INTO `c_user_daily_stats` (`id`, `c_user_id`, `stat_date`, `accept_count`, `submit_count`, `approved_count`, `rejected_count`, `created_at`, `updated_at`) VALUES
(1, 2, '2026-02-27', 1, 0, 0, 0, '2026-02-27 18:31:47', '2026-02-27 18:31:47'),
(2, 3, '2026-02-27', 1, 0, 0, 0, '2026-02-27 18:36:54', '2026-02-27 18:36:54'),
(3, 2, '2026-03-01', 1, 0, 0, 0, '2026-03-01 00:36:33', '2026-03-01 00:36:33'),
(4, 5, '2026-03-01', 1, 1, 0, 0, '2026-03-01 01:00:34', '2026-03-01 01:00:51');

-- --------------------------------------------------------

--
-- 表的结构 `notifications`
--

CREATE TABLE `notifications` (
  `id` bigint UNSIGNED NOT NULL COMMENT '通知ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知内容',
  `target_type` tinyint NOT NULL DEFAULT '0' COMMENT '目标类型：0=全体，1=C端全体，2=B端全体，3=指定用户',
  `target_user_id` bigint UNSIGNED DEFAULT NULL COMMENT '目标用户ID（target_type=3时使用）',
  `target_user_type` tinyint DEFAULT NULL COMMENT '目标用户类型（target_type=3时使用，1=C端，2=B端）',
  `sender_type` tinyint NOT NULL DEFAULT '3' COMMENT '发送者类型：1=系统自动，3=Admin',
  `sender_id` bigint UNSIGNED DEFAULT NULL COMMENT '发送者ID（Admin ID，预留字段）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统通知表-通知模板';

--
-- 转存表中的数据 `notifications`
--

INSERT INTO `notifications` (`id`, `title`, `content`, `target_type`, `target_user_id`, `target_user_type`, `sender_type`, `sender_id`, `created_at`) VALUES
(1, '充值审核通过', '您的充值申请已审核通过，金额：¥1,000.00 已到账。感谢您的使用！', 3, 1, 2, 1, NULL, '2026-02-27 12:49:56'),
(2, '充值审核通过', '您的充值申请已审核通过，金额：¥1,000.00 已到账。感谢您的使用！', 3, 2, 2, 1, NULL, '2026-02-27 12:49:58'),
(3, '充值审核通过', '您的充值申请已审核通过，金额：¥100.00 已到账。感谢您的使用！', 3, 2, 2, 1, NULL, '2026-02-27 14:23:06'),
(4, '充值审核通过', '您的充值申请已审核通过，金额：¥1,000.00 已到账。感谢您的使用！', 3, 1, 2, 1, NULL, '2026-02-27 14:23:08'),
(5, '充值审核通过', '您的充值申请已审核通过，金额：¥1,000.00 已到账。感谢您的使用！', 3, 2, 2, 1, NULL, '2026-02-27 14:23:13'),
(6, '收到新的应征申请', '您的求租「抖音日租」收到了新的应征，请前往查看审核', 3, 2, 2, 1, NULL, '2026-02-27 17:54:24'),
(7, '任务已超时', '您接取的任务「中评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-02-27 18:31:47\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。', 3, 2, 1, 1, NULL, '2026-02-27 18:42:02'),
(8, '任务已超时', '您接取的任务「中评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-02-27 18:36:54\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。', 3, 3, 1, 1, NULL, '2026-02-27 18:47:02'),
(9, '任务已到期下架', '您发布的任务「上评评论」已到期自动下架。\n任务进度：0/2（0%）\n截止时间：2026-02-27 18:55:58\n', 3, 2, 2, 1, NULL, '2026-02-27 18:56:02'),
(10, '任务已到期下架', '您发布的任务「中评评论」已到期自动下架。\n任务进度：0/2（0%）\n截止时间：2026-02-27 19:01:17\n', 3, 2, 2, 1, NULL, '2026-02-27 19:02:01'),
(11, '充值审核通过', '您的充值申请已审核通过，金额：¥200.00 已到账。感谢您的使用！', 3, 1, 2, 1, NULL, '2026-02-28 23:20:14'),
(12, '任务已到期下架', '您发布的任务「上评评论」已到期自动下架。\n任务进度：0/1（0%）\n截止时间：2026-02-28 23:44:34\n', 3, 2, 2, 1, NULL, '2026-02-28 23:45:01'),
(13, '求租已过期', '您的求租「抖音日租」已过期，预算金额已退回您的钱包。', 3, 2, 2, 1, NULL, '2026-03-01 00:00:04'),
(14, '任务已超时', '您接取的任务「上评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-03-01 00:36:33\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。', 3, 2, 1, 1, NULL, '2026-03-01 00:47:02'),
(15, '充值审核通过', '您的充值申请已审核通过，金额：¥2,000.00 已到账。感谢您的使用！', 3, 3, 2, 1, NULL, '2026-03-01 00:51:51'),
(16, '收到新的应征申请', '您的求租「测试求租发布」收到了新的应征，请前往查看审核', 3, 3, 2, 1, NULL, '2026-03-01 00:55:31'),
(17, '收到新的应征申请', '您的求租「测试求租发布」收到了新的应征，请前往查看审核', 3, 3, 2, 1, NULL, '2026-03-01 00:56:41');

-- --------------------------------------------------------

--
-- 表的结构 `recharge_requests`
--

CREATE TABLE `recharge_requests` (
  `id` bigint UNSIGNED NOT NULL COMMENT '充值申请ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '用户ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（冗余字段）',
  `user_type` tinyint NOT NULL COMMENT '用户类型：1=C端，2=B端',
  `wallet_id` bigint UNSIGNED NOT NULL COMMENT '钱包ID',
  `amount` bigint NOT NULL DEFAULT '0' COMMENT '充值金额（单位：分）',
  `payment_method` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '支付方式：alipay=支付宝，wechat=微信，usdt=USDT',
  `payment_voucher` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '支付凭证图片URL',
  `log_id` bigint UNSIGNED DEFAULT NULL COMMENT '关联的钱包流水ID',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '审核状态：0=待审核，1=审核通过，2=审核拒绝',
  `reject_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '拒绝原因',
  `admin_id` bigint UNSIGNED DEFAULT NULL COMMENT '审核管理员ID',
  `reviewed_at` datetime DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='充值申请表-需要管理员审核';

--
-- 转存表中的数据 `recharge_requests`
--

INSERT INTO `recharge_requests` (`id`, `user_id`, `username`, `user_type`, `wallet_id`, `amount`, `payment_method`, `payment_voucher`, `log_id`, `status`, `reject_reason`, `admin_id`, `reviewed_at`, `created_at`) VALUES
(1, 2, 'Ceshi1', 2, 2, 100000, 'alipay', 'http://54.179.253.64:28806/img/344ccc2b0873c9f91547ebce99c6434a.jpg', 1, 1, NULL, NULL, '2026-02-27 12:49:58', '2026-02-27 12:49:30'),
(2, 1, 'Ceshi', 2, 1, 100000, 'alipay', 'http://54.179.253.64:28806/img/344ccc2b0873c9f91547ebce99c6434a.jpg', 2, 1, NULL, NULL, '2026-02-27 12:49:56', '2026-02-27 12:49:46'),
(3, 2, 'Ceshi1', 2, 2, 100000, 'alipay', 'http://54.179.253.64:28806/img/5bd3c8f2949429377aeb618b1806bc00.jpg', 5, 1, NULL, NULL, '2026-02-27 14:23:13', '2026-02-27 13:17:34'),
(4, 1, 'Ceshi', 2, 1, 100000, 'alipay', 'http://54.179.253.64:28806/img/611c57187a88a0ff7dd2b378c6f265e1.jpg', 6, 1, NULL, NULL, '2026-02-27 14:23:08', '2026-02-27 13:18:09'),
(5, 2, 'Ceshi1', 2, 2, 10000, 'alipay', 'http://54.179.253.64:28806/img/ce3b52d16e59e4e5a46be99e18739ecd.jpg', 8, 1, NULL, NULL, '2026-02-27 14:23:06', '2026-02-27 14:22:20'),
(6, 1, 'Ceshi', 2, 1, 20000, 'alipay', 'https://api.kktaskpaas.com/img/15a21bda57f6cf3bc0a05e68292a82d6.jpg', 14, 1, NULL, NULL, '2026-02-28 23:20:14', '2026-02-28 23:20:05'),
(7, 3, 'task', 2, 7, 200000, 'alipay', 'https://api.kktaskpaas.com/img/15a21bda57f6cf3bc0a05e68292a82d6.jpg', 19, 1, NULL, NULL, '2026-03-01 00:51:51', '2026-03-01 00:51:42');

-- --------------------------------------------------------

--
-- 表的结构 `rental_applications`
--

CREATE TABLE `rental_applications` (
  `id` bigint UNSIGNED NOT NULL COMMENT '应征ID',
  `demand_id` bigint UNSIGNED NOT NULL COMMENT '关联的求租信息ID',
  `applicant_user_id` bigint UNSIGNED NOT NULL COMMENT '应征者用户ID',
  `applicant_user_type` tinyint NOT NULL COMMENT '应征者类型：1=C端，2=B端',
  `allow_renew` tinyint NOT NULL DEFAULT '1' COMMENT '是否允许续租：0=不允许，1=允许',
  `application_json` json DEFAULT NULL COMMENT '应征资料（账号截图、说明等）',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态：0=待审核，1=审核通过（自动生成订单），2=已驳回',
  `review_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '审核备注（通过/驳回原因）',
  `reviewed_at` datetime DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='求租应征表-我有符合要求的账号';

--
-- 转存表中的数据 `rental_applications`
--

INSERT INTO `rental_applications` (`id`, `demand_id`, `applicant_user_id`, `applicant_user_type`, `allow_renew`, `application_json`, `status`, `review_remark`, `reviewed_at`, `created_at`, `updated_at`) VALUES
(1, 1, 3, 1, 1, '{\"apply_days\": 1, \"description\": \"无异常，及时回复\", \"screenshots\": [\"https://api.kktaskpaas.com/img/35efa290342aaaec4560b84d2e134463.jpg\"]}', 0, NULL, NULL, '2026-02-27 17:54:24', '2026-02-28 23:21:52'),
(2, 2, 5, 1, 0, '{\"description\": \"账号正常，及时回复消息\", \"screenshots\": [\"https://api.kktaskpaas.com/img/15a21bda57f6cf3bc0a05e68292a82d6.jpg\"]}', 0, NULL, NULL, '2026-03-01 00:55:31', '2026-03-01 00:55:31'),
(3, 2, 2, 1, 0, '{\"description\": \"账号正常，及时回复消息,第二个接单用户应征\", \"screenshots\": [\"https://api.kktaskpaas.com/img/15a21bda57f6cf3bc0a05e68292a82d6.jpg\"]}', 0, NULL, NULL, '2026-03-01 00:56:41', '2026-03-01 00:56:41');

-- --------------------------------------------------------

--
-- 表的结构 `rental_demands`
--

CREATE TABLE `rental_demands` (
  `id` bigint UNSIGNED NOT NULL COMMENT '求租信息ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '求租方用户ID',
  `user_type` tinyint NOT NULL COMMENT '求租方类型：1=C端，2=B端',
  `wallet_id` bigint UNSIGNED NOT NULL COMMENT '钱包ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `budget_amount` bigint NOT NULL DEFAULT '0' COMMENT '预算金额（单位：分，发布时冻结）',
  `days_needed` int UNSIGNED NOT NULL COMMENT '需要租用天数',
  `deadline` datetime NOT NULL COMMENT '截止时间（最多30天）',
  `requirements_json` json DEFAULT NULL COMMENT '账号要求、登录要求等详细需求',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：0=已下架（释放冻结），1=发布中（预算已冻结），2=已成交（订单生成），3=已过期（自动下架，释放冻结）',
  `view_count` int UNSIGNED NOT NULL DEFAULT '0' COMMENT '浏览次数',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='求租信息表-账号需求市场';

--
-- 转存表中的数据 `rental_demands`
--

INSERT INTO `rental_demands` (`id`, `user_id`, `user_type`, `wallet_id`, `title`, `budget_amount`, `days_needed`, `deadline`, `requirements_json`, `status`, `view_count`, `created_at`, `updated_at`) VALUES
(1, 2, 2, 2, '抖音日租', 5000, 1, '2026-03-01 00:00:00', '{\"email\": \"\", \"post_ad\": 0, \"qq_number\": \"271010123\", \"scan_code\": 1, \"deblocking\": 1, \"post_douyin\": 0, \"phone_number\": \"\", \"phone_message\": 1, \"platform_type\": \"douyin\", \"requested_all\": 1, \"account_password\": 0, \"basic_information\": 1, \"other_requirements\": 1, \"account_requirements\": \"账号正常，及时回复消息\", \"additional_requirements\": \"\", \"additional_requirements_tag\": 0}', 3, 9, '2026-02-27 13:47:33', '2026-03-01 00:00:04'),
(2, 3, 2, 7, '测试求租发布', 5000, 2, '2026-03-10 00:00:00', '{\"deblocking\": \"true\", \"phone_number\": \"13912340001\", \"phone_message\": \"true\", \"basic_information\": \"账号正常，及时回复消息\"}', 1, 1, '2026-03-01 00:52:02', '2026-03-01 00:54:39');

-- --------------------------------------------------------

--
-- 表的结构 `rental_offers`
--

CREATE TABLE `rental_offers` (
  `id` bigint UNSIGNED NOT NULL COMMENT '出租信息ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '出租方用户ID',
  `user_type` tinyint NOT NULL COMMENT '出租方类型：1=C端，2=B端',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `price_per_day` bigint NOT NULL DEFAULT '0' COMMENT '日租金（单位：分）',
  `min_days` int UNSIGNED NOT NULL DEFAULT '1' COMMENT '最少租赁天数',
  `max_days` int UNSIGNED NOT NULL DEFAULT '30' COMMENT '最多租赁天数',
  `allow_renew` tinyint NOT NULL DEFAULT '0' COMMENT '是否允许续租：0=不允许，1=允许',
  `content_json` json DEFAULT NULL COMMENT '详细内容（账号能力、登录方式、说明、截图等）',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：0=已下架，1=上架中，2=已封禁',
  `view_count` int UNSIGNED NOT NULL DEFAULT '0' COMMENT '浏览次数',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='出租信息表-账号出租市场';

--
-- 转存表中的数据 `rental_offers`
--

INSERT INTO `rental_offers` (`id`, `user_id`, `user_type`, `title`, `price_per_day`, `min_days`, `max_days`, `allow_renew`, `content_json`, `status`, `view_count`, `created_at`, `updated_at`) VALUES
(1, 2, 2, '抖音号日租', 5000, 1, 30, 1, '{\"email\": \"\", \"images\": [\"https://api.kktaskpaas.com/img/35efa290342aaaec4560b84d2e134463.jpg\"], \"post_ad\": \"false\", \"qq_number\": \"\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"false\", \"account_info\": \"信息真实，账号正常，及时响应回消息\", \"phone_number\": \"13112345678\", \"other_require\": \"false\", \"phone_message\": \"false\", \"platform_type\": \"douyin\", \"account_password\": \"false\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}', 1, 3, '2026-02-27 13:31:54', '2026-02-28 21:31:26'),
(2, 1, 2, 'QQ号月租', 5000, 30, 31, 1, '{\"email\": \"\", \"images\": [\"https://api.kktaskpaas.com/img/35efa290342aaaec4560b84d2e134463.jpg\"], \"post_ad\": \"false\", \"qq_number\": \"\", \"scan_code\": \"true\", \"deblocking\": \"false\", \"post_douyin\": \"false\", \"account_info\": \"信息真实，账号无异常，回应消息及时\", \"phone_number\": \"13112345678\", \"other_require\": \"false\", \"phone_message\": \"false\", \"platform_type\": \"qq\", \"account_password\": \"true\", \"basic_information\": \"false\", \"identity_verification\": \"false\"}', 1, 4, '2026-02-27 13:32:43', '2026-02-28 21:31:36'),
(3, 2, 2, 'QQ号日租', 5000, 1, 30, 0, '{\"email\": \"\", \"images\": [\"https://api.kktaskpaas.com/img/35efa290342aaaec4560b84d2e134463.jpg\"], \"post_ad\": \"true\", \"qq_number\": \"\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"false\", \"account_info\": \"账号真实有效，无异常，及时回应租客消息\", \"phone_number\": \"13794719208\", \"other_require\": \"false\", \"phone_message\": \"false\", \"platform_type\": \"qq\", \"account_password\": \"true\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}', 1, 0, '2026-02-28 03:27:04', '2026-02-28 21:31:46'),
(4, 2, 2, '发布抖音日租', 5000, 1, 30, 0, '{\"email\": \"\", \"images\": [\"https://api.kktaskpaas.com/img/35efa290342aaaec4560b84d2e134463.jpg\"], \"post_ad\": \"false\", \"qq_number\": \"\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"账号真实有效，无异常，及时回应租客消息\", \"phone_number\": \"13794719208\", \"other_require\": \"false\", \"phone_message\": \"true\", \"platform_type\": \"douyin\", \"account_password\": \"false\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}', 1, 0, '2026-02-28 03:31:37', '2026-02-28 21:31:56'),
(5, 2, 2, '发布抖音日租', 5000, 1, 30, 0, '{\"email\": \"\", \"images\": [\"https://api.kktaskpaas.com/img/35efa290342aaaec4560b84d2e134463.jpg\"], \"post_ad\": \"false\", \"qq_number\": \"\", \"scan_code\": \"true\", \"deblocking\": \"false\", \"post_douyin\": \"true\", \"account_info\": \"账号真实有效，无异常，及时回应租客消息\", \"phone_number\": \"13794719208\", \"other_require\": \"false\", \"phone_message\": \"false\", \"platform_type\": \"douyin\", \"account_password\": \"false\", \"basic_information\": \"false\", \"identity_verification\": \"false\"}', 1, 0, '2026-02-28 03:35:12', '2026-02-28 21:32:05');

-- --------------------------------------------------------

--
-- 表的结构 `rental_orders`
--

CREATE TABLE `rental_orders` (
  `id` bigint UNSIGNED NOT NULL COMMENT '订单ID',
  `source_type` tinyint NOT NULL COMMENT '来源类型：0=出租信息成交，1=求租信息成交',
  `source_id` bigint UNSIGNED NOT NULL COMMENT '来源ID（offer_id或demand_id）',
  `buyer_user_id` bigint UNSIGNED NOT NULL COMMENT '买方（租用方）用户ID',
  `buyer_user_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '买方类型：b=B端，c=C端',
  `buyer_wallet_id` bigint UNSIGNED NOT NULL COMMENT '买方钱包ID',
  `buyer_info_json` json DEFAULT NULL COMMENT '买方详细信息（求租需求/下单备注等）',
  `seller_user_id` bigint UNSIGNED NOT NULL COMMENT '卖方（出租方）用户ID',
  `seller_user_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '卖方类型：b=B端，c=C端',
  `seller_wallet_id` bigint UNSIGNED NOT NULL COMMENT '卖方钱包ID',
  `seller_info_json` json DEFAULT NULL COMMENT '卖方详细信息（账号信息/应征资料等）',
  `agent_user_id` bigint UNSIGNED DEFAULT NULL COMMENT '团长用户ID',
  `agent_amount` bigint NOT NULL DEFAULT '0' COMMENT '团长佣金金额（分）',
  `total_amount` bigint NOT NULL COMMENT '订单总金额（单位：分）',
  `platform_amount` bigint NOT NULL DEFAULT '0' COMMENT '平台抽成金额（单位：分）',
  `seller_amount` bigint NOT NULL DEFAULT '0' COMMENT '卖方实得金额（单位：分）',
  `days` int UNSIGNED NOT NULL COMMENT '租赁天数',
  `allow_renew` tinyint NOT NULL DEFAULT '0' COMMENT '是否允许续租：0=不允许，1=允许',
  `order_json` json DEFAULT NULL COMMENT '订单额外数据（价格快照等）',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态：0=待支付，1=已支付/待客服，2=进行中，3=已完成，4=已取消',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='租赁订单表-成交订单记录';

-- --------------------------------------------------------

--
-- 表的结构 `rental_tickets`
--

CREATE TABLE `rental_tickets` (
  `id` bigint UNSIGNED NOT NULL COMMENT '工单ID',
  `ticket_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工单编号（TK + YYYYMMDD + 6位随机数）',
  `order_id` bigint UNSIGNED NOT NULL COMMENT '关联订单ID',
  `creator_user_id` bigint UNSIGNED NOT NULL COMMENT '创建者用户ID',
  `creator_user_type` tinyint NOT NULL COMMENT '创建者类型：1=C端，2=B端',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工单标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '问题描述',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态：0=待处理，1=处理中，2=已解决，3=已关闭',
  `handler_id` bigint UNSIGNED DEFAULT NULL COMMENT '处理人ID（Admin）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `closed_at` datetime DEFAULT NULL COMMENT '关闭时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='租赁工单表-售后纠纷处理';

-- --------------------------------------------------------

--
-- 表的结构 `rental_ticket_messages`
--

CREATE TABLE `rental_ticket_messages` (
  `id` bigint UNSIGNED NOT NULL COMMENT '消息ID',
  `ticket_id` bigint UNSIGNED NOT NULL COMMENT '工单ID',
  `sender_type` tinyint NOT NULL COMMENT '发送者类型：1=C端用户，2=B端用户，3=Admin，4=系统',
  `sender_id` bigint UNSIGNED DEFAULT NULL COMMENT '发送者ID（系统消息为NULL）',
  `message_type` tinyint NOT NULL DEFAULT '0' COMMENT '消息类型：0=文本，1=图片，2=文件，3=系统通知',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '消息内容',
  `attachments` json DEFAULT NULL COMMENT '附件（JSON数组：[{url,type,name,size}]）',
  `is_read` tinyint NOT NULL DEFAULT '0' COMMENT '是否已读：0=未读，1=已读',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='工单消息表-客服聊天记录';

-- --------------------------------------------------------

--
-- 表的结构 `task_templates`
--

CREATE TABLE `task_templates` (
  `id` int UNSIGNED NOT NULL COMMENT '模板ID',
  `type` tinyint NOT NULL DEFAULT '0' COMMENT '任务类型：0=单任务，1=组合任务',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务标题',
  `price` decimal(18,2) NOT NULL DEFAULT '0.00' COMMENT '单价（元，单任务用）',
  `description1` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '描述信息1',
  `description2` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '描述信息2',
  `stage1_title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '阶段1标题（组合任务用）',
  `stage1_price` decimal(18,2) DEFAULT NULL COMMENT '阶段1单价（组合任务用）',
  `stage2_title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '阶段2标题（组合任务用）',
  `stage2_price` decimal(18,2) DEFAULT NULL COMMENT '阶段2单价（组合任务用）',
  `default_stage1_count` int DEFAULT '1' COMMENT '默认阶段1数量（组合任务用）',
  `default_stage2_count` int DEFAULT '3' COMMENT '默认阶段2数量（组合任务用）',
  `c_user_commission` int NOT NULL DEFAULT '0' COMMENT '普通用户佣金（分）',
  `agent_commission` int NOT NULL DEFAULT '0' COMMENT '普通团长佣金（分）',
  `senior_agent_commission` int NOT NULL DEFAULT '0' COMMENT '高级团长佣金（分）',
  `stage1_c_user_commission` int DEFAULT NULL COMMENT '组合任务阶段1-普通用户佣金（分）',
  `stage1_agent_commission` int DEFAULT NULL COMMENT '组合任务阶段1-普通团长佣金（分）',
  `stage1_senior_agent_commission` int DEFAULT NULL COMMENT '组合任务阶段1-高级团长佣金（分）',
  `stage2_c_user_commission` int DEFAULT NULL COMMENT '组合任务阶段2-普通用户佣金（分）',
  `stage2_agent_commission` int DEFAULT NULL COMMENT '组合任务阶段2-普通团长佣金（分）',
  `stage2_senior_agent_commission` int DEFAULT NULL COMMENT '组合任务阶段2-高级团长佣金（分）',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：1=启用，0=禁用',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='任务模板表-平台配置';

--
-- 转存表中的数据 `task_templates`
--

INSERT INTO `task_templates` (`id`, `type`, `title`, `price`, `description1`, `description2`, `stage1_title`, `stage1_price`, `stage2_title`, `stage2_price`, `default_stage1_count`, `default_stage2_count`, `c_user_commission`, `agent_commission`, `senior_agent_commission`, `stage1_c_user_commission`, `stage1_agent_commission`, `stage1_senior_agent_commission`, `stage2_c_user_commission`, `stage2_agent_commission`, `stage2_senior_agent_commission`, `status`, `created_at`) VALUES
(1, 0, '上评评论', 3.00, '发布上评评论', '', NULL, NULL, NULL, NULL, NULL, NULL, 100, 50, 50, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-02-15 14:51:45'),
(2, 0, '中评评论', 2.00, '发布中评评论', '', NULL, NULL, NULL, NULL, NULL, NULL, 80, 30, 30, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-02-15 14:51:45'),
(3, 0, '放大镜搜索词', 5.00, '抖音平台规则问题，本产品属于稀罕出版大礼，搜索词搜索次数就越多，出现概率越大', '', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-02-15 14:51:45'),
(4, 1, '上中评评论', 9.00, '组合评论：上评+中评(1+3)', '', '上评评论', 3.00, '中评回复', 2.00, 1, 3, 0, 0, 0, 100, 50, 50, 80, 30, 30, 1, '2026-02-15 14:51:45'),
(5, 1, '中下评评论', 6.00, '组合评论：中评+下评(1+1)3元/条', '真人评论，评论内容真实有效。下评完成后需要这个晒图评论为晒图套餐。', '中评评论', 3.00, '下评回复', 3.00, 1, 1, 0, 0, 0, 130, 45, 43, 130, 45, 45, 1, '2026-02-15 14:51:45');

-- --------------------------------------------------------

--
-- 表的结构 `user_notifications`
--

CREATE TABLE `user_notifications` (
  `id` bigint UNSIGNED NOT NULL COMMENT '记录ID',
  `notification_id` bigint UNSIGNED NOT NULL COMMENT '通知ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '用户ID',
  `user_type` tinyint NOT NULL COMMENT '用户类型：1=C端，2=B端',
  `is_read` tinyint NOT NULL DEFAULT '0' COMMENT '是否已读：0=未读，1=已读',
  `read_at` datetime DEFAULT NULL COMMENT '阅读时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '接收时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户通知表-每个用户收到的通知';

--
-- 转存表中的数据 `user_notifications`
--

INSERT INTO `user_notifications` (`id`, `notification_id`, `user_id`, `user_type`, `is_read`, `read_at`, `created_at`) VALUES
(1, 1, 1, 2, 1, '2026-02-27 13:18:23', '2026-02-27 12:49:56'),
(2, 2, 2, 2, 1, '2026-02-27 14:06:06', '2026-02-27 12:49:58'),
(3, 3, 2, 2, 1, '2026-02-27 14:26:23', '2026-02-27 14:23:06'),
(4, 4, 1, 2, 1, '2026-02-27 18:10:23', '2026-02-27 14:23:08'),
(5, 5, 2, 2, 1, '2026-02-27 14:26:23', '2026-02-27 14:23:13'),
(6, 6, 2, 2, 1, '2026-02-27 18:11:40', '2026-02-27 17:54:24'),
(7, 7, 2, 1, 0, NULL, '2026-02-27 18:42:02'),
(8, 8, 3, 1, 0, NULL, '2026-02-27 18:47:02'),
(9, 9, 2, 2, 0, NULL, '2026-02-27 18:56:02'),
(10, 10, 2, 2, 0, NULL, '2026-02-27 19:02:01'),
(11, 11, 1, 2, 0, NULL, '2026-02-28 23:20:14'),
(12, 12, 2, 2, 0, NULL, '2026-02-28 23:45:01'),
(13, 13, 2, 2, 0, NULL, '2026-03-01 00:00:04'),
(14, 14, 2, 1, 0, NULL, '2026-03-01 00:47:02'),
(15, 15, 3, 2, 0, NULL, '2026-03-01 00:51:51'),
(16, 16, 3, 2, 0, NULL, '2026-03-01 00:55:31'),
(17, 17, 3, 2, 0, NULL, '2026-03-01 00:56:41');

-- --------------------------------------------------------

--
-- 表的结构 `wallets`
--

CREATE TABLE `wallets` (
  `id` bigint UNSIGNED NOT NULL COMMENT '钱包ID',
  `balance` bigint NOT NULL DEFAULT '0' COMMENT '余额（单位：分，100=1元）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='钱包表-三端共用';

--
-- 转存表中的数据 `wallets`
--

INSERT INTO `wallets` (`id`, `balance`, `created_at`, `updated_at`) VALUES
(1, 219700, '2026-02-27 11:49:20', '2026-03-01 00:34:05'),
(2, 208700, '2026-02-27 12:02:50', '2026-03-01 00:00:04'),
(3, 0, '2026-02-27 13:06:22', '2026-02-27 13:06:22'),
(4, 0, '2026-02-27 17:24:33', '2026-02-27 17:24:33'),
(5, 0, '2026-02-27 17:26:27', '2026-02-27 17:26:27'),
(6, 0, '2026-02-27 17:31:08', '2026-02-27 17:31:08'),
(7, 190000, '2026-03-01 00:48:16', '2026-03-01 00:52:02'),
(8, 0, '2026-03-01 00:53:23', '2026-03-01 00:53:23');

-- --------------------------------------------------------

--
-- 表的结构 `wallets_log`
--

CREATE TABLE `wallets_log` (
  `id` bigint UNSIGNED NOT NULL COMMENT '流水ID',
  `wallet_id` bigint UNSIGNED NOT NULL COMMENT '钱包ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '用户ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（冗余字段）',
  `user_type` tinyint NOT NULL COMMENT '用户类型：1=C端，2=B端，3=Admin端',
  `type` tinyint NOT NULL COMMENT '流水类型：1=收入，2=支出',
  `amount` bigint NOT NULL DEFAULT '0' COMMENT '变动金额（单位：分，正数）',
  `before_balance` bigint NOT NULL DEFAULT '0' COMMENT '变动前余额（单位：分）',
  `after_balance` bigint NOT NULL DEFAULT '0' COMMENT '变动后余额（单位：分）',
  `related_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '关联类型：task=任务，recharge=充值，withdraw=提现，refund=退款',
  `related_id` bigint UNSIGNED DEFAULT NULL COMMENT '关联ID（任务ID、订单ID等）',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '备注说明（扣费或收入原因）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='钱包流水表-记录所有收支';

--
-- 转存表中的数据 `wallets_log`
--

INSERT INTO `wallets_log` (`id`, `wallet_id`, `user_id`, `username`, `user_type`, `type`, `amount`, `before_balance`, `after_balance`, `related_type`, `related_id`, `remark`, `created_at`) VALUES
(1, 2, 2, 'Ceshi1', 2, 1, 0, 0, 0, 'recharge', 1, '充值 ¥1,000.00（alipay），审核中', '2026-02-27 12:49:30'),
(2, 1, 1, 'Ceshi', 2, 1, 0, 0, 0, 'recharge', 2, '充值 ¥1,000.00（alipay），审核中', '2026-02-27 12:49:46'),
(3, 1, 1, 'Ceshi', 2, 1, 100000, 0, 100000, 'recharge', 2, '充值到账：¥1,000.00', '2026-02-27 12:49:56'),
(4, 2, 2, 'Ceshi1', 2, 1, 100000, 0, 100000, 'recharge', 1, '充值到账：¥1,000.00', '2026-02-27 12:49:58'),
(5, 2, 2, 'Ceshi1', 2, 1, 0, 100000, 100000, 'recharge', 3, '充值 ¥1,000.00（alipay），审核中', '2026-02-27 13:17:34'),
(6, 1, 1, 'Ceshi', 2, 1, 0, 100000, 100000, 'recharge', 4, '充值 ¥1,000.00（alipay），审核中', '2026-02-27 13:18:09'),
(7, 2, 2, 'Ceshi1', 2, 2, 5000, 100000, 95000, 'rental_freeze', 1, '求租信息冻结预算（5000分/天×1天）：抖音日租', '2026-02-27 13:47:33'),
(8, 2, 2, 'Ceshi1', 2, 1, 0, 95000, 95000, 'recharge', 5, '充值 ¥100.00（alipay），审核中', '2026-02-27 14:22:20'),
(9, 2, 2, 'Ceshi1', 2, 1, 10000, 95000, 105000, 'recharge', 5, '充值到账：¥100.00', '2026-02-27 14:23:06'),
(10, 1, 1, 'Ceshi', 2, 1, 100000, 100000, 200000, 'recharge', 4, '充值到账：¥1,000.00', '2026-02-27 14:23:08'),
(11, 2, 2, 'Ceshi1', 2, 1, 100000, 105000, 205000, 'recharge', 3, '充值到账：¥1,000.00', '2026-02-27 14:23:13'),
(12, 2, 2, 'Ceshi1', 2, 2, 600, 205000, 204400, 'task', 1, '发布任务【上评评论】2个任务，扣除 ¥6.00', '2026-02-27 18:25:58'),
(13, 2, 2, 'Ceshi1', 2, 2, 400, 204400, 204000, 'task', 2, '发布任务【中评评论】2个任务，扣除 ¥4.00', '2026-02-27 18:31:19'),
(14, 1, 1, 'Ceshi', 2, 1, 0, 200000, 200000, 'recharge', 6, '充值 ¥200.00（alipay），审核中', '2026-02-28 23:20:05'),
(15, 1, 1, 'Ceshi', 2, 1, 20000, 200000, 220000, 'recharge', 6, '充值到账：¥200.00', '2026-02-28 23:20:14'),
(16, 2, 2, 'Ceshi1', 2, 2, 300, 204000, 203700, 'task', 3, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-02-28 23:34:35'),
(17, 2, 2, 'Ceshi1', 2, 1, 5000, 203700, 208700, 'rental_unfreeze', 1, '求租到期退回预算（5000分/天×1天）：抖音日租', '2026-03-01 00:00:04'),
(18, 1, 1, 'Ceshi', 2, 2, 300, 220000, 219700, 'task', 4, '发布任务【上评评论】1个任务，扣除 ¥3.00', '2026-03-01 00:34:05'),
(19, 7, 3, 'task', 2, 1, 0, 0, 0, 'recharge', 7, '充值 ¥2,000.00（alipay），审核中', '2026-03-01 00:51:42'),
(20, 7, 3, 'task', 2, 1, 200000, 0, 200000, 'recharge', 7, '充值到账：¥2,000.00', '2026-03-01 00:51:51'),
(21, 7, 3, 'task', 2, 2, 10000, 200000, 190000, 'rental_freeze', 2, '求租信息冻结预算（5000分/天×2天）：测试求租发布', '2026-03-01 00:52:02');

-- --------------------------------------------------------

--
-- 表的结构 `wallet_password`
--

CREATE TABLE `wallet_password` (
  `id` bigint UNSIGNED NOT NULL COMMENT '主键ID',
  `wallet_id` bigint UNSIGNED NOT NULL COMMENT '钱包ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '用户ID',
  `user_type` tinyint NOT NULL COMMENT '用户类型：1=C端，2=B端，3=Admin端',
  `password_hash` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '支付密码（前端MD5 32位）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付密码表-钱包支付密码管理';

-- --------------------------------------------------------

--
-- 表的结构 `withdraw_requests`
--

CREATE TABLE `withdraw_requests` (
  `id` bigint UNSIGNED NOT NULL COMMENT '提现申请ID',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '用户ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（冗余字段）',
  `user_type` tinyint NOT NULL COMMENT '用户类型：1=C端，2=B端',
  `wallet_id` bigint UNSIGNED NOT NULL COMMENT '钱包ID',
  `amount` bigint NOT NULL DEFAULT '0' COMMENT '提现金额（单位：分）',
  `fee_rate` decimal(5,4) NOT NULL DEFAULT '0.0300' COMMENT '手续费比例（如0.03=3%）',
  `fee_amount` bigint NOT NULL DEFAULT '0' COMMENT '手续费金额（单位：分）',
  `actual_amount` bigint NOT NULL DEFAULT '0' COMMENT '实际到账金额（单位：分）',
  `withdraw_method` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收款方式：alipay=支付宝，wechat=微信，bank=银行卡，usdt=USDT',
  `withdraw_account` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收款账号/信息',
  `account_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '收款人姓名',
  `log_id` bigint UNSIGNED DEFAULT NULL COMMENT '关联的钱包流水ID',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '审核状态：0=待审核，1=审核通过，2=审核拒绝',
  `reject_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '拒绝原因',
  `img_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '审核凭证图片URL（管理员审核通过后上传）',
  `admin_id` bigint UNSIGNED DEFAULT NULL COMMENT '审核管理员ID',
  `reviewed_at` datetime DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='提现申请表-需要管理员审核';

--
-- 转储表的索引
--

--
-- 表的索引 `agent_applications`
--
ALTER TABLE `agent_applications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_c_user_id` (`c_user_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- 表的索引 `app_config`
--
ALTER TABLE `app_config`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_config_key` (`config_key`),
  ADD KEY `idx_config_group` (`config_group`);

--
-- 表的索引 `b_tasks`
--
ALTER TABLE `b_tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_b_user_id` (`b_user_id`),
  ADD KEY `idx_combo_task_id` (`combo_task_id`),
  ADD KEY `idx_stage` (`stage`),
  ADD KEY `idx_stage_status` (`stage_status`),
  ADD KEY `idx_parent_task_id` (`parent_task_id`),
  ADD KEY `idx_template_id` (`template_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_deadline` (`deadline`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_completed_at` (`completed_at`);

--
-- 表的索引 `b_users`
--
ALTER TABLE `b_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_username` (`username`),
  ADD UNIQUE KEY `uk_email` (`email`),
  ADD UNIQUE KEY `uk_phone` (`phone`),
  ADD KEY `idx_token` (`token`(255)),
  ADD KEY `idx_wallet_id` (`wallet_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- 表的索引 `c_task_records`
--
ALTER TABLE `c_task_records`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_c_user_b_task` (`c_user_id`,`b_task_id`),
  ADD KEY `idx_c_user_id` (`c_user_id`),
  ADD KEY `idx_b_task_id` (`b_task_id`),
  ADD KEY `idx_b_user_id` (`b_user_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- 表的索引 `c_users`
--
ALTER TABLE `c_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_username` (`username`),
  ADD UNIQUE KEY `uk_email` (`email`),
  ADD UNIQUE KEY `uk_invite_code` (`invite_code`),
  ADD UNIQUE KEY `uk_phone` (`phone`),
  ADD KEY `idx_parent_id` (`parent_id`),
  ADD KEY `idx_is_agent` (`is_agent`),
  ADD KEY `idx_token` (`token`(255)),
  ADD KEY `idx_wallet_id` (`wallet_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- 表的索引 `c_user_daily_stats`
--
ALTER TABLE `c_user_daily_stats`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_user_date` (`c_user_id`,`stat_date`),
  ADD KEY `idx_c_user_id` (`c_user_id`),
  ADD KEY `idx_stat_date` (`stat_date`);

--
-- 表的索引 `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_target_type` (`target_type`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- 表的索引 `recharge_requests`
--
ALTER TABLE `recharge_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_user_type` (`user_type`),
  ADD KEY `idx_wallet_id` (`wallet_id`),
  ADD KEY `idx_log_id` (`log_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- 表的索引 `rental_applications`
--
ALTER TABLE `rental_applications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_demand_id` (`demand_id`),
  ADD KEY `idx_applicant` (`applicant_user_id`,`applicant_user_type`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- 表的索引 `rental_demands`
--
ALTER TABLE `rental_demands`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user` (`user_id`,`user_type`),
  ADD KEY `idx_wallet_id` (`wallet_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_deadline` (`deadline`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- 表的索引 `rental_offers`
--
ALTER TABLE `rental_offers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user` (`user_id`,`user_type`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_price` (`price_per_day`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- 表的索引 `rental_orders`
--
ALTER TABLE `rental_orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_source` (`source_type`,`source_id`),
  ADD KEY `idx_buyer` (`buyer_user_id`,`buyer_user_type`),
  ADD KEY `idx_seller` (`seller_user_id`,`seller_user_type`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- 表的索引 `rental_tickets`
--
ALTER TABLE `rental_tickets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_ticket_no` (`ticket_no`),
  ADD KEY `idx_order_id` (`order_id`),
  ADD KEY `idx_creator` (`creator_user_id`,`creator_user_type`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_handler_id` (`handler_id`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- 表的索引 `rental_ticket_messages`
--
ALTER TABLE `rental_ticket_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_ticket_id` (`ticket_id`),
  ADD KEY `idx_sender` (`sender_type`,`sender_id`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- 表的索引 `task_templates`
--
ALTER TABLE `task_templates`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_type` (`type`),
  ADD KEY `idx_status` (`status`);

--
-- 表的索引 `user_notifications`
--
ALTER TABLE `user_notifications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_notification_user` (`notification_id`,`user_id`,`user_type`),
  ADD KEY `idx_user` (`user_id`,`user_type`),
  ADD KEY `idx_notification_id` (`notification_id`),
  ADD KEY `idx_is_read` (`is_read`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- 表的索引 `wallets`
--
ALTER TABLE `wallets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_balance` (`balance`);

--
-- 表的索引 `wallets_log`
--
ALTER TABLE `wallets_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_wallet_id` (`wallet_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_user_type` (`user_type`),
  ADD KEY `idx_type` (`type`),
  ADD KEY `idx_related` (`related_type`,`related_id`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- 表的索引 `wallet_password`
--
ALTER TABLE `wallet_password`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_wallet_id` (`wallet_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_user_type` (`user_type`);

--
-- 表的索引 `withdraw_requests`
--
ALTER TABLE `withdraw_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_user_type` (`user_type`),
  ADD KEY `idx_wallet_id` (`wallet_id`),
  ADD KEY `idx_log_id` (`log_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- 在导出的表使用AUTO_INCREMENT
--

--
-- 使用表AUTO_INCREMENT `agent_applications`
--
ALTER TABLE `agent_applications`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '申请ID';

--
-- 使用表AUTO_INCREMENT `app_config`
--
ALTER TABLE `app_config`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '配置ID', AUTO_INCREMENT=37;

--
-- 使用表AUTO_INCREMENT `b_tasks`
--
ALTER TABLE `b_tasks`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '任务ID', AUTO_INCREMENT=5;

--
-- 使用表AUTO_INCREMENT `b_users`
--
ALTER TABLE `b_users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'B端用户ID', AUTO_INCREMENT=4;

--
-- 使用表AUTO_INCREMENT `c_task_records`
--
ALTER TABLE `c_task_records`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID', AUTO_INCREMENT=5;

--
-- 使用表AUTO_INCREMENT `c_users`
--
ALTER TABLE `c_users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'C端用户ID', AUTO_INCREMENT=6;

--
-- 使用表AUTO_INCREMENT `c_user_daily_stats`
--
ALTER TABLE `c_user_daily_stats`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID', AUTO_INCREMENT=5;

--
-- 使用表AUTO_INCREMENT `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '通知ID', AUTO_INCREMENT=18;

--
-- 使用表AUTO_INCREMENT `recharge_requests`
--
ALTER TABLE `recharge_requests`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '充值申请ID', AUTO_INCREMENT=8;

--
-- 使用表AUTO_INCREMENT `rental_applications`
--
ALTER TABLE `rental_applications`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '应征ID', AUTO_INCREMENT=4;

--
-- 使用表AUTO_INCREMENT `rental_demands`
--
ALTER TABLE `rental_demands`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '求租信息ID', AUTO_INCREMENT=3;

--
-- 使用表AUTO_INCREMENT `rental_offers`
--
ALTER TABLE `rental_offers`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '出租信息ID', AUTO_INCREMENT=6;

--
-- 使用表AUTO_INCREMENT `rental_orders`
--
ALTER TABLE `rental_orders`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '订单ID';

--
-- 使用表AUTO_INCREMENT `rental_tickets`
--
ALTER TABLE `rental_tickets`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '工单ID';

--
-- 使用表AUTO_INCREMENT `rental_ticket_messages`
--
ALTER TABLE `rental_ticket_messages`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '消息ID';

--
-- 使用表AUTO_INCREMENT `task_templates`
--
ALTER TABLE `task_templates`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '模板ID', AUTO_INCREMENT=7;

--
-- 使用表AUTO_INCREMENT `user_notifications`
--
ALTER TABLE `user_notifications`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID', AUTO_INCREMENT=18;

--
-- 使用表AUTO_INCREMENT `wallets`
--
ALTER TABLE `wallets`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '钱包ID', AUTO_INCREMENT=9;

--
-- 使用表AUTO_INCREMENT `wallets_log`
--
ALTER TABLE `wallets_log`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '流水ID', AUTO_INCREMENT=22;

--
-- 使用表AUTO_INCREMENT `wallet_password`
--
ALTER TABLE `wallet_password`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID';

--
-- 使用表AUTO_INCREMENT `withdraw_requests`
--
ALTER TABLE `withdraw_requests`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '提现申请ID';
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
