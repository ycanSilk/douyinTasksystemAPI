

// ========== 任务模板管理 ==========

// 加载任务模板列表
async function loadTaskTemplates(page = 1) {
    const type = document.getElementById('templateType')?.value || '';
    const status = document.getElementById('templateStatus')?.value || '';
    
    try {
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        
        const response = await fetch(`/task_admin/api/tasks/list.php?page=${page}&type=${type}&status=${status}`, {
            method: 'GET',
            headers: headers,
            credentials: 'include'
        });
        
        if (!response.ok) {
            throw new Error('网络响应错误');
        }
        
        const data = await response.json();
        
        if (data && data.code === 0) {
            renderTaskTemplatesTable(data.data.list);
        }
    } catch (err) {
        console.error('加载任务模板失败', err);
    }
}

function renderTaskTemplatesTable(list) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>类型</th>
                    <th>标题</th>
                    <th>单价</th>
                    <th>描述1</th>
                    <th>描述2</th>
                    <th>阶段1标题</th>
                    <th>阶段1单价</th>
                    <th>阶段2标题</th>
                    <th>阶段2单价</th>
                    <th>默认阶段1数</th>
                    <th>默认阶段2数</th>
                    <th>状态</th>
                    <th>创建时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    if (list.length === 0) {
        html += '<tr><td colspan="15" style="text-align: center; padding: 40px; color: #86868b;">暂无数据</td></tr>';
    } else {
        list.forEach(t => {
            const typeBadge = t.type === 0 ? '<span class="badge badge-info">单任务</span>' : '<span class="badge badge-success">组合任务</span>';
            const statusBadge = t.status === 1 ? '<span class="badge badge-success">已上线</span>' : '<span class="badge badge-neutral">已下线</span>';
            
            html += `
                <tr>
                    <td>${t.id}</td>
                    <td>${typeBadge}</td>
                    <td><strong>${t.title}</strong></td>
                    <td>¥${t.price}</td>
                    <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis;">${t.description1 || '-'}</td>
                    <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis;">${t.description2 || '-'}</td>
                    <td>${t.stage1_title || '-'}</td>
                    <td>${t.stage1_price ? '¥' + t.stage1_price : '-'}</td>
                    <td>${t.stage2_title || '-'}</td>
                    <td>${t.stage2_price ? '¥' + t.stage2_price : '-'}</td>
                    <td>${t.default_stage1_count || '-'}</td>
                    <td>${t.default_stage2_count || '-'}</td>
                    <td>${statusBadge}</td>
                    <td>${t.created_at}</td>
                    <td>
                        <button class="btn-info btn-small" onclick='editTaskTemplate(${JSON.stringify(t)})'><i class="ri-edit-line"></i> 编辑</button>
                        <button class="btn-danger btn-small" onclick="deleteTaskTemplate(${t.id})"><i class="ri-delete-bin-line"></i> 删除</button>
                    </td>
                </tr>
            `;
        });
    }
    
    html += '</tbody></table></div>';
    document.getElementById('templatesTable').innerHTML = html;
}

