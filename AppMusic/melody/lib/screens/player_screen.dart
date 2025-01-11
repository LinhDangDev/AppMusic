import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:melody/models/music.dart';
import 'package:melody/screens/Queue_screen.dart';
import 'package:melody/provider/music_controller.dart';
import 'package:melody/constants/api_constants.dart';
import 'package:melody/services/music_service.dart';

enum RepeatMode {
  off,
  one,
  all,
}

class PlayerScreen extends GetView<MusicController> {
  final String title;
  final String artist;
  final String imageUrl;
  final String youtubeId;

  PlayerScreen({
    Key? key,
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.youtubeId,
  }) : super(key: key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Move state updates to post-frame callback
      final controller = Get.find<MusicController>();
      controller.updateCurrentTrack(title, artist, imageUrl, youtubeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.minimizePlayer();
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background với thumbnail được blur
            Obx(() => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(controller.currentImageUrl.value),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) =>
                          const AssetImage('assets/images/logo.png'),
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                )),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(),
                    _buildAlbumArt(),
                    _buildSongInfo(),
                    _buildProgressBar(),
                    _buildControls(),
                    _buildAdditionalControls(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            onPressed: () {
              controller.showMiniPlayer.value = true;
              Get.back();
            },
          ),
          const Text(
            'ĐANG PHÁT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (BuildContext context) => [
              _buildPopupMenuItem('Thích', Icons.favorite_outline),
              _buildPopupMenuItem('Tải xuống', Icons.download_outlined),
              _buildPopupMenuItem('Thêm danh sách phát', Icons.playlist_add),
              _buildPopupMenuItem('Phát tiếp theo', Icons.play_circle_outline),
              _buildPopupMenuItem('Thêm vào hàng đợi', Icons.queue_music),
              _buildPopupMenuItem('Nghệ sĩ', Icons.person_outline),
              _buildPopupMenuItem('Album', Icons.album_outlined),
              _buildPopupMenuItem('Bắt đầu đài phát', Icons.radio_outlined),
              _buildPopupMenuItem('Lời bài hát', Icons.lyrics_outlined),
              _buildPopupMenuItem('Hẹn giờ ngủ', Icons.bedtime_outlined),
              _buildPopupMenuItem('Chia sẻ', Icons.share_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Obx(() {
              final imageUrl = controller.currentImageUrl.value;
              return Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[900],
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 64,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                      controller.currentTitle.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                const SizedBox(height: 8),
                Obx(() => Text(
                      controller.currentArtist.value,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Obx(() => SliderTheme(
                data: SliderThemeData(
                  trackHeight: 2,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.grey[800],
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withOpacity(0.2),
                ),
                child: Slider(
                  value: controller.position.value.inSeconds.toDouble(),
                  min: 0,
                  max: controller.duration.value.inSeconds.toDouble(),
                  onChanged: (value) {
                    controller.seek(Duration(seconds: value.toInt()));
                  },
                ),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      _formatDuration(controller.position.value),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    )),
                Obx(() => Text(
                      _formatDuration(controller.duration.value),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Obx(() => IconButton(
                icon: Icon(
                  Icons.shuffle,
                  color: controller.isShuffleEnabled.value
                      ? Colors.green
                      : Colors.white,
                ),
                onPressed: controller.toggleShuffle,
              )),
          IconButton(
            icon: const Icon(Icons.skip_previous, color: Colors.white),
            iconSize: 35,
            onPressed: controller.playPrevious,
          ),
          Obx(() => IconButton(
                icon: Icon(
                  controller.isPlaying.value
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white,
                  size: 64,
                ),
                onPressed: controller.togglePlay,
              )),
          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white),
            iconSize: 35,
            onPressed: controller.playNext,
          ),
          Obx(() => IconButton(
                icon: Icon(
                  _getRepeatIcon(),
                  color: controller.repeatMode.value == RepeatMode.off
                      ? Colors.white
                      : Colors.green,
                ),
                onPressed: controller.toggleRepeatMode,
              )),
        ],
      ),
    );
  }

  Widget _buildAdditionalControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () => _addToFavorites(),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () => _showAddToPlaylistDialog(),
              ),
              IconButton(
                icon: const Icon(Icons.queue_music, color: Colors.white),
                onPressed: () => Get.to(() => QueueScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getRepeatIcon() {
    switch (controller.repeatMode.value) {
      case RepeatMode.off:
        return Icons.repeat;
      case RepeatMode.one:
        return Icons.repeat_one;
      case RepeatMode.all:
        return Icons.repeat;
      default:
        return Icons.repeat;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  PopupMenuItem<String> _buildPopupMenuItem(String text, IconData icon) {
    return PopupMenuItem<String>(
      value: text,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToPlaylistDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add to Playlist',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.queue_music, color: Colors.black),
              title: const Text('Add to Queue',
                  style: TextStyle(color: Colors.black)),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Added to Queue',
                  'Song added to queue',
                  backgroundColor: Colors.green.withOpacity(0.7),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Colors.black),
              title: const Text('Add to Playlist',
                  style: TextStyle(color: Colors.black)),
              onTap: () {
                Get.back();
                _showPlaylistSelectionDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaylistSelectionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Playlist'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: const Text('Favorites'),
                onTap: () => _addToFavorites(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToFavorites() async {
    try {
      final response = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/users/me/favorites/${youtubeId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        Get.snackbar(
          'Success',
          'Song added to favorites successfully',
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
        );
      } else {
        throw Exception('Failed to add song to favorites');
      }
    } catch (e) {
      print('Error adding to favorites: $e');
      Get.snackbar(
        'Error',
        'Failed to add song to favorites',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }
}
