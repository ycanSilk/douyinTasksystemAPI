// API基础URL
const API_BASE = '/task_admin';

// 全局状态
let currentUser = null;

// 初始化
document.addEventListener('DOMContentLoaded', () => {
    initLoginForm();
    initLogout();
    initNavigation();
    initModal();
    
    // 检查登录状态
    checkLoginStatus();
});

// 检查登录状态
function checkLoginStatus() {
    // Session存储，刷新后自动跳转
    if (sessionStorage.getItem('admin_logged_in')) {
        showMainPage();
        // 恢复上次选中的页面
        const lastPage = localStorage.getItem('admin_current_page') || 'dashboard';
        switchToPage(lastPage);
    }
}

// 登录表单
function initLoginForm() {
    const form = document.getElementById('loginForm');
    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const username = document.getElementById('username').value;
        const password = document.getElementById('password').value;
        const errorDiv = document.getElementById('loginError');
        
        // MD5加密密码
        const hashedPassword = md5(password);
        
        try {
            const res = await fetch(`${API_BASE}/auth/login.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ username, password: hashedPassword })
            });
            
            const data = await res.json();
            
            if (data.code === 0) {
                sessionStorage.setItem('admin_logged_in', 'true');
                sessionStorage.setItem('admin_username', data.data.username);
                currentUser = data.data;
                showMainPage();
                // 新登录时默认跳转到统计面板
                switchToPage('dashboard');
            } else {
                errorDiv.innerHTML = `<i class="ri-error-warning-line"></i> ${data.message}`;
            }
        } catch (err) {
            errorDiv.innerHTML = `<i class="ri-wifi-off-line"></i> 登录失败，请检查网络连接`;
        }
    });
}

// 显示主页面
function showMainPage() {
    document.getElementById('loginPage').classList.remove('active');
    document.getElementById('mainPage').classList.add('active');
    document.querySelector('.username-display').textContent = sessionStorage.getItem('admin_username');
}

// 登出
function initLogout() {
    document.getElementById('logoutBtn').addEventListener('click', async () => {
        try {
            await fetch(`${API_BASE}/auth/logout.php`, { method: 'POST' });
        } catch (err) {}
        
        sessionStorage.clear();
        localStorage.removeItem('admin_current_page'); // 清除页面记忆
        document.getElementById('mainPage').classList.remove('active');
        document.getElementById('loginPage').classList.add('active');
        document.getElementById('loginError').textContent = '';
        document.getElementById('loginForm').reset();
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
        case 'templates': loadTaskTemplates(); break;
        case 'market': loadMarketTasks(); break;
        case 'wallet-logs': loadWalletLogs(); break;
        case 'recharge': loadRechargeList(); break;
        case 'withdraw': loadWithdrawList(); break;
        case 'agent': loadAgentList(); break;
        case 'rental-orders': loadRentalOrders(); break;
        case 'rental-tickets': loadTickets(); break;
        case 'system-config': loadSystemConfig(); break;
        case 'notifications': loadNotificationList(); break;
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

// 加载统计面板
async function loadDashboard() {
    try {
        const res = await fetch(`${API_BASE}/api/stats/dashboard.php`);
        const data = await res.json();
        
        if (data.code === 0) {
            const d = data.data;
            
            // 任务统计
            document.getElementById('stat_total_tasks').textContent = String(d.tasks?.total ?? 0);
            document.getElementById('stat_today_tasks').textContent = String(d.tasks?.today_total ?? 0);
            document.getElementById('stat_today_reviewing').textContent = String(d.tasks?.today_reviewing ?? 0);
            document.getElementById('stat_today_doing').textContent = String(d.tasks?.today_doing ?? 0);
            document.getElementById('stat_today_completed').textContent = String(d.tasks?.today_completed ?? 0);
            document.getElementById('stat_today_rejected').textContent = String(d.tasks?.today_rejected ?? 0);
            
            // 流水统计
            document.getElementById('stat_total_revenue').textContent = '¥' + (d.revenue?.total ?? '0.00');
            document.getElementById('stat_today_revenue').textContent = '¥' + (d.revenue?.today ?? '0.00');
            document.getElementById('stat_7days_revenue').textContent = '¥' + (d.revenue?.['7_days'] ?? '0.00');
            document.getElementById('stat_30days_revenue').textContent = '¥' + (d.revenue?.['30_days'] ?? '0.00');
            
            // 利润统计
            document.getElementById('stat_total_profit').textContent = '¥' + (d.profit?.total ?? '0.00');
            document.getElementById('stat_today_profit').textContent = '¥' + (d.profit?.today ?? '0.00');
            document.getElementById('stat_7days_profit').textContent = '¥' + (d.profit?.['7_days'] ?? '0.00');
            document.getElementById('stat_30days_profit').textContent = '¥' + (d.profit?.['30_days'] ?? '0.00');
            
            // 团长佣金
            document.getElementById('stat_total_commission').textContent = '¥' + (d.agent_commission?.total ?? '0.00');
            document.getElementById('stat_7days_commission').textContent = '¥' + (d.agent_commission?.['7_days'] ?? '0.00');
            document.getElementById('stat_30days_commission').textContent = '¥' + (d.agent_commission?.['30_days'] ?? '0.00');
        } else {
            console.error('加载统计数据失败', data);
            showToast('加载统计数据失败: ' + data.message, 'error');
        }
    } catch (err) {
        console.error('加载统计数据失败', err);
        showToast('加载统计数据失败', 'error');
    }
}

// 加载B端用户列表
async function loadBUsers(page = 1) {
    const search = document.getElementById('bUserSearch').value;
    try {
        const res = await fetch(`${API_BASE}/api/b_users/list.php?page=${page}&search=${encodeURIComponent(search)}`);
        const data = await res.json();
        
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
            const res = await fetch(`${API_BASE}/api/b_users/update.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            const result = await res.json();
            
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

// 加载C端用户列表
async function loadCUsers(page = 1) {
    const search = document.getElementById('cUserSearch').value;
    try {
        const res = await fetch(`${API_BASE}/api/c_users/list.php?page=${page}&search=${encodeURIComponent(search)}`);
        const data = await res.json();
        
        if (data.code === 0) {
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
                    <th>团长</th>
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
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    list.forEach(u => {
        const statusBadge = u.status === 1 ? '<span class="badge badge-success">正常</span>' : '<span class="badge badge-danger">禁用</span>';
        const agentBadge = u.is_agent === 2 ? '<span class="badge badge-warning"><i class="ri-vip-diamond-fill"></i> 高级团长</span>' : u.is_agent === 1 ? '<span class="badge badge-success"><i class="ri-vip-crown-fill"></i> 普通团长</span>' : '<span class="badge badge-neutral">普通用户</span>';
        html += `
            <tr>
                <td>${u.id}</td>
                <td><strong>${u.username}</strong></td>
                <td>${u.email}</td>
                <td>${u.phone || '-'}</td>
                <td>${u.invite_code}</td>
                <td>${u.parent_id || '-'}</td>
                <td>${u.parent_username || '-'}</td>
                <td>${agentBadge}</td>
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
                    <button class="btn-info btn-small" onclick='editCUser(${JSON.stringify(u)})'><i class="ri-edit-line"></i> 编辑</button>
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
                </select>
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
            const res = await fetch(`${API_BASE}/api/c_users/update.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            const result = await res.json();
            
            if (result.code === 0) {
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

// 加载充值列表
async function loadRechargeList(page = 1) {
    const status = document.getElementById('rechargeStatus').value;
    try {
        const res = await fetch(`${API_BASE}/api/recharge/list.php?page=${page}&status=${status}`);
        const data = await res.json();
        
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
                <td>¥${r.amount}</td>
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
                const res = await fetch(`${API_BASE}/api/recharge/review.php`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ id, action: 'approve' })
                });
                const result = await res.json();
                
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
                const res = await fetch(`${API_BASE}/api/recharge/review.php`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ id, action: 'reject', reject_reason: reason })
                });
                const result = await res.json();
                
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
        const res = await fetch(`${API_BASE}/api/withdraw/list.php?page=${page}&status=${status}`);
        const data = await res.json();
        
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
                const res = await fetch(`${API_BASE}/api/withdraw/review.php`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ id, action: 'reject', reject_reason: reason })
                });
                const result = await res.json();
                
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
            
            const res = await fetch(`${API_BASE}/api/upload.php`, {
                method: 'POST',
                body: formData
            });
            const result = await res.json();
            
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
                const res = await fetch(`${API_BASE}/api/withdraw/review.php`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ id, action: 'approve', img_url: imgUrl })
                });
                const result = await res.json();
                
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
        const res = await fetch(`${API_BASE}/api/agent/list.php?page=${page}&status=${status}`);
        const data = await res.json();
        
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
                const res = await fetch(`${API_BASE}/api/agent/review.php`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ id, action: 'approve' })
                });
                const result = await res.json();
                
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
                const res = await fetch(`${API_BASE}/api/agent/review.php`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ id, action: 'reject', reject_reason: reason })
                });
                const result = await res.json();
                
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

