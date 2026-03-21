// ========== 系统用户管理 ==========

// 加载系统用户列表
async function loadSystemUsers() {
    try {
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const response = await fetch('/task_admin/api/system_users/list.php', {
            method: 'GET',
            headers: headers,
            credentials: 'include'
        });
        
        if (!response.ok) {
            throw new Error('网络响应错误');
        }
        
        const data = await response.json();
        
        if (data && data.code === 0) {
            renderSystemUsersTable(data.data);
        } else {
            showToast('加载系统用户失败: ' + (data ? data.message : '未知错误'), 'error');
        }
    } catch (err) {
        console.error('加载系统用户失败', err);
        showToast('加载系统用户失败', 'error');
    }
}

// 渲染系统用户表格
function renderSystemUsersTable(users) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>用户名</th>
                    <th>邮箱</th>
                    <th>手机号</th>
                    <th>角色</th>
                    <th>状态</th>
                    <th>最后登录</th>
                    <th>创建时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    if (users.length === 0) {
        html += '<tr><td colspan="9" style="text-align: center; padding: 40px; color: #86868b;">暂无数据</td></tr>';
    } else {
        users.forEach(user => {
            const statusBadge = user.status === 1 ? '<span class="badge badge-success">正常</span>' : '<span class="badge badge-danger">禁用</span>';
            html += `
                <tr>
                    <td>${user.id}</td>
                    <td><strong>${user.username}</strong></td>
                    <td>${user.email}</td>
                    <td>${user.phone || '-'}</td>
                    <td>${user.role_name}</td>
                    <td>${statusBadge}</td>
                    <td>${user.last_login_at || '-'}</td>
                    <td>${user.created_at}</td>
                    <td>
                        <button class="btn-info btn-small" onclick='editSystemUser(${JSON.stringify(user)})'><i class="ri-edit-line"></i> 编辑</button>
                        <button class="btn-danger btn-small" onclick="deleteSystemUser(${user.id})"><i class="ri-delete-bin-line"></i> 删除</button>
                        <button class="btn-secondary btn-small" onclick="changeSystemUserPassword(${user.id}, '${user.username}')"><i class="ri-key-2-line"></i> 改密</button>
                    </td>
                </tr>
            `;
        });
    }
    
    html += '</tbody></table></div>';
    document.getElementById('systemUsersTable').innerHTML = html;
}

// 新增系统用户
function addSystemUser() {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-add-line"></i> 新增系统用户</h3>
        <form id="addSystemUserForm">
            <div class="form-group">
                <label>用户名</label>
                <input type="text" name="username" placeholder="用户名" required>
            </div>
            <div class="form-group">
                <label>密码</label>
                <input type="password" name="password" placeholder="密码" required>
            </div>
            <div class="form-group">
                <label>邮箱（选填）</label>
                <input type="email" name="email" placeholder="邮箱">
            </div>
            <div class="form-group">
                <label>手机号</label>
                <input type="text" name="phone" placeholder="手机号">
            </div>
            <div class="form-group">
                <label>角色</label>
                <select name="role_id" id="roleSelect" required></select>
            </div>
            <div class="form-group">
                <label>状态</label>
                <select name="status" required>
                    <option value="1">正常</option>
                    <option value="0">禁用</option>
                </select>
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-primary">创建</button>
            </div>
        </form>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    // 加载角色列表
    loadRolesForSelect('roleSelect');
    
    document.getElementById('addSystemUserForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const data = {};
        
        for (const [key, value] of formData.entries()) {
            if (value !== '') {
                if (key === 'password') {
                    // 使用MD5哈希加密密码
                    data[key] = md5(value);
                } else {
                    data[key] = value;
                }
            }
        }
        
        // 表单校验
        if (!data.username || data.username.length < 4) {
            showToast('用户名长度不得少于4个字符', 'error');
            return;
        }
        
        if (!data.password) {
            showToast('密码不能为空', 'error');
            return;
        }
        
        if (!data.role_id) {
            showToast('请选择角色', 'error');
            return;
        }
        
        if (!data.status) {
            showToast('请选择状态', 'error');
            return;
        }
        
        // 邮箱校验（非必填，但如果填写了需要检查格式）
        if (data.email) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(data.email)) {
                showToast('邮箱格式不正确', 'error');
                return;
            }
        }
        
        // 手机号校验
        if (data.phone) {
            const phoneRegex = /^1[3-9]\d{9}$/;
            if (!phoneRegex.test(data.phone)) {
                showToast('手机号格式不正确', 'error');
                return;
            }
        }
        
        try {
            const token = sessionStorage.getItem('admin_token');
            const headers = {
                'Content-Type': 'application/json'
            };
            
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
            
            const response = await fetch('/task_admin/api/system_users/create.php', {
                method: 'POST',
                headers: headers,
                credentials: 'include',
                body: JSON.stringify(data)
            });
            
            if (!response.ok) {
                throw new Error('网络响应错误');
            }
            
            const result = await response.json();
            
            if (result && result.code === 0) {
                showToast('创建成功', 'success');
                closeModal();
                loadSystemUsers();
            } else {
                showToast(result ? result.message : '创建失败', 'error');
            }
        } catch (err) {
            showToast('创建失败', 'error');
        }
    });
}

