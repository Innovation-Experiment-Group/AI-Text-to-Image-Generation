import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _loading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _token != null;
  bool get isLoading => _loading;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(Constants.tokenKey);
    if (savedToken != null) {
      _token = savedToken;
      try {
        final res = await AuthService.getProfile();
        _user = User.fromJson(res['data']);
      } catch (e) {
        _token = null;
        _user = null;
        await prefs.remove(Constants.tokenKey);
        rethrow;
      }
      notifyListeners();
    }
  }

  Future<void> login(String username, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final res = await AuthService.login(username, password);
      _token = res['token'];
      _user = User.fromJson(res['data']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.tokenKey, _token!);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.tokenKey);
    _user = null;
    _token = null;
    notifyListeners();
  }

  /// 新增：设置用户及token（可选），并同步缓存
  Future<void> setUser(User user, {String? token}) async {
    _user = user;
    if (token != null) {
      _token = token;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.tokenKey, token);
    }
    notifyListeners();
  }
}
