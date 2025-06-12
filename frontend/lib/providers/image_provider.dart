import 'package:flutter/material.dart';
import '../models/image_item.dart';
import '../services/image_service.dart';

class ImageProviderModel with ChangeNotifier {
  List<ImageItem> _images = [];
  bool _loading = false;

  List<ImageItem> get images => _images;
  bool get isLoading => _loading;

  Future<void> fetchGallery({int page = 1}) async {
    _loading = true;
    notifyListeners();
    try {
      _images = await ImageService.getGallery(page: page);
    } catch (_) {
      _images = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshGallery() async => await fetchGallery(page: 1);
}
