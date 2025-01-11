import 'package:dio/dio.dart';
import 'package:melody/models/music.dart';
import 'package:melody/models/genre.dart';
import 'package:melody/models/search_result.dart';
import 'package:melody/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class MusicService {
  final Dio _dio = Dio();
  final String baseUrl = ApiConstants.baseUrl;
  final _yt = yt.YoutubeExplode();

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

  Future<List<Genre>> getGenres() async {
    try {
      final response =
          await http.get(Uri.parse('${ApiConstants.baseUrl}/api/genres'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> genresJson = jsonResponse['data'];

        return genresJson.map((json) => Genre.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load genres');
      }
    } catch (e) {
      print('Error fetching genres: $e');
      throw Exception('Failed to load genres');
    }
  }

  Future<String> getAudioUrl(String youtubeId) async {
    try {
      // Lấy manifest của video
      final manifest = await _yt.videos.streamsClient.getManifest(youtubeId);

      // Lấy audio stream với chất lượng cao nhất
      final audioStream = manifest.audioOnly.withHighestBitrate();

      if (audioStream != null) {
        return audioStream.url.toString();
      } else {
        throw Exception('No audio stream found');
      }
    } catch (e) {
      print('Error getting YouTube audio URL: $e');
      throw Exception('Failed to get audio URL');
    }
  }

  // Đảm bảo dispose resources khi không cần nữa
  void dispose() {
    _yt.close();
  }
}
