import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';

class CommentProvider with ChangeNotifier {
  List<Comment> _comments = [];
  bool _loading = false;

  List<Comment> get comments => _comments;
  bool get isLoading => _loading;

  Future<void> fetchComments(String imageId) async {
    _loading = true;
    notifyListeners();
    try {
      _comments = await CommentService.getComments(imageId);
    } catch (_) {
      _comments = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addComment(String imageId, String content, String token) async {
    try {
      final comment = await CommentService.addComment(
        imageId: imageId,
        content: content,
        token: token,
      );
      _comments.insert(0, comment);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> deleteComment(String commentId, String token) async {
    try {
      await CommentService.deleteComment(commentId, token);
      _comments.removeWhere((c) => c.commentId == commentId);
      notifyListeners();
    } catch (_) {}
  }
}
