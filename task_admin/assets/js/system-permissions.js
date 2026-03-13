
// 加载权限模板列表
async function loadSystemPermissions() {
    try {
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const response = await fetch('/task_admin/api/system_permission_template/list.php?all=1', {
            method: 'GET',
            headers: headers,
            credentials: 'include'
        });
        
        if (!response.ok) {
            throw new Error('网络响应错误');
        }
        
        const data = await response.json();
        
        if (data && data.code === 0) {
            renderSystemPermissionsTable(data.data);
        } else {
            showToast('加载权限模板列表失败: ' + (data ? data.message : '未知错误'), 'error');
        }
    } catch (err) {
        console.error('加载权限模板列表失败', err);
        showToast('加载权限模板列表失败', 'error');
    }
}

// 渲染权限模板表格
function renderSystemPermissionsTable(templates) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>导航名称</th>
                    <th>导航代码</th>
                    <th>图标</th>
                    <th>状态</th>
                    <th>排序</th>
                    <th>层级</th>
                    <th>父级ID</th>
                    <th>描述</th>
                    <th>创建时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    if (templates.length === 0) {
        html += '<tr><td colspan="9" style="text-align: center; padding: 40px; color: #86868b;">暂无数据</td></tr>';
    } else {
        templates.forEach(template => {
            const statusBadge = template.status === 1 ? '<span class="badge badge-success">启用</span>' : '<span class="badge badge-danger">禁用</span>';
            html += `
                <tr>
                    <td>${template.id}</td>
                    <td><strong>${template.name}</strong></td>
                    <td>${template.code}</td>
                    <td><i class="${template.icon}"></i></td>
                    <td>${statusBadge}</td>
                    <td>${template.sort_order}</td>
                    <td>${template.parent_level || 1}</td>
                    <td>${template.parent_id || 0}</td>
                    <td>${template.description || '-'}</td>
                    <td>${template.created_at}</td>
                    <td>
                        <button class="btn-info btn-small" onclick='editSystemPermission(${JSON.stringify(template)})'><i class="ri-edit-line"></i> 编辑</button>
                        <button class="btn-danger btn-small" onclick="deleteSystemPermission(${template.id})"><i class="ri-delete-bin-line"></i> 删除</button>
                        <button class="btn-${template.status === 1 ? 'warning' : 'success'} btn-small" onclick="togglePermissionTemplateStatus(${template.id}, ${template.status})"><i class="ri-${template.status === 1 ? 'close' : 'check'}-line"></i> ${template.status === 1 ? '禁用' : '启用'}</button>
                    </td>
                </tr>
            `;
        });
    }
    
    html += '</tbody></table></div>';
    document.getElementById('systemPermissionsTable').innerHTML = html;
}

