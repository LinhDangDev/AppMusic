import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import '../utils/api_constants.dart';
import 'token_storage_service.dart';

class DioClient {
  late dioLib.Dio _dio;
  final TokenStorageService _tokenStorage;

  DioClient({TokenStorageService? tokenStorage})
      : _tokenStorage = tokenStorage ?? Get.find<TokenStorageService>();

  dioLib.Dio get dio => _dio;

  void initialize() {
    _dio = dioLib.Dio(
      dioLib.BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
        receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
        sendTimeout: Duration(seconds: ApiConstants.sendTimeout),
        contentType: 'application/json',
        responseType: dioLib.ResponseType.json,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(AuthInterceptor(_tokenStorage));
    _dio.interceptors.add(ErrorInterceptor());

    // Log interceptor (only in debug mode)
    if (true) {
      // Set to false in production
      _dio.interceptors.add(LoggingInterceptor());
    }
  }

  Future<dioLib.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    dioLib.Options? options,
    dioLib.CancelToken? cancelToken,
    dioLib.ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dioLib.Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dioLib.Options? options,
    dioLib.CancelToken? cancelToken,
    dioLib.ProgressCallback? onSendProgress,
    dioLib.ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dioLib.Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dioLib.Options? options,
    dioLib.CancelToken? cancelToken,
    dioLib.ProgressCallback? onSendProgress,
    dioLib.ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dioLib.Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dioLib.Options? options,
    dioLib.CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

class AuthInterceptor extends dioLib.Interceptor {
  final TokenStorageService _tokenStorage;

  AuthInterceptor(this._tokenStorage);

  @override
  Future<void> onRequest(
    dioLib.RequestOptions options,
    dioLib.RequestInterceptorHandler handler,
  ) async {
    try {
      // Skip token attachment for auth endpoints
      if (options.path.contains('/auth/login') ||
          options.path.contains('/auth/register') ||
          options.path.contains('/auth/verify-email') ||
          options.path.contains('/auth/request-password-reset') ||
          options.path.contains('/auth/reset-password')) {
        return handler.next(options);
      }

      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }

      return handler.next(options);
    } catch (e) {
      return handler.next(options);
    }
  }
}

class ErrorInterceptor extends dioLib.Interceptor {
  @override
  Future<void> onError(
    dioLib.DioException err,
    dioLib.ErrorInterceptorHandler handler,
  ) async {
    String errorMessage = ApiConstants.unknownError;

    if (err.type == dioLib.DioExceptionType.connectionTimeout) {
      errorMessage = ApiConstants.networkError;
    } else if (err.type == dioLib.DioExceptionType.receiveTimeout) {
      errorMessage = 'Request timeout. Please try again';
    } else if (err.response != null) {
      final statusCode = err.response?.statusCode;
      final responseData = err.response?.data;

      switch (statusCode) {
        case 400:
          errorMessage = responseData?['message'] ?? 'Bad request';
          break;
        case 401:
          errorMessage = ApiConstants.unauthorizedError;
          break;
        case 403:
          errorMessage = ApiConstants.accountLocked;
          break;
        case 404:
          errorMessage = 'Resource not found';
          break;
        case 409:
          errorMessage = ApiConstants.emailAlreadyExists;
          break;
        case 429:
          errorMessage = 'Too many requests. Please try again later';
          break;
        case 500:
          errorMessage = 'Server error. Please try again later';
          break;
        default:
          errorMessage = responseData?['message'] ?? ApiConstants.unknownError;
      }
    } else if (err.type == dioLib.DioExceptionType.unknown) {
      errorMessage = ApiConstants.networkError;
    }

    final newErr = dioLib.DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage,
    );
    return handler.next(newErr);
  }
}

class LoggingInterceptor extends dioLib.Interceptor {
  @override
  Future<void> onRequest(
    dioLib.RequestOptions options,
    dioLib.RequestInterceptorHandler handler,
  ) async {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    if (options.data != null) {
      print('REQUEST DATA: ${options.data}');
    }
    print('REQUEST HEADERS: ${options.headers}');
    return handler.next(options);
  }

  @override
  Future<void> onResponse(
    dioLib.Response response,
    dioLib.ResponseInterceptorHandler handler,
  ) async {
    print(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print('RESPONSE DATA: ${response.data}');
    return handler.next(response);
  }

  @override
  Future<void> onError(
    dioLib.DioException err,
    dioLib.ErrorInterceptorHandler handler,
  ) async {
    print(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('ERROR MESSAGE: ${err.message}');
    if (err.response?.data != null) {
      print('ERROR DATA: ${err.response?.data}');
    }
    return handler.next(err);
  }
}
