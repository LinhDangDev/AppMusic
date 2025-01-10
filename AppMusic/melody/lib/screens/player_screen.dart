import 'package:flutter/material.dart';
// import 'package:audio_service/audio_service.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:melody/provider/audio_provider.dart';
// import 'package:melody/services/audio_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;


import 'package:melody/screens/Queue_screen.dart';
import 'package:melody/provider/music_controller.dart';
import 'package:melody/constants/api_constants.dart';

class PlayerScreen extends StatefulWidget {
  final String title;
  final String artist;
  final String imageUrl;
  final String youtubeId;

  const PlayerScreen({
    Key? key,
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.youtubeId,
  }) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioProvider audioProvider;
  final MusicController controller = Get.find<MusicController>();

  @override
  void initState() {
    super.initState();
    audioProvider = Provider.of<AudioProvider>(context, listen: false);
    _checkAndInitializeAudio();
  }

  void _checkAndInitializeAudio() async {
    if (audioProvider.currentYoutubeId != widget.youtubeId) {
      await audioProvider.playYoutubeAudio(
        widget.youtubeId,
        title: widget.title,
        artist: widget.artist,
        imageUrl: widget.imageUrl,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AudioProvider>(
        builder: (context, audioProvider, child) {
          return Stack(
            children: [
              // Background với thumbnail được blur
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),
              // Content
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
                      // App Bar
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.keyboard_arrow_down,
                                  color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Text(
                              'ĐANG PHÁT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, color: Colors.white),
                              color: Colors.grey[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              itemBuilder: (BuildContext context) => [
                                _buildPopupMenuItem(
                                    'Thích', Icons.favorite_outline),
                                _buildPopupMenuItem(
                                    'Tải xuống', Icons.download_outlined),
                                _buildPopupMenuItem(
                                    'Thêm danh sách phát', Icons.playlist_add),
                                _buildPopupMenuItem('Phát tiếp theo',
                                    Icons.play_circle_outline),
                                _buildPopupMenuItem(
                                    'Thêm vào hàng đợi', Icons.queue_music),
                                _buildPopupMenuItem(
                                    'Nghệ sĩ', Icons.person_outline),
                                _buildPopupMenuItem(
                                    'Không có album', Icons.album_outlined),
                                _buildPopupMenuItem(
                                    'Bắt đầu đài phát', Icons.radio_outlined),
                                _buildPopupMenuItem(
                                    'Nguồn cung cấp lời bài hát chính',
                                    Icons.lyrics_outlined),
                                _buildPopupMenuItem(
                                    'Hẹn giờ ngủ', Icons.bedtime_outlined),
                                _buildPopupMenuItem(
                                    'Chia sẻ', Icons.share_outlined),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Album Art
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
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
                              child: Image.network(
                                widget.imageUrl,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[900],
                                    child: Icon(
                                      Icons.music_note,
                                      color: Colors.white,
                                      size: 64,
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Song Info
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            // Song Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    widget.artist,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Like Button
                            IconButton(
                              icon: Icon(Icons.favorite_border,
                                  color: Colors.white),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),

                      // Progress Bar
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 2,
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 6),
                                overlayShape:
                                    RoundSliderOverlayShape(overlayRadius: 14),
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.grey[800],
                                thumbColor: Colors.white,
                                overlayColor: Colors.white.withOpacity(0.2),
                              ),
                              child: Slider(
                                value:
                                    audioProvider.position.inSeconds.toDouble(),
                                min: 0,
                                max:
                                    audioProvider.duration.inSeconds.toDouble(),
                                onChanged: (value) {
                                  final position =
                                      Duration(seconds: value.toInt());
                                  audioProvider.seek(position);
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(audioProvider.position),
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 12),
                                  ),
                                  Text(
                                    _formatDuration(audioProvider.duration),
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Controls
                      Padding(
                        padding: EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Shuffle button with 3 states
                            IconButton(
                              icon: audioProvider.isSmartShuffleEnabled
                                  ? ImageIcon(
                                      AssetImage(
                                          'assets/icons/smart_shuffle.png'),
                                      color: Colors.green,
                                    )
                                  : Icon(
                                      Icons.shuffle,
                                      color: audioProvider.isShuffleEnabled
                                          ? Colors.green
                                          : Colors.white,
                                    ),
                              onPressed: () {
                                if (!audioProvider.isShuffleEnabled &&
                                    !audioProvider.isSmartShuffleEnabled) {
                                  // Trạng thái 1: Off -> Shuffle thường
                                  audioProvider.toggleShuffle();
                                } else if (audioProvider.isShuffleEnabled) {
                                  // Trạng thái 2: Shuffle thường -> Smart shuffle
                                  audioProvider
                                      .toggleShuffle(); // tắt shuffle thường
                                  audioProvider
                                      .toggleSmartShuffle(); // bật smart shuffle
                                } else {
                                  // Trạng thái 3: Smart shuffle -> Off
                                  audioProvider.toggleSmartShuffle();
                                }
                              },
                            ),

                            // Previous button
                            IconButton(
                              icon: Icon(Icons.skip_previous,
                                  color: Colors.white),
                              onPressed: audioProvider.playPrevious,
                            ),

                            // Play/Pause button
                            IconButton(
                              icon: Icon(
                                audioProvider.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                size: 64,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (audioProvider.isPlaying) {
                                  audioProvider.pause();
                                } else {
                                  audioProvider.resume();
                                }
                              },
                            ),

                            // Next button
                            IconButton(
                              icon: Icon(Icons.skip_next, color: Colors.white),
                              onPressed: audioProvider.playNext,
                            ),

                            // Repeat button
                            IconButton(
                              icon: Icon(
                                audioProvider.repeatMode == RepeatMode.off
                                    ? Icons.repeat
                                    : audioProvider.repeatMode ==
                                            RepeatMode.single
                                        ? Icons.repeat_one
                                        : Icons.repeat,
                                color:
                                    audioProvider.repeatMode == RepeatMode.off
                                        ? Colors.white
                                        : Colors.green,
                              ),
                              onPressed: audioProvider.toggleRepeatMode,
                            ),
                          ],
                        ),
                      ),

                      // Thêm row mới cho các nút bổ sung
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.favorite_border,
                                  color: Colors.white),
                              onPressed: () {
                                // TODO: Thêm vào playlist yêu thích
                                Get.snackbar(
                                  'Added to Favorites',
                                  'Song added to your Favorites playlist',
                                  backgroundColor:
                                      Colors.green.withOpacity(0.7),
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.TOP,
                                  duration: Duration(seconds: 2),
                                );
                              },
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.add, color: Colors.white),
                                  onPressed: () {
                                    // TODO: Thêm vào playlist
                                    _showAddToPlaylistDialog();
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.queue_music,
                                      color: Colors.white),
                                  onPressed: () => Get.to(() => QueueScreen()),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
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
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Thêm method để hiển thị dialog thêm vào playlist
  void _showAddToPlaylistDialog() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add to Playlist',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.queue_music, color: Colors.black),
              title:
                  Text('Add to Queue', style: TextStyle(color: Colors.black)),
              onTap: () {
                // TODO: Thêm vào queue
                Get.back();
                Get.snackbar(
                  'Added to Queue',
                  'Song added to queue',
                  backgroundColor: Colors.green.withOpacity(0.7),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                  duration: Duration(seconds: 2),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.playlist_add, color: Colors.black),
              title: Text('Add to Playlist',
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

  // Thêm method để hiển thị dialog chọn playlist
  void _showPlaylistSelectionDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Select Playlist'),
        content: Container(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: Icon(Icons.favorite, color: Colors.red),
                title: Text('Favorites'),
                onTap: () async {
                  try {
                    // Thay đổi endpoint và body format
                    final response = await http.post(
                      Uri.parse('${ApiConstants.baseUrl}/api/users/me/favorites/${widget.youtubeId}'),
                      headers: {
                        'Content-Type': 'application/json',
                      },
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
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
