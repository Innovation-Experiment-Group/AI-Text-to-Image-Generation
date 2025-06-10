const { v4: uuidv4 } = require('uuid');
const fs = require('fs').promises;
const path = require('path');
const { createPool } = require('../config/db');
const { ApiError, catchAsync } = require('../utils/error');
const { createImageTask, getImageTaskResult, downloadGeneratedImage } = require('../services/dashscope.service');
const { saveGeneratedImage } = require('../services/image.service');

// 创建数据库连接池
const pool = createPool();

// 模拟图片生成任务队列，实际项目中应使用Redis或其他消息队列
const taskQueue = new Map();

// 确定是否使用AI服务
const useAiService = process.env.USE_AI_SERVICE === 'true';

/**
 * 生成图片
 */
const generateImage = catchAsync(async (req, res, next) => {
    const {
        prompt,
        negativePrompt,
        style,
        isPublic = true,
        width = process.env.DEFAULT_IMAGE_WIDTH || 512,
        height = process.env.DEFAULT_IMAGE_HEIGHT || 512,
        samplingSteps = process.env.DEFAULT_SAMPLING_STEPS || 30
    } = req.body;

    // 验证必填字段
    if (!prompt) {
        return next(new ApiError('文本描述是必填字段', 400));
    }

    const userId = req.user.id;
    const taskId = uuidv4();

    // 创建任务
    taskQueue.set(taskId, {
        userId,
        status: 'pending',
        progress: 0,
        prompt,
        negativePrompt,
        style,
        isPublic,
        width,
        height,
        samplingSteps,
        createdAt: new Date()
    });    // 异步图片生成过程
    setTimeout(async () => {
        try {
            // 更新任务状态为处理中
            taskQueue.set(taskId, {
                ...taskQueue.get(taskId),
                status: 'processing',
                progress: 20
            });

            let imageId, imageUrl, thumbnailUrl;

            if (useAiService) {
                // 调用阿里云百炼API生成图片
                try {
                    // 1. 创建生成任务并获取任务ID
                    const sizeStr = `${width}*${height}`;
                    const createResponse = await createImageTask(
                        prompt,
                        negativePrompt || '',
                        {
                            size: sizeStr,
                            n: 1,
                            promptExtend: true,
                            watermark: false
                        }
                    );

                    // 检查任务创建是否成功
                    if (createResponse.output && createResponse.output.task_id) {
                        const aiTaskId = createResponse.output.task_id;

                        // 更新任务进度
                        taskQueue.set(taskId, {
                            ...taskQueue.get(taskId),
                            progress: 30,
                            aiTaskId
                        });

                        // 2. 定期检查任务状态直到完成或失败
                        let taskCompleted = false;
                        let retryCount = 0;
                        const maxRetries = 30; // 最多检查30次，约2.5分钟
                        const checkInterval = parseInt(process.env.AI_TASK_CHECK_INTERVAL) || 5000; // 默认5秒检查一次

                        while (!taskCompleted && retryCount < maxRetries) {
                            await new Promise(resolve => setTimeout(resolve, checkInterval));

                            // 检查任务状态
                            const taskResult = await getImageTaskResult(aiTaskId);

                            if (taskResult.output && taskResult.output.task_status === 'SUCCEEDED') {
                                // 任务成功完成
                                const imageResults = taskResult.output.results;
                                if (imageResults && imageResults.length > 0 && imageResults[0].url) {
                                    // 3. 下载生成的图片
                                    const imageData = await downloadGeneratedImage(imageResults[0].url);

                                    // 4. 保存图片到本地
                                    const savedImage = await saveGeneratedImage(imageData, userId);
                                    imageId = savedImage.imageId;
                                    imageUrl = savedImage.imageUrl;
                                    thumbnailUrl = savedImage.thumbnailUrl;

                                    taskCompleted = true;

                                    // 更新任务进度
                                    taskQueue.set(taskId, {
                                        ...taskQueue.get(taskId),
                                        progress: 90
                                    });
                                } else {
                                    throw new Error('未找到生成的图片URL');
                                }
                            } else if (taskResult.output && taskResult.output.task_status === 'FAILED') {
                                // 任务失败
                                throw new Error(taskResult.output.message || '图片生成任务失败');
                            }

                            // 更新任务进度(基于已等待的时间)
                            const progressIncrement = 50 / maxRetries;
                            const newProgress = Math.min(80, 30 + (retryCount * progressIncrement));
                            taskQueue.set(taskId, {
                                ...taskQueue.get(taskId),
                                progress: newProgress
                            });

                            retryCount++;
                        }

                        if (!taskCompleted) {
                            throw new Error('图片生成任务超时');
                        }
                    } else {
                        throw new Error('创建图片生成任务失败');
                    }
                } catch (aiError) {
                    console.error('AI图片生成失败:', aiError);
                    taskQueue.set(taskId, {
                        ...taskQueue.get(taskId),
                        status: 'failed',
                        error: aiError.message || 'AI图片生成失败'
                    });
                    return; // 提前退出
                }
            } else {
                // 使用模拟进度
                await new Promise(resolve => setTimeout(resolve, 2000));
                taskQueue.set(taskId, {
                    ...taskQueue.get(taskId),
                    progress: 50
                });

                await new Promise(resolve => setTimeout(resolve, 2000));
                taskQueue.set(taskId, {
                    ...taskQueue.get(taskId),
                    progress: 80
                });

                // 在模拟模式下创建图片ID和路径
                imageId = uuidv4();
                const imageName = `image_${imageId}.png`;
                imageUrl = `/uploads/images/${imageName}`;
                thumbnailUrl = `/uploads/images/thumb_${imageName}`;
            }

            // 保存图片记录到数据库
            try {
                await pool.execute(
                    `INSERT INTO images (id, userId, prompt, negativePrompt, style, imageUrl, thumbnailUrl, 
                     width, height, samplingSteps, isPublic, createdAt) 
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
                    [
                        imageId,
                        userId,
                        prompt,
                        negativePrompt || null,
                        style || null,
                        imageUrl,
                        thumbnailUrl,
                        width,
                        height,
                        samplingSteps,
                        isPublic ? 1 : 0
                    ]
                );

                // 更新任务状态为完成
                taskQueue.set(taskId, {
                    ...taskQueue.get(taskId),
                    status: 'completed',
                    progress: 100,
                    imageId,
                    imageUrl
                });
            } catch (error) {
                console.error('保存图片记录失败:', error);
                taskQueue.set(taskId, {
                    ...taskQueue.get(taskId),
                    status: 'failed',
                    error: '保存图片记录失败'
                });
            }
        } catch (error) {
            console.error('图片生成任务失败:', error);
            taskQueue.set(taskId, {
                ...taskQueue.get(taskId),
                status: 'failed',
                error: '图片生成失败'
            });
        }
    }, 1000);

    // 返回任务ID
    res.status(202).json({
        status: 'success',
        data: {
            taskId,
            status: 'pending',
            message: '图片生成任务已提交'
        }
    });
});

/**
 * 获取生成任务状态
 */
const getGenerationStatus = catchAsync(async (req, res, next) => {
    const { taskId } = req.params;
    const userId = req.user.id;

    // 检查任务是否存在
    if (!taskQueue.has(taskId)) {
        return next(new ApiError('任务不存在', 404));
    }

    const task = taskQueue.get(taskId);

    // 验证任务所有者
    if (task.userId !== userId) {
        return next(new ApiError('没有权限访问此任务', 403));
    }

    // 根据任务状态返回不同的响应
    const { status, progress, imageId, imageUrl, error } = task;

    const response = {
        status: 'success',
        data: {
            taskId,
            status,
            progress
        }
    };

    if (status === 'completed' && imageId) {
        // 如果任务完成，返回图片信息
        const [images] = await pool.execute(
            'SELECT id, imageUrl, thumbnailUrl FROM images WHERE id = ?',
            [imageId]
        );

        if (images.length > 0) {
            response.data.imageId = images[0].id;
            response.data.imageUrl = images[0].imageUrl;
            response.data.thumbnailUrl = images[0].thumbnailUrl;

            // 任务完成且信息已返回，可以从队列中删除任务
            // 实际项目中可能需要保留一段时间用于调试
            setTimeout(() => taskQueue.delete(taskId), 3600000); // 1小时后删除
        }
    } else if (status === 'failed' && error) {
        // 如果任务失败，返回错误信息
        response.data.error = error;

        // 任务失败且信息已返回，可以从队列中删除任务
        setTimeout(() => taskQueue.delete(taskId), 3600000); // 1小时后删除
    }

    res.status(200).json(response);
});

/**
 * 获取公开图片列表（画廊）
 */
const getGallery = catchAsync(async (req, res, next) => {
    // 获取查询参数
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const sort = req.query.sort || 'newest';
    const offset = (page - 1) * limit;

    // 查询公开图片
    try {
        console.log('排序方式:', sort);

        // 使用完全硬编码的排序，避免动态SQL注入风险
        let query;
        if (sort === 'popular') {
            query = `
                SELECT 
                    i.id AS imageId, 
                    i.imageUrl, 
                    i.thumbnailUrl, 
                    i.prompt, 
                    i.createdAt, 
                    COUNT(DISTINCT l.id) AS likes, 
                    COUNT(DISTINCT c.id) AS commentCount, 
                    u.id AS userId, 
                    u.nickname, 
                    u.avatarUrl 
                FROM 
                    images i
                    LEFT JOIN likes l ON i.id = l.imageId
                    LEFT JOIN comments c ON i.id = c.imageId
                    JOIN users u ON i.userId = u.id 
                WHERE 
                    i.isPublic = 1
                GROUP BY 
                    i.id
                ORDER BY 
                    COUNT(DISTINCT l.id) DESC
                LIMIT ${limit} OFFSET ${offset}
            `;
        } else {
            // 默认按最新排序
            query = `
                SELECT 
                    i.id AS imageId, 
                    i.imageUrl, 
                    i.thumbnailUrl, 
                    i.prompt, 
                    i.createdAt, 
                    COUNT(DISTINCT l.id) AS likes, 
                    COUNT(DISTINCT c.id) AS commentCount, 
                    u.id AS userId, 
                    u.nickname, 
                    u.avatarUrl 
                FROM 
                    images i
                    LEFT JOIN likes l ON i.id = l.imageId
                    LEFT JOIN comments c ON i.id = c.imageId
                    JOIN users u ON i.userId = u.id 
                WHERE 
                    i.isPublic = 1
                GROUP BY 
                    i.id
                ORDER BY 
                    i.createdAt DESC
                LIMIT ${limit} OFFSET ${offset}
            `;
        }

        // 执行查询，直接使用字符串而不是参数化查询
        const [images] = await pool.query(query);

        // 获取总数以便于分页
        const [countResult] = await pool.execute(
            'SELECT COUNT(*) as total FROM images WHERE isPublic = 1'
        );

        const total = countResult[0].total;
        const pages = Math.ceil(total / limit);

        res.status(200).json({
            status: 'success',
            data: {
                images: images.map(img => ({
                    imageId: img.imageId,
                    imageUrl: img.imageUrl,
                    thumbnailUrl: img.thumbnailUrl,
                    prompt: img.prompt,
                    createdAt: img.createdAt,
                    likes: parseInt(img.likes) || 0,
                    commentCount: parseInt(img.commentCount) || 0,
                    user: {
                        userId: img.userId,
                        nickname: img.nickname || '',
                        avatarUrl: img.avatarUrl || ''
                    }
                })),
                pagination: {
                    total,
                    page,
                    limit,
                    pages
                }
            }
        });
    } catch (error) {
        console.error('获取图片列表错误:', error);
        return next(new ApiError('获取图片列表失败', 500));
    }
});

/**
 * 获取用户图片列表
 */
const getUserImages = catchAsync(async (req, res, next) => {
    // 获取查询参数
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const isPublicFilter = req.query.isPublic !== undefined ?
        (req.query.isPublic === 'true' ? 1 : 0) :
        null;
    const offset = (page - 1) * limit;

    // 获取当前用户ID
    const userId = req.user.id;

    try {
        // 构建查询条件
        let query = `
            SELECT 
                i.id AS imageId, 
                i.imageUrl, 
                i.thumbnailUrl, 
                i.prompt, 
                i.isPublic, 
                i.createdAt, 
                COUNT(DISTINCT l.id) AS likes, 
                COUNT(DISTINCT c.id) AS commentCount
            FROM 
                images i
                LEFT JOIN likes l ON i.id = l.imageId
                LEFT JOIN comments c ON i.id = c.imageId
            WHERE 
                i.userId = ?
        `;

        const queryParams = [userId];

        // 添加公开/私有过滤条件（如果指定）
        if (isPublicFilter !== null) {
            query += ` AND i.isPublic = ?`;
            queryParams.push(isPublicFilter);
        }

        query += `
            GROUP BY 
                i.id
            ORDER BY 
                i.createdAt DESC
            LIMIT ${limit} OFFSET ${offset}
        `;

        // 查询用户的图片列表
        const [images] = await pool.query(query, queryParams);

        // 获取总数以便于分页
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
                    imageId: img.imageId,
                    imageUrl: img.imageUrl,
                    thumbnailUrl: img.thumbnailUrl,
                    prompt: img.prompt,
                    isPublic: Boolean(img.isPublic),
                    createdAt: img.createdAt,
                    likes: parseInt(img.likes) || 0,
                    commentCount: parseInt(img.commentCount) || 0
                })),
                pagination: {
                    total,
                    page,
                    limit,
                    pages
                }
            }
        });
    } catch (error) {
        console.error('获取用户图片列表错误:', error);
        return next(new ApiError('获取用户图片列表失败', 500));
    }
});

/**
 * 获取图片详情
 */
const getImageDetails = catchAsync(async (req, res, next) => {
    const { imageId } = req.params;

    // 查询图片详情
    const [images] = await pool.execute(
        `SELECT 
      i.id AS imageId, 
      i.userId,
      i.imageUrl, 
      i.thumbnailUrl, 
      i.prompt, 
      i.negativePrompt,
      i.style,
      i.width,
      i.height,
      i.samplingSteps,
      i.isPublic,
      i.createdAt,
      u.id AS authorId,
      u.nickname,
      u.avatarUrl,
      COUNT(DISTINCT l.id) AS likesCount
     FROM 
      images i
      LEFT JOIN users u ON i.userId = u.id
      LEFT JOIN likes l ON i.id = l.imageId
     WHERE 
      i.id = ?
     GROUP BY 
      i.id`,
        [imageId]
    );

    if (images.length === 0) {
        return next(new ApiError('图片不存在', 404));
    }

    const image = images[0];

    // 检查访问权限
    if (!image.isPublic && (!req.user || req.user.id !== image.userId)) {
        return next(new ApiError('没有权限访问此图片', 403));
    }

    // 获取图片评论
    const [comments] = await pool.execute(
        `SELECT 
      c.id AS commentId, 
      c.content, 
      c.createdAt,
      u.id AS userId,
      u.nickname,
      u.avatarUrl
     FROM 
      comments c
      LEFT JOIN users u ON c.userId = u.id
     WHERE 
      c.imageId = ?
     ORDER BY 
      c.createdAt DESC`,
        [imageId]
    );

    // 格式化评论数据
    const formattedComments = comments.map(comment => ({
        commentId: comment.commentId,
        content: comment.content,
        createdAt: comment.createdAt,
        user: {
            userId: comment.userId,
            nickname: comment.nickname,
            avatarUrl: comment.avatarUrl
        }
    }));

    // 格式化返回数据
    const response = {
        imageId: image.imageId,
        imageUrl: image.imageUrl,
        thumbnailUrl: image.thumbnailUrl,
        prompt: image.prompt,
        negativePrompt: image.negativePrompt,
        style: image.style,
        width: image.width,
        height: image.height,
        samplingSteps: image.samplingSteps,
        isPublic: Boolean(image.isPublic),
        createdAt: image.createdAt,
        likes: parseInt(image.likesCount),
        user: {
            userId: image.authorId,
            nickname: image.nickname,
            avatarUrl: image.avatarUrl
        },
        comments: formattedComments
    };

    res.status(200).json({
        status: 'success',
        data: response
    });
});

/**
 * 更新图片设置
 */
const updateImage = catchAsync(async (req, res, next) => {
    const { imageId } = req.params;
    const userId = req.user.id;
    const { isPublic, prompt } = req.body;

    // 验证图片存在并属于该用户
    const [images] = await pool.execute(
        'SELECT id, userId FROM images WHERE id = ?',
        [imageId]
    );

    if (images.length === 0) {
        return next(new ApiError('图片不存在', 404));
    }

    if (images[0].userId !== userId) {
        return next(new ApiError('没有权限修改此图片', 403));
    }

    // 准备更新字段
    const updateFields = [];
    const updateValues = [];

    // 检查并添加要更新的字段
    if (isPublic !== undefined) {
        updateFields.push('isPublic = ?');
        updateValues.push(isPublic ? 1 : 0);
    }

    if (prompt !== undefined) {
        updateFields.push('prompt = ?');
        updateValues.push(prompt);
    }

    // 如果没有更新字段，则返回错误
    if (updateFields.length === 0) {
        return next(new ApiError('未提供任何要更新的信息', 400));
    }

    // 添加更新时间字段
    updateFields.push('updatedAt = NOW()');

    // 构建SQL语句
    const sql = `UPDATE images SET ${updateFields.join(', ')} WHERE id = ?`;
    updateValues.push(imageId);

    // 执行更新
    await pool.execute(sql, updateValues);

    // 获取更新后的图片信息
    const [updatedImages] = await pool.execute(
        'SELECT id, isPublic, prompt, updatedAt FROM images WHERE id = ?',
        [imageId]
    );

    res.status(200).json({
        status: 'success',
        data: {
            imageId: updatedImages[0].id,
            isPublic: Boolean(updatedImages[0].isPublic),
            prompt: updatedImages[0].prompt,
            updatedAt: updatedImages[0].updatedAt
        }
    });
});

/**
 * 删除图片
 */
const deleteImage = catchAsync(async (req, res, next) => {
    const { imageId } = req.params;
    const userId = req.user.id;

    // 验证图片存在并属于该用户
    const [images] = await pool.execute(
        'SELECT id, userId, imageUrl, thumbnailUrl FROM images WHERE id = ?',
        [imageId]
    );

    if (images.length === 0) {
        return next(new ApiError('图片不存在', 404));
    }

    if (images[0].userId !== userId) {
        return next(new ApiError('没有权限删除此图片', 403));
    }

    const image = images[0];

    // 删除数据库记录
    await pool.execute('DELETE FROM images WHERE id = ?', [imageId]);

    // 尝试删除图片文件
    try {
        if (image.imageUrl) {
            const imagePath = path.join(__dirname, '../../', image.imageUrl.replace(/^\/+/, ''));
            await fs.unlink(imagePath).catch(() => { });
        }

        if (image.thumbnailUrl) {
            const thumbPath = path.join(__dirname, '../../', image.thumbnailUrl.replace(/^\/+/, ''));
            await fs.unlink(thumbPath).catch(() => { });
        }
    } catch (error) {
        // 文件删除失败不影响API响应
        console.error('删除图片文件失败:', error);
    }

    res.status(200).json({
        status: 'success',
        message: '图片已成功删除'
    });
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
