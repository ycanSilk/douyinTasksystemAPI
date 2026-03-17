// 团队收益统计相关变量
var teamRevenueCurrentPeriod = 7;
var teamRevenueUserId = '';
var teamRevenueUsername = '';
var teamRevenueTeamName = '';
var teamRevenueTeamId = '';

// 加载团队列表数据
async function loadTeamList() {
    console.log('=== 开始加载团队列表数据 ===');
    // 检查DOM元素是否存在
    const teamListContainer = document.getElementById('teamListContainer');
    if (!teamListContainer) {
        console.error('❌ teamListContainer 元素不存在');
        return;
    }
    console.log('✅ teamListContainer 元素存在');
    
    // 显示加载状态
    teamListContainer.innerHTML = '<div style="text-align: center; padding: 40px;"><i class="ri-loading-line ri-spin"></i> 加载中...</div>';
    
    // 获取筛选参数
    const userId = document.getElementById('teamRevenueUserId') ? document.getElementById('teamRevenueUserId').value : '';
    const username = document.getElementById('teamRevenueUsername') ? document.getElementById('teamRevenueUsername').value : '';
    const agentLevel = document.getElementById('teamRevenueAgentLevel') ? document.getElementById('teamRevenueAgentLevel').value : '';
    console.log('获取团队列表筛选参数:', { userId, username, agentLevel });
    
    try {
        // 构建查询参数
        const params = new URLSearchParams();
        
        if (userId) {
            params.append('user_id', userId);
        }
        
        if (username) {
            params.append('username', username);
        }
        
        if (agentLevel) {
            params.append('agent_level', agentLevel);
        }
        
        const apiUrl = `/task_admin/api/team_revenue/team_users.php?${params.toString()}`;
        console.log('团队列表API请求URL:', apiUrl);
        
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['X-token'] = token;
        }
        console.log('请求头:', headers);
        
        console.log('🚀 发送团队列表API请求...');
        const response = await fetch(apiUrl, {
            method: 'GET',
            headers: headers,
            credentials: 'include'
        });
        console.log('团队列表API响应状态:', response.status);
        
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
        
        console.log('📦 解析团队列表API响应...');
        const data = await response.json();
        console.log('团队列表API返回数据:', data);
        
        if (data && data.code === 0) {
            console.log('✅ 团队列表数据获取成功，开始渲染');
            renderTeamList(data.data.list);
        } else {
            console.error('❌ 团队列表数据获取失败:', data.message || '未知错误');
            teamListContainer.innerHTML = `<div class="empty">${data.message || '获取团队列表数据失败'}</div>`;
        }
    } catch (err) {
        console.error('❌ 请求异常:', err);
        teamListContainer.innerHTML = '<div class="empty">网络错误，请稍后重试</div>';
    }
}

// 加载团队收益统计数据
async function loadTeamRevenue() {
    console.log('=== 开始加载团队收益统计数据 ===');
    // 检查DOM元素是否存在
    const teamRevenueDataContainer = document.getElementById('teamRevenueContainer');
    if (!teamRevenueDataContainer) {
        console.error('❌ teamRevenueContainer 元素不存在');
        return;
    }
    console.log('✅ teamRevenueContainer 元素存在');
    
    // 显示加载状态
    teamRevenueDataContainer.innerHTML = '<div style="text-align: center; padding: 40px;"><i class="ri-loading-line ri-spin"></i> 加载中...</div>';
    
    // 获取筛选参数
    const userId = document.getElementById('teamRevenueUserId') ? document.getElementById('teamRevenueUserId').value : '';
    const username = document.getElementById('teamRevenueUsername') ? document.getElementById('teamRevenueUsername').value : '';
    const agentLevel = document.getElementById('teamRevenueAgentLevel') ? document.getElementById('teamRevenueAgentLevel').value : '';
    const revenueSource = document.getElementById('teamRevenueRevenueSource') ? document.getElementById('teamRevenueRevenueSource').value : '';
    const period = document.getElementById('teamRevenuePeriod') ? document.getElementById('teamRevenuePeriod').value : 7;
    console.log('获取筛选参数:', { userId, username, agentLevel, revenueSource, period });
    
    // 保存当前筛选参数
    teamRevenueCurrentPeriod = period;
    teamRevenueUserId = userId;
    teamRevenueUsername = username;
    try {
        // 构建查询参数
        const params = new URLSearchParams({
            days: period
        });
        
        if (userId) {
            params.append('user_id', userId);
        }
        
        if (username) {
            params.append('username', username);
        }
        
        if (agentLevel) {
            params.append('agent_level', agentLevel);
        }
        
        if (revenueSource) {
            params.append('revenue_source', revenueSource);
        }
        
        const apiUrl = `/task_admin/api/team_revenue/statistics.php?${params.toString()}`;
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
            renderTeamRevenue(data.data);
        } else {
            console.error('❌ 数据获取失败:', data.message || '未知错误');
            teamRevenueDataContainer.innerHTML = `<div class="empty">${data.message || '获取数据失败'}</div>`;
        }
    } catch (err) {
        console.error('❌ 请求异常:', err);
        teamRevenueDataContainer.innerHTML = '<div class="empty">网络错误，请稍后重试</div>';
    }
}

