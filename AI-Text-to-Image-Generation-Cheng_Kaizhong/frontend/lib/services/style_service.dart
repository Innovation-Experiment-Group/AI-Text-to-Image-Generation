import '../models/style.dart';
import 'api_service.dart';

class StyleService {
  static Future<List<Style>> getStyles() async {
    final res = await ApiService.get('/styles');
    return (res['data'] as List).map((e) => Style.fromJson(e)).toList();
  }
}
