import '../services/api_service.dart';
import '../utils/constants.dart';
import '../models/comment.dart';

class CommentService {
  /// 获取某图片的评论列表，返回 List<Comment>
  static Future<List<Comment>> getComments(
    String imageId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final res = await ApiService.get(
      '/images/$imageId/comments?page=$page&pageSize=$pageSize',
    );

    if (res.containsKey('data')) {
      final List<dynamic> list = res['data'];
      return list.map((e) => Comment.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  /// 发布评论，返回 Comment 对象
  static Future<Comment> addComment(String imageId, String content) async {
    final data = {'content': content};
    final res = await ApiService.post('/images/$imageId/comments', data);
    if (res.containsKey('data')) {
      return Comment.fromJson(res['data']);
    } else {
      throw Exception('发布评论失败，返回数据格式错误');
    }
  }

  /// 删除评论
  static Future<void> deleteComment(String imageId, String commentId) async {
    final res = await ApiService.delete('/images/$imageId/comments/$commentId');
    if (res.containsKey('success') && res['success'] == true) {
      return;
    } else {
      throw Exception('删除评论失败');
    }
  }
}
