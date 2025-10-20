import 'package:get/get.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../services/token_storage_service.dart';

class AuthController extends GetxController {
  final AuthService _authService;

  AuthController({
    required AuthService authService,
    required TokenStorageService tokenStorage,
  }) : _authService = authService;

  // Reactive variables
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoggedIn = RxBool(false);
  final RxBool isLoading = RxBool(false);
  final RxString errorMessage = RxString('');
  final RxBool isEmailVerified = RxBool(false);
  final Rx<String?> accessToken = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  /// Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        final storedUser = await _authService.getStoredUser();
        if (storedUser != null) {
          user.value = storedUser;
          isLoggedIn.value = true;
          isEmailVerified.value = storedUser.isEmailVerified ?? false;

          final token = await _authService.getAccessToken();
          accessToken.value = token;
        }
      }
    } catch (e) {
      print('Error checking auth status: $e');
    }
  }

  /// Register new user
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authService.register(
        email: email,
        password: password,
        name: name,
      );

      if (response.user != null) {
        user.value = response.user;
        isLoggedIn.value = true;
        isEmailVerified.value = response.user!.isEmailVerified ?? false;

        final token = await _authService.getAccessToken();
        accessToken.value = token;

        Get.offAllNamed('/home');
      } else {
        errorMessage.value = response.message ?? 'Registration failed';
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Registration Error',
        errorMessage.value,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Login user
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.user != null) {
        user.value = response.user;
        isLoggedIn.value = true;
        isEmailVerified.value = response.user!.isEmailVerified ?? false;

        final token = await _authService.getAccessToken();
        accessToken.value = token;

        Get.offAllNamed('/home');
      } else {
        errorMessage.value = response.message ?? 'Login failed';
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Login Error',
        errorMessage.value,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      isLoading.value = true;

      await _authService.logout();

      user.value = null;
      isLoggedIn.value = false;
      isEmailVerified.value = false;
      accessToken.value = null;
      errorMessage.value = '';

      Get.offAllNamed('/login');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Logout Error',
        errorMessage.value,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Request password reset
  Future<void> requestPasswordReset(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authService.requestPasswordReset(email);

      if (response.success) {
        Get.snackbar(
          'Success',
          'Password reset link sent to your email',
          duration: Duration(seconds: 3),
        );
        Get.toNamed('/login');
      } else {
        errorMessage.value = response.message ?? 'Failed to send reset link';
        Get.snackbar(
          'Error',
          errorMessage.value,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset password with token
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authService.resetPassword(
        token: token,
        newPassword: newPassword,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Password reset successfully',
          duration: Duration(seconds: 3),
        );
        Get.offAllNamed('/login');
      } else {
        errorMessage.value = response.message ?? 'Failed to reset password';
        Get.snackbar(
          'Error',
          errorMessage.value,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify email
  Future<void> verifyEmail(String token) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authService.verifyEmail(token);

      if (response.success) {
        isEmailVerified.value = true;
        Get.snackbar(
          'Success',
          'Email verified successfully',
          duration: Duration(seconds: 3),
        );
        Get.toNamed('/home');
      } else {
        errorMessage.value = response.message ?? 'Email verification failed';
        Get.snackbar(
          'Error',
          errorMessage.value,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get current user profile
  Future<void> getCurrentUser() async {
    try {
      isLoading.value = true;

      final currentUser = await _authService.getCurrentUser();
      user.value = currentUser;
      isEmailVerified.value = currentUser.isEmailVerified ?? false;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      print('Error fetching user: $errorMessage');
    } finally {
      isLoading.value = false;
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Password changed successfully',
          duration: Duration(seconds: 3),
        );
        Get.back();
      } else {
        errorMessage.value = response.message ?? 'Failed to change password';
        Get.snackbar(
          'Error',
          errorMessage.value,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh access token (called by interceptor)
  Future<bool> refreshAccessToken() async {
    try {
      final response = await _authService.refreshToken();
      accessToken.value = response.accessToken;
      return true;
    } catch (e) {
      print('Token refresh failed: $e');
      // If refresh fails, logout user
      await logout();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  /// Get user display name
  String get displayName => user.value?.name ?? 'User';

  /// Get user email
  String get userEmail => user.value?.email ?? '';

  /// Check if user is premium
  bool get isPremium => user.value?.isPremium ?? false;

  /// Check if user profile is complete
  bool get isProfileComplete {
    return user.value != null &&
        user.value!.email.isNotEmpty &&
        user.value!.name.isNotEmpty;
  }
}
