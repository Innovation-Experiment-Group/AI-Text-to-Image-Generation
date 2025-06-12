# 数据库初始化指南

本目录包含AI文生图应用的数据库初始化脚本，用于创建所有必要的数据库表结构。

## 数据库连接信息

- **数据库名称**：ai_text2img
- **数据库用户**：dev_ai
- **数据库密码**：HyzVB8O7mQ1AN3Vk
- **数据库地址**：mysql2.sqlpub.com:3307

## 文件说明

- `database_setup.sql` - 包含创建所有表的SQL语句
- `init_database.js` - Node.js脚本，用于执行SQL文件并初始化数据库
- `config/database.js` - 数据库配置文件，用于其他部分的应用程序

## 初始化数据库

### 方法一: 使用Node.js脚本

1. 确保已安装所需依赖：
```bash
npm install mysql2 bcrypt uuid
```

2. 运行初始化脚本：
```bash
node init_database.js
```

### 方法二: 直接使用SQL文件

1. 使用MySQL客户端连接到数据库：
```bash
mysql -h mysql2.sqlpub.com -P 3307 -u dev_ai -p
```

2. 输入密码：`HyzVB8O7mQ1AN3Vk`

3. 创建数据库（如果不存在）：
```sql
CREATE DATABASE IF NOT EXISTS ai_text2img CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ai_text2img;
```

4. 执行SQL文件：
```sql
source path/to/database_setup.sql
```

## 表结构说明

数据库包含以下表：

1. `users` - 用户信息表
2. `images` - 生成图片信息表
3. `comments` - 图片评论表
4. `likes` - 图片点赞表

同时创建了一个 `image_stats` 视图，用于快速获取图片的点赞数和评论数统计信息。
