

// ==================== 网站配置管理 ====================

// 加载系统配置
async function loadSystemConfig() {
    const group = document.getElementById('configGroupFilter').value;
    const params = new URLSearchParams();
    if (group) params.append('group', group);

    try {
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        const response = await fetch(`/task_admin/api/config/list.php?${params}`, {
            method: 'GET',
            headers: headers,
            credentials: 'include'
        });
        
        if (!response.ok) {
            throw new Error('网络响应错误');
        }
        
        const result = await response.json();

        if (result && (result.code === 0 || result.code === 200)) {
            renderConfigTable(result.data.configs);
        } else {
            showToast('加载失败: ' + (result ? result.message : '未知错误'), 'error');
        }
    } catch (err) {
        showToast('加载配置失败: ' + err.message, 'error');
    }
}

// 渲染配置表格
function renderConfigTable(configs) {
    const container = document.getElementById('configTable');

    if (!configs || configs.length === 0) {
        container.innerHTML = '<p class="empty-message" style="text-align: center; padding: 40px; color: #86868b;">暂无配置</p>';
        return;
    }

    // 按分组整理配置
    const groupedConfigs = {};
    configs.forEach(config => {
        if (!groupedConfigs[config.config_group]) {
            groupedConfigs[config.config_group] = [];
        }
        groupedConfigs[config.config_group].push(config);
    });

    const groupNames = {
        'general': '基础配置',
        'withdraw': '提现配置',
        'task': '任务配置',
        'rental': '租赁配置',
        'notification': '消息通知配置',
        'agent': '大团团长佣金配置',
        'incentive': '团长激励配置'
    };

    let html = '';
    
    for (const [group, items] of Object.entries(groupedConfigs)) {
        html += `
            <div style="margin-bottom: 30px;" class="card">
                <div class="card-header">
                    <div class="card-title">${groupNames[group] || group}</div>
                </div>
                <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>配置名称</th>
                            <th>配置键</th>
                            <th>当前值</th>
                            <th>类型</th>
                            <th>说明</th>
                            <th>更新时间</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
        `;

        items.forEach(config => {
            let displayValue = '';
            if (config.config_type === 'array') {
                displayValue = Array.isArray(config.display_value) 
                    ? config.display_value.join(', ') 
                    : config.display_value;
            } else if (config.config_type === 'boolean') {
                displayValue = config.display_value ? '是' : '否';
            } else {
                displayValue = config.display_value;
            }

            html += `
                <tr>
                    <td><strong>${config.description || config.config_key}</strong></td>
                    <td><code>${config.config_key}</code></td>
                    <td>${displayValue}</td>
                    <td><span class="badge badge-neutral">${config.config_type}</span></td>
                    <td style="color: #86868b; font-size: 13px;">${config.description || '-'}</td>
                    <td>${config.updated_at}</td>
                    <td>
                        <button class="btn-info btn-small" onclick="showEditConfigModal('${config.config_key}', '${config.config_type}', '${displayValue}', '${config.description || ''}')"><i class="ri-edit-line"></i> 编辑</button>
                    </td>
                </tr>
            `;
        });

        html += `
                    </tbody>
                </table>
                </div>
            </div>
        `;
    }

    container.innerHTML = html;
}

// 显示编辑配置弹窗
function showEditConfigModal(configKey, configType, currentValue, description) {
    let inputHtml = '';
    
    switch (configType) {
        case 'boolean':
            const checked = currentValue === '是' || currentValue === '1' || currentValue === 'true';
            inputHtml = `
                <label style="display: flex; align-items: center; gap: 10px; cursor: pointer;">
                    <input type="checkbox" id="configValueInput" ${checked ? 'checked' : ''} style="width: auto;">
                    <span>启用</span>
                </label>
            `;
            break;
            
        case 'int':
        case 'float':
            inputHtml = `<input type="number" id="configValueInput" value="${currentValue}" ${configType === 'float' ? 'step="0.01"' : ''} style="width: 100%;">`;
            break;
            
        case 'array':
            inputHtml = `
                <input type="text" id="configValueInput" value="${currentValue}" placeholder="多个值用逗号分隔" style="width: 100%;">
                <p style="color: var(--text-secondary); font-size: 13px; margin-top: 5px;">提示：多个值用逗号分隔，例如：1,3,5</p>
            `;
            break;
            
        default:
            inputHtml = `<input type="text" id="configValueInput" value="${currentValue}" style="width: 100%;">`;
    }

    const html = `
        <h3><i class="ri-edit-line"></i> 编辑配置</h3>
        <div style="margin: 20px 0;">
            <div class="form-group">
                <label>配置键</label>
                <input type="text" value="${configKey}" disabled style="background: var(--bg-body);">
            </div>
            
            <div class="form-group">
                <label>说明</label>
                <p style="color: var(--text-secondary); margin: 0;">${description || '无'}</p>
            </div>
            
            <div class="form-group">
                <label>配置值</label>
                ${inputHtml}
            </div>
            
            <div class="form-actions">
                <button class="btn-secondary" onclick="document.getElementById('modal').classList.remove('active')">取消</button>
                <button class="btn-primary" onclick="saveConfig('${configKey}', '${configType}')">保存</button>
            </div>
        </div>
    `;

    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = html;
    document.getElementById('modal').classList.add('active');
}

// 保存配置
async function saveConfig(configKey, configType) {
    let configValue;
    const input = document.getElementById('configValueInput');
    
    switch (configType) {
        case 'boolean':
            configValue = input.checked ? '1' : '0';
            break;
        case 'int':
            configValue = parseInt(input.value);
            if (isNaN(configValue)) {
                showToast('请输入有效的整数', 'error');
                return;
            }
            break;
        case 'float':
            configValue = parseFloat(input.value);
            if (isNaN(configValue)) {
                showToast('请输入有效的数字', 'error');
                return;
            }
            break;
        case 'array':
            configValue = input.value.split(',').map(v => v.trim()).filter(v => v);
            break;
        default:
            configValue = input.value;
    }

    try {
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        const response = await fetch('/task_admin/api/config/update.php', {
            method: 'POST',
            headers: headers,
            credentials: 'include',
            body: JSON.stringify({
                config_key: configKey,
                config_value: configValue
            })
        });
        
        if (!response.ok) {
            throw new Error('网络响应错误');
        }
        
        const result = await response.json();

        if (result && (result.code === 0 || result.code === 200)) {
            showToast('配置更新成功', 'success');
            document.getElementById('modal').classList.remove('active');
            loadSystemConfig();
        } else {
            showToast('更新失败: ' + (result ? result.message : '未知错误'), 'error');
        }
    } catch (err) {
        showToast('更新失败: ' + err.message, 'error');
    }
}
