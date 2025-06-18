import '../models/image_item.dart';
import '../services/api_service.dart';

class ImageService {
  /// 获取公开画廊图片列表
  static Future<List<ImageItem>> fetchGallery({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await ApiService.get('/images/gallery?page=$page&limit=$limit');
    final List<dynamic> list = res['data']['images'];
    return list.map((e) => ImageItem.fromJson(e)).toList();
  }

  /// 获取当前登录用户的图片列表（可选是否仅公开）
  static Future<List<ImageItem>> fetchUserImages({
    int page = 1,
    int limit = 20,
    bool? isPublic,
  }) async {
    String query = '?page=$page&limit=$limit';
    if (isPublic != null) query += '&isPublic=$isPublic';
    final res = await ApiService.get('/images/user$query');
    final List<dynamic> list = res['data']['images'];
    return list.map((e) => ImageItem.fromJson(e)).toList();
  }

  /// 获取图片详情
  static Future<ImageItem> getImageDetail(String imageId) async {
    final res = await ApiService.get('/images/$imageId');
    return ImageItem.fromJson(res['data']);
  }

  /// 生成图片
  static Future<ImageItem> generateImage({
    required String prompt,
    String? negativePrompt,
    String? style,
    bool isPublic = true,
    int width = 512,
    int height = 512,
    int samplingSteps = 30,
  }) async {
    final body = {
      'prompt': prompt,
      'negativePrompt': negativePrompt,
      'style': style,
      'isPublic': isPublic,
      'width': width,
      'height': height,
      'samplingSteps': samplingSteps,
    }..removeWhere((_, value) => value == null);

    final res = await ApiService.post('/images/generate', body);
    return ImageItem.fromJson(res['data']);
  }

  /// 删除图片
  static Future<void> deleteImage(String imageId) async {
    await ApiService.delete('/images/$imageId');
  }

  /// 点赞或取消点赞
  static Future<bool> toggleLike(String imageId) async {
    final res = await ApiService.post('/images/$imageId/like', {});
    return res['data']['liked'];
  }

  /// 获取点赞状态
  static Future<bool> getLikeStatus(String imageId) async {
    final res = await ApiService.get('/images/$imageId/like');
    return res['data']['liked'];
  }
}
