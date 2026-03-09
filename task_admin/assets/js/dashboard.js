// 仪表板相关功能
// 全局图表实例
let taskTrendChart = null;
let revenueDistributionChart = null;
// 当前图表周期
let currentChartPeriod = 7;

// 是否显示数据级别
let showDataSizeFormat = true;

// 当前数据尺度
let currentDataScale = 100;

// 全局图表实例
let miniTaskChart = null;
let miniFinanceChart = null;
let miniUserChart = null;
let miniExpenseChart = null;
let miniTicketChart = null;
let mainTrendChart = null;
let taskTypePieChartInstance = null;
let financePieChartInstance = null;

// 切换图表周期
function changeChartPeriod(period) {
    console.log('=== 开始切换周期 ===');
    console.log('切换到周期:', period, '天');
    

    currentChartPeriod = period;
    console.log('更新后 currentChartPeriod:', currentChartPeriod);
    
    // 更新按钮状态
    console.log('更新按钮状态...');
    document.querySelectorAll('.period-btn').forEach(btn => {
        btn.style.background = 'transparent';
        btn.style.color = '#64748b';
        btn.style.boxShadow = 'none';
    });
    
    const activeBtn = document.getElementById(`period${period}`);
    if (activeBtn) {
        console.log('激活按钮:', activeBtn.id);
        activeBtn.style.background = '#4f46e5';
        activeBtn.style.color = 'white';
        activeBtn.style.boxShadow = '0 2px 4px rgba(79, 70, 229, 0.3)';
    } else {
        console.warn('未找到对应按钮:', `period${period}`);
    }
    
    // 重新加载仪表板数据
    console.log('开始重新加载仪表板数据...');
    loadDashboard();
    console.log('数据尺度:', currentDataScale);
    console.log('=== 切换周期完成 ===');
}

// 设置数据尺度
function setDataScale(scale) {
    console.log('=== 开始切换数据库维度 ===');
    console.log('切换到数据库维度:', scale);
    
    // 更新全局变量
    currentDataScale = scale;
    console.log('更新后 currentDataScale:', currentDataScale);
    
    // 更新按钮状态
    console.log('更新按钮状态...');
    document.querySelectorAll('.scale-btn').forEach(btn => {
        btn.style.background = 'transparent';
        btn.style.color = '#64748b';
        btn.style.boxShadow = 'none';
    });
    
    const activeBtn = document.getElementById(`scale${scale}`);
    if (activeBtn) {
        console.log('激活按钮:', activeBtn.id);
        activeBtn.style.background = '#4f46e5';
        activeBtn.style.color = 'white';
        activeBtn.style.boxShadow = '0 2px 4px rgba(79, 70, 229, 0.3)';
    } else {
        console.warn('未找到对应按钮:', `scale${scale}`);
    }
    
    // 重新加载仪表板数据
    console.log('开始重新加载仪表板数据...');
    loadDashboard();
    console.log('=== 切换数据库维度完成 ===');
}

