const mysql = require('mysql2/promise');
const dbConfig = require('../../config/database');

// 创建连接池
const createPool = () => {
    return mysql.createPool({
        host: dbConfig.database.host,
        port: dbConfig.database.port,
        user: dbConfig.database.user,
        password: dbConfig.database.password,
        database: dbConfig.database.database,
        waitForConnections: true,
        connectionLimit: 10,
        queueLimit: 0
    });
};

// 导出连接池
module.exports = {
    createPool
};
