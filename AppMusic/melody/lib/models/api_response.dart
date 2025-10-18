// Generic API Response wrapper for all endpoints

class ApiResponse<T> {
  final bool success;
  final int status;
  final String message;
  final T? data;
  final Map<String, dynamic>? error;
  final DateTime? timestamp;

  ApiResponse({
    required this.success,
    required this.status,
    required this.message,
    this.data,
    this.error,
    this.timestamp,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] as bool,
      status: json['status'] as int,
      message: json['message'] as String,
      data: json['data'],
      error: json['error'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'status': status,
        'message': message,
        'data': data,
        'error': error,
        'timestamp': timestamp?.toIso8601String(),
      };

  /// Helper method to check if response was successful
  bool get isSuccess => success && status >= 200 && status < 300;

  /// Helper method to get error message
  String? get errorMessage => error?['code'] as String?;

  /// Helper method to get error details
  String? get errorDetails => error?['details'] as String?;
}
