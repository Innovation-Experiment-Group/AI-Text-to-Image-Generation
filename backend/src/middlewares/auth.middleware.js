const jwt = require('jsonwebtoken');
const { ApiError } = require('../utils/error');
const { createPool } = require('../config/db');

// 创建数据库连接池
const pool = createPool();

/**
 * JWT认证中间件
 */
const authenticate = async (req, res, next) => {
    try {
        // 检查Authorization头
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            throw new ApiError('未提供认证令牌', 401);
        }

        // 获取token
        const token = authHeader.split(' ')[1];
        if (!token) {
            throw new ApiError('未提供有效的认证令牌', 401);
        }

        // 验证token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        if (!decoded) {
            throw new ApiError('无效的认证令牌', 401);
        }

        // 获取用户信息
        const [rows] = await pool.execute(
            'SELECT id, username, email, nickname, avatarUrl, bio FROM users WHERE id = ?',
            [decoded.id]
        );

        if (rows.length === 0) {
            throw new ApiError('用户不存在', 401);
        }

        // 将用户信息添加到请求对象
        req.user = rows[0];
        next();
    } catch (error) {
        if (error.name === 'JsonWebTokenError') {
            return next(new ApiError('无效的认证令牌', 401));
        }
        if (error.name === 'TokenExpiredError') {
            return next(new ApiError('认证令牌已过期', 401));
        }
        next(error);
    }
};

/**
 * 可选的JWT认证中间件
 * 如果有token则验证并设置req.user，没有则继续
 */
const optionalAuthenticate = async (req, res, next) => {
    try {
        // 检查Authorization头
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return next(); // 没有token，直接继续
        }

        // 获取token
        const token = authHeader.split(' ')[1];
        if (!token) {
            return next(); // 没有token，直接继续
        }

        // 验证token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        if (!decoded) {
            return next(); // token无效，直接继续
        }

        // 获取用户信息
        const [rows] = await pool.execute(
            'SELECT id, username, email, nickname, avatarUrl, bio FROM users WHERE id = ?',
            [decoded.id]
        );

        if (rows.length > 0) {
            // 将用户信息添加到请求对象
            req.user = rows[0];
        }

        next();
    } catch (error) {
        // 任何错误直接继续，不设置用户信息
        next();
    }
};

module.exports = {
    authenticate,
    optionalAuthenticate
};
