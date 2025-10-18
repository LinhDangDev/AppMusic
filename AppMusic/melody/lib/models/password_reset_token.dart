// Password reset tokens table model

class PasswordResetToken {
  final int id;
  final int userId;
  final String token;
  final DateTime expiresAt;
  final DateTime createdAt;
  final bool isUsed;

  PasswordResetToken({
    required this.id,
    required this.userId,
    required this.token,
    required this.expiresAt,
    required this.createdAt,
    required this.isUsed,
  });

  factory PasswordResetToken.fromJson(Map<String, dynamic> json) {
    return PasswordResetToken(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      isUsed: json['is_used'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'token': token,
        'expires_at': expiresAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'is_used': isUsed,
      };

  /// Check if token has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if token is still valid (not expired and not used)
  bool get isValid => !isExpired && !isUsed;
}
