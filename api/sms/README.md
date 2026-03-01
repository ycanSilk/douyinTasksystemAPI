# 短信校验API接口文档

## 接口说明

本目录包含短信校验相关的API接口，使用阿里云短信认证服务API实现。

## 接口列表

| 接口名称 | 路径 | 方法 | 功能描述 |
|---------|------|------|----------|
| 获取验证码 | /api/sms/send-code.php | POST | 向指定手机号发送验证码 |
| 校验验证码 | /api/sms/verify-code.php | POST | 验证手机号和验证码是否匹配 |

## 通用响应格式

所有接口返回统一的JSON格式：

```json
{
    "code": 0,           // 0 表示成功，非 0 表示错误
    "message": "ok",    // 响应消息
    "data": {},          // 响应数据
    "timestamp": 1234567890  // 时间戳
}
```

## 详细接口说明

### 获取验证码接口

#### 请求地址
`POST http://localhost:8000/api/sms/send-code.php`

#### 请求参数

| 参数名 | 类型 | 必填 | 描述 |
|--------|------|------|------|
| phone_number | string | 是 | 手机号，11位数字 |

#### 请求示例

```bash
curl -X POST http://localhost:8000/api/sms/send-code.php \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "phone_number=13794719208"
```

#### 响应示例

**成功响应：**
```json
{
    "code": 0,
    "message": "验证码发送成功",
    "data": {
        "phone_number": "13794719208",
        "code": "123456" // 实际项目中不应该返回验证码
    },
    "timestamp": 1772359526
}
```

**失败响应：**
```json
{
    "code": 1001,
    "message": "手机号不能为空",
    "data": {},
    "timestamp": 1772359526
}
```

#### 错误码说明

| 错误码 | 说明 |
|--------|------|
| 1001 | 手机号不能为空 |
| 1002 | 手机号格式不正确 |
| 1003 | 验证码发送失败 |

### 2. 校验验证码接口

#### 请求地址
`POST http://localhost:8000/api/sms/verify-code.php`

#### 请求参数

| 参数名 | 类型 | 必填 | 描述 |
|--------|------|------|------|
| phone_number | string | 是 | 手机号，11位数字 |
| verify_code | string | 是 | 验证码，6位数字 |

#### 请求示例

```bash
curl -X POST http://localhost:8000/api/sms/verify-code.php \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "phone_number=13794719208&verify_code=123456"
```

#### 响应示例

**成功响应：**
```json
{
    "code": 0,
    "message": "验证码验证成功",
    "data": {
        "phone_number": "13794719208"
    },
    "timestamp": 1772359526
}
```

**失败响应：**
```json
{
    "code": 1005,
    "message": "验证码验证失败: Invalid verify code",
    "data": {},
    "timestamp": 1772359526
}
```

#### 错误码说明

| 错误码 | 说明 |
|--------|------|
| 1001 | 手机号不能为空 |
| 1002 | 验证码不能为空 |
| 1003 | 手机号格式不正确 |
| 1004 | 验证码格式不正确 |
| 1005 | 验证码验证失败 |

## 环境要求

1. PHP 7.0 或更高版本
2. Composer
3. 阿里云短信服务配置

## 安装依赖

```bash
composer install
```

## 配置说明

需要在阿里云控制台配置：
1. 短信签名（signName）
2. 短信模板（templateCode）
3. 配置阿里云访问凭证

## 注意事项

1. 实际项目中应将验证码存储到数据库或缓存中，并设置过期时间
2. 生产环境中不应在响应中返回验证码
3. 应添加频率限制，防止短信轰炸
4. 验证码有效期一般设置为5-10分钟
