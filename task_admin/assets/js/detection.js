// 执行所有检测
async function performAllChecks() {
    const startTime = getTimestamp();
    const startDateTime = new Date().toISOString().slice(0, 19).replace('T', ' ');
    log('INFO', `开始执行所有检测，开始时间: ${startTime}，检测类型: 全面板检测`, 'DETECTION');
    
    // 获取计时器状态，确保检测过程中使用正确的计时器状态
    try {
        log('INFO', '开始获取计时器状态', 'TIMER');
        const timerData = await getTimerStatus();
        log('INFO', `获取计时器状态成功: ${JSON.stringify(timerData)}`, 'TIMER');
    } catch (error) {
        log('ERROR', '获取计时器状态失败: ' + error.message, 'TIMER');
    }
    
    // 重置提示音标志
    needPlaySound = false;
    let detectionStatus = 'SUCCESS';
    const detectionResults = {};
    const detectionItems = [];
    
    try {
        // 检测系统通知（使用detect.php接口，已包含所有检测逻辑）
        log('INFO', '开始检测系统通知', 'DETECTION');
        const notificationResult = await detectNotifications();
        detectionResults.notification = notificationResult;
        detectionItems.push({
            type: '系统通知',
            status: 'SUCCESS',
            data: notificationResult
        });
        log('INFO', `系统通知检测结果: 新增 ${notificationResult.notifications.length} 条，未读 ${notificationResult.unreadCount} 条`, 'DETECTION');
        log('INFO', `检测详情: ${JSON.stringify(notificationResult.detection_result)}`, 'DETECTION');
        
        // 所有检测完成后，检查是否需要播放提示音
        if (needPlaySound) {
            log('INFO', '检测完成，播放提示音', 'DETECTION');
            playNotificationSound();
        }
        
        const endTime = getTimestamp();
        log('INFO', `所有检测执行完成，结束时间: ${endTime}`, 'DETECTION');
        
        // 持久化检测结果日志
        const detectionLog = log('INFO', `检测结果: ${JSON.stringify(detectionResults)}, 状态: ${detectionStatus}, 检测项: ${detectionItems.length}`, 'DETECTION');
        await persistLogToFile(detectionLog);
    } catch (error) {
        detectionStatus = 'ERROR';
        log('ERROR', `检测过程中发生错误: ${error.message}`, 'DETECTION');
        
        // 持久化错误日志
        const errorLog = log('ERROR', `检测错误: ${error.message}`, 'DETECTION');
        await persistLogToFile(errorLog);
    } finally {
        // 重新启动倒计时
        log('INFO', '重新启动倒计时', 'DETECTION');
        startCountdown();
    }
}

// 更新红色角标
function updateBadge(panelType, count) {
    // 映射面板类型到导航栏的data-page属性
    const pageMap = {
        'recharge': 'recharge',
        'withdraw': 'withdraw',
        'agent': 'agent',
        'magnifier': 'magnifier',
        'rental-orders': 'rental-orders',
        'rental-tickets': 'rental-tickets'
    };
    
    const pageCode = pageMap[panelType];
    if (!pageCode) return;
    
    // 找到对应的导航链接
    const navLink = document.querySelector(`.nav-link[data-page="${pageCode}"]`);
    if (!navLink) return;
    
    // 查找现有的角标
    let badge = navLink.querySelector('.badge-notification');
    
    // 如果数量为0，移除角标
    if (count === 0) {
        if (badge) {
            badge.remove();
        }
        return;
    }
    
    // 如果角标不存在，创建新的
    if (!badge) {
        badge = document.createElement('span');
        badge.className = 'badge-notification';
        navLink.appendChild(badge);
    }
    
    // 更新角标数量
    badge.textContent = count;
}