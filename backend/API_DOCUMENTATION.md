# AI 文生图小软件 - 后端 API 文档

## 基础信息

- 基础 URL: `http://localhost:3000/api` (开发环境)
- 所有 API 请求和响应均采用 JSON 格式
- 认证方式: JWT Token (在请求头中使用 `Authorization: Bearer <token>`)
- API 版本: v1

## 错误处理

所有 API 响应使用标准 HTTP 状态码表示请求状态:

- 200: 成功
- 201: 创建成功
- 400: 请求错误
- 401: 未授权
- 403: 禁止访问
- 404: 资源不存在
- 500: 服务器内部错误

错误响应格式:

```json
{
  "status": "error",
  "code": 400,
  "message": "错误描述"
}
```

## API 端点

### 1. 用户管理 ✅

#### 1.1 用户注册 

- **URL**: `/auth/register`
- **方法**: `POST`
- **描述**: 创建新用户账号
- **请求参数**:

```json
{
  "username": "用户名",
  "password": "密码",
  "email": "邮箱地址",
  "nickname": "昵称(可选)"
}
```

- **响应**:

```json
{
  "status": "success",
  "data": {
    "userId": "用户ID",
    "username": "用户名",
    "email": "邮箱地址",
    "nickname": "昵称",
    "createdAt": "创建时间"
  },
  "token": "JWT Token"
}
```

#### 1.2 用户登录

- **URL**: `/auth/login`
- **方法**: `POST`
- **描述**: 用户登录并获取认证令牌
- **请求参数**:

```json
{
  "username": "用户名",
  "password": "密码"
}
```

- **响应**:

```json
{
  "status": "success",
  "data": {
    "userId": "用户ID",
    "username": "用户名",
    "email": "邮箱地址",
    "nickname": "昵称",
    "avatarUrl": "头像URL"
  },
  "token": "JWT Token"
}
```

#### 1.3 获取用户信息

- **URL**: `/users/profile`
- **方法**: `GET`
- **描述**: 获取当前登录用户的详细信息
- **认证**: 需要
- **响应**:

```json
{
  "status": "success",
  "data": {
    "userId": "用户ID",
    "username": "用户名",
    "email": "邮箱地址",
    "nickname": "昵称",
    "avatarUrl": "头像URL",
    "bio": "个人简介",
    "createdAt": "创建时间",
    "lastLoginAt": "最后登录时间",
    "imageCount": "已生成图片数量"
  }
}
```

#### 1.4 更新用户信息

- **URL**: `/users/profile`
- **方法**: `PUT`
- **描述**: 更新当前登录用户的信息
- **认证**: 需要
- **请求参数**:

```json
{
  "nickname": "新昵称(可选)",
  "email": "新邮箱(可选)",
  "bio": "新个人简介(可选)",
  "password": "新密码(可选)"
}
```

- **响应**:

```json
{
  "status": "success",
  "data": {
    "userId": "用户ID",
    "username": "用户名",
    "email": "邮箱地址",
    "nickname": "昵称",
    "bio": "个人简介",
    "updatedAt": "更新时间"
  }
}
```

#### 1.5 上传用户头像

- **URL**: `/users/avatar`
- **方法**: `POST`
- **描述**: 上传或更新用户头像
- **认证**: 需要
- **请求参数**: 
  - Content-Type: `multipart/form-data`
  - Form 字段: `avatar` (图片文件)
- **响应**:

```json
{
  "status": "success",
  "data": {
    "avatarUrl": "头像URL"
  }
}
```

### 2. 图片生成 ✅

#### 2.1 生成图片

- **URL**: `/images/generate`
- **方法**: `POST`
- **描述**: 根据文本提示生成图片
- **认证**: 需要
- **请求参数**:

```json
{
  "prompt": "详细的文本描述",
  "negativePrompt": "不希望出现的元素(可选)",
  "style": "风格选项(可选)",
  "isPublic": true,  // 是否公开, 默认为 true
  "width": 512,      // 图片宽度, 可选
  "height": 512,     // 图片高度, 可选
  "samplingSteps": 30  // 采样步数, 可选
}
```

- **响应**:

```json
{
  "status": "success",
  "data": {
    "imageId": "图片ID",
    "imageUrl": "生成的图片URL",
    "thumbnailUrl": "缩略图URL",
    "prompt": "使用的文本描述",
    "style": "使用的风格",
    "isPublic": true,
    "createdAt": "创建时间",
    "userId": "用户ID"
  }
}
```

#### 2.2 获取生成任务状态

- **URL**: `/images/status/:taskId`
- **方法**: `GET`
- **描述**: 检查图片生成任务的状态
- **认证**: 需要
- **响应**:

