class ApiConstants {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://192.168.102.3:3000');
  
  static const int maxRetries = 3;
  static const int retryDelay = 2000; // milliseconds
  static const Duration timeout = Duration(seconds: 30);
}
