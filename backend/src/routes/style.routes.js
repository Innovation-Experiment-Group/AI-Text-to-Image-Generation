const express = require('express');
const router = express.Router();

// 图片生成风格数据
const imageStyles = [
    {
        styleId: 'realistic',
        name: '写实风格',
        description: '生成逼真的照片级图像',
        previewUrl: '/uploads/styles/realistic.jpg'
    },
    {
        styleId: 'cartoon',
        name: '卡通风格',
        description: '生成卡通风格的图像',
        previewUrl: '/uploads/styles/cartoon.jpg'
    },
    {
        styleId: 'anime',
        name: '动漫风格',
        description: '生成日本动漫风格的图像',
        previewUrl: '/uploads/styles/anime.jpg'
    },
    {
        styleId: 'painting',
        name: '艺术绘画',
        description: '生成艺术绘画风格的图像',
        previewUrl: '/uploads/styles/painting.jpg'
    },
    {
        styleId: '3d-render',
        name: '3D渲染',
        description: '生成3D渲染风格的图像',
        previewUrl: '/uploads/styles/3d-render.jpg'
    }
];

// 获取可用风格列表
router.get('/', (req, res) => {
    res.status(200).json({
        status: 'success',
        data: imageStyles
    });
});

module.exports = router;
