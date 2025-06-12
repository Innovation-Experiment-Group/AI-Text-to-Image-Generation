/**
 * 数据库配置文件
 */
require('dotenv').config();

module.exports = {
    // 数据库连接配置
    database: {
        host: process.env.DB_HOST || 'mysql2.sqlpub.com',
        port: process.env.DB_PORT || 3307,
        user: process.env.DB_USER || 'dev_ai',
        password: process.env.DB_PASSWORD || 'HyzVB8O7mQ1AN3Vk',
        database: process.env.DB_NAME || 'ai_text2img',
        waitForConnections: true,
        connectionLimit: 10,
        queueLimit: 0,
    },

    // 数据库连接URI (用于某些ORM框架)
    getDatabaseURI: function () {
        return `mysql://${this.database.user}:${this.database.password}@${this.database.host}:${this.database.port}/${this.database.database}`;
    }
};
