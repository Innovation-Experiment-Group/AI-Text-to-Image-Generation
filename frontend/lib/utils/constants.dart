class Constants {
  // ⚠️ 开发环境后端地址
  static const String baseUrl = 'http://localhost:3000/api';

  // 统一请求头键名
  static const String authHeader = 'Authorization';

  // 本地存储的 key（如 SharedPreferences）
  static const String tokenKey = 'auth_token';

  // 默认图片尺寸
  static const int defaultImageWidth = 512;
  static const int defaultImageHeight = 512;
}
