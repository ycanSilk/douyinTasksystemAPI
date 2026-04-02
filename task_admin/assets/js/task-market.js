
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

// ========== 快捷发布任务模态框 ==========

// 显示发布任务模态框
function showQuickTaskModal() {
    console.log('=== 点击发布刷单任务按钮 ===');
    
    const modal = document.getElementById('modal');
    const modalBody = document.getElementById('modalBody');
    
    console.log('modal 元素:', modal);
    console.log('modalBody 元素:', modalBody);
    
    if (!modal || !modalBody) {
        console.error('模态框元素不存在!');
        alert('模态框元素不存在，请检查 HTML 结构');
        return;
    }
    
    modalBody.innerHTML = `
        <div style="padding: 20px; width: 90%; max-width: none;" onclick="event.stopPropagation();">
            <h2 style="margin: 0 0 20px 0; font-size: 20px; font-weight: 600; color: #1d1d1f;">发布刷单任务</h2>
            <div class="space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">视频链接 <span class="text-red-500">*</span></label>
                    <input type="text" id="quickTaskVideoUrl" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" placeholder="请输入视频链接" required>
                </div>
                
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">评论内容 <span class="text-red-500">*</span></label>
                    <textarea id="quickTaskComment" rows="3" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" placeholder="请输入评论内容" required></textarea>
                </div>
                
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">单价</label>
                    <input type="text" value="3.00" disabled class="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-100 text-gray-500 cursor-not-allowed">
                </div>
                
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">发布次数 <span class="text-red-500">*</span></label>
                    <input type="number" id="quickTaskReleases" min="1" max="999" value="1" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" oninput="calculateTotalPrice()" required>
                </div>
                
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">总价格</label>
                    <input type="text" id="quickTaskTotalPrice" value="3.00" disabled class="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-100 text-gray-500 cursor-not-allowed">
                </div>
            </div>
            
            <div class="flex justify-end space-x-3 mt-6">
                <button onclick="closeQuickTaskModal()" class="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500">取消</button>
                <button onclick="submitQuickTask()" class="px-4 py-2 bg-blue-600 text-white rounded-md text-sm font-medium hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500">发布任务</button>
            </div>
        </div>
    `;
    
    // 移除 modal 的 onclick 事件，防止点击外部关闭
    modal.onclick = null;
    
    // 为关闭按钮添加事件监听
    const closeBtn = modal.querySelector('.close');
    if (closeBtn) {
        closeBtn.onclick = function() {
            closeQuickTaskModal();
        };
    }
    
    console.log('模态框内容已设置');
    console.log('添加 active 类之前 modal 的 classList:', modal.classList);
    modal.classList.add('active');
    console.log('添加 active 类之后 modal 的 classList:', modal.classList);
    console.log('=== 模态框显示完成 ===');
}

// 关闭发布任务模态框
function closeQuickTaskModal() {
    console.log('=== 关闭模态框 ===');
    const modal = document.getElementById('modal');
    console.log('modal 元素:', modal);
    if (modal) {
        console.log('关闭前 classList:', modal.classList);
        modal.classList.remove('active');
        console.log('关闭后 classList:', modal.classList);
    }
}

// 计算总价格
function calculateTotalPrice() {
    const releases = parseInt(document.getElementById('quickTaskReleases').value) || 0;
    const unitPrice = 3.00;
    const totalPrice = (unitPrice * releases).toFixed(2);
    document.getElementById('quickTaskTotalPrice').value = totalPrice;
}

// 提交快捷任务
async function submitQuickTask() {
    console.log('=== 开始提交快捷任务 ===');
    
    const videoUrl = document.getElementById('quickTaskVideoUrl').value.trim();
    const comment = document.getElementById('quickTaskComment').value.trim();
    const releases = parseInt(document.getElementById('quickTaskReleases').value);
    
    console.log('表单数据:', {
        videoUrl,
        comment,
        releases
    });
    
    if (!videoUrl) {
        console.error('视频链接为空');
        alert('请输入视频链接');
        return;
    }
    
    if (!comment) {
        console.error('评论内容为空');
        alert('请输入评论内容');
        return;
    }
    
    if (!releases || releases < 1 || releases > 999) {
        console.error('发布次数无效:', releases);
        alert('发布次数必须在 1-999 之间');
        return;
    }
    
    const token = sessionStorage.getItem('admin_token');
    console.log('token:', token ? '存在' : '不存在');
    
    if (!token) {
        console.error('未登录');
        alert('未登录，请重新登录');
        return;
    }
    
    const requestData = {
        template_id: 1,
        video_url: videoUrl,
        releases_number: releases,
        comment: comment
    };
    
    console.log('请求数据:', requestData);
    
    try {
        console.log('开始发送请求...');
        const response = await fetch('/task_admin/api/quick_task/create.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify(requestData)
        });
        
        console.log('响应状态:', response.status);
        
        // 先获取原始文本，检查是否为 JSON
        const responseText = await response.text();
        console.log('原始响应:', responseText);
        
        // 尝试解析 JSON
        let data;
        try {
            data = JSON.parse(responseText);
        } catch (parseError) {
            console.error('JSON 解析失败:', parseError);
            console.error('响应内容不是有效的 JSON:', responseText.substring(0, 500));
            alert('服务器返回错误：' + responseText.substring(0, 200));
            return;
        }
        
        console.log('响应数据:', data);
        
        if (data.code === 0) {
            console.log('发布任务成功!');
            alert('发布任务成功！');
            closeQuickTaskModal();
            loadMarketTasks(1);
        } else {
            console.error('发布任务失败:', data.message);
            alert(data.message || '发布任务失败');
        }
    } catch (err) {
        console.error('发布任务错误', err);
        alert('网络错误，请稍后重试');
    }
}