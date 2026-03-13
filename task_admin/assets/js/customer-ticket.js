
// ==================== 工单管理 ====================

// 加载工单列表
async function loadTickets(page = 1) {
    const status = document.getElementById('ticketStatusFilter').value;
    const params = new URLSearchParams({ page, page_size: 20 });
    if (status) params.append('status', status);

    try {
        const apiUrl = `/task_admin/api/rental_tickets/list.php?${params}`;
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
        
        const result = await response.json();

        if (result && (result.code === 0 || result.code === 200)) {
            renderTicketsTable(result.data);
        } else {
            showToast('加载失败: ' + result.message, 'error');
        }
    } catch (err) {
        showToast('加载工单失败: ' + err.message, 'error');
    }
}

// 渲染工单列表
function renderTicketsTable(data) {
    const container = document.getElementById('ticketsTable');
    const tickets = data.tickets;
    const pagination = data.pagination;

    if (!tickets || tickets.length === 0) {
        container.innerHTML = '<p style="text-align: center; padding: 40px; color: #86868b;">暂无工单</p>';
        return;
    }

    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>工单号</th>
                    <th>标题</th>
                    <th>订单ID</th>
                    <th>买家</th>
                    <th>卖家</th>
                    <th>创建者</th>
                    <th>来源</th>
                    <th>状态</th>
                    <th>消息数</th>
                    <th>创建时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;

    tickets.forEach(ticket => {
        const statusClass = ticket.status === 0 ? 'badge badge-warning' : 
                          ticket.status === 1 ? 'badge badge-success' : 'badge badge-neutral';
        const unreadBadge = ticket.unread_admin_count > 0 ? 
            `<span class="badge badge-danger">${ticket.unread_admin_count}</span>` : '';

        html += `
            <tr>
                <td>${ticket.ticket_no}</td>
                <td><strong>${ticket.title}</strong></td>
                <td>#${ticket.order_id}</td>
                <td>${ticket.buyer_username}</td>
                <td>${ticket.seller_username}</td>
                <td>${ticket.creator_username}</td>
                <td>${ticket.source_type_text}</td>
                <td><span class="${statusClass}">${ticket.status_text}</span></td>
                <td>${ticket.message_count} ${unreadBadge}</td>
                <td>${ticket.created_at}</td>
                <td>
                    <button class="btn-small btn-info" onclick="openTicketChat(${ticket.ticket_id}, '${ticket.ticket_no}')"><i class="ri-chat-1-line"></i> 查看</button>
                    ${ticket.status !== 2 ? `<button class="btn-small btn-warning" onclick="closeTicket(${ticket.ticket_id})"><i class="ri-checkbox-circle-line"></i> 关闭</button>` : ''}
                </td>
            </tr>
        `;
    });

    html += `
            </tbody>
        </table>
        </div>
        <div class="pagination">
            <button onclick="loadTickets(${pagination.current_page - 1})" 
                    ${pagination.current_page === 1 ? 'disabled' : ''}>上一页</button>
            <span style="font-size: 13px; color: var(--text-secondary);">第 ${pagination.current_page} / ${pagination.total_pages} 页 (共 ${pagination.total} 条)</span>
            <button onclick="loadTickets(${pagination.current_page + 1})" 
                    ${pagination.current_page >= pagination.total_pages ? 'disabled' : ''}>下一页</button>
        </div>
    `;

    container.innerHTML = html;
}

// 打开工单聊天界面
async function openTicketChat(ticketId, ticketNo) {
    try {
        const apiUrl = `/task_admin/api/rental_tickets/detail.php?ticket=${ticketId}`;
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
        
        const result = await response.json();

        if (result && (result.code === 0 || result.code === 200)) {
            showTicketChatModal(result.data);
        } else {
            showToast('加载失败: ' + result.message, 'error');
        }
    } catch (err) {
        showToast('加载工单详情失败: ' + err.message, 'error');
    }
}

