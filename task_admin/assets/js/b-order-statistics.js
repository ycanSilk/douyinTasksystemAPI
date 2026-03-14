// 为了保持向后兼容性，使用var声明局部变量以避免重复声明
var orderStatisticsCurrentPeriod = '7days';
var orderStatisticsUserId = '';
var orderStatisticsUsername = '';
// 分页相关变量
var orderStatisticsCurrentPage = 1;
var orderStatisticsPageSize = 100;
var orderStatisticsTotalPages = 1;
var orderStatisticsTotalRecords = 0;



// 加载派单数据统计
async function loadOrderStatistics() {
    // 检查DOM元素是否存在
    const orderStatisticsContainer = document.getElementById('orderStatisticsContainer');
    if (!orderStatisticsContainer) {
        return;
    }
    
    // 显示加载状态
    orderStatisticsContainer.innerHTML = '<div style="text-align: center; padding: 40px;"><i class="ri-loading-line ri-spin"></i> 加载中...</div>';
    
    // 获取筛选参数
    const userId = document.getElementById('orderStatisticsUserId') ? document.getElementById('orderStatisticsUserId').value : '';
    const username = document.getElementById('orderStatisticsUsername') ? document.getElementById('orderStatisticsUsername').value : '';
    const period = document.getElementById('orderStatisticsPeriod') ? document.getElementById('orderStatisticsPeriod').value : '7days';
    
    // 保存当前筛选参数
    orderStatisticsCurrentPeriod = period;
    orderStatisticsUserId = userId;
    orderStatisticsUsername = username;
    
    try {
        // 构建查询参数
        const params = new URLSearchParams({
            period: period,
            page: orderStatisticsCurrentPage,
            limit: orderStatisticsPageSize
        });
        
        // 根据输入类型添加用户搜索参数
        if (userId) {
            params.append('b_user_id', userId);
        } else if (username) {
            params.append('b_user_id', username);
        }
        
        const apiUrl = `/task_admin/api/b_users_static/summary.php?${params.toString()}`;
        
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
            renderOrderStatistics(data.data);
        } else {
            orderStatisticsContainer.innerHTML = `<div class="empty">${data.message || '获取数据失败'}</div>`;
        }
    } catch (err) {
        orderStatisticsContainer.innerHTML = '<div class="empty">网络错误，请稍后重试</div>';
    }
}

