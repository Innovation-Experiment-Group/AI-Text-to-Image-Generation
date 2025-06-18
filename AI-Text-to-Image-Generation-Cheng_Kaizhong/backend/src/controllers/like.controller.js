const { v4: uuidv4 } = require('uuid');
const { createPool } = require('../config/db');
const { ApiError, catchAsync } = require('../utils/error');

// 创建数据库连接池
const pool = createPool();

/**
 * 点赞/取消点赞图片
 */
const toggleLike = catchAsync(async (req, res, next) => {
    const { imageId } = req.params;
    const userId = req.user.id;

    // 检查图片是否存在
    const [images] = await pool.execute(
        'SELECT id, isPublic, userId FROM images WHERE id = ?',
        [imageId]
    );

    if (images.length === 0) {
        return next(new ApiError('图片不存在', 404));
    }

    // 检查是否有权限点赞（公开图片或用户自己的图片）
    const image = images[0];
    if (!image.isPublic && image.userId !== userId) {
        return next(new ApiError('没有权限点赞此图片', 403));
    }

    // 检查是否已点赞
    const [existingLikes] = await pool.execute(
        'SELECT id FROM likes WHERE imageId = ? AND userId = ?',
        [imageId, userId]
    );

    let liked;

    if (existingLikes.length > 0) {
        // 如果已点赞，则取消点赞
        await pool.execute(
            'DELETE FROM likes WHERE imageId = ? AND userId = ?',
            [imageId, userId]
        );
        liked = false;
    } else {
        // 如果未点赞，则添加点赞
        const likeId = uuidv4();
        await pool.execute(
            'INSERT INTO likes (id, imageId, userId, createdAt) VALUES (?, ?, ?, NOW())',
            [likeId, imageId, userId]
        );
        liked = true;
    }

    // 获取最新点赞数
    const [likesCount] = await pool.execute(
        'SELECT COUNT(*) AS count FROM likes WHERE imageId = ?',
        [imageId]
    );

    res.status(200).json({
        status: 'success',
        data: {
            liked,
            likesCount: likesCount[0].count
        }
    });
});

/**
 * 获取图片点赞状态
 */
const getLikeStatus = catchAsync(async (req, res, next) => {
    const { imageId } = req.params;
    const userId = req.user.id;

    // 检查图片是否存在
    const [images] = await pool.execute(
        'SELECT id FROM images WHERE id = ?',
        [imageId]
    );

    if (images.length === 0) {
        return next(new ApiError('图片不存在', 404));
    }

    // 检查是否已点赞
    const [existingLikes] = await pool.execute(
        'SELECT id FROM likes WHERE imageId = ? AND userId = ?',
        [imageId, userId]
    );

    // 获取总点赞数
    const [likesCount] = await pool.execute(
        'SELECT COUNT(*) AS count FROM likes WHERE imageId = ?',
        [imageId]
    );

    res.status(200).json({
        status: 'success',
        data: {
            liked: existingLikes.length > 0,
            likesCount: likesCount[0].count
        }
    });
});

module.exports = {
    toggleLike,
    getLikeStatus
};
