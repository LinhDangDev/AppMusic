import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:melody/models/music.dart';
import 'package:melody/models/playlist.dart';

class PlaylistService {
  final String baseUrl = 'http://192.168.102.4:3000';

  Future<List<Playlist>> getAllPlaylists() async {
    final response = await http.get(Uri.parse('$baseUrl/api/playlists'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['data'] as List)
          .map((json) => Playlist.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load playlists');
  }

  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/playlists/$playlistId/songs/$songId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add song to playlist');
    }
  }

  Future<List<Music>> getPlaylistSongs(int playlistId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/playlists/$playlistId/songs'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['data'] as List)
          .map((json) => Music.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load playlist songs');
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
          id: data['data']['id'],
          userId: data['data']['user_id'],
          name: data['data']['name'],
          description: data['data']['description'],
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          songCount: 0,
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

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.statusCode == 204) {
          return true;
        }
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> data = json.decode(response.body);
          print('Delete response data: $data');
          return true;
        }
        return true;
      }
      
      if (response.body.isNotEmpty) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        print('Delete error data: $errorData');
      }
      
      return false;
    } catch (e) {
      print('Delete playlist error: $e');
      return false;
    }
  }
}
