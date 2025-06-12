import 'package:flutter/material.dart';

class ImagePromptInput extends StatelessWidget {
  final TextEditingController promptController;
  final TextEditingController? negativeController;
  final bool isPublic;
  final void Function(bool)? onTogglePublic;

  const ImagePromptInput({
    super.key,
    required this.promptController,
    this.negativeController,
    required this.isPublic,
    this.onTogglePublic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "图像描述（Prompt）",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: promptController,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "请输入图像描述...",
          ),
        ),
        const SizedBox(height: 12),
        if (negativeController != null) ...[
          const Text(
            "排除元素（Negative Prompt）",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: negativeController,
            maxLines: 2,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "不希望图像中出现的内容...",
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            const Text("是否公开:"),
            const SizedBox(width: 8),
            Switch(value: isPublic, onChanged: onTogglePublic),
          ],
        ),
      ],
    );
  }
}
