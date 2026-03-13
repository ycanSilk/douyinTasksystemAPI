// API配置和请求方法

/**
 * 通用API请求方法
 * @param {string} url - API请求地址
 * @param {object} options - 请求选项
 * @param {string} options.method - 请求方法（GET, POST, PUT, DELETE等）
 * @param {object} options.headers - 请求头
 * @param {object|string} options.body - 请求体
 * @param {boolean} options.requiresAuth - 是否需要认证（默认true）
 * @returns {Promise<Response>} - 标准Response对象
 */
async function apiRequest(url, options = {}) {
    // 默认选项
    const defaultOptions = {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        },
        requiresAuth: true
    };
    
    // 合并选项
    const config = {
        ...defaultOptions,
        ...options,
        headers: {
            ...defaultOptions.headers,
            ...options.headers
        }
    };
    
    // 添加时间戳参数以避免浏览器缓存
    if (config.method === 'GET' || config.method === 'DELETE') {
        if (url.includes('?')) {
            url += `&t=${Date.now()}`;
        } else {
            url += `?t=${Date.now()}`;
        }
    }
    
    // 添加认证token
    if (config.requiresAuth) {
        const token = sessionStorage.getItem('admin_token');
        if (token) {
            config.headers['Authorization'] = `Bearer ${token}`;
        }
    }
    
    // 处理请求体
    if (config.body && typeof config.body === 'object' && config.headers['Content-Type'] === 'application/json') {
        config.body = JSON.stringify(config.body);
    }
    
    try {
        // 发送请求
        const response = await fetch(url, {
            method: config.method,
            headers: config.headers,
            body: config.body
        });
        
        // 处理未授权错误
        if (response.status === 401) {
            // 先抛出错误，再处理重定向
            throw new Error('Unauthorized');
        }
        
        // 对于其他错误状态码，仍然返回Response对象
        // 调用方可以根据status和statusText判断是否成功
        return response;
    } catch (error) {
        // 网络错误
        console.error('API请求失败:', error);
        
        // 处理未授权错误
        if (error.message === 'Unauthorized') {
            handleUnauthorizedError();
        } else {
            showToast('网络请求失败，请检查网络连接', 'error');
        }
        
        throw error;
    }
}

/**
 * 处理未授权错误
 */
function handleUnauthorizedError() {
    // 清除登录状态
    sessionStorage.clear();
    localStorage.removeItem('admin_current_page'); // 清除页面记忆
    
    // 尝试调用logout接口（可选）
    fetch(`/task_admin/auth/logout.php`, { method: 'POST' }).catch(err => {});
    
    // 重定向到登录页面
    window.location.href = `/task_admin/login.html`;
}

// 确保showToast函数可用
if (typeof showToast === 'undefined') {
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
}

// 导出apiRequest函数（如果在模块化环境中）
if (typeof module !== 'undefined' && module.exports) {
    module.exports = apiRequest;
}
