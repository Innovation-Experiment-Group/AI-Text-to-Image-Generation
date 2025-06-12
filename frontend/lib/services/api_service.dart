import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static Future<Map<String, dynamic>> get(
    String path, {
    String? token,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(
      '${Constants.baseUrl}$path',
    ).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers(token));
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> post(
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${Constants.baseUrl}$path');
    final response = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> put(
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${Constants.baseUrl}$path');
    final response = await http.put(
      uri,
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> delete(
    String path, {
    String? token,
  }) async {
    final uri = Uri.parse('${Constants.baseUrl}$path');
    final response = await http.delete(uri, headers: _headers(token));
    return _handleResponse(response);
  }

  static Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) Constants.authHeader: 'Bearer $token',
    };
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? '请求错误');
    }
  }
}