// 渲染团队收益统计数据
function renderTeamRevenue(data) {
    const teamRevenueDataContainer = document.getElementById('teamRevenueContainer');
    if (!teamRevenueDataContainer) {
        return;
    }
    
    // 构建HTML
    let html = `
        <div class="bg-white rounded-xl shadow-md border border-gray-200 overflow-hidden">
            <div class="bg-gray-50 border-b border-gray-200 px-6 py-4">
                <h3 class="text-lg font-semibold text-gray-800">团队收益统计</h3>
            </div>
            <div class="p-6">
                <!-- 汇总数据 -->
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
                    <div class="bg-blue-50 rounded-lg p-4 border border-blue-100">
                        <div class="text-sm text-blue-600 font-medium mb-1">任务收益</div>
                        <div class="text-2xl font-bold text-blue-700">¥${parseFloat(data.task_revenue || 0).toFixed(2)}</div>
                    </div>
                    <div class="bg-green-50 rounded-lg p-4 border border-green-100">
                        <div class="text-sm text-green-600 font-medium mb-1">账号租赁收益</div>
                        <div class="text-2xl font-bold text-green-700">¥${parseFloat(data.rental_revenue || 0).toFixed(2)}</div>
                    </div>
                    <div class="bg-purple-50 rounded-lg p-4 border border-purple-100">
                        <div class="text-sm text-purple-600 font-medium mb-1">总收益</div>
                        <div class="text-2xl font-bold text-purple-700">¥${parseFloat(data.total_revenue || 0).toFixed(2)}</div>
                    </div>
                </div>
                
                <!-- 统计周期信息 -->
                <div class="bg-gray-50 rounded-lg p-4 border border-gray-200">
                    <div class="text-sm text-gray-600 font-medium">统计周期</div>
                    <div class="text-lg font-semibold text-gray-800">${getTeamRevenuePeriodText(teamRevenueCurrentPeriod)}天</div>
                </div>
            </div>
        </div>
    `;
    
    // 更新DOM
    teamRevenueDataContainer.innerHTML = html;
    
    // 加载团队列表数据
    loadTeamList();
}