```json
{
  "status": "success",
  "data": {
    "taskId": "任务ID",
    "status": "pending|processing|completed|failed",
    "progress": 75,  // 完成百分比
    "imageId": "图片ID(如果已完成)",
    "imageUrl": "生成的图片URL(如果已完成)",
    "error": "错误信息(如果失败)"
  }
}
```

### 3. 图片管理 ✅

#### 3.1 获取公开图片列表 (画廊)

- **URL**: `/images/gallery`
- **方法**: `GET`
- **描述**: 获取公开的图片列表，支持分页
- **认证**: 不需要
- **请求参数**:
  - Query 参数:
    - `page`: 页码 (默认 1)
    - `limit`: 每页数量 (默认 20)
    - `sort`: 排序方式 (newest, popular, 默认 newest)
- **响应**:

```json
{
  "status": "success",
  "data": {
    "images": [
      {
        "imageId": "图片ID",
        "imageUrl": "图片URL",
        "thumbnailUrl": "缩略图URL",
        "prompt": "文本描述",
        "createdAt": "创建时间",
        "likes": 42,
        "commentCount": 5,
        "user": {
          "userId": "用户ID",
          "nickname": "用户昵称",
          "avatarUrl": "用户头像"
        }
      },
      // 更多图片...
    ],
    "pagination": {
      "total": 100,
      "page": 1,
      "limit": 20,
      "pages": 5
    }
  }
}
```

#### 3.2 获取用户图片列表

- **URL**: `/images/user`
- **方法**: `GET`
- **描述**: 获取当前登录用户的所有图片
- **认证**: 需要
- **请求参数**:
  - Query 参数:
    - `page`: 页码 (默认 1)
    - `limit`: 每页数量 (默认 20)
    - `isPublic`: 过滤公开/私有图片 (true/false, 可选)
- **响应**:

```json
{
  "status": "success",
  "data": {
    "images": [
      {
        "imageId": "图片ID",
        "imageUrl": "图片URL",
        "thumbnailUrl": "缩略图URL",
        "prompt": "文本描述",
        "isPublic": true,
        "createdAt": "创建时间",
        "likes": 42,
        "commentCount": 5
      },
      // 更多图片...
    ],
    "pagination": {
      "total": 50,
      "page": 1,
      "limit": 20,
      "pages": 3
    }
  }
}
```

#### 3.3 获取图片详情

- **URL**: `/images/:imageId`
- **方法**: `GET`
- **描述**: 获取特定图片的详细信息
- **认证**: 仅私有图片需要
- **响应**:

```json
{
  "status": "success",
  "data": {
    "imageId": "图片ID",
    "imageUrl": "图片URL",
    "thumbnailUrl": "缩略图URL",
    "prompt": "文本描述",
    "negativePrompt": "负面提示词",
    "style": "使用的风格",
    "width": 512,
    "height": 512,
    "samplingSteps": 30,
    "isPublic": true,
    "createdAt": "创建时间",
    "likes": 42,
    "user": {
      "userId": "用户ID",
      "nickname": "用户昵称",
      "avatarUrl": "用户头像"
    },
    "comments": [
      {
        "commentId": "评论ID",
        "content": "评论内容",
        "createdAt": "创建时间",
        "user": {
          "userId": "用户ID",
          "nickname": "用户昵称",
          "avatarUrl": "用户头像"
        }
      },
      // 更多评论...
    ]
  }
}
```

#### 3.4 更新图片设置

- **URL**: `/images/:imageId`
- **方法**: `PUT`
- **描述**: 更新图片的设置
- **认证**: 需要 (仅图片创建者)
- **请求参数**:

```json
{
  "isPublic": false,  // 是否公开
  "prompt": "更新的文本描述(可选)"
}
```

- **响应**:

```json
{
  "status": "success",
  "data": {
    "imageId": "图片ID",
    "isPublic": false,
    "prompt": "更新的文本描述",
    "updatedAt": "更新时间"
  }
}
```

#### 3.5 删除图片

- **URL**: `/images/:imageId`
- **方法**: `DELETE`
- **描述**: 删除指定图片
- **认证**: 需要 (仅图片创建者)
- **响应**:

```json
{
  "status": "success",
  "message": "图片已成功删除"
}
```

### 4. 评论管理✅（4.2获取图片评论功能修改）

#### 4.1 添加评论

- **URL**: `/images/:imageId/comments`
- **方法**: `POST`
- **描述**: 为图片添加评论
- **认证**: 需要
- **请求参数**:

```json
{
  "content": "评论内容"
}
```

- **响应**:

```json
{
  "status": "success",
  "data": {
    "commentId": "评论ID",
    "content": "评论内容",
    "createdAt": "创建时间",
    "imageId": "图片ID",
    "user": {
      "userId": "用户ID",
      "nickname": "用户昵称",
      "avatarUrl": "用户头像"
    }
  }
}
```

#### 4.2 获取图片评论（修改了文件 comment.controller.js）

