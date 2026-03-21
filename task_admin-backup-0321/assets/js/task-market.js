
// ========== 任务市场管理 ==========

// 加载任务市场列表
async function loadMarketTasks(page = 1) {
    const bUserId = document.getElementById('marketBUserId')?.value || '';
    const stage = document.getElementById('marketStage')?.value || '';
    const status = document.getElementById('marketStatus')?.value || '';
    
    const params = new URLSearchParams({
        page,
        b_user_id: bUserId,
        stage,
        status
    });
    
    try {
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const response = await fetch(`/task_admin/api/market/list.php?${params}`, {
            method: 'GET',
            headers: headers,
            credentials: 'include'
        });
        
        if (!response.ok) {
            throw new Error('网络响应错误');
        }
        
        const data = await response.json();
        
        if (data && data.code === 0) {
            renderMarketTasksTable(data.data.list, data.data.pagination);
        }
    } catch (err) {
        console.error('加载任务市场失败', err);
    }
}

function renderMarketTasksTable(list, pagination) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>任务ID</th>
                    <th>B端用户</th>
                    <th>模板名称</th>
                    <th>模板类型</th>
                    <th>阶段</th>
                    <th>阶段状态</th>
                    <th>视频链接</th>
                    <th>总数量</th>
                    <th>已完成</th>
                    <th>进行中</th>
                    <th>待审核</th>
                    <th>剩余</th>
                    <th>单价</th>
                    <th>总价</th>
                    <th>状态</th>
                    <th>截止时间</th>
                    <th>创建时间</th>
                    <th>完成时间</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    if (list.length === 0) {
        html += '<tr><td colspan="18" style="text-align: center; padding: 40px; color: #86868b;">暂无数据</td></tr>';
    } else {
        list.forEach(task => {
            const statusBadge = {
                0: '<span class="badge badge-danger">已过期</span>',
                1: '<span class="badge badge-success">进行中</span>',
                2: '<span class="badge badge-info">已完成</span>',
                3: '<span class="badge badge-neutral">已取消</span>'
            }[task.status] || '<span class="badge">未知</span>';
            
            const stageStatusBadge = {
                0: '<span class="badge badge-neutral">未开放</span>',
                1: '<span class="badge badge-success">已开放</span>',
                2: '<span class="badge badge-info">已完成</span>'
            }[task.stage_status] || '<span class="badge">未知</span>';
            
            const deadlineDate = new Date(task.deadline * 1000).toLocaleString('zh-CN');
            
            html += `
                <tr>
                    <td>${task.id}</td>
                    <td>${task.b_username} (${task.b_user_id})</td>
                    <td>${task.template_title}</td>
                    <td>${task.template_type === 0 ? '单任务' : '组合任务'}</td>
                    <td>${task.stage_text}</td>
                    <td>${stageStatusBadge}</td>
                    <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis;">${task.video_url || '-'}</td>
                    <td>${task.task_count}</td>
                    <td>${task.task_done}</td>
                    <td>${task.task_doing}</td>
                    <td>${task.task_reviewing}</td>
                    <td><strong>${task.remaining}</strong></td>
                    <td>¥${task.unit_price}</td>
                    <td>¥${task.total_price}</td>
                    <td>${statusBadge}</td>
                    <td>${deadlineDate}</td>
                    <td>${task.created_at}</td>
                    <td>${task.completed_at || '-'}</td>
                </tr>
            `;
        });
    }
    
    html += `</tbody></table></div>
    <div class="pagination">
        ${pagination.page > 1 ? `<button onclick="loadMarketTasks(${pagination.page - 1})">上一页</button>` : '<button disabled>上一页</button>'}
        <span style="font-size: 13px; color: var(--text-secondary);">第 ${pagination.page} / ${pagination.total_pages} 页</span>
        ${pagination.page < pagination.total_pages ? `<button onclick="loadMarketTasks(${pagination.page + 1})">下一页</button>` : '<button disabled>下一页</button>'}
    </div>`;
    
    document.getElementById('marketTable').innerHTML = html;
}