// 加载统计面板
async function loadDashboard() {
    console.log('=== 开始加载仪表板数据 ===');
    console.log('当前周期:', currentChartPeriod, '天');
    
    try {
        const apiUrl = `${API_BASE}/api/stats/dashboard.php?period=${currentChartPeriod}&scale=${currentDataScale}`;
        console.log('请求API:', apiUrl);
        console.log('当前数据库维度:', currentDataScale);
        
        const data = await apiRequest(apiUrl);
        console.log('API响应:', data);
        
        if (data.code === 0) {
            console.log('API请求成功，开始更新数据...');
            const d = data.data;
            
            // 任务核心模块
            if (d.task_core) {
                console.log('更新任务核心模块数据');
                const statTotalSendTasks = document.getElementById('stat_total_send_tasks');
                if (statTotalSendTasks) statTotalSendTasks.textContent = String(d.task_core.total_send_tasks ?? 0);
                const statTotalExpiredTasks = document.getElementById('stat_total_expired_tasks');
                if (statTotalExpiredTasks) statTotalExpiredTasks.textContent = String(d.task_core.total_expired_tasks ?? 0);
                const statTotalReceiveTasks = document.getElementById('stat_total_receive_tasks');
                if (statTotalReceiveTasks) statTotalReceiveTasks.textContent = String(d.task_core.total_receive_tasks ?? 0);
                const statTotalPendingTasks = document.getElementById('stat_total_pending_tasks');
                if (statTotalPendingTasks) statTotalPendingTasks.textContent = String(d.task_core.total_pending_tasks ?? 0);
                const statTotalCompletedTasks = document.getElementById('stat_total_completed_tasks');
                if (statTotalCompletedTasks) statTotalCompletedTasks.textContent = String(d.task_core.total_completed_tasks ?? 0);
                const statTodayDoingTasks = document.getElementById('stat_today_doing_tasks');
                if (statTodayDoingTasks) statTodayDoingTasks.textContent = String(d.task_core.today_doing_tasks ?? 0);
                const statTodayReviewingTasks = document.getElementById('stat_today_reviewing_tasks');
                if (statTodayReviewingTasks) statTodayReviewingTasks.textContent = String(d.task_core.today_reviewing_tasks ?? 0);
                const statSingleTasks = document.getElementById('stat_single_tasks');
                if (statSingleTasks) statSingleTasks.textContent = String(d.task_core.single_tasks ?? 0);
                const statComboTasks = document.getElementById('stat_combo_tasks');
                if (statComboTasks) statComboTasks.textContent = String(d.task_core.combo_tasks ?? 0);
                const statMagnifierTasks = document.getElementById('stat_magnifier_tasks');
                if (statMagnifierTasks) statMagnifierTasks.textContent = String(d.task_core.magnifier_tasks ?? 0);
            } else {
                console.warn('任务核心模块数据不存在');
            }
            
            // 财务收支模块
            if (d.finance) {
                console.log('更新财务收支模块数据');
                //充值收入
                const statTotalRecharge = document.getElementById('stat_total_recharge');
                if (statTotalRecharge) statTotalRecharge.textContent = '+' + (d.finance.total_recharge ?? '0.00');

                //提现支出
                const statTotalWithdraw = document.getElementById('stat_total_withdraw');
                if (statTotalWithdraw) statTotalWithdraw.textContent = '-' + (d.finance.total_withdraw ?? '0.00');

              
                //高级团长佣金支出
                const statSecondAgentCommission = document.getElementById('stat_second_agent_commission');
                if (statSecondAgentCommission) statSecondAgentCommission.textContent = '-' + (d.finance.second_agent_commission ?? '0.00');

                 //普通团长佣金支出
                const statNormalAgentCommission = document.getElementById('stat_normal_agent_commission');
                if (statNormalAgentCommission) statNormalAgentCommission.textContent = '-' + (d.finance.normal_agent_commission ?? '0.00');
                
               
                //任务奖励支出
                const statTaskRewardExpense = document.getElementById('stat_task_reward_expense');
                if (statTaskRewardExpense) statTaskRewardExpense.textContent = '-' + (d.finance.task_reward_expense ?? '0.00');
                
                //账号购买支出
                const statAccountPurchaseExpense = document.getElementById('stat_account_purchase_expense');
                if (statAccountPurchaseExpense) statAccountPurchaseExpense.textContent = '-' + (d.finance.account_purchase_expense ?? '0.00');
                
                //账号租金奖励支出
                const statAccountRentalReward = document.getElementById('stat_account_rental_reward');
                if (statAccountRentalReward) statAccountRentalReward.textContent = '-' + (d.finance.account_rental_reward ?? '0.00');
                
                //总利润
                const statTotalProfit = document.getElementById('stat_total_profit');
                if (statTotalProfit) statTotalProfit.textContent = '+' + (d.finance.total_profit ?? '0.00');
                
                //利润margin
                const statProfitMargin = document.getElementById('stat_profit_margin');
                if (statProfitMargin) statProfitMargin.textContent = (d.finance.profit_margin ?? '0.00') + '%';
            } else {
                console.warn('财务收支模块数据不存在');
            }
            
            // 用户分析模块
            if (d.user_analysis) {
                console.log('更新用户分析模块数据');
                const statTotalSendUsersCounts = document.getElementById('stat_total_send_users_counts');
                if (statTotalSendUsersCounts) statTotalSendUsersCounts.textContent = String(d.user_analysis.total_send_users ?? 0);    
                const statTotalSendUsers = document.getElementById('stat_total_send_users');
                if (statTotalSendUsers) statTotalSendUsers.textContent = String(d.user_analysis.total_send_users ?? 0);
                const statTotalReceiveUsers = document.getElementById('stat_total_receive_users');
                if (statTotalReceiveUsers) statTotalReceiveUsers.textContent = String(d.user_analysis.total_receive_users ?? 0);
                const statSeniorAgents = document.getElementById('stat_senior_agents');
                if (statSeniorAgents) statSeniorAgents.textContent = String(d.user_analysis.senior_agents ?? 0);
                const statNormalAgents = document.getElementById('stat_normal_agents');
                if (statNormalAgents) statNormalAgents.textContent = String(d.user_analysis.normal_agents ?? 0);
                const statNormalUsers = document.getElementById('stat_normal_users');
                if (statNormalUsers) statNormalUsers.textContent = String(d.user_analysis.normal_users ?? 0);
                const statSeniorAgentRatio = document.getElementById('stat_senior_agent_ratio');
                if (statSeniorAgentRatio) statSeniorAgentRatio.textContent = (d.user_analysis.senior_agent_ratio ?? '0.00') + '%';
                const statNormalAgentRatio = document.getElementById('stat_normal_agent_ratio');
                if (statNormalAgentRatio) statNormalAgentRatio.textContent = (d.user_analysis.normal_agent_ratio ?? '0.00') + '%';
                const statNormalUserRatio = document.getElementById('stat_normal_user_ratio');
                if (statNormalUserRatio) statNormalUserRatio.textContent = (d.user_analysis.normal_user_ratio ?? '0.00') + '%';
                // 注意：stat_active_users 和 stat_today_new_users 由今日运营数据模块处理，避免重复赋值
            } else {
                console.warn('用户分析模块数据不存在');
            }
            
            // 今日运营数据分析模块
            if (d.today_operation) {
                console.log('更新今日运营数据分析模块数据');
                const statTodayNewUsers = document.getElementById('stat_today_new_users');
                if (statTodayNewUsers) statTodayNewUsers.textContent = String(d.today_operation.today_new_users ?? 0);
                const statTodayRecharge = document.getElementById('stat_today_recharge');
                if (statTodayRecharge) statTodayRecharge.textContent = '+' + (d.today_operation.today_recharge ?? '0.00');
                const statTodayWithdraw = document.getElementById('stat_today_withdraw');
                if (statTodayWithdraw) statTodayWithdraw.textContent = '-' + (d.today_operation.today_withdraw ?? '0.00');
                const statTodayPendingWithdraw = document.getElementById('stat_today_pending_withdraw');
                if (statTodayPendingWithdraw) statTodayPendingWithdraw.textContent = '-' + (d.today_operation.today_pending_withdraw ?? '0.00');
                const statActiveUsers = document.getElementById('stat_active_users');
                if (statActiveUsers) statActiveUsers.textContent = String(d.today_operation.active_users ?? 0);
            } else {
                console.warn('今日运营数据分析模块数据不存在');
            }
            
            // 任务支出细分模块
            if (d.task_expense) {
                console.log('更新任务支出细分模块数据');
                const statSingleTaskExpense = document.getElementById('stat_single_task_expense');
                if (statSingleTaskExpense) statSingleTaskExpense.textContent = '¥' + (d.task_expense.single_task_expense ?? '0.00');
                const statComboTaskExpense = document.getElementById('stat_combo_task_expense');
                if (statComboTaskExpense) statComboTaskExpense.textContent = '¥' + (d.task_expense.combo_task_expense ?? '0.00');
                const statPositiveCommentExpense = document.getElementById('stat_positive_comment_expense');
                if (statPositiveCommentExpense) statPositiveCommentExpense.textContent = '¥' + (d.task_expense.positive_comment_expense ?? '0.00');
                const statNeutralCommentExpense = document.getElementById('stat_neutral_comment_expense');
                if (statNeutralCommentExpense) statNeutralCommentExpense.textContent = '¥' + (d.task_expense.neutral_comment_expense ?? '0.00');
                const statPositiveNeutralExpense = document.getElementById('stat_positive_neutral_expense');
                if (statPositiveNeutralExpense) statPositiveNeutralExpense.textContent = '¥' + (d.task_expense.positive_neutral_expense ?? '0.00');
                const statNeutralNegativeExpense = document.getElementById('stat_neutral_negative_expense');
                if (statNeutralNegativeExpense) statNeutralNegativeExpense.textContent = '¥' + (d.task_expense.neutral_negative_expense ?? '0.00');
                const statMagnifierTaskExpense = document.getElementById('stat_magnifier_task_expense');
                if (statMagnifierTaskExpense) statMagnifierTaskExpense.textContent = '¥' + (d.task_expense.magnifier_task_expense ?? '0.00');
            } else {
                console.warn('任务支出细分模块数据不存在');
            }
            
            // 工单处理模块
            if (d.ticket_handling) {
                console.log('更新工单处理模块数据');
                const statTotalTickets = document.getElementById('stat_total_tickets');
                if (statTotalTickets) statTotalTickets.textContent = String(d.ticket_handling.total_tickets ?? 0);
                const statClosedTickets = document.getElementById('stat_closed_tickets');
                if (statClosedTickets) statClosedTickets.textContent = String(d.ticket_handling.closed_tickets ?? 0);
                const statCompletedTickets = document.getElementById('stat_completed_tickets');
                if (statCompletedTickets) statCompletedTickets.textContent = String(d.ticket_handling.completed_tickets ?? 0);
                const statInProgressTickets = document.getElementById('stat_in_progress_tickets');
                if (statInProgressTickets) statInProgressTickets.textContent = String(d.ticket_handling.in_progress_tickets ?? 0);
                const statPendingTickets = document.getElementById('stat_pending_tickets');
                if (statPendingTickets) statPendingTickets.textContent = String(d.ticket_handling.pending_tickets ?? 0);
            } else {
                console.warn('工单处理模块数据不存在');
            }
            
            // 渲染图表
            console.log('开始渲染图表...');
            renderCharts(d, currentChartPeriod);
            console.log('图表渲染完成');
        } else {
            console.error('加载统计数据失败', data);
            showToast('加载统计数据失败: ' + data.message, 'error');
        }
    } catch (err) {
        console.error('加载统计数据失败', err);
        showToast('加载统计数据失败', 'error');
    } finally {
        console.log('=== 加载仪表板数据完成 ===');
    }
}

