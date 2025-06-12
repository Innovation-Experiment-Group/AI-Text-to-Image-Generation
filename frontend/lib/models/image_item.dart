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
  final int? likes;
  final int? commentCount;
  final User? user;

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
    );
  }
}
