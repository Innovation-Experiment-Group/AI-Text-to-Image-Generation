const express = require('express');
const router = express.Router();
const { register, login } = require('../controllers/auth.controller');

// 用户注册
router.post('/register', register);

// 用户登录
router.post('/login', login);

module.exports = router;