// 格式化数据大小，显示级别
function formatDataSize(value) {
    return `${value} (1-${currentDataScale})`;
}

// 渲染图表
function renderCharts(data, period = currentChartPeriod) {
    console.log('=== 开始渲染图表 ===');
    console.log('周期:', period, '天');
    console.log('数据尺度:', currentDataScale);
    
    // 生成日期标签
    function generateDateLabels(period) {
        const labels = [];
        for (let i = period - 1; i >= 0; i--) {
            const date = new Date();
            date.setDate(date.getDate() - i);
            const displayDate = `${date.getMonth() + 1}/${date.getDate()}`;
            labels.push(displayDate);
        }
        return labels;
    }
    
    // 生成随机数据（用于演示）
    function generateRandomData(period, min = 10, max = 100) {
        return Array.from({ length: period }, () => Math.floor(Math.random() * (max - min + 1)) + min);
    }
    
    const labels = generateDateLabels(period);
    
    // 根据数据尺度调整数据范围
    const scaleFactor = currentDataScale / 100;
    console.log('数据尺度因子:', scaleFactor);
    
    // 渲染迷你任务图表
    const miniTaskCtx = document.getElementById('miniTaskChart');
    if (miniTaskCtx) {
        if (miniTaskChart) {
            miniTaskChart.destroy();
        }
        miniTaskChart = new Chart(miniTaskCtx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: '任务量',
                    data: generateRandomData(period, 50, 300),
                    borderColor: '#3b82f6',
                    borderWidth: 2,
                    pointRadius: 0,
                    fill: false,
                    tension: 0.2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    x: {
                        display: false
                    },
                    y: {
                        display: false
                    }
                }
            }
        });
    }
    
    // 渲染迷你财务图表
    const miniFinanceCtx = document.getElementById('miniFinanceChart');
    if (miniFinanceCtx) {
        if (miniFinanceChart) {
            miniFinanceChart.destroy();
        }
        miniFinanceChart = new Chart(miniFinanceCtx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    data: generateRandomData(period, 30, 150),
                    borderColor: '#10b981',
                    pointRadius: 0,
                    borderWidth: 2,
                    tension: 0.2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    x: {
                        display: false
                    },
                    y: {
                        display: false
                    }
                }
            }
        });
    }
    
    // 渲染迷你用户图表
    const miniUserCtx = document.getElementById('miniUserChart');
    if (miniUserCtx) {
        if (miniUserChart) {
            miniUserChart.destroy();
        }
        miniUserChart = new Chart(miniUserCtx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    data: generateRandomData(period, 20, 80),
                    borderColor: '#8b5cf6',
                    pointRadius: 0,
                    borderWidth: 2,
                    tension: 0.2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    x: {
                        display: false
                    },
                    y: {
                        display: false
                    }
                }
            }
        });
    }
    
    // 渲染迷你支出图表
    const miniExpenseCtx = document.getElementById('miniExpenseChart');
    if (miniExpenseCtx) {
        if (miniExpenseChart) {
            miniExpenseChart.destroy();
        }
        miniExpenseChart = new Chart(miniExpenseCtx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    data: generateRandomData(period, 10, 100),
                    borderColor: '#f59e0b',
                    pointRadius: 0,
                    borderWidth: 2,
                    tension: 0.2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    x: {
                        display: false
                    },
                    y: {
                        display: false
                    }
                }
            }
        });
    }
    
    // 渲染迷你工单图表
    const miniTicketCtx = document.getElementById('miniTicketChart');
    if (miniTicketCtx) {
        if (miniTicketChart) {
            miniTicketChart.destroy();
        }
        miniTicketChart = new Chart(miniTicketCtx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    data: generateRandomData(period, 5, 40),
                    borderColor: '#14b8a6',
                    pointRadius: 0,
                    borderWidth: 2,
                    tension: 0.2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    x: {
                        display: false
                    },
                    y: {
                        display: false
                    }
                }
            }
        });
    }
    
    // 渲染主趋势图表
    const mainTrendCtx = document.getElementById('mainTrendChart');
    if (mainTrendCtx) {
        if (mainTrendChart) {
            mainTrendChart.destroy();
        }
        
        // 准备趋势数据
        let sendTasksData = [];
        let receiveTasksData = [];
        let completedTasksData = [];
        let newUsersData = [];
        let agentCommissionData = [];
        let taskRewardData = [];
        
        // 尝试从API数据中获取实际趋势数据
        const trendKey = `${period}_days_daily`;
        if (data.trends?.[trendKey]) {
            const dailyData = data.trends[trendKey];
            
            // 优先使用API返回的实际数据
            sendTasksData = dailyData.send_tasks?.map(item => item.count) || [];
            receiveTasksData = dailyData.receive_tasks?.map(item => item.count) || [];
            completedTasksData = dailyData.completed_tasks?.map(item => item.count) || [];
            newUsersData = dailyData.new_users?.map(item => item.count) || [];
            agentCommissionData = dailyData.agent_commission?.map(item => item.amount) || [];
            taskRewardData = dailyData.task_reward?.map(item => item.amount) || [];
            
            // 如果某些数据不存在，使用其他数据作为备选
            if (sendTasksData.length === 0 && dailyData.tasks) {
                sendTasksData = dailyData.tasks.map(item => item.count);
            }
            if (receiveTasksData.length === 0 && dailyData.tasks) {
                receiveTasksData = dailyData.tasks.map(item => item.count);
            }
            if (completedTasksData.length === 0 && dailyData.tasks) {
                completedTasksData = dailyData.tasks.map(item => item.count);
            }
            if (newUsersData.length === 0 && dailyData.tasks) {
                newUsersData = dailyData.tasks.map(item => Math.floor(item.count * 0.3));
            }
            if (agentCommissionData.length === 0 && dailyData.tasks) {
                agentCommissionData = dailyData.tasks.map(item => Math.floor(item.count * 0.2));
            }
            if (taskRewardData.length === 0 && dailyData.tasks) {
                taskRewardData = dailyData.tasks.map(item => Math.floor(item.count * 0.4));
            }
        }
        
        // 确保所有数据数组长度与标签长度一致
        const expectedLength = labels.length;
        sendTasksData = ensureArrayLength(sendTasksData, expectedLength);
        receiveTasksData = ensureArrayLength(receiveTasksData, expectedLength);
        completedTasksData = ensureArrayLength(completedTasksData, expectedLength);
        newUsersData = ensureArrayLength(newUsersData, expectedLength);
        agentCommissionData = ensureArrayLength(agentCommissionData, expectedLength);
        taskRewardData = ensureArrayLength(taskRewardData, expectedLength);
        
        // 辅助函数：确保数组长度与期望长度一致
        function ensureArrayLength(arr, length) {
            if (arr.length === length) return arr;
            if (arr.length === 0) return Array(length).fill(0);
            // 如果数据长度不足，重复填充
            const result = [];
            for (let i = 0; i < length; i++) {
                result.push(arr[i % arr.length]);
            }
            return result;
        }
        
        mainTrendChart = new Chart(mainTrendCtx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: '派单任务',
                        data: sendTasksData,
                        borderColor: '#2563eb',
                        tension: 0.2
                    },
                    {
                        label: '接单任务',
                        data: receiveTasksData,
                        borderColor: '#7c3aed',
                        tension: 0.2
                    },
                    {
                        label: '完成任务',
                        data: completedTasksData,
                        borderColor: '#059669',
                        tension: 0.2
                    },
                    {
                        label: '新增用户',
                        data: newUsersData,
                        borderColor: '#d97706',
                        tension: 0.2
                    },
                    {
                        label: '团长佣金支出',
                        data: agentCommissionData,
                        borderColor: '#ef4444',
                        tension: 0.2
                    },
                    {
                        label: '任务奖励支出',
                        data: taskRewardData,
                        borderColor: '#f97316',
                        tension: 0.2
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: {
                    mode: 'index'
                },
                scales: {
                    y: {
                        title: {
                            display: true,
                            text: `数据维度 (1-${currentDataScale})`
                        },
                        beginAtZero: true,
                        // 根据数据维度级别自动调整刻度范围
                        suggestedMax: function(context) {
                            const maxValue = Math.max(...sendTasksData, ...receiveTasksData, ...completedTasksData, ...newUsersData, ...agentCommissionData, ...taskRewardData) || 100;
                            // 根据数据尺度确定合适的最大值
                            if (currentDataScale === 100) {
                                return 100;
                            } else if (currentDataScale === 1000) {
                                return 1000;
                            } else if (currentDataScale === 10000) {
                                return 10000;
                            } else {
                                // 对于更大的尺度，向上取整到最近的10的幂次
                                const magnitude = Math.pow(10, Math.floor(Math.log10(maxValue)));
                                return Math.ceil(maxValue / magnitude) * magnitude;
                            }
                        },
                        ticks: {
                            // 确保基础间隔数据值保持一致，使用10作为基础间隔
                            stepSize: 10,
                            // 自定义刻度生成器
                            callback: function(value) {
                                // 确保值为整数
                                value = Math.round(value);
                                
                                // 根据数据尺度确定显示规则
                                if (currentDataScale === 100) {
                                    // 1-100范围：10、20、30、40、50、60、70、80、90、100
                                    if (value % 10 === 0 && value <= 100) {
                                        return value;
                                    }
                                    return null;
                                } else if (currentDataScale === 1000) {
                                    // 1-1000范围：100、200、...、1000
                                    if (value % 100 === 0 && value <= 1000) {
                                        return value;
                                    }
                                    return null;
                                } else if (currentDataScale === 10000) {
                                    // 1-10000范围：1000、2000、...、10000
                                    if (value % 1000 === 0 && value <= 10000) {
                                        return value;
                                    }
                                    return null;
                                } else {
                                    // 对于更大的尺度，使用单位递进规则
                                    if (value >= 100000000) {
                                        // 亿级
                                        return (value / 100000000).toFixed(1) + '亿';
                                    } else if (value >= 10000) {
                                        // 万级
                                        return (value / 10000).toFixed(1) + '万';
                                    } else if (value >= 1000) {
                                        // 千级
                                        return (value / 1000).toFixed(1) + 'k';
                                    }
                                    return value;
                                }
                            }
                        }
                    }
                }
            }
        });
    }
    
    // 渲染任务类型占比饼图 (使用Chart.js)
    const taskTypePieChart = document.getElementById('taskTypePieChart');
    if (taskTypePieChart) {
        // 设置容器样式
        taskTypePieChart.style.position = 'relative';
        taskTypePieChart.style.width = '90%';
        taskTypePieChart.style.height = '90%';
        taskTypePieChart.style.userSelect = 'none';
        taskTypePieChart.style.webkitTapHighlightColor = 'rgba(0, 0, 0, 0)';
        
        // 创建canvas元素
        let canvas = taskTypePieChart.querySelector('canvas');
        if (!canvas) {
            canvas = document.createElement('canvas');
            taskTypePieChart.innerHTML = '';
            taskTypePieChart.appendChild(canvas);
        }
        
        // 设置canvas样式
        canvas.style.width = '80%';
        canvas.style.height = '80%';
        canvas.style.display = 'block';
        
        // 准备任务类型数据 - 使用与统计数据完全一致的数据
        const singleTasks = data?.task_core?.single_tasks ?? 0;
        const comboTasks = data?.task_core?.combo_tasks ?? 0;
        const magnifierTasks = data?.task_core?.magnifier_tasks ?? 0;
        const rentalTasks = data?.task_core?.rental_tasks?.total ?? 0;
        
        console.log('任务类型图表数据（与统计数据一致）:', {
            singleTasks, comboTasks, magnifierTasks, rentalTasks
        });
        
        // 创建过滤后的数据 - 只显示有数据的项
        const taskTypeData = [];
        const taskTypeLabels = [];
        const taskTypeColors = [];
        
        if (singleTasks > 0) {
            taskTypeData.push(singleTasks);
            taskTypeLabels.push('单任务');
            taskTypeColors.push('#3b82f6');
        }
        
        if (comboTasks > 0) {
            taskTypeData.push(comboTasks);
            taskTypeLabels.push('组合任务');
            taskTypeColors.push('#8b5cf6');
        }
        
        if (magnifierTasks > 0) {
            taskTypeData.push(magnifierTasks);
            taskTypeLabels.push('放大镜任务');
            taskTypeColors.push('#10b981');
        }
        
        if (rentalTasks > 0) {
            taskTypeData.push(rentalTasks);
            taskTypeLabels.push('账号租赁');
            taskTypeColors.push('#f59e0b');
        }
        
        // 如果所有数据都为0，显示空状态
        if (taskTypeData.length === 0) {
            taskTypeData.push(1);
            taskTypeLabels.push('暂无数据');
            taskTypeColors.push('#9ca3af');
        }
        
        console.log('任务类型图表过滤后数据:', {
            labels: taskTypeLabels,
            data: taskTypeData,
            colors: taskTypeColors
        });
        
        // 销毁旧的图表实例
        if (taskTypePieChartInstance) {
            taskTypePieChartInstance.destroy();
        }
        
        // 创建图表
        taskTypePieChartInstance = new Chart(canvas, {
            type: 'pie',
            data: {
                labels: taskTypeLabels,
                datasets: [{
                    data: taskTypeData,
                    backgroundColor: taskTypeColors,
                    borderWidth: 2,
                    borderColor: '#ffffffff',
                    hoverOffset: 15,
                    shadowColor: 'rgba(48, 48, 48, 0.88)',
                    shadowBlur: 5,
                    shadowOffsetX: 0,
                    shadowOffsetY: 2,
                    borderRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '70%',
                plugins: {
                    legend: {
                        position: 'right',
                        labels: {
                            padding: 15,
                            font: {
                                size: 12,
                                family: 'Arial, sans-serif'
                            },
                            color: '#5e5e5eff'
                        },
                        align: 'start',
                        padding: 20
                    },
                    tooltip: {
                        backgroundColor: 'rgba(0, 53, 97, 0.6)',
                        borderColor: '#ffffffff',
                        borderWidth: 1,
                        padding: 10,
                        titleFont: {
                            size: 14,
                            weight: 'bold',
                            color: '#202020ff'
                        },
                        bodyFont: {
                            size: 13,
                            color: '#1d1919ff'
                        },
                        callbacks: {
                            label: function(context) {
                                const label = context.label || '';
                                const value = context.parsed || 0;
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = total > 0 ? ((value / total) * 100).toFixed(2) : 0;
                                return `${label}: ¥${value.toFixed(2)} (${percentage}%)`;
                            }
                        }
                    }
                },
                onHover: function(event, chartElements) {
                    event.native.target.style.cursor = chartElements.length ? 'pointer' : 'default';
                }
            }
        });
    }
    
    // 渲染财务收支占比饼图 (使用Chart.js)
    const financePieChart = document.getElementById('financePieChart');
    if (financePieChart) {
        // 设置容器样式
        financePieChart.style.position = 'relative';
        financePieChart.style.width = '90%';
        financePieChart.style.height = '90%';
        financePieChart.style.userSelect = 'none';
        financePieChart.style.webkitTapHighlightColor = 'rgba(0, 0, 0, 0)';
        
        // 创建canvas元素
        let canvas = financePieChart.querySelector('canvas');
        if (!canvas) {
            canvas = document.createElement('canvas');
            financePieChart.innerHTML = '';
            financePieChart.appendChild(canvas);
        }
        
        // 设置canvas样式
        canvas.style.width = '100%';
        canvas.style.height = '100%';
        canvas.style.display = 'block';
        
        // 准备财务收支数据
        const parseCurrency = (value) => {
            if (typeof value === 'string') {
                // 移除千分位逗号并转换为数字
                return parseFloat(value.replace(/,/g, '')) || 0;
            }
            return parseFloat(value) || 0;
        };
        
        // 收入数据 - 使用与统计数据完全一致的数据
        const recharge = parseCurrency(data.finance.total_recharge ?? '0.00');
        const totalWithdraw = parseCurrency(data.finance.total_withdraw ?? '0.00');
        
        // 支出数据 - 使用与统计数据完全一致的数据
        const taskReward = parseCurrency(data.finance.task_reward_expense ?? '0.00');
        const seniorAgentCommission = parseCurrency(data.finance.senior_agent_commission ?? '0.00');    //高级团长佣金
        const normalAgentCommission = parseCurrency(data.finance.normal_agent_commission ?? '0.00');    //普通团长佣金

        const agentCommission = seniorAgentCommission + normalAgentCommission;
        
        // 确保使用与后端完全一致的数据
        const accountPurchaseExpense = parseCurrency(data.finance.account_purchase_expense ?? '0.00');
        const accountRentalReward = parseCurrency(data.finance.account_rental_reward ?? '0.00');
        const totalProfit = parseCurrency(data.finance.total_profit ?? '0.00');
        
        // 创建过滤后的数据 - 只显示有数据的项
        const financeData = [];
        const financeLabels = [];
        const financeColors = [];
        
        if (recharge > 0) {
            financeData.push(recharge);
            financeLabels.push('充值收入');
            financeColors.push('#10b981');
        }
        
        if (totalWithdraw > 0) {
            financeData.push(totalWithdraw);
            financeLabels.push('提现支出');
            financeColors.push('#ef4444');
        }
        
        if (taskReward > 0) {
            financeData.push(taskReward);
            financeLabels.push('任务奖励支出');
            financeColors.push('#f59e0b');
        }
        
        if (agentCommission > 0) {
            financeData.push(agentCommission);
            financeLabels.push('团长佣金支出');
            financeColors.push('#8b5cf6');
        }
        
        if (accountPurchaseExpense > 0) {
            financeData.push(accountPurchaseExpense);
            financeLabels.push('账号购买支出');
            financeColors.push('#ec4899');
        }
        
        if (accountRentalReward > 0) {
            financeData.push(accountRentalReward);
            financeLabels.push('账号出租支出');
            financeColors.push('#06b6d4');
        }
        
        // 如果所有数据都为0，显示空状态
        if (financeData.length === 0) {
            financeData.push(1);
            financeLabels.push('暂无数据');
            financeColors.push('#9ca3af');
        }
        
        console.log('财务收支图表数据:', {
            labels: financeLabels,
            data: financeData,
            colors: financeColors
        });
        
        // 销毁旧的图表实例
        if (financePieChartInstance) {
            financePieChartInstance.destroy();
        }
        
        // 创建图表
        financePieChartInstance = new Chart(canvas, {
            type: 'pie',
            data: {
                labels: financeLabels,
                datasets: [{
                    data: financeData,
                    backgroundColor: financeColors,
                    borderWidth: 2,
                    borderColor: '#ffffffff',
                    hoverOffset: 15,
                    shadowColor: 'rgba(48, 48, 48, 0.88)',
                    shadowBlur: 5,
                    shadowOffsetX: 0,
                    shadowOffsetY: 2,
                    borderRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '70%',
                plugins: {
                    legend: {
                        position: 'right',
                        labels: {
                            padding: 15,
                            font: {
                                size: 12,
                                family: 'Arial, sans-serif'
                            },
                            color: '#5e5e5eff'
                        },
                        align: 'start',
                        padding: 20
                    },
                    tooltip: {
                        backgroundColor: 'rgba(0, 53, 97, 0.6)',
                        borderColor: '#ffffffff',
                        borderWidth: 1,
                        padding: 10,
                        titleFont: {
                            size: 14,
                            weight: 'bold',
                            color: '#202020ff'
                        },
                        bodyFont: {
                            size: 13,
                            color: '#1d1919ff'
                        },
                        callbacks: {
                            label: function(context) {
                                const label = context.label || '';
                                const value = context.parsed || 0;
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = total > 0 ? ((value / total) * 100).toFixed(2) : 0;
                                return `${label}: ¥${value.toFixed(2)} (${percentage}%)`;
                            }
                        }
                    }
                },
                onHover: function(event, chartElements) {
                    event.native.target.style.cursor = chartElements.length ? 'pointer' : 'default';
                }
            }
        });
    }
}

// 初始化仪表板
function initDashboard() {
    // 加载仪表板数据
    loadDashboard();
    
    // 绑定周期切换按钮
    document.querySelectorAll('.period-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const period = parseInt(this.id.replace('period', ''));
            changeChartPeriod(period);
        });
    });
    
    // 绑定数据尺度切换按钮
    document.querySelectorAll('.scale-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const scale = parseInt(this.id.replace('scale', ''));
            setDataScale(scale);
        });
    });
}