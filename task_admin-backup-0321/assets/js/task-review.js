

// ========== 任务审核管理 ==========

// 加载待审核任务列表
async function loadTaskReviewList(page = 1) {
    const bTaskId = document.getElementById('taskReviewBTaskId').value;
    const cUserId = document.getElementById('taskReviewCUserId').value;
    
    try {
        // 构建查询参数
        let params = `page=${page}`;
        if (bTaskId) params += `&b_task_id=${bTaskId}`;
        if (cUserId) params += `&c_user_id=${cUserId}`;
        
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const response = await fetch(`/task_admin/api/tasks/pending.php?${params}`, {
            method: 'GET',
            headers: headers,
            credentials: 'include'
        });
        
        if (!response.ok) {
            throw new Error('网络响应错误');
        }
        
        const data = await response.json();
        
        if (data && data.code === 0) {
            renderTaskReviewTable(data.data.list, data.data.pagination);
        } else {
            showToast('加载待审核任务失败: ' + (data ? data.message : '未知错误'), 'error');
        }
    } catch (err) {
        console.error('加载待审核任务失败', err);
        showToast('加载待审核任务失败', 'error');
    }
}

function renderTaskReviewTable(list, pagination) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>记录ID</th>
                    <th>任务ID</th>
                    <th>C端用户</th>
                    <th>C端用户ID</th>
                    <th>B端用户</th>
                    <th>B端用户ID</th>
                    <th>模板标题</th>
                    <th>视频链接</th>
                    <th>评论链接</th>
                    <th>截图</th>
                    <th>奖励金额</th>
                    <th>提交时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    if (list.length === 0) {
        html += '<tr><td colspan="13" style="text-align: center; padding: 40px; color: #86868b;">暂无待审核任务</td></tr>';
    } else {
        list.forEach(item => {
            const screenshots = item.screenshots && item.screenshots.length > 0 ? 
                `<a href="javascript:void(0)" onclick="showScreenshots(${JSON.stringify(item.screenshots)})" class="text-primary"><i class="ri-image-line"></i> 查看(${item.screenshots.length})</a>` : '-';
            
            html += `
                <tr>
                    <td>${item.record_id}</td>
                    <td>${item.b_task_id}</td>
                    <td><strong>${item.c_username}</strong></td>
                    <td>${item.c_user_id || '-'}</td>
                    <td>${item.b_username || '-'}</td>
                    <td>${item.b_user_id || '-'}</td>
                    <td>${item.template_title}</td>
                    <td>${item.video_url ? `<a href="${item.video_url}" target="_blank" class="text-primary"><i class="ri-play-circle-line"></i> 查看</a>` : '-'}</td>
                    <td>${item.comment_url ? `<a href="${item.comment_url}" target="_blank" class="text-primary"><i class="ri-link"></i> 查看</a>` : '-'}</td>
                    <td>${screenshots}</td>
                    <td>¥${item.reward_amount}</td>
                    <td>${item.submitted_at}</td>
                    <td>
                        <button class="btn-success btn-small" onclick="reviewTask(${item.record_id}, ${item.b_task_id}, 'approve')"><i class="ri-check-line"></i> 通过</button>
                        <button class="btn-danger btn-small" onclick="reviewTask(${item.record_id}, ${item.b_task_id}, 'reject')"><i class="ri-close-line"></i> 驳回</button>
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
                <button class="btn-secondary btn-small" ${pagination.page <= 1 ? 'disabled' : ''} onclick="loadTaskReviewList(${pagination.page - 1})">上一页</button>
                <span style="margin: 0 10px;">第 ${pagination.page} / ${pagination.total_pages} 页</span>
                <button class="btn-secondary btn-small" ${pagination.page >= pagination.total_pages ? 'disabled' : ''} onclick="loadTaskReviewList(${pagination.page + 1})">下一页</button>
            </div>
        `;
    }
    
    document.getElementById('taskReviewTable').innerHTML = html;
}

// 显示截图预览
function showScreenshots(screenshots) {
    const modalBody = document.getElementById('modalBody');
    let html = '<h3><i class="ri-image-line"></i> 任务截图</h3>';
    
    if (!screenshots || !Array.isArray(screenshots) || screenshots.length === 0) {
        html += '<p style="text-align: center; padding: 40px; color: #86868b;">暂无截图</p>';
    } else {
        html += '<div style="display: flex; flex-wrap: wrap; gap: 10px;">';
        screenshots.forEach((url, index) => {
            html += `
                <div style="flex: 1 1 200px; max-width: 300px;">
                    <img src="${url}" style="width: 100%; height: auto; border-radius: 4px;" alt="截图 ${index + 1}">
                </div>
            `;
        });
        html += '</div>';
    }
    
    html += '<div class="form-actions" style="margin-top: 20px;"><button type="button" class="btn-primary" onclick="closeModal()">关闭</button></div>';
    modalBody.innerHTML = html;
    document.getElementById('modal').classList.add('active', 'fullscreen');
}

// 审核任务
function reviewTask(recordId, bTaskId, action) {
    if (action === 'approve') {
        showConfirm('确认通过该任务吗？佣金将自动发放。', async () => {
            try {
                const token = sessionStorage.getItem('admin_token');
                const headers = {
                    'Content-Type': 'application/json'
                };
                
                if (token) {
                    headers['Authorization'] = `Bearer ${token}`;
                }
                
                const response = await fetch('/task_admin/api/tasks/review.php', {
                    method: 'POST',
                    headers: headers,
                    credentials: 'include',
                    body: JSON.stringify({ 
                        record_id: recordId, 
                        b_task_id: bTaskId, 
                        action: 'approve' 
                    })
                });
                
                if (!response.ok) {
                    throw new Error('网络响应错误');
                }
                
                const result = await response.json();
                
                if (result && result.code === 0) {
                    showToast(result.message, 'success');
                    loadTaskReviewList();
                } else {
                    showToast(result ? result.message : '审核失败', 'error');
                }
            } catch (err) {
                showToast('审核失败', 'error');
            }
        });
    } else {
        showRejectModal('任务', async (reason) => {
            try {
                const token = sessionStorage.getItem('admin_token');
                const headers = {
                    'Content-Type': 'application/json'
                };
                
                if (token) {
                    headers['Authorization'] = `Bearer ${token}`;
                }
                
                const response = await fetch('/task_admin/api/tasks/review.php', {
                    method: 'POST',
                    headers: headers,
                    credentials: 'include',
                    body: JSON.stringify({ 
                        record_id: recordId, 
                        b_task_id: bTaskId, 
                        action: 'reject',
                        reject_reason: reason 
                    })
                });
                
                if (!response.ok) {
                    throw new Error('网络响应错误');
                }
                
                const result = await response.json();
                
                if (result && result.code === 0) {
                    showToast(result.message, 'success');
                    loadTaskReviewList();
                } else {
                    showToast(result ? result.message : '审核失败', 'error');
                }
            } catch (err) {
                showToast('审核失败', 'error');
            }
        });
    }
}