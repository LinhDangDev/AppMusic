import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/auth_models.dart';
import '../utils/api_constants.dart';
import 'dio_client.dart';
import 'token_storage_service.dart';

class AuthService {
  final DioClient _dioClient;
  final TokenStorageService _tokenStorage;

  AuthService({
    required DioClient dioClient,
    required TokenStorageService tokenStorage,
  })  : _dioClient = dioClient,
        _tokenStorage = tokenStorage;

  /// Register new user
  /// POST /api/v1/auth/register
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        name: name,
      );

      final response = await _dioClient.post(
        ApiConstants.authRegister,
        data: request.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final authResponse =
            AuthResponse.fromJson(response.data['data'] ?? response.data);

        // Save tokens if provided
        if (authResponse.accessToken != null &&
            authResponse.refreshToken != null) {
          await _tokenStorage.saveTokens(
            accessToken: authResponse.accessToken!,
            refreshToken: authResponse.refreshToken!,
          );

          // Save user data
          if (authResponse.user != null) {
            await _tokenStorage.saveUserData(
              jsonEncode(authResponse.user!.toJson()),
            );
          }
        }

        return authResponse;
      }

      throw Exception('Registration failed');
    } on DioException catch (e) {
      throw Exception(e.error ?? ApiConstants.unknownError);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Login user
  /// POST /api/v1/auth/login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(
        email: email,
        password: password,
      );

      final response = await _dioClient.post(
        ApiConstants.authLogin,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final authResponse =
            AuthResponse.fromJson(response.data['data'] ?? response.data);

        // Save tokens
        if (authResponse.accessToken != null &&
            authResponse.refreshToken != null) {
          await _tokenStorage.saveTokens(
            accessToken: authResponse.accessToken!,
            refreshToken: authResponse.refreshToken!,
          );

          // Save user data
          if (authResponse.user != null) {
            await _tokenStorage.saveUserData(
              jsonEncode(authResponse.user!.toJson()),
            );
          }
        }

        return authResponse;
      }

      throw Exception('Login failed');
    } on DioException catch (e) {
      throw Exception(e.error ?? ApiConstants.invalidCredentials);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Refresh access token
  /// POST /api/v1/auth/refresh-token
  Future<TokenRefreshResponse> refreshToken() async {
    try {
      final currentRefreshToken = await _tokenStorage.getRefreshToken();

      if (currentRefreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _dioClient.post(
        ApiConstants.authRefreshToken,
        data: {'refreshToken': currentRefreshToken},
      );

      if (response.statusCode == 200) {
        final tokenResponse = TokenRefreshResponse.fromJson(
          response.data['data'] ?? response.data,
        );

        // Update tokens
        await _tokenStorage.updateAccessToken(tokenResponse.accessToken);

        // If refresh token also updated
        if (tokenResponse.refreshToken.isNotEmpty) {
          await _tokenStorage.saveTokens(
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken,
          );
        }

        return tokenResponse;
      }

      throw Exception('Token refresh failed');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Token refresh failed');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Logout user
  /// POST /api/v1/auth/logout
  Future<void> logout() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();

      if (refreshToken != null) {
        await _dioClient.post(
          ApiConstants.authLogout,
          data: {'refreshToken': refreshToken},
        );
      }

      // Clear tokens regardless of API response
      await _tokenStorage.clearTokens();
    } on DioException catch (e) {
      // Clear tokens even if API call fails
      await _tokenStorage.clearTokens();
      throw Exception(e.error ?? 'Logout failed');
    } catch (e) {
      await _tokenStorage.clearTokens();
      throw Exception(e.toString());
    }
  }

  /// Request password reset
  /// POST /api/v1/auth/request-password-reset
  Future<PasswordResetResponse> requestPasswordReset(String email) async {
    try {
      final request = PasswordResetRequest(email: email);

      final response = await _dioClient.post(
        ApiConstants.authRequestPasswordReset,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return PasswordResetResponse.fromJson(
          response.data['data'] ?? response.data,
        );
      }

      throw Exception('Password reset request failed');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Failed to request password reset');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Reset password with token
  /// POST /api/v1/auth/reset-password
  Future<PasswordResetResponse> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final request = ResetPasswordRequest(
        token: token,
        newPassword: newPassword,
      );

      final response = await _dioClient.post(
        ApiConstants.authResetPassword,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return PasswordResetResponse.fromJson(
          response.data['data'] ?? response.data,
        );
      }

      throw Exception('Password reset failed');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Failed to reset password');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Verify email
  /// GET /api/v1/auth/verify-email/:token
  Future<VerifyEmailResponse> verifyEmail(String token) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.authVerifyEmail}/$token',
      );

      if (response.statusCode == 200) {
        return VerifyEmailResponse.fromJson(
          response.data['data'] ?? response.data,
        );
      }

      throw Exception('Email verification failed');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Email verification failed');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Get current user profile
  /// GET /api/v1/auth/me (protected)
  Future<User> getCurrentUser() async {
    try {
      final response = await _dioClient.get(ApiConstants.userProfile);

      if (response.statusCode == 200) {
        return User.fromJson(response.data['data'] ?? response.data);
      }

      throw Exception('Failed to fetch user profile');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Failed to fetch user profile');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _tokenStorage.isAuthenticated();
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return await _tokenStorage.getAccessToken();
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await _tokenStorage.getRefreshToken();
  }

  /// Get stored user data
  Future<User?> getStoredUser() async {
    try {
      final userData = await _tokenStorage.getUserData();
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Change password
  /// POST /api/v1/auth/change-password (protected)
  Future<PasswordResetResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.authChangePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return PasswordResetResponse.fromJson(
          response.data['data'] ?? response.data,
        );
      }

      throw Exception('Password change failed');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Failed to change password');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
