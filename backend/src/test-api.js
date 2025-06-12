/**
 * API测试脚本
 * 这个脚本用于测试主要API端点的功能
 */

const axios = require('axios');
const fs = require('fs');
const FormData = require('form-data');
const path = require('path');

// API基础URL
const API_BASE_URL = 'http://localhost:3000/api';

// 存储认证令牌和用户ID
let authToken = '';
let userId = '';
let testImageId = '';

// 辅助函数 - 发送请求并打印结果
async function sendRequest(method, endpoint, data = null, headers = {}, isFormData = false) {
    try {
        const url = `${API_BASE_URL}${endpoint}`;
        console.log(`\n[${method.toUpperCase()}] ${url}`);

        const config = {
            method,
            url,
            headers
        };

        if (data) {
            if (isFormData) {
                config.data = data;
                config.headers = {
                    ...config.headers,
                    ...data.getHeaders()
                };
            } else {
                config.data = data;
            }
        }

        const response = await axios(config);
        console.log(`状态码: ${response.status}`);
        console.log('响应数据:', JSON.stringify(response.data, null, 2));
        return response.data;
    } catch (error) {
        console.error('请求错误:', error.response ? error.response.data : error.message);
        return null;
    }
}

// 测试用户注册
async function testRegister() {
    console.log('\n=== 测试用户注册 ===');
    const username = `user_${Date.now()}`;
    const data = {
        username,
        password: 'Password123!',
        email: `${username}@example.com`,
        nickname: '测试用户'
    };

    const response = await sendRequest('post', '/auth/register', data);
    if (response && response.token) {
        authToken = response.token;
        userId = response.data.userId;
        console.log(`认证令牌: ${authToken}`);
        console.log(`用户ID: ${userId}`);
        return true;
    }
    return false;
}

// 测试用户登录
async function testLogin() {
    console.log('\n=== 测试用户登录 ===');
    const data = {
        username: 'admin', // 使用预设管理员账号
        password: 'admin123'
    };

    const response = await sendRequest('post', '/auth/login', data);
    if (response && response.token) {
        authToken = response.token;
        userId = response.data.userId;
        console.log(`认证令牌: ${authToken}`);
        console.log(`用户ID: ${userId}`);
        return true;
    }
    return false;
}

// 测试获取用户信息
async function testGetUserProfile() {
    console.log('\n=== 测试获取用户信息 ===');
    const headers = {
        Authorization: `Bearer ${authToken}`
    };

    await sendRequest('get', '/users/profile', null, headers);
}

// 测试生成图片
async function testGenerateImage() {
    console.log('\n=== 测试生成图片 ===');
    const headers = {
        Authorization: `Bearer ${authToken}`
    };

    const data = {
        prompt: '一只可爱的小猫咪在草地上玩耍',
        style: 'cartoon',
        isPublic: true,
        width: 512,
        height: 512
    };

    const response = await sendRequest('post', '/images/generate', data, headers);
    if (response && response.data && response.data.taskId) {
        const taskId = response.data.taskId;
        console.log(`任务ID: ${taskId}`);

        // 等待3秒后检查任务状态
        await new Promise(resolve => setTimeout(resolve, 3000));

        // 检查任务状态
        console.log('\n=== 检查图片生成任务状态 ===');
        const statusResponse = await sendRequest('get', `/images/status/${taskId}`, null, headers);

        if (statusResponse && statusResponse.data && statusResponse.data.imageId) {
            testImageId = statusResponse.data.imageId;
            console.log(`生成的图片ID: ${testImageId}`);
        }

        return statusResponse;
    }
    return null;
}

// 测试获取公开图片列表
async function testGetGallery() {
    console.log('\n=== 测试获取公开图片列表 ===');
    await sendRequest('get', '/images/gallery?page=1&limit=5&sort=newest');
}

// 测试获取图片详情
async function testGetImageDetails() {
    console.log('\n=== 测试获取图片详情 ===');
    if (!testImageId) {
        console.log('没有可用的图片ID，跳过测试');
        return;
    }

    const headers = {
        Authorization: `Bearer ${authToken}`
    };

    await sendRequest('get', `/images/${testImageId}`, null, headers);
}

// 测试添加评论
async function testAddComment() {
    console.log('\n=== 测试添加评论 ===');
    if (!testImageId) {
        console.log('没有可用的图片ID，跳过测试');
        return;
    }

    const headers = {
        Authorization: `Bearer ${authToken}`
    };

    const data = {
        content: '这张图片真漂亮！'
    };

    await sendRequest('post', `/images/${testImageId}/comments`, data, headers);
}

// 测试获取风格列表
async function testGetStyles() {
    console.log('\n=== 测试获取风格列表 ===');
    await sendRequest('get', '/styles');
}

// 运行测试
async function runTests() {
    try {
        // 测试用户认证
        const isRegistered = await testRegister();
        if (!isRegistered) {
            // 如果注册失败，尝试登录
            const isLoggedIn = await testLogin();
            if (!isLoggedIn) {
                console.error('认证失败，无法继续测试');
                return;
            }
        }

        // 测试用户信息
        await testGetUserProfile();

        // 测试图片生成
        await testGenerateImage();

        // 测试获取图片列表
        await testGetGallery();

        // 测试获取图片详情
        await testGetImageDetails();

        // 测试添加评论
        await testAddComment();

        // 测试获取风格列表
        await testGetStyles();

        console.log('\n所有测试完成！');
    } catch (error) {
        console.error('测试过程中发生错误:', error);
    }
}

// 开始运行测试
runTests();
