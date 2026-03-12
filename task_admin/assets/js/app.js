// API基础URL
const API_BASE = '/task_admin';

// 全局状态
let currentUser = null;

// 通知中心相关变量
let notificationPage = 1;
let notificationTotalPages = 1;
let currentNotificationType = '';
let currentNotificationStatus = '';

// 通知检测日志相关变量
let logPage = 1;
let logTotalPages = 1;

// 日志存储
const LOG_STORAGE_KEY = 'task_admin_logs';
const MAX_LOGS = 1000;

// 日志目录
const LOG_DIR = 'task_admin/logs';

// 获取当前时间戳（精确到毫秒）
function getTimestamp() {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const seconds = String(now.getSeconds()).padStart(2, '0');
    const milliseconds = String(now.getMilliseconds()).padStart(3, '0');
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}.${milliseconds}`;
}

// 格式化日志消息
function formatLog(level, message, module = 'SYSTEM') {
    const timestamp = getTimestamp();
    const logMessage = `[${timestamp}] [${level}] [${module}] ${message}`;
    return {
        timestamp,
        level,
        module,
        message,
        formatted: logMessage,
        timestampISO: new Date().toISOString()
    };
}

// 保存日志到本地存储
function saveLogToStorage(log) {
    try {
        const logs = JSON.parse(localStorage.getItem(LOG_STORAGE_KEY) || '[]');
        logs.push(log);
        if (logs.length > MAX_LOGS) {
            logs.shift(); // 移除最旧的日志
        }
        localStorage.setItem(LOG_STORAGE_KEY, JSON.stringify(logs));
    } catch (error) {
        console.error('保存日志到本地存储失败:', error);
    }
}

// 输出日志
function log(level, message, module = 'SYSTEM') {
    const log = formatLog(level, message, module);
    saveLogToStorage(log);
    return log;
}

// 持久化日志到文件
async function persistLogToFile(log) {
    try {
        const logData = {
            ...log,
            timestamp: new Date().toISOString()
        };
        
        await apiRequest(`${API_BASE}/api/logs/save.php`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(logData)
        });
    } catch (error) {
        console.error('持久化日志到文件失败:', error);
    }
}



// 增强的showToast函数，带日志记录
function showToast(message, type = 'info') {
    // 记录系统提示信息到日志
    log(type.toUpperCase(), message, 'UI');
    
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





// 带认证的API请求
async function apiRequest(url, options = {}) {
    const token = sessionStorage.getItem('admin_token');
    
    // 添加时间戳参数以避免浏览器缓存
    if (url.includes('?')) {
        url += `&t=${Date.now()}`;
    } else {
        url += `?t=${Date.now()}`;
    }
    
    // 设置默认选项
    const defaultOptions = {
        headers: {
            'Content-Type': 'application/json'
        }
    };
    
    // 合并选项
    const mergedOptions = {
        ...defaultOptions,
        ...options,
        headers: {
            ...defaultOptions.headers,
            ...options.headers
        }
    };
    
    // 添加token到请求头
    if (token) {
        mergedOptions.headers['Authorization'] = `Bearer ${token}`;
    }
    
    try {
        const response = await fetch(url, mergedOptions);
        
        // 处理未授权错误
        if (response.status === 401) {
            // 清除登录状态
            sessionStorage.clear();
            localStorage.removeItem('admin_current_page'); // 清除页面记忆
            
            // 尝试调用logout接口（可选）
            fetch(`${API_BASE}/auth/logout.php`, { method: 'POST' }).catch(err => {});
            
            // 重定向到登录页面
            window.location.href = `${API_BASE}/login.html`;
            
            // 返回错误对象
            return { code: 401, message: '登录已过期' };
        }
        
        // 尝试解析JSON
        try {
            const data = await response.json();
            
            // 检查响应中的code字段
            if (data.code === 401) {
                // 清除登录状态
                sessionStorage.clear();
                localStorage.removeItem('admin_current_page'); // 清除页面记忆
                
                // 尝试调用logout接口（可选）
                await apiRequest(`${API_BASE}/auth/logout.php`, { method: 'POST' }).catch(err => {});
                
                // 重定向到登录页面
                window.location.href = `${API_BASE}/login.html`;
                
                // 返回错误对象
                return { code: 401, message: '登录已过期' };
            }
            
            return data;
        } catch (e) {
            return { code: response.status, message: '响应格式错误' };
        }
    } catch (error) {
        console.error('API请求失败:', error);
        showToast('网络请求失败，请检查网络连接', 'error');
        return { code: 500, message: '网络请求失败' };
    }
}

// 初始化
document.addEventListener('DOMContentLoaded', init);

// 检查登录状态
function checkLoginStatus() {
    // Session存储，刷新后自动跳转
    if (sessionStorage.getItem('admin_logged_in')) {
        showMainPage();
        // 恢复上次选中的页面
        const lastPage = localStorage.getItem('admin_current_page') || 'dashboard';
        switchToPage(lastPage);
    } else {
        // 未登录，重定向到登录页面
        window.location.href = `${API_BASE}/login.html`;
    }
}

// 登录表单 - 已迁移到login.html
function initLoginForm() {
    // 登录表单已迁移到login.html，此函数保留以保持兼容性
}

// 显示主页面
function showMainPage() {
    document.getElementById('mainPage').classList.add('active');
    document.querySelector('.username-display').textContent = sessionStorage.getItem('admin_username');
    // 加载导航栏
    loadNavigation();
    // 加载通知列表
    setTimeout(() => {
        loadNotifications(1, '', 0); // 默认加载未读消息
        loadNotificationLogs();
    }, 500);
}

// 加载导航栏
async function loadNavigation() {
    try {
        const data = await apiRequest(`${API_BASE}/api/system_permission_template/user_permissions.php`);
        
        if (data.code === 0) {
            renderNavigation(data.data);
        } else {
            console.error('加载导航栏失败:', data.message);
        }
    } catch (err) {
        console.error('加载导航栏失败:', err);
    }
}

// 渲染导航栏
function renderNavigation(templates) {
    const navMenu = document.getElementById('navMenu');
    navMenu.innerHTML = '';
    
    templates.forEach(template => {
        const li = document.createElement('li');
        li.className = 'nav-item';
        
        const a = document.createElement('a');
        a.href = '#';
        a.className = 'nav-link';
        a.dataset.page = template.code;
        a.innerHTML = `<i class="${template.icon}"></i> ${template.name}`;
        
        a.addEventListener('click', (e) => {
            e.preventDefault();
            const page = a.dataset.page;
            switchToPage(page);
        });
        
        li.appendChild(a);
        navMenu.appendChild(li);
    });
}

// 登出
function initLogout() {
    document.getElementById('logoutBtn').addEventListener('click', async () => {
        try {
            await apiRequest(`${API_BASE}/auth/logout.php`, { method: 'POST' });
        } catch (err) {}
        
        sessionStorage.clear();
        localStorage.removeItem('admin_current_page'); // 清除页面记忆
        
        // 重定向到登录页面
        window.location.href = `${API_BASE}/login.html`;
    });
}

// 导航切换
function initNavigation() {
    const navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const page = link.dataset.page;
            switchToPage(page);
        });
    });
}

// 切换到指定页面
function switchToPage(page) {
    // 更新导航高亮
    document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
    const targetLink = document.querySelector(`.nav-link[data-page="${page}"]`);
    if (targetLink) {
        targetLink.classList.add('active');
    }
    
    // 切换内容区
    document.querySelectorAll('.content-section').forEach(section => {
        section.classList.remove('active');
    });
    const targetSection = document.getElementById(`${page}Section`);
    if (targetSection) {
        targetSection.classList.add('active');
    }
    
    // 保存当前页面到localStorage
    localStorage.setItem('admin_current_page', page);
    
    // 加载对应数据
    switch(page) {
        case 'dashboard': loadDashboard(); break;
        case 'b-users': loadBUsers(); break;
        case 'c-users': loadCUsers(); break;
        case 'system-users': loadSystemUsers(); break;
        case 'system-roles': loadSystemRoles(); break;
        case 'system-permissions': loadSystemPermissions(); break;
        case 'templates': loadTaskTemplates(); break;
        case 'market': loadMarketTasks(); break;
        case 'wallet-logs': loadWalletLogs(); break;
        case 'recharge': loadRechargeList(); break;
        case 'withdraw': loadWithdrawList(); break;
        case 'agent': loadAgentList(); break;
        case 'rental-orders': loadRentalOrders(); break;
        case 'rental-tickets': loadTickets(); break;
        case 'system-config': loadSystemConfig(); break;
        case 'task-review': loadTaskReviewList(); break;
        case 'notifications': loadNotificationList(); break;
        case 'notification-logsSection': 
            loadNotifications(1, '', '0'); // 默认加载未读消息
            loadNotificationLogs();
            break;
        case 'magnifier': loadMagnifierTasks(); break;
    }
}

// Modal初始化
function initModal() {
    const modal = document.getElementById('modal');
    const closeBtn = modal.querySelector('.close');
    
    closeBtn.onclick = () => modal.classList.remove('active', 'fullscreen');
    window.onclick = (e) => {
        if (e.target === modal) modal.classList.remove('active', 'fullscreen');
    };
}


// 加载B端用户列表
async function loadBUsers(page = 1) {
    const search = document.getElementById('bUserSearch').value;
    try {
        const data = await apiRequest(`${API_BASE}/api/b_users/list.php?page=${page}&search=${encodeURIComponent(search)}`);
        
        if (data.code === 0) {
            renderBUsersTable(data.data.list, data.data.pagination);
        }
    } catch (err) {
        console.error('加载B端用户失败', err);
    }
}

function renderBUsersTable(list, pagination) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>用户名</th>
                    <th>邮箱</th>
                    <th>手机号</th>
                    <th>组织名称</th>
                    <th>负责人</th>
                    <th>钱包ID</th>
                    <th>余额</th>
                    <th>总发布</th>
                    <th>今日发布</th>
                    <th>待审核</th>
                    <th>总驳回</th>
                    <th>今日驳回</th>
                    <th>状态</th>
                    <th>禁用原因</th>
                    <th>注册IP</th>
                    <th>注册时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    list.forEach(u => {
        const statusBadge = u.status === 1 ? '<span class="badge badge-success">正常</span>' : '<span class="badge badge-danger">禁用</span>';
        html += `
            <tr>
                <td>${u.id}</td>
                <td><strong>${u.username}</strong></td>
                <td>${u.email}</td>
                <td>${u.phone || '-'}</td>
                <td>${u.organization_name}</td>
                <td>${u.organization_leader}</td>
                <td>${u.wallet_id}</td>
                <td>¥${u.balance}</td>
                <td>${u.total_tasks}</td>
                <td>${u.today_tasks}</td>
                <td>${u.reviewing_tasks}</td>
                <td>${u.total_rejected}</td>
                <td>${u.today_rejected}</td>
                <td>${statusBadge}</td>
                <td>${u.reason || '-'}</td>
                <td>${u.create_ip || '-'}</td>
                <td>${u.created_at}</td>
                <td>
                    <button class="btn-info btn-small" onclick='editBUser(${JSON.stringify(u)})'><i class="ri-edit-line"></i> 编辑</button>
                </td>
            </tr>
        `;
    });
    
    html += '</tbody></table></div>';
    document.getElementById('bUsersTable').innerHTML = html;
}

// 编辑B端用户
function editBUser(user) {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-edit-line"></i> 编辑B端用户 #${user.id}</h3>
        <form id="editBUserForm">
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
                <input type="text" name="phone" value="${user.phone || ''}" placeholder="手机号（选填）">
            </div>
            <div class="form-group">
                <label>组织名称</label>
                <input type="text" name="organization_name" value="${user.organization_name}" placeholder="组织名称">
            </div>
            <div class="form-group">
                <label>组织负责人</label>
                <input type="text" name="organization_leader" value="${user.organization_leader}" placeholder="组织负责人">
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
    
    document.getElementById('editBUserForm').addEventListener('submit', async (e) => {
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
            const result = await apiRequest(`${API_BASE}/api/b_users/update.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            
            if (result.code === 0) {
                showToast('更新成功', 'success');
                closeModal();
                loadBUsers();
            } else {
                showToast(result.message, 'error');
            }
        } catch (err) {
            showToast('更新失败', 'error');
        }
    });
}