// ========== 任务模板管理 ==========

// 加载任务模板列表
async function loadTaskTemplates(page = 1) {
    const type = document.getElementById('templateType')?.value || '';
    const status = document.getElementById('templateStatus')?.value || '';
    
    try {
        const res = await fetch(`${API_BASE}/api/tasks/list.php?page=${page}&type=${type}&status=${status}`);
        const data = await res.json();
        
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
            const res = await fetch(`${API_BASE}/api/tasks/create.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            const result = await res.json();
            
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
            const res = await fetch(`${API_BASE}/api/tasks/delete.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ id })
            });
            const result = await res.json();
            
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
            const res = await fetch(`${API_BASE}/api/tasks/update.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            const result = await res.json();
            
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
        const res = await fetch(`${API_BASE}/api/wallet_logs/list.php?${params}`);
        const data = await res.json();
        
        if (data.code === 0) {
            renderWalletLogsTable(data.data.list, data.data.pagination);
        }
    } catch (err) {
        console.error('加载钱包记录失败', err);
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
        const res = await fetch(`${API_BASE}/api/market/list.php?${params}`);
        const data = await res.json();
        
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
        const res = await fetch(`${API_BASE}/api/notifications/list.php?${params}`);
        const data = await res.json();
        
        if (data.code === 0) {
            renderNotificationList(data.data.list, data.data.pagination);
        } else {
            showToast('加载失败: ' + data.message, 'error');
        }
    } catch (err) {
        showToast('加载失败: ' + err.message, 'error');
    }
}

// 渲染通知列表
function renderNotificationList(list, pagination) {
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
        const res = await fetch(`${API_BASE}/api/notifications/send.php`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        
        const data = await res.json();
        
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
        const res = await fetch(`${API_BASE}/api/rental_orders/list.php?${params}`);
        const data = await res.json();

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
            const res = await fetch(`${API_BASE}/api/rental_orders/dispatch.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ order_id: orderId, action })
            });
            const result = await res.json();

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
        const res = await fetch(`${API_BASE}/api/rental_tickets/list.php?${params}`);
        const result = await res.json();

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
        const res = await fetch(`${API_BASE}/api/rental_tickets/detail.php?ticket=${ticketId}`);
        const result = await res.json();

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
            const res = await fetch(`${API_BASE}/api/upload.php`, {
                method: 'POST',
                body: formData
            });
            const result = await res.json();

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
        const res = await fetch(`${API_BASE}/api/rental_tickets/send-message.php`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        const result = await res.json();

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
        const res = await fetch(`${API_BASE}/api/rental_tickets/close.php`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ ticket_id: ticketId, close_reason: reason })
        });
        const result = await res.json();

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
        const res = await fetch(`${API_BASE}/api/config/list.php?${params}`);
        const result = await res.json();

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
        'rental': '租赁配置'
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
        const res = await fetch(`${API_BASE}/api/config/update.php`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                config_key: configKey,
                config_value: configValue
            })
        });
        const result = await res.json();

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
