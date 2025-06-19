import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';

  static const String authHeader = 'Authorization';
  static const String tokenKey = 'auth_token';

  static const int defaultImageWidth = 512;
  static const int defaultImageHeight = 512;
}