function closeModal() {
    const modal = document.getElementById('modal');
    modal.classList.remove('active', 'fullscreen');
}



// 加载充值列表
async function loadRechargeList(page = 1) {
    const status = document.getElementById('rechargeStatus').value;
    try {
        const data = await apiRequest(`${API_BASE}/api/recharge/list.php?page=${page}&status=${status}`);
        
        if (data.code === 0) {
            renderRechargeTable(data.data.list);
        }
    } catch (err) {
        console.error('加载充值列表失败', err);
    }
}

function renderRechargeTable(list) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>用户</th>
                    <th>金额</th>
                    <th>支付方式</th>
                    <th>支付凭证</th>
                    <th>状态</th>
                    <th>申请时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    list.forEach(r => {
        let statusBadge = '';
        if (r.status === 0) statusBadge = '<span class="badge badge-warning">待审核</span>';
        else if (r.status === 1) statusBadge = '<span class="badge badge-success">已通过</span>';
        else statusBadge = '<span class="badge badge-danger">已拒绝</span>';
        
        const actions = r.status === 0 ? `
            <button class="btn-success btn-small" onclick="reviewRecharge(${r.id}, 'approve')"><i class="ri-check-line"></i> 通过</button>
            <button class="btn-danger btn-small" onclick="reviewRecharge(${r.id}, 'reject')"><i class="ri-close-line"></i> 拒绝</button>
        ` : '-';
        
        html += `
            <tr>
                <td>${r.id}</td>
                <td><strong>${r.username}</strong></td>
                <td>¥${(r.amount/100).toFixed(2)}</td>
                <td>${r.payment_method}</td>
                <td><a href="${r.payment_voucher}" target="_blank" class="text-primary"><i class="ri-image-line"></i> 查看</a></td>
                <td>${statusBadge}</td>
                <td>${r.created_at}</td>
                <td>${actions}</td>
            </tr>
        `;
    });
    
    html += '</tbody></table></div>';
    document.getElementById('rechargeTable').innerHTML = html;
}

// 审核充值
function reviewRecharge(id, action) {
    if (action === 'approve') {
        showConfirm('确认通过该充值申请吗？', async () => {
            try {
                const result = await apiRequest(`${API_BASE}/api/recharge/review.php`, {
                    method: 'POST',
                    body: JSON.stringify({ id, action: 'approve' })
                });
                
                if (result.code === 0) {
                    showToast(result.message, 'success');
                    loadRechargeList();
                } else {
                    showToast(result.message, 'error');
                }
            } catch (err) {
                showToast('审核失败', 'error');
            }
        });
    } else {
        showRejectModal('充值', async (reason) => {
            try {
                const result = await apiRequest(`${API_BASE}/api/recharge/review.php`, {
                    method: 'POST',
                    body: JSON.stringify({ id, action: 'reject', reject_reason: reason })
                });
                
                if (result.code === 0) {
                    showToast(result.message, 'success');
                    loadRechargeList();
                } else {
                    showToast(result.message, 'error');
                }
            } catch (err) {
                showToast('审核失败', 'error');
            }
        });
    }
}

// 加载提现列表
async function loadWithdrawList(page = 1) {
    const status = document.getElementById('withdrawStatus').value;
    try {
        const data = await apiRequest(`${API_BASE}/api/withdraw/list.php?page=${page}&status=${status}`);
        
        if (data.code === 0) {
            renderWithdrawTable(data.data.list);
        }
    } catch (err) {
        console.error('加载提现列表失败', err);
    }
}

function renderWithdrawTable(list) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>用户</th>
                    <th>金额</th>
                    <th>收款方式</th>
                    <th>收款账号</th>
                    <th>姓名</th>
                    <th>状态</th>
                    <th>申请时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    list.forEach(w => {
        let statusBadge = '';
        if (w.status === 0) statusBadge = '<span class="badge badge-warning">待审核</span>';
        else if (w.status === 1) statusBadge = '<span class="badge badge-success">已通过</span>';
        else statusBadge = '<span class="badge badge-danger">已拒绝</span>';
        
        const actions = w.status === 0 ? `
            <button class="btn-success btn-small" onclick="reviewWithdraw(${w.id}, 'approve')"><i class="ri-check-line"></i> 通过</button>
            <button class="btn-danger btn-small" onclick="reviewWithdraw(${w.id}, 'reject')"><i class="ri-close-line"></i> 拒绝</button>
        ` : '-';
        
        html += `
            <tr>
                <td>${w.id}</td>
                <td><strong>${w.username}</strong></td>
                <td>¥${w.amount}</td>
                <td>${w.withdraw_method}</td>
                <td>${w.withdraw_account}</td>
                <td>${w.account_name || '-'}</td>
                <td>${statusBadge}</td>
                <td>${w.created_at}</td>
                <td>${actions}</td>
            </tr>
        `;
    });
    
    html += '</tbody></table></div>';
    document.getElementById('withdrawTable').innerHTML = html;
}

// 审核提现
function reviewWithdraw(id, action) {
    if (action === 'approve') {
        showWithdrawApproveModal(id);
    } else {
        showRejectModal('提现', async (reason) => {
            try {
                const result = await apiRequest(`${API_BASE}/api/withdraw/review.php`, {
                    method: 'POST',
                    body: JSON.stringify({ id, action: 'reject', reject_reason: reason })
                });
                
                if (result.code === 0) {
                    showToast(result.message, 'success');
                    loadWithdrawList();
                } else {
                    showToast(result.message, 'error');
                }
            } catch (err) {
                showToast('审核失败', 'error');
            }
        });
    }
}

// 显示提现审核通过模态框（带图片上传）
function showWithdrawApproveModal(id) {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3>审核通过 - 上传打款凭证</h3>
        <form id="withdrawApproveForm">
            <div class="upload-area" id="uploadArea">
                <p><i class="ri-camera-line" style="font-size: 32px; color: #ccc;"></i><br>点击或拖拽上传打款凭证图片</p>
                <p style="font-size: 12px; color: #86868b; margin-top: 10px;">支持 JPG、PNG、GIF、WEBP，最大5MB</p>
                <input type="file" id="imageInput" accept="image/*" style="display:none;">
                <img id="uploadPreview" class="upload-preview" style="display:none;">
            </div>
            <input type="hidden" id="uploadedImageUrl" value="">
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-primary">确认通过并打款</button>
            </div>
        </form>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    // 上传区域点击事件
    const uploadArea = document.getElementById('uploadArea');
    const imageInput = document.getElementById('imageInput');
    const uploadPreview = document.getElementById('uploadPreview');
    
    uploadArea.onclick = () => imageInput.click();
    
    imageInput.onchange = async (e) => {
        const file = e.target.files[0];
        if (!file) return;
        
        // 显示预览
        const reader = new FileReader();
        reader.onload = (e) => {
            uploadPreview.src = e.target.result;
            uploadPreview.style.display = 'block';
        };
        reader.readAsDataURL(file);
        
        // 上传到服务器
        uploadArea.classList.add('uploading');
        uploadArea.innerHTML = '<p><i class="ri-loader-4-line ri-spin"></i> 上传中...</p>';
        
        try {
            const formData = new FormData();
            formData.append('image', file);
            
            const result = await apiRequest(`${API_BASE}/api/upload.php`, {
                method: 'POST',
                body: formData
            });
            
            if (result.code === 0) {
                document.getElementById('uploadedImageUrl').value = result.data.url;
                uploadArea.classList.remove('uploading');
                uploadArea.innerHTML = `
                    <p><i class="ri-check-circle-line" style="color: var(--success-color);"></i> 上传成功</p>
                    <img src="${result.data.url}" class="upload-preview" style="max-height: 150px; margin-top: 10px; border-radius: 4px;">
                `;
                showToast('图片上传成功', 'success');
            } else {
                uploadArea.classList.remove('uploading');
                uploadArea.innerHTML = '<p><i class="ri-close-circle-line" style="color: var(--danger-color);"></i> 上传失败，请重试</p>';
                showToast(result.message, 'error');
            }
        } catch (err) {
            uploadArea.classList.remove('uploading');
            uploadArea.innerHTML = '<p><i class="ri-close-circle-line" style="color: var(--danger-color);"></i> 上传失败，请重试</p>';
            showToast('图片上传失败', 'error');
        }
    };
    
    // 表单提交
    document.getElementById('withdrawApproveForm').onsubmit = async (e) => {
        e.preventDefault();
        
        const imgUrl = document.getElementById('uploadedImageUrl').value;
        
        showConfirm('确认通过该提现申请并打款吗？', async () => {
            try {
                const result = await apiRequest(`${API_BASE}/api/withdraw/review.php`, {
                    method: 'POST',
                    body: JSON.stringify({ id, action: 'approve', img_url: imgUrl })
                });
                
                if (result.code === 0) {
                    showToast(result.message, 'success');
                    closeModal();
                    loadWithdrawList();
                } else {
                    showToast(result.message, 'error');
                }
            } catch (err) {
                showToast('审核失败', 'error');
            }
        });
    };
}

