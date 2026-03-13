

// 加载团长申请列表
async function loadAgentList(page = 1) {
    const status = document.getElementById('agentStatus').value;
    try {
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        const response = await fetch(`/task_admin/api/agent/list.php?page=${page}&status=${status}`, {
            method: 'GET',
            headers: headers,
            credentials: 'include'
        });
        
        if (!response.ok) {
            throw new Error('网络响应错误');
        }
        
        const data = await response.json();
        
        if (data && data.code === 0) {
            renderAgentTable(data.data.list);
        }
    } catch (err) {
        console.error('加载团长申请失败', err);
    }
}

function renderAgentTable(list) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>用户名</th>
                    <th>申请类型</th>
                    <th>邀请码</th>
                    <th>有效邀请</th>
                    <th>总邀请</th>
                    <th>迁跃等级</th>
                    <th>状态</th>
                    <th>申请时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    list.forEach(a => {
        let statusBadge = '';
        if (a.status === 0) statusBadge = '<span class="badge badge-warning">待审核</span>';
        else if (a.status === 1) statusBadge = '<span class="badge badge-success">已通过</span>';
        else statusBadge = '<span class="badge badge-danger">已拒绝</span>';

        const applyTypeBadge = (a.apply_type === 2) ? '<span class="badge badge-warning">高级团长</span>' : '<span class="badge badge-info">普通团长</span>';

        const actions = a.status === 0 ? `
            <button class="btn-success btn-small" onclick="reviewAgent(${a.id}, 'approve')"><i class="ri-check-line"></i> 通过</button>
            <button class="btn-danger btn-small" onclick="reviewAgent(${a.id}, 'reject')"><i class="ri-close-line"></i> 拒绝</button>
        ` : '-';

        html += `
            <tr>
                <td>${a.id}</td>
                <td><strong>${a.username}</strong></td>
                <td>${applyTypeBadge}</td>
                <td>${a.invite_code}</td>
                <td>${a.valid_invites}</td>
                <td>${a.total_invites}</td>
                <td>${a.from_level && a.to_level ? `${a.from_level} → ${a.to_level}` : '-'}</td>
                <td>${statusBadge}</td>
                <td>${a.created_at}</td>
                <td>${actions}</td>
            </tr>
        `;
    });
    
    html += '</tbody></table></div>';
    document.getElementById('agentTable').innerHTML = html;
}

// 审核团长申请
function reviewAgent(id, action) {
    if (action === 'approve') {
        showConfirm('确认通过该团长申请吗？用户将获得团长身份。', async () => {
            try {
                const token = sessionStorage.getItem('admin_token');
                const headers = {
                    'Content-Type': 'application/json'
                };
                if (token) {
                    headers['Authorization'] = `Bearer ${token}`;
                }
                const response = await fetch('/task_admin/api/agent/review.php', {
                    method: 'POST',
                    headers: headers,
                    credentials: 'include',
                    body: JSON.stringify({ id, action: 'approve' })
                });
                
                if (!response.ok) {
                    throw new Error('网络响应错误');
                }
                
                const result = await response.json();
                
                if (result && result.code === 0) {
                    showToast(result.message, 'success');
                    loadAgentList();
                } else {
                    showToast(result ? result.message : '审核失败', 'error');
                }
            } catch (err) {
                showToast('审核失败', 'error');
            }
        });
    } else {
        showRejectModal('团长申请', async (reason) => {
            try {
                const token = sessionStorage.getItem('admin_token');
                const headers = {
                    'Content-Type': 'application/json'
                };
                if (token) {
                    headers['Authorization'] = `Bearer ${token}`;
                }
                const response = await fetch('/task_admin/api/agent/review.php', {
                    method: 'POST',
                    headers: headers,
                    credentials: 'include',
                    body: JSON.stringify({ id, action: 'reject', reject_reason: reason })
                });
                
                if (!response.ok) {
                    throw new Error('网络响应错误');
                }
                
                const result = await response.json();
                
                if (result && result.code === 0) {
                    showToast(result.message, 'success');
                    loadAgentList();
                } else {
                    showToast(result ? result.message : '审核失败', 'error');
                }
            } catch (err) {
                showToast('审核失败', 'error');
            }
        });
    }
}

// 显示拒绝理由模态框
function showRejectModal(title, callback) {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-close-circle-line" style="color: var(--danger-color);"></i> 拒绝${title}</h3>
        <form id="rejectForm">
            <div class="form-group">
                <label>拒绝原因</label>
                <textarea name="reason" placeholder="请输入拒绝原因..." required></textarea>
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-danger">确认拒绝</button>
            </div>
        </form>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    document.getElementById('rejectForm').onsubmit = async (e) => {
        e.preventDefault();
        const reason = new FormData(e.target).get('reason');
        closeModal();
        await callback(reason);
    };
}

// 显示确认对话框
function showConfirm(message, callback) {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-question-line" style="color: var(--primary-color);"></i> 确认操作</h3>
        <p style="margin: 20px 0; font-size: 15px; color: var(--text-primary); line-height: 1.6;">${message}</p>
        <div class="form-actions">
            <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
            <button type="button" class="btn-primary" id="confirmBtn">确认</button>
        </div>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    document.getElementById('confirmBtn').onclick = () => {
        closeModal();
        callback();
    };
}

// Toast提示
function showToast(message, type = 'info') {
    // 移除现有toast
    const existingToast = document.querySelector('.toast');
    if (existingToast) existingToast.remove();
    
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    
    let icon = 'ri-information-line';
    if (type === 'success') icon = 'ri-checkbox-circle-line';
    if (type === 'error') icon = 'ri-error-warning-line';
    
    toast.innerHTML = `<i class="${icon}"></i> ${message}`;
    document.body.appendChild(toast);
    
    setTimeout(() => toast.classList.add('show'), 10);
    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 400);
    }, 3000);
}