// 渲染团队列表数据
function renderTeamList(data) {
    const teamListContainer = document.getElementById('teamListContainer');
    if (!teamListContainer) {
        return;
    }
    
    // 构建HTML
    let html = `
        <div class="bg-white rounded-xl shadow-md border border-gray-200 overflow-hidden">
            <div class="bg-gray-50 border-b border-gray-200 px-6 py-4">
                <h3 class="text-lg font-semibold text-gray-800">所有团队列表</h3>
            </div>
            <div class="overflow-x-auto" style="max-height: calc(100vh - 300px); overflow-y: auto;">
                <table class="w-full min-w-[1000px] divide-y divide-gray-200">
                    <thead class="bg-gray-50 sticky top-0">
                        <tr>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">用户ID</th>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">用户名</th>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">手机号</th>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">当前用户代理等级</th>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">直接上级</th>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">间接上级</th>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">直接下级</th>
                            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">创建时间</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
    `;
    
    // 渲染团队列表数据
    if (data && data.length > 0) {
        data.forEach(user => {
            // 构建直接下级列表
            let directSubordinates = '';
            if (user.subordinates && user.subordinates.direct && user.subordinates.direct.length > 0) {
                directSubordinates = user.subordinates.direct.map(sub => `${sub.username}(${sub.id})`).join(', ');
            }
            
            html += `
                        <tr>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${user.id || '-'}</td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                                    ${user.username || '-'}
                                </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${user.phone || '-'}</td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${user.is_agent === 0 ? 'bg-gray-100 text-gray-800' : user.is_agent === 1 ? 'bg-blue-100 text-blue-800' : user.is_agent === 2 ? 'bg-green-100 text-green-800' : 'bg-purple-100 text-purple-800'}">
                                    ${user.is_agent_text || '-'}
                                </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${user.superiors && user.superiors.direct ? `${user.superiors.direct.username}(${user.superiors.direct.id})` : '-'}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${user.superiors && user.superiors.indirect ? `${user.superiors.indirect.username}(${user.superiors.indirect.id})` : '-'}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${directSubordinates || '-'}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${user.created_at || '-'}</td>
                        </tr>
            `;
        });
    } else {
        html += `
                        <tr>
                            <td colspan="8" class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 text-center">暂无数据</td>
                        </tr>
        `;
    }
    
    html += `
                    </tbody>
                </table>
            </div>
        </div>
    `;
    
    // 更新DOM
    teamListContainer.innerHTML = html;
}

// 获取周期文本
function getTeamRevenuePeriodText(period) {
    return period;
}

// 初始化团队收益统计表单
function initTeamRevenueForm() {
    const form = document.getElementById('teamRevenueForm');
    if (form) {
        // 设置表单宽度为100%
        form.style.width = '100%';
        form.style.maxWidth = 'none';
        
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // 异步调用loadTeamRevenue，避免阻塞事件处理
            setTimeout(() => {
                loadTeamRevenue();
            }, 0);
        });
        
        // 初始化重置按钮
        const resetBtn = document.getElementById('resetTeamRevenue');
        if (resetBtn) {
            resetBtn.addEventListener('click', function() {
                // 清空表单
                if (document.getElementById('teamRevenueUserId')) document.getElementById('teamRevenueUserId').value = '';
                if (document.getElementById('teamRevenueUsername')) document.getElementById('teamRevenueUsername').value = '';
                if (document.getElementById('teamRevenueAgentLevel')) document.getElementById('teamRevenueAgentLevel').value = '';
                if (document.getElementById('teamRevenueRevenueSource')) document.getElementById('teamRevenueRevenueSource').value = '';
                if (document.getElementById('teamRevenuePeriod')) document.getElementById('teamRevenuePeriod').value = 7;
                
                // 重置参数
                teamRevenueCurrentPeriod = 7;
                teamRevenueUserId = '';
                teamRevenueUsername = '';
                
                // 清空容器
                const teamRevenueContainer = document.getElementById('teamRevenueContainer');
                if (teamRevenueContainer) {
                    teamRevenueContainer.innerHTML = '';
                }
                
                const teamListContainer = document.getElementById('teamListContainer');
                if (teamListContainer) {
                    teamListContainer.innerHTML = '';
                }
            });
        }
    }
}

// 暴露全局变量
window.teamRevenueCurrentPeriod = teamRevenueCurrentPeriod;
window.teamRevenueUserId = teamRevenueUserId;
window.teamRevenueUsername = teamRevenueUsername;
window.teamRevenueTeamName = teamRevenueTeamName;
window.teamRevenueTeamId = teamRevenueTeamId;
window.loadTeamRevenue = loadTeamRevenue;
window.loadTeamList = loadTeamList;
window.renderTeamRevenue = renderTeamRevenue;
window.renderTeamList = renderTeamList;
window.initTeamRevenueForm = initTeamRevenueForm;