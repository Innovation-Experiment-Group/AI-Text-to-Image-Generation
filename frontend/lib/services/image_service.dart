// lib/services/image_service.dart (已加固，处理data为null的情况)

import '../models/image_item.dart';
import '../services/api_service.dart';

class ImageService {
  /// 获取公开画廊图片列表
  static Future<List<ImageItem>> fetchGallery({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await ApiService.get('/images/gallery?page=$page&limit=$limit');
    // 在这里也要加固
    if (res['data'] != null && res['data']['images'] is List) {
      final List<dynamic> list = res['data']['images'];
      return list.map((e) => ImageItem.fromJson(e)).toList();
    }
    return []; // 如果数据格式不对，返回空列表
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
    // 在这里也要加固
    if (res['data'] != null && res['data']['images'] is List) {
      final List<dynamic> list = res['data']['images'];
      return list.map((e) => ImageItem.fromJson(e)).toList();
    }
    return [];
  }

  /// 获取图片详情
  static Future<ImageItem> getImageDetail(String imageId) async {
    final res = await ApiService.get('/images/$imageId');
    // 加固
    if (res['data'] != null && res['data'] is Map<String, dynamic>) {
      return ImageItem.fromJson(res['data']);
    }
    throw Exception('获取图片详情失败，返回数据格式错误');
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

    // --- 这是修复的关键 ---
    // 在调用 fromJson 之前，检查 res['data'] 是否是一个有效的 Map
    if (res['data'] != null && res['data'] is Map<String, dynamic>) {
      return ImageItem.fromJson(res['data']);
    } else {
      // 如果 res['data'] 是 null 或其他类型，抛出一个明确的异常
      throw Exception('图片生成成功，但服务器返回数据格式不正确');
    }
  }

  /// 删除图片
  static Future<void> deleteImage(String imageId) async {
    await ApiService.delete('/images/$imageId');
  }

  /// 点赞或取消点赞
  static Future<bool> toggleLike(String imageId) async {
    final res = await ApiService.post('/images/$imageId/like', {});
    // 加固
    if (res['data'] != null && res['data']['liked'] is bool) {
      return res['data']['liked'];
    }
    throw Exception('点赞操作失败，返回数据格式错误');
  }

  /// 获取点赞状态
  static Future<bool> getLikeStatus(String imageId) async {
    final res = await ApiService.get('/images/$imageId/like');
    // 加固
    if (res['data'] != null && res['data']['liked'] is bool) {
      return res['data']['liked'];
    }
    throw Exception('获取点赞状态失败，返回数据格式错误');
  }
}