// 显示工单聊天弹窗
function showTicketChatModal(ticket) {
    const statusClass = ticket.status === 0 ? 'badge badge-warning' : 
                       ticket.status === 1 ? 'badge badge-success' : 'badge badge-neutral';
    
    const orderInfo = ticket.order_info;
    
    let html = `
        <div class="ticket-chat-container">
            <div class="ticket-header">
                <h3 style="margin-bottom: 12px;">工单 #${ticket.ticket_no} - ${ticket.title} <span class="${statusClass}">${ticket.status_text}</span></h3>
                <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px; font-size: 13px; color: var(--text-secondary);">
                    <div><strong>订单ID:</strong> #${orderInfo.order_id}</div>
                    <div><strong>来源:</strong> ${orderInfo.source_type_text}</div>
                    <div><strong>买家:</strong> ${orderInfo.buyer_username}</div>
                    <div><strong>卖家:</strong> ${orderInfo.seller_username}</div>
                    <div><strong>订单状态:</strong> ${orderInfo.order_status_text}</div>
                    <div><strong>租期:</strong> ${orderInfo.days}天</div>
                </div>
                
                <div style="margin-top: 15px; display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                    <div>
                        <strong style="color: var(--primary-color);">买家详细信息：</strong>
                        <div class="json-display" style="margin-top: 4px;">
                            <pre>${JSON.stringify(orderInfo.buyer_info_json, null, 2)}</pre>
                        </div>
                    </div>
                    <div>
                        <strong style="color: var(--success-color);">卖家详细信息：</strong>
                        <div class="json-display" style="margin-top: 4px;">
                            <pre>${JSON.stringify(orderInfo.seller_info_json, null, 2)}</pre>
                        </div>
                    </div>
                </div>
            </div>

            <div class="chat-messages" id="chatMessages">
                ${renderChatMessages(ticket.messages, orderInfo)}
            </div>

            ${ticket.status !== 2 ? `
            <div class="chat-input-area">
                <div style="margin-bottom: 12px; display: flex; gap: 12px; align-items: center;">
                    <button class="btn-secondary btn-small" onclick="triggerImageUpload()"><i class="ri-image-add-line"></i> 上传图片</button>
                    <span style="font-size: 12px; color: var(--text-secondary);">最多3张</span>
                </div>
                <textarea id="chatMessageInput" placeholder="输入消息内容..." style="width: 100%; min-height: 100px; margin-bottom: 12px; border-radius: var(--radius-sm); border: 1px solid var(--border-color); padding: 12px; font-family: inherit;"></textarea>
                <div id="uploadPreview" class="upload-preview"></div>
                <div style="display: flex; gap: 12px; justify-content: flex-end; margin-top: 16px;">
                    <button class="btn-warning btn-small" onclick="closeTicketInChat(${ticket.ticket_id})"><i class="ri-close-circle-line"></i> 关闭工单</button>
                    <button class="btn-primary" onclick="sendTicketMessage(${ticket.ticket_id})"><i class="ri-send-plane-fill"></i> 发送消息</button>
                </div>
            </div>
            ` : '<div class="chat-input-area" style="text-align:center;color:#999;padding: 24px;">工单已关闭</div>'}
        </div>
    `;

    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = html;
    const modal = document.getElementById('modal');
    modal.classList.add('active', 'fullscreen');

    // 滚动到底部
    setTimeout(() => {
        const chatMessages = document.getElementById('chatMessages');
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }, 100);
}

// 渲染聊天消息
function renderChatMessages(messages, orderInfo) {
    if (!messages || messages.length === 0) {
        return '<p style="text-align:center;color:#999;padding:40px 0;">暂无消息</p>';
    }

    let html = '';
    messages.forEach(msg => {
        const senderClass = msg.sender_type === 1 ? 'text-primary' :
                           msg.sender_type === 2 ? 'text-success' :
                           msg.sender_type === 3 ? 'text-danger' : 'text-secondary';
        
        const roleText = msg.role_text ? ` (${msg.role_text})` : '';
        const messageClass = msg.sender_type === 3 ? 'message message-admin' : 'message';
        
        // 将换行符转换为<br>标签
        const formattedContent = msg.content.replace(/\n/g, '<br>');

        html += `
            <div class="${messageClass}">
                <div class="message-header">
                    <span class="${senderClass}" style="font-weight: 600;">${msg.sender_type_text}${roleText}</span>
                    <span class="message-time">${msg.created_at}</span>
                </div>
                <div class="message-content">
                    <div>${formattedContent}</div>
                    ${msg.attachments && msg.attachments.length > 0 ? `
                        <div class="message-images" style="display: flex; gap: 8px; margin-top: 8px; flex-wrap: wrap;">
                            ${msg.attachments.map(img => `
                                <img src="${img}" style="max-width: 150px; max-height: 150px; border-radius: 4px; cursor: pointer;" onclick="window.open('${img}', '_blank')" />
                            `).join('')}
                        </div>
                    ` : ''}
                </div>
            </div>
        `;
    });

    return html;
}

// 全局存储上传的图片URL
window.ticketUploadedImages = [];

