-- MySQL dump 10.13  Distrib 8.0.36, for Linux (x86_64)
--
-- Host: localhost    Database: task_platform
-- ------------------------------------------------------
-- Server version	8.0.36

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `agent_applications`
--

DROP TABLE IF EXISTS `agent_applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agent_applications` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '申请ID',
  `c_user_id` bigint unsigned NOT NULL COMMENT 'C端用户ID',
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（冗余字段）',
  `invite_code` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邀请码（冗余字段）',
  `apply_type` tinyint NOT NULL DEFAULT '1' COMMENT '申请类型：1=普通团长，2=高级团长',
  `valid_invites` int unsigned NOT NULL DEFAULT '0' COMMENT '有效邀请人数（申请时的快照）',
  `total_invites` int unsigned NOT NULL DEFAULT '0' COMMENT '总邀请人数（申请时的快照）',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '审核状态：0=待审核，1=审核通过，2=审核拒绝',
  `reject_reason` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '拒绝原因',
  `admin_id` bigint unsigned DEFAULT NULL COMMENT '审核管理员ID',
  `reviewed_at` datetime DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_c_user_id` (`c_user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='团长申请表-C端用户申请成为团长';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_applications`
--

LOCK TABLES `agent_applications` WRITE;
/*!40000 ALTER TABLE `agent_applications` DISABLE KEYS */;
INSERT INTO `agent_applications` VALUES (1,1,'cceshi1','FM58FB',1,0,1,1,NULL,NULL,'2026-02-16 12:19:08','2026-02-16 12:18:38','2026-02-16 12:19:08'),(7,12,'test','SUBZ5P',1,3,4,1,NULL,NULL,'2026-02-23 21:54:58','2026-02-23 21:50:31','2026-02-23 21:54:58'),(8,17,'advanced','KYQUX7',1,5,6,1,NULL,NULL,'2026-02-24 14:46:47','2026-02-24 14:46:35','2026-02-24 14:46:47'),(9,17,'advanced','KYQUX7',2,5,6,1,NULL,NULL,'2026-02-24 14:49:57','2026-02-24 14:47:19','2026-02-24 14:49:57'),(10,24,'thirdly','YXXEZY',1,3,3,1,NULL,NULL,'2026-02-24 15:18:31','2026-02-24 15:18:25','2026-02-24 15:18:31'),(11,24,'thirdly','YXXEZY',2,3,3,1,NULL,NULL,'2026-02-24 15:19:48','2026-02-24 15:19:42','2026-02-24 15:19:48');
/*!40000 ALTER TABLE `agent_applications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_config`
--

DROP TABLE IF EXISTS `app_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_config` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `config_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置键名',
  `config_value` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置值',
  `config_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'string' COMMENT '配置类型：string, int, float, boolean, json, array',
  `config_group` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'general' COMMENT '配置分组：general, withdraw, task, rental等',
  `description` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '配置描述',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_config_key` (`config_key`),
  KEY `idx_config_group` (`config_group`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='网站配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_config`
--

LOCK TABLES `app_config` WRITE;
/*!40000 ALTER TABLE `app_config` DISABLE KEYS */;
INSERT INTO `app_config` VALUES (1,'website','http://54.179.253.64:28806','string','general','网站地址','2026-02-23 21:28:17'),(2,'upload_path','./img','string','general','上传文件路径','2026-02-15 14:51:56'),(3,'platform_fee_rate','0.25','float','general','平台抽成比例（0.25 = 25%）','2026-02-15 14:51:56'),(4,'task_submit_timeout','600','int','task','任务提交超时时间（秒）','2026-02-15 14:51:56'),(7,'c_withdraw_min_amount','1','int','withdraw','C端每次提现最低金额（元）','2026-02-23 20:53:03'),(8,'c_withdraw_max_amount','500','int','withdraw','C端每次提现最高金额（元）','2026-02-15 14:51:56'),(9,'c_withdraw_amount_multiple','1','int','withdraw','C端提现金额必须是此数的整数倍','2026-02-23 20:53:12'),(10,'c_withdraw_daily_limit','1000','int','withdraw','C端每天提现总额限制（元）','2026-02-15 14:51:56'),(11,'c_withdraw_allowed_weekdays','0,1,2,3,4,5,6','array','withdraw','允许提现的星期几（0=周日,1-6=周一至周六，多个用逗号分隔）','2026-02-24 15:34:06'),(12,'b_withdraw_min_amount','100','int','withdraw','B端每次提现最低金额（元）','2026-02-15 14:51:56'),(13,'b_withdraw_max_amount','5000','int','withdraw','B端每次提现最高金额（元）','2026-02-15 14:51:56'),(14,'b_withdraw_daily_limit','10000','int','withdraw','B端每天提现总额限制（元）','2026-02-15 14:51:56'),(15,'rental_platform_rate','25','int','rental','租赁订单平台抽成比例（%）','2026-02-15 14:51:56'),(16,'rental_platform_fee_rate','0.25','float','rental','租赁系统平台抽成比例（小数形式，兼容旧代码）','2026-02-15 14:51:56'),(17,'c_withdraw_fee_rate','0.03','float','withdraw','C端提现手续费比例（0.03=3%）','2026-02-21 17:33:08'),(18,'senior_agent_required_active_users','30','int','task','申请高级团长需要的有效活跃用户数','2026-02-26 11:25:04'),(19,'senior_agent_active_user_task_count','10','int','task','有效活跃用户需完成的任务数','2026-02-26 11:25:25'),(20,'senior_agent_active_user_hours','48','int','task','有效活跃用户注册后需在多少小时内完成任务','2026-02-26 11:25:30'),(21,'senior_agent_max_count','100','int','task','高级团长数量上限','2026-02-26 11:25:39'),(23,'agent_required_active_users','5','int','task','申请普通团长需要的有效活跃用户数','2026-02-25 10:50:57'),(24,'agent_active_user_task_count','5','int','task','普通团长有效活跃用户需完成的任务数','2026-02-26 11:24:36'),(25,'agent_active_user_hours','24','int','task','普通团长有效活跃用户注册后需在多少小时内完成任务','2026-02-24 15:09:12'),(26,'agent_incentive_enabled','1','int','incentive','团长激励活动开关','2026-02-21 19:31:16'),(27,'agent_incentive_end_time','2099-12-31 23:59:59','string','incentive','团长激励活动终止时间','2026-02-21 19:24:37'),(28,'agent_incentive_amount','1000','int','incentive','团长激励金额（分）','2026-02-26 11:26:41'),(29,'agent_incentive_min_withdraw','10000','int','incentive','触发激励最低提现金额（分）','2026-02-26 11:26:36'),(30,'agent_incentive_limit_enabled','1','int','incentive','人数限制开关','2026-02-23 21:06:59'),(31,'agent_incentive_limit_count','5','int','incentive','每个团长最多激励次数','2026-02-24 15:52:44'),(32,'rental_seller_rate','70','int','rental','租赁卖方分成比例（%）','2026-02-26 11:26:20'),(33,'rental_agent_rate','5','int','rental','租赁普通团长分成比例（%）','2026-02-26 11:26:09'),(34,'rental_senior_agent_rate','5','int','rental','租赁高级团长分成比例（%）','2026-02-26 11:26:13'),(35,'commission_c_user','0','int','task','C端用户佣金比例（%）','2026-02-26 11:25:53'),(36,'commission_agent','0','int','task','团长（代理）佣金比例（%）','2026-02-25 15:03:32');
/*!40000 ALTER TABLE `app_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `b_tasks`
--

DROP TABLE IF EXISTS `b_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `b_tasks` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `b_user_id` bigint unsigned NOT NULL COMMENT 'B端用户ID',
  `combo_task_id` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '组合任务标识（同一组合任务共享）',
  `stage` tinyint NOT NULL DEFAULT '0' COMMENT '阶段：0=单任务，1=阶段1，2=阶段2',
  `stage_status` tinyint NOT NULL DEFAULT '1' COMMENT '阶段状态：0=未开放，1=已开放，2=已完成',
  `parent_task_id` bigint unsigned DEFAULT NULL COMMENT '父任务ID（阶段2指向阶段1）',
  `template_id` int unsigned NOT NULL COMMENT '任务模板ID',
  `video_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '视频链接（阶段2创建时为空，等阶段1完成后分配）',
  `deadline` int unsigned NOT NULL COMMENT '到期时间（10位时间戳-秒级）',
  `recommend_marks` json DEFAULT NULL COMMENT '推荐评论（JSON数组）',
  `task_count` int unsigned NOT NULL DEFAULT '0' COMMENT '任务总数量（评论数组长度）',
  `task_done` int unsigned NOT NULL DEFAULT '0' COMMENT '已完成数量（已通过审核）',
  `task_doing` int unsigned NOT NULL DEFAULT '0' COMMENT '进行中数量（C端正在做）',
  `task_reviewing` int unsigned NOT NULL DEFAULT '0' COMMENT '待审核数量（已提交待审核）',
  `unit_price` decimal(18,2) NOT NULL DEFAULT '0.00' COMMENT '单价（元，从模板获取）',
  `total_price` decimal(18,2) NOT NULL DEFAULT '0.00' COMMENT '总价（元，单价*数量）',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：1=进行中，2=已完成，3=已取消，0=已过期',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `completed_at` datetime DEFAULT NULL COMMENT '完成时间（任务完成时记录）',
  PRIMARY KEY (`id`),
  KEY `idx_b_user_id` (`b_user_id`),
  KEY `idx_combo_task_id` (`combo_task_id`),
  KEY `idx_stage` (`stage`),
  KEY `idx_stage_status` (`stage_status`),
  KEY `idx_parent_task_id` (`parent_task_id`),
  KEY `idx_template_id` (`template_id`),
  KEY `idx_status` (`status`),
  KEY `idx_deadline` (`deadline`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_completed_at` (`completed_at`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='B端发布任务表-商家派单';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `b_tasks`
--

LOCK TABLES `b_tasks` WRITE;
/*!40000 ALTER TABLE `b_tasks` DISABLE KEYS */;
INSERT INTO `b_tasks` VALUES (1,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7581044582247370010',1772294400,'[{\"comment\": \"测试发布上评\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-16 11:47:29','2026-02-24 16:20:58','2026-02-24 16:20:58'),(2,1,NULL,0,1,NULL,2,'https://www.douyin.com/jingxuan?modal_id=7581044582247370010',1772294400,'[{\"at_user\": \"@测试\", \"comment\": \"测试发布中评1\", \"image_url\": \"\"}, {\"at_user\": \"@测试\", \"comment\": \"测试发布中评2\", \"image_url\": \"\"}, {\"at_user\": \"@测试\", \"comment\": \"测试发布中评3\", \"image_url\": \"\"}]',3,2,0,0,2.00,6.00,1,'2026-02-16 11:49:11','2026-02-24 16:21:03',NULL),(3,1,NULL,0,1,NULL,3,'https://www.douyin.com/jingxuan?modal_id=7581044582247370010',1772294400,'[{\"at_user\": \"@超哥超车\", \"comment\": \"搜索@超哥超车100次\", \"image_url\": \"\"}]',1,0,0,0,5.00,5.00,1,'2026-02-16 11:50:02','2026-02-16 11:50:02',NULL),(4,1,'COMBO_1771242968_1',1,2,NULL,4,'https://www.douyin.com/jingxuan?modal_id=7581044582247370010',1772294400,'[{\"at_user\": \"\", \"comment\": \"组合任务上评1\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-16 11:56:08','2026-02-24 16:21:15','2026-02-24 16:21:15'),(5,1,'COMBO_1771242968_1',2,1,4,4,'https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click',1772294400,'[{\"at_user\": \"\", \"comment\": \"组合任务中评1\", \"image_url\": \"\"}, {\"at_user\": \"\", \"comment\": \"组合任务中评2\", \"image_url\": \"\"}, {\"at_user\": \"@超哥超车\", \"comment\": \"组合任务中评3\", \"image_url\": \"\"}]',3,0,0,0,2.00,6.00,1,'2026-02-16 11:56:08','2026-02-24 16:21:15',NULL),(6,1,'COMBO_1771242999_1',1,2,NULL,5,'https://www.douyin.com/jingxuan?modal_id=7581044582247370010',1772294400,'[{\"at_user\": \"\", \"comment\": \"组合任务中评1\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-16 11:56:39','2026-02-24 16:21:28','2026-02-24 16:21:28'),(7,1,'COMBO_1771242999_1',2,1,6,5,'https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click',1772294400,'[{\"at_user\": \"\", \"comment\": \"组合任务下评1\", \"image_url\": \"\"}, {\"at_user\": \"@超哥超车\", \"comment\": \"组合任务下评2\", \"image_url\": \"\"}]',2,0,0,0,3.00,6.00,1,'2026-02-16 11:56:39','2026-02-24 16:21:28',NULL),(8,1,NULL,0,2,NULL,1,'https://douyin.com/video/test123',1772000000,'[{\"comment\": \"test comment 1\", \"image_url\": \"\"}, {\"comment\": \"test comment 2\", \"image_url\": \"\"}]',2,2,0,0,4.00,8.00,2,'2026-02-21 20:39:01','2026-02-24 16:21:37','2026-02-24 16:21:37'),(9,1,NULL,0,2,NULL,1,'https://example.com/test-senior.mp4',1772300000,'[{\"comment\": \"very good product\", \"image_url\": \"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"}]',1,1,0,0,4.00,4.00,2,'2026-02-21 21:21:32','2026-02-23 23:09:08','2026-02-23 23:09:08'),(16,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论1\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 21:18:37','2026-02-23 21:44:16','2026-02-23 21:44:16'),(17,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论2\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 21:18:42','2026-02-23 21:44:33','2026-02-23 21:44:33'),(18,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论3\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 21:18:48','2026-02-23 21:44:38','2026-02-23 21:44:38'),(19,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论4\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 21:18:53','2026-02-23 21:44:48','2026-02-23 21:44:48'),(20,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论5\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 21:19:01','2026-02-23 21:44:56','2026-02-23 21:44:56'),(21,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论6\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 21:19:05','2026-02-23 21:45:03','2026-02-23 21:45:03'),(22,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论7\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 21:19:09','2026-02-23 21:45:09','2026-02-23 21:45:09'),(23,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论8\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 21:19:13','2026-02-23 21:45:14','2026-02-23 21:45:14'),(24,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论9\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 21:19:17','2026-02-23 21:45:19','2026-02-23 21:45:19'),(25,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论10\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 21:19:22','2026-02-23 21:45:25','2026-02-23 21:45:25'),(26,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论11\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 21:19:39','2026-02-23 21:46:15','2026-02-23 21:46:15'),(27,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论11\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 21:42:08','2026-02-23 22:02:44','2026-02-23 22:02:44'),(28,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论13\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 21:42:14','2026-02-23 21:46:26','2026-02-23 21:46:26'),(29,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论14，测试普通团长的佣金。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 21:56:05','2026-02-23 22:03:06','2026-02-23 22:03:06'),(30,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论15，测试普通团长的佣金。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 21:56:15','2026-02-23 22:10:43','2026-02-23 22:10:43'),(31,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论16，测试普通团长的佣金。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 21:56:18','2026-02-23 22:10:36','2026-02-23 22:10:36'),(32,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论17，测试普通团长的佣金。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 21:56:22','2026-02-23 22:10:31','2026-02-23 22:10:31'),(33,1,NULL,0,2,NULL,2,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务，中评评论18，测试普通团长的佣金。\", \"image_url\": \"\"}, {\"comment\": \"新测试，单任务，中评评论19，测试普通团长的佣金。\", \"image_url\": \"\"}, {\"comment\": \"新测试，单任务，中评评论20，测试普通团长的佣金。\", \"image_url\": \"\"}]',3,3,0,0,2.00,6.00,2,'2026-02-23 22:16:06','2026-02-23 22:19:18','2026-02-23 22:19:18'),(34,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 22:36:25','2026-02-23 22:43:48','2026-02-23 22:43:48'),(35,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务，上评评论19，测试高级团长邀请。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 22:36:35','2026-02-23 22:43:58','2026-02-23 22:43:58'),(36,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务，上评评论20，测试高级团长邀请。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 22:36:41','2026-02-23 22:44:03','2026-02-23 22:44:03'),(37,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务，上评评论21，测试高级团长邀请。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 22:36:47','2026-02-23 22:44:09','2026-02-23 22:44:09'),(38,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务，上评评论22，测试高级团长邀请。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 22:36:52','2026-02-23 22:44:16','2026-02-23 22:44:16'),(39,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务，上评评论23，测试高级团长邀请。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 22:36:57','2026-02-23 22:44:23','2026-02-23 22:44:23'),(40,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务，上评评论24，测试高级团长邀请。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 22:37:01','2026-02-23 22:44:32','2026-02-23 22:44:32'),(41,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务，上评评论25，测试高级团长邀请。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 22:37:05','2026-02-23 22:44:38','2026-02-23 22:44:38'),(42,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务，上评评论26，测试高级团长邀请。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 22:37:10','2026-02-23 22:44:46','2026-02-23 22:44:46'),(43,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务，上评评论27，测试高级团长邀请。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 22:37:14','2026-02-23 22:44:53','2026-02-23 22:44:53'),(44,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务，上评评论28，测试高级团长邀请。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 22:37:19','2026-02-23 22:45:18','2026-02-23 22:45:18'),(45,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务，上评评论29，测试高级团长邀请。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 22:37:24','2026-02-23 22:46:41','2026-02-23 22:46:41'),(46,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务，上评评论30，测试高级团长邀请。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 22:37:30','2026-02-24 14:44:35','2026-02-24 14:44:35'),(47,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务，上评评论31，测试高级团长邀请。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-23 22:37:35','2026-02-24 14:49:17','2026-02-24 14:49:17'),(48,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论20\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-24 14:35:18','2026-02-24 14:51:10','2026-02-24 14:51:10'),(49,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论20\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-24 14:35:20','2026-02-24 15:08:08','2026-02-24 15:08:08'),(50,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试上评评论20\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-24 14:35:22','2026-02-24 15:21:36','2026-02-24 15:21:36'),(51,1,NULL,0,2,NULL,2,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务中评，测试高级团长邀请和佣金结算1。\", \"image_url\": \"\"}, {\"comment\": \"新测试，单任务中评，测试高级团长邀请和佣金结算2。\", \"image_url\": \"\"}, {\"comment\": \"新测试，单任务中评，测试高级团长邀请和佣金结算3。\", \"image_url\": \"\"}]',3,3,0,0,2.00,6.00,2,'2026-02-24 15:13:10','2026-02-24 15:15:51','2026-02-24 15:15:51'),(52,1,NULL,0,1,NULL,2,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务中评，测试高级团长邀请和佣金结算1，0.8+0.3。\", \"image_url\": \"\"}, {\"comment\": \"新测试，单任务中评，测试高级团长邀请和佣金结算2，0.8+0.3。\", \"image_url\": \"\"}, {\"comment\": \"新测试，单任务中评，测试高级团长邀请和佣金结算3，0.8+0.3。\", \"image_url\": \"\"}]',3,2,0,0,2.00,6.00,1,'2026-02-24 16:02:55','2026-02-24 16:28:47',NULL),(53,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务中评，测试高级团长邀请和佣金结算1，2+0.5。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-24 16:03:26','2026-02-24 16:13:24','2026-02-24 16:13:24'),(54,1,'COMBO_1771920468_1',1,2,NULL,4,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，组合任务，上评，阶段1测试高级团长邀请和佣金结算1，2+0.5。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-24 16:07:48','2026-02-24 16:15:54','2026-02-24 16:15:54'),(55,1,'COMBO_1771920468_1',2,1,54,4,'https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click',1772294400,'[{\"comment\": \"新测试，组合任务，上评，阶段2测试高级团长邀请和佣金结算2，2+0.5\", \"image_url\": \"\"}, {\"comment\": \"新测试，组合任务，上评，阶段2测试高级团长邀请和佣金结算3，2+0.5\", \"image_url\": \"\"}, {\"at_user\": \"@超哥超车\", \"comment\": \"新测试，组合任务，上评，阶段2测试高级团长邀请和佣金结算4，2+0.5\", \"image_url\": \"\"}]',3,1,0,0,2.00,6.00,1,'2026-02-24 16:07:48','2026-02-24 16:28:17',NULL),(56,1,'COMBO_1771920617_1',1,2,NULL,5,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，组合任务，中评，阶段1测试高级团长邀请和佣金结算1，2+0.5。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-24 16:10:17','2026-02-24 16:17:13','2026-02-24 16:17:13'),(57,1,'COMBO_1771920617_1',2,2,56,5,'https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click',1772294400,'[{\"comment\": \"新测试，组合任务，下评，阶段2测试高级团长邀请和佣金结算2，2+0.5\", \"image_url\": \"\"}]',1,1,0,0,3.00,3.00,2,'2026-02-24 16:10:17','2026-02-24 16:27:29','2026-02-24 16:27:29'),(58,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务中评，测试高级团长邀请和佣金结算1，2+0.5。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-24 16:11:06','2026-02-24 16:26:38','2026-02-24 16:26:38'),(59,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-25 15:02:11','2026-02-25 15:11:34','2026-02-25 15:11:34'),(60,1,NULL,0,2,NULL,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638',1772294400,'[{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}]',1,1,0,0,4.00,4.00,2,'2026-02-25 15:11:45','2026-02-25 15:15:51','2026-02-25 15:15:51');
/*!40000 ALTER TABLE `b_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `b_users`
--

DROP TABLE IF EXISTS `b_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `b_users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'B端用户ID',
  `username` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（必填，登录账号）',
  `email` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邮箱（必填）',
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '手机号（选填）',
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码哈希',
  `organization_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '组织名称',
  `organization_leader` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '组织负责人名称',
  `token` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '当前有效Token（base64格式）',
  `token_expired_at` datetime DEFAULT NULL COMMENT 'Token过期时间',
  `wallet_id` bigint unsigned NOT NULL COMMENT '关联钱包ID',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：1=正常，0=禁用',
  `reason` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '禁用原因',
  `create_ip` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '注册IP地址（支持IPv6）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_email` (`email`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_token` (`token`(255)),
  KEY `idx_wallet_id` (`wallet_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='B端用户表-商家端';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `b_users`
--

LOCK TABLES `b_users` WRITE;
/*!40000 ALTER TABLE `b_users` DISABLE KEYS */;
INSERT INTO `b_users` VALUES (1,'bceshi','bceshi@qq.com','13900000001','$2y$10$hxm8Fs/e2P6S.psgcyDn4.173BIidRFrMmKekLdTggXqdPAHeywZe','小白团队','xiaobai','eyJ1c2VyX2lkIjoxLCJ0eXBlIjoyLCJleHAiOjE3NzI3MTY3NjJ9','2026-03-05 21:19:22',1,1,NULL,'120.239.213.128','2026-02-16 11:27:54','2026-02-26 21:19:22');
/*!40000 ALTER TABLE `b_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `c_task_records`
--

DROP TABLE IF EXISTS `c_task_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `c_task_records` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `c_user_id` bigint unsigned NOT NULL COMMENT 'C端用户ID',
  `b_task_id` bigint unsigned NOT NULL COMMENT 'B端任务ID',
  `b_user_id` bigint unsigned NOT NULL COMMENT 'B端用户ID（发布者）',
  `template_id` int unsigned NOT NULL COMMENT '任务模板ID',
  `video_url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '视频链接',
  `recommend_mark` json DEFAULT NULL COMMENT '分配的推荐评论（comment和image_url）',
  `comment_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户提交的评论链接',
  `screenshot_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户提交的截图',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：1=进行中(doing)，2=待审核(reviewing)，3=已通过(approved)，4=已驳回(rejected)',
  `reject_reason` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '驳回原因',
  `reward_amount` bigint NOT NULL DEFAULT '0' COMMENT '奖励金额（单位：分）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '接单时间',
  `submitted_at` datetime DEFAULT NULL COMMENT '提交时间',
  `reviewed_at` datetime DEFAULT NULL COMMENT '审核时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_c_user_b_task` (`c_user_id`,`b_task_id`),
  KEY `idx_c_user_id` (`c_user_id`),
  KEY `idx_b_task_id` (`b_task_id`),
  KEY `idx_b_user_id` (`b_user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='C端任务记录表-接单执行审核全流程';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `c_task_records`
--

LOCK TABLES `c_task_records` WRITE;
/*!40000 ALTER TABLE `c_task_records` DISABLE KEYS */;
INSERT INTO `c_task_records` VALUES (3,1,1,1,1,'https://www.douyin.com/jingxuan?modal_id=7581044582247370010','{\"comment\": \"测试发布上评\", \"image_url\": \"\"}',NULL,NULL,5,NULL,400,'2026-02-16 15:04:26',NULL,NULL),(4,1,2,1,2,'https://www.douyin.com/jingxuan?modal_id=7581044582247370010','{\"at_user\": \"@测试\", \"comment\": \"测试发布中评3\", \"image_url\": \"\"}',NULL,NULL,5,NULL,200,'2026-02-16 15:21:55',NULL,NULL),(5,2,1,1,1,'https://www.douyin.com/jingxuan?modal_id=7581044582247370010','{\"comment\": \"测试发布上评\", \"image_url\": \"\"}',NULL,NULL,5,NULL,400,'2026-02-16 15:23:47',NULL,NULL),(6,2,2,1,2,'https://www.douyin.com/jingxuan?modal_id=7581044582247370010','{\"at_user\": \"@测试\", \"comment\": \"测试发布中评2\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7590670082435517748','[\"http:\\/\\/134.122.136.221:4667\\/img\\/9f52770a23ef5512c8562cf732c61e14.jpg\"]',3,NULL,200,'2026-02-16 23:48:11','2026-02-16 23:54:18','2026-02-16 23:55:47'),(7,2,8,1,1,'https://douyin.com/video/test123','{\"comment\": \"test comment 2\", \"image_url\": \"\"}','https://douyin.com/comment/test123','[\"http:\\/\\/example.com\\/img\\/test1.jpg\"]',3,NULL,200,'2026-02-21 20:39:08','2026-02-21 20:40:18','2026-02-21 20:40:37'),(14,13,16,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论1\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 21:25:42','2026-02-23 21:29:01','2026-02-23 21:44:16'),(15,13,17,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论2\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 21:29:27','2026-02-23 21:29:43','2026-02-23 21:44:33'),(16,13,18,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论3\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 21:30:02','2026-02-23 21:30:13','2026-02-23 21:44:38'),(17,14,19,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论4\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 21:30:45','2026-02-23 21:30:56','2026-02-23 21:44:48'),(18,14,20,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论5\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 21:31:13','2026-02-23 21:31:22','2026-02-23 21:44:56'),(19,14,21,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论6\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 21:31:32','2026-02-23 21:31:42','2026-02-23 21:45:03'),(20,16,22,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论7\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 21:33:27','2026-02-23 21:33:39','2026-02-23 21:45:09'),(21,16,23,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论8\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 21:33:45','2026-02-23 21:33:52','2026-02-23 21:45:14'),(22,16,24,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论9\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 21:34:06','2026-02-23 21:34:12','2026-02-23 21:45:19'),(23,16,25,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论10\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 21:34:57','2026-02-23 21:35:05','2026-02-23 21:45:25'),(24,16,26,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论11\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',4,'测试驳回功能，驳回后原用户还能不能接取该任务',200,'2026-02-23 21:36:25','2026-02-23 21:36:33','2026-02-23 21:37:44'),(25,13,26,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论11\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 21:40:35','2026-02-23 21:40:55','2026-02-23 21:46:15'),(26,15,28,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论13\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 21:43:16','2026-02-23 21:43:31','2026-02-23 21:46:26'),(27,13,29,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论14，测试普通团长的佣金。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,400,'2026-02-23 21:58:14','2026-02-23 21:59:21','2026-02-23 22:03:06'),(28,13,27,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论11\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,400,'2026-02-23 22:00:35','2026-02-23 22:00:50','2026-02-23 22:02:44'),(29,14,32,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论17，测试普通团长的佣金。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 22:07:19','2026-02-23 22:07:42','2026-02-23 22:10:31'),(30,15,31,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论16，测试普通团长的佣金。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 22:09:08','2026-02-23 22:09:36','2026-02-23 22:10:36'),(31,16,30,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论15，测试普通团长的佣金。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 22:10:01','2026-02-23 22:10:12','2026-02-23 22:10:43'),(32,13,33,1,2,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，中评评论19，测试普通团长的佣金。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,80,'2026-02-23 22:16:52','2026-02-23 22:17:06','2026-02-23 22:19:02'),(33,14,33,1,2,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，中评评论20，测试普通团长的佣金。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,80,'2026-02-23 22:17:34','2026-02-23 22:17:45','2026-02-23 22:19:09'),(34,16,33,1,2,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，中评评论20，测试普通团长的佣金。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,80,'2026-02-23 22:18:07','2026-02-23 22:18:18','2026-02-23 22:19:18'),(35,18,34,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 22:38:38','2026-02-23 22:38:50','2026-02-23 22:43:48'),(36,18,35,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，上评评论19，测试高级团长邀请。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 22:38:57','2026-02-23 22:39:04','2026-02-23 22:43:58'),(37,19,36,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，上评评论20，测试高级团长邀请。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 22:39:30','2026-02-23 22:39:38','2026-02-23 22:44:03'),(38,19,37,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，上评评论21，测试高级团长邀请。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 22:39:46','2026-02-23 22:39:57','2026-02-23 22:44:09'),(39,20,38,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，上评评论22，测试高级团长邀请。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 22:40:26','2026-02-23 22:40:38','2026-02-23 22:44:16'),(40,20,39,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，上评评论23，测试高级团长邀请。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 22:40:47','2026-02-23 22:40:55','2026-02-23 22:44:23'),(41,21,40,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，上评评论24，测试高级团长邀请。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 22:41:19','2026-02-23 22:41:35','2026-02-23 22:44:32'),(42,21,41,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，上评评论25，测试高级团长邀请。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 22:41:40','2026-02-23 22:41:45','2026-02-23 22:44:38'),(43,22,42,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，上评评论26，测试高级团长邀请。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 22:42:06','2026-02-23 22:42:14','2026-02-23 22:44:46'),(44,22,43,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，上评评论27，测试高级团长邀请。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 22:42:18','2026-02-23 22:42:24','2026-02-23 22:44:53'),(45,23,44,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，上评评论28，测试高级团长邀请。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 22:42:58','2026-02-23 22:43:06','2026-02-23 22:45:18'),(46,17,45,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，上评评论29，测试高级团长邀请。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 22:46:18','2026-02-23 22:46:31','2026-02-23 22:46:41'),(47,15,9,1,1,'https://example.com/test-senior.mp4','{\"comment\": \"very good product\", \"image_url\": \"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"}','https://www.douyin.com/jingxuan?modal_id=7580005351660014891','[\"http:\\/\\/54.179.253.64:28806\\/img\\/6d306fbfd7e39c1b0c0fc9c06665a2fe.png\"]',3,NULL,200,'2026-02-23 23:07:34','2026-02-23 23:08:12','2026-02-23 23:09:08'),(48,18,46,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，上评评论30，测试高级团长邀请。\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,200,'2026-02-24 14:36:17','2026-02-24 14:43:48','2026-02-24 14:44:35'),(49,18,47,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，上评评论31，测试高级团长邀请。\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,200,'2026-02-24 14:48:47','2026-02-24 14:48:59','2026-02-24 14:49:17'),(50,18,48,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论20\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,200,'2026-02-24 14:50:27','2026-02-24 14:50:45','2026-02-24 14:51:10'),(51,23,49,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论20\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,200,'2026-02-24 15:07:39','2026-02-24 15:07:56','2026-02-24 15:08:08'),(52,25,51,1,2,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务中评，测试高级团长邀请和佣金结算3。\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,80,'2026-02-24 15:14:09','2026-02-24 15:14:25','2026-02-24 15:15:39'),(53,26,51,1,2,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务中评，测试高级团长邀请和佣金结算1。\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,80,'2026-02-24 15:14:43','2026-02-24 15:14:52','2026-02-24 15:15:46'),(54,27,51,1,2,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务中评，测试高级团长邀请和佣金结算1。\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,80,'2026-02-24 15:15:09','2026-02-24 15:15:21','2026-02-24 15:15:51'),(55,27,50,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试上评评论20\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,200,'2026-02-24 15:21:13','2026-02-24 15:21:23','2026-02-24 15:21:36'),(56,13,52,1,2,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务中评，测试高级团长邀请和佣金结算1，0.8+0.3。\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,80,'2026-02-24 16:12:10','2026-02-24 16:12:25','2026-02-24 16:13:17'),(57,13,53,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务中评，测试高级团长邀请和佣金结算1，2+0.5。\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,200,'2026-02-24 16:12:37','2026-02-24 16:12:52','2026-02-24 16:13:24'),(58,13,54,1,4,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，组合任务，上评，阶段1测试高级团长邀请和佣金结算1，2+0.5。\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,200,'2026-02-24 16:14:54','2026-02-24 16:15:02','2026-02-24 16:15:54'),(59,13,56,1,5,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，组合任务，中评，阶段1测试高级团长邀请和佣金结算1，2+0.5。\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,130,'2026-02-24 16:16:51','2026-02-24 16:17:02','2026-02-24 16:17:13'),(60,14,1,1,1,'https://www.douyin.com/jingxuan?modal_id=7581044582247370010','{\"comment\": \"测试发布上评\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,200,'2026-02-24 16:18:28','2026-02-24 16:18:42','2026-02-24 16:20:58'),(61,14,2,1,2,'https://www.douyin.com/jingxuan?modal_id=7581044582247370010','{\"at_user\": \"@测试\", \"comment\": \"测试发布中评3\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,80,'2026-02-24 16:19:00','2026-02-24 16:19:10','2026-02-24 16:21:03'),(62,14,4,1,4,'https://www.douyin.com/jingxuan?modal_id=7581044582247370010','{\"at_user\": \"\", \"comment\": \"组合任务上评1\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,200,'2026-02-24 16:19:40','2026-02-24 16:19:47','2026-02-24 16:21:15'),(63,14,6,1,5,'https://www.douyin.com/jingxuan?modal_id=7581044582247370010','{\"at_user\": \"\", \"comment\": \"组合任务中评1\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,130,'2026-02-24 16:20:06','2026-02-24 16:20:15','2026-02-24 16:21:28'),(64,14,8,1,1,'https://douyin.com/video/test123','{\"comment\": \"test comment 1\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,200,'2026-02-24 16:20:24','2026-02-24 16:20:32','2026-02-24 16:21:37'),(65,18,58,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务中评，测试高级团长邀请和佣金结算1，2+0.5。\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,200,'2026-02-24 16:24:20','2026-02-24 16:24:32','2026-02-24 16:26:38'),(66,18,57,1,5,'https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','{\"comment\": \"新测试，组合任务，下评，阶段2测试高级团长邀请和佣金结算2，2+0.5\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,130,'2026-02-24 16:24:54','2026-02-24 16:25:04','2026-02-24 16:27:29'),(67,18,55,1,4,'https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','{\"at_user\": \"@超哥超车\", \"comment\": \"新测试，组合任务，上评，阶段2测试高级团长邀请和佣金结算4，2+0.5\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,80,'2026-02-24 16:25:16','2026-02-24 16:25:23','2026-02-24 16:28:17'),(68,18,52,1,2,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务中评，测试高级团长邀请和佣金结算3，0.8+0.3。\", \"image_url\": \"\"}','https://www.bilibili.com/video/BV1mufwBcEzL/?spm_id_from=333.1007.tianma.2-2-5.click','[\"http:\\/\\/54.179.253.64:28806\\/img\\/699b12749bb2bca12cbcae12d7373511.jpg\"]',3,NULL,80,'2026-02-24 16:25:32','2026-02-24 16:25:38','2026-02-24 16:28:47'),(69,17,59,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7577335582393699638','[\"http:\\/\\/54.179.253.64:28806\\/img\\/344ccc2b0873c9f91547ebce99c6434a.jpg\"]',3,NULL,200,'2026-02-25 15:04:39','2026-02-25 15:06:10','2026-02-25 15:11:34'),(70,12,60,1,1,'https://www.douyin.com/jingxuan?modal_id=7577335582393699638','{\"comment\": \"新测试，单任务，上评评论18，测试高级团长邀请。\", \"image_url\": \"\"}','https://www.douyin.com/jingxuan?modal_id=7577335582393699638','[\"http:\\/\\/54.179.253.64:28806\\/img\\/d0e6e3dd81eff0fdccb13f8165a7c8bc.webp\"]',3,NULL,200,'2026-02-25 15:14:18','2026-02-25 15:14:43','2026-02-25 15:15:51');
/*!40000 ALTER TABLE `c_task_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `c_user_daily_stats`
--

DROP TABLE IF EXISTS `c_user_daily_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `c_user_daily_stats` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `c_user_id` bigint unsigned NOT NULL COMMENT 'C端用户ID',
  `stat_date` date NOT NULL COMMENT '统计日期',
  `accept_count` int unsigned NOT NULL DEFAULT '0' COMMENT '当日接单次数',
  `submit_count` int unsigned NOT NULL DEFAULT '0' COMMENT '当日提交次数',
  `approved_count` int unsigned NOT NULL DEFAULT '0' COMMENT '当日通过次数',
  `rejected_count` int unsigned NOT NULL DEFAULT '0' COMMENT '当日驳回次数',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date` (`c_user_id`,`stat_date`),
  KEY `idx_c_user_id` (`c_user_id`),
  KEY `idx_stat_date` (`stat_date`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='C端用户每日统计表-限制驳回次数';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `c_user_daily_stats`
--

LOCK TABLES `c_user_daily_stats` WRITE;
/*!40000 ALTER TABLE `c_user_daily_stats` DISABLE KEYS */;
INSERT INTO `c_user_daily_stats` VALUES (1,1,'2026-02-16',4,0,0,0,'2026-02-16 12:11:02','2026-02-16 15:21:55'),(2,2,'2026-02-16',2,1,1,0,'2026-02-16 15:23:47','2026-02-16 23:55:47'),(3,2,'2026-02-21',1,1,1,0,'2026-02-21 20:39:08','2026-02-21 20:40:37'),(6,13,'2026-02-23',7,7,7,0,'2026-02-23 21:25:42','2026-02-23 22:19:02'),(7,14,'2026-02-23',5,5,5,0,'2026-02-23 21:30:45','2026-02-23 22:19:09'),(8,16,'2026-02-23',7,7,6,1,'2026-02-23 21:33:27','2026-02-23 22:19:18'),(9,15,'2026-02-23',3,3,3,0,'2026-02-23 21:43:16','2026-02-23 23:09:08'),(10,18,'2026-02-23',2,2,2,0,'2026-02-23 22:38:38','2026-02-23 22:43:58'),(11,19,'2026-02-23',2,2,2,0,'2026-02-23 22:39:30','2026-02-23 22:44:09'),(12,20,'2026-02-23',2,2,2,0,'2026-02-23 22:40:26','2026-02-23 22:44:23'),(13,21,'2026-02-23',2,2,2,0,'2026-02-23 22:41:19','2026-02-23 22:44:38'),(14,22,'2026-02-23',2,2,2,0,'2026-02-23 22:42:06','2026-02-23 22:44:53'),(15,23,'2026-02-23',1,1,1,0,'2026-02-23 22:42:58','2026-02-23 22:45:18'),(16,17,'2026-02-23',1,1,1,0,'2026-02-23 22:46:18','2026-02-23 22:46:41'),(17,18,'2026-02-24',7,7,7,0,'2026-02-24 14:36:17','2026-02-24 16:28:47'),(18,23,'2026-02-24',1,1,1,0,'2026-02-24 15:07:39','2026-02-24 15:08:08'),(19,25,'2026-02-24',1,1,1,0,'2026-02-24 15:14:09','2026-02-24 15:15:39'),(20,26,'2026-02-24',1,1,1,0,'2026-02-24 15:14:43','2026-02-24 15:15:46'),(21,27,'2026-02-24',2,2,2,0,'2026-02-24 15:15:09','2026-02-24 15:21:36'),(22,13,'2026-02-24',4,4,4,0,'2026-02-24 16:12:10','2026-02-24 16:17:13'),(23,14,'2026-02-24',5,5,5,0,'2026-02-24 16:18:28','2026-02-24 16:21:37'),(24,17,'2026-02-25',1,1,1,0,'2026-02-25 15:04:39','2026-02-25 15:11:34'),(25,12,'2026-02-25',1,1,1,0,'2026-02-25 15:14:18','2026-02-25 15:15:51');
/*!40000 ALTER TABLE `c_user_daily_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `c_users`
--

DROP TABLE IF EXISTS `c_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `c_users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'C端用户ID',
  `username` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（必填，登录账号）',
  `email` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邮箱（必填）',
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '手机号（选填）',
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码哈希',
  `invite_code` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邀请码（6位数字字母组合，唯一）',
  `parent_id` bigint unsigned DEFAULT NULL COMMENT '上级用户ID（邀请人ID）',
  `is_agent` tinyint NOT NULL DEFAULT '0' COMMENT '代理身份：0=未激活团长，1=团长',
  `token` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '当前有效Token（base64格式）',
  `token_expired_at` datetime DEFAULT NULL COMMENT 'Token过期时间',
  `wallet_id` bigint unsigned NOT NULL COMMENT '关联钱包ID',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：1=正常，0=禁用',
  `reason` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '禁用原因',
  `create_ip` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '注册IP地址（支持IPv6）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_email` (`email`),
  UNIQUE KEY `uk_invite_code` (`invite_code`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_is_agent` (`is_agent`),
  KEY `idx_token` (`token`(255)),
  KEY `idx_wallet_id` (`wallet_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='C端用户表-消费者端';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `c_users`
--

LOCK TABLES `c_users` WRITE;
/*!40000 ALTER TABLE `c_users` DISABLE KEYS */;
INSERT INTO `c_users` VALUES (1,'cceshi1','cceshi1@qq.com','13900000002','$2y$10$hxm8Fs/e2P6S.psgcyDn4.173BIidRFrMmKekLdTggXqdPAHeywZe','FM58FB',NULL,2,'eyJ1c2VyX2lkIjoxLCJ0eXBlIjoxLCJleHAiOjE3NzIyODIwNDV9','2026-02-28 20:34:05',2,1,NULL,'120.239.213.128','2026-02-16 12:05:32','2026-02-21 21:19:03'),(2,'cceshi2','cceshi2@qq.com','13900000003','$2y$10$hxm8Fs/e2P6S.psgcyDn4.173BIidRFrMmKekLdTggXqdPAHeywZe','E2DAGE',1,0,'eyJ1c2VyX2lkIjoyLCJ0eXBlIjoxLCJleHAiOjE3NzIyODIwNDZ9','2026-02-28 20:34:06',3,1,NULL,'120.239.213.128','2026-02-16 12:05:51','2026-02-21 20:34:06'),(12,'test','test@qq.com',NULL,'$2y$10$ug6gxtRjRDtn4kaAiCiF3.AKTBQ537QgxKL9wTZ4E5MAAVxRurhUG','SUBZ5P',NULL,1,'eyJ1c2VyX2lkIjoxMiwidHlwZSI6MSwiZXhwIjoxNzcyNjgzMDYxfQ==','2026-03-05 11:57:41',13,1,NULL,'223.74.62.205','2026-02-23 21:10:12','2026-02-26 11:57:41'),(13,'test1','test1@qq.com',NULL,'$2y$10$Eu0hgE2GxrdcD3TNili8putGC1eqyXSXpWzjz/jfJ6sKW5VCFJ/Su','2TZM7Z',12,0,'eyJ1c2VyX2lkIjoxMywidHlwZSI6MSwiZXhwIjoxNzcyNTI1NDkwfQ==','2026-03-03 16:11:30',14,1,NULL,'223.74.62.205','2026-02-23 21:11:29','2026-02-24 16:11:30'),(14,'test2','test2@qq.com',NULL,'$2y$10$WpEzx983FIsgovk9AMcwFeiVRLzfiUluGBGjx66zOiDQpRVNuO4O.','BNQNB9',12,0,'eyJ1c2VyX2lkIjoxNCwidHlwZSI6MSwiZXhwIjoxNzcyNTI1ODc3fQ==','2026-03-03 16:17:57',15,1,NULL,'223.74.62.205','2026-02-23 21:11:37','2026-02-24 16:17:57'),(15,'test3','test3@qq.com',NULL,'$2y$10$aNNF2Xz6MnCnSGYYebIGNuoMdoXJEzfEv6zA0rBmae/GqMk5Rd0Yu','3ZHUGS',12,0,'eyJ1c2VyX2lkIjoxNSwidHlwZSI6MSwiZXhwIjoxNzcyNDY0MDI3fQ==','2026-03-02 23:07:07',16,1,NULL,'223.74.62.205','2026-02-23 21:11:49','2026-02-23 23:07:07'),(16,'test4','test4@qq.com',NULL,'$2y$10$B0qzb9z9U2jT3DlKM4WRsOXCH7Ts2KJeG8JMaBWc3NfDS7hZJGYCm','3VKM5V',12,0,'eyJ1c2VyX2lkIjoxNiwidHlwZSI6MSwiZXhwIjoxNzcyNTEwNTYwfQ==','2026-03-03 12:02:40',17,1,NULL,'223.74.62.205','2026-02-23 21:13:13','2026-02-24 12:02:40'),(17,'advanced','advanced@qq.com',NULL,'$2y$10$aTeb9gnCjMaJZfbn70wux.6.iss4QC1yav8Kz/pvlmbdJOWZ0dr12','KYQUX7',12,2,'eyJ1c2VyX2lkIjoxNywidHlwZSI6MSwiZXhwIjoxNzcyNjgxMzkwfQ==','2026-03-05 11:29:50',18,1,NULL,'223.74.62.205','2026-02-23 22:30:54','2026-02-26 11:29:50'),(18,'advanced1','advanced1@qq.com',NULL,'$2y$10$yceFZQO9D6N7RjBYMM78eO51hJkWoKwV5Ct/wZR5FYH/OOj.pVN9W','MS7JAP',17,0,'eyJ1c2VyX2lkIjoxOCwidHlwZSI6MSwiZXhwIjoxNzcyNjE3MDYyfQ==','2026-03-04 17:37:42',19,1,NULL,'223.74.62.205','2026-02-23 22:31:05','2026-02-25 17:37:42'),(19,'advanced2','advanced2@qq.com',NULL,'$2y$10$ehi6U6IEp2j4VbehYiHg0OCGSvmUOVY77T0OPD/h7iMlDtOvxmwV.','VZ265D',17,0,'eyJ1c2VyX2lkIjoxOSwidHlwZSI6MSwiZXhwIjoxNzcyNTI0MjI2fQ==','2026-03-03 15:50:26',20,1,NULL,'223.74.62.205','2026-02-23 22:31:12','2026-02-24 15:50:26'),(20,'advanced3','advanced3@qq.com',NULL,'$2y$10$PKjnbkldwH0mWEjpbTvVeOhZTPOXcIHDTpJFaBEvjcSDuY6TvRqES','XRJPBS',17,0,'eyJ1c2VyX2lkIjoyMCwidHlwZSI6MSwiZXhwIjoxNzcyNTI0MjQ1fQ==','2026-03-03 15:50:45',21,1,NULL,'223.74.62.205','2026-02-23 22:31:17','2026-02-24 15:50:45'),(21,'advanced4','advanced4@qq.com',NULL,'$2y$10$2qloF5PxPeJh.yXuoUwkPe6DFUKNYGNuoZJjIUPXL8F6HodUep9YK','4C4W4G',17,0,'eyJ1c2VyX2lkIjoyMSwidHlwZSI6MSwiZXhwIjoxNzcyNTI0NDI4fQ==','2026-03-03 15:53:48',22,1,NULL,'223.74.62.205','2026-02-23 22:31:22','2026-02-24 15:53:48'),(22,'advanced5','advanced5@qq.com',NULL,'$2y$10$3BVJ8cSBlhSbeoMo6IbPhegD/cgDZCZxpVONcwKpmT3qlK9wkaSAi','M96ZYK',17,0,'eyJ1c2VyX2lkIjoyMiwidHlwZSI6MSwiZXhwIjoxNzcyNTI0NDQ4fQ==','2026-03-03 15:54:08',23,1,NULL,'223.74.62.205','2026-02-23 22:31:28','2026-02-24 15:54:08'),(23,'advanced6','advanced6@qq.com',NULL,'$2y$10$DpZJpoWYScjxlwm93CgQkOhvkBCB6X7lIXkMpchmlbpxI7I3p363q','8RTHDU',17,0,'eyJ1c2VyX2lkIjoyMywidHlwZSI6MSwiZXhwIjoxNzcyNTI0NDY1fQ==','2026-03-03 15:54:25',24,1,NULL,'223.74.62.205','2026-02-23 22:31:35','2026-02-24 15:54:25'),(24,'thirdly','thirdly@qq.com',NULL,'$2y$10$toHei8dKszfP95A.CaBP6OsNQGbh9xRLj78eCZ6i3CBS1EOzpvXJa','YXXEZY',NULL,2,'eyJ1c2VyX2lkIjoyNCwidHlwZSI6MSwiZXhwIjoxNzcyNTIyMjYzfQ==','2026-03-03 15:17:43',25,1,NULL,'120.237.23.202','2026-02-24 15:11:14','2026-02-24 15:19:48'),(25,'thirdly1','thirdly1@qq.com',NULL,'$2y$10$SM8QhFtjUzKgqS4.THa8Bu4DRSzgDSoDKjZTkx1bGo8kQfkYJs9z.','THW9K5',24,0,'eyJ1c2VyX2lkIjoyNSwidHlwZSI6MSwiZXhwIjoxNzcyNTIyMDA2fQ==','2026-03-03 15:13:26',26,1,NULL,'120.237.23.202','2026-02-24 15:11:25','2026-02-24 15:13:26'),(26,'thirdly2','thirdly2@qq.com',NULL,'$2y$10$5EARucaI1i0DQl0QYIWtWuWQ19HKcEcdxqKT2ElT9Lo9hrlh5QbAS','AY4QM5',24,0,'eyJ1c2VyX2lkIjoyNiwidHlwZSI6MSwiZXhwIjoxNzcyNTIyMDczfQ==','2026-03-03 15:14:33',27,1,NULL,'120.237.23.202','2026-02-24 15:11:31','2026-02-24 15:14:33'),(27,'thirdly3','thirdly3@qq.com',NULL,'$2y$10$srGAr0J7F7rQGG0opXCHse6wakgvuI.l4S4nf.ajDbTMvnFmRdf5a','PR6YGB',24,0,'eyJ1c2VyX2lkIjoyNywidHlwZSI6MSwiZXhwIjoxNzcyNTIyNDUyfQ==','2026-03-03 15:20:52',28,1,NULL,'120.237.23.202','2026-02-24 15:11:37','2026-02-24 15:20:52');
/*!40000 ALTER TABLE `c_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '通知ID',
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知标题',
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知内容',
  `target_type` tinyint NOT NULL DEFAULT '0' COMMENT '目标类型：0=全体，1=C端全体，2=B端全体，3=指定用户',
  `target_user_id` bigint unsigned DEFAULT NULL COMMENT '目标用户ID（target_type=3时使用）',
  `target_user_type` tinyint DEFAULT NULL COMMENT '目标用户类型（target_type=3时使用，1=C端，2=B端）',
  `sender_type` tinyint NOT NULL DEFAULT '3' COMMENT '发送者类型：1=系统自动，3=Admin',
  `sender_id` bigint unsigned DEFAULT NULL COMMENT '发送者ID（Admin ID，预留字段）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  PRIMARY KEY (`id`),
  KEY `idx_target_type` (`target_type`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统通知表-通知模板';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,'充值审核通过','您的充值申请已审核通过，金额：¥1,000.00 已到账。感谢您的使用！',3,1,2,1,NULL,'2026-02-16 11:45:59'),(2,'🎉 恭喜！团长申请已通过','恭喜您！您的团长申请已审核通过。\n\n现在您可以享受以下权益：\n• 推广邀请码，获得下线用户\n• 下线完成任务时，您可获得 8% 佣金分成\n• 更多权益敬请期待\n\n邀请码：FM58FB\n\n感谢您对平台的支持！',3,1,1,1,NULL,'2026-02-16 12:19:08'),(3,'收到新的应征申请','您的求租「测试更新求租信息的功能」收到了新的应征，请前往查看审核',3,1,2,1,NULL,'2026-02-16 13:15:14'),(4,'应征审核通过','您应征的求租「测试更新求租信息的功能」已通过审核，订单已生成，等待客服处理',3,1,1,1,NULL,'2026-02-16 13:22:26'),(5,'应征已审核','您的求租「测试更新求租信息的功能」已选中应征方，订单已创建',3,1,2,1,NULL,'2026-02-16 13:22:26'),(6,'租赁订单已开始','您租用的订单 #1 已开始执行，租期 10 天，到期时间：2026-02-26 21:23:20',3,1,2,1,NULL,'2026-02-16 13:23:20'),(7,'租赁订单已开始','您出租的订单 #1 已开始执行，租期 10 天，到期时间：2026-02-26 21:23:20',3,1,1,1,NULL,'2026-02-16 13:23:20'),(8,'新工单通知','您的租赁订单 #1 收到新工单：测试创建工单功能，这个订单存在诈骗行为,账号货不对板。工单编号：TK20260216784973，请及时查看处理。',3,1,1,1,NULL,'2026-02-16 13:26:59'),(9,'工单新消息','工单「测试创建工单功能，这个订单存在诈骗行为,账号货不对板」收到来自出租方的新消息（文本消息）：我要验牌',3,1,2,1,NULL,'2026-02-16 13:30:10'),(10,'工单新消息','工单「测试创建工单功能，这个订单存在诈骗行为,账号货不对板」收到来自购买方的新消息（文本消息）：牌没有问题http://134.122.136.221:4667/img/a9b76843e779d...',3,1,1,1,NULL,'2026-02-16 13:33:01'),(11,'工单已关闭','工单「测试创建工单功能，这个订单存在诈骗行为,账号货不对板」已被关闭。工单编号：TK20260216784973',3,1,1,1,NULL,'2026-02-16 13:33:35'),(12,'工单已关闭','工单「测试创建工单功能，这个订单存在诈骗行为,账号货不对板」已被管理员关闭。管理员关闭工单',3,1,2,1,NULL,'2026-02-16 13:37:14'),(13,'工单已关闭','工单「测试创建工单功能，这个订单存在诈骗行为,账号货不对板」已被管理员关闭。管理员关闭工单',3,1,1,1,NULL,'2026-02-16 13:37:14'),(14,'任务已超时','您接取的任务「中评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-02-16 15:21:55\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。',3,1,1,1,NULL,'2026-02-16 15:22:02'),(15,'任务已超时','您接取的任务「上评评论」已超时未提交，任务已自动取消。\n\n接单时间：2026-02-16 15:23:47\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。',3,2,1,1,NULL,'2026-02-16 15:24:02'),(16,'收到新的租赁订单','您的出租「抖音账号出租」收到新订单，租期1天，等待客服处理',3,1,1,1,NULL,'2026-02-16 23:47:20'),(17,'租赁订单支付成功','您租赁的「抖音账号出租」已支付成功，等待客服处理',3,1,2,1,NULL,'2026-02-16 23:47:20'),(18,'租赁订单已开始','您租用的订单 #2 已开始执行，租期 1 天，到期时间：2026-02-17 23:59:07',3,1,2,1,NULL,'2026-02-16 23:59:07'),(19,'租赁订单已开始','您出租的订单 #2 已开始执行，租期 1 天，到期时间：2026-02-17 23:59:07',3,1,1,1,NULL,'2026-02-16 23:59:07'),(20,'订单已续租','您的订单 #2 已被租用方续租 1 天，新的到期时间：2026-02-18 23:59:07',3,1,1,1,NULL,'2026-02-16 23:59:15'),(21,'订单续租成功','订单 #2 续租成功，续租 1 天，扣费 ¥1.00，新的到期时间：2026-02-18 23:59:07',3,1,2,1,NULL,'2026-02-16 23:59:15'),(22,'租赁订单已完成','您出租的订单 #2 已完成，收益 ¥1.50 已到账',3,1,1,1,NULL,'2026-02-19 00:00:03'),(23,'租赁订单已完成','您租用的订单 #2 已到期完成，感谢使用',3,1,2,1,NULL,'2026-02-19 00:00:03'),(24,'提现审核通过','您的提现申请已审核通过，提现金额：¥100.00，手续费：¥3.00，实际到账：¥97.00。\n\n收款方式：alipay\n收款账号：13800000000',3,3,1,1,NULL,'2026-02-21 18:33:39'),(25,'恭喜！高级团长申请已通过','恭喜您！您的高级团长申请已审核通过。\n\n高级团长权益已生效，佣金将按高级团长标准结算。\n\n邀请码：PW773G',3,3,1,1,NULL,'2026-02-21 18:35:08'),(26,'恭喜！团长申请已通过','恭喜您！您的团长申请已审核通过。\n\n现在您可以享受以下权益：\n• 推广邀请码，获得下线用户\n• 下线完成任务时，您可获得佣金分成\n\n邀请码：AEFJFE',3,4,1,1,NULL,'2026-02-21 18:48:06'),(32,'收到新的租赁订单','您的出租「senior_test_rental_offer」收到新订单，租期3天，等待客服处理',3,8,1,1,NULL,'2026-02-21 21:54:13'),(33,'租赁订单支付成功','您租赁的「senior_test_rental_offer」已支付成功，等待客服处理',3,1,2,1,NULL,'2026-02-21 21:54:13'),(34,'租赁订单已开始','您租用的订单 #3 已开始执行，租期 3 天，到期时间：2026-02-24 21:55:44',3,1,2,1,NULL,'2026-02-21 21:55:44'),(35,'租赁订单已开始','您出租的订单 #3 已开始执行，租期 3 天，到期时间：2026-02-24 21:55:44',3,8,1,1,NULL,'2026-02-21 21:55:44'),(36,'租赁订单已完成','您出租的订单 #3 已完成，收益 ¥2.10 已到账',3,8,1,1,NULL,'2026-02-21 21:56:02'),(37,'租赁订单已完成','您租用的订单 #3 已到期完成，感谢使用',3,1,2,1,NULL,'2026-02-21 21:56:02'),(38,'收到新的租赁订单','您的出租「rental_agent_test」收到新订单，租期2天，等待客服处理',3,10,1,1,NULL,'2026-02-21 22:04:32'),(39,'租赁订单支付成功','您租赁的「rental_agent_test」已支付成功，等待客服处理',3,1,2,1,NULL,'2026-02-21 22:04:32'),(40,'租赁订单已开始','您租用的订单 #4 已开始执行，租期 2 天，到期时间：2026-02-23 22:04:41',3,1,2,1,NULL,'2026-02-21 22:04:41'),(41,'租赁订单已开始','您出租的订单 #4 已开始执行，租期 2 天，到期时间：2026-02-23 22:04:41',3,10,1,1,NULL,'2026-02-21 22:04:41'),(42,'租赁订单已完成','您出租的订单 #4 已完成，收益 ¥2.80 已到账',3,10,1,1,NULL,'2026-02-21 22:06:01'),(43,'租赁订单已完成','您租用的订单 #4 已到期完成，感谢使用',3,1,2,1,NULL,'2026-02-21 22:06:01'),(44,'收到新的租赁订单','您的出租「verify_agent_commission」收到新订单，租期2天，等待客服处理',3,11,1,1,NULL,'2026-02-21 22:39:45'),(45,'租赁订单支付成功','您租赁的「verify_agent_commission」已支付成功，等待客服处理',3,1,2,1,NULL,'2026-02-21 22:39:45'),(46,'租赁订单已开始','您租用的订单 #5 已开始执行，租期 2 天，到期时间：2026-02-23 22:39:55',3,1,2,1,NULL,'2026-02-21 22:39:55'),(47,'租赁订单已开始','您出租的订单 #5 已开始执行，租期 2 天，到期时间：2026-02-23 22:39:55',3,11,1,1,NULL,'2026-02-21 22:39:55'),(48,'租赁订单已完成','您出租的订单 #5 已完成，收益 ¥2.80 已到账',3,11,1,1,NULL,'2026-02-21 22:40:48'),(49,'租赁订单已完成','您租用的订单 #5 已到期完成，感谢使用',3,1,2,1,NULL,'2026-02-21 22:40:48'),(50,'恭喜！团长申请已通过','恭喜您！您的团长申请已审核通过。\n\n现在您可以享受以下权益：\n• 推广邀请码，获得下线用户\n• 下线完成任务时，您可获得佣金分成\n\n邀请码：SUBZ5P',3,12,1,1,NULL,'2026-02-23 21:54:58'),(51,'提现审核通过','您的提现申请已审核通过，提现金额：¥10.00，手续费：¥0.30，实际到账：¥9.70。\n\n收款方式：alipay\n收款账号：15900000001',3,13,1,1,NULL,'2026-02-24 11:59:15'),(52,'团长激励奖励到账','恭喜！您的下级用户 test1 完成首次提现，您获得激励奖励 ¥1.00，已自动充值到您的钱包。',3,12,1,1,NULL,'2026-02-24 11:59:15'),(53,'提现审核通过','您的提现申请已审核通过，提现金额：¥5.00，手续费：¥0.15，实际到账：¥4.85。\n\n收款方式：alipay\n收款账号：15900000001',3,14,1,1,NULL,'2026-02-24 12:00:47'),(54,'提现审核通过','您的提现申请已审核通过，提现金额：¥5.00，手续费：¥0.15，实际到账：¥4.85。\n\n收款方式：alipay\n收款账号：15900000001',3,16,1,1,NULL,'2026-02-24 12:03:22'),(55,'团长激励奖励到账','恭喜！您的下级用户 test4 完成首次提现，您获得激励奖励 ¥1.00，已自动充值到您的钱包。',3,12,1,1,NULL,'2026-02-24 12:03:22'),(56,'恭喜！团长申请已通过','恭喜您！您的团长申请已审核通过。\n\n现在您可以享受以下权益：\n• 推广邀请码，获得下线用户\n• 下线完成任务时，您可获得佣金分成\n\n邀请码：KYQUX7',3,17,1,1,NULL,'2026-02-24 14:46:47'),(57,'恭喜！高级团长申请已通过','恭喜您！您的高级团长申请已审核通过。\n\n高级团长权益已生效，佣金将按高级团长标准结算。\n\n邀请码：KYQUX7',3,17,1,1,NULL,'2026-02-24 14:49:57'),(58,'恭喜！团长申请已通过','恭喜您！您的团长申请已审核通过。\n\n现在您可以享受以下权益：\n• 推广邀请码，获得下线用户\n• 下线完成任务时，您可获得佣金分成\n\n邀请码：YXXEZY',3,24,1,1,NULL,'2026-02-24 15:18:31'),(59,'恭喜！高级团长申请已通过','恭喜您！您的高级团长申请已审核通过。\n\n高级团长权益已生效，佣金将按高级团长标准结算。\n\n邀请码：YXXEZY',3,24,1,1,NULL,'2026-02-24 15:19:48'),(60,'提现审核通过','您的提现申请已审核通过，提现金额：¥1.00，手续费：¥0.03，实际到账：¥0.97。\n\n收款方式：alipay\n收款账号：15900000001',3,18,1,1,NULL,'2026-02-24 15:28:16'),(61,'团长激励奖励到账','恭喜！您的下级用户 advanced1 完成首次提现，您获得激励奖励 ¥5.00，已自动充值到您的钱包。',3,17,1,1,NULL,'2026-02-24 15:28:16'),(62,'提现审核未通过','很抱歉，您的提现申请未通过审核。\n\n拒绝原因：收款账号和姓名错误\n\n如有疑问，请联系客服。',3,18,1,1,NULL,'2026-02-24 15:31:43'),(63,'收到新的租赁订单','您的出租「测试租赁系统的新功能，佣金结算」收到新订单，租期1天，等待客服处理',3,17,1,1,NULL,'2026-02-24 15:41:11'),(64,'租赁订单支付成功','您租赁的「测试租赁系统的新功能，佣金结算」已支付成功，等待客服处理',3,1,2,1,NULL,'2026-02-24 15:41:11'),(65,'租赁订单已开始','您租用的订单 #6 已开始执行，租期 1 天，到期时间：2026-02-25 15:41:49',3,1,2,1,NULL,'2026-02-24 15:41:49'),(66,'租赁订单已开始','您出租的订单 #6 已开始执行，租期 1 天，到期时间：2026-02-25 15:41:49',3,17,1,1,NULL,'2026-02-24 15:41:49'),(67,'收到新的租赁订单','您的出租「测试租赁系统的新功能，佣金结算，我的团长是高级团长」收到新订单，租期1天，等待客服处理',3,18,1,1,NULL,'2026-02-24 15:44:39'),(68,'租赁订单支付成功','您租赁的「测试租赁系统的新功能，佣金结算，我的团长是高级团长」已支付成功，等待客服处理',3,1,2,1,NULL,'2026-02-24 15:44:39'),(69,'租赁订单已开始','您租用的订单 #7 已开始执行，租期 1 天，到期时间：2026-02-25 15:44:55',3,1,2,1,NULL,'2026-02-24 15:44:55'),(70,'租赁订单已开始','您出租的订单 #7 已开始执行，租期 1 天，到期时间：2026-02-25 15:44:55',3,18,1,1,NULL,'2026-02-24 15:44:55'),(71,'提现审核通过','您的提现申请已审核通过，提现金额：¥1.00，手续费：¥0.03，实际到账：¥0.97。\n\n收款方式：alipay\n收款账号：15900000001',3,19,1,1,NULL,'2026-02-24 15:51:12'),(72,'团长激励奖励到账','恭喜！您的下级用户 advanced2 完成首次提现，您获得激励奖励 ¥5.00，已自动充值到您的钱包。',3,17,1,1,NULL,'2026-02-24 15:51:12'),(73,'提现审核通过','您的提现申请已审核通过，提现金额：¥1.00，手续费：¥0.03，实际到账：¥0.97。\n\n收款方式：alipay\n收款账号：15900000001',3,20,1,1,NULL,'2026-02-24 15:51:26'),(74,'提现审核通过','您的提现申请已审核通过，提现金额：¥1.00，手续费：¥0.03，实际到账：¥0.97。\n\n收款方式：alipay\n收款账号：15900000001',3,20,1,1,NULL,'2026-02-24 15:51:51'),(75,'提现审核通过','您的提现申请已审核通过，提现金额：¥1.00，手续费：¥0.03，实际到账：¥0.97。\n\n收款方式：alipay\n收款账号：15900000001',3,20,1,1,NULL,'2026-02-24 15:52:59'),(76,'提现审核通过','您的提现申请已审核通过，提现金额：¥1.00，手续费：¥0.03，实际到账：¥0.97。\n\n收款方式：alipay\n收款账号：15900000001',3,20,1,1,NULL,'2026-02-24 15:53:27'),(77,'提现审核通过','您的提现申请已审核通过，提现金额：¥1.00，手续费：¥0.03，实际到账：¥0.97。\n\n收款方式：alipay\n收款账号：15900000001',3,21,1,1,NULL,'2026-02-24 15:54:47'),(78,'团长激励奖励到账','恭喜！您的下级用户 advanced4 完成首次提现，您获得激励奖励 ¥5.00，已自动充值到您的钱包。',3,17,1,1,NULL,'2026-02-24 15:54:47'),(79,'提现审核通过','您的提现申请已审核通过，提现金额：¥1.00，手续费：¥0.03，实际到账：¥0.97。\n\n收款方式：alipay\n收款账号：15900000001',3,22,1,1,NULL,'2026-02-24 15:55:10'),(80,'团长激励奖励到账','恭喜！您的下级用户 advanced5 完成首次提现，您获得激励奖励 ¥5.00，已自动充值到您的钱包。',3,17,1,1,NULL,'2026-02-24 15:55:10'),(81,'提现审核通过','您的提现申请已审核通过，提现金额：¥1.00，手续费：¥0.03，实际到账：¥0.97。\n\n收款方式：alipay\n收款账号：15900000001',3,22,1,1,NULL,'2026-02-24 15:55:22'),(82,'提现审核通过','您的提现申请已审核通过，提现金额：¥1.00，手续费：¥0.03，实际到账：¥0.97。\n\n收款方式：alipay\n收款账号：15900000001',3,23,1,1,NULL,'2026-02-24 15:55:34'),(83,'团长激励奖励到账','恭喜！您的下级用户 advanced6 完成首次提现，您获得激励奖励 ¥5.00，已自动充值到您的钱包。',3,17,1,1,NULL,'2026-02-24 15:55:34'),(84,'提现审核通过','您的提现申请已审核通过，提现金额：¥1.00，手续费：¥0.03，实际到账：¥0.97。\n\n收款方式：alipay\n收款账号：15900000001',3,23,1,1,NULL,'2026-02-24 16:00:15'),(85,'租赁订单已完成','您出租的订单 #6 已完成，收益 ¥60.00 已到账',3,17,1,1,NULL,'2026-02-24 21:00:02'),(86,'租赁订单已完成','您租用的订单 #6 已到期完成，感谢使用',3,1,2,1,NULL,'2026-02-24 21:00:02'),(87,'租赁订单已完成','您出租的订单 #7 已完成，收益 ¥60.00 已到账',3,18,1,1,NULL,'2026-02-24 21:00:02'),(88,'租赁订单已完成','您租用的订单 #7 已到期完成，感谢使用',3,1,2,1,NULL,'2026-02-24 21:00:02'),(89,'提现审核未通过','很抱歉，您的提现申请未通过审核。\n\n拒绝原因：账号信息错误\n\n如有疑问，请联系客服。',3,17,1,1,NULL,'2026-02-25 10:16:49'),(90,'提现审核通过','您的提现申请已审核通过，提现金额：¥10.00，手续费：¥0.30，实际到账：¥9.70。\n\n收款方式：alipay\n收款账号：15900000001',3,17,1,1,NULL,'2026-02-25 10:16:54'),(91,'团长激励奖励到账','恭喜！您的下级用户 advanced 完成首次提现，您获得激励奖励 ¥5.00，已自动充值到您的钱包。',3,12,1,1,NULL,'2026-02-25 10:16:54'),(92,'提现审核通过','您的提现申请已审核通过，提现金额：¥10.00，手续费：¥0.30，实际到账：¥9.70。\n\n收款方式：alipay\n收款账号：15900000001',3,17,1,1,NULL,'2026-02-25 10:31:19'),(93,'收到新的租赁订单','您的出租「测试租赁系统的新功能，佣金结算」收到新订单，租期1天，等待客服处理',3,1,2,1,NULL,'2026-02-25 15:45:46'),(94,'租赁订单支付成功','您租赁的「测试租赁系统的新功能，佣金结算」已支付成功，等待客服处理',3,17,1,1,NULL,'2026-02-25 15:45:46'),(95,'收到新的应征申请','您的求租「测试租赁系统的新功能，佣金结算」收到了新的应征，请前往查看审核',3,17,1,1,NULL,'2026-02-25 17:39:26'),(96,'应征审核未通过','您应征的求租「测试租赁系统的新功能，佣金结算」未通过审核：没有输出出租天数',3,18,1,1,NULL,'2026-02-25 17:49:38'),(97,'收到新的应征申请','您的求租「测试租赁系统的新功能，佣金结算」收到了新的应征，请前往查看审核',3,17,1,1,NULL,'2026-02-25 17:51:35'),(98,'应征审核通过','您应征的求租「测试租赁系统的新功能，佣金结算」已通过审核，订单已生成，等待客服处理',3,12,1,1,NULL,'2026-02-25 18:12:08'),(99,'应征已审核','您的求租「测试租赁系统的新功能，佣金结算」已选中应征方，订单已创建',3,17,1,1,NULL,'2026-02-25 18:12:08'),(100,'收到新的应征申请','您的求租「测试发布求租信息2」收到了新的应征，请前往查看审核',3,1,2,1,NULL,'2026-02-25 21:17:35'),(101,'租赁订单已开始','您租用的订单 #9 已开始执行，租期 2 天，到期时间：2026-02-27 22:57:56',3,17,1,1,NULL,'2026-02-25 22:57:56'),(102,'租赁订单已开始','您出租的订单 #9 已开始执行，租期 2 天，到期时间：2026-02-27 22:57:56',3,12,1,1,NULL,'2026-02-25 22:57:56'),(103,'租赁订单已取消并退款','您租用的订单 #8 已由客服取消，款项已退回钱包。',3,17,1,1,NULL,'2026-02-25 22:57:59'),(104,'租赁订单已取消','您出租的订单 #8 已由客服取消。',3,1,2,1,NULL,'2026-02-25 22:57:59'),(105,'租赁订单已终止','您租用的订单 #1 已被客服终止，如有疑问请联系客服。',3,1,2,1,NULL,'2026-02-25 22:58:10'),(106,'租赁订单已终止','您出租的订单 #1 已被客服终止。',3,1,1,1,NULL,'2026-02-25 22:58:10'),(107,'充值审核通过','您的充值申请已审核通过，金额：¥10.00 已到账。感谢您的使用！',3,1,2,1,NULL,'2026-02-26 23:30:31'),(108,'充值审核通过','您的充值申请已审核通过，金额：¥200.00 已到账。感谢您的使用！',3,1,2,1,NULL,'2026-02-26 23:30:33');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recharge_requests`
--

DROP TABLE IF EXISTS `recharge_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recharge_requests` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '充值申请ID',
  `user_id` bigint unsigned NOT NULL COMMENT '用户ID',
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（冗余字段）',
  `user_type` tinyint NOT NULL COMMENT '用户类型：1=C端，2=B端',
  `wallet_id` bigint unsigned NOT NULL COMMENT '钱包ID',
  `amount` bigint NOT NULL DEFAULT '0' COMMENT '充值金额（单位：分）',
  `payment_method` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '支付方式：alipay=支付宝，wechat=微信，usdt=USDT',
  `payment_voucher` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '支付凭证图片URL',
  `log_id` bigint unsigned DEFAULT NULL COMMENT '关联的钱包流水ID',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '审核状态：0=待审核，1=审核通过，2=审核拒绝',
  `reject_reason` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '拒绝原因',
  `admin_id` bigint unsigned DEFAULT NULL COMMENT '审核管理员ID',
  `reviewed_at` datetime DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_user_type` (`user_type`),
  KEY `idx_wallet_id` (`wallet_id`),
  KEY `idx_log_id` (`log_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='充值申请表-需要管理员审核';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recharge_requests`
--

LOCK TABLES `recharge_requests` WRITE;
/*!40000 ALTER TABLE `recharge_requests` DISABLE KEYS */;
INSERT INTO `recharge_requests` VALUES (1,1,'bceshi',2,1,100000,'alipay','http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg',1,1,NULL,NULL,'2026-02-16 11:45:59','2026-02-16 11:44:32'),(2,1,'bceshi',2,1,20000,'alipay','http://54.179.253.64:28806/img/344ccc2b0873c9f91547ebce99c6434a.jpg',250,1,NULL,NULL,'2026-02-26 23:30:33','2026-02-26 23:17:58'),(3,1,'bceshi',2,1,1000,'alipay','http://54.179.253.64:28806/img/ebf8e518973ed5280c182c257b611587.jpg',251,1,NULL,NULL,'2026-02-26 23:30:31','2026-02-26 23:26:09');
/*!40000 ALTER TABLE `recharge_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rental_applications`
--

DROP TABLE IF EXISTS `rental_applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rental_applications` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '应征ID',
  `demand_id` bigint unsigned NOT NULL COMMENT '关联的求租信息ID',
  `applicant_user_id` bigint unsigned NOT NULL COMMENT '应征者用户ID',
  `applicant_user_type` tinyint NOT NULL COMMENT '应征者类型：1=C端，2=B端',
  `allow_renew` tinyint NOT NULL DEFAULT '1' COMMENT '是否允许续租：0=不允许，1=允许',
  `application_json` json DEFAULT NULL COMMENT '应征资料（账号截图、说明等）',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态：0=待审核，1=审核通过（自动生成订单），2=已驳回',
  `review_remark` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '审核备注（通过/驳回原因）',
  `reviewed_at` datetime DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_demand_id` (`demand_id`),
  KEY `idx_applicant` (`applicant_user_id`,`applicant_user_type`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='求租应征表-我有符合要求的账号';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rental_applications`
--

LOCK TABLES `rental_applications` WRITE;
/*!40000 ALTER TABLE `rental_applications` DISABLE KEYS */;
INSERT INTO `rental_applications` VALUES (1,1,1,1,0,'{\"description\": \"我这个账号有10万粉丝\", \"screenshots\": [\"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\", \"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"]}',1,'','2026-02-16 13:22:26','2026-02-16 13:15:14','2026-02-16 13:22:26'),(2,3,18,1,1,'{\"description\": \"测试求租匹配功能，应征\", \"screenshots\": [\"http://54.179.253.64:28806/img/344ccc2b0873c9f91547ebce99c6434a.jpg\"]}',2,'没有输出出租天数','2026-02-25 17:49:38','2026-02-25 17:39:26','2026-02-25 17:49:38'),(3,3,12,1,1,'{\"day\": \"5\", \"description\": \"测试求租匹配功能，应征\", \"screenshots\": [\"http://54.179.253.64:28806/img/344ccc2b0873c9f91547ebce99c6434a.jpg\"]}',1,'','2026-02-25 18:12:08','2026-02-25 17:51:35','2026-02-25 18:12:08'),(4,2,17,1,1,'{\"day\": \"2\", \"description\": \"测试,我要出租账号给求租方,可以出租2天\", \"screenshots\": [\"http://54.179.253.64:28806/img/344ccc2b0873c9f91547ebce99c6434a.jpg\"]}',0,NULL,NULL,'2026-02-25 21:17:35','2026-02-25 21:17:35');
/*!40000 ALTER TABLE `rental_applications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rental_demands`
--

DROP TABLE IF EXISTS `rental_demands`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rental_demands` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '求租信息ID',
  `user_id` bigint unsigned NOT NULL COMMENT '求租方用户ID',
  `user_type` tinyint NOT NULL COMMENT '求租方类型：1=C端，2=B端',
  `wallet_id` bigint unsigned NOT NULL COMMENT '钱包ID',
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `budget_amount` bigint NOT NULL DEFAULT '0' COMMENT '预算金额（单位：分，发布时冻结）',
  `days_needed` int unsigned NOT NULL COMMENT '需要租用天数',
  `deadline` datetime NOT NULL COMMENT '截止时间（最多30天）',
  `requirements_json` json DEFAULT NULL COMMENT '账号要求、登录要求等详细需求',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：0=已下架（释放冻结），1=发布中（预算已冻结），2=已成交（订单生成），3=已过期（自动下架，释放冻结）',
  `view_count` int unsigned NOT NULL DEFAULT '0' COMMENT '浏览次数',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`,`user_type`),
  KEY `idx_wallet_id` (`wallet_id`),
  KEY `idx_status` (`status`),
  KEY `idx_deadline` (`deadline`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='求租信息表-账号需求市场';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rental_demands`
--

LOCK TABLES `rental_demands` WRITE;
/*!40000 ALTER TABLE `rental_demands` DISABLE KEYS */;
INSERT INTO `rental_demands` VALUES (1,1,2,1,'测试更新求租信息的功能',300,10,'2026-02-27 21:46:40','{\"login_requirements\": \"扫码登录\", \"other_requirements\": \"需要实名认证\", \"account_requirements\": \"粉丝10000万+，权重高\"}',2,0,'2026-02-16 12:56:47','2026-02-16 13:22:26'),(2,1,2,1,'测试发布求租信息2',100,1,'2026-03-01 00:00:00','{\"qq_number\": \"1306904145\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"phone_message\": \"true\", \"basic_information\": \"true\", \"other_requirements\": \"其他要求，例如要求分数数量\", \"account_requirements\": \"粉丝10000万+，权重高\", \"identity_verification\": \"true\"}',1,0,'2026-02-16 13:04:57','2026-02-16 13:04:57'),(3,17,1,18,'测试租赁系统的新功能，佣金结算',2000,2,'2026-03-01 00:00:00','{\"email\": \"douyin@qq.com\", \"qq_number\": \"2235676091\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"测试租赁系统的新功能，佣金结算，卖方分成60%，普通团长10%，高级团长20%；这是出租信息详细描速\", \"phone_number\": \"15900000000\", \"phone_message\": \"true\", \"platform_type\": \"douyin\", \"requested_all\": \"true\", \"basic_information\": \"true\", \"other_requirements\": \"无其他要求\", \"account_requirements\": \"粉丝10000万+，权重高\", \"identity_verification\": \"true\"}',2,0,'2026-02-25 17:03:49','2026-02-25 18:12:08');
/*!40000 ALTER TABLE `rental_demands` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rental_offers`
--

DROP TABLE IF EXISTS `rental_offers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rental_offers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '出租信息ID',
  `user_id` bigint unsigned NOT NULL COMMENT '出租方用户ID',
  `user_type` tinyint NOT NULL COMMENT '出租方类型：1=C端，2=B端',
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `price_per_day` bigint NOT NULL DEFAULT '0' COMMENT '日租金（单位：分）',
  `min_days` int unsigned NOT NULL DEFAULT '1' COMMENT '最少租赁天数',
  `max_days` int unsigned NOT NULL DEFAULT '30' COMMENT '最多租赁天数',
  `allow_renew` tinyint NOT NULL DEFAULT '0' COMMENT '是否允许续租：0=不允许，1=允许',
  `content_json` json DEFAULT NULL COMMENT '详细内容（账号能力、登录方式、说明、截图等）',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：0=已下架，1=上架中，2=已封禁',
  `view_count` int unsigned NOT NULL DEFAULT '0' COMMENT '浏览次数',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`,`user_type`),
  KEY `idx_status` (`status`),
  KEY `idx_price` (`price_per_day`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='出租信息表-账号出租市场';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rental_offers`
--

LOCK TABLES `rental_offers` WRITE;
/*!40000 ALTER TABLE `rental_offers` DISABLE KEYS */;
INSERT INTO `rental_offers` VALUES (1,1,1,'更新抖音账号出租',50,1,10,0,'{\"email\": \"qq@qq.com\", \"qq_number\": \"\", \"scan_code\": \"false\", \"deblocking\": \"false\", \"post_douyin\": \"false\", \"account_info\": \"测试更新出租信息功能\", \"phone_number\": \"\", \"other_require\": \"false\", \"phone_message\": \"false\", \"basic_information\": \"false\", \"identity_verification\": \"false\"}',1,1,'2026-02-16 12:29:16','2026-02-16 15:03:00'),(2,1,2,'抖音账号出租',5000,1,30,1,'{\"email\": \"true\", \"images\": [\"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"], \"qq_number\": \"true\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"测试抖音账号出租发布功能，这一条是B端用户bceshi发布的\", \"phone_number\": \"true\", \"other_require\": \"true\", \"phone_message\": \"true\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}',1,2,'2026-02-16 12:30:09','2026-02-25 21:44:34'),(3,1,1,'抖音账号出租',100,1,30,1,'{\"email\": \"true\", \"images\": [\"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"], \"qq_number\": \"true\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"测试抖音账号出租发布功能，这一条是c端用户cceshi1发布的,第二条出租信息，测试出租金额问题\", \"phone_number\": \"true\", \"other_require\": \"true\", \"phone_message\": \"true\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}',0,0,'2026-02-16 12:33:47','2026-02-16 23:47:20'),(7,17,1,'测试租赁系统的新功能，佣金结算',10000,1,30,0,'{\"platform_type\": \"douyin\"}',0,1,'2026-02-24 15:39:28','2026-02-25 16:47:44'),(8,18,1,'测试租赁系统的新功能，佣金结算，我的团长是高级团长',10000,1,30,0,'{\"email\": \"true\", \"images\": [\"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"], \"qq_number\": \"true\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"测试租赁系统的新功能，佣金结算，卖方分成60%，普通团长10%，高级团长20%,此条信息测试高级团长的佣金\", \"phone_number\": \"true\", \"other_require\": \"true\", \"phone_message\": \"true\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}',0,0,'2026-02-24 15:44:28','2026-02-24 15:44:39'),(9,1,2,'测试租赁系统的新功能，佣金结算',10,1,30,0,'{\"email\": \"true\", \"images\": [\"http://54.179.253.64:28806/img/344ccc2b0873c9f91547ebce99c6434a.jpg\"], \"qq_number\": \"true\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"测试租赁系统的新功能，佣金结算，卖方分成60%，普通团长10%，高级团长20%\", \"phone_number\": \"true\", \"other_require\": \"true\", \"phone_message\": \"true\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}',0,4,'2026-02-25 15:44:25','2026-02-25 15:45:46'),(10,17,1,'测试新UI发布出租',100,1,30,0,'{\"email\": \"qq@qq.com\", \"images\": [\"http://54.179.253.64:28806/img/5cf6dbffd95e223e113aaef3741cf56c.webp\", \"http://54.179.253.64:28806/img/83230d83ed52ee79f4ebb3ca01d46269.webp\"], \"qq_number\": \"2235676091\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"false\", \"account_info\": \"测试新UI发布出租\", \"phone_number\": \"15900000000\", \"other_require\": \"true\", \"phone_message\": \"true\", \"platform_type\": \"qq\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}',1,1,'2026-02-25 22:40:11','2026-02-27 01:25:02');
/*!40000 ALTER TABLE `rental_offers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rental_orders`
--

DROP TABLE IF EXISTS `rental_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rental_orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `source_type` tinyint NOT NULL COMMENT '来源类型：0=出租信息成交，1=求租信息成交',
  `source_id` bigint unsigned NOT NULL COMMENT '来源ID（offer_id或demand_id）',
  `buyer_user_id` bigint unsigned NOT NULL COMMENT '买方（租用方）用户ID',
  `buyer_user_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '买方类型：b=B端，c=C端',
  `buyer_wallet_id` bigint unsigned NOT NULL COMMENT '买方钱包ID',
  `buyer_info_json` json DEFAULT NULL COMMENT '买方详细信息（求租需求/下单备注等）',
  `seller_user_id` bigint unsigned NOT NULL COMMENT '卖方（出租方）用户ID',
  `seller_user_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '卖方类型：b=B端，c=C端',
  `seller_wallet_id` bigint unsigned NOT NULL COMMENT '卖方钱包ID',
  `seller_info_json` json DEFAULT NULL COMMENT '卖方详细信息（账号信息/应征资料等）',
  `agent_user_id` bigint unsigned DEFAULT NULL COMMENT '团长用户ID',
  `agent_amount` bigint NOT NULL DEFAULT '0' COMMENT '团长佣金金额（分）',
  `second_agent_user_id` bigint unsigned DEFAULT NULL COMMENT '二级代理用户ID',
  `second_agent_amount` bigint NOT NULL DEFAULT '0' COMMENT '二级代理佣金金额（分）',
  `total_amount` bigint NOT NULL COMMENT '订单总金额（单位：分）',
  `platform_amount` bigint NOT NULL DEFAULT '0' COMMENT '平台抽成金额（单位：分）',
  `seller_amount` bigint NOT NULL DEFAULT '0' COMMENT '卖方实得金额（单位：分）',
  `days` int unsigned NOT NULL COMMENT '租赁天数',
  `allow_renew` tinyint NOT NULL DEFAULT '0' COMMENT '是否允许续租：0=不允许，1=允许',
  `order_json` json DEFAULT NULL COMMENT '订单额外数据（价格快照等）',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态：0=待支付，1=已支付/待客服，2=进行中，3=已完成，4=已取消',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_source` (`source_type`,`source_id`),
  KEY `idx_buyer` (`buyer_user_id`,`buyer_user_type`),
  KEY `idx_seller` (`seller_user_id`,`seller_user_type`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='租赁订单表-成交订单记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rental_orders`
--

LOCK TABLES `rental_orders` WRITE;
/*!40000 ALTER TABLE `rental_orders` DISABLE KEYS */;
INSERT INTO `rental_orders` VALUES (1,1,1,1,'b',2,'{\"login_requirements\": \"扫码登录\", \"other_requirements\": \"需要实名认证\", \"account_requirements\": \"粉丝10000万+，权重高\"}',1,'c',2,'{\"description\": \"我这个账号有10万粉丝\", \"screenshots\": [\"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\", \"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"]}',NULL,0,3000,75,225,10,0,'{\"end_time\": 1772031490, \"max_days\": 30, \"min_days\": 1, \"start_time\": 1771248200, \"demand_title\": \"测试更新求租信息的功能\", \"price_per_day\": 300, \"terminated_at\": 1772031490, \"application_id\": 1, \"original_end_time\": 1772112200}',4,'2026-02-16 13:22:26','2026-02-25 22:58:10'),(2,0,3,1,'b',1,'{\"notes\": \"测试购买出租的账号功能，出租下单\", \"usage\": \"用于直播带货\", \"contact\": \"qq@qq.com\"}',1,'c',2,'{\"email\": \"true\", \"images\": [\"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"], \"qq_number\": \"true\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"测试抖音账号出租发布功能，这一条是c端用户cceshi1发布的,第二条出租信息，测试出租金额问题\", \"phone_number\": \"true\", \"other_require\": \"true\", \"phone_message\": \"true\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}',NULL,0,200,50,150,2,1,'{\"end_time\": 1771430347, \"max_days\": 30, \"min_days\": 1, \"start_time\": 1771257547, \"offer_title\": \"抖音账号出租\", \"price_per_day\": 100, \"renew_history\": [{\"renew_at\": 1771257555, \"renew_days\": 1, \"new_end_time\": 1771430347, \"renew_amount\": 100}]}',3,'2026-02-16 23:47:20','2026-02-19 00:00:03'),(6,0,7,1,'b',1,'{\"notes\": \"无其他要求\", \"usage\": \"测试租赁系统的新功能，佣金结算，卖方分成60%，普通团长10%，高级团长20%\", \"contact\": \"微信登录\"}',17,'c',18,'{\"email\": \"true\", \"images\": [\"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"], \"qq_number\": \"true\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"测试租赁系统的新功能，佣金结算，卖方分成60%，普通团长10%，高级团长20%\", \"phone_number\": \"true\", \"other_require\": \"true\", \"phone_message\": \"true\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}',12,1000,10000,3000,6000,1,0,'{\"end_time\": 1771938000, \"max_days\": 30, \"min_days\": 1, \"start_time\": 1771918909, \"offer_title\": \"测试租赁系统的新功能，佣金结算\", \"price_per_day\": 10000}',3,'2026-02-24 15:41:11','2026-02-24 21:00:02'),(7,0,8,1,'b',1,'{\"notes\": \"无其他要求\", \"usage\": \"测试租赁系统的新功能，佣金结算，卖方分成60%，普通团长10%，高级团长20%\", \"contact\": \"微信登录\"}',18,'c',19,'{\"email\": \"true\", \"images\": [\"http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg\"], \"qq_number\": \"true\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"测试租赁系统的新功能，佣金结算，卖方分成60%，普通团长10%，高级团长20%,此条信息测试高级团长的佣金\", \"phone_number\": \"true\", \"other_require\": \"true\", \"phone_message\": \"true\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}',17,2000,10000,2000,6000,1,0,'{\"end_time\": 1771938000, \"max_days\": 30, \"min_days\": 1, \"start_time\": 1771919095, \"offer_title\": \"测试租赁系统的新功能，佣金结算，我的团长是高级团长\", \"price_per_day\": 10000}',3,'2026-02-24 15:44:39','2026-02-24 21:00:02'),(8,0,9,17,'c',18,'{\"notes\": \"11111\", \"usage\": \"内容创作\", \"contact\": \"QQ:2235676091\"}',1,'b',1,'{\"email\": \"true\", \"images\": [\"http://54.179.253.64:28806/img/344ccc2b0873c9f91547ebce99c6434a.jpg\"], \"qq_number\": \"true\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"测试租赁系统的新功能，佣金结算，卖方分成60%，普通团长10%，高级团长20%\", \"phone_number\": \"true\", \"other_require\": \"true\", \"phone_message\": \"true\", \"basic_information\": \"true\", \"identity_verification\": \"true\"}',NULL,0,10,4,6,1,0,'{\"max_days\": 30, \"min_days\": 1, \"offer_title\": \"测试租赁系统的新功能，佣金结算\", \"price_per_day\": 10}',4,'2026-02-25 15:45:46','2026-02-25 22:57:59'),(9,1,3,17,'c',18,'{\"email\": \"douyin@qq.com\", \"qq_number\": \"2235676091\", \"scan_code\": \"true\", \"deblocking\": \"true\", \"post_douyin\": \"true\", \"account_info\": \"测试租赁系统的新功能，佣金结算，卖方分成60%，普通团长10%，高级团长20%；这是出租信息详细描速\", \"phone_number\": \"15900000000\", \"phone_message\": \"true\", \"platform_type\": \"douyin\", \"requested_all\": \"true\", \"basic_information\": \"true\", \"other_requirements\": \"无其他要求\", \"account_requirements\": \"粉丝10000万+，权重高\", \"identity_verification\": \"true\"}',12,'c',13,'{\"day\": \"5\", \"description\": \"测试求租匹配功能，应征\", \"screenshots\": [\"http://54.179.253.64:28806/img/344ccc2b0873c9f91547ebce99c6434a.jpg\"]}',NULL,0,4000,800,1200,2,1,'{\"end_time\": 1772204276, \"max_days\": 30, \"min_days\": 1, \"start_time\": 1772031476, \"demand_title\": \"测试租赁系统的新功能，佣金结算\", \"price_per_day\": 2000, \"application_id\": 3}',2,'2026-02-25 18:12:08','2026-02-25 22:57:56');
/*!40000 ALTER TABLE `rental_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rental_ticket_messages`
--

DROP TABLE IF EXISTS `rental_ticket_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rental_ticket_messages` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `ticket_id` bigint unsigned NOT NULL COMMENT '工单ID',
  `sender_type` tinyint NOT NULL COMMENT '发送者类型：1=C端用户，2=B端用户，3=Admin，4=系统',
  `sender_id` bigint unsigned DEFAULT NULL COMMENT '发送者ID（系统消息为NULL）',
  `message_type` tinyint NOT NULL DEFAULT '0' COMMENT '消息类型：0=文本，1=图片，2=文件，3=系统通知',
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '消息内容',
  `attachments` json DEFAULT NULL COMMENT '附件（JSON数组：[{url,type,name,size}]）',
  `is_read` tinyint NOT NULL DEFAULT '0' COMMENT '是否已读：0=未读，1=已读',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  PRIMARY KEY (`id`),
  KEY `idx_ticket_id` (`ticket_id`),
  KEY `idx_sender` (`sender_type`,`sender_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='工单消息表-客服聊天记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rental_ticket_messages`
--

LOCK TABLES `rental_ticket_messages` WRITE;
/*!40000 ALTER TABLE `rental_ticket_messages` DISABLE KEYS */;
INSERT INTO `rental_ticket_messages` VALUES (1,1,4,NULL,3,'【工单已创建】\n━━━━━━━━━━━━━━━━\n工单编号：TK20260216784973\n关联订单：#1\n订单类型：求租\n订单状态：进行中\n租赁天数：10天\n订单金额：¥30.00\n购买方：B端用户（ID:1）\n出租方：C端用户（ID:1）\n创建时间：2026-02-16 13:22:26\n━━━━━━━━━━━━━━━━\n工单问题：测试创建工单功能，这个订单存在诈骗行为,账号货不对板\n问题描述：卖家修改账号信息\n━━━━━━━━━━━━━━━━\n本工单由购买方发起，买卖双方及管理员可参与讨论。\n请勿脱离平台交易，谨防诈骗！',NULL,1,'2026-02-16 13:26:59'),(2,1,1,1,0,'我要验牌',NULL,0,'2026-02-16 13:30:10'),(3,1,2,1,0,'牌没有问题http://134.122.136.221:4667/img/a9b76843e779d5727ecf6b4269287206.jpg',NULL,0,'2026-02-16 13:33:01'),(4,1,4,NULL,3,'━━━━━━━━━━━━━━━━\n【工单已关闭】\n工单编号：TK20260216784973\n关闭原因：问题已解决\n关闭时间：2026-02-16 21:33:35\n━━━━━━━━━━━━━━━━',NULL,0,'2026-02-16 13:33:35'),(5,1,4,NULL,0,'工单已由管理员关闭。原因：管理员关闭工单',NULL,1,'2026-02-16 13:37:14');
/*!40000 ALTER TABLE `rental_ticket_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rental_tickets`
--

DROP TABLE IF EXISTS `rental_tickets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rental_tickets` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '工单ID',
  `ticket_no` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工单编号（TK + YYYYMMDD + 6位随机数）',
  `order_id` bigint unsigned NOT NULL COMMENT '关联订单ID',
  `creator_user_id` bigint unsigned NOT NULL COMMENT '创建者用户ID',
  `creator_user_type` tinyint NOT NULL COMMENT '创建者类型：1=C端，2=B端',
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工单标题',
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '问题描述',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态：0=待处理，1=处理中，2=已解决，3=已关闭',
  `handler_id` bigint unsigned DEFAULT NULL COMMENT '处理人ID（Admin）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `closed_at` datetime DEFAULT NULL COMMENT '关闭时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ticket_no` (`ticket_no`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_creator` (`creator_user_id`,`creator_user_type`),
  KEY `idx_status` (`status`),
  KEY `idx_handler_id` (`handler_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='租赁工单表-售后纠纷处理';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rental_tickets`
--

LOCK TABLES `rental_tickets` WRITE;
/*!40000 ALTER TABLE `rental_tickets` DISABLE KEYS */;
INSERT INTO `rental_tickets` VALUES (1,'TK20260216784973',1,1,2,'测试创建工单功能，这个订单存在诈骗行为,账号货不对板','卖家修改账号信息',2,NULL,'2026-02-16 13:26:59','2026-02-16 13:37:14','2026-02-16 13:37:14');
/*!40000 ALTER TABLE `rental_tickets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_templates`
--

DROP TABLE IF EXISTS `task_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_templates` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '模板ID',
  `type` tinyint NOT NULL DEFAULT '0' COMMENT '任务类型：0=单任务，1=组合任务',
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务标题',
  `price` decimal(18,2) NOT NULL DEFAULT '0.00' COMMENT '单价（元，单任务用）',
  `description1` text COLLATE utf8mb4_unicode_ci COMMENT '描述信息1',
  `description2` text COLLATE utf8mb4_unicode_ci COMMENT '描述信息2',
  `stage1_title` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '阶段1标题（组合任务用）',
  `stage1_price` decimal(18,2) DEFAULT NULL COMMENT '阶段1单价（组合任务用）',
  `stage2_title` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '阶段2标题（组合任务用）',
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
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_type` (`type`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='任务模板表-平台配置';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_templates`
--

LOCK TABLES `task_templates` WRITE;
/*!40000 ALTER TABLE `task_templates` DISABLE KEYS */;
INSERT INTO `task_templates` VALUES (1,0,'上评评论',3.00,'发布上评评论','',NULL,NULL,NULL,NULL,NULL,NULL,100,50,50,NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-02-15 14:51:45'),(2,0,'中评评论',2.00,'发布中评评论','',NULL,NULL,NULL,NULL,NULL,NULL,80,30,30,NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-02-15 14:51:45'),(3,0,'放大镜搜索词',5.00,'抖音平台规则问题，本产品属于稀罕出版大礼，搜索词搜索次数就越多，出现概率越大','',NULL,NULL,NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-02-15 14:51:45'),(4,1,'上中评评论',9.00,'组合评论：上评+中评(1+3)','','上评评论',3.00,'中评回复',2.00,1,3,0,0,0,100,50,50,80,30,30,1,'2026-02-15 14:51:45'),(5,1,'中下评评论',6.00,'组合评论：中评+下评(1+2)','真人评论，评论内容真实有效。下评完成后需要这个晒图评论为晒图套餐。','中评评论',3.00,'下评回复',3.00,1,1,0,0,0,130,45,43,130,45,45,1,'2026-02-15 14:51:45');
/*!40000 ALTER TABLE `task_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_notifications`
--

DROP TABLE IF EXISTS `user_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_notifications` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `notification_id` bigint unsigned NOT NULL COMMENT '通知ID',
  `user_id` bigint unsigned NOT NULL COMMENT '用户ID',
  `user_type` tinyint NOT NULL COMMENT '用户类型：1=C端，2=B端',
  `is_read` tinyint NOT NULL DEFAULT '0' COMMENT '是否已读：0=未读，1=已读',
  `read_at` datetime DEFAULT NULL COMMENT '阅读时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '接收时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_notification_user` (`notification_id`,`user_id`,`user_type`),
  KEY `idx_user` (`user_id`,`user_type`),
  KEY `idx_notification_id` (`notification_id`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户通知表-每个用户收到的通知';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_notifications`
--

LOCK TABLES `user_notifications` WRITE;
/*!40000 ALTER TABLE `user_notifications` DISABLE KEYS */;
INSERT INTO `user_notifications` VALUES (1,1,1,2,1,'2026-02-16 12:02:22','2026-02-16 11:45:59'),(2,2,1,1,0,NULL,'2026-02-16 12:19:08'),(3,3,1,2,0,NULL,'2026-02-16 13:15:14'),(4,4,1,1,0,NULL,'2026-02-16 13:22:26'),(5,5,1,2,0,NULL,'2026-02-16 13:22:26'),(6,6,1,2,0,NULL,'2026-02-16 13:23:20'),(7,7,1,1,0,NULL,'2026-02-16 13:23:20'),(8,8,1,1,0,NULL,'2026-02-16 13:26:59'),(9,9,1,2,1,'2026-02-16 13:31:02','2026-02-16 13:30:10'),(10,10,1,1,0,NULL,'2026-02-16 13:33:01'),(11,11,1,1,0,NULL,'2026-02-16 13:33:35'),(12,12,1,2,0,NULL,'2026-02-16 13:37:14'),(13,13,1,1,0,NULL,'2026-02-16 13:37:14'),(14,14,1,1,0,NULL,'2026-02-16 15:22:02'),(15,15,2,1,0,NULL,'2026-02-16 15:24:02'),(16,16,1,1,0,NULL,'2026-02-16 23:47:20'),(17,17,1,2,0,NULL,'2026-02-16 23:47:20'),(18,18,1,2,0,NULL,'2026-02-16 23:59:07'),(19,19,1,1,0,NULL,'2026-02-16 23:59:07'),(20,20,1,1,0,NULL,'2026-02-16 23:59:15'),(21,21,1,2,0,NULL,'2026-02-16 23:59:15'),(22,22,1,1,0,NULL,'2026-02-19 00:00:03'),(23,23,1,2,1,'2026-02-26 16:57:33','2026-02-19 00:00:03'),(24,24,3,1,0,NULL,'2026-02-21 18:33:39'),(25,25,3,1,0,NULL,'2026-02-21 18:35:08'),(26,26,4,1,0,NULL,'2026-02-21 18:48:06'),(33,33,1,2,1,'2026-02-26 16:57:33','2026-02-21 21:54:13'),(34,34,1,2,1,'2026-02-26 16:57:33','2026-02-21 21:55:44'),(37,37,1,2,1,'2026-02-26 16:57:33','2026-02-21 21:56:02'),(39,39,1,2,1,'2026-02-26 16:57:33','2026-02-21 22:04:32'),(40,40,1,2,1,'2026-02-26 16:57:33','2026-02-21 22:04:41'),(43,43,1,2,1,'2026-02-26 16:57:33','2026-02-21 22:06:01'),(45,45,1,2,1,'2026-02-26 16:57:33','2026-02-21 22:39:45'),(46,46,1,2,1,'2026-02-26 16:57:33','2026-02-21 22:39:55'),(49,49,1,2,1,'2026-02-26 16:57:33','2026-02-21 22:40:48'),(50,50,12,1,0,NULL,'2026-02-23 21:54:58'),(51,51,13,1,0,NULL,'2026-02-24 11:59:15'),(52,52,12,1,0,NULL,'2026-02-24 11:59:15'),(53,53,14,1,0,NULL,'2026-02-24 12:00:47'),(54,54,16,1,0,NULL,'2026-02-24 12:03:22'),(55,55,12,1,0,NULL,'2026-02-24 12:03:22'),(56,56,17,1,0,NULL,'2026-02-24 14:46:47'),(57,57,17,1,0,NULL,'2026-02-24 14:49:57'),(58,58,24,1,0,NULL,'2026-02-24 15:18:31'),(59,59,24,1,0,NULL,'2026-02-24 15:19:48'),(60,60,18,1,0,NULL,'2026-02-24 15:28:16'),(61,61,17,1,0,NULL,'2026-02-24 15:28:16'),(62,62,18,1,0,NULL,'2026-02-24 15:31:43'),(63,63,17,1,0,NULL,'2026-02-24 15:41:11'),(64,64,1,2,1,'2026-02-26 16:57:33','2026-02-24 15:41:11'),(65,65,1,2,1,'2026-02-26 16:57:33','2026-02-24 15:41:49'),(66,66,17,1,0,NULL,'2026-02-24 15:41:49'),(67,67,18,1,0,NULL,'2026-02-24 15:44:39'),(68,68,1,2,1,'2026-02-26 16:57:33','2026-02-24 15:44:39'),(69,69,1,2,1,'2026-02-26 16:57:33','2026-02-24 15:44:55'),(70,70,18,1,0,NULL,'2026-02-24 15:44:55'),(71,71,19,1,0,NULL,'2026-02-24 15:51:12'),(72,72,17,1,0,NULL,'2026-02-24 15:51:12'),(73,73,20,1,0,NULL,'2026-02-24 15:51:26'),(74,74,20,1,0,NULL,'2026-02-24 15:51:51'),(75,75,20,1,0,NULL,'2026-02-24 15:52:59'),(76,76,20,1,0,NULL,'2026-02-24 15:53:27'),(77,77,21,1,0,NULL,'2026-02-24 15:54:47'),(78,78,17,1,0,NULL,'2026-02-24 15:54:47'),(79,79,22,1,0,NULL,'2026-02-24 15:55:10'),(80,80,17,1,0,NULL,'2026-02-24 15:55:10'),(81,81,22,1,0,NULL,'2026-02-24 15:55:22'),(82,82,23,1,0,NULL,'2026-02-24 15:55:34'),(83,83,17,1,0,NULL,'2026-02-24 15:55:34'),(84,84,23,1,0,NULL,'2026-02-24 16:00:15'),(85,85,17,1,0,NULL,'2026-02-24 21:00:02'),(86,86,1,2,1,'2026-02-26 16:57:33','2026-02-24 21:00:02'),(87,87,18,1,0,NULL,'2026-02-24 21:00:02'),(88,88,1,2,1,'2026-02-26 16:57:33','2026-02-24 21:00:02'),(89,89,17,1,0,NULL,'2026-02-25 10:16:49'),(90,90,17,1,0,NULL,'2026-02-25 10:16:54'),(91,91,12,1,0,NULL,'2026-02-25 10:16:54'),(92,92,17,1,0,NULL,'2026-02-25 10:31:19'),(93,93,1,2,1,'2026-02-26 16:57:33','2026-02-25 15:45:46'),(94,94,17,1,0,NULL,'2026-02-25 15:45:46'),(95,95,17,1,0,NULL,'2026-02-25 17:39:26'),(96,96,18,1,0,NULL,'2026-02-25 17:49:38'),(97,97,17,1,0,NULL,'2026-02-25 17:51:35'),(98,98,12,1,0,NULL,'2026-02-25 18:12:08'),(99,99,17,1,0,NULL,'2026-02-25 18:12:08'),(100,100,1,2,1,'2026-02-26 16:57:33','2026-02-25 21:17:35'),(101,101,17,1,0,NULL,'2026-02-25 22:57:56'),(102,102,12,1,0,NULL,'2026-02-25 22:57:56'),(103,103,17,1,0,NULL,'2026-02-25 22:57:59'),(104,104,1,2,1,'2026-02-26 16:57:33','2026-02-25 22:57:59'),(105,105,1,2,1,'2026-02-26 16:55:00','2026-02-25 22:58:10'),(106,106,1,1,0,NULL,'2026-02-25 22:58:10'),(107,107,1,2,0,NULL,'2026-02-26 23:30:31'),(108,108,1,2,0,NULL,'2026-02-26 23:30:33');
/*!40000 ALTER TABLE `user_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wallet_password`
--

DROP TABLE IF EXISTS `wallet_password`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wallet_password` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `wallet_id` bigint unsigned NOT NULL COMMENT '钱包ID',
  `user_id` bigint unsigned NOT NULL COMMENT '用户ID',
  `user_type` tinyint NOT NULL COMMENT '用户类型：1=C端，2=B端，3=Admin端',
  `password_hash` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '支付密码（前端MD5 32位）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_wallet_id` (`wallet_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_user_type` (`user_type`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付密码表-钱包支付密码管理';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallet_password`
--

LOCK TABLES `wallet_password` WRITE;
/*!40000 ALTER TABLE `wallet_password` DISABLE KEYS */;
INSERT INTO `wallet_password` VALUES (1,1,1,2,'123456','2026-02-16 11:34:30','2026-02-16 11:34:30'),(2,2,1,1,'123456','2026-02-16 12:08:40','2026-02-16 12:08:40');
/*!40000 ALTER TABLE `wallet_password` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wallets`
--

DROP TABLE IF EXISTS `wallets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wallets` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '钱包ID',
  `balance` bigint NOT NULL DEFAULT '0' COMMENT '余额（单位：分，100=1元）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_balance` (`balance`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='钱包表-三端共用';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallets`
--

LOCK TABLES `wallets` WRITE;
/*!40000 ALTER TABLE `wallets` DISABLE KEYS */;
INSERT INTO `wallets` VALUES (1,74300,'2026-02-16 11:27:54','2026-02-26 23:30:33'),(2,216,'2026-02-16 12:05:32','2026-02-21 22:42:44'),(3,314,'2026-02-16 12:05:51','2026-02-21 20:40:37'),(13,2790,'2026-02-23 21:10:12','2026-02-25 15:15:51'),(14,890,'2026-02-23 21:11:29','2026-02-24 16:17:13'),(15,1190,'2026-02-23 21:11:37','2026-02-24 16:21:37'),(16,600,'2026-02-23 21:11:48','2026-02-23 23:09:08'),(17,580,'2026-02-23 21:13:13','2026-02-24 12:03:08'),(18,5450,'2026-02-23 22:30:54','2026-02-25 22:57:59'),(19,7390,'2026-02-23 22:31:05','2026-02-24 21:00:02'),(20,300,'2026-02-23 22:31:12','2026-02-24 15:50:37'),(21,0,'2026-02-23 22:31:17','2026-02-24 15:53:12'),(22,300,'2026-02-23 22:31:22','2026-02-24 15:54:00'),(23,200,'2026-02-23 22:31:28','2026-02-24 15:54:19'),(24,200,'2026-02-23 22:31:35','2026-02-24 15:56:06'),(25,50,'2026-02-24 15:11:14','2026-02-24 15:21:36'),(26,80,'2026-02-24 15:11:25','2026-02-24 15:15:39'),(27,80,'2026-02-24 15:11:31','2026-02-24 15:15:46'),(28,280,'2026-02-24 15:11:37','2026-02-24 15:21:36');
/*!40000 ALTER TABLE `wallets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wallets_log`
--

DROP TABLE IF EXISTS `wallets_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wallets_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '流水ID',
  `wallet_id` bigint unsigned NOT NULL COMMENT '钱包ID',
  `user_id` bigint unsigned NOT NULL COMMENT '用户ID',
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（冗余字段）',
  `user_type` tinyint NOT NULL COMMENT '用户类型：1=C端，2=B端，3=Admin端',
  `type` tinyint NOT NULL COMMENT '流水类型：1=收入，2=支出',
  `amount` bigint NOT NULL DEFAULT '0' COMMENT '变动金额（单位：分，正数）',
  `before_balance` bigint NOT NULL DEFAULT '0' COMMENT '变动前余额（单位：分）',
  `after_balance` bigint NOT NULL DEFAULT '0' COMMENT '变动后余额（单位：分）',
  `related_type` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '关联类型：task=任务，recharge=充值，withdraw=提现，refund=退款',
  `related_id` bigint unsigned DEFAULT NULL COMMENT '关联ID（任务ID、订单ID等）',
  `remark` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '备注说明（扣费或收入原因）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_wallet_id` (`wallet_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_user_type` (`user_type`),
  KEY `idx_type` (`type`),
  KEY `idx_related` (`related_type`,`related_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=254 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='钱包流水表-记录所有收支';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallets_log`
--

LOCK TABLES `wallets_log` WRITE;
/*!40000 ALTER TABLE `wallets_log` DISABLE KEYS */;
INSERT INTO `wallets_log` VALUES (1,1,1,'bceshi',2,1,0,0,0,'recharge',1,'充值 ¥1,000.00（alipay），审核中','2026-02-16 11:44:32'),(2,1,1,'bceshi',2,1,100000,0,100000,'recharge',1,'充值到账：¥1,000.00','2026-02-16 11:45:59'),(3,1,1,'bceshi',2,2,400,100000,99600,'task',1,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-16 11:47:29'),(4,1,1,'bceshi',2,2,600,99600,99000,'task',2,'发布任务【中评评论】3个任务，扣除 ¥6.00','2026-02-16 11:49:11'),(5,1,1,'bceshi',2,2,500,99000,98500,'task',3,'发布任务【放大镜搜索词】1个任务，扣除 ¥5.00','2026-02-16 11:50:02'),(6,1,1,'bceshi',2,2,1000,98500,97500,'task',4,'发布任务【上中评评论】4个任务，扣除 ¥10.00','2026-02-16 11:56:08'),(7,1,1,'bceshi',2,2,1000,97500,96500,'task',6,'发布任务【中下评评论】3个任务，扣除 ¥10.00','2026-02-16 11:56:39'),(8,1,1,'bceshi',2,2,100,96500,96400,'rental_freeze',1,'求租信息冻结预算（100分/天×1天）：测试发布求租信息','2026-02-16 12:56:47'),(9,1,1,'bceshi',2,2,100,96400,96300,'rental_freeze',2,'求租信息冻结预算（100分/天×1天）：测试发布求租信息2','2026-02-16 13:04:57'),(10,1,1,'bceshi',2,1,100,96300,96400,'rental_unfreeze',1,'求租信息手动下架退回预算（100分/天×1天）：测试发布求租信息','2026-02-16 13:06:00'),(11,1,1,'bceshi',2,2,100,96400,96300,'rental_freeze',1,'求租信息重新上架冻结预算（100分/天×1天）：测试发布求租信息','2026-02-16 13:06:12'),(12,1,1,'bceshi',2,2,1900,96300,94400,'rental_freeze',1,'求租信息修改增加预算（200分/天×10天）：测试更新求租信息的功能（+1900）','2026-02-16 13:08:10'),(13,1,1,'bceshi',2,2,1000,94400,93400,'rental_freeze',1,'求租信息修改增加预算（300分/天×10天）：测试更新求租信息的功能（+1000）','2026-02-16 13:11:55'),(14,2,1,'cceshi1',2,2,0,0,0,'rental_order_pay',1,'求租订单已创建：测试更新求租信息的功能（冻结金额转入订单：300）','2026-02-16 13:22:26'),(15,2,1,'cceshi1',1,2,0,0,0,'rental_order_pending',1,'租赁订单已创建，待客服处理：测试更新求租信息的功能（预计收益：225）','2026-02-16 13:22:26'),(16,1,1,'bceshi',2,2,100,93400,93300,'rental_order_pay',2,'租赁订单支付：抖音账号出租（1天）','2026-02-16 23:47:20'),(17,2,1,'cceshi1',1,2,0,0,0,'rental_order_pending',2,'租赁订单已创建，待客服处理：抖音账号出租（1天，预计收益：75）','2026-02-16 23:47:20'),(18,3,2,'cceshi2',1,1,114,0,114,'commission',2,'完成任务获得佣金，任务ID：2','2026-02-16 23:55:47'),(19,2,1,'cceshi1',1,1,16,0,16,'agent_commission',2,'下级用户 cceshi2 完成任务，获得团长佣金，任务ID：2','2026-02-16 23:55:47'),(20,1,1,'bceshi',2,2,100,93300,93200,'rental_order_renew',2,'订单续租 1 天','2026-02-16 23:59:15'),(21,2,1,'cceshi1',1,1,0,0,0,'rental_order_renew',2,'订单续租收入 1 天（待结算：¥0.75）','2026-02-16 23:59:15'),(22,2,1,'cceshi1',1,1,150,16,166,'rental_order_settlement',2,'租赁订单结算收益（订单#2）','2026-02-19 00:00:03'),(35,1,1,'bceshi',2,2,800,93200,92400,'task',8,'发布任务【上评评论】2个任务，扣除 ¥8.00','2026-02-21 20:39:01'),(36,3,2,'cceshi2',1,1,200,114,314,'commission',8,'完成任务获得佣金，任务ID：8','2026-02-21 20:40:37'),(37,2,1,'cceshi1',1,1,50,166,216,'agent_commission',8,'下级用户 cceshi2 完成任务，获得团长佣金，任务ID：8','2026-02-21 20:40:37'),(38,1,1,'bceshi',2,2,400,92400,92000,'task',9,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-21 21:21:32'),(65,1,1,'bceshi',2,2,400,92000,91600,'task',16,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 21:18:37'),(66,1,1,'bceshi',2,2,400,91600,91200,'task',17,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 21:18:42'),(67,1,1,'bceshi',2,2,400,91200,90800,'task',18,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 21:18:48'),(68,1,1,'bceshi',2,2,400,90800,90400,'task',19,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 21:18:53'),(69,1,1,'bceshi',2,2,400,90400,90000,'task',20,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 21:19:01'),(70,1,1,'bceshi',2,2,400,90000,89600,'task',21,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 21:19:05'),(71,1,1,'bceshi',2,2,400,89600,89200,'task',22,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 21:19:09'),(72,1,1,'bceshi',2,2,400,89200,88800,'task',23,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 21:19:13'),(73,1,1,'bceshi',2,2,400,88800,88400,'task',24,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 21:19:17'),(74,1,1,'bceshi',2,2,400,88400,88000,'task',25,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 21:19:22'),(75,1,1,'bceshi',2,2,400,88000,87600,'task',26,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 21:19:39'),(76,1,1,'bceshi',2,2,400,87600,87200,'task',27,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 21:42:08'),(77,1,1,'bceshi',2,2,400,87200,86800,'task',28,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 21:42:14'),(78,14,13,'test1',1,1,200,0,200,'commission',16,'完成任务获得佣金，任务ID：16','2026-02-23 21:44:16'),(79,14,13,'test1',1,1,200,200,400,'commission',17,'完成任务获得佣金，任务ID：17','2026-02-23 21:44:33'),(80,14,13,'test1',1,1,200,400,600,'commission',18,'完成任务获得佣金，任务ID：18','2026-02-23 21:44:38'),(81,15,14,'test2',1,1,200,0,200,'commission',19,'完成任务获得佣金，任务ID：19','2026-02-23 21:44:48'),(82,15,14,'test2',1,1,200,200,400,'commission',20,'完成任务获得佣金，任务ID：20','2026-02-23 21:44:56'),(83,15,14,'test2',1,1,200,400,600,'commission',21,'完成任务获得佣金，任务ID：21','2026-02-23 21:45:03'),(84,17,16,'test4',1,1,200,0,200,'commission',22,'完成任务获得佣金，任务ID：22','2026-02-23 21:45:09'),(85,17,16,'test4',1,1,200,200,400,'commission',23,'完成任务获得佣金，任务ID：23','2026-02-23 21:45:14'),(86,17,16,'test4',1,1,200,400,600,'commission',24,'完成任务获得佣金，任务ID：24','2026-02-23 21:45:19'),(87,17,16,'test4',1,1,200,600,800,'commission',25,'完成任务获得佣金，任务ID：25','2026-02-23 21:45:25'),(88,14,13,'test1',1,1,200,600,800,'commission',26,'完成任务获得佣金，任务ID：26','2026-02-23 21:46:15'),(89,16,15,'test3',1,1,200,0,200,'commission',28,'完成任务获得佣金，任务ID：28','2026-02-23 21:46:26'),(90,1,1,'bceshi',2,2,400,86800,86400,'task',29,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 21:56:05'),(91,1,1,'bceshi',2,2,400,86400,86000,'task',30,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 21:56:15'),(92,1,1,'bceshi',2,2,400,86000,85600,'task',31,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 21:56:18'),(93,1,1,'bceshi',2,2,400,85600,85200,'task',32,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 21:56:22'),(94,14,13,'test1',1,1,200,800,1000,'commission',27,'完成任务获得佣金，任务ID：27','2026-02-23 22:02:44'),(95,13,12,'test',1,1,50,0,50,'agent_commission',27,'下级用户 test1 完成任务，获得团长佣金，任务ID：27','2026-02-23 22:02:44'),(96,14,13,'test1',1,1,200,1000,1200,'commission',29,'完成任务获得佣金，任务ID：29','2026-02-23 22:03:06'),(97,13,12,'test',1,1,50,50,100,'agent_commission',29,'下级用户 test1 完成任务，获得团长佣金，任务ID：29','2026-02-23 22:03:06'),(98,15,14,'test2',1,1,200,600,800,'commission',32,'完成任务获得佣金，任务ID：32','2026-02-23 22:10:31'),(99,13,12,'test',1,1,50,100,150,'agent_commission',32,'下级用户 test2 完成任务，获得团长佣金，任务ID：32','2026-02-23 22:10:31'),(100,16,15,'test3',1,1,200,200,400,'commission',31,'完成任务获得佣金，任务ID：31','2026-02-23 22:10:36'),(101,13,12,'test',1,1,50,150,200,'agent_commission',31,'下级用户 test3 完成任务，获得团长佣金，任务ID：31','2026-02-23 22:10:36'),(102,17,16,'test4',1,1,200,800,1000,'commission',30,'完成任务获得佣金，任务ID：30','2026-02-23 22:10:43'),(103,13,12,'test',1,1,50,200,250,'agent_commission',30,'下级用户 test4 完成任务，获得团长佣金，任务ID：30','2026-02-23 22:10:43'),(104,1,1,'bceshi',2,2,600,85200,84600,'task',33,'发布任务【中评评论】3个任务，扣除 ¥6.00','2026-02-23 22:16:06'),(105,14,13,'test1',1,1,80,1200,1280,'commission',33,'完成任务获得佣金，任务ID：33','2026-02-23 22:19:02'),(106,13,12,'test',1,1,30,250,280,'agent_commission',33,'下级用户 test1 完成任务，获得团长佣金，任务ID：33','2026-02-23 22:19:02'),(107,15,14,'test2',1,1,80,800,880,'commission',33,'完成任务获得佣金，任务ID：33','2026-02-23 22:19:09'),(108,13,12,'test',1,1,30,280,310,'agent_commission',33,'下级用户 test2 完成任务，获得团长佣金，任务ID：33','2026-02-23 22:19:09'),(109,17,16,'test4',1,1,80,1000,1080,'commission',33,'完成任务获得佣金，任务ID：33','2026-02-23 22:19:18'),(110,13,12,'test',1,1,30,310,340,'agent_commission',33,'下级用户 test4 完成任务，获得团长佣金，任务ID：33','2026-02-23 22:19:18'),(111,1,1,'bceshi',2,2,400,84600,84200,'task',34,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 22:36:25'),(112,1,1,'bceshi',2,2,400,84200,83800,'task',35,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 22:36:35'),(113,1,1,'bceshi',2,2,400,83800,83400,'task',36,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 22:36:41'),(114,1,1,'bceshi',2,2,400,83400,83000,'task',37,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 22:36:47'),(115,1,1,'bceshi',2,2,400,83000,82600,'task',38,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 22:36:52'),(116,1,1,'bceshi',2,2,400,82600,82200,'task',39,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 22:36:57'),(117,1,1,'bceshi',2,2,400,82200,81800,'task',40,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 22:37:01'),(118,1,1,'bceshi',2,2,400,81800,81400,'task',41,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 22:37:05'),(119,1,1,'bceshi',2,2,400,81400,81000,'task',42,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 22:37:10'),(120,1,1,'bceshi',2,2,400,81000,80600,'task',43,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 22:37:14'),(121,1,1,'bceshi',2,2,400,80600,80200,'task',44,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 22:37:19'),(122,1,1,'bceshi',2,2,400,80200,79800,'task',45,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 22:37:24'),(123,1,1,'bceshi',2,2,400,79800,79400,'task',46,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 22:37:30'),(124,1,1,'bceshi',2,2,400,79400,79000,'task',47,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-23 22:37:35'),(125,19,18,'advanced1',1,1,200,0,200,'commission',34,'完成任务获得佣金，任务ID：34','2026-02-23 22:43:48'),(126,19,18,'advanced1',1,1,200,200,400,'commission',35,'完成任务获得佣金，任务ID：35','2026-02-23 22:43:58'),(127,20,19,'advanced2',1,1,200,0,200,'commission',36,'完成任务获得佣金，任务ID：36','2026-02-23 22:44:03'),(128,20,19,'advanced2',1,1,200,200,400,'commission',37,'完成任务获得佣金，任务ID：37','2026-02-23 22:44:09'),(129,21,20,'advanced3',1,1,200,0,200,'commission',38,'完成任务获得佣金，任务ID：38','2026-02-23 22:44:16'),(130,21,20,'advanced3',1,1,200,200,400,'commission',39,'完成任务获得佣金，任务ID：39','2026-02-23 22:44:23'),(131,22,21,'advanced4',1,1,200,0,200,'commission',40,'完成任务获得佣金，任务ID：40','2026-02-23 22:44:32'),(132,22,21,'advanced4',1,1,200,200,400,'commission',41,'完成任务获得佣金，任务ID：41','2026-02-23 22:44:38'),(133,23,22,'advanced5',1,1,200,0,200,'commission',42,'完成任务获得佣金，任务ID：42','2026-02-23 22:44:46'),(134,23,22,'advanced5',1,1,200,200,400,'commission',43,'完成任务获得佣金，任务ID：43','2026-02-23 22:44:53'),(135,24,23,'advanced6',1,1,200,0,200,'commission',44,'完成任务获得佣金，任务ID：44','2026-02-23 22:45:18'),(136,18,17,'advanced',1,1,200,0,200,'commission',45,'完成任务获得佣金，任务ID：45','2026-02-23 22:46:41'),(137,13,12,'test',1,1,50,340,390,'agent_commission',45,'下级用户 advanced 完成任务，获得团长佣金，任务ID：45','2026-02-23 22:46:41'),(138,16,15,'test3',1,1,200,400,600,'commission',9,'完成任务获得佣金，任务ID：9','2026-02-23 23:09:08'),(139,13,12,'test',1,1,50,390,440,'agent_commission',9,'下级用户 test3 完成任务，获得团长佣金，任务ID：9','2026-02-23 23:09:08'),(140,14,13,'test1',1,2,1000,1280,280,'withdraw',6,'提现申请 ¥10.00，手续费 ¥0.30，实到 ¥9.70，收款方式：alipay，审核中','2026-02-24 11:56:18'),(141,14,13,'test1',1,2,0,280,280,'withdraw',6,'提现审核通过：¥10.00','2026-02-24 11:59:15'),(142,13,12,'test',1,1,100,440,540,'agent_incentive',6,'团长激励奖励：下级用户test1首次提现，奖励¥1.00','2026-02-24 11:59:15'),(143,15,14,'test2',1,2,500,880,380,'withdraw',7,'提现申请 ¥5.00，手续费 ¥0.15，实到 ¥4.85，收款方式：alipay，审核中','2026-02-24 12:00:37'),(144,15,14,'test2',1,2,0,380,380,'withdraw',7,'提现审核通过：¥5.00','2026-02-24 12:00:47'),(145,17,16,'test4',1,2,500,1080,580,'withdraw',8,'提现申请 ¥5.00，手续费 ¥0.15，实到 ¥4.85，收款方式：alipay，审核中','2026-02-24 12:03:08'),(146,17,16,'test4',1,2,0,580,580,'withdraw',8,'提现审核通过：¥5.00','2026-02-24 12:03:22'),(147,13,12,'test',1,1,100,540,640,'agent_incentive',8,'团长激励奖励：下级用户test4首次提现，奖励¥1.00','2026-02-24 12:03:22'),(148,1,1,'bceshi',2,2,400,79000,78600,'task',48,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-24 14:35:18'),(149,1,1,'bceshi',2,2,400,78600,78200,'task',49,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-24 14:35:20'),(150,1,1,'bceshi',2,2,400,78200,77800,'task',50,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-24 14:35:22'),(151,19,18,'advanced1',1,1,200,400,600,'commission',46,'完成任务获得佣金，任务ID：46','2026-02-24 14:44:35'),(152,19,18,'advanced1',1,1,200,600,800,'commission',47,'完成任务获得佣金，任务ID：47','2026-02-24 14:49:17'),(153,18,17,'advanced',1,1,50,200,250,'agent_commission',47,'下级用户 advanced1 完成任务，获得团长佣金，任务ID：47','2026-02-24 14:49:17'),(154,19,18,'advanced1',1,1,200,800,1000,'commission',48,'完成任务获得佣金，任务ID：48','2026-02-24 14:51:10'),(155,18,17,'advanced',1,1,100,250,350,'agent_commission',48,'下级用户 advanced1 完成任务，获得团长佣金，任务ID：48','2026-02-24 14:51:10'),(156,24,23,'advanced6',1,1,200,200,400,'commission',49,'完成任务获得佣金，任务ID：49','2026-02-24 15:08:08'),(157,18,17,'advanced',1,1,100,350,450,'agent_commission',49,'下级用户 advanced6 完成任务，获得团长佣金，任务ID：49','2026-02-24 15:08:08'),(158,1,1,'bceshi',2,2,600,77800,77200,'task',51,'发布任务【中评评论】3个任务，扣除 ¥6.00','2026-02-24 15:13:10'),(159,26,25,'thirdly1',1,1,80,0,80,'commission',51,'完成任务获得佣金，任务ID：51','2026-02-24 15:15:39'),(160,27,26,'thirdly2',1,1,80,0,80,'commission',51,'完成任务获得佣金，任务ID：51','2026-02-24 15:15:46'),(161,28,27,'thirdly3',1,1,80,0,80,'commission',51,'完成任务获得佣金，任务ID：51','2026-02-24 15:15:51'),(162,28,27,'thirdly3',1,1,200,80,280,'commission',50,'完成任务获得佣金，任务ID：50','2026-02-24 15:21:36'),(163,25,24,'thirdly',1,1,50,0,50,'agent_commission',50,'下级用户 thirdly3 完成任务，获得团长佣金，任务ID：50','2026-02-24 15:21:36'),(164,19,18,'advanced1',1,2,100,1000,900,'withdraw',9,'提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中','2026-02-24 15:27:46'),(165,19,18,'advanced1',1,2,0,900,900,'withdraw',9,'提现审核通过：¥1.00','2026-02-24 15:28:16'),(166,18,17,'advanced',1,1,500,450,950,'agent_incentive',9,'团长激励奖励：下级用户advanced1首次提现，奖励¥5.00','2026-02-24 15:28:16'),(167,19,18,'advanced1',1,2,100,900,800,'withdraw',10,'提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中','2026-02-24 15:30:57'),(168,19,18,'advanced1',1,1,100,800,900,'withdraw',10,'提现申请被拒绝，退款：¥1.00','2026-02-24 15:31:43'),(169,1,1,'bceshi',2,2,10000,77200,67200,'rental_order_pay',6,'租赁订单支付：测试租赁系统的新功能，佣金结算（1天）','2026-02-24 15:41:11'),(170,18,17,'advanced',1,2,0,0,0,'rental_order_pending',6,'租赁订单已创建，待客服处理：测试租赁系统的新功能，佣金结算（1天，预计收益：6000）','2026-02-24 15:41:11'),(171,1,1,'bceshi',2,2,10000,67200,57200,'rental_order_pay',7,'租赁订单支付：测试租赁系统的新功能，佣金结算，我的团长是高级团长（1天）','2026-02-24 15:44:39'),(172,19,18,'advanced1',1,2,0,0,0,'rental_order_pending',7,'租赁订单已创建，待客服处理：测试租赁系统的新功能，佣金结算，我的团长是高级团长（1天，预计收益：6000）','2026-02-24 15:44:39'),(173,20,19,'advanced2',1,2,100,400,300,'withdraw',11,'提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中','2026-02-24 15:50:37'),(174,21,20,'advanced3',1,2,100,400,300,'withdraw',12,'提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中','2026-02-24 15:50:56'),(175,20,19,'advanced2',1,2,0,300,300,'withdraw',11,'提现审核通过：¥1.00','2026-02-24 15:51:12'),(176,18,17,'advanced',1,1,500,950,1450,'agent_incentive',11,'团长激励奖励：下级用户advanced2首次提现，奖励¥5.00','2026-02-24 15:51:12'),(177,21,20,'advanced3',1,2,0,300,300,'withdraw',12,'提现审核通过：¥1.00','2026-02-24 15:51:26'),(178,21,20,'advanced3',1,2,100,300,200,'withdraw',13,'提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中','2026-02-24 15:51:35'),(179,21,20,'advanced3',1,2,0,200,200,'withdraw',13,'提现审核通过：¥1.00','2026-02-24 15:51:51'),(180,21,20,'advanced3',1,2,100,200,100,'withdraw',14,'提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中','2026-02-24 15:52:49'),(181,21,20,'advanced3',1,2,0,100,100,'withdraw',14,'提现审核通过：¥1.00','2026-02-24 15:52:59'),(182,21,20,'advanced3',1,2,100,100,0,'withdraw',15,'提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中','2026-02-24 15:53:12'),(183,21,20,'advanced3',1,2,0,0,0,'withdraw',15,'提现审核通过：¥1.00','2026-02-24 15:53:27'),(184,22,21,'advanced4',1,2,100,400,300,'withdraw',16,'提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中','2026-02-24 15:54:00'),(185,23,22,'advanced5',1,2,100,400,300,'withdraw',17,'提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中','2026-02-24 15:54:16'),(186,23,22,'advanced5',1,2,100,300,200,'withdraw',18,'提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中','2026-02-24 15:54:19'),(187,24,23,'advanced6',1,2,100,400,300,'withdraw',19,'提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中','2026-02-24 15:54:35'),(188,22,21,'advanced4',1,2,0,300,300,'withdraw',16,'提现审核通过：¥1.00','2026-02-24 15:54:47'),(189,18,17,'advanced',1,1,500,1450,1950,'agent_incentive',16,'团长激励奖励：下级用户advanced4首次提现，奖励¥5.00','2026-02-24 15:54:47'),(190,23,22,'advanced5',1,2,0,200,200,'withdraw',17,'提现审核通过：¥1.00','2026-02-24 15:55:10'),(191,18,17,'advanced',1,1,500,1950,2450,'agent_incentive',17,'团长激励奖励：下级用户advanced5首次提现，奖励¥5.00','2026-02-24 15:55:10'),(192,23,22,'advanced5',1,2,0,200,200,'withdraw',18,'提现审核通过：¥1.00','2026-02-24 15:55:22'),(193,24,23,'advanced6',1,2,0,300,300,'withdraw',19,'提现审核通过：¥1.00','2026-02-24 15:55:34'),(194,18,17,'advanced',1,1,500,2450,2950,'agent_incentive',19,'团长激励奖励：下级用户advanced6首次提现，奖励¥5.00','2026-02-24 15:55:34'),(195,24,23,'advanced6',1,2,100,300,200,'withdraw',20,'提现申请 ¥1.00，手续费 ¥0.03，实到 ¥0.97，收款方式：alipay，审核中','2026-02-24 15:56:06'),(196,24,23,'advanced6',1,2,0,200,200,'withdraw',20,'提现审核通过：¥1.00','2026-02-24 16:00:15'),(197,1,1,'bceshi',2,2,600,57200,56600,'task',52,'发布任务【中评评论】3个任务，扣除 ¥6.00','2026-02-24 16:02:55'),(198,1,1,'bceshi',2,2,400,56600,56200,'task',53,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-24 16:03:26'),(199,1,1,'bceshi',2,2,1000,56200,55200,'task',54,'发布任务【上中评评论】4个任务，扣除 ¥10.00','2026-02-24 16:07:48'),(200,1,1,'bceshi',2,2,700,55200,54500,'task',56,'发布任务【中下评评论】2个任务，扣除 ¥7.00','2026-02-24 16:10:17'),(201,1,1,'bceshi',2,2,400,54500,54100,'task',58,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-24 16:11:06'),(202,14,13,'test1',1,1,80,280,360,'commission',52,'完成任务获得佣金，任务ID：52','2026-02-24 16:13:17'),(203,13,12,'test',1,1,30,640,670,'agent_commission',52,'下级用户 test1 完成任务，获得团长佣金，任务ID：52','2026-02-24 16:13:17'),(204,14,13,'test1',1,1,200,360,560,'commission',53,'完成任务获得佣金，任务ID：53','2026-02-24 16:13:24'),(205,13,12,'test',1,1,50,670,720,'agent_commission',53,'下级用户 test1 完成任务，获得团长佣金，任务ID：53','2026-02-24 16:13:24'),(206,14,13,'test1',1,1,200,560,760,'commission',54,'完成任务获得佣金，任务ID：54','2026-02-24 16:15:54'),(207,13,12,'test',1,1,50,720,770,'agent_commission',54,'下级用户 test1 完成任务，获得团长佣金，任务ID：54','2026-02-24 16:15:54'),(208,14,13,'test1',1,1,130,760,890,'commission',56,'完成任务获得佣金，任务ID：56','2026-02-24 16:17:13'),(209,13,12,'test',1,1,45,770,815,'agent_commission',56,'下级用户 test1 完成任务，获得团长佣金，任务ID：56','2026-02-24 16:17:13'),(210,15,14,'test2',1,1,200,380,580,'commission',1,'完成任务获得佣金，任务ID：1','2026-02-24 16:20:58'),(211,13,12,'test',1,1,50,815,865,'agent_commission',1,'下级用户 test2 完成任务，获得团长佣金，任务ID：1','2026-02-24 16:20:58'),(212,15,14,'test2',1,1,80,580,660,'commission',2,'完成任务获得佣金，任务ID：2','2026-02-24 16:21:03'),(213,13,12,'test',1,1,30,865,895,'agent_commission',2,'下级用户 test2 完成任务，获得团长佣金，任务ID：2','2026-02-24 16:21:03'),(214,15,14,'test2',1,1,200,660,860,'commission',4,'完成任务获得佣金，任务ID：4','2026-02-24 16:21:15'),(215,13,12,'test',1,1,50,895,945,'agent_commission',4,'下级用户 test2 完成任务，获得团长佣金，任务ID：4','2026-02-24 16:21:15'),(216,15,14,'test2',1,1,130,860,990,'commission',6,'完成任务获得佣金，任务ID：6','2026-02-24 16:21:28'),(217,13,12,'test',1,1,45,945,990,'agent_commission',6,'下级用户 test2 完成任务，获得团长佣金，任务ID：6','2026-02-24 16:21:28'),(218,15,14,'test2',1,1,200,990,1190,'commission',8,'完成任务获得佣金，任务ID：8','2026-02-24 16:21:37'),(219,13,12,'test',1,1,50,990,1040,'agent_commission',8,'下级用户 test2 完成任务，获得团长佣金，任务ID：8','2026-02-24 16:21:37'),(220,19,18,'advanced1',1,1,200,900,1100,'commission',58,'完成任务获得佣金，任务ID：58','2026-02-24 16:26:38'),(221,18,17,'advanced',1,1,100,2950,3050,'agent_commission',58,'下级用户 advanced1 完成任务，获得团长佣金，任务ID：58','2026-02-24 16:26:38'),(222,19,18,'advanced1',1,1,130,1100,1230,'commission',57,'完成任务获得佣金，任务ID：57','2026-02-24 16:27:29'),(223,18,17,'advanced',1,1,100,3050,3150,'agent_commission',57,'下级用户 advanced1 完成任务，获得团长佣金，任务ID：57','2026-02-24 16:27:29'),(224,19,18,'advanced1',1,1,80,1230,1310,'commission',55,'完成任务获得佣金，任务ID：55','2026-02-24 16:28:17'),(225,18,17,'advanced',1,1,50,3150,3200,'agent_commission',55,'下级用户 advanced1 完成任务，获得团长佣金，任务ID：55','2026-02-24 16:28:17'),(226,19,18,'advanced1',1,1,80,1310,1390,'commission',52,'完成任务获得佣金，任务ID：52','2026-02-24 16:28:47'),(227,18,17,'advanced',1,1,50,3200,3250,'agent_commission',52,'下级用户 advanced1 完成任务，获得团长佣金，任务ID：52','2026-02-24 16:28:47'),(228,18,17,'advanced',1,1,6000,3250,9250,'rental_order_settlement',6,'租赁订单结算收益（订单#6）','2026-02-24 21:00:02'),(229,13,12,'test',1,1,1000,1040,2040,'rental_agent_commission',6,'租赁订单团长佣金（订单#6）','2026-02-24 21:00:02'),(230,19,18,'advanced1',1,1,6000,1390,7390,'rental_order_settlement',7,'租赁订单结算收益（订单#7）','2026-02-24 21:00:02'),(231,18,17,'advanced',1,1,2000,9250,11250,'rental_agent_commission',7,'租赁订单团长佣金（订单#7）','2026-02-24 21:00:02'),(232,18,17,'advanced',1,2,1000,11250,10250,'withdraw',21,'提现申请 ¥10.00，手续费 ¥0.30，实到 ¥9.70，收款方式：alipay，审核中','2026-02-25 09:49:14'),(233,18,17,'advanced',1,2,1000,10250,9250,'withdraw',22,'提现申请 ¥10.00，手续费 ¥0.30，实到 ¥9.70，收款方式：alipay，审核中','2026-02-25 10:06:08'),(234,18,17,'advanced',1,2,1000,9250,8250,'withdraw',23,'提现申请 ¥10.00，手续费 ¥0.30，实到 ¥9.70，收款方式：alipay，审核中','2026-02-25 10:14:52'),(235,18,17,'advanced',1,1,1000,8250,9250,'withdraw',23,'提现申请被拒绝，退款：¥10.00','2026-02-25 10:16:49'),(236,18,17,'advanced',1,2,0,9250,9250,'withdraw',22,'提现审核通过：¥10.00','2026-02-25 10:16:54'),(237,13,12,'test',1,1,500,2040,2540,'agent_incentive',22,'团长激励奖励：下级用户advanced首次提现，奖励¥5.00','2026-02-25 10:16:54'),(238,18,17,'advanced',1,2,0,9250,9250,'withdraw',21,'提现审核通过：¥10.00','2026-02-25 10:31:18'),(239,1,1,'bceshi',2,2,400,54100,53700,'task',59,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-25 15:02:11'),(240,18,17,'advanced',1,1,200,9250,9450,'commission',59,'完成任务获得佣金，任务ID：59','2026-02-25 15:11:34'),(241,13,12,'test',1,1,50,2540,2590,'agent_commission',59,'下级用户 advanced 完成任务，获得团长佣金，任务ID：59','2026-02-25 15:11:34'),(242,1,1,'bceshi',2,2,400,53700,53300,'task',60,'发布任务【上评评论】1个任务，扣除 ¥4.00','2026-02-25 15:11:45'),(243,13,12,'test',1,1,200,2590,2790,'commission',60,'完成任务获得佣金，任务ID：60','2026-02-25 15:15:51'),(244,18,17,'advanced',1,2,10,9450,9440,'rental_order_pay',8,'租赁订单支付：测试租赁系统的新功能，佣金结算（1天）','2026-02-25 15:45:46'),(245,1,1,'bceshi',2,2,0,0,0,'rental_order_pending',8,'租赁订单已创建，待客服处理：测试租赁系统的新功能，佣金结算（1天，预计收益：6）','2026-02-25 15:45:46'),(246,18,17,'advanced',1,2,4000,9440,5440,'rental_freeze',3,'求租信息冻结预算（2000分/天×2天）：测试租赁系统的新功能，佣金结算','2026-02-25 17:03:49'),(247,18,17,'advanced',1,2,0,0,0,'rental_order_pay',9,'求租订单已创建：测试租赁系统的新功能，佣金结算（冻结金额转入订单：2000）','2026-02-25 18:12:08'),(248,13,12,'test',1,2,0,0,0,'rental_order_pending',9,'租赁订单已创建，待客服处理：测试租赁系统的新功能，佣金结算（预计收益：1200）','2026-02-25 18:12:08'),(249,18,17,'advanced',1,1,10,5440,5450,'rental_order_refund',8,'订单取消退款','2026-02-25 22:57:59'),(250,1,1,'bceshi',2,1,0,53300,53300,'recharge',2,'充值 ¥200.00（alipay），审核中','2026-02-26 23:17:58'),(251,1,1,'bceshi',2,1,0,53300,53300,'recharge',3,'充值 ¥10.00（alipay），审核中','2026-02-26 23:26:09'),(252,1,1,'bceshi',2,1,1000,53300,54300,'recharge',3,'充值到账：¥10.00','2026-02-26 23:30:31'),(253,1,1,'bceshi',2,1,20000,54300,74300,'recharge',2,'充值到账：¥200.00','2026-02-26 23:30:33');
/*!40000 ALTER TABLE `wallets_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `withdraw_requests`
--

DROP TABLE IF EXISTS `withdraw_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `withdraw_requests` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '提现申请ID',
  `user_id` bigint unsigned NOT NULL COMMENT '用户ID',
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（冗余字段）',
  `user_type` tinyint NOT NULL COMMENT '用户类型：1=C端，2=B端',
  `wallet_id` bigint unsigned NOT NULL COMMENT '钱包ID',
  `amount` bigint NOT NULL DEFAULT '0' COMMENT '提现金额（单位：分）',
  `fee_rate` decimal(5,4) NOT NULL DEFAULT '0.0300' COMMENT '手续费比例（如0.03=3%）',
  `fee_amount` bigint NOT NULL DEFAULT '0' COMMENT '手续费金额（单位：分）',
  `actual_amount` bigint NOT NULL DEFAULT '0' COMMENT '实际到账金额（单位：分）',
  `withdraw_method` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收款方式：alipay=支付宝，wechat=微信，bank=银行卡，usdt=USDT',
  `withdraw_account` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收款账号/信息',
  `account_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '收款人姓名',
  `log_id` bigint unsigned DEFAULT NULL COMMENT '关联的钱包流水ID',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '审核状态：0=待审核，1=审核通过，2=审核拒绝',
  `reject_reason` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '拒绝原因',
  `img_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '审核凭证图片URL（管理员审核通过后上传）',
  `admin_id` bigint unsigned DEFAULT NULL COMMENT '审核管理员ID',
  `reviewed_at` datetime DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_user_type` (`user_type`),
  KEY `idx_wallet_id` (`wallet_id`),
  KEY `idx_log_id` (`log_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='提现申请表-需要管理员审核';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `withdraw_requests`
--

LOCK TABLES `withdraw_requests` WRITE;
/*!40000 ALTER TABLE `withdraw_requests` DISABLE KEYS */;
INSERT INTO `withdraw_requests` VALUES (6,13,'test1',1,14,1000,0.0300,30,970,'alipay','15900000001','张三',140,1,NULL,'http://54.179.253.64:28806/img/b192dae5f117c1d3f4be977ebe330dfd.jpg',NULL,'2026-02-24 11:59:15','2026-02-24 11:56:18'),(7,14,'test2',1,15,500,0.0300,15,485,'alipay','15900000001','张三',143,1,NULL,'http://54.179.253.64:28806/img/71587e86f5139f9b2c3f66b2a3f4e10b.jpg',NULL,'2026-02-24 12:00:47','2026-02-24 12:00:37'),(8,16,'test4',1,17,500,0.0300,15,485,'alipay','15900000001','张三',145,1,NULL,'http://54.179.253.64:28806/img/4d4a21a2b6936e8495f31abe2f5d72cc.jpg',NULL,'2026-02-24 12:03:22','2026-02-24 12:03:08'),(9,18,'advanced1',1,19,100,0.0300,3,97,'alipay','15900000001','张三',164,1,NULL,'http://54.179.253.64:28806/img/fe4e8f0819e9e35da2e4d634f7ca9337.jpg',NULL,'2026-02-24 15:28:16','2026-02-24 15:27:46'),(10,18,'advanced1',1,19,100,0.0300,3,97,'alipay','15900000001','张三',167,2,'收款账号和姓名错误',NULL,NULL,'2026-02-24 15:31:43','2026-02-24 15:30:57'),(11,19,'advanced2',1,20,100,0.0300,3,97,'alipay','15900000001','张三',173,1,NULL,'http://54.179.253.64:28806/img/8023ce1b59485781c856d4b552d90cb0.jpg',NULL,'2026-02-24 15:51:12','2026-02-24 15:50:37'),(12,20,'advanced3',1,21,100,0.0300,3,97,'alipay','15900000001','张三',174,1,NULL,'http://54.179.253.64:28806/img/1b342e36cbc01a509daf365012bacb8e.jpg',NULL,'2026-02-24 15:51:26','2026-02-24 15:50:56'),(13,20,'advanced3',1,21,100,0.0300,3,97,'alipay','15900000001','张三',178,1,NULL,'http://54.179.253.64:28806/img/1c1a27ed70a582fe9149e35f1e8b9322.jpg',NULL,'2026-02-24 15:51:51','2026-02-24 15:51:35'),(14,20,'advanced3',1,21,100,0.0300,3,97,'alipay','15900000001','张三',180,1,NULL,'http://54.179.253.64:28806/img/cf76b3c18ab9dc84e78de1e65b8d6b3a.jpg',NULL,'2026-02-24 15:52:59','2026-02-24 15:52:49'),(15,20,'advanced3',1,21,100,0.0300,3,97,'alipay','15900000001','张三',182,1,NULL,'http://54.179.253.64:28806/img/04b6fb432c5a3b606424ce31b76b2fa5.jpg',NULL,'2026-02-24 15:53:27','2026-02-24 15:53:12'),(16,21,'advanced4',1,22,100,0.0300,3,97,'alipay','15900000001','张三',184,1,NULL,'http://54.179.253.64:28806/img/3b93b29618003b12cb8c1a07c8a61f3a.jpg',NULL,'2026-02-24 15:54:47','2026-02-24 15:54:00'),(17,22,'advanced5',1,23,100,0.0300,3,97,'alipay','15900000001','张三',185,1,NULL,'http://54.179.253.64:28806/img/c4ce2ee6892fa152cf3eb3520b9bafab.jpg',NULL,'2026-02-24 15:55:10','2026-02-24 15:54:16'),(18,22,'advanced5',1,23,100,0.0300,3,97,'alipay','15900000001','张三',186,1,NULL,'http://54.179.253.64:28806/img/3804c487135b1223d9af81aa0e8f530e.jpg',NULL,'2026-02-24 15:55:22','2026-02-24 15:54:19'),(19,23,'advanced6',1,24,100,0.0300,3,97,'alipay','15900000001','张三',187,1,NULL,'http://54.179.253.64:28806/img/e779fbb70b1e12cb37e4142364157a50.jpg',NULL,'2026-02-24 15:55:34','2026-02-24 15:54:35'),(20,23,'advanced6',1,24,100,0.0300,3,97,'alipay','15900000001','张三',195,1,NULL,'http://54.179.253.64:28806/img/daaa90068d46a76ead7dba0147dfb37f.jpg',NULL,'2026-02-24 16:00:15','2026-02-24 15:56:06'),(21,17,'advanced',1,18,1000,0.0300,30,970,'alipay','15900000001','张三',232,1,NULL,'http://54.179.253.64:28806/img/43c8d673b229b9aa57af6f7ff446e222.jpg',NULL,'2026-02-25 10:31:18','2026-02-25 09:49:14'),(22,17,'advanced',1,18,1000,0.0300,30,970,'alipay','15900000001','李四',233,1,NULL,'http://54.179.253.64:28806/img/f78792ab9a05d55f37ffbcf34a5b9332.jpg',NULL,'2026-02-25 10:16:54','2026-02-25 10:06:08'),(23,17,'advanced',1,18,1000,0.0300,30,970,'alipay','15900000001','李四',234,2,'账号信息错误',NULL,NULL,'2026-02-25 10:16:49','2026-02-25 10:14:52');
/*!40000 ALTER TABLE `withdraw_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'task_platform'
--

--
-- Dumping routines for database 'task_platform'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-02-27  4:00:04
