SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. 为c_users表添加新手相关字段
ALTER TABLE `c_users` ADD COLUMN `is_newbie` TINYINT NOT NULL DEFAULT 1 COMMENT '是否为新手：1=新手，0=转正' AFTER `is_agent`;
ALTER TABLE `c_users` ADD COLUMN `has_completed_newbie_guide` TINYINT NOT NULL DEFAULT 0 COMMENT '是否完成新手指引：1=已完成，0=未完成' AFTER `is_newbie`;

-- 3. 创建用户任务记录表
CREATE TABLE IF NOT EXISTS `c_c_user_task_records_static_static` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `task_id` INT UNSIGNED NOT NULL COMMENT '任务ID（可以是普通任务或新手任务）',
  `task_type` TINYINT NOT NULL COMMENT '任务类型：1=普通任务，2=新手任务，3=平台任务',
  `action` VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '操作类型：accept, submit, appeal, reject, complete',
  `status` TINYINT NOT NULL COMMENT '状态：1=进行中，2=已完成，3=争议中，4=已驳回，5=已弃单',
  `reward` DECIMAL(10,2) NOT NULL COMMENT '任务奖励快照',
  `completed_at` DATETIME NULL DEFAULT NULL COMMENT '完成时间',
  `appeal_at` DATETIME NULL DEFAULT NULL COMMENT '争议发起时间',
  `completed_task_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '已完成任务数量',
  `rejected_task_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '已驳回任务数量',
  `abandoned_task_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '已弃单任务数量',
  `appeal_task_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '争议任务数量',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_task_id`(`task_id` ASC) USING BTREE,
  INDEX `idx_task_type`(`task_type` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户任务记录表' ROW_FORMAT = DYNAMIC;

-- 4. 为现有用户设置默认值
UPDATE `c_users` SET `is_newbie` = 1, `has_completed_newbie_guide` = 0 WHERE `is_newbie` IS NULL;

SET FOREIGN_KEY_CHECKS = 1;