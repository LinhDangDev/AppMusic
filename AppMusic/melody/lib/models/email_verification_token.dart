// Email verification tokens table model

class EmailVerificationToken {
  final int id;
  final int userId;
  final String token;
  final DateTime expiresAt;
  final DateTime createdAt;

  EmailVerificationToken({
    required this.id,
    required this.userId,
    required this.token,
    required this.expiresAt,
    required this.createdAt,
  });

  factory EmailVerificationToken.fromJson(Map<String, dynamic> json) {
    return EmailVerificationToken(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'token': token,
        'expires_at': expiresAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  /// Check if token has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if token is still valid
  bool get isValid => !isExpired;
}