// 渲染派单数据统计
function renderOrderStatistics(data) {
    const orderStatisticsContainer = document.getElementById('orderStatisticsContainer');
    if (!orderStatisticsContainer) {
        return;
    }
    
    // 保存分页信息
    if (data.pagination) {
        orderStatisticsCurrentPage = data.pagination.page;
        orderStatisticsPageSize = data.pagination.limit;
        orderStatisticsTotalRecords = data.pagination.total;
        orderStatisticsTotalPages = data.pagination.total_pages;
    } else {
        orderStatisticsTotalRecords = data.daily_data ? data.daily_data.length : 0;
        orderStatisticsTotalPages = Math.ceil(orderStatisticsTotalRecords / orderStatisticsPageSize);
    }
    
    // 构建HTML
    let html = `
        <div class="bg-white rounded-xl shadow-md border border-gray-200 overflow-hidden">
            <div class="bg-gray-50 border-b border-gray-200 px-6 py-4">
                <h3 class="text-lg font-semibold text-gray-800">派单数据统计</h3>
            </div>
            <div class="p-6">
                <!-- 汇总数据 -->
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
                    <div class="bg-green-50 rounded-lg p-4 border border-green-100">
                        <div class="text-sm text-green-600 font-medium mb-1">总收入</div>
                        <div class="text-2xl font-bold text-green-700">¥${parseFloat(data.summary.total_income).toFixed(2)}</div>
                    </div>
                    <div class="bg-red-50 rounded-lg p-4 border border-red-100">
                        <div class="text-sm text-red-600 font-medium mb-1">总支出</div>
                        <div class="text-2xl font-bold text-red-700">¥${parseFloat(data.summary.total_expenditure).toFixed(2)}</div>
                    </div>
                    <div class="bg-${data.summary.net_change >= 0 ? 'green' : 'red'}-50 rounded-lg p-4 border border-${data.summary.net_change >= 0 ? 'green' : 'red'}-100">
                        <div class="text-sm text-${data.summary.net_change >= 0 ? 'green' : 'red'}-600 font-medium mb-1">净收入</div>
                        <div class="text-2xl font-bold text-${data.summary.net_change >= 0 ? 'green' : 'red'}-700">¥${parseFloat(data.summary.net_change).toFixed(2)}</div>
                    </div>
                    <div class="bg-blue-50 rounded-lg p-4 border border-blue-100">
                        <div class="text-sm text-blue-600 font-medium mb-1">统计周期</div>
                        <div class="text-2xl font-bold text-blue-700">${getPeriodText(data.period)}</div>
                    </div>
                </div>
                
                <!-- 每日数据表格 -->
                <div class="mb-4">
                    <h4 class="text-md font-semibold text-gray-700 mb-4">每日数据明细</h4>
                    <div class="overflow-x-auto">
                        <table class="min-w-full divide-y divide-gray-200">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">日期</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">收入(元)</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">支出(元)</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">净收入(元)</th>
                                </tr>
                            </thead>
                            <tbody class="bg-white divide-y divide-gray-200">
    `;
    
    if (data.daily_data && data.daily_data.length === 0) {
        html += '<tr><td colspan="4" class="px-6 py-12 text-center text-gray-500">暂无数据</td></tr>';
    } else {
        data.daily_data.forEach(item => {
            html += `
                <tr class="hover:bg-gray-50 transition-colors">
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${item.date}</td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-green-600 font-medium">${parseFloat(item.income).toFixed(2)}</td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-red-600 font-medium">${parseFloat(item.expenditure).toFixed(2)}</td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-${item.net_change >= 0 ? 'green' : 'red'}-600">${parseFloat(item.net_change).toFixed(2)}</td>
                </tr>
            `;
        });
    }
    
    html += `
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <!-- 分页控件 -->
                <div class="flex items-center justify-between mt-6">
                    <div class="text-sm text-gray-500">
                        共 ${orderStatisticsTotalRecords} 条记录，共 ${orderStatisticsTotalPages} 页
                    </div>
                    <div class="flex items-center space-x-2">
                        <button ${orderStatisticsCurrentPage === 1 ? 'disabled' : ''} onclick="orderStatisticsCurrentPage = 1; loadOrderStatistics();" class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                            首页
                        </button>
                        <button ${orderStatisticsCurrentPage === 1 ? 'disabled' : ''} onclick="orderStatisticsCurrentPage--; loadOrderStatistics();" class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                            上一页
                        </button>
                        <span class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white">
                            ${orderStatisticsCurrentPage}
                        </span>
                        <button ${orderStatisticsCurrentPage === orderStatisticsTotalPages ? 'disabled' : ''} onclick="orderStatisticsCurrentPage++; loadOrderStatistics();" class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                            下一页
                        </button>
                        <button ${orderStatisticsCurrentPage === orderStatisticsTotalPages ? 'disabled' : ''} onclick="orderStatisticsCurrentPage = ${orderStatisticsTotalPages}; loadOrderStatistics();" class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                            末页
                        </button>
                        <select onchange="orderStatisticsPageSize = parseInt(this.value); orderStatisticsCurrentPage = 1; loadOrderStatistics();" class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white">
                            <option value="10" ${orderStatisticsPageSize === 10 ? 'selected' : ''}>10条/页</option>
                            <option value="20" ${orderStatisticsPageSize === 20 ? 'selected' : ''}>20条/页</option>
                            <option value="50" ${orderStatisticsPageSize === 50 ? 'selected' : ''}>50条/页</option>
                            <option value="100" ${orderStatisticsPageSize === 100 ? 'selected' : ''}>100条/页</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    // 更新DOM
    orderStatisticsContainer.innerHTML = html;
}

// 获取周期文本
function getPeriodText(period) {
    const periodMap = {
        'today': '今日',
        '7days': '近7天',
        '15days': '近15天',
        '30days': '近30天',
        '12months': '近12个月'
    };
    return periodMap[period] || period;
}

// 初始化派单数据统计表单
function initOrderStatisticsForm() {
    const form = document.getElementById('orderStatisticsForm');
    if (form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // 重置分页参数
            orderStatisticsCurrentPage = 1;
            
            // 异步调用loadOrderStatistics，避免阻塞事件处理
            setTimeout(() => {
                loadOrderStatistics();
            }, 0);
        });
        
        // 初始化重置按钮
        const resetBtn = document.getElementById('resetOrderStatistics');
        if (resetBtn) {
            resetBtn.addEventListener('click', function() {
                // 清空表单
                if (document.getElementById('orderStatisticsUserId')) document.getElementById('orderStatisticsUserId').value = '';
                if (document.getElementById('orderStatisticsUsername')) document.getElementById('orderStatisticsUsername').value = '';
                if (document.getElementById('orderStatisticsPeriod')) document.getElementById('orderStatisticsPeriod').value = '7days';
                
                // 重置参数
                orderStatisticsCurrentPeriod = '7days';
                orderStatisticsUserId = '';
                orderStatisticsUsername = '';
                orderStatisticsCurrentPage = 1;
                
                // 异步调用loadOrderStatistics，避免阻塞事件处理
                setTimeout(() => {
                    loadOrderStatistics();
                }, 0);
            });
        }
    }
}

// 暴露全局变量
window.orderStatisticsCurrentPeriod = orderStatisticsCurrentPeriod;
window.orderStatisticsUserId = orderStatisticsUserId;
window.orderStatisticsUsername = orderStatisticsUsername;
window.orderStatisticsCurrentPage = orderStatisticsCurrentPage;
window.orderStatisticsPageSize = orderStatisticsPageSize;
window.orderStatisticsTotalPages = orderStatisticsTotalPages;
window.orderStatisticsTotalRecords = orderStatisticsTotalRecords;
window.loadOrderStatistics = loadOrderStatistics;
window.renderOrderStatistics = renderOrderStatistics;
window.initOrderStatisticsForm = initOrderStatisticsForm;