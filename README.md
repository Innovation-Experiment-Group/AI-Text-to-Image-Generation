# AI 文本生成图像应用

一个基于阿里云百炼API的AI文本生成图像Web应用，包含完整的前后端实现。

## 项目概述

本项目是一个完整的AI文本到图像生成平台，允许用户通过输入文本描述来生成高质量图像。应用具备用户管理、图像生成、图像管理和社交功能等完整特性。

### 主要功能

- **用户系统**: 注册、登录、个人资料管理
- **AI图像生成**: 基于文本提示词生成图像
- **图像管理**: 浏览、收藏、更新和删除图像
- **社交功能**: 评论、点赞、分享图像
- **公共画廊**: 浏览其他用户生成的公开图像

## 技术栈

### 后端

- **Node.js** + **Express**: 提供RESTful API服务
- **MySQL**: 数据存储
- **JWT**: 用户认证
- **阿里云百炼API**: AI文生图服务
- **Multer**: 文件上传处理

### 前端

- **Flutter**: 跨平台UI框架
- **Provider**: 状态管理
- **HTTP**: API通信
- **Shared Preferences**: 本地存储

## 安装指南

### 前提条件

- Node.js (v14+)
- MySQL (v8.0+)
- Flutter SDK (v3.0+)
- 阿里云账号和百炼API密钥

### 后端设置

1. 克隆仓库并进入后端目录:
   ```bash
   git clone https://github.com/yourusername/AI-Text-to-Image-Generation.git
   cd AI-Text-to-Image-Generation/backend
   ```

2. 安装依赖:
   ```bash
   npm install
   ```

3. 配置环境变量:
   创建`.env`文件并配置以下变量:
   ```
   PORT=3001
   JWT_SECRET=your_secret_key
   JWT_EXPIRES_IN=7d
   
   # 数据库配置
   DB_HOST=localhost
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=your_password
   DB_NAME=ai_text2img
   
   # 阿里云百炼API
   DASHSCOPE_API_KEY=your_api_key
   USE_AI_SERVICE=true
   DEFAULT_MODEL=wanx2.1-t2i-turbo
   
   # 文件上传路径
   AVATAR_UPLOAD_PATH=uploads/avatars
   IMAGE_UPLOAD_PATH=uploads/images
   ```

4. 初始化数据库:
   ```bash
   # 创建数据库并初始化表结构
   mysql -u root -p < database_setup.sql
   ```

5. 启动服务器:
   ```bash
   npm run dev
   ```

### 前端设置

1. 进入前端目录:
   ```bash
   cd ../frontend
   ```

2. 安装依赖:
   ```bash
   flutter pub get
   ```

3. 配置API基础URL:
   编辑 `assets/.env` 文件:
   ```
   API_BASE_URL=http://localhost:3001/api
   ```

4. 运行应用:
   ```bash
   flutter run
   ```

## 使用指南

### 图像生成

1. 登录系统
2. 导航至"生成"页面
3. 输入详细的文本描述（提示词）
4. 可选择添加负面提示词和选择风格
5. 点击生成按钮
6. 等待几秒钟，图像将被生成并显示

### 图像管理

- 在"我的图像"页面查看和管理您的所有图像
- 可设置图像为公开或私有
- 可编辑图像描述或删除图像

### 社交功能

- 浏览"画廊"查看其他用户公开的图像
- 点赞喜欢的图像
- 在图像下方添加评论

## API文档

详细的API文档可以在 `backend/API_DOCUMENTATION.md` 中找到。

## 项目结构

```
.
├── backend/               # 后端代码
│   ├── src/               # 源代码
│   │   ├── controllers/   # 控制器
│   │   ├── middlewares/   # 中间件
│   │   ├── routes/        # 路由定义
│   │   ├── services/      # 服务层
│   │   └── utils/         # 工具函数
│   └── uploads/           # 上传文件存储
└── frontend/              # 前端代码
    ├── lib/               # Flutter代码
    │   ├── models/        # 数据模型
    │   ├── pages/         # 页面UI
    │   ├── providers/     # 状态管理
    │   ├── services/      # API服务
    │   └── widgets/       # UI组件
    └── assets/            # 静态资源
```

## 开发者

- HeLong
- HuangJiaWei
- ChengKaiZhong
- LiuYi
- ZhaoXingChi
- HeShiZhen
- WangMengXi

## 许可证

MIT

