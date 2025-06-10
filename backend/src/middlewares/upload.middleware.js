const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');
const { ApiError } = require('../utils/error');

// 确保上传目录存在
const ensureDir = (dirPath) => {
    if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
    }
};

// 头像上传配置
const avatarStorage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadPath = path.join(__dirname, '../../', process.env.AVATAR_UPLOAD_PATH || 'uploads/avatars');
        ensureDir(uploadPath);
        cb(null, uploadPath);
    },
    filename: (req, file, cb) => {
        // 使用用户ID + 随机UUID作为文件名，保留原始扩展名
        const fileExt = path.extname(file.originalname);
        const filename = `avatar_${req.user.id}_${uuidv4()}${fileExt}`;
        cb(null, filename);
    }
});

// 头像上传过滤器
const avatarFileFilter = (req, file, cb) => {
    // 只允许图片格式
    const allowedTypes = /jpeg|jpg|png|gif|webp/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (extname && mimetype) {
        cb(null, true);
    } else {
        cb(new ApiError('只允许上传jpg、png、gif或webp格式的图片', 400), false);
    }
};

// 图片上传限制
const avatarLimits = {
    fileSize: 5 * 1024 * 1024, // 5MB
    files: 1
};

// 头像上传中间件
const avatarUpload = multer({
    storage: avatarStorage,
    fileFilter: avatarFileFilter,
    limits: avatarLimits
});

// 生成图片存储配置
const imageStorage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadPath = path.join(__dirname, '../../', process.env.IMAGE_UPLOAD_PATH || 'uploads/images');
        ensureDir(uploadPath);
        cb(null, uploadPath);
    },
    filename: (req, file, cb) => {
        // 使用随机UUID作为文件名，保留原始扩展名
        const fileExt = path.extname(file.originalname);
        const filename = `image_${uuidv4()}${fileExt}`;
        cb(null, filename);
    }
});

// 图片上传过滤器
const imageFileFilter = (req, file, cb) => {
    // 只允许图片格式
    const allowedTypes = /jpeg|jpg|png|gif|webp/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (extname && mimetype) {
        cb(null, true);
    } else {
        cb(new ApiError('只允许上传jpg、png、gif或webp格式的图片', 400), false);
    }
};

// 图片上传限制
const imageLimits = {
    fileSize: 10 * 1024 * 1024, // 10MB
    files: 1
};

// 图片上传中间件
const imageUpload = multer({
    storage: imageStorage,
    fileFilter: imageFileFilter,
    limits: imageLimits
});

module.exports = {
    avatarUpload,
    imageUpload
};
