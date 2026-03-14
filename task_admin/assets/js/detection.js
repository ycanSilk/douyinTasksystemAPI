// WebSocket连接管理
if (typeof window.WebSocketManager === 'undefined') {
    window.WebSocketManager = class WebSocketManager {
        constructor() {
            this.socket = null;
            this.reconnectAttempts = 0;
            this.maxReconnectAttempts = 5;
            this.reconnectDelay = 3000;
            this.connected = false;
            this.messageQueue = [];
            this.badgeMap = {
                'recharge': 'recharge',
                'withdraw': 'withdraw',
                'agent': 'agent',
                'magnifier': 'magnifier',
                'rental': 'rental-orders'
            };
            this.soundPlayDebounceTimer = null;
            this.SOUND_DEBOUNCE_TIME = 5000; // 5秒防抖时间窗口
            this.audioContext = null; // 音频上下文
            this.init();
        }

    // 初始化WebSocket连接
    init() {
        // 尝试获取音频播放权限
        this.requestAudioPermission();
        
        // 建立WebSocket连接
        this.connect();
        
        // 监听页面可见性变化，当页面重新可见时检查连接
        document.addEventListener('visibilitychange', () => {
            if (!document.hidden && !this.connected) {
                this.connect();
            }
        });
    }

    // 尝试获取音频播放权限
    requestAudioPermission() {
        // 创建一个静音的音频元素，尝试播放以获取权限
        const silentAudio = new Audio('data:audio/wav;base64,UklGRigAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQQAAAD');
        silentAudio.volume = 0;
        
        silentAudio.play().then(() => {
            // 立即暂停
            silentAudio.pause();
        }).catch(error => {
            // 监听用户互动事件，再次尝试
            this.setupUserInteractionListener();
        });
    }

    // 设置用户互动监听器
    setupUserInteractionListener() {
        const interactEvents = ['click', 'touchstart', 'keydown', 'mousedown'];
        
        const handleInteraction = () => {
            // 创建一个静音的音频元素，尝试播放以获取权限
            const silentAudio = new Audio('data:audio/wav;base64,UklGRigAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQQAAAD');
            silentAudio.volume = 0;
            
            silentAudio.play().then(() => {
                silentAudio.pause();
                // 移除所有互动监听器
                interactEvents.forEach(event => {
                    document.removeEventListener(event, handleInteraction);
                });
            }).catch(error => {
            });
        };
        
        // 添加互动监听器
        interactEvents.forEach(event => {
            document.addEventListener(event, handleInteraction, { once: true });
        });
    }

    // 建立WebSocket连接
    connect() {
        try {
            // 直接使用固定的WebSocket URL
            const wsUrl = 'ws://localhost:8080';
            
            // 创建WebSocket连接
            this.socket = new WebSocket(wsUrl);
            
            // 设置onopen事件处理程序
            this.socket.onopen = (event) => {
                this.connected = true;
                this.reconnectAttempts = 0;
                
                // 连接成功后发送队列中的消息
                this.flushMessageQueue();
            };
            
            // 设置onmessage事件处理程序
            this.socket.onmessage = (event) => {
                this.handleMessage(event.data);
            };
            
            // 设置onclose事件处理程序
            this.socket.onclose = (event) => {
                this.connected = false;
                this.attemptReconnect();
            };
            
            // 设置onerror事件处理程序
            this.socket.onerror = (error) => {
                this.connected = false;
                this.attemptReconnect();
            };
        } catch (error) {
            this.connected = false;
            this.attemptReconnect();
        }
    }

    // 尝试重新连接
    attemptReconnect() {
        if (this.reconnectAttempts < this.maxReconnectAttempts) {
            this.reconnectAttempts++;
            const delay = this.reconnectDelay * Math.pow(1.5, this.reconnectAttempts - 1);
            
            setTimeout(() => {
                this.connect();
            }, delay);
        }
    }

    // 发送消息
    send(message) {
        if (this.connected && this.socket.readyState === WebSocket.OPEN) {
            this.socket.send(message);
        } else {
            // 将消息加入队列，待连接建立后发送
            this.messageQueue.push(message);
        }
    }

    // 发送队列中的消息
    flushMessageQueue() {
        while (this.messageQueue.length > 0) {
            const message = this.messageQueue.shift();
            this.send(message);
        }
    }

    // 关闭连接
    close() {
        if (this.socket) {
            this.socket.close();
        }
    }

    // 处理接收到的消息
    handleMessage(data) {
        try {
            const message = JSON.parse(data);
            
            // 处理审核任务通知
            if (message.type === 'audit_notification') {
                this.handleAuditNotification(message.data);
            }
        } catch (error) {
        }
    }

    // 处理审核通知
    handleAuditNotification(data) {
        if (data.detection_result) {
            const detectionResult = data.detection_result;
            
            // 检查是否有新的审核任务
            let hasNewTasks = false;
            
            // 更新导航栏角标
            for (const [key, value] of Object.entries(detectionResult)) {
                if (this.badgeMap[key]) {
                    const panelType = this.badgeMap[key];
                    this.updateBadge(panelType, value);
                    if (value > 0) {
                        hasNewTasks = true;
                    }
                }
            }
            
            // 如果有新任务，先模拟用户点击获取权限，然后播放提示音
            if (hasNewTasks) {
                // 立即播放提示音，确保一次轮询只播放一次
                this.simulateUserInteraction(() => {
                    this.playNotificationSound();
                });
            }
        }
    }
    
    // 获取检测类型说明
    getDetectionTypeDescription(key) {
        const descriptions = {
            'recharge': '充值审核任务',
            'withdraw': '提现审核任务', 
            'agent': '代理审核任务',
            'magnifier': '放大镜审核任务',
            'rental': '租赁订单任务'
        };
        return descriptions[key] || '未知类型';
    }

    // 模拟用户交互以获取音频播放权限
    simulateUserInteraction(callback) {
        try {
            // 查找刷新数据按钮
            const refreshButton = document.querySelector('.btn-secondary.btn-small');
            if (refreshButton) {
                // 创建并分发点击事件
                const clickEvent = new MouseEvent('click', {
                    bubbles: true,
                    cancelable: true,
                    view: window,
                    clientX: 100,
                    clientY: 100
                });
                
                // 触发点击事件
                refreshButton.dispatchEvent(clickEvent);
                
                // 延迟执行回调，确保权限获取成功
                setTimeout(() => {
                    callback();
                }, 100);
            } else {
                // 如果找不到按钮，直接尝试播放
                callback();
            }
        } catch (error) {
            // 失败时直接尝试播放
            callback();
        }
    }

    // 更新导航栏角标
    updateBadge(panelType, count) {
        // 找到对应的导航链接
        const navLink = document.querySelector(`.nav-link[data-page="${panelType}"]`);
        if (!navLink) {
            return;
        }
        
        // 查找现有的角标
        let badge = navLink.querySelector('.badge-notification');
        
        // 如果数量为0，移除角标
        if (count === 0) {
            if (badge) {
                badge.remove();
            }
            return;
        }
        
        // 如果角标不存在，创建新的
        if (!badge) {
            badge = document.createElement('span');
            badge.className = 'badge-notification';
            // 为租赁订单添加红色角标样式
            if (panelType === 'rental-orders') {
                badge.classList.add('badge-red');
            }
            navLink.appendChild(badge);
        } else {
            // 如果是租赁订单，确保添加红色角标样式
            if (panelType === 'rental-orders') {
                badge.classList.add('badge-red');
            } else {
                badge.classList.remove('badge-red');
            }
        }
        
        // 更新角标数量
        badge.textContent = count;
    }

    // 播放通知提示音（带防抖控制）
    playNotificationSound() {
        // 检查是否在防抖时间窗口内
        if (this.soundPlayDebounceTimer) {
            return;
        }
        
        // 设置防抖定时器
        this.soundPlayDebounceTimer = setTimeout(() => {
            this.soundPlayDebounceTimer = null;
        }, this.SOUND_DEBOUNCE_TIME);
        
        // 尝试使用页面上的音频元素
        const audio = document.getElementById('notificationSound');
        if (audio) {
            audio.currentTime = 0; // 重置音频播放位置
            
            // 尝试播放音频
            audio.play().then(() => {
            }).catch(error => {
                // 尝试备用方案：创建新的音频元素
                this.tryAlternativeAudioPlay();
            });
        } else {
            this.tryAlternativeAudioPlay();
        }
    }

    // 尝试备用音频播放方案
    tryAlternativeAudioPlay() {
        try {
            const newAudio = new Audio('public/videos/preview.mp3');
            newAudio.play().then(() => {
            }).catch(err => {
                // 尝试使用AudioContext
                this.tryAudioContextPlay();
            });
        } catch (e) {
            // 尝试使用AudioContext
            this.tryAudioContextPlay();
        }
    }

    // 尝试使用AudioContext播放
    tryAudioContextPlay() {
        try {
            if (!this.audioContext) {
                this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
            }
            
            // 加载音频文件
            fetch('public/videos/preview.mp3')
                .then(response => {
                    return response.arrayBuffer();
                })
                .then(arrayBuffer => {
                    return this.audioContext.decodeAudioData(arrayBuffer);
                })
                .then(audioBuffer => {
                    const source = this.audioContext.createBufferSource();
                    source.buffer = audioBuffer;
                    source.connect(this.audioContext.destination);
                    source.start();
                })
                .catch(error => {
                });
        } catch (e) {
        }
    }
}
}

// 初始化WebSocket管理器
if (typeof wsManager === 'undefined') {
    var wsManager = null;
}

// 页面加载完成后初始化
if (typeof window !== 'undefined') {
    window.addEventListener('DOMContentLoaded', () => {
        // 初始化WebSocket管理器
        wsManager = new WebSocketManager();
    });
    
    // 页面卸载时关闭WebSocket连接
    window.addEventListener('beforeunload', () => {
        if (wsManager) {
            wsManager.close();
        }
    });
}

// 确保全局可访问
if (typeof WebSocketManager === 'undefined') {
    var WebSocketManager = window.WebSocketManager;
}

// 导出WebSocket管理器（如果在模块化环境中）
if (typeof module !== 'undefined' && module.exports) {
    module.exports = WebSocketManager;
}
