import re

file_path = r'd:\github\douyinTasksystemAPI\api\c\v1\tasks\accept.php'

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# 查看第 65 行
line_65 = lines[64]
print(f"第 65 行：{repr(line_65)}")
print(f"第 65 行字符：{[c for c in line_65[:30]]}")

# 查找所有 error_log
pattern = r"error_log\('请求方法错误:'"
matches = re.findall(pattern, ''.join(lines))
print(f"\n匹配到的 pattern '{pattern}': {len(matches)} 个")

# 简单替换测试
content = ''.join(lines)
if "error_log('请求方法错误:" in content:
    print("\n找到 error_log('请求方法错误:")
    content = content.replace("error_log('请求方法错误：' . $_SERVER['REQUEST_METHOD'])", "$requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']])")
    print("替换完成!")
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("文件已保存")
else:
    print("\n未找到目标字符串")
