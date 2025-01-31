import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'player_screen.dart';
import 'package:melody/constants/app_colors.dart';
import 'package:melody/widgets/bottom_player_nav.dart';
import 'package:melody/models/genre.dart';
import 'package:melody/models/music.dart';
import 'package:melody/provider/music_controller.dart';

class HomeScreen extends GetView<MusicController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.rankings.isEmpty &&
          controller.selectedRegion.value.isEmpty) {
        controller.selectedRegion.value = 'VN';
        controller.loadBiggestHits('VN');
        controller.loadGenres();
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Obx(() {
            if (controller.isLoading.value &&
                controller.rankings.isEmpty &&
                controller.biggestHits.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildContent(context);
          }),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomPlayerNav(currentIndex: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 16.0,
                      bottom: 140.0,
                    ),
                    child: Column(
                      children: [
                        _buildGetYouStarted(),
                        const SizedBox(height: 32),
                        _buildBiggestHits(),
                        const SizedBox(height: 32),
                        _buildRecentlyPlayed(context),
                        const SizedBox(height: 32),
                        _buildGenres(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Good afternoon',
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.black),
          onPressed: () => _showSettingsDrawer(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showSettingsDrawer(BuildContext context) {
    Get.dialog(
      Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: Get.width * 0.85,
          height: Get.height,
          color: Colors.black87,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),
                _buildMenuItems(),
                const Spacer(),
                _buildNotificationsSection(),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        _buildMenuItem(Icons.person_outline, 'Profile'),
        _buildMenuItem(Icons.history, 'Recently played'),
        _buildMenuItem(Icons.settings, 'Settings and privacy'),
        // _buildMenuItem(Icons.logout, 'Logout', onTap: _handleLogout),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {Function()? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black),
      ),
      onTap: onTap ?? () => Get.back(),
    );
  }

  Widget _buildNotificationsSection() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {},
              child: const Text(
                'Upgrade to Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetYouStarted() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Get You Started',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }

            final suggestedSongs = controller.rankings.take(5).toList();
            if (suggestedSongs.isEmpty) {
              return Center(
                child: Text(
                  'No songs available',
                  style: TextStyle(color: Colors.black),
                ),
              );
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: suggestedSongs.length,
              itemBuilder: (context, index) {
                final music = suggestedSongs[index];
                return GestureDetector(
                  onTap: () {
                    controller.playMusic(
                      music,
                      playlist: suggestedSongs,
                      currentIndex: index,
                      playlistName: "Get You Started"
                    );
                  },
                  child: Container(
                    width: 140,
                    margin: EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            music.youtubeThumbnail,
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 140,
                                height: 140,
                                color: Colors.grey[300],
                                child: Icon(Icons.music_note, size: 50),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          music.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          music.artistName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 120,
      color: Colors.grey[300],
      child: const Icon(Icons.music_note),
    );
  }

  Widget _buildRecentlyPlayed(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recently played',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.rankings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final itemCount = controller.rankings.length;
          final pageCount =
              (itemCount / 6).ceil(); // Số trang, mỗi trang 6 items (2x3)

          return SizedBox(
            height: 200, // Chiều cao cố định cho 3 hàng
            child: PageView.builder(
              itemCount: pageCount,
              itemBuilder: (context, pageIndex) {
                return GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 3,
                  ),
                  itemCount: min(
                      6, itemCount - pageIndex * 6), // Mỗi trang tối đa 6 items
                  itemBuilder: (context, index) {
                    final actualIndex = pageIndex * 6 + index;
                    if (actualIndex >= itemCount) return Container();
                    final music = controller.rankings[actualIndex];
                    return RecentMusicCard(
                      imageUrl: music.youtubeThumbnail,
                      title: music.title,
                      subtitle: music.artistName,
                      youtubeId: music.youtubeId,
                    );
                  },
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBiggestHits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Biggest Hits',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() => 
                DropdownButton<String>(
                  value: controller.selectedRegion.value,
                  dropdownColor: Colors.white,
                  style: TextStyle(color: Colors.black),
                  underline: Container(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.selectedRegion.value = newValue;
                      controller.loadBiggestHits(newValue);
                    }
                  },
                  items: [
                    DropdownMenuItem(value: 'VN', child: Text('Vietnam')),
                    DropdownMenuItem(value: 'US', child: Text('US')),
                    DropdownMenuItem(value: 'KR', child: Text('Korea')),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.rankings.isEmpty) {
            return Center(
              child: Text(
                'No rankings available',
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.rankings.length,
            itemBuilder: (context, index) {
              final music = controller.rankings[index];
              return ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          color: index < 3 ? Colors.blue : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        music.youtubeThumbnail,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: Icon(Icons.music_note, color: Colors.grey[700]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                title: Text(
                  music.title,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  music.artistName,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                  onSelected: (value) {
                    switch (value) {
                      case 'play':
                        controller.playMusic(music);
                        break;
                      case 'queue':
                        controller.addToQueue(music);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'play',
                      child: Text('Play Now', style: TextStyle(color: Colors.black)),
                    ),
                    PopupMenuItem(
                      value: 'queue',
                      child: Text('Add to Queue', style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
                onTap: () => controller.playMusic(music),
              );
            },
          );
        }),
      ],
    );
  }

  void _showMusicOptions(BuildContext context, Music music) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Play Now'),
              onTap: () {
                Get.back();
                _playMusic(music);
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue_music),
              title: const Text('Add to Queue'),
              onTap: () {
                controller.addToQueue(music);
                Get.back();
                Get.snackbar(
                  'Added to Queue',
                  music.title,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _playMusic(Music music) {
    final musicController = Get.find<MusicController>();
    musicController.setCurrentQueue(
        playlist: [music], currentIndex: 0, playlistName: "Now Playing");

    Get.to(() => PlayerScreen(
          title: music.title,
          artist: music.artistName,
          imageUrl: music.youtubeThumbnail,
          youtubeId: music.youtubeId,
        ));
  }

  Widget _buildGenres() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Browse genres',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.genres.isEmpty) {
            return const Center(
              child: Text('No genres available'),
            );
          }

          final itemsPerPage = 6; // 3 rows × 2 columns
          final pageCount = (controller.genres.length / itemsPerPage).ceil();

          return SizedBox(
            height: 200, // Chiều cao cố định cho 3 hàng
            child: PageView.builder(
              itemCount: pageCount,
              itemBuilder: (context, pageIndex) {
                final startIndex = pageIndex * itemsPerPage;
                final endIndex =
                    min(startIndex + itemsPerPage, controller.genres.length);
                final pageItems =
                    controller.genres.sublist(startIndex, endIndex);

                return GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: pageItems
                      .map((genre) => GenreCard(genre: genre))
                      .toList(),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRankings() {
    return Obx(() {
      if (controller.rankings.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.rankings.length,
        itemBuilder: (context, index) {
          final music = controller.rankings[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                music.youtubeThumbnail,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[800],
                    child: const Icon(Icons.music_note, color: Colors.white),
                  );
                },
              ),
            ),
            title: Text(
              music.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              music.artistName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () async {
              try {
                final musicController = Get.find<MusicController>();

                // Cập nhật queue với danh sách rankings
                musicController.currentQueue.assignAll(controller.rankings);
                musicController.currentQueueIndex.value = index;

                // Mở player screen
                Get.to(
                  () => PlayerScreen(
                    title: music.title,
                    artist: music.artistName,
                    imageUrl: music.youtubeThumbnail,
                    youtubeId: music.youtubeId,
                  ),
                );

                // Phát nhạc
                await musicController.playMusicDirectly(music);
              } catch (e) {
                print('Error playing ranking music: $e');
                Get.snackbar(
                  'Error',
                  'Failed to play music. Please try again.',
                  backgroundColor: Colors.red.withOpacity(0.7),
                  colorText: Colors.white,
                );
              }
            },
          );
        },
      );
    });
  }

  void _navigateToPlayer(Music song) async {
    final controller = Get.find<MusicController>();

    // Thêm vào queue và cập nhật index
    controller.currentQueue.add(song);
    controller.currentQueueIndex.value = controller.currentQueue.length - 1;

    // Chuyển đến màn hình player
    Get.to(() => PlayerScreen(
          title: song.title,
          artist: song.artistName,
          imageUrl: song.youtubeThumbnail,
          youtubeId: song.youtubeId,
        ));

    // Phát nhạc
    await controller.loadAndPlayMusic(song);
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[800],
        child: Icon(Icons.music_note, color: Colors.white),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[800],
          child: Icon(Icons.music_note, color: Colors.white),
        );
      },
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class MusicCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String youtubeId;
  final bool isCompact;

  const MusicCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.youtubeId,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      // Layout cho grid view (Recently played)
      return GestureDetector(
        onTap: () {
          final music = Music(
            id: '', // Có thể để trống hoặc tạo một ID ngẫu nhiên
            title: title,
            artistName: subtitle,
            youtubeId: youtubeId,
            youtubeThumbnail: imageUrl,
          );

          final controller = Get.find<MusicController>();
          // Thêm vào queue và cập nhật index
          controller.currentQueue.add(music);
          controller.currentQueueIndex.value =
              controller.currentQueue.length - 1;

          // Chuyển đến màn hình player
          Get.to(() => PlayerScreen(
                title: music.title,
                artist: music.artistName,
                imageUrl: music.youtubeThumbnail,
                youtubeId: music.youtubeId,
              ));

          // Phát nhạc
          controller.loadAndPlayMusic(music);
        },
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.queue_music),
                    title: Text('Thêm vào hàng chờ'),
                    onTap: () {
                      final musicController = Get.find<MusicController>();
                      musicController.addToQueue(Music(
                        id: '',
                        title: title,
                        artistName: subtitle,
                        // displayImage: imageUrl,
                        youtubeId: youtubeId,
                        youtubeThumbnail: imageUrl,
                      ));
                      Get.back();
                      Get.snackbar(
                        'Đã thêm vào hàng chờ',
                        title,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey[800],
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.music_note, color: Colors.white);
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Giữ nguyên layout cũ cho horizontal scroll
      return GestureDetector(
        onTap: () {
          Get.to(() => PlayerScreen(
                title: title,
                artist: subtitle,
                imageUrl: imageUrl,
                youtubeId: youtubeId,
              ));
        },
        child: Container(
          width: 180,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: Icon(Icons.music_note, color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class RecentMusicCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String youtubeId;

  const RecentMusicCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.youtubeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title.isNotEmpty &&
            subtitle.isNotEmpty &&
            imageUrl.isNotEmpty &&
            youtubeId.isNotEmpty) {
          final music = Music(
            id: '',
            title: title,
            artistName: subtitle,
            youtubeThumbnail: imageUrl,
            youtubeId: youtubeId,
          );

          final controller = Get.find<MusicController>();
          controller.currentQueue.add(music);
          controller.currentQueueIndex.value =
              controller.currentQueue.length - 1;

          Get.to(() => PlayerScreen(
                title: music.title,
                artist: music.artistName,
                imageUrl: music.youtubeThumbnail,
                youtubeId: music.youtubeId,
              ));

          // Phát nhạc
          controller.loadAndPlayMusic(music);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                bottomLeft: Radius.circular(4),
              ),
              child: SizedBox(
                width: 55,
                height: 55,
                child: Image.network(
                  imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey[800],
                    child: Icon(Icons.music_note, color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GenreCard extends StatelessWidget {
  final Genre genre;

  const GenreCard({Key? key, required this.genre}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getRandomColor(),
            _getRandomColor(),
          ],
        ),
      ),
      child: Row(
        children: [
          // Icon hoặc hình ảnh đại diện cho genre
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Icon(
              _getGenreIcon(genre.name),
              color: Colors.white,
              size: 24,
            ),
          ),
          // Tên genre
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                genre.name,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm trả về màu ngẫu nhiên cho gradient
  Color _getRandomColor() {
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.teal,
      Colors.pink,
      Colors.orange,
      Colors.indigo,
    ];
    // Sử dụng tên genre làm seed để màu không thay đổi mỗi lần rebuild
    final index = genre.name.hashCode % colors.length;
    return colors[index].withOpacity(0.7);
  }

  // Hàm trả về icon phù hợp với từng thể loại
  IconData _getGenreIcon(String genreName) {
    switch (genreName.toLowerCase()) {
      case 'pop':
        return Icons.music_note;
      case 'rock':
        return Icons.audiotrack;
      case 'jazz':
        return Icons.piano;
      case 'classical':
        return Icons.queue_music;
      case 'hip hop':
        return Icons.mic;
      default:
        return Icons.album;
    }
  }
}
