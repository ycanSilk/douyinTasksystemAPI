

// 更新通知角标
function updateNotificationBadge(count) {
    // 查找"提示通知列表"导航栏按钮
    const navLink = document.querySelector('.nav-link[data-page="notification-logs"]') || 
                   document.querySelector('.nav-link[data-page="notifications"]');
    if (navLink) {
        let badge = navLink.querySelector('.badge-notification');
        
        if (count > 0) {
            if (!badge) {
                badge = document.createElement('span');
                badge.className = 'badge-notification';
                navLink.appendChild(badge);
            }
            badge.textContent = count;
            badge.style.display = 'inline-block';
        } else {
            if (badge) {
                badge.remove();
            }
        }
    }
    
    // 同时更新原有的通知角标元素（如果存在）
    const badge = document.getElementById('notificationBadge');
    if (badge) {
        if (count > 0) {
            badge.textContent = count;
            badge.style.display = 'inline-block';
        } else {
            badge.style.display = 'none';
        }
    }
}

// 更新导航栏面板红色角标


// 标记通知已读
async function markNotificationAsRead(notificationId) {
    try {
        const apiUrl = `/task_admin/api/admin_notifications/read.php`;
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const response = await fetch(apiUrl, {
            method: 'POST',
            headers: headers,
            body: JSON.stringify({ notification_id: notificationId }),
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
            showToast('标记已读成功', 'success');
            loadNotifications();
        } else {
            showToast(data.message, 'error');
        }
    } catch (error) {
        log('ERROR', '标记通知已读失败: ' + error.message, 'NOTIFICATION');
        showToast('标记已读失败', 'error');
    }
}

// 批量标记已读
async function markAllNotificationsAsRead(type = '') {
    try {
        const apiUrl = `/task_admin/api/admin_notifications/read-all.php`;
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const response = await fetch(apiUrl, {
            method: 'POST',
            headers: headers,
            body: JSON.stringify({ type }),
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
            showToast(`成功标记 ${data.data.count} 条通知为已读`, 'success');
            loadNotifications();
            loadNotificationLogs();
        } else {
            showToast(data.message, 'error');
        }
    } catch (error) {
        log('ERROR', '批量标记已读失败: ' + error.message, 'NOTIFICATION');
        showToast('批量标记已读失败', 'error');
    }
}

// 标记所有通知为已读（用于提示通知列表）
async function markAllNotificationsRead() {
    try {
        const apiUrl = `/task_admin/api/admin_notifications/read-all.php`;
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const response = await fetch(apiUrl, {
            method: 'POST',
            headers: headers,
            body: JSON.stringify({ type: '' }),
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
            showToast(`成功标记 ${data.data.count} 条通知为已读`, 'success');
            loadNotificationLogs();
        } else {
            showToast(data.message, 'error');
        }
    } catch (error) {
        log('ERROR', '批量标记已读失败: ' + error.message, 'NOTIFICATION');
        showToast('批量标记已读失败', 'error');
    }
}

// 清除通知日志
async function clearNotificationLogs() {
    showConfirm('确定要清除所有通知日志吗？此操作不可恢复。', async () => {
        try {
            const apiUrl = `/task_admin/api/admin_notifications/clean-log.php`;
            const token = sessionStorage.getItem('admin_token');
            const headers = {
                'Content-Type': 'application/json'
            };
            
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
            
            const response = await fetch(apiUrl, {
                method: 'POST',
                headers: headers,
                body: JSON.stringify({ days: 0 }),
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
                showToast(`成功清理 ${data.data.deleted_count} 条日志`, 'success');
                loadNotificationLogs();
            } else {
                showToast(data.message, 'error');
            }
        } catch (error) {
            log('ERROR', '清理通知日志失败: ' + error.message, 'NOTIFICATION');
            showToast('清理日志失败', 'error');
        }
    });
}

// 获取通知列表
async function loadNotifications(page = 1, status = 0) {
    try {
        log('INFO', `开始加载通知列表，状态: ${status}`, 'NOTIFICATION');
        const search = document.getElementById('notificationSearch')?.value || '';
        const filterStatus = document.getElementById('notificationStatusFilter')?.value || status;
        
        // 移除分页参数，直接请求所有数据，不按类型过滤
        const apiUrl = `/task_admin/api/admin_notifications/list.php?page=1&pageSize=100` +
            (filterStatus ? `&status=${filterStatus}` : '') +
            (search ? `&search=${encodeURIComponent(search)}` : '');
        
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
          
            renderNotificationList(data.data.list, 1, 100, data.data.total);
          
        } else {
            log('ERROR', `API返回错误: ${data.message}`, 'NOTIFICATION');
        }
    } catch (error) {
        console.error('加载通知列表失败:', error);
    }
}

// 获取通知检测日志
async function loadNotificationLogs(page = 1, hasNewNotification = -1) {
    try {
        const search = document.getElementById('notificationSearch')?.value || '';
        const type = document.getElementById('notificationTypeFilter')?.value || '';
        
        const apiUrl = `/task_admin/api/admin_notifications/log.php?page=${page}&pageSize=20` +
            (hasNewNotification !== -1 ? `&has_new_notification=${hasNewNotification}` : '') +
            (search ? `&search=${encodeURIComponent(search)}` : '') +
            (type ? `&type=${type}` : '');
        
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
            renderNotificationLogList(data.data.list, data.data.page, data.data.pageSize, data.data.total);
            logPage = data.data.page;
            logTotalPages = Math.ceil(data.data.total / data.data.pageSize);
            updateLogPagination();
        }
    } catch (error) {
        log('ERROR', '加载通知检测日志失败: ' + error.message, 'NOTIFICATION');
    }
}

// 获取通知配置
async function loadNotificationConfigs() {
    try {
        const apiUrl = `/task_admin/api/admin_notifications/config.php`;
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
            renderNotificationConfigTable(data.data);
        }
    } catch (error) {
        log('ERROR', '加载通知配置失败: ' + error.message, 'NOTIFICATION');
    }
}

// 保存通知配置
async function saveNotificationConfig(config) {
    try {
        const apiUrl = `/task_admin/api/admin_notifications/config/update.php`;
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const response = await fetch(apiUrl, {
            method: 'POST',
            headers: headers,
            body: JSON.stringify(config),
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
            showToast('保存配置成功', 'success');
            loadNotificationConfigs();
            // 重启计时器，使用新的配置
            startCountdown();
        } else {
            showToast(data.message, 'error');
        }
    } catch (error) {
        log('ERROR', '保存通知配置失败: ' + error.message, 'NOTIFICATION');
        showToast('保存配置失败', 'error');
    }
}

// 清理通知日志
async function cleanNotificationLogs(days = 2) {
    try {
        const apiUrl = `/task_admin/api/admin_notifications/clean-log.php`;
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const response = await fetch(apiUrl, {
            method: 'POST',
            headers: headers,
            body: JSON.stringify({ days }),
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
            showToast(`成功清理 ${data.data.deleted_count} 条日志`, 'success');
            loadNotificationLogs();
        } else {
            showToast(data.message, 'error');
        }
    } catch (error) {
        log('ERROR', '清理通知日志失败: ' + error.message, 'NOTIFICATION');
        showToast('清理日志失败', 'error');
    }
}

// 渲染通知列表
function renderNotificationList(list, page, pageSize, total) {     
    const notificationList = document.getElementById('notificationList');
    
    if (!notificationList) {
        console.error('找不到notificationList元素');
        return;
    }
    
    // 检查元素样式
    const computedStyle = window.getComputedStyle(notificationList);

    
    if (list.length === 0) {
        notificationList.innerHTML = '<div class="empty-state" style="text-align: center; padding: 40px; color: #86868b;">暂无通知</div>';
        return;
    }
    
    
    let html = `
        <div class="table-container">
        <table style="width: 100%; border-collapse: collapse;">
            <thead>
                <tr style="background-color: #f9f9f9; border-bottom: 1px solid #e5e5e5;">
                    <th style="padding: 10px; text-align: left; width: 40px;">
                        <input type="checkbox" id="selectAllNotifications" onchange="selectAllNotifications(this.checked)">
                    </th>
                    <th style="padding: 10px; text-align: left;">标题</th>
                    <th style="padding: 10px; text-align: left;">内容</th>
                    <th style="padding: 10px; text-align: left;">类型</th>
                    <th style="padding: 10px; text-align: left;">状态</th>
                    <th style="padding: 10px; text-align: left;">时间</th>
                    <th style="padding: 10px; text-align: left;">操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    list.forEach(notification => {
        const statusClass = notification.status === 0 ? 'unread' : 'read';
        const priorityClass = notification.priority === 1 ? 'priority-high' : '';
        const typeClass = `type-${notification.type}`;
        const statusBadge = notification.status === 0 ? 
            '<span class="badge badge-warning">未读</span>' : 
            '<span class="badge badge-success">已读</span>';
        
        html += `
            <tr class="${statusClass} ${priorityClass} ${typeClass}" style="border-bottom: 1px solid #e5e5e5;">
                <td style="padding: 10px;">
                    <input type="checkbox" class="notification-checkbox" value="${notification.id}">
                </td>
                <td style="padding: 10px;"><strong>${notification.title}</strong></td>
                <td style="padding: 10px; max-width: 300px; overflow: hidden; text-overflow: ellipsis;">${notification.content}</td>
                <td style="padding: 10px;">${notification.type}</td>
                <td style="padding: 10px;">${statusBadge}</td>
                <td style="padding: 10px;">${notification.created_at}</td>
                <td style="padding: 10px;">
                    ${notification.status === 0 ? 
                        `<button class="btn-secondary btn-small" onclick="markNotificationAsRead(${notification.id})"><i class="ri-check-line"></i> 标记已读</button>` : 
                        `<button class="btn-secondary btn-small" onclick="markNotificationAsUnread(${notification.id})"><i class="ri-arrow-undo-line"></i> 标记未读</button>`}
                    <button class="btn-info btn-small" onclick="viewNotificationDetails(${notification.id})"><i class="ri-eye-line"></i> 查看</button>
                </td>
            </tr>
        `;
    });
    
    html += '</tbody></table></div>';
    
    try {
        notificationList.innerHTML = html;
        // 再次检查元素样式
        const afterStyle = window.getComputedStyle(notificationList);
    } catch (error) {
        console.error('渲染失败:', error);
    }
}

// 全选通知
function selectAllNotifications(checked) {
    const checkboxes = document.querySelectorAll('.notification-checkbox');
    checkboxes.forEach(checkbox => {
        checkbox.checked = checked;
    });
}

// 标记通知为未读
async function markNotificationAsUnread(notificationId) {
    try {
        const apiUrl = `/task_admin/api/admin_notifications/unread.php`;
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const response = await fetch(apiUrl, {
            method: 'POST',
            headers: headers,
            body: JSON.stringify({ notification_id: notificationId }),
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
            showToast('标记未读成功', 'success');
            loadNotifications();
        } else {
            showToast(data.message, 'error');
        }
    } catch (error) {
        log('ERROR', '标记通知未读失败: ' + error.message, 'NOTIFICATION');
        showToast('标记未读失败', 'error');
    }
}

// 批量删除通知
async function clearSelectedNotifications() {
    const checkboxes = document.querySelectorAll('.notification-checkbox:checked');
    const selectedIds = Array.from(checkboxes).map(cb => cb.value);
    
    if (selectedIds.length === 0) {
        showToast('请选择要删除的通知', 'error');
        return;
    }
    
    showConfirm(`确定要删除选中的 ${selectedIds.length} 条通知吗？`, async () => {
        try {
            const apiUrl = `/task_admin/api/admin_notifications/delete.php`;
            const token = sessionStorage.getItem('admin_token');
            const headers = {
                'Content-Type': 'application/json'
            };
            
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
            
            const response = await fetch(apiUrl, {
                method: 'POST',
                headers: headers,
                body: JSON.stringify({ ids: selectedIds }),
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
                showToast(`成功删除 ${data.data.deleted_count} 条通知`, 'success');
                loadNotifications();
            } else {
                showToast(data.message, 'error');
            }
        } catch (error) {
            log('ERROR', '批量删除通知失败: ' + error.message, 'NOTIFICATION');
            showToast('批量删除失败', 'error');
        }
    });
}

// 显示通知日志模态框
function showNotificationLogsModal() {
    const modal = document.getElementById('notificationLogsModal');
    if (modal) {
        modal.classList.add('active');
        loadNotificationLogs();
    }
}

// 关闭通知日志模态框
function closeNotificationLogsModal() {
    const modal = document.getElementById('notificationLogsModal');
    if (modal) {
        modal.classList.remove('active');
    }
}

// 格式化检测结果
function formatDetectionResult(result) {
    if (!result) return '-';
    
    try {
        let formatted = '';
        if (typeof result === 'object') {
            if (result.notifications && Array.isArray(result.notifications)) {
                formatted = `新增 ${result.notifications.length} 条通知`;
            } else if (result.recharge_count !== undefined) {
                formatted = `充值审核: ${result.recharge_count} 条`;
            } else if (result.withdraw_count !== undefined) {
                formatted = `提现审核: ${result.withdraw_count} 条`;
            } else if (result.agent_count !== undefined) {
                formatted = `团长审核: ${result.agent_count} 条`;
            } else {
                // 其他类型的检测结果
                const keys = Object.keys(result);
                if (keys.length > 0) {
                    formatted = keys.map(key => `${key}: ${result[key]}`).join('，');
                } else {
                    formatted = '检测完成';
                }
            }
        } else {
            formatted = String(result);
        }
        return formatted;
    } catch (error) {
        return '检测结果解析失败';
    }
}

// 渲染通知检测日志列表
function renderNotificationLogList(list, page, pageSize, total) {
    const logTable = document.getElementById('notificationLogTable');
    
    if (list.length === 0) {
        logTable.innerHTML = '<div class="empty-state" style="text-align: center; padding: 40px; color: #86868b;">暂无通知日志</div>';
        return;
    }
    
    let html = `
        <div class="table-container">
        <table style="width: 100%; border-collapse: collapse;">
            <thead>
                <tr style="background-color: #f9f9f9; border-bottom: 1px solid #e5e5e5;">
                    <th style="padding: 10px; text-align: left; width: 40px;">
                        <input type="checkbox" id="selectAllLogs" onchange="selectAllLogs(this.checked)">
                    </th>
                    <th style="padding: 10px; text-align: left;">检测时间</th>
                    <th style="padding: 10px; text-align: left;">通知状态</th>
                    <th style="padding: 10px; text-align: left;">新增通知数量</th>
                    <th style="padding: 10px; text-align: left;">检测结果</th>
                    <th style="padding: 10px; text-align: left;">操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    list.forEach(log => {
        const hasNewClass = log.has_new_notification === 1 ? 'has-new' : '';
        const statusBadge = log.has_new_notification === 1 ? 
            '<span class="badge badge-success">有新通知</span>' : 
            '<span class="badge badge-neutral">无新通知</span>';
        const formattedResult = formatDetectionResult(log.detection_result);
        
        html += `
            <tr class="${hasNewClass}" style="border-bottom: 1px solid #e5e5e5;">
                <td style="padding: 10px;">
                    <input type="checkbox" class="log-checkbox" value="${log.id}">
                </td>
                <td style="padding: 10px;">${log.detection_time}</td>
                <td style="padding: 10px;">${statusBadge}</td>
                <td style="padding: 10px;">${log.notification_count}</td>
                <td style="padding: 10px; max-width: 300px; overflow: hidden; text-overflow: ellipsis;">
                    ${formattedResult}
                </td>
                <td style="padding: 10px;">
                    <button class="btn-info btn-small" onclick="viewNotificationDetails(${JSON.stringify(log)})"><i class="ri-eye-line"></i> 查看详情</button>
                </td>
            </tr>
        `;
    });
    
    html += '</tbody></table></div>';
    
    // 添加分页
    html += `
        <div class="pagination" style="margin-top: 20px; text-align: center;">
            <button class="btn-secondary btn-small" ${page === 1 ? 'disabled' : ''} onclick="loadNotificationLogs(${page - 1})"><i class="ri-arrow-left-line"></i> 上一页</button>
            <span style="margin: 0 15px; line-height: 32px;">第 ${page} 页，共 ${Math.ceil(total / pageSize)} 页</span>
            <button class="btn-secondary btn-small" ${page === Math.ceil(total / pageSize) ? 'disabled' : ''} onclick="loadNotificationLogs(${page + 1})"><i class="ri-arrow-right-line"></i> 下一页</button>
        </div>
    `;
    
    logTable.innerHTML = html;
}

// 全选日志
function selectAllLogs(checked) {
    const checkboxes = document.querySelectorAll('.log-checkbox');
    checkboxes.forEach(checkbox => {
        checkbox.checked = checked;
    });
}

// 查看通知详情
async function viewNotificationDetails(item) {
    const modalBody = document.getElementById('modalBody');
    
    // 检查是通知ID还是完整对象
    if (typeof item === 'number') {
        // 通过ID获取通知详情
        try {
            const apiUrl = `/task_admin/api/admin_notifications/detail.php`;
            const token = sessionStorage.getItem('admin_token');
            const headers = {
                'Content-Type': 'application/json'
            };
            
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
            
            const response = await fetch(apiUrl, {
                method: 'POST',
                headers: headers,
                body: JSON.stringify({ notification_id: item }),
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
                const notification = data.data;
                showNotificationDetails(notification);
            } else {
                showToast('获取通知详情失败', 'error');
            }
        } catch (error) {
            log('ERROR', '获取通知详情失败: ' + error.message, 'NOTIFICATION');
            showToast('获取通知详情失败', 'error');
        }
    } else {
        // 直接使用传入的对象
        showNotificationDetails(item);
    }
}

function showNotificationDetails(item) {
    const modalBody = document.getElementById('modalBody');
    
    // 检查是通知还是日志
    if (item.detection_time) {
        // 日志详情
        modalBody.innerHTML = `
            <h3><i class="ri-eye-line"></i> 通知日志详情</h3>
            <div class="notification-detail">
                <div class="detail-item">
                    <label>检测时间:</label>
                    <span>${item.detection_time}</span>
                </div>
                <div class="detail-item">
                    <label>通知状态:</label>
                    <span>${item.has_new_notification === 1 ? '有新通知' : '无新通知'}</span>
                </div>
                <div class="detail-item">
                    <label>新增通知数量:</label>
                    <span>${item.notification_count}</span>
                </div>
                ${item.detection_result ? `
                    <div class="detail-item">
                        <label>检测结果:</label>
                        <pre style="white-space: pre-wrap; background: #f5f5f5; padding: 10px; border-radius: 4px; margin-top: 5px;">${JSON.stringify(item.detection_result, null, 2)}</pre>
                    </div>
                ` : ''}
            </div>
            <div class="form-actions" style="margin-top: 20px;">
                <button type="button" class="btn-secondary" onclick="closeModal()">关闭</button>
            </div>
        `;
    } else {
        // 通知详情
        modalBody.innerHTML = `
            <h3><i class="ri-eye-line"></i> 通知详情</h3>
            <div class="notification-detail">
                <div class="detail-item">
                    <label>标题:</label>
                    <span>${item.title}</span>
                </div>
                <div class="detail-item">
                    <label>内容:</label>
                    <span>${item.content}</span>
                </div>
                <div class="detail-item">
                    <label>类型:</label>
                    <span>${item.type}</span>
                </div>
                <div class="detail-item">
                    <label>状态:</label>
                    <span>${item.status === 0 ? '未读' : '已读'}</span>
                </div>
                <div class="detail-item">
                    <label>优先级:</label>
                    <span>${item.priority === 1 ? '重要' : '普通'}</span>
                </div>
                <div class="detail-item">
                    <label>创建时间:</label>
                    <span>${item.created_at}</span>
                </div>
                ${item.data && Object.keys(item.data).length > 0 ? `
                    <div class="detail-item">
                        <label>附加数据:</label>
                        <pre style="white-space: pre-wrap; background: #f5f5f5; padding: 10px; border-radius: 4px; margin-top: 5px;">${JSON.stringify(item.data, null, 2)}</pre>
                    </div>
                ` : ''}
            </div>
            <div class="form-actions" style="margin-top: 20px;">
                <button type="button" class="btn-secondary" onclick="closeModal()">关闭</button>
            </div>
        `;
    }
    
    document.getElementById('modal').classList.add('active');
}

// 渲染通知配置表格
function renderNotificationConfigTable(configs) {
    const configTable = document.getElementById('notificationConfigTable');
    
    if (configs.length === 0) {
        configTable.innerHTML = '<div class="empty-state">暂无配置</div>';
        return;
    }
    
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>编码</th>
                    <th>名称</th>
                    <th>描述</th>
                    <th>状态</th>
                    <th>检测间隔</th>
                    <th>优先级</th>
                    <th>创建时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    configs.forEach(config => {
        const statusBadge = config.enabled === 1 ? '<span class="badge badge-success">启用</span>' : '<span class="badge badge-danger">禁用</span>';
        const priorityBadge = config.priority === 1 ? '<span class="badge badge-warning">重要</span>' : '<span class="badge badge-neutral">普通</span>';
        
        html += `
            <tr>
                <td>${config.id}</td>
                <td>${config.code}</td>
                <td>${config.name}</td>
                <td>${config.description || '-'}</td>
                <td>${statusBadge}</td>
                <td>${config.detection_interval}秒</td>
                <td>${priorityBadge}</td>
                <td>${config.created_at}</td>
                <td>
                    <button class="btn-info btn-small" onclick="editNotificationConfig(${JSON.stringify(config)})"><i class="ri-edit-line"></i> 编辑</button>
                </td>
            </tr>
        `;
    });
    
    html += '</tbody></table></div>';
    configTable.innerHTML = html;
}

// 编辑通知配置
function editNotificationConfig(config) {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-edit-line"></i> 编辑通知配置 - ${config.name}</h3>
        <form id="editNotificationConfigForm">
            <input type="hidden" name="id" value="${config.id}">
            <div class="form-group">
                <label>编码</label>
                <input type="text" name="code" value="${config.code}" placeholder="通知类型编码" required>
            </div>
            <div class="form-group">
                <label>名称</label>
                <input type="text" name="name" value="${config.name}" placeholder="通知类型名称" required>
            </div>
            <div class="form-group">
                <label>描述</label>
                <textarea name="description" placeholder="通知类型描述">${config.description || ''}</textarea>
            </div>
            <div class="form-group">
                <label>状态</label>
                <select name="enabled" required>
                    <option value="1" ${config.enabled === 1 ? 'selected' : ''}>启用</option>
                    <option value="0" ${config.enabled === 0 ? 'selected' : ''}>禁用</option>
                </select>
            </div>
            <div class="form-group">
                <label>检测间隔（秒）</label>
                <input type="number" name="detection_interval" value="${config.detection_interval}" min="1" required>
            </div>
            <div class="form-group">
                <label>判断条件</label>
                <input type="text" name="judgment_condition" value="${config.judgment_condition || ''}" placeholder="通知判断条件">
            </div>
            <div class="form-group">
                <label>优先级</label>
                <select name="priority" required>
                    <option value="0" ${config.priority === 0 ? 'selected' : ''}>普通</option>
                    <option value="1" ${config.priority === 1 ? 'selected' : ''}>重要</option>
                </select>
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-primary">保存</button>
            </div>
        </form>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    document.getElementById('editNotificationConfigForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const data = {};
        
        for (const [key, value] of formData.entries()) {
            if (value !== '') {
                if (key === 'id' || key === 'enabled' || key === 'detection_interval' || key === 'priority') {
                    data[key] = Number(value);
                } else {
                    data[key] = value;
                }
            }
        }
        
        await saveNotificationConfig(data);
        closeModal();
    });
}

// 新增通知配置
function addNotificationConfig() {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-add-line"></i> 新增通知配置</h3>
        <form id="addNotificationConfigForm">
            <div class="form-group">
                <label>编码</label>
                <input type="text" name="code" placeholder="通知类型编码" required>
            </div>
            <div class="form-group">
                <label>名称</label>
                <input type="text" name="name" placeholder="通知类型名称" required>
            </div>
            <div class="form-group">
                <label>描述</label>
                <textarea name="description" placeholder="通知类型描述"></textarea>
            </div>
            <div class="form-group">
                <label>状态</label>
                <select name="enabled" required>
                    <option value="1">启用</option>
                    <option value="0">禁用</option>
                </select>
            </div>
            <div class="form-group">
                <label>检测间隔（秒）</label>
                <input type="number" name="detection_interval" value="60" min="1" required>
            </div>
            <div class="form-group">
                <label>判断条件</label>
                <input type="text" name="judgment_condition" placeholder="通知判断条件">
            </div>
            <div class="form-group">
                <label>优先级</label>
                <select name="priority" required>
                    <option value="0">普通</option>
                    <option value="1">重要</option>
                </select>
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-primary">创建</button>
            </div>
        </form>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    document.getElementById('addNotificationConfigForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const data = {};
        
        for (const [key, value] of formData.entries()) {
            if (value !== '') {
                if (key === 'enabled' || key === 'detection_interval' || key === 'priority') {
                    data[key] = Number(value);
                } else {
                    data[key] = value;
                }
            }
        }
        
        await saveNotificationConfig(data);
        closeModal();
    });
}

// 更新通知角标
function updateNotificationBadge(count) {
    // 更新导航栏链接上的角标
    const navLink = document.querySelector('.nav-link[data-page="notification-logs"]');
    if (navLink) {
        let badge = navLink.querySelector('.badge-notification');
        
        if (count > 0) {
            if (!badge) {
                badge = document.createElement('span');
                badge.className = 'badge-notification';
                navLink.appendChild(badge);
            }
            badge.textContent = count;
            badge.style.display = 'inline-block';
        } else {
            if (badge) {
                badge.remove();
            }
        }
    }
    
    // 同时更新原有的通知角标元素（如果存在）
    const badge = document.getElementById('notificationBadge');
    if (badge) {
        if (count > 0) {
            badge.textContent = count;
            badge.style.display = 'inline-block';
        } else {
            badge.style.display = 'none';
        }
    }
}

// 更新通知分页
function updateNotificationPagination() {
    const paginationContainer = document.getElementById('notificationPagination');
    
    if (paginationContainer) {
        paginationContainer.innerHTML = `
            <button class="btn-secondary btn-small" ${notificationPage === 1 ? 'disabled' : ''} onclick="loadNotifications(${notificationPage - 1})"><i class="ri-arrow-left-line"></i> 上一页</button>
            <span style="margin: 0 15px; line-height: 32px;">第 ${notificationPage} 页，共 ${notificationTotalPages} 页</span>
            <button class="btn-secondary btn-small" ${notificationPage === notificationTotalPages ? 'disabled' : ''} onclick="loadNotifications(${notificationPage + 1})"><i class="ri-arrow-right-line"></i> 下一页</button>
        `;
    }
}

// 更新日志分页
function updateLogPagination() {
    const prevBtn = document.getElementById('prevLogPage');
    const nextBtn = document.getElementById('nextLogPage');
    const pageInfo = document.getElementById('logPageInfo');
    
    if (prevBtn && nextBtn && pageInfo) {
        prevBtn.disabled = logPage === 1;
        nextBtn.disabled = logPage === logTotalPages;
        pageInfo.textContent = `第 ${logPage} 页，共 ${logTotalPages} 页`;
    }
}

// 初始化通知中心
function initNotificationCenter() {
    const notificationBtn = document.getElementById('notificationBtn');
    const notificationCenter = document.getElementById('notificationCenter');
    const markAllReadBtn = document.getElementById('markAllReadBtn');
    const refreshNotificationsBtn = document.getElementById('refreshNotificationsBtn');
    const viewNotificationLogsBtn = document.getElementById('viewNotificationLogsBtn');
    const notificationTypeFilter = document.getElementById('notificationTypeFilter');
    const notificationStatusFilter = document.getElementById('notificationStatusFilter');
    const prevNotificationPage = document.getElementById('prevNotificationPage');
    const nextNotificationPage = document.getElementById('nextNotificationPage');
    
    if (notificationBtn && notificationCenter) {
        notificationBtn.addEventListener('click', () => {
            notificationCenter.classList.add('active');
            loadNotifications();
        });
    }
    
    if (markAllReadBtn) {
        markAllReadBtn.addEventListener('click', () => {
            markAllNotificationsAsRead();
        });
    }
    
    if (refreshNotificationsBtn) {
        refreshNotificationsBtn.addEventListener('click', () => {
            loadNotifications(notificationPage, currentNotificationType, currentNotificationStatus);
        });
    }
    
    if (viewNotificationLogsBtn) {
        viewNotificationLogsBtn.addEventListener('click', () => {
            const notificationLogModal = document.getElementById('notificationLogModal');
            if (notificationLogModal) {
                notificationLogModal.classList.add('active');
                loadNotificationLogs();
            }
        });
    }
    
    if (notificationTypeFilter) {
        notificationTypeFilter.addEventListener('change', () => {
            currentNotificationType = notificationTypeFilter.value;
            loadNotifications(1, currentNotificationType, currentNotificationStatus);
        });
    }
    
    if (notificationStatusFilter) {
        notificationStatusFilter.addEventListener('change', () => {
            currentNotificationStatus = notificationStatusFilter.value;
            loadNotifications(1, currentNotificationType, currentNotificationStatus);
        });
    }
    
    if (prevNotificationPage) {
        prevNotificationPage.addEventListener('click', () => {
            if (notificationPage > 1) {
                loadNotifications(notificationPage - 1, currentNotificationType, currentNotificationStatus);
            }
        });
    }
    
    if (nextNotificationPage) {
        nextNotificationPage.addEventListener('click', () => {
            if (notificationPage < notificationTotalPages) {
                loadNotifications(notificationPage + 1, currentNotificationType, currentNotificationStatus);
            }
        });
    }
    
    // 初始化通知检测日志模态框
    const notificationLogModal = document.getElementById('notificationLogModal');
    const refreshLogsBtn = document.getElementById('refreshLogsBtn');
    const logHasNewFilter = document.getElementById('logHasNewFilter');
    const prevLogPage = document.getElementById('prevLogPage');
    const nextLogPage = document.getElementById('nextLogPage');
    
    if (refreshLogsBtn) {
        refreshLogsBtn.addEventListener('click', () => {
            const hasNewFilter = document.getElementById('logHasNewFilter').value;
            loadNotificationLogs(logPage, parseInt(hasNewFilter));
        });
    }
    
    if (logHasNewFilter) {
        logHasNewFilter.addEventListener('change', () => {
            loadNotificationLogs(1, parseInt(logHasNewFilter.value));
        });
    }
    
    if (prevLogPage) {
        prevLogPage.addEventListener('click', () => {
            if (logPage > 1) {
                const hasNewFilter = document.getElementById('logHasNewFilter').value;
                loadNotificationLogs(logPage - 1, parseInt(hasNewFilter));
            }
        });
    }
    
    if (nextLogPage) {
        nextLogPage.addEventListener('click', () => {
            if (logPage < logTotalPages) {
                const hasNewFilter = document.getElementById('logHasNewFilter').value;
                loadNotificationLogs(logPage + 1, parseInt(hasNewFilter));
            }
        });
    }
}

// 初始化
function init() {

    
    initLoginForm();
    initLogout();
    initNavigation();
    initModal();
    initNotificationCenter();
    initAgentUpgradePanel();
    
    // 检查登录状态
    checkLoginStatus();
    

    
    // 启动数据自动刷新（每10分钟）
    setInterval(() => {
        loadDashboard();
    }, 10 * 60 * 1000); // 10分钟
}





// ==================== 通知管理 ====================

// 加载通知列表
async function loadNotificationList(page = 1) {
    const targetType = document.getElementById('notificationTargetType').value;
    
    const params = new URLSearchParams({
        page,
        limit: 20
    });
    
    if (targetType !== '') {
        params.append('target_type', targetType);
    }
    
    try {
        const apiUrl = `/task_admin/api/notifications/list.php?${params}`;
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
            renderSystemNotificationList(data.data.list, data.data.pagination);
        } else {
            showToast('加载失败: ' + data.message, 'error');
        }
    } catch (err) {
        showToast('加载失败: ' + err.message, 'error');
    }
}

// 渲染系统通知列表
function renderSystemNotificationList(list, pagination) {
    let html = `<div class="table-container"><table>
        <thead>
            <tr>
                <th width="8%">ID</th>
                <th width="20%">标题</th>
                <th width="30%">内容预览</th>
                <th width="10%">目标类型</th>
                <th width="8%">接收人数</th>
                <th width="8%">已读人数</th>
                <th width="8%">未读人数</th>
                <th width="18%">发送时间</th>
            </tr>
        </thead>
        <tbody>`;
    
    if (list.length === 0) {
        html += `<tr><td colspan="8" style="text-align:center;padding:40px;color:#86868b;">暂无通知</td></tr>`;
    } else {
        list.forEach(item => {
            html += `
                <tr>
                    <td>${item.id}</td>
                    <td><strong>${item.title}</strong></td>
                    <td style="font-size:12px;color:#666;">${item.content_preview}</td>
                    <td><span class="badge badge-info">${item.target_type_text}</span></td>
                    <td>${item.recipient_count}</td>
                    <td>${item.read_count}</td>
                    <td>${item.unread_count}</td>
                    <td>${item.created_at}</td>
                </tr>
            `;
        });
    }
    
    html += `</tbody></table></div>
    <div class="pagination">
        ${pagination.page > 1 ? `<button onclick="loadNotificationList(${pagination.page - 1})">上一页</button>` : '<button disabled>上一页</button>'}
        <span style="font-size: 13px; color: var(--text-secondary);">第 ${pagination.page} / ${pagination.total_pages} 页</span>
        ${pagination.page < pagination.total_pages ? `<button onclick="loadNotificationList(${pagination.page + 1})">下一页</button>` : '<button disabled>下一页</button>'}
    </div>`;
    
    document.getElementById('notificationTable').innerHTML = html;
}

// 显示发送通知的模态框
function showSendNotificationModal() {
    const html = `
        <h3><i class="ri-send-plane-fill" style="color: var(--primary-color);"></i> 发送系统通知</h3>
        <form id="sendNotificationForm" style="padding: 10px 0;">
            <div class="form-group">
                <label>通知标题 *</label>
                <input type="text" id="notifTitle" placeholder="请输入通知标题" required maxlength="200">
            </div>
            
            <div class="form-group">
                <label>通知内容 *</label>
                <textarea id="notifContent" placeholder="请输入通知内容" required rows="6"></textarea>
            </div>
            
            <div class="form-group">
                <label>发送对象 *</label>
                <select id="notifTargetType" onchange="toggleUserFields()" required>
                    <option value="0">全体用户（B端+C端）</option>
                    <option value="1">C端全体用户</option>
                    <option value="2">B端全体用户</option>
                    <option value="3">指定用户</option>
                </select>
            </div>
            
            <div id="specificUserFields" style="display: none;">
                <div class="form-group">
                    <label>用户类型 *</label>
                    <select id="notifTargetUserType">
                        <option value="1">C端用户</option>
                        <option value="2">B端用户</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>用户ID *</label>
                    <input type="number" id="notifTargetUserId" placeholder="请输入用户ID">
                </div>
            </div>
            
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-primary">发送通知</button>
            </div>
        </form>
    `;
    
    document.getElementById('modalBody').innerHTML = html;
    document.getElementById('modal').classList.add('active');
    
    document.getElementById('sendNotificationForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        await sendNotification();
    });
}