// 编辑系统用户
function editSystemUser(user) {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-edit-line"></i> 编辑系统用户 #${user.id}</h3>
        <form id="editSystemUserForm">
            <input type="hidden" name="id" value="${user.id}">
            <div class="form-group">
                <label>用户名（不可修改）</label>
                <input type="text" value="${user.username}" disabled>
            </div>
            <div class="form-group">
                <label>邮箱</label>
                <input type="email" name="email" value="${user.email}" placeholder="邮箱">
            </div>
            <div class="form-group">
                <label>手机号</label>
                <input type="text" name="phone" value="${user.phone || ''}" placeholder="手机号">
            </div>
            <div class="form-group">
                <label>角色</label>
                <select name="role_id" id="editRoleSelect" required></select>
            </div>
            <div class="form-group">
                <label>状态</label>
                <select name="status" required>
                    <option value="1" ${user.status === 1 ? 'selected' : ''}>正常</option>
                    <option value="0" ${user.status === 0 ? 'selected' : ''}>禁用</option>
                </select>
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-primary">保存</button>
            </div>
        </form>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    // 加载角色列表并设置当前角色
    loadRolesForSelect('editRoleSelect', user.role_id);
    
    document.getElementById('editSystemUserForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const data = {};
        
        // 确保ID始终被传递，并且转换为数字类型
        data.user_id = Number(user.id);
        
        // 提取所有表单数据，包括空值
        for (const [key, value] of formData.entries()) {
            // 转换ID和角色ID为数字类型
            if (key === 'role_id' || key === 'status') {
                data[key] = Number(value);
            } else if (key === 'id') {
                // 忽略表单中的id字段，使用user_id
            } else {
                data[key] = value;
            }
        }
        
        
        // 表单校验
        if (!data.role_id || data.role_id === 0) {
            showToast('请选择角色', 'error');
            return;
        }
        
        if (!data.status && data.status !== 0) {
            showToast('请选择状态', 'error');
            return;
        }
        
        // 手机号校验
        if (data.phone) {
            const phoneRegex = /^1[3-9]\d{9}$/;
            if (!phoneRegex.test(data.phone)) {
                showToast('手机号格式不正确', 'error');
                return;
            }
        }
        
        
        try {
            const token = sessionStorage.getItem('admin_token');
            const headers = {
                'Content-Type': 'application/json'
            };
            
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
            
            const response = await fetch('/task_admin/api/system_users/update.php', {
                method: 'POST',
                headers: headers,
                credentials: 'include',
                body: JSON.stringify(data)
            });
            
            if (!response.ok) {
                throw new Error('网络响应错误');
            }
            
            const result = await response.json();
            
            if (result && result.code === 0) {
                showToast('更新成功', 'success');
                closeModal();
                loadSystemUsers();
            } else {
                showToast(result ? result.message : '更新失败', 'error');
            }
        } catch (err) {
            console.error('更新请求失败:', err);
            showToast('更新失败', 'error');
        }
    });
}