- **URL**: `/images/:imageId/comments`
- **方法**: `GET`
- **描述**: 获取图片的所有评论
- **认证**: 仅私有图片需要
- **请求参数**:
  - Query 参数:
    - `page`: 页码 (默认 1)
    - `limit`: 每页数量 (默认 20)
- **响应**:

```json
{
  "status": "success",
  "data": {
    "comments": [
      {
        "commentId": "评论ID",
        "content": "评论内容",
        "createdAt": "创建时间",
        "user": {
          "userId": "用户ID",
          "nickname": "用户昵称",
          "avatarUrl": "用户头像"
        }
      },
      // 更多评论...
    ],
    "pagination": {
      "total": 30,
      "page": 1,
      "limit": 20,
      "pages": 2
    }
  }
}
```

#### 4.3 删除评论

- **URL**: `/comments/:commentId`
- **方法**: `DELETE`
- **描述**: 删除指定评论
- **认证**: 需要 (仅评论创建者或图片拥有者)
- **响应**:

```json
{
  "status": "success",
  "message": "评论已成功删除"
}
```

### 5. 点赞功能✅

#### 5.1 点赞/取消点赞图片

- **URL**: `/images/:imageId/like`
- **方法**: `POST`
- **描述**: 对图片进行点赞或取消点赞
- **认证**: 需要
- **响应**:

```json
{
  "status": "success",
  "data": {
    "liked": true,  // true: 已点赞, false: 已取消点赞
    "likesCount": 43
  }
}
```

#### 5.2 获取点赞状态

- **URL**: `/images/:imageId/like`
- **方法**: `GET`
- **描述**: 获取当前用户对指定图片的点赞状态
- **认证**: 需要
- **响应**:

```json
{
  "status": "success",
  "data": {
    "liked": true,  // true: 已点赞, false: 未点赞
    "likesCount": 43
  }
}
```

### 6. 风格与模板✅

#### 6.1 获取可用风格列表

- **URL**: `/styles`
- **方法**: `GET`
- **描述**: 获取系统支持的所有图片生成风格
- **认证**: 不需要
- **响应**:

```json
{
  "status": "success",
  "data": [
    {
      "styleId": "写实风格",
      "name": "写实风格",
      "description": "生成逼真的照片级图像",
      "previewUrl": "预览图URL"
    },
    {
      "styleId": "卡通风格",
      "name": "卡通风格",
      "description": "生成卡通风格的图像",
      "previewUrl": "预览图URL"
    },
    // 更多风格...
  ]
}
```

## 数据模型

### 用户模型

```
User {
  id: String           // 用户唯一ID
  username: String     // 用户名 (唯一)
  password: String     // 加密后的密码
  email: String        // 邮箱 (唯一)
  nickname: String     // 昵称
  avatarUrl: String    // 头像URL
  bio: String          // 个人简介
  createdAt: DateTime  // 创建时间
  updatedAt: DateTime  // 更新时间
  lastLoginAt: DateTime // 最后登录时间
}
```

### 图片模型

```
Image {
  id: String           // 图片唯一ID
  userId: String       // 创建者ID
  prompt: String       // 文本描述
  negativePrompt: String // 负面提示词
  style: String        // 风格
  imageUrl: String     // 图片URL
  thumbnailUrl: String // 缩略图URL
  width: Number        // 宽度
  height: Number       // 高度
  samplingSteps: Number // 采样步数
  isPublic: Boolean    // 是否公开
  createdAt: DateTime  // 创建时间
  updatedAt: DateTime  // 更新时间
}
```

### 评论模型

```
Comment {
  id: String           // 评论唯一ID
  imageId: String      // 图片ID
  userId: String       // 用户ID
  content: String      // 评论内容
  createdAt: DateTime  // 创建时间
  updatedAt: DateTime  // 更新时间
}
```

### 点赞模型

```
Like {
  id: String           // 点赞唯一ID
  imageId: String      // 图片ID
  userId: String       // 用户ID
  createdAt: DateTime  // 创建时间
}
```

## 技术实现建议

1. **后端技术栈**:
   - Node.js
   - 数据库: MongoDB (适合处理非结构化数据如图片元数据)
   - 认证: JWT (JSON Web Token)
   - 图片存储: 阿里云 OSS/本地

2. **阿里云百炼 API 集成**:
   - 创建服务账号，获取 API 密钥
   - 使用 API 密钥调用百炼 API
   - 创建中间层以管理 API 调用配额和错误处理

3. **安全措施**:
   - 所有密码使用 bcrypt 加密
   - 实现速率限制以防止 API 滥用
   - 添加输入验证和 XSS 保护
   - 使用 HTTPS 进行通信加密

4. **性能优化**:
   - 实现图片生成任务队列
   - 图片生成使用异步模式
   - 添加图片缓存机制
   - 生成缩略图以优化加载速度