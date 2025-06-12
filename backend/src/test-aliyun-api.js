const axios = require('axios');
require('dotenv').config();

const API_KEY = process.env.DASHSCOPE_API_KEY || 'sk-5f6ce7528dad451c96371ab2b581e458';
const API_URL = 'https://dashscope.aliyuncs.com/api/v1/services/aigc/text2image/image-synthesis';

// 测试创建图片生成任务
async function testCreateImageTask() {
    try {
        console.log('正在创建图片生成任务...');
        const response = await axios({
            method: 'POST',
            url: API_URL,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${API_KEY}`,
                'X-DashScope-Async': 'enable'
            },
            data: {
                model: 'wanx2.1-t2i-turbo',
                input: {
                    prompt: '一座中国风的美丽小桥，周围有樱花树，春天，阳光明媚',
                    negative_prompt: '人物'
                },
                parameters: {
                    size: '512*512',
                    n: 1,
                    prompt_extend: true,
                    watermark: false
                }
            }
        });

        console.log('任务创建成功:', response.data);
        return response.data.output.task_id;
    } catch (error) {
        console.error('任务创建失败:', error.response ? error.response.data : error.message);
        throw error;
    }
}

// 测试查询任务状态
async function testCheckTaskStatus(taskId) {
    try {
        console.log(`\n正在查询任务(${taskId})状态...`);
        const response = await axios({
            method: 'GET',
            url: `https://dashscope.aliyuncs.com/api/v1/tasks/${taskId}`,
            headers: {
                'Authorization': `Bearer ${API_KEY}`
            }
        });

        console.log('任务状态:', response.data.output.task_status);
        console.log('详细信息:', JSON.stringify(response.data, null, 2));
        return response.data;
    } catch (error) {
        console.error('查询任务状态失败:', error.response ? error.response.data : error.message);
        throw error;
    }
}

// 运行测试
async function runTest() {
    try {
        // 1. 创建任务
        const taskId = await testCreateImageTask();

        // 2. 等待5秒
        console.log('等待5秒...');
        await new Promise(resolve => setTimeout(resolve, 5000));

        // 3. 检查任务状态
        const result = await testCheckTaskStatus(taskId);

        // 4. 如果任务还在进行中，再等待30秒后再次检查
        if (result.output.task_status === 'PENDING' || result.output.task_status === 'RUNNING') {
            console.log('\n任务仍在进行中，等待30秒后再次检查...');
            await new Promise(resolve => setTimeout(resolve, 30000));
            await testCheckTaskStatus(taskId);
        }
    } catch (error) {
        console.error('测试失败:', error);
    }
}

runTest();
