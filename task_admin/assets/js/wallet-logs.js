

// ========== 钱包记录管理 ==========

// 加载钱包记录列表
async function loadWalletLogs(page = 1) {
    const logId = document.getElementById('walletLogId').value;
    const username = document.getElementById('walletUsername').value;
    const userType = document.getElementById('walletUserType').value;
    const type = document.getElementById('walletType').value;
    const relatedType = document.getElementById('walletRelatedType').value;
    const startDate = document.getElementById('walletStartDate').value;
    const endDate = document.getElementById('walletEndDate').value;
    const minAmount = document.getElementById('walletMinAmount').value;
    const maxAmount = document.getElementById('walletMaxAmount').value;
    
    const params = new URLSearchParams({
        page,
        log_id: logId,
        username,
        user_type: userType,
        type,
        related_type: relatedType,
        start_date: startDate,
        end_date: endDate,
        min_amount: minAmount,
        max_amount: maxAmount
    });
    
    try {
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        const response = await fetch(`/task_admin/api/wallet_logs/list.php?${params}`, {
            method: 'GET',
            headers: headers,
            credentials: 'include'
        });
        
        if (!response.ok) {
            throw new Error('网络响应错误');
        }
        
        const data = await response.json();
        
        if (data && data.code === 0) {
            renderWalletLogsTable(data.data.list, data.data.pagination);
        } else {
            showToast('加载钱包记录失败: ' + (data ? data.message : '未知错误'), 'error');
        }
    } catch (err) {
        console.error('加载钱包记录失败', err);
        showToast('加载钱包记录失败', 'error');
    }
}

function renderWalletLogsTable(list, pagination) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>流水ID</th>
                    <th>钱包ID</th>
                    <th>用户ID</th>
                    <th>用户名</th>
                    <th>用户端</th>
                    <th>类型</th>
                    <th>变动金额</th>
                    <th>变动前余额</th>
                    <th>变动后余额</th>
                    <th>关联类型</th>
                    <th>关联ID</th>
                    <th>备注</th>
                    <th>创建时间</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    list.forEach(log => {
        const typeBadge = log.type === 1 ? '<span class="badge badge-success">收入</span>' : '<span class="badge badge-danger">支出</span>';
        
        html += `
            <tr>
                <td>${log.id}</td>
                <td>${log.wallet_id}</td>
                <td>${log.user_id}</td>
                <td><strong>${log.username}</strong></td>
                <td>${log.user_type_text}</td>
                <td>${typeBadge}</td>
                <td style="color: ${log.type === 1 ? 'var(--success-color)' : 'var(--danger-color)'}; font-weight: 600;">¥${log.amount}</td>
                <td>¥${log.before_balance}</td>
                <td>¥${log.after_balance}</td>
                <td><span class="badge badge-info">${log.related_type_text}</span></td>
                <td>${log.related_id || '-'}</td>
                <td style="max-width: 300px; overflow: hidden; text-overflow: ellipsis;">${log.remark}</td>
                <td>${log.created_at}</td>
            </tr>
        `;
    });
    
    html += `</tbody></table></div>
    <div class="pagination">
        ${pagination.page > 1 ? `<button onclick="loadWalletLogs(${pagination.page - 1})">上一页</button>` : '<button disabled>上一页</button>'}
        <span style="font-size: 13px; color: var(--text-secondary);">第 ${pagination.page} / ${pagination.total_pages} 页</span>
        ${pagination.page < pagination.total_pages ? `<button onclick="loadWalletLogs(${pagination.page + 1})">下一页</button>` : '<button disabled>下一页</button>'}
    </div>`;
    
    document.getElementById('walletLogsTable').innerHTML = html;
}