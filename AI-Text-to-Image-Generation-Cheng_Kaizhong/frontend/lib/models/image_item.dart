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
  int? likes; // 点赞数
  final int? commentCount;
  final User? user;

  // 新增点赞状态字段
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
    this.liked = false, // 默认未点赞
  });

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      imageId: json['imageId'],
      imageUrl: json['imageUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      prompt: json['prompt'],
      negativePrompt: json['negativePrompt'],
      style: json['style'],
      width: json['width'],
      height: json['height'],
      samplingSteps: json['samplingSteps'],
      isPublic: json['isPublic'],
      createdAt: DateTime.parse(json['createdAt']),
      likes: json['likes'],
      commentCount: json['commentCount'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      liked: json['liked'] ?? false,
    );
  }

  // 复制当前对象并可选择更新部分字段
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
