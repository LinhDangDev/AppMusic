import 'package:flutter/material.dart';
import 'package:melody/screens/player_screen.dart';
import 'package:melody/screens/home_screen.dart';
import 'package:melody/screens/search_screen.dart';
import 'package:melody/screens/library_screen.dart';
import 'package:get/get.dart';
import 'package:melody/provider/audio_provider.dart';
import 'package:provider/provider.dart';
import 'package:melody/widgets/mini_player.dart';
import 'package:melody/screens/library_screen.dart';

class BottomPlayerNav extends StatelessWidget {
  final int currentIndex;

  const BottomPlayerNav({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final bool showMiniPlayer = audioProvider.currentSongTitle != null &&
            !Navigator.of(context).widget.toString().contains('PlayerScreen');

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showMiniPlayer)
              MiniPlayer(
                title: audioProvider.currentSongTitle ?? '',
                artist: audioProvider.currentArtist ?? '',
                imageUrl: audioProvider.currentImageUrl ?? '',
                youtubeId: audioProvider.currentYoutubeId ?? '',
                isPlaying: audioProvider.isPlaying,
                onPlayPause: () {
                  if (audioProvider.isPlaying) {
                    audioProvider.pause();
                  } else {
                    audioProvider.resume();
                  }
                },
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
                  ],
                  onTap: (index) => _handleNavigation(context, index),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) return;

    final screens = [
      const HomeScreen(),
      const SearchScreen(),
      LibraryScreen(),
    ];

    Get.offAll(
      () => screens[index],
      transition: Transition.noTransition,
      duration: Duration.zero,
      popGesture: false,
      id: null,
    );
  }
}
