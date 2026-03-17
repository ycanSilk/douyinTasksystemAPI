// ========== 角色管理 ==========

// 加载角色列表
async function loadSystemRoles() {
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
            renderSystemRolesTable(data.data);
        } else {
            showToast('加载角色列表失败: ' + (data ? data.message : '未知错误'), 'error');
        }
    } catch (err) {
        console.error('加载角色列表失败', err);
        showToast('加载角色列表失败', 'error');
    }
}

// 渲染角色表格
function renderSystemRolesTable(roles) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>角色名称</th>
                    <th>描述</th>
                    <th>状态</th>
                    <th>创建时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    if (roles.length === 0) {
        html += '<tr><td colspan="6" style="text-align: center; padding: 40px; color: #86868b;">暂无数据</td></tr>';
    } else {
        roles.forEach(role => {
            const statusBadge = role.status === 1 ? '<span class="badge badge-success">启用</span>' : '<span class="badge badge-danger">禁用</span>';
            html += `
                <tr>
                    <td>${role.id}</td>
                    <td><strong>${role.name}</strong></td>
                    <td>${role.description || '-'}</td>
                    <td>${statusBadge}</td>
                    <td>${role.created_at}</td>
                    <td>
                        <button class="btn-info btn-small" onclick='editSystemRole(${JSON.stringify(role)})'><i class="ri-edit-line"></i> 编辑</button>
                        <button class="btn-danger btn-small" onclick="deleteSystemRole(${role.id})"><i class="ri-delete-bin-line"></i> 删除</button>
                        <button class="btn-secondary btn-small" onclick="configureRolePermissions(${role.id}, '${role.name}')"><i class="ri-lock-line"></i> 权限</button>
                    </td>
                </tr>
            `;
        });
    }
    
    html += '</tbody></table></div>';
    document.getElementById('systemRolesTable').innerHTML = html;
}

// 新增角色
function addSystemRole() {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-add-line"></i> 新增角色</h3>
        <form id="addSystemRoleForm">
            <div class="form-group">
                <label>角色名称</label>
                <input type="text" name="name" placeholder="角色名称" required>
            </div>
            <div class="form-group">
                <label>描述</label>
                <textarea name="description" placeholder="角色描述"></textarea>
            </div>
            <div class="form-group">
                <label>状态</label>
                <select name="status">
                    <option value="1">启用</option>
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
    
    document.getElementById('addSystemRoleForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const data = {};
        
        for (const [key, value] of formData.entries()) {
            if (value !== '') {
                data[key] = value;
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
            
            const response = await fetch('/task_admin/api/system_roles/create.php', {
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
                loadSystemRoles();
            } else {
                showToast(result ? result.message : '创建失败', 'error');
            }
        } catch (err) {
            showToast('创建失败', 'error');
        }
    });
}

// 编辑角色
function editSystemRole(role) {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-edit-line"></i> 编辑角色 #${role.id}</h3>
        <form id="editSystemRoleForm">
            <input type="hidden" name="id" value="${role.id}">
            <div class="form-group">
                <label>角色名称</label>
                <input type="text" name="name" value="${role.name}" placeholder="角色名称" required>
            </div>
            <div class="form-group">
                <label>描述</label>
                <textarea name="description" placeholder="角色描述">${role.description || ''}</textarea>
            </div>
            <div class="form-group">
                <label>状态</label>
                <select name="status">
                    <option value="1" ${role.status === 1 ? 'selected' : ''}>启用</option>
                    <option value="0" ${role.status === 0 ? 'selected' : ''}>禁用</option>
                </select>
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-primary">保存</button>
            </div>
        </form>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    document.getElementById('editSystemRoleForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const data = {};
        
        // 确保ID始终被传递，并且转换为数字类型
        data.role_id = Number(role.id);
        
        for (const [key, value] of formData.entries()) {
            if (value !== '') {
                // 转换状态为数字类型
                if (key === 'status') {
                    data[key] = Number(value);
                } else if (key === 'id') {
                    // 忽略表单中的id字段，使用role_id
                } else {
                    data[key] = value;
                }
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
            
            const response = await fetch('/task_admin/api/system_roles/update.php', {
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
                loadSystemRoles();
            } else {
                showToast(result ? result.message : '更新失败', 'error');
            }
        } catch (err) {
            console.error('更新请求失败:', err);
            showToast('更新失败', 'error');
        }
    });
}

// 删除角色
function deleteSystemRole(role_id) {
    showConfirm('确定要删除该角色吗？删除后，该角色下的用户将无法登录系统。', async () => {
        try {
            const token = sessionStorage.getItem('admin_token');
            const headers = {
                'Content-Type': 'application/json'
            };
            
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
            
            const response = await fetch('/task_admin/api/system_roles/delete.php', {
                method: 'POST',
                headers: headers,
                credentials: 'include',
                body: JSON.stringify({ role_id })
            });
            
            if (!response.ok) {
                throw new Error('网络响应错误');
            }
            
            const result = await response.json();
            
            if (result && result.code === 0) {
                showToast('删除成功', 'success');
                loadSystemRoles();
            } else {
                showToast(result ? result.message : '删除失败', 'error');
            }
        } catch (err) {
            showToast('删除失败', 'error');
        }
    });
}

// 配置角色权限
function configureRolePermissions(roleId, roleName) {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-lock-line"></i> 配置角色权限 - ${roleName}</h3>
        <form id="configurePermissionsForm">
            <input type="hidden" name="role_id" value="${roleId}">
            <div id="permissionsList" style="max-height: 400px; overflow-y: auto; margin-bottom: 20px;"></div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-primary">保存</button>
            </div>
        </form>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    // 加载权限模板列表
    loadPermissionTemplatesForRole(roleId);
    
    document.getElementById('configurePermissionsForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const data = {
            role_id: parseInt(formData.get('role_id')),
            template_ids: []
        };
        
        // 收集选中的权限模板
        const checkboxes = document.querySelectorAll('input[name="template_id"]:checked');
        checkboxes.forEach(checkbox => {
            data.template_ids.push(parseInt(checkbox.value));
        });
        
        console.log('权限配置数据:', data);
        
        try {
            const token = sessionStorage.getItem('admin_token');
            const headers = {
                'Content-Type': 'application/json'
            };
            
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
            
            console.log('请求头:', headers);
            
            const response = await fetch('/task_admin/api/system_permission_template/role_permissions.php', {
                method: 'POST',
                headers: headers,
                credentials: 'include',
                body: JSON.stringify(data)
            });
            
            console.log('API响应状态:', response.status);
            
            if (!response.ok) {
                throw new Error(`网络响应错误: ${response.status}`);
            }
            
            const result = await response.json();
            console.log('API返回数据:', result);
            
            if (result && result.code === 0) {
                showToast('权限配置成功', 'success');
                closeModal();
            } else {
                showToast(result ? result.message : '权限配置失败', 'error');
            }
        } catch (err) {
            console.error('权限配置失败:', err);
            showToast('权限配置失败', 'error');
        }
    });
}

