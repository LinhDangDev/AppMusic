import 'package:dio/dio.dart';
import 'package:melody/models/music.dart';
import 'package:melody/models/genre.dart';
import 'package:melody/models/search_result.dart';

class MusicService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://192.168.102.4:3000';

  Future<List<Music>> getAllMusic() async {
    try {
      final response = await _dio.get('$baseUrl/api/music');
      if (response.data['status'] == 'success') {
        final items = response.data['data']['items'] as List;
        return items.map((item) => Music.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting all music: $e');
      return [];
    }
  }

  Future<List<Music>> getMusicRankings(String region) async {
    try {
      final response = await _dio.get('$baseUrl/api/music/rankings/$region');
      if (response.data['status'] == 'success') {
        final rankings = response.data['data']['rankings'] as List;
        return rankings.map((item) => Music.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting rankings: $e');
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
