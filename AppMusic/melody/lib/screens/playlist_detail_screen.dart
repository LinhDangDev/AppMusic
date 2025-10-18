import 'package:flutter/material.dart';
import 'package:melody/models/playlist.dart';
import 'package:melody/models/music.dart';
import 'package:melody/services/playlist_service.dart';
import 'package:get/get.dart';
import 'package:melody/screens/player_screen.dart';
import 'package:melody/constants/app_colors.dart';
import 'dart:ui';
import 'package:melody/provider/music_controller.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;
  final PlaylistService _playlistService = PlaylistService();
  final RxList<Music> songs = <Music>[].obs;
  final RxBool isLoading = true.obs;

  PlaylistDetailScreen({Key? key, required this.playlist}) : super(key: key) {
    _loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Custom App Bar với backdrop blur
            _buildCustomAppBar(),
            // Content
            Obx(() {
              if (isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildContent();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      height: 300,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.network(
              _getPlaylistImage(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.music_note,
                      color: Colors.white, size: 50),
                );
              },
            ),
          ),
          // Blur overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Playlist info
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${songs.length} bài hát',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (songs.isEmpty) {
      return const Center(
        child: Text(
          'Không có bài hát nào',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 280)),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final song = songs[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      getYoutubeThumbnail(song.youtubeId ?? ''),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey[800],
                        child:
                            const Icon(Icons.music_note, color: Colors.white),
                      ),
                    ),
                  ),
                  title: Text(
                    song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    song.artistName ?? 'Unknown Artist',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () => _showOptions(context, song),
                  ),
                  onTap: () => _playSong(context, song, index),
                ),
              );
            },
            childCount: songs.length,
          ),
        ),
        const SliverToBoxAdapter(
            child: SizedBox(height: 100)), // Bottom padding for mini player
      ],
    );
  }

  void _showOptions(BuildContext context, Music song) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.play_circle_outline, color: Colors.white),
              title: const Text('Phát', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                _playSong(context, song, songs.indexOf(song));
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Colors.white),
              title: const Text('Thêm vào playlist',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border, color: Colors.white),
              title: const Text('Thêm vào yêu thích',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _getPlaylistImage() {
    if (playlist.imageUrl != null && playlist.imageUrl!.isNotEmpty) {
      return playlist.imageUrl!;
    } else if (songs.isNotEmpty) {
      return getYoutubeThumbnail(songs[0].youtubeId ?? '');
    } else {
      return 'https://example.com/default-playlist-image.jpg';
    }
  }

  String getYoutubeThumbnail(String youtubeId) {
    if (youtubeId.isEmpty) return '';
    return 'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg';
  }

  Future<void> _loadSongs() async {
    try {
      isLoading.value = true;
      final playlistSongs =
          await _playlistService.getPlaylistSongs(playlist.id);
      songs.assignAll(playlistSongs);
    } catch (e) {
      print('Error loading playlist songs: $e');
      Get.snackbar(
        'Error',
        'Failed to load songs',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _playSong(BuildContext context, Music song, int index) {
    final musicController = Get.find<MusicController>();

    // Set up queue first
    musicController.setCurrentQueue(
        playlist: songs, currentIndex: index, playlistName: playlist.name);

    // Ensure isQueueMode is set to true (queue is active)
    musicController.isQueueMode.value = true;

    // Navigate to player
    Get.to(() => PlayerScreen(
          title: song.title,
          artist: song.artistName ?? 'Unknown Artist',
          imageUrl: song.youtubeThumbnail ?? '',
          youtubeId: song.youtubeId ?? '',
        ));

    // Load and play music
    musicController.loadAndPlayMusic(song).catchError((error) {
      Get.snackbar(
        'Error',
        'Failed to play song: $error',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    });
  }
}
