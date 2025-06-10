/**
 * 数据库初始化脚本
 * 
 * 此脚本用于创建AI文生图应用所需的数据库表
 * 连接信息来自环境变量或配置文件
 */

const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();

// 从配置文件获取数据库连接信息
const dbConfig = require('./config/database').database;

// 确保数据库连接配置有效
const dbConnConfig = {
    host: process.env.DB_HOST || dbConfig.host,
    port: parseInt(process.env.DB_PORT || dbConfig.port),
    user: process.env.DB_USER || dbConfig.user,
    password: process.env.DB_PASSWORD || dbConfig.password,
    database: process.env.DB_NAME || dbConfig.database,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
};

async function initDatabase() {
    console.log('开始初始化数据库...');

    let connection;
    try {
        // 建立数据库连接
        connection = await mysql.createConnection({
            host: dbConfig.host,
            port: dbConfig.port,
            user: dbConfig.user,
            password: dbConfig.password,
        });

        // 确保数据库存在
        await connection.query(`CREATE DATABASE IF NOT EXISTS ${dbConfig.database} 
                          CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`);
        console.log(`数据库 ${dbConfig.database} 已创建或已存在`);

        // 使用指定的数据库
        await connection.query(`USE ${dbConfig.database}`);

        // 读取SQL文件
        const sqlFilePath = path.join(__dirname, 'database_setup.sql');
        const sqlScript = fs.readFileSync(sqlFilePath, 'utf8');

        // 按语句拆分SQL文件（以分号结尾的为一条语句）
        const statements = sqlScript.split(';').filter(stmt => stmt.trim());

        // 执行各SQL语句
        for (const statement of statements) {
            if (statement.trim()) {
                await connection.query(statement);
            }
        }

        console.log('数据库表创建完成');

        // 添加一个管理员用户（可选）
        const adminExists = await connection.query(
            'SELECT * FROM users WHERE username = ?',
            ['admin']
        );

        if (adminExists[0].length === 0) {
            // 使用bcrypt加密密码 - 这里简化处理，实际应用中应该使用bcrypt
            const bcrypt = require('bcrypt');
            const hashedPassword = await bcrypt.hash('admin123', 10);

            await connection.query(
                'INSERT INTO users (id, username, password, email, nickname, bio) VALUES (?, ?, ?, ?, ?, ?)',
                [
                    uuidv4(),
                    'admin',
                    hashedPassword,
                    'admin@example.com',
                    '系统管理员',
                    '系统管理员账号'
                ]
            );
            console.log('默认管理员账号已创建');
        }

        console.log('数据库初始化完成');

    } catch (error) {
        console.error('数据库初始化失败:', error);
    } finally {
        if (connection) {
            await connection.end();
            console.log('数据库连接已关闭');
        }
    }
}

// 执行初始化函数
initDatabase();
