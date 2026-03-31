// C 端用户管理相关功能

// 加载 C 端用户列表
async function loadCUsers(page = 1) {
    const search = document.getElementById('cUserSearch').value;
    try {
        const apiUrl = `/task_admin/api/c_users/list.php?page=${page}&page_size=20&search=${encodeURIComponent(search)}`;
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
            renderCUsersTable(data.data.list, data.data.pagination);
        }
    } catch (err) {
        console.error('加载 C 端用户失败', err);
    }
}

function renderCUsersTable(list, pagination) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>用户名</th>
                    <th>邮箱</th>
                    <th>手机号</th>
                    <th>邀请码</th>
                    <th>上级ID</th>
                <th>上级用户名</th>
                <th>一级代理</th>
                <th>二级代理</th>
                    <th>当前用户角色</th>
                    <th>迁跃状态</th>
                    <th>迁跃等级</th>
                    <th>封禁状态</th>
                    <th>封禁结束时间</th>
                    <th>钱包ID</th>
                    <th>余额</th>
                    <th>总完成</th>
                    <th>总通过</th>
                    <th>总驳回</th>
                    <th>今日完成</th>
                    <th>今日通过</th>
                    <th>今日驳回</th>
                    <th>状态</th>
                    <th>禁用原因</th>
                    <th>注册IP</th>
                    <th>注册时间（年月日/时分秒）</th>
                    <th style="width: 300px;">  操作按钮（编辑/解禁/封禁/注销用户/开启/解除冷却限制） </th>
                </tr>
            </thead>
            <tbody>
    `;
    
    list.forEach(u => {
        const statusBadge = u.status === 1 ? '<span class="badge badge-success">正常</span>' : '<span class="badge badge-danger">禁用</span>';
        let agentBadge = '<span class="badge badge-neutral">普通用户</span>';
        if (u.is_agent === 3) {
            agentBadge = '<span class="badge badge-danger"><i class="ri-vip-crown-fill"></i> 大团团长</span>';
        } else if (u.is_agent === 2) {
            agentBadge = '<span class="badge badge-warning"><i class="ri-vip-diamond-fill"></i> 高级团长</span>';
        } else if (u.is_agent === 1) {
            agentBadge = '<span class="badge badge-success"><i class="ri-vip-crown-fill"></i> 普通团长</span>';
        }
        // 处理封禁状态显示
        let blockedStatusText = '正常';
        let blockedStatusClass = 'badge-neutral';
        if (u.blocked_status === 1) {
            blockedStatusText = '禁止接单';
            blockedStatusClass = 'badge-warning';
        } else if (u.blocked_status === 2) {
            blockedStatusText = '禁止登录';
            blockedStatusClass = 'badge-danger';
        }
        
        // 处理一级代理信息
        let firstAgentText = '<div class="agent-info agent-level-1"><span class="badge badge-neutral">无</span></div>';
        if (u.parent_username) {
            let parentRole = '普通用户';
            let roleClass = 'badge-neutral';
            let roleIcon = '';
            if (u.parent_is_agent === 3) {
                parentRole = '大团团长';
                roleClass = 'badge-danger';
                roleIcon = '<i class="ri-vip-crown-fill"></i> ';
            } else if (u.parent_is_agent === 2) {
                parentRole = '高级团长';
                roleClass = 'badge-warning';
                roleIcon = '<i class="ri-vip-diamond-fill"></i> ';
            } else if (u.parent_is_agent === 1) {
                parentRole = '普通团长';
                roleClass = 'badge-success';
                roleIcon = '<i class="ri-vip-crown-fill"></i> ';
            }
            firstAgentText = `
                <div class="agent-info agent-level-1">
                    <div class="agent-name">${u.parent_username}</div>
                    <div class="agent-role"><span class="badge ${roleClass}">${roleIcon}${parentRole}</span></div>
                </div>
            `;
        }
        
        // 处理二级代理信息
        let secondAgentText = '<div class="agent-info agent-level-2"><span class="badge badge-neutral">无</span></div>';
        if (u.grandparent_username) {
            let grandparentRole = '普通用户';
            let roleClass = 'badge-neutral';
            let roleIcon = '';
            if (u.grandparent_is_agent === 3) {
                grandparentRole = '大团团长';
                roleClass = 'badge-danger';
                roleIcon = '<i class="ri-vip-crown-fill"></i> ';
            } else if (u.grandparent_is_agent === 2) {
                grandparentRole = '高级团长';
                roleClass = 'badge-warning';
                roleIcon = '<i class="ri-vip-diamond-fill"></i> ';
            } else if (u.grandparent_is_agent === 1) {
                grandparentRole = '普通团长';
                roleClass = 'badge-success';
                roleIcon = '<i class="ri-vip-crown-fill"></i> ';
            }
            secondAgentText = `
                <div class="agent-info agent-level-2">
                    <div class="agent-name">${u.grandparent_username}</div>
                    <div class="agent-role"><span class="badge ${roleClass}">${roleIcon}${grandparentRole}</span></div>
                </div>
            `;
        }
        
        html += `
            <tr>
                <td>${u.id}</td>
                <td><strong>${u.username}</strong></td>
                <td>${u.email}</td>
                <td>${u.phone || '-'}</td>
                <td>${u.invite_code}</td>
                <td>${u.parent_id || '-'}</td>
                <td>${u.parent_username || '-'}</td>
                <td>${firstAgentText}</td>
                <td>${secondAgentText}</td>
                <td>${agentBadge}</td>
                <td>${u.jump_agent_status || '不是'}</td>
                <td>${u.jump_level || 0}</td>
                <td><span class="badge ${blockedStatusClass}">${blockedStatusText}</span></td>
                <td>${u.blocked_end_time || '-'}</td>
                <td>${u.wallet_id}</td>
                <td>¥${u.balance}</td>
                <td>${u.total_completed}</td>
                <td>${u.total_approved}</td>
                <td>${u.total_rejected}</td>
                <td>${u.today_completed}</td>
                <td>${u.today_approved}</td>
                <td>${u.today_rejected}</td>
                <td>${statusBadge}</td>
                <td>${u.reason || '-'}</td>
                <td>${u.create_ip || '-'}</td>
                <td>${u.created_at}</td>
                <td style="width: 300px;">
            <div style="display: flex; gap: 2px; flex-wrap: wrap;">
                <button class="btn-info btn-small" style="display: flex;" onclick='editCUser(${JSON.stringify(u)})'>编辑</button>
                ${u.blocked_status > 0 ? 
                    `<button class="btn-success btn-small" style="display: flex;" onclick='unblockUser(${u.id})'>解禁</button>` : 
                    `<button class="btn-info btn-small" style="display: flex;" onclick='blockUser(${JSON.stringify(u)})'>封禁</button>`
                }
                <button class="btn-danger btn-small" style="display: flex;" onclick='deleteCUser(${JSON.stringify(u)})'>注销用户</button>
                <button class="btn-info btn-small" style="display: flex;" onclick='toggleCoolingLimit(${u.id}, ${u.cooling_time_limit ?? 1})'>设置冷却限制</button>
            </div>
        </td>
            </tr>
        `;
    });
    
    html += '</tbody></table></div>';
    
    // 分页
    if (pagination && pagination.total_pages > 1) {
        html += '<div class="pagination" style="margin-top: 15px; text-align: center;">';
        
        // 上一页
        if (pagination.page > 1) {
            html += `<button class="btn-small" onclick="loadCUsers(${pagination.page - 1})">上一页</button>`;
        }
        
        // 页码信息
        html += `<span style="margin: 0 15px;">第 ${pagination.page} / ${pagination.total_pages} 页，共 ${pagination.total} 条</span>`;
        
        // 下一页
        if (pagination.page < pagination.total_pages) {
            html += `<button class="btn-small" onclick="loadCUsers(${pagination.page + 1})">下一页</button>`;
        }
        
        html += '</div>';
    }
    
    document.getElementById('cUsersTable').innerHTML = html;
}

// 编辑C端用户
function editCUser(user) {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-edit-line"></i> 编辑C端用户 #${user.id}</h3>
        <form id="editCUserForm">
            <input type="hidden" name="id" value="${user.id}">
            <div class="form-group">
                <label>用户名（不可修改）</label>
                <input type="text" value="${user.username}" disabled>
            </div>
            <div class="form-group">
                <label>邀请码（不可修改）</label>
                <input type="text" value="${user.invite_code}" disabled>
            </div>
            <div class="form-group">
                <label>邮箱</label>
                <input type="email" name="email" value="${user.email}" placeholder="邮箱">
            </div>
            <div class="form-group">
                <label>手机号</label>
                <input type="text" name="phone" value="${user.phone || ''}" placeholder="手机号（选填）">
            </div>
            <div class="form-group">
                <label>上级ID（不可修改）</label>
                <input type="text" value="${user.parent_id || '无'}" disabled>
            </div>
            <div class="form-group">
                <label>上级用户名（不可修改）</label>
                <input type="text" value="${user.parent_username || '无'}" disabled>
            </div>
            <div class="form-group">
                <label>团长身份</label>
                <select name="is_agent">
                    <option value="0" ${user.is_agent === 0 ? 'selected' : ''}>普通用户</option>
                    <option value="1" ${user.is_agent === 1 ? 'selected' : ''}>普通团长</option>
                    <option value="2" ${user.is_agent === 2 ? 'selected' : ''}>高级团长</option>
                    <option value="3" ${user.is_agent === 3 ? 'selected' : ''}>大团团长</option>
                </select>
            </div>
            <div class="form-group">
                <label>迁跃状态（不可修改）</label>
                <input type="text" value="${user.jump_agent_status || '不是'}" disabled>
            </div>
            <div class="form-group">
                <label>迁跃等级（不可修改）</label>
                <input type="text" value="${user.jump_level || 0}" disabled>
            </div>
            <div class="form-group">
                <label>账号状态</label>
                <select name="status">
                    <option value="1" ${user.status === 1 ? 'selected' : ''}>正常</option>
                    <option value="0" ${user.status === 0 ? 'selected' : ''}>禁用</option>
                </select>
            </div>
            <div class="form-group">
                <label>禁用原因</label>
                <input type="text" name="reason" value="${user.reason || ''}" placeholder="禁用原因（选填）">
            </div>
            <div class="form-group">
                <label>重置密码（不填则不修改）</label>
                <input type="password" name="password" placeholder="留空表示不修改密码">
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-primary">保存</button>
            </div>
        </form>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    document.getElementById('editCUserForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const data = {};
        
        // 只包含有值的字段
        for (const [key, value] of formData.entries()) {
            if (value !== '') {
                data[key] = value;
            }
        }
        
        try {
            const apiUrl = `/task_admin/api/c_users/update.php`;
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
            
            if (result && result.code === 0) {
                showToast('更新成功', 'success');
                closeModal();
                loadCUsers();
            } else {
                showToast(result.message, 'error');
            }
        } catch (err) {
            showToast('更新失败', 'error');
        }
    });
}

// 封禁用户
function blockUser(user) {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-lock-line"></i> 封禁用户 #${user.id}</h3>
        <form id="blockUserForm">
            <input type="hidden" name="user_id" value="${user.id}">
            <div class="form-group">
                <label>用户名</label>
                <input type="text" value="${user.username}" disabled>
            </div>
            <div class="form-group">
                <label>封禁类型</label>
                <select name="blocked_status" required>
                    <option value="1">禁止接单</option>
                    <option value="2">禁止登录</option>
                </select>
            </div>
            <div class="form-group">
                <label>封禁时长（小时）</label>
                <input type="number" name="blocked_duration" min="1" required placeholder="请输入封禁时长">
            </div>
            <div class="form-actions">
                <button type="button" class="btn-info" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-info">确认封禁</button>
            </div>
        </form>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    document.getElementById('blockUserForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const data = {
            user_id: parseInt(formData.get('user_id')),
            blocked_status: parseInt(formData.get('blocked_status')),
            blocked_duration: parseInt(formData.get('blocked_duration'))
        };
        
        try {
            const apiUrl = `/task_admin/api/c_users/block.php`;
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
            
            if (result && result.code === 0) {
                showToast('封禁成功', 'success');
                closeModal();
                loadCUsers();
            } else {
                showToast(result.message, 'error');
            }
        } catch (err) {
            showToast('封禁失败', 'error');
        }
    });
}

// 解禁用户
function unblockUser(userId) {
    showConfirm('确定要解禁该用户吗？', async () => {
        try {
            const apiUrl = `/task_admin/api/c_users/block.php`;
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
                body: JSON.stringify({
                    user_id: userId,
                    blocked_status: 0,
                    blocked_duration: 0
                }),
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
            
            if (result && result.code === 0) {
                showToast('解禁成功', 'success');
                loadCUsers();
            } else {
                showToast(result.message, 'error');
            }
        } catch (err) {
            showToast('解禁失败', 'error');
        }
    });
}

// 注销C端用户
function deleteCUser(user) {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-delete-bin-line"></i> 注销用户 #${user.id}</h3>
        <div class="alert alert-warning">
            <i class="ri-alert-line"></i> 
            <strong>警告：</strong>此操作将永久删除该用户账号及其所有数据，且无法恢复！
        </div>
        <form id="deleteCUserForm">
            <input type="hidden" name="user_id" value="${user.id}">
            <div class="form-group">
                <label>用户ID</label>
                <input type="text" value="${user.id}" disabled>
            </div>
            <div class="form-group">
                <label>用户名</label>
                <input type="text" value="${user.username}" disabled>
            </div>
            <div class="form-group">
                <label>钱包余额</label>
                <input type="text" value="¥${user.balance}" disabled>
            </div>
            <div class="form-group">
                <label>注册时间</label>
                <input type="text" value="${user.created_at}" disabled>
            </div>
            <div class="form-group">
                <label style="color: #dc3545;">
                    <input type="checkbox" name="confirm_delete" required>
                    我确认要注销此用户，并了解此操作不可恢复
                </label>
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-danger">确认注销</button>
            </div>
        </form>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    document.getElementById('deleteCUserForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const confirmDelete = e.target.querySelector('[name="confirm_delete"]').checked;
        if (!confirmDelete) {
            showToast('请先勾选确认框', 'error');
            return;
        }
        
        try {
            const apiUrl = `/task_admin/api/c_users/delete.php`;
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
                body: JSON.stringify({
                    id: user.id
                }),
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
            
            if (result && result.code === 0) {
                const clearedAmount = result.data.wallet_balance_cleared || 0;
                const clearedText = clearedAmount > 0 ? `（已清零余额 ¥${(clearedAmount / 100).toFixed(2)}）` : '';
                showToast(`用户注销成功${clearedText}`, 'success');
                closeModal();
                loadCUsers();
            } else {
                showToast(result.message || '注销失败', 'error');
            }
        } catch (err) {
            console.error('注销用户失败', err);
            showToast('注销失败：' + err.message, 'error');
        }
    });
}

// 查看注销用户记录
async function showDeletionLogs(page = 1) {
    const modal = document.getElementById('modal');
    const modalBody = document.getElementById('modalBody');
    
    // 显示加载状态
    modalBody.innerHTML = `
        <h3><i class="ri-file-list-line"></i> 用户注销记录</h3>
        <div class="toolbar" style="margin-bottom: 15px;">
            <input type="text" id="deletionLogSearch" placeholder="搜索用户名..." class="search-input">
            <select id="deletionLogStatus" class="search-input">
                <option value="">全部状态</option>
                <option value="1">成功</option>
                <option value="0">失败</option>
            </select>
            <button class="btn-primary" onclick="loadDeletionLogs(1)"><i class="ri-search-line"></i> 搜索</button>
        </div>
        <div id="deletionLogsTable">加载中...</div>
    `;
    
    modal.classList.add('active', 'modal-wide');
    
    // 加载数据
    await loadDeletionLogs(page);
}

// 加载注销日志数据
async function loadDeletionLogs(page = 1) {
    const search = document.getElementById('deletionLogSearch')?.value || '';
    const status = document.getElementById('deletionLogStatus')?.value || '';
    
    try {
        let apiUrl = `/task_admin/api/c_users/deletion-logs.php?page=${page}&page_size=10`;
        if (search) apiUrl += `&username=${encodeURIComponent(search)}`;
        if (status) apiUrl += `&status=${status}`;
        
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
        
        if (result && result.code === 0) {
            renderDeletionLogsTable(result.data.list, result.data.pagination);
        } else {
            document.getElementById('deletionLogsTable').innerHTML = `
                <div class="alert alert-error">加载失败：${result.message || '未知错误'}</div>
            `;
        }
    } catch (err) {
        console.error('加载注销日志失败', err);
        document.getElementById('deletionLogsTable').innerHTML = `
            <div class="alert alert-error">加载失败：${err.message}</div>
        `;
    }
}

// 渲染注销日志表格
function renderDeletionLogsTable(list, pagination) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>用户ID</th>
                    <th>用户名</th>
                    <th>钱包余额</th>
                    <th>操作人</th>
                    <th>操作IP</th>
                    <th>状态</th>
                    <th>错误信息</th>
                    <th>注销时间</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    if (list.length === 0) {
        html += '<tr><td colspan="9" style="text-align: center;">暂无记录</td></tr>';
    } else {
        list.forEach(item => {
            const statusBadge = item.status === 1 
                ? '<span class="badge badge-success">成功</span>' 
                : '<span class="badge badge-danger">失败</span>';
            
            html += `
                <tr>
                    <td>${item.id}</td>
                    <td>${item.user_id}</td>
                    <td>${item.username || '-'}</td>
                    <td>${item.wallet_balance_before_formatted}</td>
                    <td>${item.operator_username || '系统'} (${item.operator_type_text})</td>
                    <td>${item.operation_ip || '-'}</td>
                    <td>${statusBadge}</td>
                    <td>${item.error_message ? item.error_message.substring(0, 50) + '...' : '-'}</td>
                    <td>${item.created_at}</td>
                </tr>
            `;
        });
    }
    
    html += '</tbody></table></div>';
    
    // 分页
    if (pagination.total_pages > 1) {
        html += '<div class="pagination" style="margin-top: 15px; text-align: center;">';
        
        // 上一页
        if (pagination.page > 1) {
            html += `<button class="btn-small" onclick="loadDeletionLogs(${pagination.page - 1})">上一页</button>`;
        }
        
        // 页码信息
        html += `<span style="margin: 0 15px;">第 ${pagination.page} / ${pagination.total_pages} 页，共 ${pagination.total} 条</span>`;
        
        // 下一页
        if (pagination.page < pagination.total_pages) {
            html += `<button class="btn-small" onclick="loadDeletionLogs(${pagination.page + 1})">下一页</button>`;
        }
        
        html += '</div>';
    } else if (pagination.total > 0) {
        html += `<div style="margin-top: 15px; text-align: center; color: #666;">共 ${pagination.total} 条记录</div>`;
    }
    
    document.getElementById('deletionLogsTable').innerHTML = html;
}

// 切换用户接单冷却限制 - 弹出选择框让用户主动选择
function toggleCoolingLimit(userId, currentStatus) {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-time-line"></i> 设置接单冷却限制 #${userId}</h3>
        <form id="toggleCoolingLimitForm">
            <input type="hidden" name="user_id" value="${userId}">
            <div class="form-group">
                <label>当前状态</label>
                <div style="padding: 10px; background: #f5f5f5; border-radius: 4px; margin-bottom: 15px;">
                    ${currentStatus === 0 ? 
                        '<span style="color: #28a745;"><i class="ri-check-line"></i> 已解除冷却限制（接单无需等待）</span>' : 
                        '<span style="color: #dc3545;"><i class="ri-time-line"></i> 已开启冷却限制（接单需要冷却）</span>'
                    }
                </div>
            </div>
            <div class="form-group">
                <label>操作选择</label>
                <select name="cooling_time_limit" required>
                    <option value="">-- 请选择 --</option>
                    <option value="0">解除冷却限制（接单无需等待）</option>
                    <option value="1">开启冷却限制（接单需要冷却）</option>
                </select>
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-primary">确认修改</button>
            </div>
        </form>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    document.getElementById('toggleCoolingLimitForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const coolingTimeLimit = parseInt(formData.get('cooling_time_limit'));
        
        // 输出调试日志到控制台
        console.log('[冷却限制操作]', {
            timestamp: new Date().toLocaleString('zh-CN'),
            user_id: userId,
            current_status: currentStatus,
            new_status: coolingTimeLimit,
            operator: sessionStorage.getItem('admin_username') || 'unknown'
        });
        
        try {
            const apiUrl = `/task_admin/api/c_users/remove-cooling-limit.php`;
            const token = sessionStorage.getItem('admin_token');
            const headers = {
                'Content-Type': 'application/json'
            };
            
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
            
            console.log('[冷却限制请求]', {
                url: apiUrl,
                method: 'POST',
                body: { 
                    user_id: userId,
                    cooling_time_limit: coolingTimeLimit 
                }
            });
            
            const response = await fetch(apiUrl, {
                method: 'POST',
                headers: headers,
                body: JSON.stringify({
                    user_id: userId,
                    cooling_time_limit: coolingTimeLimit
                }),
                credentials: 'include'
            });
            
            console.log('[冷却限制响应]', {
                status: response.status,
                statusText: response.statusText
            });
            
            if (response.status === 401) {
                sessionStorage.clear();
                localStorage.removeItem('admin_current_page');
                fetch('/task_admin/auth/logout.php', { method: 'POST' }).catch(err => {});
                window.location.href = '/task_admin/login.html';
                return;
            }
            
            if (!response.ok) {
                const errorText = await response.text();
                console.error('[冷却限制错误]', {
                    status: response.status,
                    statusText: response.statusText,
                    body: errorText
                });
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            const result = await response.json();
            console.log('[冷却限制结果]', result);
            
            if (result && result.code === 0) {
                const actionText = coolingTimeLimit === 0 ? '解除' : '开启';
                showToast(`${actionText}冷却限制成功`, 'success');
                closeModal();
                loadCUsers();
            } else {
                showToast(result.message || '操作失败', 'error');
            }
        } catch (err) {
            console.error('[冷却限制异常]', err);
            const actionText = coolingTimeLimit === 0 ? '解除' : '开启';
            showToast(`${actionText}失败：` + err.message, 'error');
        }
    });
}
