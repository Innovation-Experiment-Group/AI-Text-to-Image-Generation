# AI 文生图应用 - 后端服务

## 项目介绍

这是一个 AI 文生图应用的后端服务，提供用户管理、图片生成、图片管理、评论管理等功能的 API 接口。本项目使用模拟的AI图片生成服务，可以在实际部署时集成阿里云百炼 API 等图片生成服务。

## 主要功能

1. **用户管理**：注册、登录、个人信息管理、头像上传
2. **图片生成**：基于文本描述生成图片，支持不同风格和参数
3. **图片管理**：公开/私有图片管理、图片画廊、个人图片管理
4. **评论功能**：对图片进行评论
5. **点赞功能**：对图片进行点赞/取消点赞

## 技术栈

- Node.js
- Express.js
- MySQL
- JWT 认证
- 文件系统存储(本地开发)
- 可扩展的AI图片生成服务集成

## API 文档

详细的 API 文档请参考 [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)

## 开发环境设置

### 前提条件

- Node.js (v14+)
- MySQL 数据库

### 安装步骤

1. 克隆仓库
```bash
git clone <repository-url>
cd AI-Text-to-Image-Generation/backend
```

2. 安装依赖
```bash
npm install
```

3. 初始化数据库
```bash
npm run init-db
```

4. 配置环境变量
创建 `.env` 文件并设置以下参数：
```
PORT=3000
JWT_SECRET=your_secret_key
JWT_EXPIRES_IN=7d

# 数据库配置
DB_HOST=your_db_host
DB_PORT=3306
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_NAME=your_db_name

# 阿里云百炼API配置
DASHSCOPE_API_KEY=your_dashscope_api_key
USE_AI_SERVICE=true
AI_TASK_CHECK_INTERVAL=5000
DEFAULT_MODEL=wanx2.1-t2i-turbo
```


5. 启动服务
```bash
npm run dev
```

## 文件结构

```
backend/
├── config/              # 配置文件
├── src/                 # 源代码
│   ├── controllers/     # 控制器
│   ├── routes/          # 路由
│   ├── middlewares/     # 中间件
│   ├── models/          # 数据模型
│   ├── utils/           # 工具函数
│   ├── app.js           # Express 应用配置
│   └── server.js        # 服务器入口
├── uploads/             # 上传文件目录
│   ├── avatars/         # 用户头像
│   └── images/          # 生成的图片
├── .env                 # 环境变量
└── database_setup.sql   # 数据库初始化SQL脚本
```

## 测试API

项目包含一个API测试脚本：
```bash
node src/test-api.js
```

## 部署

### 生产环境部署

1. 配置生产环境变量
修改 `.env` 文件以匹配生产环境配置

2. 启动生产服务
```bash
npm start
```

建议使用 PM2 等进程管理工具进行部署：
```bash
pm2 start src/server.js --name ai-image-backend
```

## 数据库

数据库结构详情请查看 [DATABASE_README.md](./DATABASE_README.md) 文件。

## 许可证

[MIT 许可证](LICENSE)