// 新增任务模板
function addTaskTemplate() {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3><i class="ri-add-line"></i> 新增任务模板</h3>
        <form id="addTaskForm">
            <div class="form-group">
                <label>任务类型</label>
                <select name="type" id="newTaskType" onchange="toggleComboFields()">
                    <option value="0">单任务</option>
                    <option value="1">组合任务</option>
                </select>
            </div>
            <div class="form-group">
                <label>标题</label>
                <input type="text" name="title" placeholder="任务标题" required>
            </div>
            <div class="form-group">
                <label>单价（元）</label>
                <input type="number" name="price" placeholder="任务单价" step="0.01" required>
            </div>
            <div class="form-group">
                <label>描述信息1</label>
                <textarea name="description1" placeholder="描述信息1"></textarea>
            </div>
            <div class="form-group">
                <label>描述信息2</label>
                <textarea name="description2" placeholder="描述信息2"></textarea>
            </div>
            <div id="comboFields" style="display: none;">
                <div class="form-group">
                    <label>阶段1标题</label>
                    <input type="text" name="stage1_title" placeholder="阶段1标题">
                </div>
                <div class="form-group">
                    <label>阶段1单价（元）</label>
                    <input type="number" name="stage1_price" placeholder="阶段1单价" step="0.01">
                </div>
                <div class="form-group">
                    <label>阶段2标题</label>
                    <input type="text" name="stage2_title" placeholder="阶段2标题">
                </div>
                <div class="form-group">
                    <label>阶段2单价（元）</label>
                    <input type="number" name="stage2_price" placeholder="阶段2单价" step="0.01">
                </div>
                <div class="form-group">
                    <label>默认阶段1数量</label>
                    <input type="number" name="default_stage1_count" value="1" placeholder="默认阶段1数量">
                </div>
                <div class="form-group">
                    <label>默认阶段2数量</label>
                    <input type="number" name="default_stage2_count" value="3" placeholder="默认阶段2数量">
                </div>
            </div>
            <div id="singleCommissionFields">
                <h4 style="margin: 16px 0 8px; color: #666; border-top: 1px solid #eee; padding-top: 16px;">佣金配置（元）</h4>
                <div class="form-group">
                    <label>普通用户佣金（元）</label>
                    <input type="number" name="c_user_commission" value="0" step="0.01" placeholder="如 2.00">
                </div>
                <div class="form-group">
                    <label>普通团长佣金（元）</label>
                    <input type="number" name="agent_commission" value="0" step="0.01" placeholder="如 0.50">
                </div>
                <div class="form-group">
                    <label>高级团长佣金（元）</label>
                    <input type="number" name="senior_agent_commission" value="0" step="0.01" placeholder="如 1.00">
                </div>
            </div>
            <div id="comboCommissionFields" style="display: none;">
                <h4 style="margin: 16px 0 8px; color: #666; border-top: 1px solid #eee; padding-top: 16px;">阶段1佣金配置（元）</h4>
                <div class="form-group">
                    <label>阶段1-普通用户佣金（元）</label>
                    <input type="number" name="stage1_c_user_commission" value="0" step="0.01" placeholder="如 2.00">
                </div>
                <div class="form-group">
                    <label>阶段1-普通团长佣金（元）</label>
                    <input type="number" name="stage1_agent_commission" value="0" step="0.01" placeholder="如 0.50">
                </div>
                <div class="form-group">
                    <label>阶段1-高级团长佣金（元）</label>
                    <input type="number" name="stage1_senior_agent_commission" value="0" step="0.01" placeholder="如 1.00">
                </div>
                <h4 style="margin: 16px 0 8px; color: #666; border-top: 1px solid #eee; padding-top: 16px;">阶段2佣金配置（元）</h4>
                <div class="form-group">
                    <label>阶段2-普通用户佣金（元）</label>
                    <input type="number" name="stage2_c_user_commission" value="0" step="0.01" placeholder="如 2.00">
                </div>
                <div class="form-group">
                    <label>阶段2-普通团长佣金（元）</label>
                    <input type="number" name="stage2_agent_commission" value="0" step="0.01" placeholder="如 0.50">
                </div>
                <div class="form-group">
                    <label>阶段2-高级团长佣金（元）</label>
                    <input type="number" name="stage2_senior_agent_commission" value="0" step="0.01" placeholder="如 1.00">
                </div>
            </div>
            <div class="form-group">
                <label>上线状态</label>
                <select name="status">
                    <option value="1">已上线</option>
                    <option value="0">已下线</option>
                </select>
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-primary">创建</button>
            </div>
        </form>
    `;

    document.getElementById('modal').classList.add('active');

    // 类型切换
    window.toggleComboFields = () => {
        const type = document.getElementById('newTaskType').value;
        document.getElementById('comboFields').style.display = type === '1' ? 'block' : 'none';
        document.getElementById('singleCommissionFields').style.display = type === '0' ? 'block' : 'none';
        document.getElementById('comboCommissionFields').style.display = type === '1' ? 'block' : 'none';
    };
    
    document.getElementById('addTaskForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const data = {};
        const commissionFields = ['c_user_commission','agent_commission','senior_agent_commission','stage1_c_user_commission','stage1_agent_commission','stage1_senior_agent_commission','stage2_c_user_commission','stage2_agent_commission','stage2_senior_agent_commission'];

        for (const [key, value] of formData.entries()) {
            if (value !== '') {
                if (commissionFields.includes(key)) {
                    data[key] = Math.round(parseFloat(value) * 100);
                } else {
                    data[key] = value;
                }
            }
        }

        try {
            const token = sessionStorage.getItem('admin_token');
            const headers = {
                'Content-Type': 'application/json'
            };
            
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
            
            const response = await fetch('/task_admin/api/tasks/create.php', {
                method: 'POST',
                headers: headers,
                credentials: 'include',
                body: JSON.stringify(data)
            });
            
            if (!response.ok) {
                throw new Error('网络响应错误');
            }
            
            const result = await response.json();
            
            if (result && result.code === 0) {
                showToast('创建成功', 'success');
                closeModal();
                loadTaskTemplates();
            } else {
                showToast(result ? result.message : '创建失败', 'error');
            }
        } catch (err) {
            showToast('创建失败', 'error');
        }
    });
}

// 删除任务模板
function deleteTaskTemplate(id) {
    showConfirm('确认删除该任务模板吗？删除后无法恢复。', async () => {
        try {
            const token = sessionStorage.getItem('admin_token');
            const headers = {
                'Content-Type': 'application/json'
            };
            
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
            
            const response = await fetch('/task_admin/api/tasks/delete.php', {
                method: 'POST',
                headers: headers,
                credentials: 'include',
                body: JSON.stringify({ id })
            });
            
            if (!response.ok) {
                throw new Error('网络响应错误');
            }
            
            const result = await response.json();
            
            if (result && result.code === 0) {
                showToast('删除成功', 'success');
                loadTaskTemplates();
            } else {
                showToast(result ? result.message : '删除失败', 'error');
            }
        } catch (err) {
            showToast('删除失败', 'error');
        }
    });
}

// 编辑任务模板
function editTaskTemplate(task) {
    const modalBody = document.getElementById('modalBody');
    const isCombo = task.type === 1;
    
    modalBody.innerHTML = `
        <h3><i class="ri-edit-line"></i> 编辑任务模板 #${task.id}</h3>
        <form id="editTaskForm">
            <input type="hidden" name="id" value="${task.id}">
            <div class="form-group">
                <label>任务类型（不可修改）</label>
                <input type="text" value="${isCombo ? '组合任务' : '单任务'}" disabled>
            </div>
            <div class="form-group">
                <label>标题</label>
                <input type="text" name="title" value="${task.title}" placeholder="任务标题">
            </div>
            <div class="form-group">
                <label>单价（元）</label>
                <input type="number" name="price" value="${task.price}" placeholder="任务单价" step="0.01">
            </div>
            <div class="form-group">
                <label>描述信息1</label>
                <textarea name="description1" placeholder="描述信息1">${task.description1 || ''}</textarea>
            </div>
            <div class="form-group">
                <label>描述信息2</label>
                <textarea name="description2" placeholder="描述信息2">${task.description2 || ''}</textarea>
            </div>
            ${isCombo || (task.id === 1 || task.id === 2) ? `
                ${isCombo ? `
                    <div class="form-group">
                        <label>阶段1标题</label>
                        <input type="text" name="stage1_title" value="${task.stage1_title || ''}" placeholder="阶段1标题">
                    </div>
                    <div class="form-group">
                        <label>阶段1单价（元）</label>
                        <input type="number" name="stage1_price" value="${task.stage1_price || ''}" placeholder="阶段1单价" step="0.01">
                    </div>
                    <div class="form-group">
                        <label>阶段2标题</label>
                        <input type="text" name="stage2_title" value="${task.stage2_title || ''}" placeholder="阶段2标题">
                    </div>
                    <div class="form-group">
                        <label>阶段2单价（元）</label>
                        <input type="number" name="stage2_price" value="${task.stage2_price || ''}" placeholder="阶段2单价" step="0.01">
                    </div>
                ` : ''}
                <div class="form-group">
                    <label>默认阶段1数量</label>
                    <input type="number" name="default_stage1_count" value="${task.default_stage1_count || 1}" placeholder="默认阶段1数量">
                </div>
                <div class="form-group">
                    <label>默认阶段2数量</label>
                    <input type="number" name="default_stage2_count" value="${task.default_stage2_count || 3}" placeholder="默认阶段2数量">
                </div>
            ` : ''}
            ${isCombo ? `
                <h4 style="margin: 16px 0 8px; color: #666; border-top: 1px solid #eee; padding-top: 16px;">阶段 1 佣金配置（元）</h4>
                <div class="form-group">
                    <label>阶段 1-普通用户佣金（元）</label>
                    <input type="number" name="stage1_c_user_commission" value="${Number(((task.stage1_c_user_commission || 0) / 100)).toFixed(2)}" step="0.01" placeholder="如 2.00">
                </div>
                <div class="form-group">
                    <label>阶段 1-普通团长佣金（元）</label>
                    <input type="number" name="stage1_agent_commission" value="${Number(((task.stage1_agent_commission || 0) / 100)).toFixed(2)}" step="0.01" placeholder="如 0.50">
                </div>
                <div class="form-group">
                    <label>阶段 1-高级团长佣金（元）</label>
                    <input type="number" name="stage1_senior_agent_commission" value="${Number(((task.stage1_senior_agent_commission || 0) / 100)).toFixed(2)}" step="0.01" placeholder="如 1.00">
                </div>
                <h4 style="margin: 16px 0 8px; color: #666; border-top: 1px solid #eee; padding-top: 16px;">阶段 2 佣金配置（元）</h4>
                <div class="form-group">
                    <label>阶段 2-普通用户佣金（元）</label>
                    <input type="number" name="stage2_c_user_commission" value="${Number(((task.stage2_c_user_commission || 0) / 100)).toFixed(2)}" step="0.01" placeholder="如 2.00">
                </div>
                <div class="form-group">
                    <label>阶段 2-普通团长佣金（元）</label>
                    <input type="number" name="stage2_agent_commission" value="${Number(((task.stage2_agent_commission || 0) / 100)).toFixed(2)}" step="0.01" placeholder="如 0.50">
                </div>
                <div class="form-group">
                    <label>阶段 2-高级团长佣金（元）</label>
                    <input type="number" name="stage2_senior_agent_commission" value="${Number(((task.stage2_senior_agent_commission || 0) / 100)).toFixed(2)}" step="0.01" placeholder="如 1.00">
                </div>
            ` : `
                <h4 style="margin: 16px 0 8px; color: #666; border-top: 1px solid #eee; padding-top: 16px;">佣金配置（元）</h4>
                <div class="form-group">
                    <label>普通用户佣金（元）</label>
                    <input type="number" name="c_user_commission" value="${Number(((task.c_user_commission || 0) / 100)).toFixed(2)}" step="0.01" placeholder="如 2.00">
                </div>
                <div class="form-group">
                    <label>普通团长佣金（元）</label>
                    <input type="number" name="agent_commission" value="${Number(((task.agent_commission || 0) / 100)).toFixed(2)}" step="0.01" placeholder="如 0.50">
                </div>
                <div class="form-group">
                    <label>高级团长佣金（元）</label>
                    <input type="number" name="senior_agent_commission" value="${Number(((task.senior_agent_commission || 0) / 100)).toFixed(2)}" step="0.01" placeholder="如 1.00">
                </div>
            `}
            <div class="form-group">
                <label>上线状态</label>
                <select name="status">
                    <option value="1" ${task.status === 1 ? 'selected' : ''}>已上线</option>
                    <option value="0" ${task.status === 0 ? 'selected' : ''}>已下线</option>
                </select>
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-primary">保存</button>
            </div>
        </form>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    document.getElementById('editTaskForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const data = {};
        const commissionFields = ['c_user_commission','agent_commission','senior_agent_commission','stage1_c_user_commission','stage1_agent_commission','stage1_senior_agent_commission','stage2_c_user_commission','stage2_agent_commission','stage2_senior_agent_commission'];

        for (const [key, value] of formData.entries()) {
            if (value !== '') {
                if (commissionFields.includes(key)) {
                    data[key] = Math.round(parseFloat(value) * 100);
                } else {
                    data[key] = value;
                }
            }
        }

        try {
            const token = sessionStorage.getItem('admin_token');
            const headers = {
                'Content-Type': 'application/json'
            };
            
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
            
            const response = await fetch('/task_admin/api/tasks/update.php', {
                method: 'POST',
                headers: headers,
                credentials: 'include',
                body: JSON.stringify(data)
            });
            
            if (!response.ok) {
                throw new Error('网络响应错误');
            }
            
            const result = await response.json();
            
            if (result && result.code === 0) {
                showToast('更新成功', 'success');
                closeModal();
                loadTaskTemplates();
            } else {
                showToast(result ? result.message : '更新失败', 'error');
            }
        } catch (err) {
            showToast('更新失败', 'error');
        }
    });
}