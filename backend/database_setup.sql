-- AI 文生图应用数据库创建脚本
-- 连接信息:
-- 数据库名称: ai_text2img
-- 数据库用户: dev_ai
-- 数据库密码: HyzVB8O7mQ1AN3Vk
-- 数据库地址: mysql2.sqlpub.com:3307

-- 使用指定的数据库
USE ai_text2img;

-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    nickname VARCHAR(50),
    avatarUrl VARCHAR(255),
    bio TEXT,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    lastLoginAt DATETIME,
    INDEX idx_username (username),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建图片表
CREATE TABLE IF NOT EXISTS images (
    id VARCHAR(36) PRIMARY KEY,
    userId VARCHAR(36) NOT NULL,
    prompt TEXT NOT NULL,
    negativePrompt TEXT,
    style VARCHAR(50),
    imageUrl VARCHAR(255) NOT NULL,
    thumbnailUrl VARCHAR(255),
    width INT NOT NULL,
    height INT NOT NULL,
    samplingSteps INT NOT NULL DEFAULT 30,
    isPublic BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_userId (userId),
    INDEX idx_isPublic (isPublic),
    INDEX idx_createdAt (createdAt),
    FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建评论表
CREATE TABLE IF NOT EXISTS comments (
    id VARCHAR(36) PRIMARY KEY,
    imageId VARCHAR(36) NOT NULL,
    userId VARCHAR(36) NOT NULL,
    content TEXT NOT NULL,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_imageId (imageId),
    INDEX idx_userId (userId),
    FOREIGN KEY (imageId) REFERENCES images(id) ON DELETE CASCADE,
    FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建点赞表
CREATE TABLE IF NOT EXISTS likes (
    id VARCHAR(36) PRIMARY KEY,
    imageId VARCHAR(36) NOT NULL,
    userId VARCHAR(36) NOT NULL,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_image (userId, imageId),
    INDEX idx_imageId (imageId),
    INDEX idx_userId (userId),
    FOREIGN KEY (imageId) REFERENCES images(id) ON DELETE CASCADE,
    FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 添加统计查询视图
CREATE OR REPLACE VIEW image_stats AS
SELECT 
    i.id AS imageId,
    i.userId,
    i.prompt,
    i.imageUrl,
    i.thumbnailUrl,
    i.isPublic,
    i.createdAt,
    COUNT(DISTINCT l.id) AS likesCount,
    COUNT(DISTINCT c.id) AS commentCount
FROM 
    images i
    LEFT JOIN likes l ON i.id = l.imageId
    LEFT JOIN comments c ON i.id = c.imageId
WHERE 
    i.isPublic = TRUE
GROUP BY 
    i.id;
