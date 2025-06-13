const { v4: uuidv4 } = require('uuid');
const { createPool } = require('../config/db');
const { ApiError, catchAsync } = require('../utils/error');

// 创建数据库连接池
const pool = createPool();

/**
 * 添加评论
 */
const addComment = catchAsync(async (req, res, next) => {
    const { imageId } = req.params;
    const userId = req.user.id;
    const { content } = req.body;

    // 验证必填字段
    if (!content) {
        return next(new ApiError('评论内容是必填字段', 400));
    }

    // 检查图片是否存在
    const [images] = await pool.execute(
        'SELECT id, isPublic, userId FROM images WHERE id = ?',
        [imageId]
    );

    if (images.length === 0) {
        return next(new ApiError('图片不存在', 404));
    }

    // 检查是否有权限评论（公开图片或用户自己的图片）
    const image = images[0];
    if (!image.isPublic && image.userId !== userId) {
        return next(new ApiError('没有权限评论此图片', 403));
    }

    // 创建评论
    const commentId = uuidv4();

    await pool.execute(
        'INSERT INTO comments (id, imageId, userId, content, createdAt) VALUES (?, ?, ?, ?, NOW())',
        [commentId, imageId, userId, content]
    );

    // 获取用户信息
    const [users] = await pool.execute(
        'SELECT id, nickname, avatarUrl FROM users WHERE id = ?',
        [userId]
    );

    res.status(201).json({
        status: 'success',
        data: {
            commentId,
            content,
            createdAt: new Date(),
            imageId,
            user: {
                userId: users[0].id,
                nickname: users[0].nickname,
                avatarUrl: users[0].avatarUrl
            }
        }
    });
});

/**
 * 获取图片评论
 */
const getImageComments = catchAsync(async (req, res, next) => {
    const { imageId } = req.params;

    // 获取查询参数
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;

    // 检查图片是否存在
    const [images] = await pool.execute(
        'SELECT id, isPublic, userId FROM images WHERE id = ?',
        [imageId]
    );

    if (images.length === 0) {
        return next(new ApiError('图片不存在', 404));
    }

    // 检查是否有权限查看评论（公开图片或用户自己的图片）
    const image = images[0];
    if (!image.isPublic && (!req.user || image.userId !== req.user.id)) {
        return next(new ApiError('没有权限查看此图片的评论', 403));
    }

    // 查询图片评论
    const [comments] = await pool.execute(
        `SELECT
            id AS commentId,
            content,
            createdAt,
            userId
        FROM
            comments
        WHERE
            imageId = ?`,
        [imageId]
    );

    // 获取总数量
    const [totalResult] = await pool.execute(
        'SELECT COUNT(*) AS total FROM comments WHERE imageId = ?',
        [imageId]
    );
    const total = totalResult[0].total;

    // 格式化返回数据
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

    res.status(200).json({
        status: 'success',
        data: {
            comments: formattedComments,
            pagination: {
                total,
                page,
                limit,
                pages: Math.ceil(total / limit)
            }
        }
    });
});

/**
 * 删除评论
 */
const deleteComment = catchAsync(async (req, res, next) => {
    const { commentId } = req.params;
    const userId = req.user.id;

    // 获取评论信息
    const [comments] = await pool.execute(
        'SELECT c.id, c.userId, c.imageId, i.userId AS imageOwnerId FROM comments c JOIN images i ON c.imageId = i.id WHERE c.id = ?',
        [commentId]
    );

    if (comments.length === 0) {
        return next(new ApiError('评论不存在', 404));
    }

    const comment = comments[0];

    // 检查权限（评论作者或图片拥有者可以删除评论）
    if (comment.userId !== userId && comment.imageOwnerId !== userId) {
        return next(new ApiError('没有权限删除此评论', 403));
    }

    // 删除评论
    await pool.execute('DELETE FROM comments WHERE id = ?', [commentId]);

    res.status(200).json({
        status: 'success',
        message: '评论已成功删除'
    });
});

module.exports = {
    addComment,
    getImageComments,
    deleteComment
};
