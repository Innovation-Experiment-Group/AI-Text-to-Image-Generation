import '../models/comment.dart';
import 'api_service.dart';

class CommentService {
  static Future<List<Comment>> getComments(
    String imageId, {
    String? token,
  }) async {
    final res = await ApiService.get('/images/$imageId/comments', token: token);
    return (res['data']['comments'] as List)
        .map((e) => Comment.fromJson(e))
        .toList();
  }

  static Future<Comment> addComment({
    required String imageId,
    required String content,
    required String token,
  }) async {
    final res = await ApiService.post(
      '/images/$imageId/comments',
      token: token,
      body: {'content': content},
    );
    return Comment.fromJson(res['data']);
  }

  static Future<void> deleteComment(String commentId, String token) async {
    await ApiService.delete('/comments/$commentId', token: token);
  }
}
