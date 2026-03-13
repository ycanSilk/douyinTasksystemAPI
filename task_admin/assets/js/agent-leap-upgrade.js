async function loadCUsersForUpgrade(page = 1) {
    
    const username = document.getElementById('agentUpgradeUsername').value;
    const userId = document.getElementById('agentUpgradeUserId').value;
    
    
    try {
        let url = `/task_admin/api/agent/c-users-list.php?page=${page}`;
        if (username) {
            url += `&username=${encodeURIComponent(username)}`;
        }
        if (userId) {
            url += `&user_id=${userId}`;
        }
        
        
        const token = sessionStorage.getItem('admin_token');
        
        const headers = {
            'Content-Type': 'application/json'
        };
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        
        const response = await fetch(url, {
            method: 'GET',
            headers: headers,
            credentials: 'include'
        });
        
        
        if (!response.ok) {
            throw new Error(`网络响应错误: ${response.status} ${response.statusText}`);
        }
        
        const data = await response.json();
        
        if (data && data.code === 0) {
            renderAgentUpgradeTable(data.data.list, data.data);
            
            // 强制刷新页面内容
            setTimeout(() => {
                const tableContainer = document.getElementById('agentUpgradeTable');
                if (tableContainer) {
                    // 重新获取元素并更新
                    const parent = tableContainer.parentNode;
                    const clone = tableContainer.cloneNode(true);
                    parent.replaceChild(clone, tableContainer);
                }
            }, 100);
        } else {
            console.error('加载用户列表失败，返回数据:', data);
            showToast('加载用户列表失败: ' + (data ? data.message : '未知错误'), 'error');
        }
    } catch (err) {
        console.error('加载C端用户失败', err);
        showToast('加载用户列表失败', 'error');
    }
}

// 渲染团长升级用户列表
function renderAgentUpgradeTable(list, pagination) {
    
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>用户名</th>
                    <th>当前等级</th>
                    <th>注册时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    if (list.length === 0) {
        html += `
            <tr>
                <td colspan="5" style="text-align: center; padding: 40px;">
                    <i class="ri-search-line" style="font-size: 48px; color: #ccc;"></i>
                    <p style="margin-top: 16px; color: #888;">未找到符合条件的用户</p>
                </td>
            </tr>
        `;
    } else {
        list.forEach(u => {
            let levelText = '普通用户';
            let levelClass = 'badge-neutral';
            
            if (u.is_agent === 1) {
                levelText = '团长';
                levelClass = 'badge-success';
            } else if (u.is_agent === 2) {
                levelText = '高级团长';
                levelClass = 'badge-warning';
            } else if (u.is_agent === 3) {
                levelText = '大团团长';
                levelClass = 'badge-danger';
            }
            
            let actions = '';
            if (u.is_agent === 0) {
                actions = `
                    <button class="btn-success btn-small" onclick="upgradeToAgent(${u.id}, '${u.username}', 1)"><i class="ri-arrow-up-circle-line"></i> 升级成团长</button>
                    <button class="btn-warning btn-small" onclick="upgradeToAgent(${u.id}, '${u.username}', 2)"><i class="ri-arrow-up-circle-line"></i> 升级成高级团长</button>
                    <button class="btn-danger btn-small" onclick="upgradeToAgent(${u.id}, '${u.username}', 3)"><i class="ri-arrow-up-circle-line"></i> 升级成大团团长</button>
                `;
            } else if (u.is_agent === 1) {
                actions = `
                    <button class="btn-warning btn-small" onclick="upgradeToAgent(${u.id}, '${u.username}', 2)"><i class="ri-arrow-up-circle-line"></i> 升级成高级团长</button>
                    <button class="btn-danger btn-small" onclick="upgradeToAgent(${u.id}, '${u.username}', 3)"><i class="ri-arrow-up-circle-line"></i> 升级成大团团长</button>
                `;
            } else if (u.is_agent === 2) {
                actions = `
                    <button class="btn-danger btn-small" onclick="upgradeToAgent(${u.id}, '${u.username}', 3)"><i class="ri-arrow-up-circle-line"></i> 升级成大团团长</button>
                `;
            } else {
                actions = '<span class="text-gray">已是最高等级</span>';
            }
            
            html += `
                <tr>
                    <td>${u.id}</td>
                    <td><strong>${u.username}</strong></td>
                    <td><span class="badge ${levelClass}">${levelText}</span></td>
                    <td>${u.created_at}</td>
                    <td>${actions}</td>
                </tr>
            `;
        });
    }
    
    html += '</tbody></table></div>';
    
    // 添加分页
    if (pagination && pagination.total_pages > 1) {
        html += `
            <div class="pagination" style="margin-top: 20px; text-align: center;">
                <button class="btn-secondary btn-small" ${pagination.page > 1 ? '' : 'disabled'} onclick="loadCUsersForUpgrade(${pagination.page - 1})"><i class="ri-arrow-left-line"></i> 上一页</button>
                <span style="margin: 0 20px;">第 ${pagination.page} 页，共 ${pagination.total_pages} 页</span>
                <button class="btn-secondary btn-small" ${pagination.page < pagination.total_pages ? '' : 'disabled'} onclick="loadCUsersForUpgrade(${pagination.page + 1})"><i class="ri-arrow-right-line"></i> 下一页</button>
            </div>
        `;
    }
    
    
    const tableContainer = document.getElementById('agentUpgradeTable');
    
    if (tableContainer) {
        tableContainer.innerHTML = html;
    } else {
        console.error('未找到表格容器元素 agentUpgradeTable');
    }
}

