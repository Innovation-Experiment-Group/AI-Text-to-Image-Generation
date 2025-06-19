# AI 文生图应用 - 前端项目

这是一个基于Flutter开发的跨平台AI文本到图像生成应用的前端部分。该应用允许用户通过输入文本描述生成图像，并提供用户管理、图像管理和社交互动功能。

## 项目概述

AI文生图应用是一个结合了现代UI设计和强大AI能力的应用程序，使用阿里云百炼API进行图像生成。前端采用Flutter框架开发，支持Android、iOS、Web等多个平台。

### 主要功能

- **用户管理**：注册、登录、个人资料设置
- **图像生成**：文本到图像的AI生成功能
- **图库浏览**：公共图库和个人图库
- **社交互动**：点赞、评论功能
- **个性化设置**：多种图像生成风格选择

## 开发环境配置

### 前提条件

- Flutter SDK (版本: 3.10.0 或更高)
- Dart (版本: 3.0.0 或更高)
- Android Studio / VS Code
- 后端服务 (请参阅项目根目录下的backend文件夹)

### 安装步骤

1. **安装Flutter SDK**：
   ```
   # 下载Flutter SDK并添加到环境变量
   # 验证安装
   flutter doctor
   ```

2. **克隆项目**：
   ```
   git clone https://github.com/yourusername/AI-Text-to-Image-Generation.git
   cd AI-Text-to-Image-Generation/frontend
   ```

3. **安装依赖**：
   ```
   flutter pub get
   ```

4. **配置后端API地址**：
   修改 `lib/services/api_service.dart` 中的API基础URL，指向后端服务地址。

5. **运行应用**：
   ```
   # 运行在调试模式
   flutter run
   
   # 或构建发布版本
   flutter build apk  # Android
   flutter build ios  # iOS
   flutter build web  # Web
   ```

## 项目结构

```
frontend/
├── lib/                # 主要源代码
│   ├── main.dart       # 应用入口点
│   ├── models/         # 数据模型
│   ├── pages/          # 页面UI
│   ├── providers/      # 状态管理
│   ├── services/       # API服务
│   ├── utils/          # 工具函数
│   └── widgets/        # 可复用UI组件
├── assets/             # 静态资源
└── test/               # 测试代码
```

## 页面与功能

### 主要页面

1. **登录/注册页**：用户身份验证
2. **首页**：包含最新生成的图片和热门图片
3. **生成页**：文本到图像生成界面
4. **个人中心**：用户资料和个人图库
5. **图片详情页**：查看图片详情、评论和点赞

### 状态管理

项目使用Provider包进行状态管理，主要包括：

- UserProvider：管理用户身份和信息
- ImageProvider：管理图像数据
- ThemeProvider：管理应用主题设置

## 与后端集成

前端通过RESTful API与后端服务进行通信。主要集成点：

1. **认证服务**：用户注册、登录和JWT令牌管理
2. **图像服务**：图像生成请求和结果获取
3. **社交功能**：评论和点赞操作

详细API文档请参阅 `backend/API_DOCUMENTATION.md`

## 部署指南

### Web部署

1. 构建Web版本：
   ```
   flutter build web --release
   ```

2. 部署到Web服务器：
   将 `build/web` 目录下的文件复制到Web服务器根目录

### 移动应用部署

1. Android应用构建：
   ```
   flutter build apk --release
   ```

2. iOS应用构建：
   ```
   flutter build ios --release
   ```

## 贡献指南

1. Fork项目仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建Pull Request

## 常见问题

1. **API连接问题**：确保后端服务正在运行，并检查API基础URL配置
2. **图像生成失败**：检查阿里云百炼API密钥配置和网络连接
3. **构建错误**：运行 `flutter clean` 然后再次尝试构建

## 资源链接

- [Flutter官方文档](https://flutter.dev/docs)
- [Dart编程语言](https://dart.dev/)
- [阿里云百炼API文档](https://help.aliyun.com/document_detail/2399595.html)
- [Provider状态管理](https://pub.dev/packages/provider)