// 加载团长申请列表
async function loadAgentList(page = 1) {
    const status = document.getElementById('agentStatus').value;
    try {
        const data = await apiRequest(`${API_BASE}/api/agent/list.php?page=${page}&status=${status}`);
        
        if (data.code === 0) {
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
                const result = await apiRequest(`${API_BASE}/api/agent/review.php`, {
                    method: 'POST',
                    body: JSON.stringify({ id, action: 'approve' })
                });
                
                if (result.code === 0) {
                    showToast(result.message, 'success');
                    loadAgentList();
                } else {
                    showToast(result.message, 'error');
                }
            } catch (err) {
                showToast('审核失败', 'error');
            }
        });
    } else {
        showRejectModal('团长申请', async (reason) => {
            try {
                const result = await apiRequest(`${API_BASE}/api/agent/review.php`, {
                    method: 'POST',
                    body: JSON.stringify({ id, action: 'reject', reject_reason: reason })
                });
                
                if (result.code === 0) {
                    showToast(result.message, 'success');
                    loadAgentList();
                } else {
                    showToast(result.message, 'error');
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





// ========== 系统用户管理 ==========

// 加载系统用户列表
async function loadSystemUsers() {
    try {
        const data = await apiRequest(`${API_BASE}/api/system_users/list.php`);
        
        if (data.code === 0) {
            renderSystemUsersTable(data.data);
        } else {
            showToast('加载系统用户失败: ' + data.message, 'error');
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
            const result = await apiRequest(`${API_BASE}/api/system_users/create.php`, {
                method: 'POST',
                body: JSON.stringify(data)
            });
            
            if (result.code === 0) {
                showToast('创建成功', 'success');
                closeModal();
                loadSystemUsers();
            } else {
                showToast(result.message, 'error');
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
            const result = await apiRequest(`${API_BASE}/api/system_users/update.php`, {
                method: 'POST',
                body: JSON.stringify(data)
            });
            
            
            if (result.code === 0) {
                showToast('更新成功', 'success');
                closeModal();
                loadSystemUsers();
            } else {
                showToast(result.message, 'error');
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
            const result = await apiRequest(`${API_BASE}/api/system_users/delete.php`, {
                method: 'POST',
                body: JSON.stringify({ id })
            });
            
            if (result.code === 0) {
                showToast('删除成功', 'success');
                loadSystemUsers();
            } else {
                showToast(result.message, 'error');
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
            const result = await apiRequest(`${API_BASE}/api/system_users/change-password.php`, {
                method: 'POST',
                body: JSON.stringify(data)
            });
            
            if (result.code === 0) {
                showToast('密码修改成功', 'success');
                closeModal();
            } else {
                showToast(result.message, 'error');
            }
        } catch (err) {
            showToast('密码修改失败', 'error');
        }
    });
}

// 加载角色列表用于下拉选择
async function loadRolesForSelect(selectId, selectedRoleId = null) {
    try {
     
        
        const data = await apiRequest(`${API_BASE}/api/system_roles/list.php`);
        
 
        if (data.code === 0) {
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

// ========== 角色管理 ==========

// 加载角色列表
async function loadSystemRoles() {
    try {
        const data = await apiRequest(`${API_BASE}/api/system_roles/list.php`);
        
        if (data.code === 0) {
            renderSystemRolesTable(data.data);
        } else {
            showToast('加载角色列表失败: ' + data.message, 'error');
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
            const result = await apiRequest(`${API_BASE}/api/system_roles/create.php`, {
                method: 'POST',
                body: JSON.stringify(data)
            });
            
            if (result.code === 0) {
                showToast('创建成功', 'success');
                closeModal();
                loadSystemRoles();
            } else {
                showToast(result.message, 'error');
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
            
            const result = await apiRequest(`${API_BASE}/api/system_roles/update.php`, {
                method: 'POST',
                body: JSON.stringify(data)
            });
            
            if (result.code === 0) {
                showToast('更新成功', 'success');
                closeModal();
                loadSystemRoles();
            } else {
                showToast(result.message, 'error');
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
            const result = await apiRequest(`${API_BASE}/api/system_roles/delete.php`, {
                method: 'POST',
                body: JSON.stringify({ role_id })
            });
            
            if (result.code === 0) {
                showToast('删除成功', 'success');
                loadSystemRoles();
            } else {
                showToast(result.message, 'error');
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
            role_id: formData.get('role_id'),
            template_ids: []
        };
        
        // 收集选中的权限模板
        const checkboxes = document.querySelectorAll('input[name="template_id"]:checked');
        checkboxes.forEach(checkbox => {
            data.template_ids.push(parseInt(checkbox.value));
        });
        
        try {
            const result = await apiRequest(`${API_BASE}/api/system_permission_template/role_permissions.php`, {
                method: 'POST',
                body: JSON.stringify(data)
            });
            
            if (result.code === 0) {
                showToast('权限配置成功', 'success');
                closeModal();
            } else {
                showToast(result.message, 'error');
            }
        } catch (err) {
            showToast('权限配置失败', 'error');
        }
    });
}

// 加载角色权限模板
async function loadPermissionTemplatesForRole(roleId) {
    try {
        const [templatesData, roleTemplatesData] = await Promise.all([
            apiRequest(`${API_BASE}/api/system_permission_template/list.php`),
            apiRequest(`${API_BASE}/api/system_permission_template/role_permissions_get.php?role_id=${roleId}`)
        ]);
        
        if (templatesData.code === 0 && roleTemplatesData.code === 0) {
            const permissionsList = document.getElementById('permissionsList');
            let html = '<div class="permission-groups">';
            
            // 生成权限模板列表
            html += '<div class="permission-group">';
            html += '<h4>导航栏面板</h4>';
            html += '<div class="permission-items">';
            
            templatesData.data.forEach(template => {
                const isChecked = roleTemplatesData.data.includes(template.id);
                html += `
                    <div class="permission-item">
                        <input type="checkbox" id="template_${template.id}" name="template_id" value="${template.id}" ${isChecked ? 'checked' : ''}>
                        <label for="template_${template.id}">${template.name} (${template.code})</label>
                        <span class="permission-desc">${template.description || '-'}</span>
                    </div>
                `;
            });
            
            html += '</div></div>';
            html += '</div>';
            permissionsList.innerHTML = html;
        }
    } catch (err) {
        console.error('加载权限模板列表失败', err);
    }
}

// ========== 权限管理 ==========

// 通知API调用函数

// 检测通知
// 静默重载页面数据




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
        const data = await apiRequest(`${API_BASE}/api/admin_notifications/read.php`, {
            method: 'POST',
            body: JSON.stringify({ notification_id: notificationId })
        });
        
        if (data.code === 0) {
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
        const data = await apiRequest(`${API_BASE}/api/admin_notifications/read-all.php`, {
            method: 'POST',
            body: JSON.stringify({ type })
        });
        
        if (data.code === 0) {
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
        const data = await apiRequest(`${API_BASE}/api/admin_notifications/read-all.php`, {
            method: 'POST',
            body: JSON.stringify({ type: '' })
        });
        
        if (data.code === 0) {
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
            const data = await apiRequest(`${API_BASE}/api/admin_notifications/clean-log.php`, {
                method: 'POST',
                body: JSON.stringify({ days: 0 })
            });
            
            if (data.code === 0) {
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
        const url = `${API_BASE}/api/admin_notifications/list.php?page=1&pageSize=100` +
            (filterStatus ? `&status=${filterStatus}` : '') +
            (search ? `&search=${encodeURIComponent(search)}` : '');
        
        const data = await apiRequest(url);
      
        if (data.code === 0) {
          
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
        
        const url = `${API_BASE}/api/admin_notifications/log.php?page=${page}&pageSize=20` +
            (hasNewNotification !== -1 ? `&has_new_notification=${hasNewNotification}` : '') +
            (search ? `&search=${encodeURIComponent(search)}` : '') +
            (type ? `&type=${type}` : '');
        
        const data = await apiRequest(url);
        
        if (data.code === 0) {
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
        const data = await apiRequest(`${API_BASE}/api/admin_notifications/config.php`);
        
        if (data.code === 0) {
            renderNotificationConfigTable(data.data);
        }
    } catch (error) {
        log('ERROR', '加载通知配置失败: ' + error.message, 'NOTIFICATION');
    }
}

// 保存通知配置
async function saveNotificationConfig(config) {
    try {
        const data = await apiRequest(`${API_BASE}/api/admin_notifications/config/update.php`, {
            method: 'POST',
            body: JSON.stringify(config)
        });
        
        if (data.code === 0) {
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
        const data = await apiRequest(`${API_BASE}/api/admin_notifications/clean-log.php`, {
            method: 'POST',
            body: JSON.stringify({ days })
        });
        
        if (data.code === 0) {
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
        const data = await apiRequest(`${API_BASE}/api/admin_notifications/unread.php`, {
            method: 'POST',
            body: JSON.stringify({ notification_id: notificationId })
        });
        
        if (data.code === 0) {
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
            const data = await apiRequest(`${API_BASE}/api/admin_notifications/delete.php`, {
                method: 'POST',
                body: JSON.stringify({ ids: selectedIds })
            });
            
            if (data.code === 0) {
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
            const data = await apiRequest(`${API_BASE}/api/admin_notifications/detail.php`, {
                method: 'POST',
                body: JSON.stringify({ notification_id: item })
            });
            
            if (data.code === 0) {
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



// 加载权限模板列表
async function loadSystemPermissions() {
    try {
        const data = await apiRequest(`${API_BASE}/api/system_permission_template/list.php?all=1`);
        
        if (data.code === 0) {
            renderSystemPermissionsTable(data.data);
        } else {
            showToast('加载权限模板列表失败: ' + data.message, 'error');
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
            const result = await apiRequest(`${API_BASE}/api/system_permission_template/create.php`, {
                method: 'POST',
                body: JSON.stringify(data)
            });
            
            if (result.code === 0) {
                showToast('创建成功', 'success');
                closeModal();
                loadSystemPermissions();
            } else {
                showToast(result.message, 'error');
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
            const result = await apiRequest(`${API_BASE}/api/system_permission_template/update.php`, {
                method: 'POST',
                body: JSON.stringify(data)
            });
            
            if (result.code === 0) {
                showToast('更新成功', 'success');
                closeModal();
                loadSystemPermissions();
            } else {
                showToast(result.message, 'error');
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
            const result = await apiRequest(`${API_BASE}/api/system_permission_template/delete.php`, {
                method: 'POST',
                body: JSON.stringify({ id })
            });
            
            if (result.code === 0) {
                showToast('删除成功', 'success');
                loadSystemPermissions();
            } else {
                showToast(result.message, 'error');
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
            const result = await apiRequest(`${API_BASE}/api/system_permission_template/update.php`, {
                method: 'POST',
                body: JSON.stringify({ id, status: newStatus })
            });
            
            if (result.code === 0) {
                showToast(`${actionText}成功`, 'success');
                loadSystemPermissions();
            } else {
                showToast(result.message, 'error');
            }
        } catch (err) {
            showToast(`${actionText}失败`, 'error');
        }
    });
}

// ========== 任务模板管理 ==========

// 加载任务模板列表
async function loadTaskTemplates(page = 1) {
    const type = document.getElementById('templateType')?.value || '';
    const status = document.getElementById('templateStatus')?.value || '';
    
    try {
        const data = await apiRequest(`${API_BASE}/api/tasks/list.php?page=${page}&type=${type}&status=${status}`);
        
        if (data.code === 0) {
            renderTaskTemplatesTable(data.data.list);
        }
    } catch (err) {
        console.error('加载任务模板失败', err);
    }
}

function renderTaskTemplatesTable(list) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>类型</th>
                    <th>标题</th>
                    <th>单价</th>
                    <th>描述1</th>
                    <th>描述2</th>
                    <th>阶段1标题</th>
                    <th>阶段1单价</th>
                    <th>阶段2标题</th>
                    <th>阶段2单价</th>
                    <th>默认阶段1数</th>
                    <th>默认阶段2数</th>
                    <th>状态</th>
                    <th>创建时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    if (list.length === 0) {
        html += '<tr><td colspan="15" style="text-align: center; padding: 40px; color: #86868b;">暂无数据</td></tr>';
    } else {
        list.forEach(t => {
            const typeBadge = t.type === 0 ? '<span class="badge badge-info">单任务</span>' : '<span class="badge badge-success">组合任务</span>';
            const statusBadge = t.status === 1 ? '<span class="badge badge-success">已上线</span>' : '<span class="badge badge-neutral">已下线</span>';
            
            html += `
                <tr>
                    <td>${t.id}</td>
                    <td>${typeBadge}</td>
                    <td><strong>${t.title}</strong></td>
                    <td>¥${t.price}</td>
                    <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis;">${t.description1 || '-'}</td>
                    <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis;">${t.description2 || '-'}</td>
                    <td>${t.stage1_title || '-'}</td>
                    <td>${t.stage1_price ? '¥' + t.stage1_price : '-'}</td>
                    <td>${t.stage2_title || '-'}</td>
                    <td>${t.stage2_price ? '¥' + t.stage2_price : '-'}</td>
                    <td>${t.default_stage1_count || '-'}</td>
                    <td>${t.default_stage2_count || '-'}</td>
                    <td>${statusBadge}</td>
                    <td>${t.created_at}</td>
                    <td>
                        <button class="btn-info btn-small" onclick='editTaskTemplate(${JSON.stringify(t)})'><i class="ri-edit-line"></i> 编辑</button>
                        <button class="btn-danger btn-small" onclick="deleteTaskTemplate(${t.id})"><i class="ri-delete-bin-line"></i> 删除</button>
                    </td>
                </tr>
            `;
        });
    }
    
    html += '</tbody></table></div>';
    document.getElementById('templatesTable').innerHTML = html;
}

// 新增任务模板
function addTaskTemplate() {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-add-line"></i> 新增任务模板</h3>
        <form id="addTaskForm">
            <div class="form-group">
                <label>任务类型</label>
                <select name="type" id="newTaskType" onchange="toggleComboFields()">
                    <option value="0">单任务</option>
                    <option value="1">组合任务</option>
                </select>
            </div>
            <div class="form-group">
                <label>标题</label>
                <input type="text" name="title" placeholder="任务标题" required>
            </div>
            <div class="form-group">
                <label>单价（元）</label>
                <input type="number" name="price" placeholder="任务单价" step="0.01" required>
            </div>
            <div class="form-group">
                <label>描述信息1</label>
                <textarea name="description1" placeholder="描述信息1"></textarea>
            </div>
            <div class="form-group">
                <label>描述信息2</label>
                <textarea name="description2" placeholder="描述信息2"></textarea>
            </div>
            <div id="comboFields" style="display: none;">
                <div class="form-group">
                    <label>阶段1标题</label>
                    <input type="text" name="stage1_title" placeholder="阶段1标题">
                </div>
                <div class="form-group">
                    <label>阶段1单价（元）</label>
                    <input type="number" name="stage1_price" placeholder="阶段1单价" step="0.01">
                </div>
                <div class="form-group">
                    <label>阶段2标题</label>
                    <input type="text" name="stage2_title" placeholder="阶段2标题">
                </div>
                <div class="form-group">
                    <label>阶段2单价（元）</label>
                    <input type="number" name="stage2_price" placeholder="阶段2单价" step="0.01">
                </div>
                <div class="form-group">
                    <label>默认阶段1数量</label>
                    <input type="number" name="default_stage1_count" value="1" placeholder="默认阶段1数量">
                </div>
                <div class="form-group">
                    <label>默认阶段2数量</label>
                    <input type="number" name="default_stage2_count" value="3" placeholder="默认阶段2数量">
                </div>
            </div>
            <div id="singleCommissionFields">
                <h4 style="margin: 16px 0 8px; color: #666; border-top: 1px solid #eee; padding-top: 16px;">佣金配置（元）</h4>
                <div class="form-group">
                    <label>普通用户佣金（元）</label>
                    <input type="number" name="c_user_commission" value="0" step="0.01" placeholder="如 2.00">
                </div>
                <div class="form-group">
                    <label>普通团长佣金（元）</label>
                    <input type="number" name="agent_commission" value="0" step="0.01" placeholder="如 0.50">
                </div>
                <div class="form-group">
                    <label>高级团长佣金（元）</label>
                    <input type="number" name="senior_agent_commission" value="0" step="0.01" placeholder="如 1.00">
                </div>
            </div>
            <div id="comboCommissionFields" style="display: none;">
                <h4 style="margin: 16px 0 8px; color: #666; border-top: 1px solid #eee; padding-top: 16px;">阶段1佣金配置（元）</h4>
                <div class="form-group">
                    <label>阶段1-普通用户佣金（元）</label>
                    <input type="number" name="stage1_c_user_commission" value="0" step="0.01" placeholder="如 2.00">
                </div>
                <div class="form-group">
                    <label>阶段1-普通团长佣金（元）</label>
                    <input type="number" name="stage1_agent_commission" value="0" step="0.01" placeholder="如 0.50">
                </div>
                <div class="form-group">
                    <label>阶段1-高级团长佣金（元）</label>
                    <input type="number" name="stage1_senior_agent_commission" value="0" step="0.01" placeholder="如 1.00">
                </div>
                <h4 style="margin: 16px 0 8px; color: #666; border-top: 1px solid #eee; padding-top: 16px;">阶段2佣金配置（元）</h4>
                <div class="form-group">
                    <label>阶段2-普通用户佣金（元）</label>
                    <input type="number" name="stage2_c_user_commission" value="0" step="0.01" placeholder="如 2.00">
                </div>
                <div class="form-group">
                    <label>阶段2-普通团长佣金（元）</label>
                    <input type="number" name="stage2_agent_commission" value="0" step="0.01" placeholder="如 0.50">
                </div>
                <div class="form-group">
                    <label>阶段2-高级团长佣金（元）</label>
                    <input type="number" name="stage2_senior_agent_commission" value="0" step="0.01" placeholder="如 1.00">
                </div>
            </div>
            <div class="form-group">
                <label>上线状态</label>
                <select name="status">
                    <option value="1">已上线</option>
                    <option value="0">已下线</option>
                </select>
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-primary">创建</button>
            </div>
        </form>
    `;

    document.getElementById('modal').classList.add('active');

    // 类型切换
    window.toggleComboFields = () => {
        const type = document.getElementById('newTaskType').value;
        document.getElementById('comboFields').style.display = type === '1' ? 'block' : 'none';
        document.getElementById('singleCommissionFields').style.display = type === '0' ? 'block' : 'none';
        document.getElementById('comboCommissionFields').style.display = type === '1' ? 'block' : 'none';
    };
    
    document.getElementById('addTaskForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const data = {};
        const commissionFields = ['c_user_commission','agent_commission','senior_agent_commission','stage1_c_user_commission','stage1_agent_commission','stage1_senior_agent_commission','stage2_c_user_commission','stage2_agent_commission','stage2_senior_agent_commission'];

        for (const [key, value] of formData.entries()) {
            if (value !== '') {
                if (commissionFields.includes(key)) {
                    data[key] = Math.round(parseFloat(value) * 100);
                } else {
                    data[key] = value;
                }
            }
        }

        try {
            const result = await apiRequest(`${API_BASE}/api/tasks/create.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            
            if (result.code === 0) {
                showToast('创建成功', 'success');
                closeModal();
                loadTaskTemplates();
            } else {
                showToast(result.message, 'error');
            }
        } catch (err) {
            showToast('创建失败', 'error');
        }
    });
}

// 删除任务模板
function deleteTaskTemplate(id) {
    showConfirm('确认删除该任务模板吗？删除后无法恢复。', async () => {
        try {
            const result = await apiRequest(`${API_BASE}/api/tasks/delete.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ id })
            });
            if (result.code === 0) {
                showToast('删除成功', 'success');
                loadTaskTemplates();
            } else {
                showToast(result.message, 'error');
            }
        } catch (err) {
            showToast('删除失败', 'error');
        }
    });
}

// 编辑任务模板
function editTaskTemplate(task) {
    const modalBody = document.getElementById('modalBody');
    const isCombo = task.type === 1;
    
    modalBody.innerHTML = `
        <h3><i class="ri-edit-line"></i> 编辑任务模板 #${task.id}</h3>
        <form id="editTaskForm">
            <input type="hidden" name="id" value="${task.id}">
            <div class="form-group">
                <label>任务类型（不可修改）</label>
                <input type="text" value="${isCombo ? '组合任务' : '单任务'}" disabled>
            </div>
            <div class="form-group">
                <label>标题</label>
                <input type="text" name="title" value="${task.title}" placeholder="任务标题">
            </div>
            <div class="form-group">
                <label>单价（元）</label>
                <input type="number" name="price" value="${task.price}" placeholder="任务单价" step="0.01">
            </div>
            <div class="form-group">
                <label>描述信息1</label>
                <textarea name="description1" placeholder="描述信息1">${task.description1 || ''}</textarea>
            </div>
            <div class="form-group">
                <label>描述信息2</label>
                <textarea name="description2" placeholder="描述信息2">${task.description2 || ''}</textarea>
            </div>
            ${isCombo || (task.id === 1 || task.id === 2) ? `
                ${isCombo ? `
                    <div class="form-group">
                        <label>阶段1标题</label>
                        <input type="text" name="stage1_title" value="${task.stage1_title || ''}" placeholder="阶段1标题">
                    </div>
                    <div class="form-group">
                        <label>阶段1单价（元）</label>
                        <input type="number" name="stage1_price" value="${task.stage1_price || ''}" placeholder="阶段1单价" step="0.01">
                    </div>
                    <div class="form-group">
                        <label>阶段2标题</label>
                        <input type="text" name="stage2_title" value="${task.stage2_title || ''}" placeholder="阶段2标题">
                    </div>
                    <div class="form-group">
                        <label>阶段2单价（元）</label>
                        <input type="number" name="stage2_price" value="${task.stage2_price || ''}" placeholder="阶段2单价" step="0.01">
                    </div>
                ` : ''}
                <div class="form-group">
                    <label>默认阶段1数量</label>
                    <input type="number" name="default_stage1_count" value="${task.default_stage1_count || 1}" placeholder="默认阶段1数量">
                </div>
                <div class="form-group">
                    <label>默认阶段2数量</label>
                    <input type="number" name="default_stage2_count" value="${task.default_stage2_count || 3}" placeholder="默认阶段2数量">
                </div>
            ` : ''}
            ${isCombo ? `
                <h4 style="margin: 16px 0 8px; color: #666; border-top: 1px solid #eee; padding-top: 16px;">阶段1佣金配置（元）</h4>
                <div class="form-group">
                    <label>阶段1-普通用户佣金（元）</label>
                    <input type="number" name="stage1_c_user_commission" value="${((task.stage1_c_user_commission || 0) / 100).toFixed(2)}" step="0.01" placeholder="如 2.00">
                </div>
                <div class="form-group">
                    <label>阶段1-普通团长佣金（元）</label>
                    <input type="number" name="stage1_agent_commission" value="${((task.stage1_agent_commission || 0) / 100).toFixed(2)}" step="0.01" placeholder="如 0.50">
                </div>
                <div class="form-group">
                    <label>阶段1-高级团长佣金（元）</label>
                    <input type="number" name="stage1_senior_agent_commission" value="${((task.stage1_senior_agent_commission || 0) / 100).toFixed(2)}" step="0.01" placeholder="如 1.00">
                </div>
                <h4 style="margin: 16px 0 8px; color: #666; border-top: 1px solid #eee; padding-top: 16px;">阶段2佣金配置（元）</h4>
                <div class="form-group">
                    <label>阶段2-普通用户佣金（元）</label>
                    <input type="number" name="stage2_c_user_commission" value="${((task.stage2_c_user_commission || 0) / 100).toFixed(2)}" step="0.01" placeholder="如 2.00">
                </div>
                <div class="form-group">
                    <label>阶段2-普通团长佣金（元）</label>
                    <input type="number" name="stage2_agent_commission" value="${((task.stage2_agent_commission || 0) / 100).toFixed(2)}" step="0.01" placeholder="如 0.50">
                </div>
                <div class="form-group">
                    <label>阶段2-高级团长佣金（元）</label>
                    <input type="number" name="stage2_senior_agent_commission" value="${((task.stage2_senior_agent_commission || 0) / 100).toFixed(2)}" step="0.01" placeholder="如 1.00">
                </div>
            ` : `
                <h4 style="margin: 16px 0 8px; color: #666; border-top: 1px solid #eee; padding-top: 16px;">佣金配置（元）</h4>
                <div class="form-group">
                    <label>普通用户佣金（元）</label>
                    <input type="number" name="c_user_commission" value="${((task.c_user_commission || 0) / 100).toFixed(2)}" step="0.01" placeholder="如 2.00">
                </div>
                <div class="form-group">
                    <label>普通团长佣金（元）</label>
                    <input type="number" name="agent_commission" value="${((task.agent_commission || 0) / 100).toFixed(2)}" step="0.01" placeholder="如 0.50">
                </div>
                <div class="form-group">
                    <label>高级团长佣金（元）</label>
                    <input type="number" name="senior_agent_commission" value="${((task.senior_agent_commission || 0) / 100).toFixed(2)}" step="0.01" placeholder="如 1.00">
                </div>
            `}
            <div class="form-group">
                <label>上线状态</label>
                <select name="status">
                    <option value="1" ${task.status === 1 ? 'selected' : ''}>已上线</option>
                    <option value="0" ${task.status === 0 ? 'selected' : ''}>已下线</option>
                </select>
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-primary">保存</button>
            </div>
        </form>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    document.getElementById('editTaskForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const data = {};
        const commissionFields = ['c_user_commission','agent_commission','senior_agent_commission','stage1_c_user_commission','stage1_agent_commission','stage1_senior_agent_commission','stage2_c_user_commission','stage2_agent_commission','stage2_senior_agent_commission'];

        for (const [key, value] of formData.entries()) {
            if (value !== '') {
                if (commissionFields.includes(key)) {
                    data[key] = Math.round(parseFloat(value) * 100);
                } else {
                    data[key] = value;
                }
            }
        }

        try {
            const result = await apiRequest(`${API_BASE}/api/tasks/update.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            
            if (result.code === 0) {
                showToast('更新成功', 'success');
                closeModal();
                loadTaskTemplates();
            } else {
                showToast(result.message, 'error');
            }
        } catch (err) {
            showToast('更新失败', 'error');
        }
    });
}

// ========== 钱包记录管理 ==========

// 加载钱包记录列表
async function loadWalletLogs(page = 1) {
    const logId = document.getElementById('walletLogId').value;
    const username = document.getElementById('walletUsername').value;
    const userType = document.getElementById('walletUserType').value;
    const type = document.getElementById('walletType').value;
    const relatedType = document.getElementById('walletRelatedType').value;
    const startDate = document.getElementById('walletStartDate').value;
    const endDate = document.getElementById('walletEndDate').value;
    const minAmount = document.getElementById('walletMinAmount').value;
    const maxAmount = document.getElementById('walletMaxAmount').value;
    
    const params = new URLSearchParams({
        page,
        log_id: logId,
        username,
        user_type: userType,
        type,
        related_type: relatedType,
        start_date: startDate,
        end_date: endDate,
        min_amount: minAmount,
        max_amount: maxAmount
    });
    
    try {
        const data = await apiRequest(`${API_BASE}/api/wallet_logs/list.php?${params}`);
        
        if (data.code === 0) {
            renderWalletLogsTable(data.data.list, data.data.pagination);
        } else {
            showToast('加载钱包记录失败: ' + data.message, 'error');
        }
    } catch (err) {
        console.error('加载钱包记录失败', err);
        showToast('加载钱包记录失败', 'error');
    }
}

function renderWalletLogsTable(list, pagination) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>流水ID</th>
                    <th>钱包ID</th>
                    <th>用户ID</th>
                    <th>用户名</th>
                    <th>用户端</th>
                    <th>类型</th>
                    <th>变动金额</th>
                    <th>变动前余额</th>
                    <th>变动后余额</th>
                    <th>关联类型</th>
                    <th>关联ID</th>
                    <th>备注</th>
                    <th>创建时间</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    list.forEach(log => {
        const typeBadge = log.type === 1 ? '<span class="badge badge-success">收入</span>' : '<span class="badge badge-danger">支出</span>';
        
        html += `
            <tr>
                <td>${log.id}</td>
                <td>${log.wallet_id}</td>
                <td>${log.user_id}</td>
                <td><strong>${log.username}</strong></td>
                <td>${log.user_type_text}</td>
                <td>${typeBadge}</td>
                <td style="color: ${log.type === 1 ? 'var(--success-color)' : 'var(--danger-color)'}; font-weight: 600;">¥${log.amount}</td>
                <td>¥${log.before_balance}</td>
                <td>¥${log.after_balance}</td>
                <td><span class="badge badge-info">${log.related_type_text}</span></td>
                <td>${log.related_id || '-'}</td>
                <td style="max-width: 300px; overflow: hidden; text-overflow: ellipsis;">${log.remark}</td>
                <td>${log.created_at}</td>
            </tr>
        `;
    });
    
    html += `</tbody></table></div>
    <div class="pagination">
        ${pagination.page > 1 ? `<button onclick="loadWalletLogs(${pagination.page - 1})">上一页</button>` : '<button disabled>上一页</button>'}
        <span style="font-size: 13px; color: var(--text-secondary);">第 ${pagination.page} / ${pagination.total_pages} 页</span>
        ${pagination.page < pagination.total_pages ? `<button onclick="loadWalletLogs(${pagination.page + 1})">下一页</button>` : '<button disabled>下一页</button>'}
    </div>`;
    
    document.getElementById('walletLogsTable').innerHTML = html;
}

// ========== 任务市场管理 ==========

// 加载任务市场列表
async function loadMarketTasks(page = 1) {
    const bUserId = document.getElementById('marketBUserId')?.value || '';
    const stage = document.getElementById('marketStage')?.value || '';
    const status = document.getElementById('marketStatus')?.value || '';
    
    const params = new URLSearchParams({
        page,
        b_user_id: bUserId,
        stage,
        status
    });
    
    try {
        const data = await apiRequest(`${API_BASE}/api/market/list.php?${params}`);
        
        if (data.code === 0) {
            renderMarketTasksTable(data.data.list, data.data.pagination);
        }
    } catch (err) {
        console.error('加载任务市场失败', err);
    }
}

function renderMarketTasksTable(list, pagination) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>任务ID</th>
                    <th>B端用户</th>
                    <th>模板名称</th>
                    <th>模板类型</th>
                    <th>阶段</th>
                    <th>阶段状态</th>
                    <th>视频链接</th>
                    <th>总数量</th>
                    <th>已完成</th>
                    <th>进行中</th>
                    <th>待审核</th>
                    <th>剩余</th>
                    <th>单价</th>
                    <th>总价</th>
                    <th>状态</th>
                    <th>截止时间</th>
                    <th>创建时间</th>
                    <th>完成时间</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    if (list.length === 0) {
        html += '<tr><td colspan="18" style="text-align: center; padding: 40px; color: #86868b;">暂无数据</td></tr>';
    } else {
        list.forEach(task => {
            const statusBadge = {
                0: '<span class="badge badge-danger">已过期</span>',
                1: '<span class="badge badge-success">进行中</span>',
                2: '<span class="badge badge-info">已完成</span>',
                3: '<span class="badge badge-neutral">已取消</span>'
            }[task.status] || '<span class="badge">未知</span>';
            
            const stageStatusBadge = {
                0: '<span class="badge badge-neutral">未开放</span>',
                1: '<span class="badge badge-success">已开放</span>',
                2: '<span class="badge badge-info">已完成</span>'
            }[task.stage_status] || '<span class="badge">未知</span>';
            
            const deadlineDate = new Date(task.deadline * 1000).toLocaleString('zh-CN');
            
            html += `
                <tr>
                    <td>${task.id}</td>
                    <td>${task.b_username} (${task.b_user_id})</td>
                    <td>${task.template_title}</td>
                    <td>${task.template_type === 0 ? '单任务' : '组合任务'}</td>
                    <td>${task.stage_text}</td>
                    <td>${stageStatusBadge}</td>
                    <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis;">${task.video_url || '-'}</td>
                    <td>${task.task_count}</td>
                    <td>${task.task_done}</td>
                    <td>${task.task_doing}</td>
                    <td>${task.task_reviewing}</td>
                    <td><strong>${task.remaining}</strong></td>
                    <td>¥${task.unit_price}</td>
                    <td>¥${task.total_price}</td>
                    <td>${statusBadge}</td>
                    <td>${deadlineDate}</td>
                    <td>${task.created_at}</td>
                    <td>${task.completed_at || '-'}</td>
                </tr>
            `;
        });
    }
    
    html += `</tbody></table></div>
    <div class="pagination">
        ${pagination.page > 1 ? `<button onclick="loadMarketTasks(${pagination.page - 1})">上一页</button>` : '<button disabled>上一页</button>'}
        <span style="font-size: 13px; color: var(--text-secondary);">第 ${pagination.page} / ${pagination.total_pages} 页</span>
        ${pagination.page < pagination.total_pages ? `<button onclick="loadMarketTasks(${pagination.page + 1})">下一页</button>` : '<button disabled>下一页</button>'}
    </div>`;
    
    document.getElementById('marketTable').innerHTML = html;
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
        const data = await apiRequest(`${API_BASE}/api/notifications/list.php?${params}`);
        
        if (data.code === 0) {
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
        const data = await apiRequest(`${API_BASE}/api/notifications/send.php`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        
   
        
        if (data.code === 0) {
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

// ==================== 租赁订单处理 ====================

// 加载租赁订单列表
async function loadRentalOrders(page = 1) {
    const orderId = document.getElementById('rentalOrderId')?.value || '';
    const buyerId = document.getElementById('rentalBuyerId')?.value || '';
    const status = document.getElementById('rentalStatus')?.value || '';

    const params = new URLSearchParams({
        page,
        order_id: orderId,
        buyer_id: buyerId,
        status
    });

    try {
        const data = await apiRequest(`${API_BASE}/api/rental_orders/list.php?${params}`);

        if (data.code === 0) {
            renderRentalOrdersTable(data.data.list, data.data.pagination);
        } else {
            showToast('加载租赁订单失败: ' + data.message, 'error');
        }
    } catch (err) {
        showToast('加载租赁订单失败: ' + err.message, 'error');
    }
}

// 智能解析 JSON 信息并格式化显示
function formatJsonInfo(jsonData, prefix = '') {
    if (!jsonData || typeof jsonData !== 'object') return '无';
    
    let result = [];
    for (let key in jsonData) {
        let value = jsonData[key];
        
        // 处理嵌套对象
        if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
            result.push(`<strong>${key}:</strong>`);
            result.push(formatJsonInfo(value, '  '));
        } 
        // 处理数组
        else if (Array.isArray(value)) {
            result.push(`<strong>${key}:</strong> ${value.join(', ')}`);
        }
        // 普通值
        else {
            result.push(`<strong>${key}:</strong> ${value || '无'}`);
        }
    }
    
    return result.join('<br>' + prefix);
}

function renderRentalOrdersTable(list, pagination) {
    let html = `
        <div class="table-container">
        <table style="font-size: 13px;">
            <thead>
                <tr>
                    <th style="width: 50px;">ID</th>
                    <th style="width: 120px;">买家信息</th>
                    <th style="width: 120px;">卖家信息</th>
                    <th style="width: 60px;">来源</th>
                    <th style="width: 80px;">金额</th>
                    <th style="width: 60px;">租期</th>
                    <th style="width: 80px;">状态</th>
                    <th style="min-width: 150px;">买家详情</th>
                    <th style="min-width: 150px;">卖家详情</th>
                    <th style="width: 140px;">时间</th>
                    <th style="width: 140px;">操作</th>
                </tr>
            </thead>
            <tbody>
    `;

    if (list.length === 0) {
        html += '<tr><td colspan="11" style="text-align: center; padding: 40px; color: #86868b;">暂无数据</td></tr>';
    } else {
        list.forEach(order => {
            const statusMap = {
                0: { text: '待支付', class: 'badge badge-neutral' },
                1: { text: '已支付/待客服', class: 'badge badge-warning' },
                2: { text: '进行中', class: 'badge badge-success' },
                3: { text: '已完成', class: 'badge badge-info' },
                4: { text: '已取消', class: 'badge badge-danger' }
            };
            const statusInfo = statusMap[order.status] || { text: '未知', class: 'badge' };
            const statusBadge = `<span class="${statusInfo.class}">${statusInfo.text}</span>`;
            
            const sourceType = order.source_type === 0 ? '出租' : '求租';
            // 兼容两种格式：'c'/'b' 和 '1'/'2'
            const userTypeText = (type) => {
                if (type === 'c' || type === '1' || type === 1) return 'C端';
                if (type === 'b' || type === '2' || type === 2) return 'B端';
                return '未知';
            };
            
            // 买家详情信息
            const buyerInfo = formatJsonInfo(order.buyer_info_json);
            
            // 卖家详情信息
            const sellerInfo = formatJsonInfo(order.seller_info_json);
            
            let actions = '-';
            if (order.status === 1) {
                // 待客服：开始、退款
                actions = `
                    <button class="btn-success btn-small" onclick="dispatchOrder(${order.id}, 'start')" style="margin: 2px;">开始</button>
                    <button class="btn-danger btn-small" onclick="dispatchOrder(${order.id}, 'refund')" style="margin: 2px;">退款</button>
                `;
            } else if (order.status === 2) {
                // 进行中：终止
                actions = `
                    <button class="btn-danger btn-small" onclick="dispatchOrder(${order.id}, 'terminate')" style="margin: 2px;">终止</button>
                `;
            }

            html += `
                <tr style="vertical-align: top;">
                    <td><strong>#${order.id}</strong></td>
                    <td>
                        ${order.buyer_username}<br>
                        <small style="color: #86868b;">ID: ${order.buyer_user_id}</small><br>
                        <small style="color: #86868b;">${userTypeText(order.buyer_user_type)}</small>
                    </td>
                    <td>
                        ${order.seller_username}<br>
                        <small style="color: #86868b;">ID: ${order.seller_user_id}</small><br>
                        <small style="color: #86868b;">${userTypeText(order.seller_user_type)}</small>
                    </td>
                    <td>${sourceType}</td>
                    <td>
                        <strong>¥${(order.total_amount / 100).toFixed(2)}</strong><br>
                        <small style="color: #86868b;">抽成: ¥${(order.platform_amount / 100).toFixed(2)}</small><br>
                        <small style="color: #86868b;">卖家得: ¥${(order.seller_amount / 100).toFixed(2)}</small>
                    </td>
                    <td>${order.days}天<br>${order.allow_renew ? '<small style="color: green;">可续租</small>' : '<small style="color: #999;">不可续租</small>'}</td>
                    <td>${statusBadge}</td>
                    <td style="font-size: 11px; line-height: 1.5; max-width: 200px; word-break: break-word;">
                        ${buyerInfo}
                    </td>
                    <td style="font-size: 11px; line-height: 1.5; max-width: 200px; word-break: break-word;">
                        ${sellerInfo}
                    </td>
                    <td style="font-size: 11px; line-height: 1.5;">
                        创建: ${order.created_at}<br>
                        ${order.order_json?.start_time ? '开始: ' + new Date(order.order_json.start_time * 1000).toLocaleString('zh-CN', {hour12: false}).replace(/\//g, '-') + '<br>' : ''}
                        ${order.order_json?.end_time ? '结束: ' + new Date(order.order_json.end_time * 1000).toLocaleString('zh-CN', {hour12: false}).replace(/\//g, '-') : ''}
                    </td>
                    <td>${actions}</td>
                </tr>
            `;
        });
    }

    html += `</tbody></table></div>
    <div class="pagination">
        ${pagination.page > 1 ? `<button onclick="loadRentalOrders(${pagination.page - 1})">上一页</button>` : '<button disabled>上一页</button>'}
        <span style="font-size: 13px; color: var(--text-secondary);">第 ${pagination.page} / ${pagination.total_pages} 页</span>
        ${pagination.page < pagination.total_pages ? `<button onclick="loadRentalOrders(${pagination.page + 1})">下一页</button>` : '<button disabled>下一页</button>'}
    </div>`;

    document.getElementById('rentalOrdersTable').innerHTML = html;
}

// 调度订单
function dispatchOrder(orderId, action) {
    let confirmMsg = '';
    if (action === 'start') {
        confirmMsg = '确认开始此订单吗？订单将进入进行中状态并开始计时。';
    } else if (action === 'refund') {
        confirmMsg = '确认全额退款吗？订单将取消，金额将退回买家钱包。';
    } else if (action === 'terminate') {
        confirmMsg = '确认强行终止此订单吗？订单将立即结束，不退还金额。';
    }

    showConfirm(confirmMsg, async () => {
        try {
            const result = await apiRequest(`${API_BASE}/api/rental_orders/dispatch.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ order_id: orderId, action })
            });
            if (result.code === 0) {
                showToast(result.message, 'success');
                loadRentalOrders();
            } else {
                showToast(result.message, 'error');
            }
        } catch (err) {
            showToast('操作失败: ' + err.message, 'error');
        }
    });
}

// ==================== 工单管理 ====================

// 加载工单列表
async function loadTickets(page = 1) {
    const status = document.getElementById('ticketStatusFilter').value;
    const params = new URLSearchParams({ page, page_size: 20 });
    if (status) params.append('status', status);

    try {
        const result = await apiRequest(`${API_BASE}/api/rental_tickets/list.php?${params}`);

        if (result.code === 0 || result.code === 200) {
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
        const result = await apiRequest(`${API_BASE}/api/rental_tickets/detail.php?ticket=${ticketId}`);

        if (result.code === 0 || result.code === 200) {
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
            const result = await apiRequest(`${API_BASE}/api/upload.php`, {
                method: 'POST',
                body: formData
            });

            if (result.code === 0 || result.code === 200) {
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
        const result = await apiRequest(`${API_BASE}/api/rental_tickets/send-message.php`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });

        if (result.code === 0 || result.code === 200) {
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
        const result = await apiRequest(`${API_BASE}/api/rental_tickets/close.php`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ ticket_id: ticketId, close_reason: reason })
        });

        if (result.code === 0 || result.code === 200) {
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

// ==================== 网站配置管理 ====================

// 加载系统配置
async function loadSystemConfig() {
    const group = document.getElementById('configGroupFilter').value;
    const params = new URLSearchParams();
    if (group) params.append('group', group);

    try {
        const result = await apiRequest(`${API_BASE}/api/config/list.php?${params}`);

        if (result.code === 0 || result.code === 200) {
            renderConfigTable(result.data.configs);
        } else {
            showToast('加载失败: ' + result.message, 'error');
        }
    } catch (err) {
        showToast('加载配置失败: ' + err.message, 'error');
    }
}

// 渲染配置表格
function renderConfigTable(configs) {
    const container = document.getElementById('configTable');

    if (!configs || configs.length === 0) {
        container.innerHTML = '<p class="empty-message" style="text-align: center; padding: 40px; color: #86868b;">暂无配置</p>';
        return;
    }

    // 按分组整理配置
    const groupedConfigs = {};
    configs.forEach(config => {
        if (!groupedConfigs[config.config_group]) {
            groupedConfigs[config.config_group] = [];
        }
        groupedConfigs[config.config_group].push(config);
    });

    const groupNames = {
        'general': '基础配置',
        'withdraw': '提现配置',
        'task': '任务配置',
        'rental': '租赁配置',
        'notification': '消息通知配置',
        'agent': '大团团长佣金配置',
        'incentive': '团长激励配置'
    };

    let html = '';
    
    for (const [group, items] of Object.entries(groupedConfigs)) {
        html += `
            <div style="margin-bottom: 30px;" class="card">
                <div class="card-header">
                    <div class="card-title">${groupNames[group] || group}</div>
                </div>
                <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>配置名称</th>
                            <th>配置键</th>
                            <th>当前值</th>
                            <th>类型</th>
                            <th>说明</th>
                            <th>更新时间</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
        `;

        items.forEach(config => {
            let displayValue = '';
            if (config.config_type === 'array') {
                displayValue = Array.isArray(config.display_value) 
                    ? config.display_value.join(', ') 
                    : config.display_value;
            } else if (config.config_type === 'boolean') {
                displayValue = config.display_value ? '是' : '否';
            } else {
                displayValue = config.display_value;
            }

            html += `
                <tr>
                    <td><strong>${config.description || config.config_key}</strong></td>
                    <td><code>${config.config_key}</code></td>
                    <td>${displayValue}</td>
                    <td><span class="badge badge-neutral">${config.config_type}</span></td>
                    <td style="color: #86868b; font-size: 13px;">${config.description || '-'}</td>
                    <td>${config.updated_at}</td>
                    <td>
                        <button class="btn-info btn-small" onclick="showEditConfigModal('${config.config_key}', '${config.config_type}', '${displayValue}', '${config.description || ''}')"><i class="ri-edit-line"></i> 编辑</button>
                    </td>
                </tr>
            `;
        });

        html += `
                    </tbody>
                </table>
                </div>
            </div>
        `;
    }

    container.innerHTML = html;
}

// 显示编辑配置弹窗
function showEditConfigModal(configKey, configType, currentValue, description) {
    let inputHtml = '';
    
    switch (configType) {
        case 'boolean':
            const checked = currentValue === '是' || currentValue === '1' || currentValue === 'true';
            inputHtml = `
                <label style="display: flex; align-items: center; gap: 10px; cursor: pointer;">
                    <input type="checkbox" id="configValueInput" ${checked ? 'checked' : ''} style="width: auto;">
                    <span>启用</span>
                </label>
            `;
            break;
            
        case 'int':
        case 'float':
            inputHtml = `<input type="number" id="configValueInput" value="${currentValue}" ${configType === 'float' ? 'step="0.01"' : ''} style="width: 100%;">`;
            break;
            
        case 'array':
            inputHtml = `
                <input type="text" id="configValueInput" value="${currentValue}" placeholder="多个值用逗号分隔" style="width: 100%;">
                <p style="color: var(--text-secondary); font-size: 13px; margin-top: 5px;">提示：多个值用逗号分隔，例如：1,3,5</p>
            `;
            break;
            
        default:
            inputHtml = `<input type="text" id="configValueInput" value="${currentValue}" style="width: 100%;">`;
    }

    const html = `
        <h3><i class="ri-edit-line"></i> 编辑配置</h3>
        <div style="margin: 20px 0;">
            <div class="form-group">
                <label>配置键</label>
                <input type="text" value="${configKey}" disabled style="background: var(--bg-body);">
            </div>
            
            <div class="form-group">
                <label>说明</label>
                <p style="color: var(--text-secondary); margin: 0;">${description || '无'}</p>
            </div>
            
            <div class="form-group">
                <label>配置值</label>
                ${inputHtml}
            </div>
            
            <div class="form-actions">
                <button class="btn-secondary" onclick="document.getElementById('modal').classList.remove('active')">取消</button>
                <button class="btn-primary" onclick="saveConfig('${configKey}', '${configType}')">保存</button>
            </div>
        </div>
    `;

    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = html;
    document.getElementById('modal').classList.add('active');
}

// 保存配置
async function saveConfig(configKey, configType) {
    let configValue;
    const input = document.getElementById('configValueInput');
    
    switch (configType) {
        case 'boolean':
            configValue = input.checked ? '1' : '0';
            break;
        case 'int':
            configValue = parseInt(input.value);
            if (isNaN(configValue)) {
                showToast('请输入有效的整数', 'error');
                return;
            }
            break;
        case 'float':
            configValue = parseFloat(input.value);
            if (isNaN(configValue)) {
                showToast('请输入有效的数字', 'error');
                return;
            }
            break;
        case 'array':
            configValue = input.value.split(',').map(v => v.trim()).filter(v => v);
            break;
        default:
            configValue = input.value;
    }

    try {
        const result = await apiRequest(`${API_BASE}/api/config/update.php`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                config_key: configKey,
                config_value: configValue
            })
        });

        if (result.code === 0 || result.code === 200) {
            showToast('配置更新成功', 'success');
            document.getElementById('modal').classList.remove('active');
            loadSystemConfig();
        } else {
            showToast('更新失败: ' + result.message, 'error');
        }
    } catch (err) {
        showToast('更新失败: ' + err.message, 'error');
    }
}

// ========== 任务审核管理 ==========

// 加载待审核任务列表
async function loadTaskReviewList(page = 1) {
    const bTaskId = document.getElementById('taskReviewBTaskId').value;
    const cUserId = document.getElementById('taskReviewCUserId').value;
    
    try {
        // 构建查询参数
        let params = `page=${page}`;
        if (bTaskId) params += `&b_task_id=${bTaskId}`;
        if (cUserId) params += `&c_user_id=${cUserId}`;
        
        const data = await apiRequest(`${API_BASE}/api/tasks/pending.php?${params}`);
        
        if (data.code === 0) {
            renderTaskReviewTable(data.data.list, data.data.pagination);
        } else {
            showToast('加载待审核任务失败: ' + data.message, 'error');
        }
    } catch (err) {
        console.error('加载待审核任务失败', err);
        showToast('加载待审核任务失败', 'error');
    }
}

function renderTaskReviewTable(list, pagination) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>记录ID</th>
                    <th>任务ID</th>
                    <th>C端用户</th>
                    <th>C端用户ID</th>
                    <th>B端用户</th>
                    <th>B端用户ID</th>
                    <th>模板标题</th>
                    <th>视频链接</th>
                    <th>评论链接</th>
                    <th>截图</th>
                    <th>奖励金额</th>
                    <th>提交时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    if (list.length === 0) {
        html += '<tr><td colspan="13" style="text-align: center; padding: 40px; color: #86868b;">暂无待审核任务</td></tr>';
    } else {
        list.forEach(item => {
            const screenshots = item.screenshots && item.screenshots.length > 0 ? 
                `<a href="javascript:void(0)" onclick="showScreenshots(${JSON.stringify(item.screenshots)})" class="text-primary"><i class="ri-image-line"></i> 查看(${item.screenshots.length})</a>` : '-';
            
            html += `
                <tr>
                    <td>${item.record_id}</td>
                    <td>${item.b_task_id}</td>
                    <td><strong>${item.c_username}</strong></td>
                    <td>${item.c_user_id || '-'}</td>
                    <td>${item.b_username || '-'}</td>
                    <td>${item.b_user_id || '-'}</td>
                    <td>${item.template_title}</td>
                    <td>${item.video_url ? `<a href="${item.video_url}" target="_blank" class="text-primary"><i class="ri-play-circle-line"></i> 查看</a>` : '-'}</td>
                    <td>${item.comment_url ? `<a href="${item.comment_url}" target="_blank" class="text-primary"><i class="ri-link"></i> 查看</a>` : '-'}</td>
                    <td>${screenshots}</td>
                    <td>¥${item.reward_amount}</td>
                    <td>${item.submitted_at}</td>
                    <td>
                        <button class="btn-success btn-small" onclick="reviewTask(${item.record_id}, ${item.b_task_id}, 'approve')"><i class="ri-check-line"></i> 通过</button>
                        <button class="btn-danger btn-small" onclick="reviewTask(${item.record_id}, ${item.b_task_id}, 'reject')"><i class="ri-close-line"></i> 驳回</button>
                    </td>
                </tr>
            `;
        });
    }
    
    html += '</tbody></table></div>';
    
    // 添加分页
    if (pagination) {
        html += `
            <div class="pagination" style="margin-top: 20px; text-align: center;">
                <button class="btn-secondary btn-small" ${pagination.page <= 1 ? 'disabled' : ''} onclick="loadTaskReviewList(${pagination.page - 1})">上一页</button>
                <span style="margin: 0 10px;">第 ${pagination.page} / ${pagination.total_pages} 页</span>
                <button class="btn-secondary btn-small" ${pagination.page >= pagination.total_pages ? 'disabled' : ''} onclick="loadTaskReviewList(${pagination.page + 1})">下一页</button>
            </div>
        `;
    }
    
    document.getElementById('taskReviewTable').innerHTML = html;
}

// 显示截图预览
function showScreenshots(screenshots) {
    const modalBody = document.getElementById('modalBody');
    let html = '<h3><i class="ri-image-line"></i> 任务截图</h3>';
    
    if (!screenshots || !Array.isArray(screenshots) || screenshots.length === 0) {
        html += '<p style="text-align: center; padding: 40px; color: #86868b;">暂无截图</p>';
    } else {
        html += '<div style="display: flex; flex-wrap: wrap; gap: 10px;">';
        screenshots.forEach((url, index) => {
            html += `
                <div style="flex: 1 1 200px; max-width: 300px;">
                    <img src="${url}" style="width: 100%; height: auto; border-radius: 4px;" alt="截图 ${index + 1}">
                </div>
            `;
        });
        html += '</div>';
    }
    
    html += '<div class="form-actions" style="margin-top: 20px;"><button type="button" class="btn-primary" onclick="closeModal()">关闭</button></div>';
    modalBody.innerHTML = html;
    document.getElementById('modal').classList.add('active', 'fullscreen');
}

// 审核任务
function reviewTask(recordId, bTaskId, action) {
    if (action === 'approve') {
        showConfirm('确认通过该任务吗？佣金将自动发放。', async () => {
            try {
                const result = await apiRequest(`${API_BASE}/api/tasks/review.php`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ 
                        record_id: recordId, 
                        b_task_id: bTaskId, 
                        action: 'approve' 
                    })
                });
                
                if (result.code === 0) {
                    showToast(result.message, 'success');
                    loadTaskReviewList();
                } else {
                    showToast(result.message, 'error');
                }
            } catch (err) {
                showToast('审核失败', 'error');
            }
        });
    } else {
        showRejectModal('任务', async (reason) => {
            try {
                const result = await apiRequest(`${API_BASE}/api/tasks/review.php`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ 
                        record_id: recordId, 
                        b_task_id: bTaskId, 
                        action: 'reject',
                        reject_reason: reason 
                    })
                });
                
                if (result.code === 0) {
                    showToast(result.message, 'success');
                    loadTaskReviewList();
                } else {
                    showToast(result.message, 'error');
                }
            } catch (err) {
                showToast('审核失败', 'error');
            }
        });
    }
}

// ========== 放大镜任务管理 ==========

// 加载放大镜任务列表
async function loadMagnifierTasks(page = 1) {
    
    const status = document.getElementById('magnifierStatus')?.value || '';
    
    try {
        const params = new URLSearchParams({ page, pageSize: 10 });
        if (status) {
            params.append('status', status);
        }
        
        const url = `${API_BASE}/api/magnifier/list.php?${params}`;
        
        const data = await apiRequest(url);
        
        if (data.code === 0) {
            renderMagnifierTasksTable(data.data.list, data.data);
        } else {
            console.error('加载放大镜任务失败:', data.message);
            showToast('加载放大镜任务失败: ' + data.message, 'error');
        }
    } catch (err) {
        console.error('加载放大镜任务失败:', err);
        showToast('加载放大镜任务失败', 'error');
    }
}

// 渲染放大镜任务表格
function renderMagnifierTasksTable(list, pagination) {    
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>任务ID</th>
                    <th>任务标题</th>
                    <th>单价</th>
                    <th>总数量</th>
                    <th>总价</th>
                    <th>已完成</th>
                    <th>进行中</th>
                    <th>待审核</th>
                    <th>状态</th>
                    <th>查看状态</th>
                    <th>视频链接</th>
                    <th>蓝词搜索词</th>
                    <th>@用户</th>
                    <th>图片</th>
                    <th>创建时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    if (list.length === 0) {
        html += '<tr><td colspan="15" style="text-align: center; padding: 40px; color: #86868b;">暂无数据</td></tr>';
    } else {
        list.forEach(task => {
            const statusBadge = task.status === 0 ? '<span class="badge badge-neutral">待发布</span>' :
                               task.status === 1 ? '<span class="badge badge-success">发布中</span>' :
                               task.status === 2 ? '<span class="badge badge-info">已完成</span>' :
                               task.status === 3 ? '<span class="badge badge-danger">已取消</span>' :
                               '<span class="badge">未知</span>';
            
            // 处理 recommend_marks
            let recommendMarks = [];
            if (task.recommend_marks) {
                if (typeof task.recommend_marks === 'string') {
                    try {
                        recommendMarks = JSON.parse(task.recommend_marks);
                        if (!Array.isArray(recommendMarks)) {
                            recommendMarks = [recommendMarks];
                        }
                    } catch (e) {
                        console.error('解析 recommend_marks 失败:', e);
                    }
                } else if (Array.isArray(task.recommend_marks)) {
                    recommendMarks = task.recommend_marks;
                } else if (typeof task.recommend_marks === 'object') {
                    recommendMarks = [task.recommend_marks];
                }
            }
            
            // 获取第一个推荐标记
            const firstMark = recommendMarks[0] || {};
            const comment = firstMark.comment || '-';
            const atUser = firstMark.at_user || '-';
            const imageUrl = firstMark.image_url || '';
            
            // 视频链接按钮
            const videoButton = task.video_url ? 
                `<a href="${task.video_url.replace(/`/g, '')}" target="_blank" class="btn-info btn-small"><i class="ri-play-circle-line"></i> 查看</a>` : 
                '-';
            
            // 图片显示
            const imageDisplay = imageUrl ? 
                `<img src="${imageUrl}" style="max-width: 60px; max-height: 60px; border-radius: 4px;" alt="图片">` : 
                '-';
            
            // 计算总价
            const totalPrice = task.total_price || (task.price * task.task_count);
            
            // 查看状态
            const viewStatusBadge = task.view_status === 1 ? '<span class="badge badge-success">已查看</span>' : '<span class="badge badge-warning">未查看</span>';
            
            html += `
                <tr>
                    <td>${task.id}</td>
                    <td><strong>${task.title}</strong></td>
                    <td>¥${task.price}</td>
                    <td>${task.task_count}</td>
                    <td>¥${totalPrice}</td>
                    <td>${task.task_done}</td>
                    <td>${task.task_doing}</td>
                    <td>${task.task_reviewing}</td>
                    <td>${statusBadge}</td>
                    <td>${viewStatusBadge}</td>
                    <td>${videoButton}</td>
                    <td>${comment}</td>
                    <td>${atUser}</td>
                    <td>${imageDisplay}</td>
                    <td>${task.created_at}</td>
                    <td>
                        <button class="btn-info btn-small" onclick="viewMagnifierTaskDetail(${task.id})"><i class="ri-eye-line"></i> 详情</button>
                        ${task.view_status === 0 ? `
                            <button class="btn-info btn-small" onclick="markMagnifierTaskAsViewed(${task.id})"><i class="ri-check-line"></i> 标记已查看</button>
                        ` : ''}
                    </td>
                </tr>
            `;
        });
    }
    
    html += '</tbody></table></div>';
    
    // 添加分页
    if (pagination) {
        html += `
            <div class="pagination" style="margin-top: 20px; text-align: center;">
                <button class="btn-secondary btn-small" ${pagination.page <= 1 ? 'disabled' : ''} onclick="loadMagnifierTasks(${pagination.page - 1})">上一页</button>
                <span style="margin: 0 10px;">第 ${pagination.page} / ${Math.ceil(pagination.total / pagination.pageSize)} 页</span>
                <button class="btn-secondary btn-small" ${pagination.page >= Math.ceil(pagination.total / pagination.pageSize) ? 'disabled' : ''} onclick="loadMagnifierTasks(${pagination.page + 1})">下一页</button>
            </div>
        `;
    }
    
    const tableContainer = document.getElementById('magnifierTable');
    if (tableContainer) {
        tableContainer.innerHTML = html;
    } else {
        console.error('未找到放大镜任务表格容器');
    }
}

// 标记放大镜任务为已查看
async function markMagnifierTaskAsViewed(taskId) {
    try {
        const data = await apiRequest(`${API_BASE}/api/magnifier/mark-viewed.php`, {
            method: 'POST',
            body: JSON.stringify({ task_id: taskId })
        });
        
        if (data.code === 0) {
            showToast('标记成功', 'success');
            loadMagnifierTasks();
        } else {
            showToast(data.message, 'error');
        }
    } catch (error) {
        console.error('标记放大镜任务已查看失败:', error);
        showToast('标记失败', 'error');
    }
}

// 查看放大镜任务详情
async function viewMagnifierTaskDetail(taskId) {
    
    try {
        // 先标记任务为已查看
        await markMagnifierTaskAsViewed(taskId);
        
        const data = await apiRequest(`${API_BASE}/api/magnifier/detail.php?id=${taskId}`);
        
        if (data.code === 0) {
            showMagnifierTaskDetailModal(data.data);
        } else {
            showToast('获取详情失败: ' + data.message, 'error');
        }
    } catch (err) {
        console.error('获取详情失败:', err);
        showToast('获取详情失败', 'error');
    }
}

// 显示放大镜任务详情模态框
function showMagnifierTaskDetailModal(data) {
    const task = data.task;
    const records = data.records || [];
    
    // 处理 recommend_marks
    let recommendMarks = [];
    if (task.recommend_marks) {
        if (typeof task.recommend_marks === 'string') {
            try {
                recommendMarks = JSON.parse(task.recommend_marks);
                if (!Array.isArray(recommendMarks)) {
                    recommendMarks = [recommendMarks];
                }
            } catch (e) {
                console.error('解析 recommend_marks 失败:', e);
            }
        } else if (Array.isArray(task.recommend_marks)) {
            recommendMarks = task.recommend_marks;
        } else if (typeof task.recommend_marks === 'object') {
            recommendMarks = [task.recommend_marks];
        }
    }
    
    const modalBody = document.getElementById('modalBody');
    let html = `
        <div class="ticket-chat-container">
            <div class="ticket-header">
                <h3><i class="ri-eye-line" style="margin-right: 12px; color: var(--primary-color);"></i> 放大镜任务详情 #${task.id}</h3>
                <div class="stats-grid" style="grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; margin-top: 16px;">
                    <div class="stat-card">
                        <h3 style="margin-bottom: 12px;"><i class="ri-task-line"></i> 任务状态</h3>
                        <div class="stat-item">
                            <span class="stat-label">状态</span>
                            <span class="stat-value">${task.status_text}</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-label">单价</span>
                            <span class="stat-value">¥${task.price}</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-label">总价</span>
                            <span class="stat-value">¥${task.total_price || (task.price * task.task_count)}</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <h3 style="margin-bottom: 12px;"><i class="ri-bar-chart-2-line"></i> 任务进度</h3>
                        <div class="stat-item">
                            <span class="stat-label">总数量</span>
                            <span class="stat-value">${task.task_count}</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-label">已完成</span>
                            <span class="stat-value">${task.task_done}</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-label">进行中</span>
                            <span class="stat-value">${task.task_doing}</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-label">待审核</span>
                            <span class="stat-value">${task.task_reviewing}</span>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="chat-messages" style="padding: 32px;">
                <div class="card" style="margin-bottom: 24px;">
                    <div class="card-header" style="margin-bottom: 16px;">
                        <div class="card-title">任务详情</div>
                    </div>
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 16px;">
                        <div class="form-group">
                            <label>任务标题</label>
                            <div style="background: var(--bg-body); border: 1px solid var(--border-color); border-radius: var(--radius-sm); padding: 12px; font-weight: 500;">
                                ${task.title}
                            </div>
                        </div>
                        <div class="form-group">
                            <label>视频链接</label>
                            <div>
                                ${task.video_url ? 
                                    `<a href="${task.video_url.replace(/`/g, '')}" target="_blank" class="text-primary" style="display: inline-flex; align-items: center; gap: 6px;"><i class="ri-play-circle-line"></i> 查看视频</a>` : 
                                    '<span style="color: var(--text-secondary);">无</span>'
                                }
                            </div>
                        </div>
                        <div class="form-group">
                            <label>创建时间</label>
                            <div style="background: var(--bg-body); border: 1px solid var(--border-color); border-radius: var(--radius-sm); padding: 12px;">
                                ${task.created_at}
                            </div>
                        </div>
                        <div class="form-group">
                            <label>更新时间</label>
                            <div style="background: var(--bg-body); border: 1px solid var(--border-color); border-radius: var(--radius-sm); padding: 12px;">
                                ${task.updated_at}
                            </div>
                        </div>
                    </div>
                </div>
                
                ${recommendMarks.length > 0 ? `
                    <div class="card" style="margin-bottom: 24px;">
                        <div class="card-header" style="margin-bottom: 16px;">
                            <div class="card-title">推荐标记</div>
                        </div>
                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 16px;">
                            ${recommendMarks.map((mark, index) => `
                                <div style="border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 20px; background: var(--bg-body);">
                                    <div style="font-weight: 600; margin-bottom: 12px; color: var(--text-primary); display: flex; align-items: center; gap: 8px;">
                                        <i class="ri-tag-line" style="color: var(--primary-color);"></i>
                                        标记 ${index + 1}
                                    </div>
                                    <div style="space-y: 8px;">
                                        <div style="margin-bottom: 8px;">
                                            <span style="color: var(--text-secondary); font-size: 13px;">@用户:</span>
                                            <span style="margin-left: 8px; font-weight: 500;">${mark.at_user || '-'}</span>
                                        </div>
                                        <div style="margin-bottom: 8px;">
                                            <span style="color: var(--text-secondary); font-size: 13px;">蓝词搜索:</span>
                                            <span style="margin-left: 8px; font-weight: 500;">${mark.comment || '-'}</span>
                                        </div>
                                        <div style="margin-bottom: 8px;">
                                            <span style="color: var(--text-secondary); font-size: 13px;">图片:</span>
                                            <div style="margin-left: 8px; margin-top: 8px;">
                                                ${mark.image_url ? 
                                                    `<img src="${mark.image_url}" style="max-width: 100%; max-height: 200px; border-radius: var(--radius-sm); object-fit: cover;" alt="图片">` : 
                                                    '<span style="color: var(--text-secondary);">无</span>'
                                                }
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            `).join('')}
                        </div>
                    </div>
                ` : ''}
                
                ${records.length > 0 ? `
                    <div class="card">
                        <div class="card-header" style="margin-bottom: 16px;">
                            <div class="card-title">任务记录</div>
                        </div>
                        <div class="table-container">
                            <table>
                                <thead>
                                    <tr>
                                        <th>记录ID</th>
                                        <th>C端用户</th>
                                        <th>状态</th>
                                        <th>创建时间</th>
                                        <th>审核时间</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    ${records.map(record => `
                                        <tr>
                                            <td>${record.id}</td>
                                            <td>${record.c_username}</td>
                                            <td>${record.status_text}</td>
                                            <td>${record.created_at}</td>
                                            <td>${record.reviewed_at || '-'}</td>
                                        </tr>
                                    `).join('')}
                                </tbody>
                            </table>
                        </div>
                    </div>
                ` : ''}
            </div>
            
            <div class="chat-input-area">
                <div class="form-actions" style="margin: 0;">
                    <button class="btn-primary" onclick="closeModal()" style="flex: 1; justify-content: center;">
                        <i class="ri-close-line"></i> 关闭
                    </button>
                </div>
            </div>
        </div>
    `;
    
    modalBody.innerHTML = html;
    document.getElementById('modal').classList.add('active', 'fullscreen');
}

// 团长升级相关功能

// 加载C端用户列表用于升级
async function loadCUsersForUpgrade(page = 1) {
    const username = document.getElementById('agentUpgradeUsername').value;
    const userId = document.getElementById('agentUpgradeUserId').value;
    
    try {
        let url = `${API_BASE}/api/agent/c-users-list.php?page=${page}`;
        if (username) {
            url += `&username=${encodeURIComponent(username)}`;
        }
        if (userId) {
            url += `&user_id=${userId}`;
        }
        
        const data = await apiRequest(url);
        
        if (data.code === 0) {
            renderAgentUpgradeTable(data.data.list, data.data);
        } else {
            showToast('加载用户列表失败: ' + data.message, 'error');
        }
    } catch (err) {
        console.error('加载C端用户失败', err);
        showToast('加载用户列表失败', 'error');
    }
}

// 渲染团长升级用户列表
function renderAgentUpgradeTable(list, pagination) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>用户名</th>
                    <th>当前等级</th>
                    <th>注册时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    if (list.length === 0) {
        html += `
            <tr>
                <td colspan="5" style="text-align: center; padding: 40px;">
                    <i class="ri-search-line" style="font-size: 48px; color: #ccc;"></i>
                    <p style="margin-top: 16px; color: #888;">未找到符合条件的用户</p>
                </td>
            </tr>
        `;
    } else {
        list.forEach(u => {
            let levelText = '普通用户';
            let levelClass = 'badge-neutral';
            
            if (u.is_agent === 1) {
                levelText = '团长';
                levelClass = 'badge-success';
            } else if (u.is_agent === 2) {
                levelText = '高级团长';
                levelClass = 'badge-warning';
            } else if (u.is_agent === 3) {
                levelText = '大团团长';
                levelClass = 'badge-danger';
            }
            
            let actions = '';
            if (u.is_agent === 0) {
                actions = `
                    <button class="btn-success btn-small" onclick="upgradeToAgent(${u.id}, '${u.username}', 1)"><i class="ri-arrow-up-circle-line"></i> 升级成团长</button>
                    <button class="btn-warning btn-small" onclick="upgradeToAgent(${u.id}, '${u.username}', 2)"><i class="ri-arrow-up-circle-line"></i> 升级成高级团长</button>
                    <button class="btn-danger btn-small" onclick="upgradeToAgent(${u.id}, '${u.username}', 3)"><i class="ri-arrow-up-circle-line"></i> 升级成大团团长</button>
                `;
            } else if (u.is_agent === 1) {
                actions = `
                    <button class="btn-warning btn-small" onclick="upgradeToAgent(${u.id}, '${u.username}', 2)"><i class="ri-arrow-up-circle-line"></i> 升级成高级团长</button>
                    <button class="btn-danger btn-small" onclick="upgradeToAgent(${u.id}, '${u.username}', 3)"><i class="ri-arrow-up-circle-line"></i> 升级成大团团长</button>
                `;
            } else if (u.is_agent === 2) {
                actions = `
                    <button class="btn-danger btn-small" onclick="upgradeToAgent(${u.id}, '${u.username}', 3)"><i class="ri-arrow-up-circle-line"></i> 升级成大团团长</button>
                `;
            } else {
                actions = '<span class="text-gray">已是最高等级</span>';
            }
            
            html += `
                <tr>
                    <td>${u.id}</td>
                    <td><strong>${u.username}</strong></td>
                    <td><span class="badge ${levelClass}">${levelText}</span></td>
                    <td>${u.created_at}</td>
                    <td>${actions}</td>
                </tr>
            `;
        });
    }
    
    html += '</tbody></table></div>';
    
    // 添加分页
    if (pagination && pagination.total_pages > 1) {
        html += `
            <div class="pagination" style="margin-top: 20px; text-align: center;">
                <button class="btn-secondary btn-small" ${pagination.page > 1 ? '' : 'disabled'} onclick="loadCUsersForUpgrade(${pagination.page - 1})"><i class="ri-arrow-left-line"></i> 上一页</button>
                <span style="margin: 0 20px;">第 ${pagination.page} 页，共 ${pagination.total_pages} 页</span>
                <button class="btn-secondary btn-small" ${pagination.page < pagination.total_pages ? '' : 'disabled'} onclick="loadCUsersForUpgrade(${pagination.page + 1})"><i class="ri-arrow-right-line"></i> 下一页</button>
            </div>
        `;
    }
    
    document.getElementById('agentUpgradeTable').innerHTML = html;
}

// 升级用户为团长、高级团长或大团团长
function upgradeToAgent(userId, username, level) {
    let levelText = '团长';
    if (level === 2) {
        levelText = '高级团长';
    } else if (level === 3) {
        levelText = '大团团长';
    }
    
    showConfirm(`确认将用户 ${username} (ID: ${userId}) 升级为${levelText}吗？`, async () => {
        try {
            const res = await apiRequest(`${API_BASE}/api/agent/upgrade-to-senior.php`, {
                method: 'POST',
                body: JSON.stringify({ user_id: userId, level: level })
            });
            
            if (res.code === 0) {
                showToast(res.message, 'success');
                loadCUsersForUpgrade();
            } else {
                showToast(res.message, 'error');
            }
        } catch (err) {
            console.error('升级失败', err);
            showToast('升级失败，请检查网络连接', 'error');
        }
    });
}

// 重置团长升级搜索
function resetAgentUpgradeSearch() {
    document.getElementById('agentUpgradeUsername').value = '';
    document.getElementById('agentUpgradeUserId').value = '';
    loadCUsersForUpgrade();
}

// 初始化团长升级面板
function initAgentUpgradePanel() {
    // 页面切换时加载数据
    const agentUpgradeSection = document.getElementById('agentUpgradeSection');
    if (agentUpgradeSection) {
        agentUpgradeSection.addEventListener('click', (e) => {
            if (e.target.closest('.content-section')) {
                loadCUsersForUpgrade();
            }
        });
    }
}

// 页面切换时加载团长升级数据
function switchToPage(page) {
    // 更新导航高亮
    document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
    const targetLink = document.querySelector(`.nav-link[data-page="${page}"]`);
    if (targetLink) {
        targetLink.classList.add('active');
    }
    
    // 切换内容区
    document.querySelectorAll('.content-section').forEach(section => {
        section.classList.remove('active');
    });
    
    // 处理特殊页面的section ID映射
    let sectionId = `${page}Section`;
    if (page === 'agent-upgrade') {
        sectionId = 'agentUpgradeSection';
    } else if (page === 'notification-logs') {
        sectionId = 'notification-logsSection';
    }
    
    const targetSection = document.getElementById(sectionId);
    if (targetSection) {
        targetSection.classList.add('active');
    }
    
    // 保存当前页面到localStorage
    localStorage.setItem('admin_current_page', page);
    
    // 加载对应数据
    switch(page) {
        case 'dashboard': loadDashboard(); break;
        case 'b-users': loadBUsers(); break;
        case 'c-users': loadCUsers(); break;
        case 'system-users': loadSystemUsers(); break;
        case 'system-roles': loadSystemRoles(); break;
        case 'system-permissions': loadSystemPermissions(); break;
        case 'templates': loadTaskTemplates(); break;
        case 'market': loadMarketTasks(); break;
        case 'wallet-logs': loadWalletLogs(); break;
        case 'recharge': loadRechargeList(); break;
        case 'withdraw': loadWithdrawList(); break;
        case 'agent': loadAgentList(); break;
        case 'agent-upgrade': loadCUsersForUpgrade(); break;
        case 'rental-orders': loadRentalOrders(); break;
        case 'rental-tickets': loadTickets(); break;
        case 'system-config': loadSystemConfig(); break;
        case 'task-review': loadTaskReviewList(); break;
        case 'notifications': loadNotificationList(); break;
        case 'notification-logs': loadNotificationLogs(); break;
        case 'magnifier': loadMagnifierTasks(); break;
    }
}