// 加载角色权限模板
async function loadPermissionTemplatesForRole(roleId) {
    try {
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const [templatesResponse, roleTemplatesResponse] = await Promise.all([
            fetch('/task_admin/api/system_permission_template/list.php', {
                method: 'GET',
                headers: headers,
                credentials: 'include'
            }),
            fetch(`/task_admin/api/system_permission_template/role_permissions_get.php?role_id=${roleId}`, {
                method: 'GET',
                headers: headers,
                credentials: 'include'
            })
        ]);
        
        if (!templatesResponse.ok || !roleTemplatesResponse.ok) {
            throw new Error('网络响应错误');
        }
        
        const templatesData = await templatesResponse.json();
        const roleTemplatesData = await roleTemplatesResponse.json();
        
        if (templatesData && templatesData.code === 0 && roleTemplatesData && roleTemplatesData.code === 0) {
            const permissionsList = document.getElementById('permissionsList');
            let html = '<div class="permission-groups">';
            
            // 按 parent_id 分组模板
            const templateMap = {};
            const level1Templates = [];
            
            templatesData.data.forEach(template => {
                if (!templateMap[template.parent_id]) {
                    templateMap[template.parent_id] = [];
                }
                templateMap[template.parent_id].push(template);
                if ((template.parent_level || 1) === 1) {
                    level1Templates.push(template);
                }
            });
            
            // 生成权限模板列表
            html += '<div class="permission-group">';
            html += '<h4>导航栏面板</h4>';
            html += '<div class="permission-items">';
            
            // 渲染一级导航
            level1Templates.forEach(template => {
                const isChecked = roleTemplatesData.data.includes(template.id);
                html += `
                    <div class="permission-item">
                        <input type="checkbox" id="template_${template.id}" name="template_id" value="${template.id}" ${isChecked ? 'checked' : ''}>
                        <label for="template_${template.id}">${template.name} (${template.code})</label>
                        <span class="permission-desc">${template.description || '-'}</span>
                    </div>
                `;
                
                // 渲染二级导航
                const childTemplates = templateMap[template.id] || [];
                if (childTemplates.length > 0) {
                    html += '<div class="permission-sub-items">';
                    childTemplates.forEach(childTemplate => {
                        const childIsChecked = roleTemplatesData.data.includes(childTemplate.id);
                        html += `
                            <div class="permission-sub-item">
                                <input type="checkbox" id="template_${childTemplate.id}" name="template_id" value="${childTemplate.id}" ${childIsChecked ? 'checked' : ''}>
                                <label for="template_${childTemplate.id}">${childTemplate.name} (${childTemplate.code})</label>
                                <span class="permission-desc">${childTemplate.description || '-'}</span>
                            </div>
                        `;
                    });
                    html += '</div>';
                }
            });
            
            html += '</div></div>';
            html += '</div>';
            permissionsList.innerHTML = html;
        }
    } catch (err) {
        console.error('加载权限模板列表失败', err);
    }
}