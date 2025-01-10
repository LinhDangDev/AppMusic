import 'package:flutter/material.dart';
import 'package:melody/screens/player_screen.dart';
import 'package:melody/screens/home_screen.dart';
import 'package:melody/screens/search_screen.dart';
import 'package:melody/screens/library_screen.dart';
import 'package:melody/screens/premium_screen.dart';

class BottomPlayerNav extends StatelessWidget {
  final int currentIndex;
  final bool isPlaying;
  final String? currentSongTitle;
  final String? currentArtist;
  final String? currentImageUrl;
  final VoidCallback? onPlayPause;
  final VoidCallback? onTapPlayer;

  const BottomPlayerNav({
    Key? key,
    required this.currentIndex,
    this.isPlaying = false,
    this.currentSongTitle,
    this.currentArtist,
    this.currentImageUrl,
    this.onPlayPause,
    this.onTapPlayer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mini Player
        if (currentSongTitle != null)
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerScreen(
                  songTitle: currentSongTitle,
                  artistName: currentArtist,
                  imageUrl: currentImageUrl,
                  isPlaying: isPlaying,
                  onPlayPause: onPlayPause,
                ),
              ),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    child: Image.asset(
                      currentImageUrl ?? 'assets/playlist1.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12),
                  
                  // Song Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentSongTitle ?? 'No song playing',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          currentArtist ?? 'Unknown artist',
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
          margin: EdgeInsets.all(16),
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
              items: [
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
      HomeScreen(),
      SearchScreen(),
      LibraryScreen(),
      PremiumScreen(),
    ];

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screens[index],
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(index > currentIndex ? 1.0 : -1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }
} 