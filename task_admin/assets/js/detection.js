// WebSocket连接管理
class WebSocketManager {
    constructor() {
        console.log('=== WebSocketManager 初始化 ===');
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
            'magnifier': 'magnifier'
        };
        this.soundPlayDebounceTimer = null;
        this.SOUND_DEBOUNCE_TIME = 5000; // 5秒防抖时间窗口
        this.audioContext = null; // 音频上下文
        this.init();
    }

    // 初始化WebSocket连接
    init() {
        console.log('=== 开始初始化WebSocket连接 ===');
        // 尝试获取音频播放权限
        console.log('1. 尝试获取音频播放权限');
        this.requestAudioPermission();
        
        // 建立WebSocket连接
        console.log('2. 建立WebSocket连接');
        this.connect();
        
        // 监听页面可见性变化，当页面重新可见时检查连接
        console.log('3. 监听页面可见性变化');
        document.addEventListener('visibilitychange', () => {
            if (!document.hidden && !this.connected) {
                console.log('页面重新可见，检查WebSocket连接');
                this.connect();
            }
        });
        console.log('=== WebSocket初始化完成 ===');
    }

    // 尝试获取音频播放权限
    requestAudioPermission() {
        console.log('=== 尝试获取音频播放权限 ===');
        // 创建一个静音的音频元素，尝试播放以获取权限
        const silentAudio = new Audio('data:audio/wav;base64,UklGRigAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQQAAAD');
        silentAudio.volume = 0;
        
        console.log('尝试播放静音音频以获取权限');
        silentAudio.play().then(() => {
            console.log('✅ 成功获取音频播放权限');
            // 立即暂停
            silentAudio.pause();
        }).catch(error => {
            console.log('❌ 首次音频播放权限请求失败，需要用户互动:', error);
            // 监听用户互动事件，再次尝试
            console.log('设置用户互动监听器');
            this.setupUserInteractionListener();
        });
    }

    // 设置用户互动监听器
    setupUserInteractionListener() {
        console.log('=== 设置用户互动监听器 ===');
        const interactEvents = ['click', 'touchstart', 'keydown', 'mousedown'];
        console.log('监听的事件类型:', interactEvents);
        
        const handleInteraction = () => {
            console.log('=== 用户互动，尝试获取音频播放权限 ===');
            
            // 创建一个静音的音频元素，尝试播放以获取权限
            const silentAudio = new Audio('data:audio/wav;base64,UklGRigAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQQAAAD');
            silentAudio.volume = 0;
            
            console.log('用户互动后尝试播放静音音频');
            silentAudio.play().then(() => {
                console.log('✅ 用户互动后成功获取音频播放权限');
                silentAudio.pause();
                // 移除所有互动监听器
                console.log('移除所有互动监听器');
                interactEvents.forEach(event => {
                    document.removeEventListener(event, handleInteraction);
                });
            }).catch(error => {
                console.log('❌ 用户互动后音频播放权限请求仍失败:', error);
            });
        };
        
        // 添加互动监听器
        console.log('添加互动监听器');
        interactEvents.forEach(event => {
            document.addEventListener(event, handleInteraction, { once: true });
        });
        console.log('用户互动监听器设置完成');
    }

    // 建立WebSocket连接
    connect() {
        console.log('=== 建立WebSocket连接 ===');
        console.log('WebSocket连接开始时间:', new Date().toISOString());
        try {
            // 直接使用固定的WebSocket URL
            const wsUrl = 'ws://localhost:8080';
            
            console.log('WebSocket URL:', wsUrl);
            console.log('尝试连接...');
            
            // 创建WebSocket连接
            this.socket = new WebSocket(wsUrl);
            console.log('WebSocket对象已创建');
            
            // 设置onopen事件处理程序
            this.socket.onopen = (event) => {
                console.log('✅ WebSocket连接已建立 - 连接成功');
                console.log('连接建立时间:', new Date().toISOString());
                console.log('连接状态:', this.socket.readyState);
                this.connected = true;
                this.reconnectAttempts = 0;
                
                // 连接成功后发送队列中的消息
                console.log('准备发送队列中的消息');
                this.flushMessageQueue();
            };
            
            // 设置onmessage事件处理程序
            this.socket.onmessage = (event) => {
                console.log('=== 🔔 接收到WebSocket消息 ===');
                console.log('接收时间:', new Date().toISOString());
                console.log('原始消息数据(event.data):', event.data);
                console.log('消息数据类型:', typeof event.data);
                console.log('消息数据长度:', event.data ? event.data.length : 0);
                
                this.handleMessage(event.data);
            };
            
            // 设置onclose事件处理程序
            this.socket.onclose = (event) => {
                console.log('❌ WebSocket连接已关闭');
                console.log('关闭时间:', new Date().toISOString());
                console.log('关闭状态码:', event.code);
                console.log('关闭原因:', event.reason);
                this.connected = false;
                console.log('准备尝试重新连接...');
                this.attemptReconnect();
            };
            
            // 设置onerror事件处理程序
            this.socket.onerror = (error) => {
                console.error('❌ WebSocket发生错误');
                console.error('错误时间:', new Date().toISOString());
                console.error('错误详情:', error);
                this.connected = false;
                console.log('准备尝试重新连接...');
                this.attemptReconnect();
            };
        } catch (error) {
            console.error('❌ WebSocket连接异常');
            console.error('异常时间:', new Date().toISOString());
            console.error('异常详情:', error);
            this.connected = false;
            console.log('准备尝试重新连接...');
            this.attemptReconnect();
        }
    }

    // 尝试重新连接
    attemptReconnect() {
        console.log('=== 尝试重新连接 ===');
        if (this.reconnectAttempts < this.maxReconnectAttempts) {
            this.reconnectAttempts++;
            const delay = this.reconnectDelay * Math.pow(1.5, this.reconnectAttempts - 1);
            console.log(`尝试重新连接 (${this.reconnectAttempts}/${this.maxReconnectAttempts})，延迟 ${delay}ms`);
            
            setTimeout(() => {
                console.log('执行重新连接');
                this.connect();
            }, delay);
        } else {
            console.error('❌ 达到最大重连尝试次数，停止重连');
        }
    }

    // 发送消息
    send(message) {
        console.log('=== 发送消息 ===');
        console.log('发送的消息:', message);
        if (this.connected && this.socket.readyState === WebSocket.OPEN) {
            console.log('WebSocket连接正常，发送消息');
            this.socket.send(message);
        } else {
            console.log('WebSocket连接未建立，将消息加入队列');
            // 将消息加入队列，待连接建立后发送
            this.messageQueue.push(message);
        }
    }

    // 发送队列中的消息
    flushMessageQueue() {
        console.log('=== 发送队列中的消息 ===');
        console.log('队列中的消息数量:', this.messageQueue.length);
        while (this.messageQueue.length > 0) {
            const message = this.messageQueue.shift();
            console.log('发送队列中的消息:', message);
            this.send(message);
        }
        console.log('队列消息发送完成');
    }

    // 关闭连接
    close() {
        console.log('=== 关闭WebSocket连接 ===');
        if (this.socket) {
            console.log('关闭WebSocket连接');
            this.socket.close();
        } else {
            console.log('WebSocket连接不存在');
        }
    }

    // 处理接收到的消息
    handleMessage(data) {
        console.log('=== 🚀 开始处理WebSocket消息 ===');
        console.log('处理开始时间:', new Date().toISOString());
        console.log('原始数据:', data);
        
        try {
            console.log('开始解析JSON数据...');
            const message = JSON.parse(data);
            console.log('✅ JSON解析成功');
            
            console.log('解析后的消息对象:', message);
            console.log('消息JSON字符串:', JSON.stringify(message, null, 2));
            
            // 输出消息类型和完整数据结构
            console.log('消息类型 (message.type):', message.type);
            console.log('消息完整数据 (JSON.stringify):', JSON.stringify(message, null, 2));
            
            // 处理审核任务通知
            if (message.type === 'audit_notification') {
                console.log('检测到审核任务通知类型');
                console.log('消息数据 (message.data):', message.data);
                this.handleAuditNotification(message.data);
            } else {
                console.log('⚠️ 未知消息类型:', message.type);
            }
            
            console.log('消息处理完成');
        } catch (error) {
            console.error('❌ 解析WebSocket消息失败');
            console.error('错误:', error);
            console.error('原始数据:', data);
        }
    }

    // 处理审核通知
    handleAuditNotification(data) {
        console.log('=== 📋 开始处理审核通知 ===');
        console.log('处理时间:', new Date().toISOString());
        console.log('接收到的完整数据:', data);
        console.log('数据类型:', typeof data);
        console.log('数据JSON:', JSON.stringify(data, null, 2));
        
        // 输出完整的审核通知数据结构
        console.log('审核通知完整数据 (JSON):', JSON.stringify(data, null, 2));
        
        // 检查是否有 detection_result 字段
        console.log('检查 detection_result 字段是否存在...');
        console.log('data.detection_result:', data.detection_result);
        
        if (data.detection_result) {
            const detectionResult = data.detection_result;
            console.log('审核任务检测结果:', detectionResult);
            
            // 输出每个检测结果的详细信息
            console.log('=== 详细检测结果分析 ===');
            for (const [key, value] of Object.entries(detectionResult)) {
                console.log(`检测项: ${key} = ${value}`);
                console.log(`类型说明: ${this.getDetectionTypeDescription(key)}`);
            }
            
            // 检查是否有新的审核任务
            let hasNewTasks = false;
            let totalTasks = 0;
            
            // 更新导航栏角标
            console.log('开始更新导航栏角标...');
            for (const [key, value] of Object.entries(detectionResult)) {
                console.log(`处理任务类型: ${key}, 数量: ${value}`);
                if (this.badgeMap[key]) {
                    const panelType = this.badgeMap[key];
                    console.log(`映射到面板类型: ${panelType}`);
                    console.log(`更新 ${panelType} 角标，数量: ${value}`);
                    this.updateBadge(panelType, value);
                    if (value > 0) {
                        hasNewTasks = true;
                        totalTasks += value;
                    }
                } else {
                    console.log(`未知任务类型: ${key} (不在badgeMap中)`);
                }
            }
            
            console.log(`是否有新任务: ${hasNewTasks}, 总任务数: ${totalTasks}`);
            
            // 如果有新任务，先模拟用户点击获取权限，然后播放提示音
            if (hasNewTasks) {
                console.log('检测到新任务，准备播放提示音...');
                this.simulateUserInteraction(() => {
                    console.log('模拟点击完成，准备播放提示音');
                    this.playNotificationSound();
                });
            }
        } else {
            console.warn('⚠️ 审核通知数据中没有 detection_result 字段');
            console.warn('可用字段:', Object.keys(data));
        }
        
        console.log('审核通知处理完成');
    }
    
    // 获取检测类型说明
    getDetectionTypeDescription(key) {
        const descriptions = {
            'recharge': '充值审核任务',
            'withdraw': '提现审核任务', 
            'agent': '代理审核任务',
            'magnifier': '放大镜审核任务'
        };
        return descriptions[key] || '未知类型';
    }

    // 模拟用户交互以获取音频播放权限
    simulateUserInteraction(callback) {
        console.log('=== 模拟用户交互 ===');
        try {
            // 查找刷新数据按钮
            console.log('查找刷新数据按钮');
            const refreshButton = document.querySelector('.btn-secondary.btn-small');
            if (refreshButton) {
                console.log('找到刷新数据按钮，准备模拟点击');
                console.log('按钮信息:', refreshButton);
                
                // 创建并分发点击事件
                console.log('创建点击事件');
                const clickEvent = new MouseEvent('click', {
                    bubbles: true,
                    cancelable: true,
                    view: window,
                    clientX: 100,
                    clientY: 100
                });
                
                // 触发点击事件
                console.log('触发点击事件');
                const clicked = refreshButton.dispatchEvent(clickEvent);
                console.log('模拟点击结果:', clicked);
                
                // 延迟执行回调，确保权限获取成功
                console.log('延迟100ms执行回调');
                setTimeout(() => {
                    console.log('执行回调函数');
                    callback();
                }, 100);
            } else {
                console.warn('❌ 未找到刷新数据按钮，直接尝试播放提示音');
                // 如果找不到按钮，直接尝试播放
                callback();
            }
        } catch (error) {
            console.error('❌ 模拟用户交互失败:', error);
            // 失败时直接尝试播放
            callback();
        }
    }

    // 更新导航栏角标
    updateBadge(panelType, count) {
        console.log('=== 更新导航栏角标 ===');
        console.log(`更新 ${panelType} 角标，数量: ${count}`);
        // 找到对应的导航链接
        const navLink = document.querySelector(`.nav-link[data-page="${panelType}"]`);
        if (!navLink) {
            console.warn('❌ 未找到对应的导航链接:', panelType);
            return;
        }
        console.log('找到导航链接:', navLink);
        
        // 查找现有的角标
        let badge = navLink.querySelector('.badge-notification');
        console.log('现有角标:', badge);
        
        // 如果数量为0，移除角标
        if (count === 0) {
            console.log('数量为0，移除角标');
            if (badge) {
                badge.remove();
                console.log('角标已移除');
            }
            return;
        }
        
        // 如果角标不存在，创建新的
        if (!badge) {
            console.log('角标不存在，创建新的');
            badge = document.createElement('span');
            badge.className = 'badge-notification';
            navLink.appendChild(badge);
            console.log('新角标已创建');
        }
        
        // 更新角标数量
        console.log('更新角标数量为:', count);
        badge.textContent = count;
        console.log('角标更新完成');
    }

    // 播放通知提示音（带防抖控制）
    playNotificationSound() {
        console.log('=== 播放通知提示音 ===');
        // 检查是否在防抖时间窗口内
        if (this.soundPlayDebounceTimer) {
            console.log('在防抖时间窗口内，跳过播放');
            return;
        }
        
        // 设置防抖定时器
        console.log('设置防抖定时器，时间窗口:', this.SOUND_DEBOUNCE_TIME);
        this.soundPlayDebounceTimer = setTimeout(() => {
            console.log('防抖定时器到期');
            this.soundPlayDebounceTimer = null;
        }, this.SOUND_DEBOUNCE_TIME);
        
        console.log('准备播放提示音');
        
        // 尝试使用页面上的音频元素
        const audio = document.getElementById('notificationSound');
        if (audio) {
            console.log('找到页面上的音频元素，准备播放');
            audio.currentTime = 0; // 重置音频播放位置
            
            // 尝试播放音频
            console.log('尝试播放音频');
            audio.play().then(() => {
                console.log('✅ 提示音播放成功');
            }).catch(error => {
                console.error('❌ 提示音播放失败:', error);
                // 尝试备用方案：创建新的音频元素
                console.log('尝试备用方案：创建新的音频元素');
                this.tryAlternativeAudioPlay();
            });
        } else {
            console.warn('❌ 未找到通知音频元素，尝试备用方案');
            this.tryAlternativeAudioPlay();
        }
    }

    // 尝试备用音频播放方案
    tryAlternativeAudioPlay() {
        console.log('=== 尝试备用音频播放方案 ===');
        try {
            console.log('创建新的音频元素');
            const newAudio = new Audio('public/videos/preview.mp3');
            console.log('尝试播放新音频元素');
            newAudio.play().then(() => {
                console.log('✅ 备用方案播放提示音成功');
            }).catch(err => {
                console.error('❌ 备用方案播放失败:', err);
                // 尝试使用AudioContext
                console.log('尝试使用AudioContext');
                this.tryAudioContextPlay();
            });
        } catch (e) {
            console.error('❌ 创建音频元素失败:', e);
            // 尝试使用AudioContext
            console.log('尝试使用AudioContext');
            this.tryAudioContextPlay();
        }
    }

    // 尝试使用AudioContext播放
    tryAudioContextPlay() {
        console.log('=== 尝试使用AudioContext播放 ===');
        try {
            console.log('初始化AudioContext');
            if (!this.audioContext) {
                this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
                console.log('AudioContext初始化成功');
            }
            
            // 加载音频文件
            console.log('加载音频文件: public/videos/preview.mp3');
            fetch('public/videos/preview.mp3')
                .then(response => {
                    console.log('音频文件加载成功:', response);
                    return response.arrayBuffer();
                })
                .then(arrayBuffer => {
                    console.log('解码音频数据');
                    return this.audioContext.decodeAudioData(arrayBuffer);
                })
                .then(audioBuffer => {
                    console.log('音频数据解码成功，创建音频源');
                    const source = this.audioContext.createBufferSource();
                    source.buffer = audioBuffer;
                    source.connect(this.audioContext.destination);
                    console.log('播放音频');
                    source.start();
                    console.log('✅ AudioContext播放提示音成功');
                })
                .catch(error => {
                    console.error('❌ AudioContext播放失败:', error);
                });
        } catch (e) {
            console.error('❌ AudioContext初始化失败:', e);
        }
    }
}

// 初始化WebSocket管理器
let wsManager = null;

// 页面加载完成后初始化
if (typeof window !== 'undefined') {
    window.addEventListener('DOMContentLoaded', () => {
        console.log('页面加载完成，开始初始化');
        
        // 初始化WebSocket管理器
        wsManager = new WebSocketManager();
        console.log('WebSocket管理器初始化完成');
    });
    
    // 页面卸载时关闭WebSocket连接
    window.addEventListener('beforeunload', () => {
        if (wsManager) {
            wsManager.close();
        }
    });
}

// 导出WebSocket管理器（如果在模块化环境中）
if (typeof module !== 'undefined' && module.exports) {
    module.exports = WebSocketManager;
}
