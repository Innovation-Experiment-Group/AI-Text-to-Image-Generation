import 'dart:convert';

class JwtHelper {
  /// 解析 JWT 的 payload 内容（通常用不到 header 和 signature）
  static Map<String, dynamic>? parseJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT');
      }

      final payload = _decodeBase64(parts[1]);
      final payloadMap = json.decode(payload);

      if (payloadMap is! Map<String, dynamic>) {
        throw Exception('Invalid JWT payload');
      }

      return payloadMap;
    } catch (e) {
      return null;
    }
  }

  /// 检查 token 是否过期（exp 是秒级时间戳）
  static bool isExpired(String token) {
    final payload = parseJwtPayload(token);
    if (payload == null || !payload.containsKey('exp')) return true;

    final expiry = payload['exp'];
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return expiry < currentTimestamp;
  }

  static String _decodeBase64(String str) {
    // 修复 Base64 URL 字符串格式
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Invalid base64url string!');
    }
    return utf8.decode(base64Url.decode(output));
  }
}
