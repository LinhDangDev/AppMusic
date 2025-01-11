import 'package:dio/dio.dart';
import 'package:melody/models/music.dart';
import 'package:melody/models/genre.dart';
import 'package:melody/models/search_result.dart';
import 'package:melody/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class MusicService {
  final _yt = yt.YoutubeExplode();
  final Dio _dio = Dio();

  MusicService() {
    _dio.options.validateStatus = (status) {
      return status! < 500;
    };
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.connectTimeout = const Duration(seconds: 30);
  }

  Future<List<Music>> getAllMusic() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/api/music');
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
      print('Fetching rankings for region: $region');
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/api/music/rankings/$region',
        options: Options(
          headers: {'Accept': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Rankings response: ${response.data}');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final data = response.data['data'];
        if (data == null) {
          print('No data in response');
          return [];
        }

        final rankings = data['rankings'] as List?;
        if (rankings == null) {
          print('No rankings in data');
          return [];
        }

        return rankings.map((item) => Music.fromJson(item)).toList();
      } else {
        print('Error response: ${response.statusCode} - ${response.data}');
        return [];
      }
    } catch (e) {
      print('Error getting rankings: $e');
      return [];
    }
  }

  Future<List<SearchResult>> searchMusic(String query) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/api/music/search',
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

  Future<String?> getAudioUrl(String youtubeId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(youtubeId);
      final audioStream = manifest.audioOnly.withHighestBitrate();
      if (audioStream != null) {
        return audioStream.url.toString();
      }
      return null;
    } catch (e) {
      print('Error getting audio URL: $e');
      return null;
    }
  }

  Future<List<Music>> getRandomMusic() async {
    try {
      final response = await _dio.get(
          '${ApiConstants.baseUrl}/api/music/random',
          queryParameters: {'limit': 10});

      if (response.data['status'] == 'success') {
        final items = response.data['data'] as List;
        return items.map((item) => Music.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting random music: $e');
      return [];
    }
  }

  Future<void> updatePlayCount(String musicId) async {
    try {
      await _dio.post('${ApiConstants.baseUrl}/api/music/$musicId/play');
    } catch (e) {
      print('Error updating play count: $e');
    }
  }

  Future<List<Music>> getRankings(String region) async {
    try {
      final response =
          await _dio.get('${ApiConstants.baseUrl}/api/music/rankings/$region');

      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> rankingsData = response.data['data']['rankings'];
        return rankingsData.map((json) => Music.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting rankings: $e');
      return [];
    }
  }

  void dispose() {
    _yt.close();
  }

  String validateImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'assets/images/loggo.png';
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (url.length == 11) {
      return 'https://img.youtube.com/vi/$url/mqdefault.jpg';
    }

    return 'assets/images/default_music.png';
  }
}
