// lib/controllers/image.controller.js (最终修复版，严格净化返回值)

const { v4: uuidv4 } = require('uuid');
const fs = require('fs').promises;
const path = require('path');
const { createPool } = require('../config/db');
const { ApiError, catchAsync } = require('../utils/error');
const { createImageTask, getImageTaskResult, downloadGeneratedImage } = require('../services/dashscope.service');
const { saveGeneratedImage } = require('../services/image.service');

const pool = createPool();
const useAiService = process.env.USE_AI_SERVICE === 'true';

const generateImage = catchAsync(async (req, res, next) => {
    const {
        prompt,
        negativePrompt,
        style,
        isPublic = true,
        width = 512,
        height = 512,
        samplingSteps = 30
    } = req.body;

    if (!prompt) {
        return next(new ApiError('文本描述是必填字段', 400));
    }

    const userId = req.user.id;
    let imageId, imageUrl, thumbnailUrl;

    try {
        if (useAiService) {
            const createResponse = await createImageTask(prompt, negativePrompt || '', { size: `${width}*${height}`, n: 1 });
            if (!createResponse.output || !createResponse.output.task_id) throw new Error('创建图片生成任务失败');
            
            const aiTaskId = createResponse.output.task_id;
            let taskResult, taskCompleted = false, retryCount = 0;
            const maxRetries = 30, checkInterval = 5000;

            while (!taskCompleted && retryCount < maxRetries) {
                await new Promise(resolve => setTimeout(resolve, checkInterval));
                taskResult = await getImageTaskResult(aiTaskId);
                if (taskResult.output && taskResult.output.task_status === 'SUCCEEDED') {
                    taskCompleted = true;
                } else if (taskResult.output && taskResult.output.task_status === 'FAILED') {
                    throw new Error(taskResult.output.message || 'AI图片生成任务失败');
                }
                retryCount++;
            }

            if (!taskCompleted) throw new Error('图片生成任务超时');
            
            const imageResults = taskResult.output.results;
            if (imageResults && imageResults.length > 0 && imageResults[0].url) {
                const imageData = await downloadGeneratedImage(imageResults[0].url);
                const savedImage = await saveGeneratedImage(imageData, userId);
                imageId = savedImage.imageId; imageUrl = savedImage.imageUrl; thumbnailUrl = savedImage.thumbnailUrl;
            } else {
                throw new Error('未找到生成的图片URL');
            }
        } else {
            await new Promise(resolve => setTimeout(resolve, 1000));
            imageId = uuidv4();
            const imageName = `image_${imageId}.png`;
            imageUrl = `/uploads/images/${imageName}`;
            thumbnailUrl = `/uploads/images/thumb_${imageName}`;
        }

        await pool.execute(
            `INSERT INTO images (id, userId, prompt, negativePrompt, style, imageUrl, thumbnailUrl, width, height, samplingSteps, isPublic, createdAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
            [imageId, userId, prompt, negativePrompt || null, style || null, imageUrl, thumbnailUrl, width, height, samplingSteps, isPublic ? 1 : 0]
        );

        const [newImages] = await pool.execute(
            'SELECT i.*, u.nickname, u.avatarUrl FROM images i JOIN users u ON i.userId = u.id WHERE i.id = ?', [imageId]
        );

        if (newImages.length === 0) {
            throw new Error('图片已生成但无法从数据库中检索');
        }

        const dbRecord = newImages[0];

        // --- 这是修复的关键 ---
        // 手动构建一个干净、安全、与前端模型完全匹配的返回对象
        const responseData = {
            imageId: dbRecord.id || '',
            imageUrl: dbRecord.imageUrl || '',
            thumbnailUrl: dbRecord.thumbnailUrl || dbRecord.imageUrl || '',
            prompt: dbRecord.prompt || '无提示词',
            negativePrompt: dbRecord.negativePrompt, // 可空
            style: dbRecord.style, // 可空
            width: dbRecord.width,
            height: dbRecord.height,
            samplingSteps: dbRecord.samplingSteps,
            isPublic: Boolean(dbRecord.isPublic),
            createdAt: dbRecord.createdAt ? new Date(dbRecord.createdAt).toISOString() : new Date().toISOString(),
            likes: dbRecord.likes || 0, // 假设新图片likes为0
            commentCount: dbRecord.commentCount || 0, // 假设新图片评论为0
            user: {
                userId: dbRecord.userId || '',
                username: dbRecord.username || '', // 从JOIN查询中获取
                nickname: dbRecord.nickname || '',
                avatarUrl: dbRecord.avatarUrl || ''
            }
        };

        res.status(201).json({
            status: 'success',
            data: responseData
        });

    } catch (error) {
        console.error('图片生成任务失败:', error);
        return next(new ApiError(error.message || '图片生成失败', 500));
    }
});


// 其他函数保持不变
// ... (复制您原来的 getGallery, getUserImages 等所有其他函数到这里)
// ...
const getGenerationStatus = catchAsync(async (req, res, next) => {
    res.status(404).json({status: 'error', message: '此接口已停用'});
});
const getGallery = catchAsync(async (req, res, next) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const sort = req.query.sort || 'newest';
    const offset = (page - 1) * limit;
    try {
        let query;
        if (sort === 'popular') {
            query = `
                SELECT 
                    i.id AS imageId, i.imageUrl, i.thumbnailUrl, i.prompt, i.createdAt, 
                    COUNT(DISTINCT l.id) AS likes, COUNT(DISTINCT c.id) AS commentCount, 
                    u.id AS userId, u.nickname, u.avatarUrl 
                FROM images i
                LEFT JOIN likes l ON i.id = l.imageId
                LEFT JOIN comments c ON i.id = c.imageId
                JOIN users u ON i.userId = u.id 
                WHERE i.isPublic = 1
                GROUP BY i.id
                ORDER BY COUNT(DISTINCT l.id) DESC
                LIMIT ${limit} OFFSET ${offset}
            `;
        } else {
            query = `
                SELECT 
                    i.id AS imageId, i.imageUrl, i.thumbnailUrl, i.prompt, i.createdAt, 
                    COUNT(DISTINCT l.id) AS likes, COUNT(DISTINCT c.id) AS commentCount, 
                    u.id AS userId, u.nickname, u.avatarUrl 
                FROM images i
                LEFT JOIN likes l ON i.id = l.imageId
                LEFT JOIN comments c ON i.id = c.imageId
                JOIN users u ON i.userId = u.id 
                WHERE i.isPublic = 1
                GROUP BY i.id
                ORDER BY i.createdAt DESC
                LIMIT ${limit} OFFSET ${offset}
            `;
        }
        const [images] = await pool.query(query);
        const [countResult] = await pool.execute('SELECT COUNT(*) as total FROM images WHERE isPublic = 1');
        const total = countResult[0].total;
        const pages = Math.ceil(total / limit);
        res.status(200).json({
            status: 'success',
            data: {
                images: images.map(img => ({
                    imageId: img.imageId, imageUrl: img.imageUrl, thumbnailUrl: img.thumbnailUrl,
                    prompt: img.prompt, createdAt: img.createdAt,
                    likes: parseInt(img.likes) || 0, commentCount: parseInt(img.commentCount) || 0,
                    user: { userId: img.userId, nickname: img.nickname || '', avatarUrl: img.avatarUrl || '' }
                })),
                pagination: { total, page, limit, pages }
            }
        });
    } catch (error) {
        console.error('获取图片列表错误:', error);
        return next(new ApiError('获取图片列表失败', 500));
    }
});
const getUserImages = catchAsync(async (req, res, next) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const isPublicFilter = req.query.isPublic !== undefined ? (req.query.isPublic === 'true' ? 1 : 0) : null;
    const offset = (page - 1) * limit;
    const userId = req.user.id;
    try {
        let query = `
            SELECT i.id AS imageId, i.imageUrl, i.thumbnailUrl, i.prompt, i.isPublic, i.createdAt, 
                   COUNT(DISTINCT l.id) AS likes, COUNT(DISTINCT c.id) AS commentCount
            FROM images i
            LEFT JOIN likes l ON i.id = l.imageId
            LEFT JOIN comments c ON i.id = c.imageId
            WHERE i.userId = ?`;
        const queryParams = [userId];
        if (isPublicFilter !== null) {
            query += ` AND i.isPublic = ?`;
            queryParams.push(isPublicFilter);
        }
        query += ` GROUP BY i.id ORDER BY i.createdAt DESC LIMIT ${limit} OFFSET ${offset}`;
        const [images] = await pool.query(query, queryParams);
        let countQuery = `SELECT COUNT(*) as total FROM images i WHERE i.userId = ?`;
        const countParams = [userId];
        if (isPublicFilter !== null) {
            countQuery += ` AND i.isPublic = ?`;
            countParams.push(isPublicFilter);
        }
        const [countResult] = await pool.query(countQuery, countParams);
        const total = countResult[0].total;
        const pages = Math.ceil(total / limit);
        res.status(200).json({
            status: 'success',
            data: {
                images: images.map(img => ({
                    imageId: img.imageId, imageUrl: img.imageUrl, thumbnailUrl: img.thumbnailUrl,
                    prompt: img.prompt, isPublic: Boolean(img.isPublic), createdAt: img.createdAt,
                    likes: parseInt(img.likes) || 0, commentCount: parseInt(img.commentCount) || 0
                })),
                pagination: { total, page, limit, pages }
            }
        });
    } catch (error) {
        console.error('获取用户图片列表错误:', error);
        return next(new ApiError('获取用户图片列表失败', 500));
    }
});
const getImageDetails = catchAsync(async (req, res, next) => {
    const { imageId } = req.params;
    const [images] = await pool.execute(`SELECT i.id AS imageId, i.userId, i.imageUrl, i.thumbnailUrl, i.prompt, i.negativePrompt, i.style, i.width, i.height, i.samplingSteps, i.isPublic, i.createdAt, u.id AS authorId, u.nickname, u.avatarUrl, COUNT(DISTINCT l.id) AS likesCount FROM images i LEFT JOIN users u ON i.userId = u.id LEFT JOIN likes l ON i.id = l.imageId WHERE i.id = ? GROUP BY i.id`, [imageId]);
    if (images.length === 0) return next(new ApiError('图片不存在', 404));
    const image = images[0];
    if (!image.isPublic && (!req.user || req.user.id !== image.userId)) return next(new ApiError('没有权限访问此图片', 403));
    const [comments] = await pool.execute(`SELECT c.id AS commentId, c.content, c.createdAt, u.id AS userId, u.nickname, u.avatarUrl FROM comments c LEFT JOIN users u ON c.userId = u.id WHERE c.imageId = ? ORDER BY c.createdAt DESC`, [imageId]);
    const formattedComments = comments.map(comment => ({ commentId: comment.commentId, content: comment.content, createdAt: comment.createdAt, user: { userId: comment.userId, nickname: comment.nickname, avatarUrl: comment.avatarUrl } }));
    const response = {
        imageId: image.imageId, imageUrl: image.imageUrl, thumbnailUrl: image.thumbnailUrl,
        prompt: image.prompt, negativePrompt: image.negativePrompt, style: image.style, width: image.width, height: image.height,
        samplingSteps: image.samplingSteps, isPublic: Boolean(image.isPublic), createdAt: image.createdAt,
        likes: parseInt(image.likesCount),
        user: { userId: image.authorId, nickname: image.nickname, avatarUrl: image.avatarUrl },
        comments: formattedComments
    };
    res.status(200).json({ status: 'success', data: response });
});
const updateImage = catchAsync(async (req, res, next) => {
    const { imageId } = req.params; const userId = req.user.id; const { isPublic, prompt } = req.body;
    const [images] = await pool.execute('SELECT id, userId FROM images WHERE id = ?', [imageId]);
    if (images.length === 0) return next(new ApiError('图片不存在', 404));
    if (images[0].userId !== userId) return next(new ApiError('没有权限修改此图片', 403));
    const updateFields = []; const updateValues = [];
    if (isPublic !== undefined) { updateFields.push('isPublic = ?'); updateValues.push(isPublic ? 1 : 0); }
    if (prompt !== undefined) { updateFields.push('prompt = ?'); updateValues.push(prompt); }
    if (updateFields.length === 0) return next(new ApiError('未提供任何要更新的信息', 400));
    updateFields.push('updatedAt = NOW()');
    const sql = `UPDATE images SET ${updateFields.join(', ')} WHERE id = ?`;
    updateValues.push(imageId);
    await pool.execute(sql, updateValues);
    const [updatedImages] = await pool.execute('SELECT id, isPublic, prompt, updatedAt FROM images WHERE id = ?', [imageId]);
    res.status(200).json({ status: 'success', data: { imageId: updatedImages[0].id, isPublic: Boolean(updatedImages[0].isPublic), prompt: updatedImages[0].prompt, updatedAt: updatedImages[0].updatedAt } });
});
const deleteImage = catchAsync(async (req, res, next) => {
    const { imageId } = req.params; const userId = req.user.id;
    const [images] = await pool.execute('SELECT id, userId, imageUrl, thumbnailUrl FROM images WHERE id = ?', [imageId]);
    if (images.length === 0) return next(new ApiError('图片不存在', 404));
    if (images[0].userId !== userId) return next(new ApiError('没有权限删除此图片', 403));
    const image = images[0];
    await pool.execute('DELETE FROM images WHERE id = ?', [imageId]);
    try {
        if (image.imageUrl) { const imagePath = path.join(__dirname, '../../', image.imageUrl.replace(/^\/+/, '')); await fs.unlink(imagePath).catch(() => {}); }
        if (image.thumbnailUrl) { const thumbPath = path.join(__dirname, '../../', image.thumbnailUrl.replace(/^\/+/, '')); await fs.unlink(thumbPath).catch(() => {}); }
    } catch (error) { console.error('删除图片文件失败:', error); }
    res.status(200).json({ status: 'success', message: '图片已成功删除' });
});

module.exports = {
    generateImage,
    getGenerationStatus,
    getGallery,
    getUserImages,
    getImageDetails,
    updateImage,
    deleteImage
};
