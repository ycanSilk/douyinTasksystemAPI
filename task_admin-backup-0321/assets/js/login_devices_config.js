if (typeof window.LoginDevicesConfig === 'undefined') {
    window.LoginDevicesConfig = class LoginDevicesConfig {
        constructor() {
            this.cMaxDevicesInput = document.getElementById('c-max-devices');
            this.bMaxDevicesInput = document.getElementById('b-max-devices');
            this.saveCConfigBtn = document.getElementById('save-c-config');
            this.saveBConfigBtn = document.getElementById('save-b-config');
            this.messageDiv = document.getElementById('config-message');
            
            this.initEventListeners();
            this.loadCurrentConfig();
        }
        
        /**
         * 初始化事件监听器
         */
        initEventListeners() {
            if (this.saveCConfigBtn) {
                this.saveCConfigBtn.addEventListener('click', () => this.saveConfig('c'));
            }
            
            if (this.saveBConfigBtn) {
                this.saveBConfigBtn.addEventListener('click', () => this.saveConfig('b'));
            }
        }
        
        /**
         * 加载当前配置
         */
        async loadCurrentConfig() {
            try {
                // 这里可以添加获取当前配置的逻辑
                // 暂时使用默认值
                if (this.cMaxDevicesInput) {
                    this.cMaxDevicesInput.value = 1;
                }
                if (this.bMaxDevicesInput) {
                    this.bMaxDevicesInput.value = 1;
                }
            } catch (error) {
                console.error('加载配置失败:', error);
            }
        }
        
        /**
         * 保存配置
         * @param {string} type - 'c' 或 'b'，表示C端或B端
         */
        async saveConfig(type) {
            try {
                const input = type === 'c' ? this.cMaxDevicesInput : this.bMaxDevicesInput;
                const maxDevices = parseInt(input.value);
                
                if (isNaN(maxDevices) || maxDevices < 1 || maxDevices > 10) {
                    this.showMessage('设备数量必须在1-10之间', 'error');
                    return;
                }
                
                const url = `/task_admin/api/login_devices_configuration/${type}_users.php`;
                const token = sessionStorage.getItem('admin_token');
                const headers = {
                    'Content-Type': 'application/json'
                };
                
                if (token) {
                    headers['Authorization'] = `Bearer ${token}`;
                }
                
                const response = await fetch(url, {
                    method: 'POST',
                    headers: headers,
                    body: JSON.stringify({ max_devices: maxDevices }),
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
                    this.showMessage(result.message, 'success');
                } else {
                    this.showMessage(result.message, 'error');
                }
                
            } catch (error) {
                console.error('保存配置失败:', error);
                this.showMessage('保存失败，请稍后重试', 'error');
            }
        }
        
        /**
         * 显示消息
         * @param {string} message - 消息内容
         * @param {string} type - 'success' 或 'error'
         */
        showMessage(message, type) {
            if (!this.messageDiv) return;
            
            this.messageDiv.textContent = message;
            this.messageDiv.className = `config-message ${type}`;
            
            // 3秒后隐藏消息
            setTimeout(() => {
                this.messageDiv.textContent = '';
                this.messageDiv.className = 'config-message';
            }, 3000);
        }
    };
}

// 确保全局可访问
if (typeof LoginDevicesConfig === 'undefined') {
    var LoginDevicesConfig = window.LoginDevicesConfig;
}

// 页面加载完成后初始化
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => new LoginDevicesConfig());
} else {
    new LoginDevicesConfig();
}
