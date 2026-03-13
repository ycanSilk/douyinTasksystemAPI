// API基础URL已替换为硬编码路径


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
        
        await apiRequest(`/task_admin/api/logs/save.php`, {
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





// 引入API配置和请求方法
// 注意：实际项目中需要在HTML中添加<script src="assets/js/apiconfig.js"></script>引用

// 初始化
function init() {
    checkLoginStatus();
    initLogout();
    initNavigation();
    initModal();
    // 初始化B端用户交易流水搜索表单
    console.log('检查initBStatisticsForm函数是否存在:', typeof initBStatisticsForm === 'function');
    if (typeof initBStatisticsForm === 'function') {
        console.log('调用initBStatisticsForm函数');
        initBStatisticsForm();
    } else {
        console.log('initBStatisticsForm函数不存在，可能b-user-list.js未正确加载');
    }
}

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
            window.location.href = `/task_admin/login.html`;
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
    console.log('开始加载导航栏');
    try {
        const url = `/task_admin/api/system_permission_template/list.php`;
        console.log('导航栏API URL:', url);
        
        // 使用传统的fetch方法
        const token = sessionStorage.getItem('admin_token');
        console.log('获取到的token:', token ? '存在' : '不存在');
        
        console.log('开始发送API请求');
        const response = await fetch(url + `?t=${Date.now()}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
                ...(token && { 'Authorization': `Bearer ${token}` })
            }
        });
        
        console.log('API请求完成，状态码:', response.status, '状态文本:', response.statusText);
        
        // 检查响应状态码
        if (!response.ok) {
            console.error('加载导航栏失败: 状态码', response.status, response.statusText);
            showToast(`加载导航栏失败: ${response.status} ${response.statusText}`, 'error');
            return;
        }
        
        // 尝试解析JSON
        try {
            console.log('开始解析响应JSON');
            const data = await response.json();
            console.log('响应JSON解析完成:', data);
            
            if (data && data.code === 0) {
                console.log('导航栏面板响应成功，数据数量:', data.data ? data.data.length : 0);
                renderNavigation(data.data);
            } else if (data) {
                console.error('加载导航栏失败:', data.message);
                showToast('加载导航栏失败: ' + (data.message || '未知错误'), 'error');
            } else {
                console.error('加载导航栏失败: 响应数据为undefined');
                showToast('加载导航栏失败', 'error');
            }
        } catch (e) {
            console.error('响应格式错误:', e);
            showToast('响应格式错误', 'error');
        }
    } catch (err) {
        console.error('加载导航栏失败:', err);
        showToast('网络请求失败，请检查网络连接', 'error');
    } finally {
        console.log('导航栏加载过程完成');
    }
}

// 渲染导航栏
function renderNavigation(templates) {
    console.log('开始渲染导航栏，模板数量:', templates.length);
    
    const navMenu = document.getElementById('navMenu');
    console.log('导航菜单元素:', navMenu);
    
    if (!navMenu) {
        console.error('导航菜单元素不存在');
        return;
    }
    
    navMenu.innerHTML = '';
    console.log('清空导航菜单');
    
    // 按 parent_id 分组导航项
    const menuMap = {};
    console.log('开始构建菜单映射');
    
    templates.forEach((template, index) => {
        console.log(`处理模板 ${index}:`, template);
        // 确保parent_id是数字类型，NULL或undefined时设为0
        const parentId = template.parent_id ? parseInt(template.parent_id) : 0;
        console.log(`  父ID: ${parentId}`);
        
        if (!menuMap[parentId]) {
            menuMap[parentId] = [];
            console.log(`  创建新的父ID组: ${parentId}`);
        }
        menuMap[parentId].push(template);
        console.log(`  添加到父ID组 ${parentId}，当前数量:`, menuMap[parentId].length);
    });
    
    console.log('菜单映射构建完成:', menuMap);
    
    // 渲染一级导航项（parent_id = 0）
    const level1Items = menuMap[0] || [];
    console.log('一级导航项数量:', level1Items.length);
    
    level1Items.forEach((item, index) => {
        console.log(`渲染一级导航项 ${index}:`, item);
        
        const li = document.createElement('li');
        li.className = 'nav-item';
        console.log(`  创建导航项元素:`, li);
        
        const a = document.createElement('a');
        a.href = '#';
        a.className = 'nav-link';
        a.dataset.page = item.code;
        if (item.section_id) {
            a.dataset.sectionId = item.section_id;
        }
        console.log(`  创建链接元素:`, a);
        
        // 检查是否有子导航项
        const itemId = parseInt(item.id);
        const hasChildren = menuMap[itemId] && menuMap[itemId].length > 0;
        console.log(`  导航项ID: ${itemId}, 是否有子导航项:`, hasChildren);
        if (hasChildren) {
            console.log(`  子导航项数量:`, menuMap[itemId].length);
            console.log(`  子导航项列表:`, menuMap[itemId]);
        }
        
        // 为所有一级导航项创建带折叠图标的结构
        // 创建容器div
        const div = document.createElement('div');
        div.style.display = 'flex';
        div.style.alignItems = 'center';
        div.style.justifyContent = 'space-between';
        div.style.width = '100%';
        
        // 创建左侧span
        const span = document.createElement('span');
        
        // 创建图标
        const icon = document.createElement('i');
        icon.className = item.icon;
        
        // 创建文本
        const text = document.createTextNode(` ${item.name}`);
        
        // 组装左侧span
        span.appendChild(icon);
        span.appendChild(text);
        
        // 创建右侧toggle图标
        const toggleIcon = document.createElement('i');
        toggleIcon.className = 'ri-arrow-down-s-line toggle-icon';
        
        // 组装div
        div.appendChild(span);
        div.appendChild(toggleIcon);
        
        // 添加到链接
        a.appendChild(div);
        console.log(`  设置带折叠图标的链接内容`);
        
        // 添加点击事件用于折叠/展开
        a.addEventListener('click', (e) => {
            e.preventDefault();
            const subMenu = li.querySelector('.sub-menu');
            const toggleIcon = a.querySelector('.toggle-icon');
            console.log(`  点击折叠/展开，子菜单:`, subMenu, '图标:', toggleIcon);
            
            if (subMenu) {
                subMenu.classList.toggle('active');
                toggleIcon.classList.toggle('ri-arrow-down-s-line');
                toggleIcon.classList.toggle('ri-arrow-up-s-line');
                console.log(`  切换子菜单显示状态:`, subMenu.classList.contains('active'));
            }
            
            // 如果没有子导航项，直接跳转到对应页面
            if (!hasChildren) {
                const page = a.dataset.page;
                console.log(`  没有子导航项，直接跳转到页面:`, page);
                switchToPage(page);
            }
        });
        
        li.appendChild(a);
        console.log(`  添加链接到导航项`);
        
        // 为所有一级导航项创建二级导航面板
        const subMenu = document.createElement('ul');
        subMenu.className = 'sub-menu';
        console.log(`  创建子菜单元素:`, subMenu);
        
        // 如果有子导航项，渲染它们
        if (hasChildren) {
            menuMap[itemId].forEach((child, childIndex) => {
                console.log(`  渲染二级导航项 ${childIndex}:`, child);
                
                const subLi = document.createElement('li');
                subLi.className = 'sub-nav-item';
                console.log(`    创建子导航项元素:`, subLi);
                
                const subA = document.createElement('a');
                subA.href = '#';
                subA.className = 'sub-nav-link';
                subA.dataset.page = child.code;
                if (child.section_id) {
                    subA.dataset.sectionId = child.section_id;
                }
                
                // 创建图标元素
                const icon = document.createElement('i');
                icon.className = child.icon;
                
                // 创建文本节点
                const text = document.createTextNode(` ${child.name}`);
                
                // 组装元素
                subA.appendChild(icon);
                subA.appendChild(text);
                
                console.log(`    创建子链接元素:`, subA);
                
                subA.addEventListener('click', (e) => {
                    e.preventDefault();
                    const page = subA.dataset.page;
                    console.log(`    点击子导航项，页面:`, page);
                    switchToPage(page);
                });
                
                subLi.appendChild(subA);
                console.log(`    添加子链接到子导航项`);
                
                subMenu.appendChild(subLi);
                console.log(`    添加子导航项到子菜单`);
            });
        }
        
        li.appendChild(subMenu);
        console.log(`  添加子菜单到导航项`);
        
        navMenu.appendChild(li);
        console.log(`  添加导航项到导航菜单`);
    });
    
    console.log('导航栏渲染完成');
}

// 登出
function initLogout() {
    document.getElementById('logoutBtn').addEventListener('click', async () => {
        try {
            await apiRequest(`/task_admin/auth/logout.php`, { method: 'POST' });
        } catch (err) {}
        
        sessionStorage.clear();
        localStorage.removeItem('admin_current_page'); // 清除页面记忆
        
        // 重定向到登录页面
        window.location.href = `/task_admin/login.html`;
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
    document.querySelectorAll('.nav-link, .sub-nav-link').forEach(l => l.classList.remove('active'));
    const targetLink = document.querySelector(`.nav-link[data-page="${page}"]`) || document.querySelector(`.sub-nav-link[data-page="${page}"]`);
    if (targetLink) {
        targetLink.classList.add('active');
    }
    
    // 切换内容区
    document.querySelectorAll('.content-section').forEach(section => {
        section.classList.remove('active');
    });
    
    // 获取section ID - 优先使用data-sectionId属性，然后使用默认规则
    let sectionId = `${page}Section`;
    if (targetLink && targetLink.dataset.sectionId) {
        sectionId = targetLink.dataset.sectionId;
        console.log(`使用数据集中的section_id: ${sectionId}`);
    }
    
    const targetSection = document.getElementById(sectionId);
    if (targetSection) {
        targetSection.classList.add('active');
    } else {
        console.warn(`未找到section元素: ${sectionId}`);
    }
    
    // 保存当前页面到localStorage
    localStorage.setItem('admin_current_page', page);
    
    // 加载对应数据
    switch(page) {
        case 'dashboard': loadDashboard(); break;
        case 'b-users': loadBUsers(); break;
        case 'b-statistics-flows': loadBStatistics(); break;
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
        case 'notification-logs': 
            loadNotifications(1, '', '0'); // 默认加载未读消息
            loadNotificationLogs();
            break;
        case 'magnifier': loadMagnifierTasks(); break;
    }
    
    // 处理B端和C端交易流水页面的内容显示
    if (page === 'b-statistics-flows' || page === 'b-statistics-summary') {
        // 显示交易流水内容，隐藏统计内容
        document.getElementById('b-statistics-flows-content').style.display = page === 'b-statistics-flows' ? 'block' : 'none';
        document.getElementById('b-statistics-summary-content').style.display = page === 'b-statistics-summary' ? 'block' : 'none';
        
        // 当切换到B端交易流水页面时，重新初始化搜索表单
        if (page === 'b-statistics-flows') {
            console.log('切换到b-statistics-flows页面，检查bStatisticsForm元素');
            setTimeout(() => {
                const form = document.getElementById('bStatisticsForm');
                console.log(`bStatisticsForm元素: ${form ? '存在' : '不存在'}`);
                if (typeof initBStatisticsForm === 'function') {
                    console.log('重新调用initBStatisticsForm函数');
                    initBStatisticsForm();
                } else {
                    console.log('initBStatisticsForm函数不存在');
                }
            }, 100);
        }
    } else if (page === 'c-statistics-flows' || page === 'c-statistics-summary') {
        // 显示C端交易流水内容，隐藏统计内容
        document.getElementById('c-statistics-flows-content').style.display = page === 'c-statistics-flows' ? 'block' : 'none';
        document.getElementById('c-statistics-summary-content').style.display = page === 'c-statistics-summary' ? 'block' : 'none';
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



function closeModal() {
    const modal = document.getElementById('modal');
    modal.classList.remove('active', 'fullscreen');
}