// 切换指定用户字段显示
function toggleUserFields() {
    const targetType = document.getElementById('notifTargetType').value;
    const fields = document.getElementById('specificUserFields');
    
    if (targetType === '3') {
        fields.style.display = 'block';
        document.getElementById('notifTargetUserId').required = true;
    } else {
        fields.style.display = 'none';
        document.getElementById('notifTargetUserId').required = false;
    }
}

// 发送通知
async function sendNotification() {
    const title = document.getElementById('notifTitle').value.trim();
    const content = document.getElementById('notifContent').value.trim();
    const targetType = parseInt(document.getElementById('notifTargetType').value);
    
    if (!title || !content) {
        showToast('请填写完整信息', 'error');
        return;
    }
    
    const payload = {
        title,
        content,
        target_type: targetType
    };
    
    // 如果是指定用户，添加用户ID和类型
    if (targetType === 3) {
        const targetUserId = parseInt(document.getElementById('notifTargetUserId').value);
        const targetUserType = parseInt(document.getElementById('notifTargetUserType').value);
        
        if (!targetUserId || targetUserId <= 0) {
            showToast('请输入有效的用户ID', 'error');
            return;
        }
        
        payload.target_user_id = targetUserId;
        payload.target_user_type = targetUserType;
    }
    
    try {
        const apiUrl = `/task_admin/api/notifications/send.php`;
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const response = await fetch(apiUrl, {
            method: 'POST',
            headers: headers,
            body: JSON.stringify(payload),
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
            showToast('通知发送成功', 'success');
            closeModal();
            loadNotificationList();
        } else {
            showToast('发送失败: ' + data.message, 'error');
        }
    } catch (err) {
        showToast('发送失败: ' + err.message, 'error');
    }
}





