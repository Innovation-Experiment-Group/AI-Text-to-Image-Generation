/**
 * 阿里云百炼API服务
 * 提供调用阿里云百炼文生图API的功能
 */
const axios = require('axios');
require('dotenv').config();

// API基础配置
const API_BASE_URL = 'https://dashscope.aliyuncs.com/api/v1';
const API_KEY = process.env.DASHSCOPE_API_KEY || 'sk-5f6ce7528dad451c96371ab2b581e458';
const DEFAULT_MODEL = process.env.DEFAULT_MODEL || 'wanx2.1-t2i-turbo';

/**
 * 创建文生图任务
 * @param {string} prompt - 正向提示词
 * @param {string} negativePrompt - 反向提示词(可选)
 * @param {object} options - 其他选项
 * @returns {Promise<object>} - 返回任务ID和状态
 */
const createImageTask = async (prompt, negativePrompt = '', options = {}) => {
    try {
        // 设置默认参数
        const size = options.size || '1024*1024';
        const n = options.n || 1;
        const seed = options.seed;
        const promptExtend = options.promptExtend !== false; // 默认开启
        const watermark = options.watermark || false;

        // 构建请求体
        const requestBody = {
            model: DEFAULT_MODEL,
            input: {
                prompt: prompt,
                negative_prompt: negativePrompt
            },
            parameters: {
                size: size,
                n: n,
                prompt_extend: promptExtend,
                watermark: watermark
            }
        };

        // 如果提供了seed，添加到请求参数
        if (seed !== undefined) {
            requestBody.parameters.seed = seed;
        }

        // 发送请求创建任务
        const response = await axios({
            method: 'POST',
            url: `${API_BASE_URL}/services/aigc/text2image/image-synthesis`,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${API_KEY}`,
                'X-DashScope-Async': 'enable'
            },
            data: requestBody
        });

        return response.data;
    } catch (error) {
        console.error('创建文生图任务失败:', error.response ? error.response.data : error.message);
        throw error;
    }
};

/**
 * 查询文生图任务状态和结果
 * @param {string} taskId - 任务ID
 * @returns {Promise<object>} - 返回任务状态和结果(如果成功)
 */
const getImageTaskResult = async (taskId) => {
    try {
        // 发送请求获取任务结果
        const response = await axios({
            method: 'GET',
            url: `${API_BASE_URL}/tasks/${taskId}`,
            headers: {
                'Authorization': `Bearer ${API_KEY}`
            }
        });

        return response.data;
    } catch (error) {
        console.error('查询文生图任务失败:', error.response ? error.response.data : error.message);
        throw error;
    }
};

/**
 * 下载生成的图片
 * @param {string} imageUrl - 图片URL
 * @returns {Promise<Buffer>} - 返回图片数据
 */
const downloadGeneratedImage = async (imageUrl) => {
    try {
        const response = await axios({
            method: 'GET',
            url: imageUrl,
            responseType: 'arraybuffer'
        });

        return response.data;
    } catch (error) {
        console.error('下载生成的图片失败:', error.message);
        throw error;
    }
};

module.exports = {
    createImageTask,
    getImageTaskResult,
    downloadGeneratedImage
};
