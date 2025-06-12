const express = require('express');
const router = express.Router();
const {
    generateImage,
    getGenerationStatus,
    getGallery,
    getUserImages,
    getImageDetails,
    updateImage,
    deleteImage
} = require('../controllers/image.controller');
const {
    addComment,
    getImageComments
} = require('../controllers/comment.controller');
const {
    toggleLike,
    getLikeStatus
} = require('../controllers/like.controller');
const { authenticate, optionalAuthenticate } = require('../middlewares/auth.middleware');

// 生成图片
router.post('/generate', authenticate, generateImage);

// 获取生成任务状态
router.get('/status/:taskId', authenticate, getGenerationStatus);

// 获取公开图片列表（画廊）
router.get('/gallery', getGallery);

// 获取用户图片列表
router.get('/user', authenticate, getUserImages);

// 获取图片详情
router.get('/:imageId', optionalAuthenticate, getImageDetails);

// 更新图片设置
router.put('/:imageId', authenticate, updateImage);

// 删除图片
router.delete('/:imageId', authenticate, deleteImage);

// 添加评论
router.post('/:imageId/comments', authenticate, addComment);

// 获取图片评论
router.get('/:imageId/comments', optionalAuthenticate, getImageComments);

// 点赞/取消点赞图片
router.post('/:imageId/like', authenticate, toggleLike);

// 获取点赞状态
router.get('/:imageId/like', authenticate, getLikeStatus);

module.exports = router;
