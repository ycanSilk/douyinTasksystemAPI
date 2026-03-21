// 加载提现列表
async function loadWithdrawList(page = 1) {
    const status = document.getElementById('withdrawStatus').value;
    try {
        const token = sessionStorage.getItem('admin_token');
        const headers = {
            'Content-Type': 'application/json'
        };
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }
        const response = await fetch(`/task_admin/api/withdraw/list.php?page=${page}&status=${status}`, {
            method: 'GET',
            headers: headers,
            credentials: 'include'
        });
        
        if (!response.ok) {
            throw new Error('网络响应错误');
        }
        
        const data = await response.json();
        
        if (data && data.code === 0) {
            renderWithdrawTable(data.data.list);
        }
    } catch (err) {
        console.error('加载提现列表失败', err);
    }
}

function renderWithdrawTable(list) {
    let html = `
        <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>用户</th>
                    <th>金额</th>
                    <th>收款方式</th>
                    <th>收款账号</th>
                    <th>姓名</th>
                    <th>状态</th>
                    <th>申请时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    list.forEach(w => {
        let statusBadge = '';
        if (w.status === 0) statusBadge = '<span class="badge badge-warning">待审核</span>';
        else if (w.status === 1) statusBadge = '<span class="badge badge-success">已通过</span>';
        else statusBadge = '<span class="badge badge-danger">已拒绝</span>';
        
        const actions = w.status === 0 ? `
            <button class="btn-success btn-small" onclick="reviewWithdraw(${w.id}, 'approve')"><i class="ri-check-line"></i> 通过</button>
            <button class="btn-danger btn-small" onclick="reviewWithdraw(${w.id}, 'reject')"><i class="ri-close-line"></i> 拒绝</button>
        ` : '-';
        
        html += `
            <tr>
                <td>${w.id}</td>
                <td><strong>${w.username}</strong></td>
                <td>¥${(w.amount / 100).toFixed(2)}</td>
                <td>${w.withdraw_method}</td>
                <td>${w.withdraw_account}</td>
                <td>${w.account_name || '-'}</td>
                <td>${statusBadge}</td>
                <td>${w.created_at}</td>
                <td>${actions}</td>
            </tr>
        `;
    });
    
    html += '</tbody></table></div>';
    document.getElementById('withdrawTable').innerHTML = html;
}

// 审核提现
function reviewWithdraw(id, action) {
    if (action === 'approve') {
        showWithdrawApproveModal(id);
    } else {
        showRejectModal('提现', async (reason) => {
            try {
                const token = sessionStorage.getItem('admin_token');
                const headers = {
                    'Content-Type': 'application/json'
                };
                if (token) {
                    headers['Authorization'] = `Bearer ${token}`;
                }
                const response = await fetch('/task_admin/api/withdraw/review.php', {
                    method: 'POST',
                    headers: headers,
                    credentials: 'include',
                    body: JSON.stringify({ id, action: 'reject', reject_reason: reason })
                });
                
                if (!response.ok) {
                    throw new Error('网络响应错误');
                }
                
                const result = await response.json();
                
                if (result && result.code === 0) {
                    showToast(result.message, 'success');
                    loadWithdrawList();
                } else {
                    showToast(result ? result.message : '审核失败', 'error');
                }
            } catch (err) {
                showToast('审核失败', 'error');
            }
        });
    }
}

// 显示提现审核通过模态框（带图片上传）
function showWithdrawApproveModal(id) {
    const modalBody = document.getElementById('modalBody');
    modalBody.innerHTML = `
        <h3>审核通过 - 上传打款凭证</h3>
        <form id="withdrawApproveForm">
            <div class="upload-area" id="uploadArea">
                <p><i class="ri-camera-line" style="font-size: 32px; color: #ccc;"></i><br>点击或拖拽上传打款凭证图片</p>
                <p style="font-size: 12px; color: #86868b; margin-top: 10px;">支持 JPG、PNG、GIF、WEBP，最大5MB</p>
                <input type="file" id="imageInput" accept="image/*" style="display:none;">
                <img id="uploadPreview" class="upload-preview" style="display:none;">
            </div>
            <input type="hidden" id="uploadedImageUrl" value="">
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                <button type="submit" class="btn-primary">确认通过并打款</button>
            </div>
        </form>
    `;
    
    document.getElementById('modal').classList.add('active');
    
    // 上传区域点击事件
    const uploadArea = document.getElementById('uploadArea');
    const imageInput = document.getElementById('imageInput');
    const uploadPreview = document.getElementById('uploadPreview');
    
    uploadArea.onclick = () => imageInput.click();
    
    imageInput.onchange = async (e) => {
        const file = e.target.files[0];
        if (!file) return;
        
        // 显示预览
        const reader = new FileReader();
        reader.onload = (e) => {
            uploadPreview.src = e.target.result;
            uploadPreview.style.display = 'block';
        };
        reader.readAsDataURL(file);
        
        // 上传到服务器
        uploadArea.classList.add('uploading');
        uploadArea.innerHTML = '<p><i class="ri-loader-4-line ri-spin"></i> 上传中...</p>';
        
        try {
            const token = sessionStorage.getItem('admin_token');
            console.log('Upload token:', token ? 'Exists' : 'Not found');
            
            const formData = new FormData();
            formData.append('image', file);
            
            const headers = {};
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
                console.log('Authorization header set');
            }
            
            console.log('Starting upload request');
            const response = await fetch('/task_admin/api/upload.php', {
                method: 'POST',
                headers: headers,
                credentials: 'include',
                body: formData
            });
            
            console.log('Upload response status:', response.status);
            
            // 读取响应体文本，以便多次使用
            const responseText = await response.text();
            console.log('Upload response text:', responseText);
            
            if (!response.ok) {
                console.error('Upload error response:', responseText);
                throw new Error(`网络响应错误: ${response.status} - ${responseText}`);
            }
            
            try {
                const result = JSON.parse(responseText);
                console.log('Upload result:', result);
                
                if (result && result.code === 0) {
                    document.getElementById('uploadedImageUrl').value = result.data.url;
                    uploadArea.classList.remove('uploading');
                    uploadArea.innerHTML = `
                        <p><i class="ri-check-circle-line" style="color: var(--success-color);"></i> 上传成功</p>
                        <img src="${result.data.url}" class="upload-preview" style="max-height: 150px; margin-top: 10px; border-radius: 4px; display: block; width: auto;">
                    `;
                    console.log('Image URL:', result.data.url);
                    showToast('图片上传成功', 'success');
                } else {
                    console.error('Upload failed:', result);
                    uploadArea.classList.remove('uploading');
                    uploadArea.innerHTML = '<p><i class="ri-close-circle-line" style="color: var(--danger-color);"></i> 上传失败，请重试</p>';
                    showToast(result ? result.message : '上传失败', 'error');
                }
            } catch (jsonError) {
                console.error('JSON parsing error:', jsonError);
                console.error('Response text:', responseText);
                uploadArea.classList.remove('uploading');
                uploadArea.innerHTML = '<p><i class="ri-close-circle-line" style="color: var(--danger-color);"></i> 上传失败，请重试</p>';
                showToast('上传失败: 服务器返回无效响应', 'error');
            }
        } catch (err) {
            console.error('Upload error:', err);
            uploadArea.classList.remove('uploading');
            uploadArea.innerHTML = '<p><i class="ri-close-circle-line" style="color: var(--danger-color);"></i> 上传失败，请重试</p>';
            showToast('图片上传失败: ' + err.message, 'error');
        }
    };
    
    // 表单提交
    document.getElementById('withdrawApproveForm').onsubmit = async (e) => {
        e.preventDefault();
        
        const imgUrl = document.getElementById('uploadedImageUrl').value;
        
        showConfirm('确认通过该提现申请并打款吗？', async () => {
            try {
                const token = sessionStorage.getItem('admin_token');
                const headers = {
                    'Content-Type': 'application/json'
                };
                if (token) {
                    headers['Authorization'] = `Bearer ${token}`;
                }
                const response = await fetch('/task_admin/api/withdraw/review.php', {
                    method: 'POST',
                    headers: headers,
                    credentials: 'include',
                    body: JSON.stringify({ id, action: 'approve', img_url: imgUrl })
                });
                
                if (!response.ok) {
                    throw new Error('网络响应错误');
                }
                
                const result = await response.json();
                
                if (result && result.code === 0) {
                    showToast(result.message, 'success');
                    closeModal();
                    loadWithdrawList();
                } else {
                    showToast(result ? result.message : '审核失败', 'error');
                }
            } catch (err) {
                showToast('审核失败', 'error');
            }
        });
    };
}