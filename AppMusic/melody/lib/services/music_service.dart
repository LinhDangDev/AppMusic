import 'package:dio/dio.dart';
import 'package:melody/services/auth_service.dart';

class MusicService {
  final String baseUrl = 'http://192.168.102.4:3000/api';
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  Future<List<dynamic>> searchMusic(String query) async {
    try {
      // Lấy token từ AuthService
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Vui lòng đăng nhập để tiếp tục');
      }

      final response = await _dio.get(
        '$baseUrl/music/search',
        queryParameters: {'q': query},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['data'] ?? [];
      } else {
        throw Exception(response.data['message'] ?? 'Không tìm thấy kết quả');
      }
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn');
      }
      throw Exception('Lỗi kết nối: ${e.message}');
    } catch (e) {
      print('Search Error: $e');
      throw Exception('Có lỗi xảy ra khi tìm kiếm');
    }
  }

  Future<String> getStreamUrl(String musicId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Vui lòng đăng nhập để tiếp tục');
      }

      final response = await _dio.get(
        '$baseUrl/music/$musicId/stream',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['data']['streamUrl'];
      } else {
        throw Exception('Không thể lấy đường dẫn phát nhạc');
      }
    } catch (e) {
      print('Get Stream URL Error: $e');
      throw Exception('Có lỗi xảy ra khi lấy đường dẫn phát nhạc');
    }
  }

  Future<void> recordPlay(String musicId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Vui lòng đăng nhập để tiếp tục');
      }

      await _dio.post(
        '$baseUrl/music/$musicId/play',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      print('Record Play Error: $e');
      // Có thể bỏ qua lỗi này vì không ảnh hưởng đến trải nghiệm người dùng
    }
  }
} 