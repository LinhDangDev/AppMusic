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
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  ));

  MusicService() {
    _dio.options.validateStatus = (status) {
      return status! < 500;
    };
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.connectTimeout = const Duration(seconds: 60);

    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<List<Music>> getAllMusic() async {
    int retries = 0;
    while (retries < ApiConstants.maxRetries) {
      try {
        final response = await _dio.get('/api/music');
        if (response.data['status'] == 'success') {
          final items = response.data['data']['items'] as List;
          return items.map((item) => Music.fromJson(item)).toList();
        }
        return [];
      } catch (e) {
        retries++;
        if (retries == ApiConstants.maxRetries) {
          print('Error getting all music after $retries retries: $e');
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: ApiConstants.retryDelay));
      }
    }
    return [];
  }

  Future<List<Music>> getMusicRankings(String region) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/api/rankings/region',
        queryParameters: {'region': region},
        options: Options(
          headers: {'Accept': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) {
          return [];
        }

        final rankings = data is List ? data : [data];
        if (rankings.isEmpty) {
          return [];
        }

        return rankings
            .map((item) {
              try {
                return Music.fromJson(item);
              } catch (e) {
                print('Error parsing music item: $e');
                return null;
              }
            })
            .whereType<Music>()
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting music rankings: $e');
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
      // Kiểm tra và làm sạch YouTube ID
      String videoId = youtubeId;
      if (youtubeId.contains('youtube.com') || youtubeId.contains('youtu.be')) {
        final uri = Uri.parse(youtubeId);
        videoId = uri.queryParameters['v'] ??
            youtubeId.split('/').last.split('?').first;
      }

      if (videoId.isEmpty) {
        throw Exception('Invalid YouTube ID');
      }

      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioStream = manifest.audioOnly.withHighestBitrate();
      return audioStream.url.toString();
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
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/api/rankings/region',
        queryParameters: {'region': region},
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> rankingsData = response.data['data'];
        return rankingsData.map((json) => Music.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting rankings: $e');
      return [];
    }
  }

  Future<List<Music>> getBiggestHits(String region) async {
    try {
      final response = await _dio.get(
          '${ApiConstants.baseUrl}/api/rankings/region',
          queryParameters: {'region': region});

      if (response.statusCode == 200 && response.data['data'] != null) {
        final rankingsData = response.data['data'] as List?;
        if (rankingsData == null || rankingsData.isEmpty) return [];

        return rankingsData
            .map((song) {
              if (song == null) return null;

              try {
                String title = (song['title'] ?? 'Unknown').toString().trim();
                String artistName =
                    (song['artist_name'] ?? 'Unknown Artist').toString().trim();
                String youtubeId = _extractYoutubeId(song['youtube_url'] ?? '');
                String thumbnail = song['youtube_thumbnail'] ?? '';

                if (title.isEmpty) {
                  print('Warning: Empty title in ranking song');
                  return null;
                }

                if (thumbnail.isEmpty && youtubeId.isNotEmpty) {
                  thumbnail =
                      'https://img.youtube.com/vi/$youtubeId/mqdefault.jpg';
                }

                return Music(
                  id: song['id'] as int?,
                  title: title,
                  artistName: artistName,
                  youtubeId: youtubeId,
                  youtubeThumbnail: thumbnail,
                  playCount: song['play_count'] as int? ?? 0,
                  position: song['position'] as int?,
                  duration: song['duration'] as int?,
                  genre: (song['genres'] as List?)?.join(', '),
                );
              } catch (e) {
                print('Error parsing ranking item: $e');
                return null;
              }
            })
            .whereType<Music>()
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting biggest hits: $e');
      return [];
    }
  }

  String _extractYoutubeId(String url) {
    if (url.isEmpty) return '';
    try {
      if (url.contains('youtu.be/')) {
        return url.split('youtu.be/')[1].split('?')[0];
      } else if (url.contains('youtube.com/watch')) {
        return Uri.parse(url).queryParameters['v'] ?? '';
      }
      return url;
    } catch (e) {
      print('Error extracting YouTube ID: $e');
      return '';
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