// 新增权限模板
function addSystemPermission() {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-add-line"></i> 新增导航面板</h3>
        <form id="addSystemPermissionForm">
            <div class="form-group">
                <label>导航名称</label>
                <input type="text" name="name" placeholder="导航名称" required>
            </div>
            <div class="form-group">
                <label>导航代码</label>
                <input type="text" name="code" placeholder="导航代码" required>
            </div>
            <div class="form-group">
                <label>图标</label>
                <select name="icon" placeholder="选择图标" style="padding-left: 40px; width: 100%; font-family: 'Remix Icon', sans-serif;">
                    <option value="" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><i class="ri-user-3-line"></i></span> 默认图标</option>
                    <option value="ri-dashboard-line" style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-user-3-line"></i> 仪表盘</option>
                    <option value="ri-group-line" style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-user-3-line"></i> 用户组</option>
                    <option value="ri-user-line" style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-user-line" style="margin-right: 8px;"></i> 用户</option>
                    <option value="ri-money-cny-circle-line" style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-money-cny-circle-line" style="margin-right: 8px;"></i> 充值</option>
                    <option value="ri-wallet-line" style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-wallet-line" style="margin-right: 8px;"></i> 钱包</option>
                    <option value="ri-file-list-line" style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-file-list-line" style="margin-right: 8px;"></i> 文件列表</option>
                    <option value="ri-store-line" style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-store-line" style="margin-right: 8px;"></i> 商店</option>
                    <option value="ri-bank-card-line" style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-bank-card-line" style="margin-right: 8px;"></i> 银行卡</option>
                    <option value="ri-user-star-line" style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-user-star-line" style="margin-right: 8px;"></i> 明星用户</option>
                    <option value="ri-home-line" style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-home-line" style="margin-right: 8px;"></i> 首页</option>
                    <option value="ri-clipboard-line" style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-clipboard-line" style="margin-right: 8px;"></i> 剪贴板</option>
                    <option value="ri-settings-line" style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-settings-line" style="margin-right: 8px;"></i> 设置</option>
                    <option value="ri-check-double-line" style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-check-double-line" style="margin-right: 8px;"></i> 检查</option>
                    <option value="ri-notification-line" style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-notification-line" style="margin-right: 8px;"></i> 通知</option>
                    <option value="ri-admin-line" style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-admin-line" style="margin-right: 8px;"></i> 管理员</option>
                    <option value="ri-shield-keyhole-line" style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-shield-keyhole-line" style="margin-right: 8px;"></i> 盾牌</option>
                    <option value="ri-lock-unlock-line" style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-lock-unlock-line" style="margin-right: 8px;"></i> 锁</option>
                    <option value="ri-search-line" style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-search-line" style="margin-right: 8px;"></i> 搜索</option>
                </select>
            </div>
            <div class="form-group">
                <label>排序</label>
                <input type="number" name="sort_order" value="0" placeholder="排序值" required>
            </div>
            <div class="form-group">
                <label>状态</label>
                <select name="status">
                    <option value="1">启用</option>
                    <option value="0">禁用</option>
                </select>
            </div>
            <div class="form-group">
                <label>描述</label>
                <textarea name="description" placeholder="导航描述"></textarea>
            </div>
            <div class="form-group">
                <label>层级</label>
                <select name="parent_level">
                    <option value="1">一级导航</option>
                    <option value="2">二级导航</option>
                </select>
            </div>
            <div class="form-group">
                <label>父级ID</label>
                <input type="number" name="parent_id" value="0" placeholder="父级导航ID，一级导航为0">
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-primary">创建</button>
            </div>
        </form>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    document.getElementById('addSystemPermissionForm').addEventListener('submit', async (e) => {
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
            
            const response = await fetch('/task_admin/api/system_permission_template/create.php', {
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
                loadSystemPermissions();
            } else {
                showToast(result ? result.message : '创建失败', 'error');
            }
        } catch (err) {
            showToast('创建失败', 'error');
        }
    });
}

