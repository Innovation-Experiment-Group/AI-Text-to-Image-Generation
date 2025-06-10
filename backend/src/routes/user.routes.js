const express = require('express');
const router = express.Router();
const {
    getUserProfile,
    updateUserProfile,
    uploadAvatar
} = require('../controllers/user.controller');
const { authenticate } = require('../middlewares/auth.middleware');
const { avatarUpload } = require('../middlewares/upload.middleware');

// 获取用户信息
router.get('/profile', authenticate, getUserProfile);

// 更新用户信息
router.put('/profile', authenticate, updateUserProfile);

// 上传用户头像
router.post('/avatar', authenticate, avatarUpload.single('avatar'), uploadAvatar);

module.exports = router;
