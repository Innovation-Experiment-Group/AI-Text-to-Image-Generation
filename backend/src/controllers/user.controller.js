const bcrypt = require('bcrypt');
const fs = require('fs').promises;
const path = require('path');
const { createPool } = require('../config/db');
const { ApiError, catchAsync } = require('../utils/error');

// 创建数据库连接池
const pool = createPool();

/**
 * 获取当前用户信息
 */
const getUserProfile = catchAsync(async (req, res, next) => {
    const userId = req.user.id;

    // 获取用户基本信息
    const [users] = await pool.execute(
        `SELECT id, username, email, nickname, avatarUrl, bio, createdAt, lastLoginAt 
     FROM users WHERE id = ?`,
        [userId]
    );

    if (users.length === 0) {
        return next(new ApiError('用户不存在', 404));
    }

    // 获取用户生成的图片数量
    const [imageCounts] = await pool.execute(
        'SELECT COUNT(*) as imageCount FROM images WHERE userId = ?',
        [userId]
    );

    const user = users[0];

    res.status(200).json({
        status: 'success',
        data: {
            userId: user.id,
            username: user.username,
            email: user.email,
            nickname: user.nickname,
            avatarUrl: user.avatarUrl,
            bio: user.bio,
            createdAt: user.createdAt,
            lastLoginAt: user.lastLoginAt,
            imageCount: imageCounts[0].imageCount
        }
    });
});

/**
 * 更新用户信息
 */
const updateUserProfile = catchAsync(async (req, res, next) => {
    const userId = req.user.id;
    const { nickname, email, bio, password } = req.body;

    // 准备更新字段
    const updateFields = [];
    const updateValues = [];

    // 检查并添加要更新的字段
    if (nickname !== undefined) {
        updateFields.push('nickname = ?');
        updateValues.push(nickname);
    }

    if (email !== undefined) {
        // 检查邮箱是否已被其他用户使用
        const [existingEmails] = await pool.execute(
            'SELECT id FROM users WHERE email = ? AND id != ?',
            [email, userId]
        );

        if (existingEmails.length > 0) {
            return next(new ApiError('该邮箱已被使用', 400));
        }

        updateFields.push('email = ?');
        updateValues.push(email);
    }

    if (bio !== undefined) {
        updateFields.push('bio = ?');
        updateValues.push(bio);
    }

    if (password !== undefined) {
        // 密码加密
        const hashedPassword = await bcrypt.hash(password, 10);
        updateFields.push('password = ?');
        updateValues.push(hashedPassword);
    }

    // 如果没有更新字段，则返回错误
    if (updateFields.length === 0) {
        return next(new ApiError('未提供任何要更新的信息', 400));
    }

    // 添加更新时间字段
    updateFields.push('updatedAt = NOW()');

    // 构建SQL语句
    const sql = `UPDATE users SET ${updateFields.join(', ')} WHERE id = ?`;
    updateValues.push(userId);

    // 执行更新
    await pool.execute(sql, updateValues);

    // 获取更新后的用户信息
    const [users] = await pool.execute(
        'SELECT id, username, email, nickname, bio, updatedAt FROM users WHERE id = ?',
        [userId]
    );

    if (users.length === 0) {
        return next(new ApiError('用户不存在', 404));
    }

    const user = users[0];

    res.status(200).json({
        status: 'success',
        data: {
            userId: user.id,
            username: user.username,
            email: user.email,
            nickname: user.nickname,
            bio: user.bio,
            updatedAt: user.updatedAt
        }
    });
});

/**
 * 上传用户头像
 */
const uploadAvatar = catchAsync(async (req, res, next) => {
    // 头像文件通过multer中间件传递到req.file
    if (!req.file) {
        return next(new ApiError('未上传头像文件', 400));
    }

    const userId = req.user.id;
    const avatarUrl = `/uploads/avatars/${req.file.filename}`;

    // 获取用户现有头像
    const [users] = await pool.execute(
        'SELECT avatarUrl FROM users WHERE id = ?',
        [userId]
    );

    if (users.length === 0) {
        return next(new ApiError('用户不存在', 404));
    }

    const oldAvatarUrl = users[0].avatarUrl;

    // 更新用户头像
    await pool.execute(
        'UPDATE users SET avatarUrl = ?, updatedAt = NOW() WHERE id = ?',
        [avatarUrl, userId]
    );

    // 如果有旧头像，尝试删除旧头像文件
    if (oldAvatarUrl && !oldAvatarUrl.includes('default') && oldAvatarUrl !== avatarUrl) {
        try {
            const oldAvatarPath = path.join(__dirname, '../../', oldAvatarUrl.replace(/^\/+/, ''));
            await fs.unlink(oldAvatarPath);
        } catch (error) {
            // 如果删除旧头像失败，只记录错误，不影响API响应
            console.error('删除旧头像文件失败:', error);
        }
    }

    res.status(200).json({
        status: 'success',
        data: {
            avatarUrl
        }
    });
});

module.exports = {
    getUserProfile,
    updateUserProfile,
    uploadAvatar
};
