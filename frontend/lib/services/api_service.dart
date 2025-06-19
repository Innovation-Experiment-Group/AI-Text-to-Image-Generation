import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static String? getToken() => _token;

  static Map<String, String> _headers({bool jsonType = true}) {
    final headers = <String, String>{};
    if (jsonType) {
      headers['Content-Type'] = 'application/json';
    }
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> get(String path) async {
    final url = Uri.parse('${Constants.baseUrl}$path');
    final response = await http.get(url, headers: _headers());
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('${Constants.baseUrl}$path');
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode(data),
    );
    return _processResponse(response);
  }

  // 这里是你缺失的 delete 方法
  static Future<Map<String, dynamic>> delete(String path) async {
    final url = Uri.parse('${Constants.baseUrl}$path');
    final response = await http.delete(url, headers: _headers());
    return _processResponse(response);
  }

  // uploadFile 方法同样可以放这里

  static Future<Map<String, dynamic>> uploadFile({
    required String path,
    required String filePath,
    required String fieldName,
    Map<String, String>? extraFields,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}$path');
    final request = http.MultipartRequest('POST', url);

    if (_token != null && _token!.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    if (extraFields != null) {
      request.fields.addAll(extraFields);
    }

    final file = await http.MultipartFile.fromPath(fieldName, filePath);
    request.files.add(file);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _processResponse(response);
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    try {
      final resJson = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return resJson;
      } else {
        final message = resJson['message'] ?? '未知错误';
        throw ApiException(message, response.statusCode);
      }
    } catch (e) {
      throw ApiException(
        '服务器返回格式错误或网络异常: ${response.body}',
        response.statusCode,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? code;

  ApiException(this.message, [this.code]);

  @override
  String toString() => 'ApiException(code: $code, message: $message)';
}
