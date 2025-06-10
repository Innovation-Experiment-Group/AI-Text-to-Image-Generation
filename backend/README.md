# AI 文生图小软件 - 后端服务

## 项目介绍

这是一个 AI 文生图小软件的后端服务，提供用户管理、图片生成、图片管理、评论管理等功能的 API 接口。本项目使用阿里云百炼 API 进行图片生成。

## 主要功能

1. **用户管理**：注册、登录、个人信息管理
2. **图片生成**：基于文本描述生成图片
3. **图片管理**：公开/私有图片管理、图片画廊
4. **评论功能**：对图片进行评论
5. **点赞功能**：对图片进行点赞/取消点赞

## 技术栈

- Node.js
- Express.js/Nest.js
- MongoDB
- JWT 认证
- 阿里云 OSS (图片存储)
- 阿里云百炼 API (AI 图片生成)

## API 文档

详细的 API 文档请参考 [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)

## 开发环境设置

### 前提条件

- Node.js (v14+)
- MongoDB
- 阿里云账号（用于百炼 API 和 OSS）

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

3. 配置环境变量
创建 `.env` 文件并设置以下变量：
```
PORT=3000
MONGODB_URI=mongodb://localhost:27017/ai-image-generator
JWT_SECRET=your_jwt_secret
ALIYUN_ACCESS_KEY_ID=your_aliyun_access_key_id
ALIYUN_ACCESS_KEY_SECRET=your_aliyun_access_key_secret
ALIYUN_OSS_BUCKET=your_oss_bucket_name
ALIYUN_OSS_REGION=your_oss_region
```

4. 启动服务
```bash
npm run dev
```

## 部署

### 生产环境部署

1. 构建应用
```bash
npm run build
```

2. 启动生产服务
```bash
npm start
```

建议使用 PM2 等进程管理工具进行部署：
```bash
pm2 start dist/main.js --name ai-image-backend
```

## 许可证

[MIT 许可证](LICENSE)
