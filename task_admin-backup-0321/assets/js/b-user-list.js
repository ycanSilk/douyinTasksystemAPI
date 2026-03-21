// 为了保持向后兼容性，使用var声明局部变量以避免重复声明
var bStatisticsCurrentPage = 1;
var bStatisticsPageSize = 100;





// 加载B端用户交易流水列表
async function loadBStatistics() {
    // 检查DOM元素是否存在
    const bUsersStatisticsTable = document.getElementById('bUsersStatisticsTable');
    if (!bUsersStatisticsTable) {
        return;
    }
    
    // 显示加载状态
    bUsersStatisticsTable.innerHTML = '<div style="text-align: center; padding: 40px;"><i class="ri-loading-line ri-spin"></i> 加载中...</div>';
    
    // 获取筛选参数
    const bUserIdSearch = document.getElementById('bUserIdSearch') ? document.getElementById('bUserIdSearch').value : '';
    const bUsernameSearch = document.getElementById('bUsernameSearch') ? document.getElementById('bUsernameSearch').value : '';
    const relatedIdSearch = document.getElementById('relatedIdSearch') ? document.getElementById('relatedIdSearch').value : '';
    const relatedTypeFilter = document.getElementById('relatedTypeFilter') ? document.getElementById('relatedTypeFilter').value : '';
    const taskTypesFilter = document.getElementById('taskTypesFilter') ? document.getElementById('taskTypesFilter').value : '';
    const startDate = document.getElementById('startDate') ? document.getElementById('startDate').value : '';
    const endDate = document.getElementById('endDate') ? document.getElementById('endDate').value : '';
    
    try {
        // 构建查询参数
        const params = new URLSearchParams({
            page: bStatisticsCurrentPage,
            limit: bStatisticsPageSize,
            related_id: relatedIdSearch || '',
            related_type: relatedTypeFilter || '',
            task_types: taskTypesFilter || '',
            start_date: startDate || '',
            end_date: endDate || ''
        });
        
        // 根据输入类型添加用户搜索参数
        if (bUserIdSearch) {
            // 用户ID转换为bigint类型
            params.append('b_user_id', BigInt(bUserIdSearch));
        } else if (bUsernameSearch) {
            // 用户名强制转换为字符串类型
            params.append('b_user_id', String(bUsernameSearch));
        }
        
        const apiUrl = `/task_admin/api/b_users_static/flows.php?${params.toString()}`;
        
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
            renderbUsersStatisticsTable(data.data.list, data.data.pagination);
        } else {
            bUsersStatisticsTable.innerHTML = `<div class="empty">${data.message || '获取数据失败'}</div>`;
        }
    } catch (err) {
        bUsersStatisticsTable.innerHTML = '<div class="empty">网络错误，请稍后重试</div>';
    }
}

// 渲染B端用户交易流水表格
function renderbUsersStatisticsTable(list, pagination) {
    const bUsersStatisticsTable = document.getElementById('bUsersStatisticsTable');
    if (!bUsersStatisticsTable) {
        return;
    }
    
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>B端用户ID</th>
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
                    <td>${item.b_user_id}</td>
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
            'bStatistics'
        );
    }
    
    // 更新DOM
    bUsersStatisticsTable.innerHTML = html;
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
function initBStatisticsForm() {
    const form = document.getElementById('bStatisticsForm');
    if (form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // 重置页码为1
            bStatisticsCurrentPage = 1;
            
            // 异步调用loadBStatistics，避免阻塞事件处理
            setTimeout(() => {
                loadBStatistics();
            }, 0);
        });
        
        // 初始化重置按钮
        const resetBtn = document.getElementById('resetBStatistics');
        
        if (resetBtn) {
            resetBtn.addEventListener('click', function() {
                // 清空表单
                if (document.getElementById('bUserIdSearch')) document.getElementById('bUserIdSearch').value = '';
                if (document.getElementById('bUsernameSearch')) document.getElementById('bUsernameSearch').value = '';
                if (document.getElementById('relatedIdSearch')) document.getElementById('relatedIdSearch').value = '';
                if (document.getElementById('relatedTypeFilter')) document.getElementById('relatedTypeFilter').value = '';
                if (document.getElementById('taskTypesFilter')) document.getElementById('taskTypesFilter').value = '';
                if (document.getElementById('startDate')) document.getElementById('startDate').value = '';
                if (document.getElementById('endDate')) document.getElementById('endDate').value = '';
                
                // 重置页码为1
                bStatisticsCurrentPage = 1;
                
                // 异步调用loadBStatistics，避免阻塞事件处理
                setTimeout(() => {
                    loadBStatistics();
                }, 0);
            });
        }
    }
}

// 加载B端用户交易流水统计
async function loadBStatisticsSummary() {
    // 检查DOM元素是否存在
    const bStatisticsSummary = document.getElementById('bStatisticsSummary');
    if (!bStatisticsSummary) {
        return;
    }
    
    // 显示加载状态
    bStatisticsSummary.innerHTML = '<div style="text-align: center; padding: 40px;"><i class="ri-loading-line ri-spin"></i> 加载中...</div>';
    
    // 获取筛选参数
    const startDate = document.getElementById('summaryStartDate') ? document.getElementById('summaryStartDate').value : '';
    const endDate = document.getElementById('summaryEndDate') ? document.getElementById('summaryEndDate').value : '';
    
    try {
        // 构建查询参数
        const params = new URLSearchParams({
            period: '7days' // 默认7天
        });
        
        if (startDate && endDate) {
            // 如果有自定义日期范围，使用自定义范围
            params.set('start_date', startDate);
            params.set('end_date', endDate);
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
            renderBStatisticsSummary(data.data);
        } else {
            bStatisticsSummary.innerHTML = `<div class="empty">${data.message || '获取数据失败'}</div>`;
        }
    } catch (err) {
        bStatisticsSummary.innerHTML = '<div class="empty">网络错误，请稍后重试</div>';
    }
}

// 渲染B端用户交易流水统计
function renderBStatisticsSummary(data) {
    const bStatisticsSummary = document.getElementById('bStatisticsSummary');
    if (!bStatisticsSummary) {
        return;
    }
    
    // 构建HTML
    let html = `
        <div class="card">
            <div class="card-header">
                <div class="card-title">B端用户交易流水统计</div>
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
    bStatisticsSummary.innerHTML = html;
}

// 初始化B端用户交易流水统计表单
function initBStatisticsSummaryForm() {
    const loadBtn = document.getElementById('loadSummaryData');
    if (loadBtn) {
        loadBtn.addEventListener('click', function() {
            loadBStatisticsSummary();
        });
    }
}

// 暴露全局变量
window.bStatisticsCurrentPage = bStatisticsCurrentPage;
window.bStatisticsPageSize = bStatisticsPageSize;
window.loadBStatistics = loadBStatistics;
window.loadBStatisticsSummary = loadBStatisticsSummary;
window.renderbUsersStatisticsTable = renderbUsersStatisticsTable;
window.renderBStatisticsSummary = renderBStatisticsSummary;
window.initBStatisticsForm = initBStatisticsForm;
window.initBStatisticsSummaryForm = initBStatisticsSummaryForm;