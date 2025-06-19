import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';

class CommentProvider with ChangeNotifier {
  List<Comment> _comments = [];
  bool _loading = false;

  List<Comment> get comments => _comments;
  bool get isLoading => _loading;

  // 直接同步替换评论列表（用于页面初次加载）
  void setComments(List<Comment> comments) {
    _comments = comments;
    notifyListeners();
  }

  // 直接同步插入一条评论（用于发表评论后即时刷新）
  void addCommentSync(Comment comment) {
    _comments.insert(0, comment);
    notifyListeners();
  }

  // 异步加载评论（通常用于初始化或刷新）
  Future<void> fetchComments(String imageId) async {
    _loading = true;
    notifyListeners();
    try {
      _comments = await CommentService.getComments(imageId);
      notifyListeners();
    } catch (e) {
      _comments = [];
      notifyListeners();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // 异步添加评论（一般用于页面调用发表评论接口）
  Future<void> addComment(String imageId, String content) async {
    try {
      final comment = await CommentService.addComment(imageId, content);
      _comments.insert(0, comment);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // 异步删除评论
  Future<void> deleteComment(String imageId, String commentId) async {
    try {
      await CommentService.deleteComment(imageId, commentId);
      _comments.removeWhere((c) => c.commentId == commentId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
