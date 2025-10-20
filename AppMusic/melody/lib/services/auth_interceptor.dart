import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../provider/auth_controller.dart';
import 'token_storage_service.dart';

class TokenRefreshInterceptor extends QueuedInterceptor {
  final Dio dio;
  final TokenStorageService tokenStorage;
  bool _isRefreshing = false;
  final List<RequestOptions> _failedRequests = [];

  TokenRefreshInterceptor({
    required this.dio,
    required this.tokenStorage,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if token is about to expire (within 60 seconds)
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken != null) {
      // Check if token expiring soon
      if (tokenStorage.isAccessTokenExpiringSoon(accessToken)) {
        // Try to refresh before making request
        final refreshed = await _refreshToken();
        if (!refreshed) {
          // If refresh fails, let the request continue and handle 401 in onError
          return handler.next(options);
        }
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized
    if (err.response?.statusCode == 401) {
      // Don't retry auth endpoints
      if (_isAuthEndpoint(err.requestOptions.path)) {
        return handler.next(err);
      }

      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          final authController = Get.find<AuthController>();
          final refreshed = await authController.refreshAccessToken();

          if (refreshed) {
            // Retry original request with new token
            final opts = err.requestOptions;
            final token = await tokenStorage.getAccessToken();
            opts.headers['Authorization'] = 'Bearer $token';

            final response = await dio.request<dynamic>(
              opts.path,
              options: Options(
                method: opts.method,
                headers: opts.headers,
              ),
              data: opts.data,
              queryParameters: opts.queryParameters,
            );

            _isRefreshing = false;
            return handler.resolve(response);
          } else {
            _isRefreshing = false;
            return handler.next(err);
          }
        } catch (e) {
          _isRefreshing = false;
          return handler.next(err);
        }
      } else {
        // Queue failed requests while refreshing
        _failedRequests.add(err.requestOptions);

        // Wait for token refresh to complete, then retry
        Future.delayed(Duration(milliseconds: 100), () async {
          final token = await tokenStorage.getAccessToken();
          err.requestOptions.headers['Authorization'] = 'Bearer $token';
        });

        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  /// Refresh access token
  Future<bool> _refreshToken() async {
    try {
      final authController = Get.find<AuthController>();
      return await authController.refreshAccessToken();
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  /// Check if endpoint is auth-related
  bool _isAuthEndpoint(String path) {
    final authPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh-token',
      '/auth/logout',
      '/auth/verify-email',
      '/auth/request-password-reset',
      '/auth/reset-password',
    ];

    return authPaths.any((authPath) => path.contains(authPath));
  }
}
