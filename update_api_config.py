import os
import json
import re

# API 根目录
api_root = r'd:\github\douyinTasksystemAPI\api'
config_file = r'd:\github\douyinTasksystemAPI\config\api_log_mapping.json'

# 加载现有配置
if os.path.exists(config_file):
    with open(config_file, 'r', encoding='utf-8') as f:
        config = json.load(f)
else:
    config = {
        "_comment": "接口日志映射配置文件",
        "_description": "配置接口路径与日志文件前缀的映射关系",
        "_version": "1.0.0",
        "api_routes": {},
        "log_types": {
            "request": {"description": "请求日志", "retention_days": 30, "priority": "high"},
            "error": {"description": "错误日志", "retention_days": 90, "priority": "critical"},
            "audit": {"description": "审计日志", "retention_days": 365, "priority": "high"},
            "sql": {"description": "SQL 日志", "retention_days": 7, "priority": "low", "production_enabled": False},
            "operation": {"description": "运维日志", "retention_days": 180, "priority": "medium"},
            "access": {"description": "访问日志", "retention_days": 90, "priority": "medium"},
            "cron": {"description": "定时任务日志", "retention_days": 30, "priority": "medium"}
        },
        "settings": {
            "default_log_type": "request",
            "date_format": "Y-m-d",
            "dir_structure": "{log_type}/{api_path}/{date}/log.log",
            "auto_rotation": True,
            "compression_enabled": False
        }
    }

# 扫描 API 文件
api_files = []
for root, dirs, files in os.walk(api_root):
    for file in files:
        if file.endswith('.php'):
            filepath = os.path.join(root, file)
            # 获取相对路径
            rel_path = os.path.relpath(filepath, api_root)
            # 转换为 API 路径格式
            api_path = rel_path.replace('\\', '/').replace('.php', '')
            api_files.append({
                'file': filepath,
                'api_path': api_path,
                'rel_path': rel_path
            })

# 分类整理
categories = {
    'B 端认证接口': [],
    'C 端认证接口': [],
    'B 端任务接口': [],
    'C 端任务接口': [],
    'B 端用户接口': [],
    'C 端用户接口': [],
    'B 端统计接口': [],
    'C 端统计接口': [],
    'B 端通知接口': [],
    'C 端通知接口': [],
    '租赁业务接口': [],
    '短信接口': [],
    '其他接口': []
}

for api_file in api_files:
    api_path = api_file['api_path']
    
    # 根据路径分类
    if 'b/v1/auth' in api_path:
        categories['B 端认证接口'].append(api_path)
    elif 'c/v1/auth' in api_path:
        categories['C 端认证接口'].append(api_path)
    elif 'b/v1/tasks' in api_path:
        categories['B 端任务接口'].append(api_path)
    elif 'c/v1/tasks' in api_path:
        categories['C 端任务接口'].append(api_path)
    elif 'b/v1' in api_path:
        if 'wallet' in api_path or 'me' in api_path or 'password' in api_path:
            categories['B 端用户接口'].append(api_path)
        elif 'statistics' in api_path or 'stats' in api_path:
            categories['B 端统计接口'].append(api_path)
        elif 'notification' in api_path:
            categories['B 端通知接口'].append(api_path)
        else:
            categories['B 端任务接口'].append(api_path)
    elif 'c/v1' in api_path:
        if 'wallet' in api_path or 'me' in api_path or 'password' in api_path:
            categories['C 端用户接口'].append(api_path)
        elif 'statistics' in api_path or 'stats' in api_path:
            categories['C 端统计接口'].append(api_path)
        elif 'notification' in api_path:
            categories['C 端通知接口'].append(api_path)
        elif 'agent' in api_path:
            categories['C 端任务接口'].append(api_path)
        else:
            categories['C 端任务接口'].append(api_path)
    elif 'rental' in api_path:
        categories['租赁业务接口'].append(api_path)
    elif 'sms' in api_path:
        categories['短信接口'].append(api_path)
    else:
        categories['其他接口'].append(api_path)

# 构建 API 路由配置
api_routes = {}

for category, paths in categories.items():
    if not paths:
        continue
    
    category_routes = {}
    for api_path in paths:
        # 生成 log_prefix
        log_prefix = api_path.replace('/', '-')
        
        # 生成描述
        desc_parts = api_path.split('/')
        description = '-'.join(desc_parts[-2:]) if len(desc_parts) > 2 else desc_parts[-1]
        description = description.replace('-', ' ').title()
        
        # 生成文件路径
        file_path = f"api/{api_path}.php"
        
        category_routes[api_path] = {
            "log_prefix": f"request/{log_prefix}",
            "description": description,
            "file": file_path
        }
    
    api_routes[category] = category_routes

# 更新配置
config['api_routes'] = api_routes

# 保存配置
with open(config_file, 'w', encoding='utf-8') as f:
    json.dump(config, f, ensure_ascii=False, indent=2)

print(f"✓ 已扫描 {len(api_files)} 个 API 文件")
print(f"✓ 已分类到 {len(categories)} 个类别")
print(f"✓ 已更新配置文件：{config_file}")
print(f"\n分类统计:")
for category, paths in categories.items():
    if paths:
        print(f"  - {category}: {len(paths)} 个接口")
