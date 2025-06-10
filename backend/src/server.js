const app = require('./app');
const { createPool } = require('./config/db');

const PORT = process.env.PORT || 3000;

// 启动前确认数据库连接
async function startServer() {
    try {
        // 测试数据库连接
        const pool = createPool();
        const connection = await pool.getConnection();
        console.log('数据库连接成功');
        connection.release();

        // 启动服务器
        app.listen(PORT, () => {
            console.log(`服务器运行在 http://localhost:${PORT}/api`);
        });
    } catch (error) {
        console.error('无法连接到数据库:', error.message);
        process.exit(1);
    }
}

startServer();
