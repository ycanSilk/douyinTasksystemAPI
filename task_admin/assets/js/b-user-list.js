// 为了保持向后兼容性，使用var声明局部变量以避免重复声明
var bStatisticsCurrentPage = 1;
var bStatisticsPageSize = 100;

// 输出日志到控制台
function log(message) {
    console.log(`[B端用户交易流水] ${message}`);
}



// 加载B端用户交易流水列表
async function loadBStatistics() {
    // 仅在开发环境输出日志
    const isDev = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
    if (isDev) {
        log('开始加载B端用户交易流水');
    }
    
    // 检查DOM元素是否存在
    const bUsersStatisticsTable = document.getElementById('bUsersStatisticsTable');
    if (!bUsersStatisticsTable) {
        if (isDev) {
            log('B端用户交易流水表格容器不存在');
        }
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
    
    if (isDev) {
        log('筛选参数:');
        log(`bUserIdSearch: ${bUserIdSearch}`);
        log(`bUsernameSearch: ${bUsernameSearch}`);
        log(`relatedIdSearch: ${relatedIdSearch}`);
        log(`relatedTypeFilter: ${relatedTypeFilter}`);
        log(`taskTypesFilter: ${taskTypesFilter}`);
        log(`startDate: ${startDate}`);
        log(`endDate: ${endDate}`);
        log(`bStatisticsCurrentPage: ${bStatisticsCurrentPage}`);
        log(`bStatisticsPageSize: ${bStatisticsPageSize}`);
    }
    
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
            params.append('b_user_id', bUserIdSearch);
        } else if (bUsernameSearch) {
            params.append('b_user_id', bUsernameSearch);
        }
        
        const apiUrl = `/task_admin/api/b_users_static/flows.php?${params.toString()}`;
        if (isDev) {
            log(`API请求URL: ${apiUrl}`);
        }
        
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
        if (isDev) {
            log(`API响应数据: ${JSON.stringify(data)}`);
        }
        
        if (data && data.code === 0) {
            if (isDev) {
                log('数据加载成功，开始渲染表格');
            }
            renderbUsersStatisticsTable(data.data.list, data.data.pagination);
        } else {
            if (isDev) {
                log(`API返回错误: ${data.message}`);
            }
            bUsersStatisticsTable.innerHTML = `<div class="empty">${data.message || '获取数据失败'}</div>`;
        }
    } catch (err) {
        if (isDev) {
            log(`加载B端用户交易流水失败: ${err.message}`);
        }
        bUsersStatisticsTable.innerHTML = '<div class="empty">网络错误，请稍后重试</div>';
    }
}

// 渲染B端用户交易流水表格
function renderbUsersStatisticsTable(list, pagination) {
    // 仅在开发环境输出日志
    const isDev = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
    if (isDev) {
        log('开始渲染B端用户交易流水表格');
    }
    
    const bUsersStatisticsTable = document.getElementById('bUsersStatisticsTable');
    if (!bUsersStatisticsTable) {
        if (isDev) {
            log('B端用户交易流水表格容器不存在');
        }
        return;
    }
    
    if (isDev) {
        log(`流水列表长度: ${list.length}`);
        log(`分页信息: ${JSON.stringify(pagination)}`);
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
                    <td style="color: ${item.flow_type === 1 ? 'green' : 'red'}">${item.amount_yuan}</td>
                    <td>${(item.before_balance / 100).toFixed(2)}</td>
                    <td>${(item.after_balance / 100).toFixed(2)}</td>
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
    // 仅在开发环境输出日志
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        log('开始初始化B端用户交易流水搜索表单');
    }
    
    const form = document.getElementById('bStatisticsForm');
    if (form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // 打印当前表单值
            const bUserIdSearch = document.getElementById('bUserIdSearch') ? document.getElementById('bUserIdSearch').value : '';
            const bUsernameSearch = document.getElementById('bUsernameSearch') ? document.getElementById('bUsernameSearch').value : '';
            const relatedIdSearch = document.getElementById('relatedIdSearch') ? document.getElementById('relatedIdSearch').value : '';
            const relatedTypeFilter = document.getElementById('relatedTypeFilter') ? document.getElementById('relatedTypeFilter').value : '';
            const taskTypesFilter = document.getElementById('taskTypesFilter') ? document.getElementById('taskTypesFilter').value : '';
            const startDate = document.getElementById('startDate') ? document.getElementById('startDate').value : '';
            const endDate = document.getElementById('endDate') ? document.getElementById('endDate').value : '';
            
            // 仅在开发环境输出日志
            const isDev = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
            if (isDev) {
                log('搜索表单提交，表单值:');
                log(`bUserIdSearch: ${bUserIdSearch}`);
                log(`bUsernameSearch: ${bUsernameSearch}`);
                log(`relatedIdSearch: ${relatedIdSearch}`);
                log(`relatedTypeFilter: ${relatedTypeFilter}`);
                log(`taskTypesFilter: ${taskTypesFilter}`);
                log(`startDate: ${startDate}`);
                log(`endDate: ${endDate}`);
            }
            
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

// 暴露全局变量
window.bStatisticsCurrentPage = bStatisticsCurrentPage;
window.bStatisticsPageSize = bStatisticsPageSize;
window.loadBStatistics = loadBStatistics;
window.renderbUsersStatisticsTable = renderbUsersStatisticsTable;
window.initBStatisticsForm = initBStatisticsForm;