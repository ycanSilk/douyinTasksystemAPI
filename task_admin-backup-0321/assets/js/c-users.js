// C端用户管理相关功能

// 加载C端用户列表
async function loadCUsers(page = 1) {
    const search = document.getElementById('cUserSearch').value;
    try {
        const apiUrl = `/task_admin/api/c_users/list.php?page=${page}&search=${encodeURIComponent(search)}`;
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
        console.error('加载C端用户失败', err);
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
                    <th>注册时间</th>
                    <th>  操作按钮  </th>
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
                <td>
                    <button class="btn-info btn-small" onclick='editCUser(${JSON.stringify(u)})' style="margin-bottom: 3px;">编辑</button>
                    ${u.blocked_status > 0 ? 
                        `<button class="btn-success btn-small" onclick='unblockUser(${u.id})'> 解禁</button>` : 
                        `<button class="btn-info btn-small" onclick='blockUser(${JSON.stringify(u)})'> 封禁</button>`
                    }
                </td>
            </tr>
        `;
    });
    
    html += '</tbody></table></div>';
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
