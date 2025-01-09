import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Thay thế IP này bằng IP của máy tính trong mạng LAN
  // Để tìm IP trên Windows: chạy 'ipconfig' trong CMD
  // Để tìm IP trên Mac/Linux: chạy 'ifconfig' trong Terminal
  final String baseUrl = 'http://192.168.102.4:3000/api';  // Thay xxx bằng IP thật
  final Dio _dio = Dio();

  // Thêm phương thức để lưu token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<AuthResponse> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201) {
        // Lưu token nếu có
        if (response.data['data']?['token'] != null) {
          await _saveToken(response.data['data']['token']);
        }
        
        return AuthResponse(
          success: true,
          message: 'Registration successful',
          data: response.data['data']
        );
      } else {
        return AuthResponse(
          success: false,
          message: response.data['message'] ?? 'Registration failed',
        );
      }
    } on DioException catch (e) {
      print('Registration error: ${e.response?.data ?? e.message}');
      return AuthResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Network error occurred',
      );
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Lưu token
        if (response.data['data']?['token'] != null) {
          await _saveToken(response.data['data']['token']);
        }
        
        return AuthResponse(
          success: true,
          message: 'Login successful',
          data: response.data['data']
        );
      } else {
        return AuthResponse(
          success: false,
          message: response.data['message'] ?? 'Login failed',
        );
      }
    } on DioException catch (e) {
      print('Login error: ${e.response?.data ?? e.message}');
      return AuthResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Network error occurred',
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Thêm phương thức kiểm tra đăng nhập
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }

  // Thêm phương thức getToken
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}

class AuthResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  AuthResponse({
    required this.success,
    this.message,
    this.data,
  });
}
