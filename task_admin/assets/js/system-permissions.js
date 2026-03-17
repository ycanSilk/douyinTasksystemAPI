
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

// 图标映射表
const iconMap = {
    '': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M22 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>',
    'ri-dashboard-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>',
    'ri-group-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>',
    'ri-user-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>',
    'ri-money-cny-circle-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><path d="M12 6v6l4 2"></path><path d="M12 12a6 6 0 0 0 6-6"></path><path d="M12 18a6 6 0 0 1-6-6"></path></svg>',
    'ri-wallet-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline><line x1="12" y1="22.08" x2="12" y2="12"></line></svg>',
    'ri-file-list-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>',
    'ri-store-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 7h-4V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2H4a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2z"></path><path d="M2 15h20"></path><path d="M2 19h20"></path></svg>',
    'ri-bank-card-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"></rect><line x1="2" y1="10" x2="22" y2="10"></line></svg>',
    'ri-user-star-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><line x1="17.5" y1="7" x2="17.51" y2="7"></line><line x1="17.5" y1="15" x2="17.51" y2="15"></line><path d="M20.5 15a2.5 2.5 0 0 0 0-5"></path></svg>',
    'ri-home-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>',
    'ri-clipboard-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="8" y="2" width="8" height="4" rx="1" ry="1"></rect><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"></path></svg>',
    'ri-settings-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>',
    'ri-check-double-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 3v4a1 1 0 0 0 1 1h4"></path><path d="M9 17v-4a1 1 0 0 1 1-1h4"></path><path d="M20 7l-5 5-3-3"></path><path d="m3 17 5-5 3 3"></path></svg>',
    'ri-notification-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.26 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.74 3.86a2 2 0 0 0-3.48 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>',
    'ri-admin-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M15 7h2a2 2 0 0 1 2 2v6a2 2 0 0 1-2 2h-2"></path><path d="M15 7v6"></path></svg>',
    'ri-shield-keyhole-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path><circle cx="12" cy="11" r="1"></circle></svg>',
    'ri-lock-unlock-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>',
    'ri-search-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>',
    'ri-edit-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"></path><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path></svg>',
    'ri-delete-bin-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>',
    'ri-close-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>',
    'ri-check-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>',
    'ri-add-line': '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>'
};

