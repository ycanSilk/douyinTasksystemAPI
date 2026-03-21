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

// 引入页面配置
import { getPageConfig, getPageContentConfig, hasPageConfig, hasPageContentConfig, pageContentConfig } from './page-config.js';

// 初始化
function init() {
    checkLoginStatus();
    initLogout();
    initNavigation();
    initModal();
    // 初始化B端用户交易流水搜索表单
    if (typeof initBStatisticsForm === 'function') {
        initBStatisticsForm();
    }
    // 初始化团队收益统计表单
    if (typeof initTeamRevenueForm === 'function') {
        initTeamRevenueForm();
    }
    // 初始化团队收益明细表单
    if (typeof initTeamRevenueDetailsForm === 'function') {
        initTeamRevenueDetailsForm();
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
    try {
        const url = `/task_admin/api/system_permission_template/user_permissions.php`;
        
        // 使用传统的fetch方法
        const token = sessionStorage.getItem('admin_token');
        
        const response = await fetch(url + `?t=${Date.now()}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
                ...(token && { 'Authorization': `Bearer ${token}` })
            }
        });
        
        
        // 检查响应状态码
        if (!response.ok) {
            showToast(`加载导航栏失败: ${response.status} ${response.statusText}`, 'error');
            return;
        }
        
        // 尝试解析JSON
        try {
            const data = await response.json();
            
            if (data && data.code === 0) {
                renderNavigation(data.data);
            } else if (data) {
                showToast('加载导航栏失败: ' + (data.message || '未知错误'), 'error');
            } else {
                showToast('加载导航栏失败', 'error');
            }
        } catch (e) {
            showToast('响应格式错误', 'error');
        }
    } catch (err) {
        showToast('网络请求失败，请检查网络连接', 'error');
    }
}

// 渲染导航栏
function renderNavigation(templates) {
    const navMenu = document.getElementById('navMenu');
    
    if (!navMenu) {
        return;
    }
    
    navMenu.innerHTML = '';
    
    // 按 parent_id 分组导航项
    const menuMap = {};
    
    
    templates.forEach((template, index) => {
        // 确保parent_id是数字类型，NULL或undefined时设为0
        const parentId = template.parent_id ? parseInt(template.parent_id) : 0;
        if (!menuMap[parentId]) {
            menuMap[parentId] = [];
        }
        menuMap[parentId].push(template);
    });
    
  
    // 渲染一级导航项（parent_id = 0）
    const level1Items = menuMap[0] || [];
    
    level1Items.forEach((item, index) => {
        const li = document.createElement('li');
        li.className = 'nav-item';
        
        const a = document.createElement('a');
        a.href = '#';
        a.className = 'nav-link';
        a.dataset.page = item.code;
        if (item.section_id) {
            a.dataset.sectionId = item.section_id;
        }
        
        // 检查是否有子导航项
        const itemId = parseInt(item.id);
        const hasChildren = menuMap[itemId] && menuMap[itemId].length > 0;
        
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
        
        // 添加点击事件用于折叠/展开
        a.addEventListener('click', (e) => {
            e.preventDefault();
            const subMenu = li.querySelector('.sub-menu');
            const toggleIcon = a.querySelector('.toggle-icon');
            
            if (subMenu) {
                subMenu.classList.toggle('active');
                toggleIcon.classList.toggle('ri-arrow-down-s-line');
                toggleIcon.classList.toggle('ri-arrow-up-s-line');
            }
            
            // 如果没有子导航项，直接跳转到对应页面
            if (!hasChildren) {
                const page = a.dataset.page;
                switchToPage(page);
            }
        });
        
        li.appendChild(a);
        
        // 为所有一级导航项创建二级导航面板
        const subMenu = document.createElement('ul');
        subMenu.className = 'sub-menu';
        
        // 如果有子导航项，渲染它们
        if (hasChildren) {
            menuMap[itemId].forEach((child, childIndex) => {
                const subLi = document.createElement('li');
                subLi.className = 'sub-nav-item';
                
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
                
                subA.addEventListener('click', (e) => {
                    e.preventDefault();
                    const page = subA.dataset.page;
                    switchToPage(page);
                });
                
                subLi.appendChild(subA);
                
                subMenu.appendChild(subLi);
            });
        }
        
        li.appendChild(subMenu);
        
        navMenu.appendChild(li);
    });
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
    console.log('切换到页面:', page);
    
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
    
    // 使用配置文件获取section ID
    let sectionId = `${page}Section`;
    if (hasPageConfig(page)) {
        const config = getPageConfig(page);
        if (config.sectionId) {
            sectionId = config.sectionId;
        }
    } else if (targetLink && targetLink.dataset.sectionId) {
        // 兼容旧的方式
        sectionId = targetLink.dataset.sectionId;
    }
    
    console.log('使用的sectionId:', sectionId);
    const targetSection = document.getElementById(sectionId);
    if (targetSection) {
        targetSection.classList.add('active');
    } else {
        console.warn('未找到对应的section:', sectionId);
    }
    
    // 保存当前页面到localStorage
    localStorage.setItem('admin_current_page', page);
    
    // 处理页面内容显示
    if (hasPageContentConfig(page)) {
        const contentConfig = getPageContentConfig(page);
        
        // 隐藏同组的其他内容
        Object.keys(pageContentConfig).forEach(key => {
            const config = pageContentConfig[key];
            if (config.contentId) {
                const contentElement = document.getElementById(config.contentId);
                if (contentElement) {
                    contentElement.style.display = (key === page) ? 'block' : 'none';
                }
            }
        });
        
        // 初始化表单
        if (contentConfig.initFunction) {
            setTimeout(() => {
                if (typeof window[contentConfig.initFunction] === 'function') {
                    console.log('初始化表单:', contentConfig.initFunction);
                    window[contentConfig.initFunction]();
                }
            }, 100);
        }
    }
    
    // 加载对应数据
    if (hasPageConfig(page)) {
        const config = getPageConfig(page);
        if (config.loadFunction) {
            setTimeout(() => {
                if (typeof config.loadFunction === 'function') {
                    console.log('执行加载函数(函数对象):', config.loadFunction.name);
                    config.loadFunction();
                } else if (typeof window[config.loadFunction] === 'function') {
                    console.log('执行加载函数(全局函数):', config.loadFunction);
                    window[config.loadFunction]();
                } else {
                    console.warn('加载函数不存在:', config.loadFunction);
                }
            }, 100);
        }
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
