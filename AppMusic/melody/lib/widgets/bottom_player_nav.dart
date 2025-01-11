import 'package:flutter/material.dart';
import 'package:melody/screens/home_screen.dart';
import 'package:melody/screens/search_screen.dart';
import 'package:melody/screens/library_screen.dart';
import 'package:get/get.dart';

import 'package:melody/widgets/mini_player.dart';

import 'package:melody/provider/music_controller.dart';

class BottomPlayerNav extends GetView<MusicController> {
  final int currentIndex;

  const BottomPlayerNav({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mini Player
        Obx(() => controller.showMiniPlayer.value &&
                controller.currentTitle.value.isNotEmpty
            ? const MiniPlayer()
            : const SizedBox.shrink()),

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
