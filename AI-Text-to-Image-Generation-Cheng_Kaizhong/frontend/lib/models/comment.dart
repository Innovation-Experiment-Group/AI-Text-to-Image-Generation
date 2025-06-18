import 'user.dart';

class Comment {
  final String commentId;
  final String content;
  final DateTime createdAt;
  final User user;

  Comment({
    required this.commentId,
    required this.content,
    required this.createdAt,
    required this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['commentId'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      user: User.fromJson(json['user']),
    );
  }
}
