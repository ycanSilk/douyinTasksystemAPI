
// ========== 放大镜任务管理 ==========

// 加载放大镜任务列表
async function loadMagnifierTasks(page = 1) {
    
    const status = document.getElementById('magnifierStatus')?.value || '';
    
    try {
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const params = new URLSearchParams({ page, pageSize: 10 });
        if (status) {
            params.append('status', status);
        }
        
        const url = `/task_admin/api/magnifier/list.php?${params}`;
        
        const response = await fetch(url, {
            method: 'GET',
            headers: headers,
            credentials: 'include'
        });
        
        if (!response.ok) {
            throw new Error('网络响应错误');
        }
        
        const data = await response.json();
        
        if (data && data.code === 0) {
            renderMagnifierTasksTable(data.data.list, data.data);
        } else {
            console.error('加载放大镜任务失败:', data ? data.message : '未知错误');
            showToast('加载放大镜任务失败: ' + (data ? data.message : '未知错误'), 'error');
        }
    } catch (err) {
        console.error('加载放大镜任务失败:', err);
        showToast('加载放大镜任务失败', 'error');
    }
}

// 渲染放大镜任务表格
function renderMagnifierTasksTable(list, pagination) {    
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>任务ID</th>
                    <th>任务标题</th>
                    <th>单价</th>
                    <th>总数量</th>
                    <th>总价</th>
                    <th>已完成</th>
                    <th>进行中</th>
                    <th>待审核</th>
                    <th>状态</th>
                    <th>查看状态</th>
                    <th>视频链接</th>
                    <th>蓝词搜索词</th>
                    <th>@用户</th>
                    <th>图片</th>
                    <th>创建时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    if (list.length === 0) {
        html += '<tr><td colspan="15" style="text-align: center; padding: 40px; color: #86868b;">暂无数据</td></tr>';
    } else {
        list.forEach(task => {
            const statusBadge = task.status === 0 ? '<span class="badge badge-neutral">待发布</span>' :
                               task.status === 1 ? '<span class="badge badge-success">发布中</span>' :
                               task.status === 2 ? '<span class="badge badge-info">已完成</span>' :
                               task.status === 3 ? '<span class="badge badge-danger">已取消</span>' :
                               '<span class="badge">未知</span>';
            
            // 处理 recommend_marks
            let recommendMarks = [];
            if (task.recommend_marks) {
                if (typeof task.recommend_marks === 'string') {
                    try {
                        recommendMarks = JSON.parse(task.recommend_marks);
                        if (!Array.isArray(recommendMarks)) {
                            recommendMarks = [recommendMarks];
                        }
                    } catch (e) {
                        console.error('解析 recommend_marks 失败:', e);
                    }
                } else if (Array.isArray(task.recommend_marks)) {
                    recommendMarks = task.recommend_marks;
                } else if (typeof task.recommend_marks === 'object') {
                    recommendMarks = [task.recommend_marks];
                }
            }
            
            // 获取第一个推荐标记
            const firstMark = recommendMarks[0] || {};
            const comment = firstMark.comment || '-';
            const atUser = firstMark.at_user || '-';
            const imageUrl = firstMark.image_url || '';
            
            // 视频链接按钮
            const videoButton = task.video_url ? 
                `<button class="btn-info btn-small" onclick="copyLink('${task.video_url.replace(/`/g, '').replace(/'/g, "\\'")}')"><i class="ri-link"></i> 复制链接</button>` : 
                '-';
            
            // 图片显示
            const imageDisplay = imageUrl ? 
                `<img src="${imageUrl}" style="max-width: 60px; max-height: 60px; border-radius: 4px;" alt="图片">` : 
                '-';
            
            // 计算总价
            const totalPrice = task.total_price || (task.price * task.task_count);
            
            // 查看状态
            const viewStatusBadge = task.view_status === 1 ? '<span class="badge badge-success">已查看</span>' : '<span class="badge badge-warning">未查看</span>';
            
            html += `
                <tr>
                    <td>${task.id}</td>
                    <td><strong>${task.title}</strong></td>
                    <td>¥${task.price}</td>
                    <td>${task.task_count}</td>
                    <td>¥${totalPrice}</td>
                    <td>${task.task_done}</td>
                    <td>${task.task_doing}</td>
                    <td>${task.task_reviewing}</td>
                    <td>${statusBadge}</td>
                    <td>${viewStatusBadge}</td>
                    <td>${videoButton}</td>
                    <td>${comment}</td>
                    <td>${atUser}</td>
                    <td>${imageDisplay}</td>
                    <td>${task.created_at}</td>
                    <td>
                        <button class="btn-info btn-small" onclick="viewMagnifierTaskDetail(${task.id})"><i class="ri-eye-line"></i> 详情</button>
                        ${task.view_status === 0 ? `
                            <button class="btn-info btn-small" onclick="markMagnifierTaskAsViewed(${task.id})"><i class="ri-check-line"></i> 标记已查看</button>
                        ` : ''}
                    </td>
                </tr>
            `;
        });
    }
    
    html += '</tbody></table></div>';
    
    // 添加分页
    if (pagination) {
        html += `
            <div class="pagination" style="margin-top: 20px; text-align: center;">
                <button class="btn-secondary btn-small" ${pagination.page <= 1 ? 'disabled' : ''} onclick="loadMagnifierTasks(${pagination.page - 1})">上一页</button>
                <span style="margin: 0 10px;">第 ${pagination.page} / ${Math.ceil(pagination.total / pagination.pageSize)} 页</span>
                <button class="btn-secondary btn-small" ${pagination.page >= Math.ceil(pagination.total / pagination.pageSize) ? 'disabled' : ''} onclick="loadMagnifierTasks(${pagination.page + 1})">下一页</button>
            </div>
        `;
    }
    
    const tableContainer = document.getElementById('magnifierTable');
    if (tableContainer) {
        tableContainer.innerHTML = html;
    } else {
        console.error('未找到放大镜任务表格容器');
    }
}

// 标记放大镜任务为已查看
async function markMagnifierTaskAsViewed(taskId) {
    try {
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const response = await fetch('/task_admin/api/magnifier/mark-viewed.php', {
            method: 'POST',
            headers: headers,
            credentials: 'include',
            body: JSON.stringify({ task_id: taskId })
        });
        
        if (!response.ok) {
            throw new Error('网络响应错误');
        }
        
        const data = await response.json();
        
        if (data && data.code === 0) {
            showToast('标记成功', 'success');
            loadMagnifierTasks();
        } else {
            showToast(data ? data.message : '标记失败', 'error');
        }
    } catch (error) {
        console.error('标记放大镜任务已查看失败:', error);
        showToast('标记失败', 'error');
    }
}

// 查看放大镜任务详情
async function viewMagnifierTaskDetail(taskId) {
    
    try {
        // 先标记任务为已查看
        await markMagnifierTaskAsViewed(taskId);
        
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const response = await fetch(`/task_admin/api/magnifier/detail.php?id=${taskId}`, {
            method: 'GET',
            headers: headers,
            credentials: 'include'
        });
        
        if (!response.ok) {
            throw new Error('网络响应错误');
        }
        
        const data = await response.json();
        
        if (data && data.code === 0) {
            showMagnifierTaskDetailModal(data.data);
        } else {
            showToast('获取详情失败: ' + (data ? data.message : '未知错误'), 'error');
        }
    } catch (err) {
        console.error('获取详情失败:', err);
        showToast('获取详情失败', 'error');
    }
}

// 复制链接到剪贴板
function copyLink(link) {
    navigator.clipboard.writeText(link)
        .then(() => {
            showToast('链接已复制到剪贴板', 'success');
        })
        .catch(err => {
            console.error('复制链接失败:', err);
            showToast('复制失败，请手动复制', 'error');
        });
}

// 显示放大镜任务详情模态框
function showMagnifierTaskDetailModal(data) {
    const task = data.task;
    const records = data.records || [];
    
    // 处理 recommend_marks
    let recommendMarks = [];
    if (task.recommend_marks) {
        if (typeof task.recommend_marks === 'string') {
            try {
                recommendMarks = JSON.parse(task.recommend_marks);
                if (!Array.isArray(recommendMarks)) {
                    recommendMarks = [recommendMarks];
                }
            } catch (e) {
                console.error('解析 recommend_marks 失败:', e);
            }
        } else if (Array.isArray(task.recommend_marks)) {
            recommendMarks = task.recommend_marks;
        } else if (typeof task.recommend_marks === 'object') {
            recommendMarks = [task.recommend_marks];
        }
    }
    
    const modalBody = document.getElementById('modalBody');
    let html = `
        <div class="ticket-chat-container">
            <div class="ticket-header">
                <h3><i class="ri-eye-line" style="margin-right: 12px; color: var(--primary-color);"></i> 放大镜任务详情 #${task.id}</h3>
                <div class="stats-grid" style="grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; margin-top: 16px;">
                    <div class="stat-card">
                        <h3 style="margin-bottom: 12px;"><i class="ri-task-line"></i> 任务状态</h3>
                        <div class="stat-item">
                            <span class="stat-label">状态</span>
                            <span class="stat-value">${task.status_text}</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-label">单价</span>
                            <span class="stat-value">¥${task.price}</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-label">总价</span>
                            <span class="stat-value">¥${task.total_price || (task.price * task.task_count)}</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <h3 style="margin-bottom: 12px;"><i class="ri-bar-chart-2-line"></i> 任务进度</h3>
                        <div class="stat-item">
                            <span class="stat-label">总数量</span>
                            <span class="stat-value">${task.task_count}</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-label">已完成</span>
                            <span class="stat-value">${task.task_done}</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-label">进行中</span>
                            <span class="stat-value">${task.task_doing}</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-label">待审核</span>
                            <span class="stat-value">${task.task_reviewing}</span>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="chat-messages" style="padding: 32px;">
                <div class="card" style="margin-bottom: 24px;">
                    <div class="card-header" style="margin-bottom: 16px;">
                        <div class="card-title">任务详情</div>
                    </div>
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 16px;">
                        <div class="form-group">
                            <label>任务标题</label>
                            <div style="background: var(--bg-body); border: 1px solid var(--border-color); border-radius: var(--radius-sm); padding: 12px; font-weight: 500;">
                                ${task.title}
                            </div>
                        </div>
                        <div class="form-group">
                            <label>视频链接</label>
                            <div>
                                ${task.video_url ? 
                                    `<a href="${task.video_url.replace(/`/g, '')}" target="_blank" class="text-primary" style="display: inline-flex; align-items: center; gap: 6px;"><i class="ri-play-circle-line"></i> 查看视频</a>` : 
                                    '<span style="color: var(--text-secondary);">无</span>'
                                }
                            </div>
                        </div>
                        <div class="form-group">
                            <label>创建时间</label>
                            <div style="background: var(--bg-body); border: 1px solid var(--border-color); border-radius: var(--radius-sm); padding: 12px;">
                                ${task.created_at}
                            </div>
                        </div>
                        <div class="form-group">
                            <label>更新时间</label>
                            <div style="background: var(--bg-body); border: 1px solid var(--border-color); border-radius: var(--radius-sm); padding: 12px;">
                                ${task.updated_at}
                            </div>
                        </div>
                    </div>
                </div>
                
                ${recommendMarks.length > 0 ? `
                    <div class="card" style="margin-bottom: 24px;">
                        <div class="card-header" style="margin-bottom: 16px;">
                            <div class="card-title">推荐标记</div>
                        </div>
                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 16px;">
                            ${recommendMarks.map((mark, index) => `
                                <div style="border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 20px; background: var(--bg-body);">
                                    <div style="font-weight: 600; margin-bottom: 12px; color: var(--text-primary); display: flex; align-items: center; gap: 8px;">
                                        <i class="ri-tag-line" style="color: var(--primary-color);"></i>
                                        标记 ${index + 1}
                                    </div>
                                    <div style="space-y: 8px;">
                                        <div style="margin-bottom: 8px;">
                                            <span style="color: var(--text-secondary); font-size: 13px;">@用户:</span>
                                            <span style="margin-left: 8px; font-weight: 500;">${mark.at_user || '-'}</span>
                                        </div>
                                        <div style="margin-bottom: 8px;">
                                            <span style="color: var(--text-secondary); font-size: 13px;">蓝词搜索:</span>
                                            <span style="margin-left: 8px; font-weight: 500;">${mark.comment || '-'}</span>
                                        </div>
                                        <div style="margin-bottom: 8px;">
                                            <span style="color: var(--text-secondary); font-size: 13px;">图片:</span>
                                            <div style="margin-left: 8px; margin-top: 8px;">
                                                ${mark.image_url ? 
                                                    `<img src="${mark.image_url}" style="max-width: 100%; max-height: 200px; border-radius: var(--radius-sm); object-fit: cover;" alt="图片">` : 
                                                    '<span style="color: var(--text-secondary);">无</span>'
                                                }
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            `).join('')}
                        </div>
                    </div>
                ` : ''}
                
                ${records.length > 0 ? `
                    <div class="card">
                        <div class="card-header" style="margin-bottom: 16px;">
                            <div class="card-title">任务记录</div>
                        </div>
                        <div class="table-container">
                            <table>
                                <thead>
                                    <tr>
                                        <th>记录ID</th>
                                        <th>C端用户</th>
                                        <th>状态</th>
                                        <th>创建时间</th>
                                        <th>审核时间</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    ${records.map(record => `
                                        <tr>
                                            <td>${record.id}</td>
                                            <td>${record.c_username}</td>
                                            <td>${record.status_text}</td>
                                            <td>${record.created_at}</td>
                                            <td>${record.reviewed_at || '-'}</td>
                                        </tr>
                                    `).join('')}
                                </tbody>
                            </table>
                        </div>
                    </div>
                ` : ''}
            </div>
            
            <div class="chat-input-area">
                <div class="form-actions" style="margin: 0;">
                    <button class="btn-primary" onclick="closeModal()" style="flex: 1; justify-content: center;">
                        <i class="ri-close-line"></i> 关闭
                    </button>
                </div>
            </div>
        </div>
    `;
    
    modalBody.innerHTML = html;
    document.getElementById('modal').classList.add('active', 'fullscreen');
}