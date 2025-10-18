import 'user.dart';

// Authentication response with tokens
class AuthResponse {
  final User user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_in': expiresIn,
      };

  /// Helper method to get expiration datetime
  DateTime get expiresAt => DateTime.now().add(Duration(seconds: expiresIn));

  /// Helper method to check if token will expire soon (within 5 minutes)
  bool get isExpiringSoon =>
      DateTime.now().add(const Duration(minutes: 5)).isAfter(expiresAt);
}
