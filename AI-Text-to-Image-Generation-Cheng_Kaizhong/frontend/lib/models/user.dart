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
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastLoginAt:
          json['lastLoginAt'] != null
              ? DateTime.parse(json['lastLoginAt'])
              : null,
    );
  }
}
