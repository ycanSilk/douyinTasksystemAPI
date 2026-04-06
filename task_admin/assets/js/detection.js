

// 检测通知 - 保留函数供其他地方调用，但不自动执行
async function detectNotifications() {
    try {
        const apiUrl = `/task_admin/api/admin_notifications/detect.php`;
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const response = await fetch(apiUrl, {
            method: 'GET',
            headers: headers,
            credentials: 'include'
        });
        
        if (response.status === 401) {
            sessionStorage.clear();
            localStorage.removeItem('admin_current_page');
            fetch('/task_admin/auth/logout.php', { method: 'POST' }).catch(err => {});
            window.location.href = '/task_admin/login.html';
            return;
        }
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        
        if (data && data.code === 0) {
            // 处理检测结果
            if (data.data && data.data.detection_result) {
                const detectionResult = data.data.detection_result;
                
                // 检查是否有新的审核任务
                let hasNewTasks = false;
                
                // 导航栏页面映射
                const badgeMap = {
                    'recharge': 'recharge',
                    'withdraw': 'withdraw',
                    'agent': 'agent',
                    'magnifier': 'magnifier',
                    'rental': 'rental-orders'
                };
                
                // 更新导航栏角标
                for (const [key, value] of Object.entries(detectionResult)) {
                    if (badgeMap[key]) {
                        const panelType = badgeMap[key];
                        updateBadge(panelType, value);
                        if (value > 0) {
                            hasNewTasks = true;
                        }
                    }
                }
                
                // 如果有新任务，显示提示
                if (hasNewTasks) {
                    showToast('有新审核任务', 'success');
                }
            }
        }
    } catch (error) {
        console.error('检测通知失败:', error);
    }
}

// 更新导航栏角标 - 核心功能，供其他地方调用
function updateBadge(panelType, count) {
    // 找到对应的导航链接
    const navLink = document.querySelector(`.nav-link[data-page="${panelType}"]`);
    if (!navLink) {
        return;
    }
    
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
        // 为租赁订单添加红色角标样式
        if (panelType === 'rental-orders') {
            badge.classList.add('badge-red');
        }
        navLink.appendChild(badge);
    } else {
        // 如果是租赁订单，确保添加红色角标样式
        if (panelType === 'rental-orders') {
            badge.classList.add('badge-red');
        } else {
            badge.classList.remove('badge-red');
        }
    }
    
    // 更新角标数量
    badge.textContent = count;
}

// 确保全局可访问
try {
    if (typeof window !== 'undefined') {
        window.detectNotifications = detectNotifications;
        window.updateBadge = updateBadge;
    }
} catch (error) {
    // 忽略错误
}
