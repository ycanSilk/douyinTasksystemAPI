// 团队收益明细相关变量
var teamRevenueDetailsCurrentPeriod = 0; // 默认0，表示查看所有
var teamRevenueDetailsUserId = '';
var teamRevenueDetailsUsername = '';
var teamRevenueDetailsTeamUserId = '';
var teamRevenueDetailsTeamUsername = '';
// 分页相关变量
var teamRevenueDetailsCurrentPage = 1;
var teamRevenueDetailsPageSize = 20;
var teamRevenueDetailsTotalPages = 1;
var teamRevenueDetailsTotalRecords = 0;

// 加载团队收益明细数据
async function loadTeamRevenueDetails() {
    console.log('=== 开始加载团队收益明细数据 ===');
    // 检查DOM元素是否存在
    const teamRevenueDetailsDataContainer = document.getElementById('teamRevenueDetailsContainer');
    if (!teamRevenueDetailsDataContainer) {
        console.error('❌ teamRevenueDetailsContainer 元素不存在');
        return;
    }
    console.log('✅ teamRevenueDetailsContainer 元素存在');
    
    // 显示加载状态
    teamRevenueDetailsDataContainer.innerHTML = '<div style="text-align: center; padding: 40px;"><i class="ri-loading-line ri-spin"></i> 加载中...</div>';
    
    // 获取筛选参数
    const userId = document.getElementById('teamRevenueDetailsUserId') ? document.getElementById('teamRevenueDetailsUserId').value : '';
    const username = document.getElementById('teamRevenueDetailsUsername') ? document.getElementById('teamRevenueDetailsUsername').value : '';
    const teamUserId = document.getElementById('teamRevenueDetailsTeamUserId') ? document.getElementById('teamRevenueDetailsTeamUserId').value : '';
    const teamUsername = document.getElementById('teamRevenueDetailsTeamUsername') ? document.getElementById('teamRevenueDetailsTeamUsername').value : '';
    const revenueSource = document.getElementById('teamRevenueDetailsRevenueSource') ? document.getElementById('teamRevenueDetailsRevenueSource').value : '';
    const agentLevel = document.getElementById('teamRevenueDetailsAgentLevel') ? document.getElementById('teamRevenueDetailsAgentLevel').value : '';
    const period = document.getElementById('teamRevenueDetailsPeriod') ? document.getElementById('teamRevenueDetailsPeriod').value : 0; // 默认0，表示查看所有
    console.log('获取筛选参数:', { userId, username, teamUserId, teamUsername, revenueSource, agentLevel, period });
    
    // 保存当前筛选参数
    teamRevenueDetailsCurrentPeriod = period;
    teamRevenueDetailsUserId = userId;
    teamRevenueDetailsUsername = username;
    teamRevenueDetailsTeamUserId = teamUserId;
    teamRevenueDetailsTeamUsername = teamUsername;
    try {
        // 构建查询参数
        const params = new URLSearchParams({
            days: period,
            page: teamRevenueDetailsCurrentPage,
            limit: teamRevenueDetailsPageSize
        });
        
        if (userId) {
            params.append('user_id', userId);
        }
        
        if (username) {
            params.append('username', username);
        }
        
        if (teamUserId) {
            params.append('downline_user_id', teamUserId);
        }
        
        if (teamUsername) {
            params.append('downline_username', teamUsername);
        }
        
        if (revenueSource) {
            params.append('revenue_source', revenueSource);
        }
        
        if (agentLevel) {
            params.append('agent_level', agentLevel);
        }
        
        const apiUrl = `api/team_revenue/breakdown.php?${params.toString()}`;
        console.log('API请求URL:', apiUrl);
        
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['X-token'] = token;
        }
        console.log('请求头:', headers);
        
        console.log('🚀 发送API请求...');
        const response = await fetch(apiUrl, {
            method: 'GET',
            headers: headers,
            credentials: 'include'
        });
        console.log('API响应状态:', response.status);
        
        if (response.status === 401) {
            console.log('🔒 未授权，跳转到登录页');
            sessionStorage.clear();
            localStorage.removeItem('admin_current_page');
            fetch('/task_admin/auth/logout.php', { method: 'POST' }).catch(err => {});
            window.location.href = '/task_admin/login.html';
            return;
        }
        
        if (!response.ok) {
            console.error('❌ HTTP错误:', response.status);
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        console.log('📦 解析API响应...');
        const data = await response.json();
        console.log('API返回数据:', data);
        
        if (data && data.code === 0) {
            console.log('✅ 数据获取成功，开始渲染');
            renderTeamRevenueDetails(data.data);
        } else {
            console.error('❌ 数据获取失败:', data.message || '未知错误');
            teamRevenueDetailsDataContainer.innerHTML = `<div class="empty">${data.message || '获取数据失败'}</div>`;
        }
    } catch (err) {
        console.error('❌ 请求异常:', err);
        teamRevenueDetailsDataContainer.innerHTML = '<div class="empty">网络错误，请稍后重试</div>';
    }
}

