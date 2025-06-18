import 'dart:io';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthService {
  /// 登录接口
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final data = {'username': username, 'password': password};
    final res = await ApiService.post('/auth/login', data);
    if (res.containsKey('token')) {
      ApiService.setToken(res['token']);
    }
    return res;
  }

  /// 注册接口
  static Future<Map<String, dynamic>> register(
    String username,
    String password,
    String email,
  ) async {
    final data = {'username': username, 'password': password, 'email': email};
    return await ApiService.post('/auth/register', data);
  }

  /// 获取当前用户信息
  static Future<Map<String, dynamic>> getProfile() async {
    return await ApiService.get('/auth/profile');
  }

  /// 登出接口
  static Future<void> logout() async {
    // 如果后端有登出接口，可以调用
    // await ApiService.post('/auth/logout', {});
    ApiService.setToken('');
  }

  /// 头像上传接口
  /// 传入File对象，返回头像URL字符串
  static Future<String> uploadAvatar(File avatarFile) async {
    if (ApiService.getToken() == null || ApiService.getToken()!.isEmpty) {
      throw Exception('用户未登录，无法上传头像');
    }

    final res = await ApiService.uploadFile(
      path: '/user/avatar',
      filePath: avatarFile.path,
      fieldName: 'avatar',
    );

    if (res.containsKey('data') && res['data'].containsKey('avatarUrl')) {
      return res['data']['avatarUrl'] as String;
    } else {
      throw Exception('头像上传失败，返回数据格式错误');
    }
  }
}
