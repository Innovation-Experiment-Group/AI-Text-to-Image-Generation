// lib/models/image_item.dart (URL处理优化版)

import 'user.dart';

class ImageItem {
  final String imageId;
  final String imageUrl;
  final String thumbnailUrl;
  final String prompt;
  final String? negativePrompt;
  final String? style;
  final int? width;
  final int? height;
  final int? samplingSteps;
  final bool isPublic;
  final DateTime createdAt;
  int? likes;
  final int? commentCount;
  final User? user;
  final bool liked;

  ImageItem({
    required this.imageId,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.prompt,
    this.negativePrompt,
    this.style,
    this.width,
    this.height,
    this.samplingSteps,
    required this.isPublic,
    required this.createdAt,
    this.likes,
    this.commentCount,
    this.user,
    this.liked = false,
  });

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      // --- 这是修复后的代码 ---
      // 如果后端返回的URL为null，则统一使用空字符串''作为默认值
      imageId: json['imageId'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      thumbnailUrl:
          json['thumbnailUrl'] as String? ?? json['imageUrl'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '无提示词',

      negativePrompt: json['negativePrompt'] as String?,
      style: json['style'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      samplingSteps: json['samplingSteps'] as int?,
      likes: json['likes'] as int?,
      commentCount: json['commentCount'] as int?,

      isPublic: json['isPublic'] is bool ? json['isPublic'] : true,
      liked: json['liked'] is bool ? json['liked'] : false,

      createdAt:
          json['createdAt'] != null
              ? (DateTime.tryParse(json['createdAt'].toString()) ??
                  DateTime.now())
              : DateTime.now(),

      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  // copyWith 方法保持不变
  ImageItem copyWith({
    String? imageId,
    String? imageUrl,
    String? thumbnailUrl,
    String? prompt,
    String? negativePrompt,
    String? style,
    int? width,
    int? height,
    int? samplingSteps,
    bool? isPublic,
    DateTime? createdAt,
    int? likes,
    int? commentCount,
    User? user,
    bool? liked,
  }) {
    return ImageItem(
      imageId: imageId ?? this.imageId,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      prompt: prompt ?? this.prompt,
      negativePrompt: negativePrompt ?? this.negativePrompt,
      style: style ?? this.style,
      width: width ?? this.width,
      height: height ?? this.height,
      samplingSteps: samplingSteps ?? this.samplingSteps,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      user: user ?? this.user,
      liked: liked ?? this.liked,
    );
  }
}
