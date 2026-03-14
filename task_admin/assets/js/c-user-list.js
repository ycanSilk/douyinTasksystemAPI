// 为了保持向后兼容性，使用var声明局部变量以避免重复声明
var cStatisticsCurrentPage = 1;
var cStatisticsPageSize = 100;





// 加载C端用户交易流水列表
async function loadCStatistics() {
    // 检查DOM元素是否存在
    const cUsersStatisticsTable = document.getElementById('cUsersStatisticsTable');
    if (!cUsersStatisticsTable) {
        return;
    }
    
    // 显示加载状态
    cUsersStatisticsTable.innerHTML = '<div style="text-align: center; padding: 40px;"><i class="ri-loading-line ri-spin"></i> 加载中...</div>';
    
    // 获取筛选参数
    const cUserIdSearch = document.getElementById('cUserIdSearch') ? document.getElementById('cUserIdSearch').value : '';
    const cUsernameSearch = document.getElementById('cUsernameSearch') ? document.getElementById('cUsernameSearch').value : '';
    const cRelatedIdSearch = document.getElementById('cRelatedIdSearch') ? document.getElementById('cRelatedIdSearch').value : '';
    const cRelatedTypeFilter = document.getElementById('cRelatedTypeFilter') ? document.getElementById('cRelatedTypeFilter').value : '';
    const cTaskTypesFilter = document.getElementById('cTaskTypesFilter') ? document.getElementById('cTaskTypesFilter').value : '';
    const cStartDate = document.getElementById('cStartDate') ? document.getElementById('cStartDate').value : '';
    const cEndDate = document.getElementById('cEndDate') ? document.getElementById('cEndDate').value : '';
    
    try {
        // 构建查询参数
        const params = new URLSearchParams({
            page: cStatisticsCurrentPage,
            limit: cStatisticsPageSize,
            related_id: cRelatedIdSearch || '',
            related_type: cRelatedTypeFilter || '',
            task_types: cTaskTypesFilter || '',
            start_date: cStartDate || '',
            end_date: cEndDate || ''
        });
        
        // 根据输入类型添加用户搜索参数
        if (cUserIdSearch) {
            params.append('c_user_id', cUserIdSearch);
        } else if (cUsernameSearch) {
            params.append('c_user_id', cUsernameSearch);
        }
        
        const apiUrl = `/task_admin/api/c_users_static/flows.php?${params.toString()}`;
        
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
            rendercUsersStatisticsTable(data.data.list, data.data.pagination);
        } else {
            cUsersStatisticsTable.innerHTML = `<div class="empty">${data.message || '获取数据失败'}</div>`;
        }
    } catch (err) {
        cUsersStatisticsTable.innerHTML = '<div class="empty">网络错误，请稍后重试</div>';
    }
}

// 渲染C端用户交易流水表格
function rendercUsersStatisticsTable(list, pagination) {
    const cUsersStatisticsTable = document.getElementById('cUsersStatisticsTable');
    if (!cUsersStatisticsTable) {
        return;
    }
    
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>C端用户ID</th>
                    <th>用户名</th>
                    <th>流水类型</th>
                    <th>金额(元)</th>
                    <th>操作前余额</th>
                    <th>操作后余额</th>
                    <th>相关类型</th>
                    <th>相关ID</th>
                    <th>任务类型</th>
                    <th>备注</th>
                    <th>创建时间</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    if (list.length === 0) {
        html += '<tr><td colspan="12" style="text-align: center; padding: 40px; color: #86868b;">暂无数据</td></tr>';
    } else {
        list.forEach(item => {
            html += `
                <tr>
                    <td>${item.id}</td>
                    <td>${item.c_user_id}</td>
                    <td><strong>${item.username}</strong></td>
                    <td>${item.flow_type_text}</td>
                    <td style="color: ${item.flow_type === 1 ? 'green' : 'red'}">${item.amount}</td>
                    <td>${(item.before_balance).toFixed(2)}</td>
                    <td>${(item.after_balance).toFixed(2)}</td>
                    <td>${item.related_type_text}</td>
                    <td>${item.related_id || '-'}</td>
                    <td>${item.task_types_text || '-'}</td>
                    <td>${item.remark}</td>
                    <td>${item.created_at}</td>
                </tr>
            `;
        });
    }
    
    html += '</tbody></table></div>';
    
    // 添加分页控件
    if (pagination) {
        html += renderPagination(
            pagination.page,
            pagination.total_pages,
            pagination.total,
            'cStatistics'
        );
    }
    
    // 更新DOM
    cUsersStatisticsTable.innerHTML = html;
}

