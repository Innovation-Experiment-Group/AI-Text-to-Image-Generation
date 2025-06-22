// lib/providers/image_provider.dart (已改进，增加错误处理)

import 'package:flutter/material.dart';
import '../models/image_item.dart';
import '../services/image_service.dart';

class ImageProviderModel with ChangeNotifier {
  List<ImageItem> _images = [];
  bool _loading = false;
  String? _error; // 新增：用于存储错误信息

  List<ImageItem> get images => _images;
  bool get isLoading => _loading;
  String? get error => _error; // 新增：外部可以获取错误信息

  /// 获取公开画廊图片
  Future<void> fetchGallery({int page = 1}) async {
    _loading = true;
    _error = null; // 开始加载时，清除旧的错误
    notifyListeners();
    try {
      _images = await ImageService.fetchGallery(page: page);
    } catch (e) {
      _images = []; // 出错时清空图片列表
      _error = e.toString(); // 捕获并保存错误信息
    } finally {
      _loading = false;
      notifyListeners(); // 无论成功或失败，都停止加载并通知UI更新
    }
  }

  /// 获取当前用户的图片（可传 isPublic 过滤）
  Future<void> fetchUserImages({int page = 1, bool? isPublic}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _images = await ImageService.fetchUserImages(
        page: page,
        isPublic: isPublic,
      );
    } catch (e) {
      _images = [];
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // 其他方法暂时保持不变...

  /// 刷新画廊
  Future<void> refreshGallery() async {
    await fetchGallery(page: 1);
  }

  /// 生成新图片
  Future<ImageItem> generateImage({
    required String prompt,
    String? negativePrompt,
    String? style,
    bool isPublic = true,
    int width = 512,
    int height = 512,
    int samplingSteps = 30,
  }) async {
    try {
      final newImage = await ImageService.generateImage(
        prompt: prompt,
        negativePrompt: negativePrompt,
        style: style,
        isPublic: isPublic,
        width: width,
        height: height,
        samplingSteps: samplingSteps,
      );
      _images.insert(0, newImage);
      _error = null;
      notifyListeners();
      return newImage;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 手动新增图片
  void addImage(ImageItem newImage) {
    _images.insert(0, newImage);
    notifyListeners();
  }

  /// 删除图片
  Future<void> deleteImage(String imageId) async {
    try {
      await ImageService.deleteImage(imageId);
      _images.removeWhere((img) => img.imageId == imageId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// 点赞或取消点赞
  Future<void> toggleLike(String imageId) async {
    try {
      final liked = await ImageService.toggleLike(imageId);
      final index = _images.indexWhere((img) => img.imageId == imageId);
      if (index != -1) {
        final currentLikes = _images[index].likes ?? 0;
        _images[index].likes = currentLikes + (liked ? 1 : -1);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
}
