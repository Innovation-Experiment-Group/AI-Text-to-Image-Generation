/**
 * 图片处理服务
 * 提供图片保存、缩略图生成等功能
 */
const fs = require('fs').promises;
const path = require('path');
const sharp = require('sharp');
const { v4: uuidv4 } = require('uuid');

/**
 * 保存下载的图片到本地存储
 * @param {Buffer} imageData - 图片数据
 * @param {string} userId - 用户ID
 * @returns {Promise<{imagePath: string, thumbnailPath: string}>} - 图片和缩略图路径
 */
const saveGeneratedImage = async (imageData, userId) => {
    try {
        // 生成唯一ID作为文件名
        const imageId = uuidv4();
        const imageName = `image_${imageId}.png`;
        const thumbnailName = `thumb_${imageName}`;

        // 保存路径
        const uploadDir = path.join(__dirname, '../../', process.env.IMAGE_UPLOAD_PATH || 'uploads/images');
        const imagePath = path.join(uploadDir, imageName);
        const thumbnailPath = path.join(uploadDir, thumbnailName);

        // 确保目录存在
        await fs.mkdir(uploadDir, { recursive: true });

        // 保存原始图片
        await fs.writeFile(imagePath, imageData);

        // 创建缩略图 (宽度调整为400px，保持纵横比)
        await sharp(imageData)
            .resize({ width: 400 })
            .toFile(thumbnailPath);

        return {
            imageId,
            imageUrl: `/uploads/images/${imageName}`,
            thumbnailUrl: `/uploads/images/${thumbnailName}`
        };
    } catch (error) {
        console.error('保存生成的图片失败:', error);
        throw error;
    }
};

module.exports = {
    saveGeneratedImage
};
