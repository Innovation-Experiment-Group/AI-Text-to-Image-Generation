const { v4: uuidv4 } = require('uuid');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { createPool } = require('../config/db');
const { ApiError, catchAsync } = require('../utils/error');

// 创建数据库连接池
const pool = createPool();

/**
 * 生成JWT令牌
 */
const generateToken = (userId) => {
    return jwt.sign({ id: userId }, process.env.JWT_SECRET, {
        expiresIn: process.env.JWT_EXPIRES_IN || '7d'
    });
};

/**
 * 用户注册
 */
const register = catchAsync(async (req, res, next) => {
    const { username, password, email, nickname } = req.body;

    // 验证必填字段
    if (!username || !password || !email) {
        return next(new ApiError('用户名、密码和邮箱是必填字段', 400));
    }

    // 验证用户名和邮箱是否已存在
    const [existingUsers] = await pool.execute(
        'SELECT username, email FROM users WHERE username = ? OR email = ?',
        [username, email]
    );

    if (existingUsers.length > 0) {
        const existingUser = existingUsers[0];
        if (existingUser.username === username) {
            return next(new ApiError('用户名已被注册', 400));
        }
        if (existingUser.email === email) {
            return next(new ApiError('邮箱已被注册', 400));
        }
    }

    // 密码加密
    const hashedPassword = await bcrypt.hash(password, 10);

    // 用户ID
    const userId = uuidv4();

    // 创建用户
    await pool.execute(
        'INSERT INTO users (id, username, password, email, nickname, createdAt) VALUES (?, ?, ?, ?, ?, NOW())',
        [userId, username, hashedPassword, email, nickname || username]
    );

    // 获取用户信息
    const [users] = await pool.execute(
        'SELECT id, username, email, nickname, createdAt FROM users WHERE id = ?',
        [userId]
    );

    if (users.length === 0) {
        return next(new ApiError('用户创建失败', 500));
    }

    const user = users[0];

    // 生成JWT令牌
    const token = generateToken(userId);

    // 返回用户信息和令牌
    res.status(201).json({
        status: 'success',
        data: {
            userId: user.id,
            username: user.username,
            email: user.email,
            nickname: user.nickname,
            createdAt: user.createdAt
        },
        token
    });
});

/**
 * 用户登录
 */
const login = catchAsync(async (req, res, next) => {
    const { username, password } = req.body;

    // 验证必填字段
    if (!username || !password) {
        return next(new ApiError('用户名和密码是必填字段', 400));
    }

    // 验证用户是否存在
    const [users] = await pool.execute(
        'SELECT id, username, password, email, nickname, avatarUrl FROM users WHERE username = ?',
        [username]
    );

    if (users.length === 0) {
        return next(new ApiError('用户名或密码错误', 401));
    }

    const user = users[0];

    // 验证密码
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
        return next(new ApiError('用户名或密码错误', 401));
    }

    // 更新最后登录时间
    await pool.execute(
        'UPDATE users SET lastLoginAt = NOW() WHERE id = ?',
        [user.id]
    );

    // 生成JWT令牌
    const token = generateToken(user.id);

    // 返回用户信息和令牌
    res.status(200).json({
        status: 'success',
        data: {
            userId: user.id,
            username: user.username,
            email: user.email,
            nickname: user.nickname,
            avatarUrl: user.avatarUrl
        },
        token
    });
});

module.exports = {
    register,
    login
};
