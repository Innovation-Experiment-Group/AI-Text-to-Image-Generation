import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../utils/date_utils.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;

  const CommentTile({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(comment.user.avatarUrl ?? ''),
      ),
      title: Text(comment.user.nickname ?? '用户'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment.content),
          const SizedBox(height: 4),
          Text(
            DateUtilsHelper.timeAgo(comment.createdAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
