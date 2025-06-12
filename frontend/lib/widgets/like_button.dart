import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final bool liked;
  final int count;
  final VoidCallback onTap;

  const LikeButton({
    super.key,
    required this.liked,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            liked ? Icons.favorite : Icons.favorite_border,
            color: liked ? Colors.red : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text('$count'),
        ],
      ),
    );
  }
}
