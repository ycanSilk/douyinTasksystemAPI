

// ==================== 租赁订单处理 ====================

// 加载租赁订单列表
async function loadRentalOrders(page = 1) {
    const orderId = document.getElementById('rentalOrderId')?.value || '';
    const buyerId = document.getElementById('rentalBuyerId')?.value || '';
    const status = document.getElementById('rentalStatus')?.value || '';

    const params = new URLSearchParams({
        page,
        order_id: orderId,
        buyer_id: buyerId,
        status
    });

    try {
        const apiUrl = `/task_admin/api/rental_orders/list.php?${params}`;
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
            renderRentalOrdersTable(data.data.list, data.data.pagination);
        } else {
            showToast('加载租赁订单失败: ' + data.message, 'error');
        }
    } catch (err) {
        showToast('加载租赁订单失败: ' + err.message, 'error');
    }
}

// 智能解析 JSON 信息并格式化显示
function formatJsonInfo(jsonData, prefix = '') {
    if (!jsonData || typeof jsonData !== 'object') return '无';
    
    let result = [];
    for (let key in jsonData) {
        let value = jsonData[key];
        
        // 处理嵌套对象
        if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
            result.push(`<strong>${key}:</strong>`);
            result.push(formatJsonInfo(value, '  '));
        } 
        // 处理数组
        else if (Array.isArray(value)) {
            result.push(`<strong>${key}:</strong> ${value.join(', ')}`);
        }
        // 普通值
        else {
            result.push(`<strong>${key}:</strong> ${value || '无'}`);
        }
    }
    
    return result.join('<br>' + prefix);
}

