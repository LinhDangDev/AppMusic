import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:melody/models/music.dart';
import 'package:melody/models/playlist.dart';
import 'package:melody/constants/api_constants.dart';

class PlaylistService {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<Playlist>> getAllPlaylists() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/playlists'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> playlistsData = data['data'] as List? ?? [];
        return playlistsData.map((json) => Playlist.fromJson(json)).toList();
      }
      throw Exception('Failed to load playlists: ${response.statusCode}');
    } catch (e) {
      print('Error getting all playlists: $e');
      rethrow;
    }
  }

  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/playlists/$playlistId/songs/$songId'),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Failed to add song to playlist: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding song to playlist: $e');
      rethrow;
    }
  }

  Future<List<Music>> getPlaylistSongs(int playlistId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/playlists/$playlistId/songs'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> songsData = data['data'] as List? ?? [];
        return songsData.map((json) => Music.fromJson(json)).toList();
      }
      throw Exception('Failed to load playlist songs: ${response.statusCode}');
    } catch (e) {
      print('Error getting playlist songs: $e');
      rethrow;
    }
  }

  Future<Playlist> createPlaylist(String name, String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/playlists'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Tạo một Playlist mới với song_count = 0 vì playlist mới không có bài hát
        return Playlist(
          id: data['data']['id'] as int,
          userId: data['data']['user_id'] as int,
          name: data['data']['name'] as String,
          description: data['data']['description'] as String?,
          isShared: false,
          songCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      throw Exception('Failed to create playlist: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to create playlist: $e');
    }
  }

  Future<bool> deletePlaylist(int playlistId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/playlists/$playlistId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.statusCode == 204) {
          return true;
        }
        if (response.body.isNotEmpty) {
          return true;
        }
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
