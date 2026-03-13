// 加载充值列表
async function loadRechargeList(page = 1) {
    const status = document.getElementById('rechargeStatus').value;
    try {
        const apiUrl = `/task_admin/api/recharge/list.php?page=${page}&status=${status}`;
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
            renderRechargeTable(data.data.list);
        }
    } catch (err) {
        console.error('加载充值列表失败', err);
    }
}

function renderRechargeTable(list) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>用户</th>
                    <th>金额</th>
                    <th>支付方式</th>
                    <th>支付凭证</th>
                    <th>状态</th>
                    <th>申请时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    list.forEach(r => {
        let statusBadge = '';
        if (r.status === 0) statusBadge = '<span class="badge badge-warning">待审核</span>';
        else if (r.status === 1) statusBadge = '<span class="badge badge-success">已通过</span>';
        else statusBadge = '<span class="badge badge-danger">已拒绝</span>';
        
        const actions = r.status === 0 ? `
            <button class="btn-success btn-small" onclick="reviewRecharge(${r.id}, 'approve')"><i class="ri-check-line"></i> 通过</button>
            <button class="btn-danger btn-small" onclick="reviewRecharge(${r.id}, 'reject')"><i class="ri-close-line"></i> 拒绝</button>
        ` : '-';
        
        html += `
            <tr>
                <td>${r.id}</td>
                <td><strong>${r.username}</strong></td>
                <td>¥${(r.amount/100).toFixed(2)}</td>
                <td>${r.payment_method}</td>
                <td><a href="${r.payment_voucher}" target="_blank" class="text-primary"><i class="ri-image-line"></i> 查看</a></td>
                <td>${statusBadge}</td>
                <td>${r.created_at}</td>
                <td>${actions}</td>
            </tr>
        `;
    });
    
    html += '</tbody></table></div>';
    document.getElementById('rechargeTable').innerHTML = html;
}

// 审核充值
function reviewRecharge(id, action) {
    if (action === 'approve') {
        showConfirm('确认通过该充值申请吗？', async () => {
            try {
                const apiUrl = `/task_admin/api/recharge/review.php`;
                const token = sessionStorage.getItem('admin_token');
                const headers = {
                    'Content-Type': 'application/json'
                };
                
                if (token) {
                    headers['Authorization'] = `Bearer ${token}`;
                }
                
                const response = await fetch(apiUrl, {
                    method: 'POST',
                    headers: headers,
                    body: JSON.stringify({ id, action: 'approve' }),
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
                
                const result = await response.json();
                
                if (result && result.code === 0) {
                    showToast(result.message, 'success');
                    loadRechargeList();
                } else {
                    showToast(result.message, 'error');
                }
            } catch (err) {
                showToast('审核失败', 'error');
            }
        });
    } else {
        showRejectModal('充值', async (reason) => {
            try {
                const apiUrl = `/task_admin/api/recharge/review.php`;
                const token = sessionStorage.getItem('admin_token');
                const headers = {
                    'Content-Type': 'application/json'
                };
                
                if (token) {
                    headers['Authorization'] = `Bearer ${token}`;
                }
                
                const response = await fetch(apiUrl, {
                    method: 'POST',
                    headers: headers,
                    body: JSON.stringify({ id, action: 'reject', reject_reason: reason }),
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
                
                const result = await response.json();
                
                if (result && result.code === 0) {
                    showToast(result.message, 'success');
                    loadRechargeList();
                } else {
                    showToast(result.message, 'error');
                }
            } catch (err) {
                showToast('审核失败', 'error');
            }
        });
    }
}