// 升级用户为团长、高级团长或大团团长
function upgradeToAgent(userId, username, level) {
    let levelText = '团长';
    if (level === 2) {
        levelText = '高级团长';
    } else if (level === 3) {
        levelText = '大团团长';
    }
    
    showConfirm(`确认将用户 ${username} (ID: ${userId}) 升级为${levelText}吗？`, async () => {
        try {
            const token = sessionStorage.getItem('admin_token');
            const headers = {
                'Content-Type': 'application/json'
            };
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
            const response = await fetch('/task_admin/api/agent/upgrade-to-senior.php', {
                method: 'POST',
                headers: headers,
                credentials: 'include',
                body: JSON.stringify({ user_id: userId, level: level })
            });
            
            if (!response.ok) {
                throw new Error('网络响应错误');
            }
            
            const res = await response.json();
            
            if (res && res.code === 0) {
                showToast(res.message, 'success');
                loadCUsersForUpgrade();
            } else {
                showToast(res ? res.message : '升级失败', 'error');
            }
        } catch (err) {
            console.error('升级失败', err);
            showToast('升级失败，请检查网络连接', 'error');
        }
    });
}

// 重置团长升级搜索
function resetAgentUpgradeSearch() {
    document.getElementById('agentUpgradeUsername').value = '';
    document.getElementById('agentUpgradeUserId').value = '';
    loadCUsersForUpgrade();
}

// 初始化团长升级面板
function initAgentUpgradePanel() {
    
    // 页面切换时加载数据
    const agentUpgradeSection = document.getElementById('agentUpgradeSection');
    
    if (agentUpgradeSection) {
        agentUpgradeSection.addEventListener('click', (e) => {
            // 确保只有在点击面板本身或其内部元素时才加载数据
            if (e.target.closest('#agentUpgradeSection')) {
                // 确保内容区域可见
                if (!agentUpgradeSection.classList.contains('active')) {
                    agentUpgradeSection.classList.add('active');
                }
                // 加载数据
                loadCUsersForUpgrade();
            }
        });
    } else {
        console.error('未找到团长升级面板元素 agentUpgradeSection');
    }
}

// 当DOM加载完成时初始化
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAgentUpgradePanel);
} else {
    initAgentUpgradePanel();
}