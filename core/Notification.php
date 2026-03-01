<?php
/**
 * 系统通知类
 * 
 * 功能：
 * - 发送通知给指定用户/用户组
 * - 创建通知记录
 * - 自动分发到用户通知表
 */

class Notification
{
    // 目标类型常量
    const TARGET_ALL = 0;      // 全体用户
    const TARGET_C_ALL = 1;    // C端全体
    const TARGET_B_ALL = 2;    // B端全体
    const TARGET_USER = 3;     // 指定用户
    
    // 发送者类型
    const SENDER_SYSTEM = 1;   // 系统自动
    const SENDER_ADMIN = 3;    // Admin手动
    
    // 用户类型
    const USER_TYPE_C = 1;     // C端
    const USER_TYPE_B = 2;     // B端
    
    /**
     * 发送系统通知给指定用户
     * 
     * @param PDO $db
     * @param int $userId
     * @param int $userType
     * @param string $title
     * @param string $content
     * @param string|null $relatedType 关联类型（暂不存入数据库，仅作参数占位）
     * @param int|null $relatedId 关联ID（暂不存入数据库，仅作参数占位）
     * @return bool
     */
    public static function sendToUser($db, $userId, $userType, $title, $content, $relatedType = null, $relatedId = null)
    {
        return self::send(
            $db,
            $title,
            $content,
            self::TARGET_USER,
            $userId,
            $userType,
            self::SENDER_SYSTEM
        );
    }

    /**
     * 发送通知
     * 
     * @param PDO $db 数据库连接
     * @param string $title 通知标题
     * @param string $content 通知内容
     * @param int $targetType 目标类型（0=全体，1=C端全体，2=B端全体，3=指定用户）
     * @param int|null $targetUserId 目标用户ID（targetType=3时必填）
     * @param int|null $targetUserType 目标用户类型（targetType=3时必填，1=C端，2=B端）
     * @param int $senderType 发送者类型（1=系统，3=Admin）
     * @param int|null $senderId 发送者ID（预留）
     * @return bool 成功返回true，失败返回false
     */
    public static function send(
        $db, 
        $title, 
        $content, 
        $targetType = self::TARGET_ALL, 
        $targetUserId = null, 
        $targetUserType = null,
        $senderType = self::SENDER_SYSTEM,
        $senderId = null
    ) {
        try {
            $db->beginTransaction();
            
            // 1. 创建通知记录
            $stmt = $db->prepare("
                INSERT INTO notifications 
                (title, content, target_type, target_user_id, target_user_type, sender_type, sender_id)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([
                $title,
                $content,
                $targetType,
                $targetUserId,
                $targetUserType,
                $senderType,
                $senderId
            ]);
            $notificationId = $db->lastInsertId();
            
            // 2. 根据目标类型分发到用户通知表
            switch ((int)$targetType) {
                case self::TARGET_ALL:
                    // 全体用户：B端 + C端
                    self::distributeToAllUsers($db, $notificationId);
                    break;
                    
                case self::TARGET_C_ALL:
                    // C端全体
                    self::distributeToCUsers($db, $notificationId);
                    break;
                    
                case self::TARGET_B_ALL:
                    // B端全体
                    self::distributeToBUsers($db, $notificationId);
                    break;
                    
                case self::TARGET_USER:
                    // 指定用户
                    if (empty($targetUserId) || empty($targetUserType)) {
                        throw new Exception('指定用户时必须提供用户ID和类型');
                    }
                    self::distributeToUser($db, $notificationId, $targetUserId, $targetUserType);
                    break;
                    
                default:
                    throw new Exception('无效的目标类型');
            }
            
            $db->commit();
            return true;
            
        } catch (Exception $e) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }
            return false;
        }
    }
    
    /**
     * 分发给全体用户（B端 + C端）
     */
    private static function distributeToAllUsers($db, $notificationId)
    {
        // 插入所有B端用户
        $stmt = $db->prepare("
            INSERT INTO user_notifications (notification_id, user_id, user_type, is_read)
            SELECT ?, id, 2, 0 FROM b_users WHERE status = 1
        ");
        $stmt->execute([$notificationId]);
        
        // 插入所有C端用户
        $stmt = $db->prepare("
            INSERT INTO user_notifications (notification_id, user_id, user_type, is_read)
            SELECT ?, id, 1, 0 FROM c_users WHERE status = 1
        ");
        $stmt->execute([$notificationId]);
    }
    
    /**
     * 分发给C端全体用户
     */
    private static function distributeToCUsers($db, $notificationId)
    {
        $stmt = $db->prepare("
            INSERT INTO user_notifications (notification_id, user_id, user_type, is_read)
            SELECT ?, id, 1, 0 FROM c_users WHERE status = 1
        ");
        $stmt->execute([$notificationId]);
    }
    
    /**
     * 分发给B端全体用户
     */
    private static function distributeToBUsers($db, $notificationId)
    {
        $stmt = $db->prepare("
            INSERT INTO user_notifications (notification_id, user_id, user_type, is_read)
            SELECT ?, id, 2, 0 FROM b_users WHERE status = 1
        ");
        $stmt->execute([$notificationId]);
    }
    
    /**
     * 分发给指定用户
     */
    private static function distributeToUser($db, $notificationId, $userId, $userType)
    {
        $stmt = $db->prepare("
            INSERT INTO user_notifications (notification_id, user_id, user_type, is_read)
            VALUES (?, ?, ?, 0)
        ");
        $stmt->execute([$notificationId, $userId, $userType]);
    }
    
    /**
     * 标记已读
     * 
     * @param PDO $db 数据库连接
     * @param int $notificationId 通知ID
     * @param int $userId 用户ID
     * @param int $userType 用户类型
     * @return bool
     */
    public static function markAsRead($db, $notificationId, $userId, $userType)
    {
        try {
            $stmt = $db->prepare("
                UPDATE user_notifications 
                SET is_read = 1, read_at = NOW() 
                WHERE notification_id = ? AND user_id = ? AND user_type = ?
            ");
            return $stmt->execute([$notificationId, $userId, $userType]);
        } catch (Exception $e) {
            return false;
        }
    }
}