// 通用分页渲染函数
function renderPagination(currentPage, totalPages, totalRecords, prefix) {
    let html = `
        <div class="pagination">
            <button ${currentPage === 1 ? 'disabled' : ''} onclick="${prefix}CurrentPage = 1; load${prefix.charAt(0).toUpperCase() + prefix.slice(1)}()">首页</button>
            <button ${currentPage === 1 ? 'disabled' : ''} onclick="${prefix}CurrentPage--; load${prefix.charAt(0).toUpperCase() + prefix.slice(1)}()">上一页</button>
    `;
    
    const startPage = Math.max(1, currentPage - 2);
    const endPage = Math.min(totalPages, startPage + 4);
    
    for (let i = startPage; i <= endPage; i++) {
        html += `
            <button ${i === currentPage ? 'class="active"' : ''} onclick="${prefix}CurrentPage = ${i}; load${prefix.charAt(0).toUpperCase() + prefix.slice(1)}()">${i}</button>
        `;
    }
    
    html += `
            <button ${currentPage === totalPages ? 'disabled' : ''} onclick="${prefix}CurrentPage++; load${prefix.charAt(0).toUpperCase() + prefix.slice(1)}()">下一页</button>
            <button ${currentPage === totalPages ? 'disabled' : ''} onclick="${prefix}CurrentPage = ${totalPages}; load${prefix.charAt(0).toUpperCase() + prefix.slice(1)}()">末页</button>
            <span style="margin-left: 20px;">共 ${totalRecords} 条记录，共 ${totalPages} 页</span>
            <select onchange="${prefix}PageSize = parseInt(this.value); ${prefix}CurrentPage = 1; load${prefix.charAt(0).toUpperCase() + prefix.slice(1)}()" style="margin-left: 10px; padding: 5px;">
                <option value="10" ${window[prefix + 'PageSize'] === 10 ? 'selected' : ''}>10条/页</option>
                <option value="20" ${window[prefix + 'PageSize'] === 20 ? 'selected' : ''}>20条/页</option>
                <option value="50" ${window[prefix + 'PageSize'] === 50 ? 'selected' : ''}>50条/页</option>
                <option value="100" ${window[prefix + 'PageSize'] === 100 ? 'selected' : ''}>100条/页</option>
            </select>
        </div>
    `;
    
    return html;
}

// 初始化搜索表单
function initCStatisticsForm() {
    const form = document.getElementById('cStatisticsForm');
    if (form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // 重置页码为1
            cStatisticsCurrentPage = 1;
            
            // 异步调用loadCStatistics，避免阻塞事件处理
            setTimeout(() => {
                loadCStatistics();
            }, 0);
        });
        
        // 初始化重置按钮
        const resetBtn = document.getElementById('resetCStatistics');
        
        if (resetBtn) {
            resetBtn.addEventListener('click', function() {
                // 清空表单
                if (document.getElementById('cUserIdSearch')) document.getElementById('cUserIdSearch').value = '';
                if (document.getElementById('cUsernameSearch')) document.getElementById('cUsernameSearch').value = '';
                if (document.getElementById('cRelatedIdSearch')) document.getElementById('cRelatedIdSearch').value = '';
                if (document.getElementById('cRelatedTypeFilter')) document.getElementById('cRelatedTypeFilter').value = '';
                if (document.getElementById('cTaskTypesFilter')) document.getElementById('cTaskTypesFilter').value = '';
                if (document.getElementById('cStartDate')) document.getElementById('cStartDate').value = '';
                if (document.getElementById('cEndDate')) document.getElementById('cEndDate').value = '';
                
                // 重置页码为1
                cStatisticsCurrentPage = 1;
                
                // 异步调用loadCStatistics，避免阻塞事件处理
                setTimeout(() => {
                    loadCStatistics();
                }, 0);
            });
        }
    }
}

