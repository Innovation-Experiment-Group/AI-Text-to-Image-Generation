const express = require('express');
const router = express.Router();
const { deleteComment } = require('../controllers/comment.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// 删除评论
router.delete('/:commentId', authenticate, deleteComment);

module.exports = router;
