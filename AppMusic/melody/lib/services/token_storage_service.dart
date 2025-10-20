import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  final FlutterSecureStorage _storage;

  TokenStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Save both access and refresh tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _accessTokenKey, value: accessToken),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
      ]);
    } catch (e) {
      throw Exception('Failed to save tokens: $e');
    }
  }

  /// Retrieve access token
  Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      if (token != null && !isTokenExpired(token)) {
        return token;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get access token: $e');
    }
  }

  /// Retrieve refresh token
  Future<String?> getRefreshToken() async {
    try {
      final token = await _storage.read(key: _refreshTokenKey);
      if (token != null && !isTokenExpired(token)) {
        return token;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get refresh token: $e');
    }
  }

  /// Check if token is expired
  bool isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      return true;
    }
  }

  /// Get time until token expiration (in seconds)
  int? getTokenExpiresIn(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final expiresAt = decodedToken['exp'] as int?;
      if (expiresAt != null) {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        return expiresAt - now;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Save user data as JSON string
  Future<void> saveUserData(String userData) async {
    try {
      await _storage.write(key: _userDataKey, value: userData);
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  /// Retrieve user data
  Future<String?> getUserData() async {
    try {
      return await _storage.read(key: _userDataKey);
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  /// Clear all authentication data (logout)
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _userDataKey),
      ]);
    } catch (e) {
      throw Exception('Failed to clear tokens: $e');
    }
  }

  /// Check if user is authenticated (has valid access token)
  Future<bool> isAuthenticated() async {
    try {
      final token = await getAccessToken();
      return token != null && !isTokenExpired(token);
    } catch (e) {
      return false;
    }
  }

  /// Check if access token is about to expire (within 60 seconds)
  bool isAccessTokenExpiringSoon(String accessToken) {
    try {
      final expiresIn = getTokenExpiresIn(accessToken);
      return expiresIn != null && expiresIn < 60;
    } catch (e) {
      return true;
    }
  }

  /// Update access token while keeping refresh token
  Future<void> updateAccessToken(String newAccessToken) async {
    try {
      await _storage.write(key: _accessTokenKey, value: newAccessToken);
    } catch (e) {
      throw Exception('Failed to update access token: $e');
    }
  }

  /// Decode JWT token and return claims
  Map<String, dynamic>? decodeToken(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      return null;
    }
  }
}
