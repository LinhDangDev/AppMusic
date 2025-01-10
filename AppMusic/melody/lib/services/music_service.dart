import 'package:dio/dio.dart';
import 'package:melody/models/music.dart';
import 'package:melody/models/genre.dart';
import 'package:melody/models/search_result.dart';

class MusicService {
  final String baseUrl = 'http://192.168.102.4:3000';
  // final String baseUrl = 'http://192.168.1.xxx:3000';
  final Dio _dio = Dio();

  MusicService() {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('Dio Log: $obj'),
    ));
  }

  Future<List<Music>> getAllMusic() async {
    try {
      final response = await _dio.get('$baseUrl/api/music');
      final Map<String, dynamic> responseData = response.data;
      final List<dynamic> items = responseData['data']['items'] ?? [];
      return items.map((item) => Music.fromJson(item)).toList();
    } catch (e) {
      print('Get All Music Error: $e');
      return [];
    }
  }

  Future<List<Music>> getMusicRankings(String country) async {
    try {
      final response = await _dio.get('$baseUrl/api/music/rankings/$country');
      final Map<String, dynamic> responseData = response.data;
      final List<dynamic> items = responseData['data']['rankings'] ?? [];
      return items.map((item) => Music.fromJson(item)).toList();
    } catch (e) {
      print('Get Music Rankings Error: $e');
      return [];
    }
  }

  Future<List<SearchResult>> searchMusic(String query) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/music/search',
        queryParameters: {'q': query},
      );
      final List<dynamic> items = response.data['data'] ?? [];
      return items.take(10).map((item) => SearchResult.fromJson(item)).toList();
    } catch (e) {
      print('Search Music Error: $e');
      return [];
    }
  }

  Future<List<Genre>> getAllGenres() async {
    try {
      final response = await _dio.get('$baseUrl/api/genres');
      final Map<String, dynamic> responseData = response.data;
      final List<dynamic> items = responseData['data'] ?? [];
      return items.map((item) => Genre.fromJson(item)).toList();
    } catch (e) {
      print('Get All Genres Error: $e');
      return [];
    }
  }
}
