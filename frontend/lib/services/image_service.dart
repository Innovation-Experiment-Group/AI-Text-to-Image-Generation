import '../models/image_item.dart';
import 'api_service.dart';

class ImageService {
  static Future<ImageItem> generateImage({
    required String token,
    required String prompt,
    String? negativePrompt,
    String? style,
    bool isPublic = true,
    int width = 512,
    int height = 512,
    int samplingSteps = 30,
  }) async {
    final res = await ApiService.post(
      '/images/generate',
      token: token,
      body: {
        'prompt': prompt,
        'negativePrompt': negativePrompt,
        'style': style,
        'isPublic': isPublic,
        'width': width,
        'height': height,
        'samplingSteps': samplingSteps,
      },
    );
    return ImageItem.fromJson(res['data']);
  }

  static Future<List<ImageItem>> getGallery({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await ApiService.get(
      '/images/gallery',
      queryParams: {'page': '$page', 'limit': '$limit', 'sort': 'newest'},
    );
    return (res['data']['images'] as List)
        .map((e) => ImageItem.fromJson(e))
        .toList();
  }

  static Future<List<ImageItem>> getUserImages(
    String token, {
    bool? isPublic,
  }) async {
    final res = await ApiService.get(
      '/images/user',
      token: token,
      queryParams: {if (isPublic != null) 'isPublic': '$isPublic'},
    );
    return (res['data']['images'] as List)
        .map((e) => ImageItem.fromJson(e))
        .toList();
  }

  static Future<ImageItem> getImageDetail(
    String imageId, {
    String? token,
  }) async {
    final res = await ApiService.get('/images/$imageId', token: token);
    return ImageItem.fromJson(res['data']);
  }

  static Future<void> deleteImage(String imageId, String token) async {
    await ApiService.delete('/images/$imageId', token: token);
  }
}
