import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';

/// Explore Screen with Genre/Category Grid
class ExploreScreenMusium extends StatelessWidget {
  const ExploreScreenMusium({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> genres = const [
    {'title': 'Pop', 'icon': Icons.star, 'color': 0xFF00C8C8},
    {'title': 'Rock', 'icon': Icons.electric_bolt, 'color': 0xFFB83DFF},
    {'title': 'Jazz', 'icon': Icons.graphic_eq, 'color': 0xFFFF00FF},
    {'title': 'Classical', 'icon': Icons.piano, 'color': 0xFF00E6E6},
    {'title': 'Hip-Hop', 'icon': Icons.mic, 'color': 0xFFFF6B6B},
    {'title': 'Electronic', 'icon': Icons.music_note, 'color': 0xFF4ECDC4},
    {'title': 'R&B', 'icon': Icons.heart_broken, 'color': 0xFFE91E63},
    {'title': 'Indie', 'icon': Icons.music_note, 'color': 0xFF9D4EDD},
    {'title': 'Country', 'icon': Icons.landscape, 'color': 0xFFD4A574},
    {'title': 'Reggae', 'icon': Icons.toys, 'color': 0xFF4CAF50},
    {'title': 'Blues', 'icon': Icons.album, 'color': 0xFF6C63FF},
    {'title': 'Metal', 'icon': Icons.flash_on, 'color': 0xFFFF7675},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorMusium.darkBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              backgroundColor: AppColorMusium.darkBg,
              elevation: 0,
              floating: true,
              title: Text(
                'Explore',
                style: AppTypographyMusium.heading3.copyWith(
                  color: AppColorMusium.accentTeal,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),

                  // Section title
                  Text(
                    'Browse Genres',
                    style: AppTypographyMusium.heading4.copyWith(
                      color: AppColorMusium.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Genre grid
                  GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: genres.length,
                    itemBuilder: (context, index) {
                      final genre = genres[index];
                      return _genreCard(
                        title: genre['title'],
                        icon: genre['icon'],
                        color: Color(genre['color']),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genreCard(
      {required String title, required IconData icon, required Color color}) {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          title,
          'Navigate to $title genre',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColorMusium.darkSurfaceLight,
          colorText: AppColorMusium.textPrimary,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.8),
              color.withValues(alpha: 0.4),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background icon
            Positioned(
              right: -15,
              bottom: -15,
              child: Icon(
                icon,
                size: 120,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  // Title
                  Text(
                    title,
                    style: AppTypographyMusium.heading5.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
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
