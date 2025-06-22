// lib/models/user.dart (最终修复版，对所有字段进行健壮的空值处理)

class User {
  final String userId;
  final String username;
  final String email;
  final String? nickname;
  final String? avatarUrl;
  final String? bio;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  User({
    required this.userId,
    required this.username,
    required this.email,
    this.nickname,
    this.avatarUrl,
    this.bio,
    this.createdAt,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // --- 这是修复的关键 ---
      // 对所有不可为空的 String 字段提供默认值
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '', // 确保 email 字段有默认值
      // 可空字段保持不变
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,

      // 日期字段做 tryParse 处理
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
      lastLoginAt:
          json['lastLoginAt'] != null
              ? DateTime.tryParse(json['lastLoginAt'].toString())
              : null,
    );
  }
}