// 获取图标SVG
function getIconSvg(iconClass) {
    return iconMap[iconClass] || iconMap[''];
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
            const iconSvg = getIconSvg(template.icon);
            const editIcon = getIconSvg('ri-edit-line');
            const deleteIcon = getIconSvg('ri-delete-bin-line');
            const toggleIcon = getIconSvg(template.status === 1 ? 'ri-close-line' : 'ri-check-line');
            html += `
                <tr>
                    <td>${template.id}</td>
                    <td><strong>${template.name}</strong></td>
                    <td>${template.code}</td>
                    <td>${iconSvg}</td>
                    <td>${statusBadge}</td>
                    <td>${template.sort_order}</td>
                    <td>${template.parent_level || 1}</td>
                    <td>${template.parent_id || 0}</td>
                    <td>${template.description || '-'}</td>
                    <td>${template.created_at}</td>
                    <td>
                        <button class="btn-info btn-small" onclick='editSystemPermission(${JSON.stringify(template)})'>${editIcon} 编辑</button>
                        <button class="btn-danger btn-small" onclick="deleteSystemPermission(${template.id})")'>${deleteIcon} 删除</button>
                        <button class="btn-${template.status === 1 ? 'warning' : 'success'} btn-small" onclick="togglePermissionTemplateStatus(${template.id}, ${template.status})")'>${toggleIcon} ${template.status === 1 ? '禁用' : '启用'}</button>
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
                    <option value="" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M22 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg></span> 默认图标</option>
                    <option value="ri-dashboard-line" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg></span> 仪表盘</option>
                    <option value="ri-group-line" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg></span> 用户组</option>
                    <option value="ri-user-line" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg></span> 用户</option>
                    <option value="ri-money-cny-circle-line" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><path d="M12 6v6l4 2"></path><path d="M12 12a6 6 0 0 0 6-6"></path><path d="M12 18a6 6 0 0 1-6-6"></path></svg></span> 充值</option>
                    <option value="ri-wallet-line" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline><line x1="12" y1="22.08" x2="12" y2="12"></line></svg></span> 钱包</option>
                    <option value="ri-file-list-line" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg></span> 文件列表</option>
                    <option value="ri-store-line" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 7h-4V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2H4a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2z"></path><path d="M2 15h20"></path><path d="M2 19h20"></path></svg></span> 商店</option>
                    <option value="ri-bank-card-line" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"></rect><line x1="2" y1="10" x2="22" y2="10"></line></svg></span> 银行卡</option>
                    <option value="ri-user-star-line" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><line x1="17.5" y1="7" x2="17.51" y2="7"></line><line x1="17.5" y1="15" x2="17.51" y2="15"></line><path d="M20.5 15a2.5 2.5 0 0 0 0-5"></path></svg></span> 明星用户</option>
                    <option value="ri-home-line" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg></span> 首页</option>
                    <option value="ri-clipboard-line" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="8" y="2" width="8" height="4" rx="1" ry="1"></rect><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"></path></svg></span> 剪贴板</option>
                    <option value="ri-settings-line" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg></span> 设置</option>
                    <option value="ri-check-double-line" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 3v4a1 1 0 0 0 1 1h4"></path><path d="M9 17v-4a1 1 0 0 1 1-1h4"></path><path d="M20 7l-5 5-3-3"></path><path d="m3 17 5-5 3 3"></path></svg></span> 检查</option>
                    <option value="ri-notification-line" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.26 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.74 3.86a2 2 0 0 0-3.48 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg></span> 通知</option>
                    <option value="ri-admin-line" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M15 7h2a2 2 0 0 1 2 2v6a2 2 0 0 1-2 2h-2"></path><path d="M15 7v6"></path></svg></span> 管理员</option>
                    <option value="ri-shield-keyhole-line" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path><circle cx="12" cy="11" r="1"></circle></svg></span> 盾牌</option>
                    <option value="ri-lock-unlock-line" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg></span> 锁</option>
                    <option value="ri-search-line" style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg></span> 搜索</option>
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
                    <option value="" ${template.icon === '' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M22 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg></span> 默认图标</option>
                    <option value="ri-dashboard-line" ${template.icon === 'ri-dashboard-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg></span> 仪表盘</option>
                    <option value="ri-group-line" ${template.icon === 'ri-group-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg></span> 用户组</option>
                    <option value="ri-user-line" ${template.icon === 'ri-user-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg></span> 用户</option>
                    <option value="ri-money-cny-circle-line" ${template.icon === 'ri-money-cny-circle-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><path d="M12 6v6l4 2"></path><path d="M12 12a6 6 0 0 0 6-6"></path><path d="M12 18a6 6 0 0 1-6-6"></path></svg></span> 充值</option>
                    <option value="ri-wallet-line" ${template.icon === 'ri-wallet-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline><line x1="12" y1="22.08" x2="12" y2="12"></line></svg></span> 钱包</option>
                    <option value="ri-file-list-line" ${template.icon === 'ri-file-list-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg></span> 文件列表</option>
                    <option value="ri-store-line" ${template.icon === 'ri-store-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 7h-4V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2H4a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2z"></path><path d="M2 15h20"></path><path d="M2 19h20"></path></svg></span> 商店</option>
                    <option value="ri-bank-card-line" ${template.icon === 'ri-bank-card-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"></rect><line x1="2" y1="10" x2="22" y2="10"></line></svg></span> 银行卡</option>
                    <option value="ri-user-star-line" ${template.icon === 'ri-user-star-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><line x1="17.5" y1="7" x2="17.51" y2="7"></line><line x1="17.5" y1="15" x2="17.51" y2="15"></line><path d="M20.5 15a2.5 2.5 0 0 0 0-5"></path></svg></span> 明星用户</option>
                    <option value="ri-home-line" ${template.icon === 'ri-home-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg></span> 首页</option>
                    <option value="ri-clipboard-line" ${template.icon === 'ri-clipboard-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="8" y="2" width="8" height="4" rx="1" ry="1"></rect><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"></path></svg></span> 剪贴板</option>
                    <option value="ri-settings-line" ${template.icon === 'ri-settings-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg></span> 设置</option>
                    <option value="ri-check-double-line" ${template.icon === 'ri-check-double-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 3v4a1 1 0 0 0 1 1h4"></path><path d="M9 17v-4a1 1 0 0 1 1-1h4"></path><path d="M20 7l-5 5-3-3"></path><path d="m3 17 5-5 3 3"></path></svg></span> 检查</option>
                    <option value="ri-notification-line" ${template.icon === 'ri-notification-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.26 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.74 3.86a2 2 0 0 0-3.48 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg></span> 通知</option>
                    <option value="ri-admin-line" ${template.icon === 'ri-admin-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M15 7h2a2 2 0 0 1 2 2v6a2 2 0 0 1-2 2h-2"></path><path d="M15 7v6"></path></svg></span> 管理员</option>
                    <option value="ri-shield-keyhole-line" ${template.icon === 'ri-shield-keyhole-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path><circle cx="12" cy="11" r="1"></circle></svg></span> 盾牌</option>
                    <option value="ri-lock-unlock-line" ${template.icon === 'ri-lock-unlock-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg></span> 锁</option>
                    <option value="ri-search-line" ${template.icon === 'ri-search-line' ? 'selected' : ''} style="padding-left: 14px; display: flex; align-items: center;"><span style="margin-right: 8px;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg></span> 搜索</option>
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