// 加载C端用户交易流水统计
async function loadCStatisticsSummary() {
    // 检查DOM元素是否存在
    const cStatisticsSummary = document.getElementById('cStatisticsSummary');
    if (!cStatisticsSummary) {
        return;
    }
    
    // 显示加载状态
    cStatisticsSummary.innerHTML = '<div style="text-align: center; padding: 40px;"><i class="ri-loading-line ri-spin"></i> 加载中...</div>';
    
    // 获取筛选参数
    const cSummaryStartDate = document.getElementById('cSummaryStartDate') ? document.getElementById('cSummaryStartDate').value : '';
    const cSummaryEndDate = document.getElementById('cSummaryEndDate') ? document.getElementById('cSummaryEndDate').value : '';
    
    try {
        // 构建查询参数
        const params = new URLSearchParams({
            period: '7days' // 默认7天
        });
        
        if (cSummaryStartDate && cSummaryEndDate) {
            // 如果有自定义日期范围，使用自定义范围
            params.set('start_date', cSummaryStartDate);
            params.set('end_date', cSummaryEndDate);
        }
        
        const apiUrl = `/task_admin/api/c_users_static/summary.php?${params.toString()}`;
        
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
            renderCStatisticsSummary(data.data);
        } else {
            cStatisticsSummary.innerHTML = `<div class="empty">${data.message || '获取数据失败'}</div>`;
        }
    } catch (err) {
        cStatisticsSummary.innerHTML = '<div class="empty">网络错误，请稍后重试</div>';
    }
}

// 渲染C端用户交易流水统计
function renderCStatisticsSummary(data) {
    const cStatisticsSummary = document.getElementById('cStatisticsSummary');
    if (!cStatisticsSummary) {
        return;
    }
    
    // 构建HTML
    let html = `
        <div class="card">
            <div class="card-header">
                <div class="card-title">C端用户交易流水统计</div>
            </div>
            <div class="card-body">
                <!-- 汇总数据 -->
                <div class="summary-cards">
                    <div class="summary-card">
                        <div class="summary-title">总收入</div>
                        <div class="summary-value" style="color: green;">¥${data.summary.total_income_yuan}</div>
                    </div>
                    <div class="summary-card">
                        <div class="summary-title">总支出</div>
                        <div class="summary-value" style="color: red;">¥${data.summary.total_expenditure_yuan}</div>
                    </div>
                    <div class="summary-card">
                        <div class="summary-title">净收入</div>
                        <div class="summary-value" style="color: ${data.summary.net_change >= 0 ? 'green' : 'red'};">¥${data.summary.net_change_yuan}</div>
                    </div>
                    <div class="summary-card">
                        <div class="summary-title">统计周期</div>
                        <div class="summary-value">${getPeriodText(data.period)}</div>
                    </div>
                </div>
                
                <!-- 每日数据表格 -->
                <div class="table-container" style="margin-top: 30px;">
                    <h4>每日数据明细</h4>
                    <table>
                        <thead>
                            <tr>
                                <th>日期</th>
                                <th>收入(元)</th>
                                <th>支出(元)</th>
                                <th>净收入(元)</th>
                            </tr>
                        </thead>
                        <tbody>
    `;
    
    if (data.daily_data && data.daily_data.length === 0) {
        html += '<tr><td colspan="4" style="text-align: center; padding: 40px; color: #86868b;">暂无数据</td></tr>';
    } else {
        data.daily_data.forEach(item => {
            html += `
                <tr>
                    <td>${item.date}</td>
                    <td style="color: green;">${item.income_yuan}</td>
                    <td style="color: red;">${item.expenditure_yuan}</td>
                    <td style="color: ${item.net_change >= 0 ? 'green' : 'red'};">${item.net_change_yuan}</td>
                </tr>
            `;
        });
    }
    
    html += `
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    `;
    
    // 更新DOM
    cStatisticsSummary.innerHTML = html;
}

// 初始化C端用户交易流水统计表单
function initCStatisticsSummaryForm() {
    const loadBtn = document.getElementById('loadCSummaryData');
    if (loadBtn) {
        loadBtn.addEventListener('click', function() {
            loadCStatisticsSummary();
        });
    }
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

// 暴露全局变量
window.cStatisticsCurrentPage = cStatisticsCurrentPage;
window.cStatisticsPageSize = cStatisticsPageSize;
window.loadCStatistics = loadCStatistics;
window.loadCStatisticsSummary = loadCStatisticsSummary;
window.rendercUsersStatisticsTable = rendercUsersStatisticsTable;
window.renderCStatisticsSummary = renderCStatisticsSummary;
window.initCStatisticsForm = initCStatisticsForm;
window.initCStatisticsSummaryForm = initCStatisticsSummaryForm;