// 触发图片上传
function triggerImageUpload() {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = 'image/*';
    input.multiple = true;
    input.onchange = handleImageUpload;
    input.click();
}

// 处理图片上传
async function handleImageUpload(e) {
    const files = Array.from(e.target.files);
    
    if (window.ticketUploadedImages.length + files.length > 3) {
        showToast('最多只能上传3张图片', 'error');
        return;
    }

    for (const file of files) {
        if (window.ticketUploadedImages.length >= 3) break;

        const formData = new FormData();
        formData.append('file', file);
        
        try {
            const apiUrl = `/task_admin/api/upload.php`;
            const token = sessionStorage.getItem('admin_token');
            const headers = {};
            
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
            
            const response = await fetch(apiUrl, {
                method: 'POST',
                headers: headers,
                body: formData,
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
            
            const result = await response.json();

            if (result && (result.code === 0 || result.code === 200)) {
                window.ticketUploadedImages.push(result.data.url);
                renderUploadPreview();
            } else {
                showToast('上传失败: ' + result.message, 'error');
            }
        } catch (err) {
            showToast('上传失败: ' + err.message, 'error');
        }
    }
}

// 渲染上传预览
function renderUploadPreview() {
    const container = document.getElementById('uploadPreview');
    if (!container) return;

    if (window.ticketUploadedImages.length === 0) {
        container.innerHTML = '';
        return;
    }

    let html = '<div style="display: flex; gap: 8px; margin-top: 8px;">';
    window.ticketUploadedImages.forEach((url, index) => {
        html += `
            <div style="position: relative; width: 80px; height: 80px;">
                <img src="${url}" style="width: 100%; height: 100%; object-fit: cover; border-radius: 4px;" />
                <button onclick="removeUploadedImage(${index})" style="position: absolute; top: -5px; right: -5px; background: red; color: white; border-radius: 50%; width: 18px; height: 18px; border: none; display: flex; align-items: center; justify-content: center; font-size: 12px; cursor: pointer;">×</button>
            </div>
        `;
    });
    html += '</div>';

    container.innerHTML = html;
}

// 移除上传的图片
function removeUploadedImage(index) {
    window.ticketUploadedImages.splice(index, 1);
    renderUploadPreview();
}

// 发送工单消息
async function sendTicketMessage(ticketId) {
    const content = document.getElementById('chatMessageInput').value.trim();
    
    if (!content) {
        showToast('请输入消息内容', 'error');
        return;
    }

    // 自动判断消息类型：有图片就是图片消息，没有就是文本消息
    const hasImages = window.ticketUploadedImages && window.ticketUploadedImages.length > 0;
    const messageType = hasImages ? 1 : 0;

    const data = {
        ticket_id: ticketId,
        message_type: messageType,
        content: content
    };

    // 如果有图片，添加attachments参数
    if (hasImages) {
        data.attachments = window.ticketUploadedImages;
    }

    try {
        const apiUrl = `/task_admin/api/rental_tickets/send-message.php`;
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
            body: JSON.stringify(data),
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
        
        const result = await response.json();

        if (result && (result.code === 0 || result.code === 200)) {
            showToast('消息发送成功', 'success');
            // 清空输入
            document.getElementById('chatMessageInput').value = '';
            window.ticketUploadedImages = [];
            renderUploadPreview();
            // 重新加载工单详情
            openTicketChat(ticketId);
        } else {
            showToast('发送失败: ' + result.message, 'error');
        }
    } catch (err) {
        showToast('发送失败: ' + err.message, 'error');
    }
}

// 在聊天界面关闭工单
function closeTicketInChat(ticketId) {
    const reason = prompt('请输入关闭原因：', '问题已解决');
    if (!reason) return;

    closeTicket(ticketId, reason);
}

// 关闭工单
async function closeTicket(ticketId, reason = '管理员关闭工单') {
    if (!confirm(`确定要关闭工单 #${ticketId} 吗？`)) return;

    try {
        const apiUrl = `/task_admin/api/rental_tickets/close.php`;
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
            body: JSON.stringify({ ticket_id: ticketId, close_reason: reason }),
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
        
        const result = await response.json();

        if (result && (result.code === 0 || result.code === 200)) {
            showToast('工单关闭成功', 'success');
            const modal = document.getElementById('modal');
            modal.classList.remove('active', 'fullscreen');
            loadTickets();
        } else {
            showToast('关闭失败: ' + result.message, 'error');
        }
    } catch (err) {
        showToast('关闭失败: ' + err.message, 'error');
    }
}