// 删除系统用户
function deleteSystemUser(id) {
    showConfirm('确定要删除该系统用户吗？', async () => {
        try {
            const token = sessionStorage.getItem('admin_token');
            const headers = {
                'Content-Type': 'application/json'
            };
            
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
            
            const response = await fetch('/task_admin/api/system_users/delete.php', {
                method: 'POST',
                headers: headers,
                credentials: 'include',
                body: JSON.stringify({ id })
            });
            
            if (!response.ok) {
                throw new Error('网络响应错误');
            }
            
            const result = await response.json();
            
            if (result && result.code === 0) {
                showToast('删除成功', 'success');
                loadSystemUsers();
            } else {
                showToast(result ? result.message : '删除失败', 'error');
            }
        } catch (err) {
            showToast('删除失败', 'error');
        }
    });
}

// 修改系统用户密码
function changeSystemUserPassword(user_id, username) {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-key-2-line"></i> 修改密码 - ${username}</h3>
        <form id="changePasswordForm">
            <input type="hidden" name="id" value="${user_id}">
            <div class="form-group">
                <label>新密码</label>
                <input type="password" name="password" placeholder="新密码" required>
            </div>
            <div class="form-group">
                <label>确认新密码</label>
                <input type="password" name="confirm_password" placeholder="确认新密码" required>
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-primary">修改</button>
            </div>
        </form>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    document.getElementById('changePasswordForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const data = {};
        
        let password = '';
        let confirmPassword = '';
        
        for (const [key, value] of formData.entries()) {
            if (value !== '') {
                if (key === 'id') {
                    data.user_id = Number(value);
                } else if (key === 'password') {
                    // 使用MD5哈希加密密码
                    data.new_password = md5(value);
                    password = value;
                } else if (key === 'confirm_password') {
                    confirmPassword = value;
                } else {
                    data[key] = value;
                }
            }
        }
        
        if (!data.new_password) {
            showToast('新密码不能为空', 'error');
            return;
        }
        
        if (password !== confirmPassword) {
            showToast('两次输入的密码不一致', 'error');
            return;
        }
        try {
            const token = sessionStorage.getItem('admin_token');
            const headers = {
                'Content-Type': 'application/json'
            };
            
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
            
            const response = await fetch('/task_admin/api/system_users/change-password.php', {
                method: 'POST',
                headers: headers,
                credentials: 'include',
                body: JSON.stringify(data)
            });
            
            if (!response.ok) {
                throw new Error('网络响应错误');
            }
            
            const result = await response.json();
            
            if (result && result.code === 0) {
                showToast('密码修改成功', 'success');
                closeModal();
            } else {
                showToast(result ? result.message : '密码修改失败', 'error');
            }
        } catch (err) {
            showToast('密码修改失败', 'error');
        }
    });
}

// 加载角色列表用于下拉选择
async function loadRolesForSelect(selectId, selectedRoleId = null) {
    try {
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const response = await fetch('/task_admin/api/system_roles/list.php', {
            method: 'GET',
            headers: headers,
            credentials: 'include'
        });
        
        if (!response.ok) {
            throw new Error('网络响应错误');
        }
        
        const data = await response.json();
        
        if (data && data.code === 0) {
            const select = document.getElementById(selectId);
            select.innerHTML = '';
            
            data.data.forEach(role => {
                const option = document.createElement('option');
                option.value = role.id;
                option.textContent = role.name;
                // 使用严格相等比较，并确保类型一致
                if (selectedRoleId && String(role.id) === String(selectedRoleId)) {
                    option.selected = true;
                }
                select.appendChild(option);
            });
            
        }
    } catch (err) {
        console.error('加载角色列表失败', err);
    }
}