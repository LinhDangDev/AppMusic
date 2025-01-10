import 'package:flutter/material.dart';
import 'package:melody/models/playlist.dart';
import 'package:melody/models/music.dart';
import 'package:melody/services/playlist_service.dart';
import 'package:get/get.dart';
import 'package:melody/screens/player_screen.dart';
import 'package:melody/provider/audio_provider.dart';
import 'package:provider/provider.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;
  final PlaylistService _playlistService = PlaylistService();
  final RxList<Music> songs = <Music>[].obs;
  final RxBool isLoading = true.obs;

  PlaylistDetailScreen({Key? key, required this.playlist}) : super(key: key) {
    _loadSongs();
  }

  String getYoutubeThumbnail(String youtubeId) {
    return 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';
  }

  Future<void> _loadSongs() async {
    try {
      isLoading.value = true;
      final playlistSongs = await _playlistService.getPlaylistSongs(playlist.id);
      songs.assignAll(playlistSongs);
    } catch (e) {
      print('Error loading playlist songs: $e');
      Get.snackbar(
        'Error',
        'Failed to load songs',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _playSong(BuildContext context, Music song, int index) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    
    // Cập nhật danh sách phát và vị trí hiện tại
    audioProvider.updateQueue(
      songs.map((s) => {
        'title': s.title,
        'artist': s.artistName,
        'imageUrl': getYoutubeThumbnail(s.youtubeId),
        'youtubeId': s.youtubeId,
      }).toList(),
      index,
    );

    // Chuyển đến màn hình player
    Get.to(() => PlayerScreen(
      title: song.title,
      artist: song.artistName,
      imageUrl: getYoutubeThumbnail(song.youtubeId),
      youtubeId: song.youtubeId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (songs.isEmpty) {
          return Center(
            child: Text('No songs in this playlist'),
          );
        }

        return ListView.builder(
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  getYoutubeThumbnail(song.youtubeId),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.music_note);
                  },
                ),
              ),
              title: Text(song.title),
              subtitle: Text(song.artistName),
              onTap: () => _playSong(context, song, index),
            );
          },
        );
      }),
    );
  }
} 