// 编辑权限模板
function editSystemPermission(template) {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-edit-line"></i> 编辑导航面板 #${template.id}</h3>
        <form id="editSystemPermissionForm">
            <input type="hidden" name="id" value="${template.id}">
            <div class="form-group">
                <label>导航名称</label>
                <input type="text" name="name" value="${template.name}" placeholder="导航名称" required>
            </div>
            <div class="form-group">
                <label>导航代码</label>
                <input type="text" name="code" value="${template.code}" placeholder="导航代码" required>
            </div>
            <div class="form-group">
                <label>图标</label>
                <select name="icon" placeholder="选择图标" style="padding-left: 40px; width: 100%; font-family: 'Remix Icon', sans-serif;">
                    <option value="" ${template.icon === '' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;">默认图标</option>
                    <option value="ri-dashboard-line" ${template.icon === 'ri-dashboard-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-dashboard-line" style="margin-right: 8px;"></i> 仪表盘</option>
                    <option value="ri-group-line" ${template.icon === 'ri-group-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-group-line" style="margin-right: 8px;"></i> 用户组</option>
                    <option value="ri-user-line" ${template.icon === 'ri-user-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-user-line" style="margin-right: 8px;"></i> 用户</option>
                    <option value="ri-money-cny-circle-line" ${template.icon === 'ri-money-cny-circle-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-money-cny-circle-line" style="margin-right: 8px;"></i> 充值</option>
                    <option value="ri-wallet-line" ${template.icon === 'ri-wallet-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-wallet-line" style="margin-right: 8px;"></i> 钱包</option>
                    <option value="ri-file-list-line" ${template.icon === 'ri-file-list-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-file-list-line" style="margin-right: 8px;"></i> 文件列表</option>
                    <option value="ri-store-line" ${template.icon === 'ri-store-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-store-line" style="margin-right: 8px;"></i> 商店</option>
                    <option value="ri-bank-card-line" ${template.icon === 'ri-bank-card-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-bank-card-line" style="margin-right: 8px;"></i> 银行卡</option>
                    <option value="ri-user-star-line" ${template.icon === 'ri-user-star-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-user-star-line" style="margin-right: 8px;"></i> 明星用户</option>
                    <option value="ri-home-line" ${template.icon === 'ri-home-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-home-line" style="margin-right: 8px;"></i> 首页</option>
                    <option value="ri-clipboard-line" ${template.icon === 'ri-clipboard-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-clipboard-line" style="margin-right: 8px;"></i> 剪贴板</option>
                    <option value="ri-settings-line" ${template.icon === 'ri-settings-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-settings-line" style="margin-right: 8px;"></i> 设置</option>
                    <option value="ri-check-double-line" ${template.icon === 'ri-check-double-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-check-double-line" style="margin-right: 8px;"></i> 检查</option>
                    <option value="ri-notification-line" ${template.icon === 'ri-notification-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-notification-line" style="margin-right: 8px;"></i> 通知</option>
                    <option value="ri-admin-line" ${template.icon === 'ri-admin-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-admin-line" style="margin-right: 8px;"></i> 管理员</option>
                    <option value="ri-shield-keyhole-line" ${template.icon === 'ri-shield-keyhole-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-shield-keyhole-line" style="margin-right: 8px;"></i> 盾牌</option>
                    <option value="ri-lock-unlock-line" ${template.icon === 'ri-lock-unlock-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-lock-unlock-line" style="margin-right: 8px;"></i> 锁</option>
                    <option value="ri-search-line" ${template.icon === 'ri-search-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><i class="ri-search-line" style="margin-right: 8px;"></i> 搜索</option>
                </select>
            </div>
            <div class="form-group">
                <label>排序</label>
                <input type="number" name="sort_order" value="${template.sort_order}" placeholder="排序值" required>
            </div>
            <div class="form-group">
                <label>状态</label>
                <select name="status">
                    <option value="1" ${template.status === 1 ? 'selected' : ''}>启用</option>
                    <option value="0" ${template.status === 0 ? 'selected' : ''}>禁用</option>
                </select>
            </div>
            <div class="form-group">
                <label>描述</label>
                <textarea name="description" placeholder="导航描述">${template.description || ''}</textarea>
            </div>
            <div class="form-group">
                <label>层级</label>
                <select name="parent_level">
                    <option value="1" ${(template.parent_level || 1) === 1 ? 'selected' : ''}>一级导航</option>
                    <option value="2" ${(template.parent_level || 1) === 2 ? 'selected' : ''}>二级导航</option>
                </select>
            </div>
            <div class="form-group">
                <label>父级ID</label>
                <input type="number" name="parent_id" value="${template.parent_id || 0}" placeholder="父级导航ID，一级导航为0">
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-primary">保存</button>
            </div>
        </form>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    document.getElementById('editSystemPermissionForm').addEventListener('submit', async (e) => {
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
            
            const response = await fetch('/task_admin/api/system_permission_template/update.php', {
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
                loadSystemPermissions();
            } else {
                showToast(result ? result.message : '更新失败', 'error');
            }
        } catch (err) {
            showToast('更新失败', 'error');
        }
    });
}

// 删除权限模板
function deleteSystemPermission(id) {
    showConfirm('确定要删除该导航面板吗？删除后，所有角色的该权限将被移除。', async () => {
        try {
            const token = sessionStorage.getItem('admin_token');
            const headers = {
                'Content-Type': 'application/json'
            };
            
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
            
            const response = await fetch('/task_admin/api/system_permission_template/delete.php', {
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
                loadSystemPermissions();
            } else {
                showToast(result ? result.message : '删除失败', 'error');
            }
        } catch (err) {
            showToast('删除失败', 'error');
        }
    });
}

// 切换权限模板状态
function togglePermissionTemplateStatus(id, currentStatus) {
    const newStatus = currentStatus === 1 ? 0 : 1;
    const actionText = newStatus === 1 ? '启用' : '禁用';
    
    showConfirm(`确定要${actionText}该导航面板吗？`, async () => {
        try {
            const token = sessionStorage.getItem('admin_token');
            const headers = {
                'Content-Type': 'application/json'
            };
            
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
            
            const response = await fetch('/task_admin/api/system_permission_template/update.php', {
                method: 'POST',
                headers: headers,
                credentials: 'include',
                body: JSON.stringify({ id, status: newStatus })
            });
            
            if (!response.ok) {
                throw new Error('网络响应错误');
            }
            
            const result = await response.json();
            
            if (result && result.code === 0) {
                showToast(`${actionText}成功`, 'success');
                loadSystemPermissions();
            } else {
                showToast(result ? result.message : `${actionText}失败`, 'error');
            }
        } catch (err) {
            showToast(`${actionText}失败`, 'error');
        }
    });
}