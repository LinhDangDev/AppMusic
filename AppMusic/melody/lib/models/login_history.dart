import 'enums.dart';

// Login history model (tracks all login attempts - success and failed)

class LoginHistory {
  final int id;
  final int? userId;
  final String? ipAddress;
  final String? userAgent;
  final LoginStatus loginStatus;
  final String? failureReason;
  final DateTime createdAt;

  LoginHistory({
    required this.id,
    this.userId,
    this.ipAddress,
    this.userAgent,
    required this.loginStatus,
    this.failureReason,
    required this.createdAt,
  });

  factory LoginHistory.fromJson(Map<String, dynamic> json) {
    return LoginHistory(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      loginStatus: LoginStatus.values
          .byName((json['login_status'] as String).toLowerCase()),
      failureReason: json['failure_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'ip_address': ipAddress,
        'user_agent': userAgent,
        'login_status': loginStatus.name.toUpperCase(),
        'failure_reason': failureReason,
        'created_at': createdAt.toIso8601String(),
      };

  /// Check if login was successful
  bool get isSuccessful => loginStatus == LoginStatus.success;

  /// Check if login failed
  bool get isFailed => loginStatus == LoginStatus.failed;
}
