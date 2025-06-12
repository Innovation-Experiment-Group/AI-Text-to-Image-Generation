import 'package:frontend/models/user.dart';
import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
    String? nickname,
  }) async {
    final res = await ApiService.post(
      '/auth/register',
      body: {
        'username': username,
        'password': password,
        'email': email,
        if (nickname != null) 'nickname': nickname,
      },
    );
    return res;
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final res = await ApiService.post(
      '/auth/login',
      body: {'username': username, 'password': password},
    );
    return res;
  }

  static Future<User> getProfile(String token) async {
    final res = await ApiService.get('/users/profile', token: token);
    return User.fromJson(res['data']);
  }
}
