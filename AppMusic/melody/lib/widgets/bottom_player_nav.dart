import 'package:flutter/material.dart';
import 'package:melody/screens/player_screen.dart';
import 'package:melody/screens/home_screen.dart';
import 'package:melody/screens/search_screen.dart';
import 'package:melody/screens/library_screen.dart';
import 'package:melody/screens/premium_screen.dart';
import 'package:get/get.dart';

class BottomPlayerNav extends StatelessWidget {
  final int currentIndex;
  final bool isPlaying;
  final String? songTitle;
  final String? artistName;
  final String? imageUrl;
  final String? youtubeId;
  final VoidCallback? onPlayPause;
  final VoidCallback? onTapPlayer;

  const BottomPlayerNav({
    Key? key,
    required this.currentIndex,
    this.isPlaying = false,
    this.songTitle,
    this.artistName,
    this.imageUrl,
    this.youtubeId,
    this.onPlayPause,
    this.onTapPlayer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mini Player
        if (songTitle != null)
          GestureDetector(
            onTap: () {
              if (songTitle != null &&
                  artistName != null &&
                  imageUrl != null &&
                  youtubeId != null) {
                Get.to(() => PlayerScreen(
                      title: songTitle!,
                      artist: artistName!,
                      imageUrl: imageUrl!,
                      youtubeId: youtubeId!,
                    ));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[800]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Album Art
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 40,
                                height: 40,
                                color: Colors.grey[800],
                                child: const Icon(Icons.music_note,
                                    color: Colors.white),
                              );
                            },
                          )
                        : Container(
                            width: 40,
                            height: 40,
                            color: Colors.grey[800],
                            child: const Icon(Icons.music_note,
                                color: Colors.white),
                          ),
                  ),
                  const SizedBox(width: 12),

                  // Song Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          songTitle ?? 'No song playing',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          artistName ?? 'Unknown artist',
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

                  // Play/Pause Button
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: onPlayPause,
                  ),
                ],
              ),
            ),
          ),

        // Bottom Navigation Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(25),
          ),
          margin: const EdgeInsets.all(16),
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 28),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search, size: 28),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_music, size: 28),
                  label: 'Your Library',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person, size: 28),
                  label: 'Premium',
                ),
              ],
              onTap: (index) => _handleNavigation(context, index),
            ),
          ),
        ),
      ],
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) return;

    final screens = [
      const HomeScreen(),
      SearchScreen(),
      LibraryScreen(),
      const PremiumScreen(),
    ];

    Get.to(() => screens[index], preventDuplicates: false);
  }
}
