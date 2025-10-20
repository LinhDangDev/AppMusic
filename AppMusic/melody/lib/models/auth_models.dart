// Auth Request Models
class RegisterRequest {
  final String email;
  final String password;
  final String name;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class VerifyEmailRequest {
  final String token;

  VerifyEmailRequest({required this.token});

  Map<String, dynamic> toJson() {
    return {'token': token};
  }
}

class PasswordResetRequest {
  final String email;

  PasswordResetRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class ResetPasswordRequest {
  final String token;
  final String newPassword;

  ResetPasswordRequest({
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'newPassword': newPassword,
    };
  }
}

// Auth Response Models
class AuthResponse {
  final String? accessToken;
  final String? refreshToken;
  final User? user;
  final String? message;
  final bool? success;

  AuthResponse({
    this.accessToken,
    this.refreshToken,
    this.user,
    this.message,
    this.success,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
      success: json['success'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user?.toJson(),
      'message': message,
      'success': success,
    };
  }
}

class TokenRefreshResponse {
  final String accessToken;
  final String refreshToken;

  TokenRefreshResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

class VerifyEmailResponse {
  final bool success;
  final String message;

  VerifyEmailResponse({
    required this.success,
    required this.message,
  });

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) {
    return VerifyEmailResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}

class PasswordResetResponse {
  final bool success;
  final String message;

  PasswordResetResponse({
    required this.success,
    required this.message,
  });

  factory PasswordResetResponse.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}

// User Model
class User {
  final int? id;
  final String email;
  final String name;
  final String? profilePicUrl;
  final bool? isPremium;
  final bool? isEmailVerified;

  User({
    this.id,
    required this.email,
    required this.name,
    this.profilePicUrl,
    this.isPremium,
    this.isEmailVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      profilePicUrl: json['profilePicUrl'] as String?,
      isPremium: json['isPremium'] as bool?,
      isEmailVerified: json['isEmailVerified'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profilePicUrl': profilePicUrl,
      'isPremium': isPremium,
      'isEmailVerified': isEmailVerified,
    };
  }
}