function renderRentalOrdersTable(list, pagination) {
    let html = `
        <div class="table-container">
        <table style="font-size: 13px;">
            <thead>
                <tr>
                    <th style="width: 50px;">ID</th>
                    <th style="width: 120px;">买家信息</th>
                    <th style="width: 120px;">卖家信息</th>
                    <th style="width: 60px;">来源</th>
                    <th style="width: 80px;">金额</th>
                    <th style="width: 60px;">租期</th>
                    <th style="width: 80px;">状态</th>
                    <th style="min-width: 150px;">买家详情</th>
                    <th style="min-width: 150px;">卖家详情</th>
                    <th style="width: 140px;">时间</th>
                    <th style="width: 140px;">操作</th>
                </tr>
            </thead>
            <tbody>
    `;

    if (list.length === 0) {
        html += '<tr><td colspan="11" style="text-align: center; padding: 40px; color: #86868b;">暂无数据</td></tr>';
    } else {
        list.forEach(order => {
            const statusMap = {
                0: { text: '待支付', class: 'badge badge-neutral' },
                1: { text: '已支付/待客服', class: 'badge badge-warning' },
                2: { text: '进行中', class: 'badge badge-success' },
                3: { text: '已完成', class: 'badge badge-info' },
                4: { text: '已取消', class: 'badge badge-danger' }
            };
            const statusInfo = statusMap[order.status] || { text: '未知', class: 'badge' };
            const statusBadge = `<span class="${statusInfo.class}">${statusInfo.text}</span>`;
            
            const sourceType = order.source_type === 0 ? '出租' : '求租';
            // 兼容两种格式：'c'/'b' 和 '1'/'2'
            const userTypeText = (type) => {
                if (type === 'c' || type === '1' || type === 1) return 'C端';
                if (type === 'b' || type === '2' || type === 2) return 'B端';
                return '未知';
            };
            
            // 买家详情信息
            const buyerInfo = formatJsonInfo(order.buyer_info_json);
            
            // 卖家详情信息
            const sellerInfo = formatJsonInfo(order.seller_info_json);
            
            let actions = '-';
            if (order.status === 1) {
                // 待客服：开始、退款
                actions = `
                    <button class="btn-success btn-small" onclick="dispatchOrder(${order.id}, 'start')" style="margin: 2px;">开始</button>
                    <button class="btn-danger btn-small" onclick="dispatchOrder(${order.id}, 'refund')" style="margin: 2px;">退款</button>
                `;
            } else if (order.status === 2) {
                // 进行中：终止
                actions = `
                    <button class="btn-danger btn-small" onclick="dispatchOrder(${order.id}, 'terminate')" style="margin: 2px;">终止租赁不退款</button>
                    <button class="btn-danger btn-small" onclick="dispatchOrder(${order.id}, 'terminate_refund')" style="margin: 2px;">终止租赁并退款</button>
                `;
            }

            html += `
                <tr style="vertical-align: top;">
                    <td><strong>#${order.id}</strong></td>
                    <td>
                        ${order.buyer_username}<br>
                        <small style="color: #86868b;">ID: ${order.buyer_user_id}</small><br>
                        <small style="color: #86868b;">${userTypeText(order.buyer_user_type)}</small>
                    </td>
                    <td>
                        ${order.seller_username}<br>
                        <small style="color: #86868b;">ID: ${order.seller_user_id}</small><br>
                        <small style="color: #86868b;">${userTypeText(order.seller_user_type)}</small>
                    </td>
                    <td>${sourceType}</td>
                    <td>
                        <strong>¥${(order.total_amount / 100).toFixed(2)}</strong><br>
                        <small style="color: #86868b;">抽成: ¥${(order.platform_amount / 100).toFixed(2)}</small><br>
                        <small style="color: #86868b;">卖家得: ¥${(order.seller_amount / 100).toFixed(2)}</small>
                    </td>
                    <td>${order.days}天<br>${order.allow_renew ? '<small style="color: green;">可续租</small>' : '<small style="color: #999;">不可续租</small>'}</td>
                    <td>${statusBadge}</td>
                    <td style="font-size: 11px; line-height: 1.5; max-width: 200px; word-break: break-word;">
                        ${buyerInfo}
                    </td>
                    <td style="font-size: 11px; line-height: 1.5; max-width: 200px; word-break: break-word;">
                        ${sellerInfo}
                    </td>
                    <td style="font-size: 11px; line-height: 1.5;">
                        创建: ${order.created_at}<br>
                        ${order.order_json?.start_time ? '开始: ' + new Date(order.order_json.start_time * 1000).toLocaleString('zh-CN', {hour12: false}).replace(/\//g, '-') + '<br>' : ''}
                        ${order.order_json?.end_time ? '结束: ' + new Date(order.order_json.end_time * 1000).toLocaleString('zh-CN', {hour12: false}).replace(/\//g, '-') : ''}
                    </td>
                    <td>${actions}</td>
                </tr>
            `;
        });
    }

    html += `</tbody></table></div>
    <div class="pagination">
        ${pagination.page > 1 ? `<button onclick="loadRentalOrders(${pagination.page - 1})">上一页</button>` : '<button disabled>上一页</button>'}
        <span style="font-size: 13px; color: var(--text-secondary);">第 ${pagination.page} / ${pagination.total_pages} 页</span>
        ${pagination.page < pagination.total_pages ? `<button onclick="loadRentalOrders(${pagination.page + 1})">下一页</button>` : '<button disabled>下一页</button>'}
    </div>`;

    document.getElementById('rentalOrdersTable').innerHTML = html;
}

// 调度订单
function dispatchOrder(orderId, action) {
    let confirmMsg = '';
    if (action === 'start') {
        confirmMsg = '确认开始此订单吗？订单将进入进行中状态并开始计时。';
    } else if (action === 'refund') {
        confirmMsg = '确认全额退款吗？订单将取消，金额将退回买家钱包。';
    } else if (action === 'terminate') {
        confirmMsg = '确认强行终止此订单吗？订单将立即结束，不退还金额。';
    } else if (action === 'terminate_refund') {
        confirmMsg = '确认终止此订单并退款吗？系统将计算剩余天数并原路退款。';
    }

    showConfirm(confirmMsg, async () => {
        try {
            const apiUrl = `/task_admin/api/rental_orders/dispatch.php`;
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
                body: JSON.stringify({ order_id: orderId, action }),
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
                loadRentalOrders();
            } else {
                showToast(result.message, 'error');
            }
        } catch (err) {
            showToast('操作失败: ' + err.message, 'error');
        }
    });
}