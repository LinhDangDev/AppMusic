// User security settings model (2FA, account locks, etc)

class SecuritySettings {
  final int userId;
  final bool twoFactorEnabled;
  final String? twoFactorSecret;
  final int failedLoginAttempts;
  final DateTime? lastFailedLogin;
  final DateTime? accountLockedUntil;
  final DateTime createdAt;
  final DateTime updatedAt;

  SecuritySettings({
    required this.userId,
    required this.twoFactorEnabled,
    this.twoFactorSecret,
    required this.failedLoginAttempts,
    this.lastFailedLogin,
    this.accountLockedUntil,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      userId: json['user_id'] as int,
      twoFactorEnabled: json['two_factor_enabled'] as bool? ?? false,
      twoFactorSecret: json['two_factor_secret'] as String?,
      failedLoginAttempts: json['failed_login_attempts'] as int? ?? 0,
      lastFailedLogin: json['last_failed_login'] != null
          ? DateTime.parse(json['last_failed_login'] as String)
          : null,
      accountLockedUntil: json['account_locked_until'] != null
          ? DateTime.parse(json['account_locked_until'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'two_factor_enabled': twoFactorEnabled,
        'two_factor_secret': twoFactorSecret,
        'failed_login_attempts': failedLoginAttempts,
        'last_failed_login': lastFailedLogin?.toIso8601String(),
        'account_locked_until': accountLockedUntil?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  /// Check if account is currently locked
  bool get isAccountLocked {
    if (accountLockedUntil == null) return false;
    return DateTime.now().isBefore(accountLockedUntil!);
  }

  /// Check if 2FA is active
  bool get is2FAActive => twoFactorEnabled && twoFactorSecret != null;
}