// 渲染团队收益明细数据
function renderTeamRevenueDetails(data) {
    const teamRevenueDetailsDataContainer = document.getElementById('teamRevenueDetailsContainer');
    if (!teamRevenueDetailsDataContainer) {
        return;
    }
    
    // 保存分页信息
    if (data) {
        teamRevenueDetailsCurrentPage = data.current_page || 1;
        teamRevenueDetailsPageSize = data.per_page || 20;
        teamRevenueDetailsTotalRecords = data.total || 0;
        teamRevenueDetailsTotalPages = data.last_page || 1;
    } else {
        teamRevenueDetailsTotalRecords = 0;
        teamRevenueDetailsTotalPages = 1;
    }
    
    // 分离一级代理和二级代理数据
    const level1Data = data.list ? data.list.filter(item => item.agent_level === 1) : [];
    const level2Data = data.list ? data.list.filter(item => item.agent_level === 2) : [];
    
    // 按用户名分组数据
    const groupByUsername = (data) => {
        return data.reduce((groups, item) => {
            const username = item.downline_user ? item.downline_user.username : '未知用户';
            if (!groups[username]) {
                groups[username] = [];
            }
            groups[username].push(item);
            return groups;
        }, {});
    };
    
    const level1ByUsername = groupByUsername(level1Data);
    const level2ByUsername = groupByUsername(level2Data);
    
    // 构建HTML
    let html = `
        <div class="bg-white rounded-xl shadow-md border border-gray-200 overflow-hidden w-full">
            <div class="bg-gray-50 border-b border-gray-200 px-6 py-4">
                <h3 class="text-lg font-semibold text-gray-800">团队收益明细</h3>
            </div>
            <div class="p-6">
                <!-- 一级代理数据 -->
                <div class="mb-8">
                    <h4 class="text-md font-semibold text-gray-700 mb-4 flex items-center">
                        <i class="ri-user-follow-line mr-2 text-blue-600"></i>一级代理收益
                        <span class="ml-2 text-sm text-gray-500">(${level1Data.length}条记录)</span>
                    </h4>
                    <div class="overflow-x-auto w-full">
                        <table class="min-w-full divide-y divide-gray-200 w-full">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">获得收益用户ID</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">获得收益用户名</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">完成任务用户名</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">团队收益金额</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">变更前金额</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">变更后金额</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">收益来源</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">相关ID</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">任务类型</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">任务阶段</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">时间</th>
                                </tr>
                            </thead>
                            <tbody class="bg-white divide-y divide-gray-200">
    `;
    
    if (level1Data.length === 0) {
        html += '<tr><td colspan="10" class="px-6 py-12 text-center text-gray-500">暂无一级代理数据</td></tr>';
    } else {
        // 按用户名分组显示
        Object.entries(level1ByUsername).forEach(([username, items]) => {
            items.forEach(item => {
                const taskType = item.task_info ? item.task_info.type_text : (item.order_info ? item.order_info.type_text : '-');
                const taskStage = item.task_info ? item.task_info.stage : '-';
                const stageText = taskStage === 0 ? '单任务' : (taskStage === 1 ? '1阶段' : (taskStage === 2 ? '2阶段' : '-'));
                html += `
                    <tr class="hover:bg-gray-50 transition-colors">
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${item.agent_id || '-'}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${item.agent_username || '未知用户'}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${item.downline_username || (item.downline_user ? item.downline_user.username : '未知用户')}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-green-600 font-medium">¥${item.team_revenue_amount || (item.revenue ? item.revenue.amount : '0.00')}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">¥${item.agent_before_amount || '0.00'}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">¥${item.agent_after_amount || '0.00'}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-blue-600 font-medium">${item.revenue_source_text || (item.revenue ? item.revenue.source_text : '未知')}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${item.related_id || '-'}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${taskType}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${stageText}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${item.created_at || '-'}</td>
                    </tr>
                `;
            });
        });
    }
    
    html += `
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <!-- 二级代理数据 -->
                <div class="mb-8">
                    <h4 class="text-md font-semibold text-gray-700 mb-4 flex items-center">
                        <i class="ri-user-follow-line mr-2 text-green-600"></i>二级代理收益
                        <span class="ml-2 text-sm text-gray-500">(${level2Data.length}条记录)</span>
                    </h4>
                    <div class="overflow-x-auto w-full">
                        <table class="min-w-full divide-y divide-gray-200 w-full">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">获得收益用户ID</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">获得收益用户名</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">完成任务用户名</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">团队收益金额</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">变更前金额</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">变更后金额</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">收益来源</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">相关ID</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">任务类型</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">任务阶段</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">时间</th>
                                </tr>
                            </thead>
                            <tbody class="bg-white divide-y divide-gray-200">
    `;
    
    if (level2Data.length === 0) {
        html += '<tr><td colspan="10" class="px-6 py-12 text-center text-gray-500">暂无二级代理数据</td></tr>';
    } else {
        // 按用户名分组显示
        Object.entries(level2ByUsername).forEach(([username, items]) => {
            items.forEach(item => {
                const taskType = item.task_info ? item.task_info.type_text : (item.order_info ? item.order_info.type_text : '-');
                const taskStage = item.task_info ? item.task_info.stage : '-';
                const stageText = taskStage === 0 ? '单任务' : (taskStage === 1 ? '1阶段' : (taskStage === 2 ? '2阶段' : '-'));
                html += `
                    <tr class="hover:bg-gray-50 transition-colors">
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${item.agent_id || '-'}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${item.agent_username || '未知用户'}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${item.downline_username || (item.downline_user ? item.downline_user.username : '未知用户')}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-green-600 font-medium">¥${item.team_revenue_amount || (item.revenue ? item.revenue.amount : '0.00')}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">¥${item.agent_before_amount || '0.00'}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">¥${item.agent_after_amount || '0.00'}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-green-600 font-medium">${item.revenue_source_text || (item.revenue ? item.revenue.source_text : '未知')}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${item.related_id || '-'}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${taskType}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${stageText}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${item.created_at || '-'}</td>
                    </tr>
                `;
            });
        });
    }
    
    html += `
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <!-- 分页控件 -->
                <div class="flex items-center justify-between mt-6 w-full">
                    <div class="text-sm text-gray-500">
                        共 ${teamRevenueDetailsTotalRecords} 条记录，共 ${teamRevenueDetailsTotalPages} 页
                    </div>
                    <div class="flex items-center space-x-2">
                        <button ${teamRevenueDetailsCurrentPage === 1 ? 'disabled' : ''} onclick="teamRevenueDetailsCurrentPage = 1; loadTeamRevenueDetails();" class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                            首页
                        </button>
                        <button ${teamRevenueDetailsCurrentPage === 1 ? 'disabled' : ''} onclick="teamRevenueDetailsCurrentPage--; loadTeamRevenueDetails();" class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                            上一页
                        </button>
                        <span class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white">
                            ${teamRevenueDetailsCurrentPage}
                        </span>
                        <button ${teamRevenueDetailsCurrentPage === teamRevenueDetailsTotalPages ? 'disabled' : ''} onclick="teamRevenueDetailsCurrentPage++; loadTeamRevenueDetails();" class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                            下一页
                        </button>
                        <button ${teamRevenueDetailsCurrentPage === teamRevenueDetailsTotalPages ? 'disabled' : ''} onclick="teamRevenueDetailsCurrentPage = ${teamRevenueDetailsTotalPages}; loadTeamRevenueDetails();" class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                            末页
                        </button>
                        <select onchange="teamRevenueDetailsPageSize = parseInt(this.value); teamRevenueDetailsCurrentPage = 1; loadTeamRevenueDetails();" class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white">
                            <option value="10" ${teamRevenueDetailsPageSize === 10 ? 'selected' : ''}>10条/页</option>
                            <option value="20" ${teamRevenueDetailsPageSize === 20 ? 'selected' : ''}>20条/页</option>
                            <option value="50" ${teamRevenueDetailsPageSize === 50 ? 'selected' : ''}>50条/页</option>
                            <option value="100" ${teamRevenueDetailsPageSize === 100 ? 'selected' : ''}>100条/页</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    // 更新DOM
    teamRevenueDetailsDataContainer.innerHTML = html;
}

// 初始化团队收益明细表单
function initTeamRevenueDetailsForm() {
    const form = document.getElementById('teamRevenueDetailsForm');
    if (form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // 重置分页参数
            teamRevenueDetailsCurrentPage = 1;
            
            // 异步调用loadTeamRevenueDetails，避免阻塞事件处理
            setTimeout(() => {
                loadTeamRevenueDetails();
            }, 0);
        });
        
        // 初始化刷新按钮
        const refreshBtn = document.getElementById('refreshTeamRevenueDetails');
        if (refreshBtn) {
            refreshBtn.addEventListener('click', function() {
                // 重新加载数据
                loadTeamRevenueDetails();
            });
        }
        
        // 初始化重置按钮
        const resetBtn = document.getElementById('resetTeamRevenueDetails');
        if (resetBtn) {
            resetBtn.addEventListener('click', function() {
                // 清空表单
                if (document.getElementById('teamRevenueDetailsUserId')) document.getElementById('teamRevenueDetailsUserId').value = '';
                if (document.getElementById('teamRevenueDetailsUsername')) document.getElementById('teamRevenueDetailsUsername').value = '';
                if (document.getElementById('teamRevenueDetailsTeamUserId')) document.getElementById('teamRevenueDetailsTeamUserId').value = '';
                if (document.getElementById('teamRevenueDetailsTeamUsername')) document.getElementById('teamRevenueDetailsTeamUsername').value = '';
                if (document.getElementById('teamRevenueDetailsRevenueSource')) document.getElementById('teamRevenueDetailsRevenueSource').value = '';
                if (document.getElementById('teamRevenueDetailsAgentLevel')) document.getElementById('teamRevenueDetailsAgentLevel').value = '';
                if (document.getElementById('teamRevenueDetailsPeriod')) document.getElementById('teamRevenueDetailsPeriod').value = 0;
                
                // 重置参数
                teamRevenueDetailsCurrentPeriod = 0; // 默认0，表示查看所有
                teamRevenueDetailsUserId = '';
                teamRevenueDetailsUsername = '';
                teamRevenueDetailsTeamUserId = '';
                teamRevenueDetailsTeamUsername = '';
                teamRevenueDetailsCurrentPage = 1;
                
                // 不调用接口，只重置表单
            });
        }
    }
}

// 暴露全局变量
window.teamRevenueDetailsCurrentPeriod = teamRevenueDetailsCurrentPeriod;
window.teamRevenueDetailsUserId = teamRevenueDetailsUserId;
window.teamRevenueDetailsUsername = teamRevenueDetailsUsername;
window.teamRevenueDetailsTeamUserId = teamRevenueDetailsTeamUserId;
window.teamRevenueDetailsTeamUsername = teamRevenueDetailsTeamUsername;
window.teamRevenueDetailsCurrentPage = teamRevenueDetailsCurrentPage;
window.teamRevenueDetailsPageSize = teamRevenueDetailsPageSize;
window.teamRevenueDetailsTotalPages = teamRevenueDetailsTotalPages;
window.teamRevenueDetailsTotalRecords = teamRevenueDetailsTotalRecords;
window.loadTeamRevenueDetails = loadTeamRevenueDetails;
window.renderTeamRevenueDetails = renderTeamRevenueDetails;
window.initTeamRevenueDetailsForm = initTeamRevenueDetailsForm;