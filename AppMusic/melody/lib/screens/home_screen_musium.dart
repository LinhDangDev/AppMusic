import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';

/// Modern Home screen with Musium design
/// Features: Featured content, Now Playing, Browse, Recommendations
class HomeScreenMusium extends StatelessWidget {
  const HomeScreenMusium({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorMusium.darkBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              backgroundColor: AppColorMusium.darkBg,
              elevation: 0,
              floating: true,
              title: Text(
                'Musium',
                style: AppTypographyMusium.heading3.copyWith(
                  color: AppColorMusium.accentTeal,
                  fontWeight: FontWeight.w900,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {},
                  color: AppColorMusium.textPrimary,
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                  color: AppColorMusium.textPrimary,
                ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),

                  // Search bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColorMusium.darkSurfaceLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color:
                            AppColorMusium.textTertiary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search songs, artists...',
                        hintStyle: AppTypographyMusium.bodyMedium.copyWith(
                          color: AppColorMusium.textTertiary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColorMusium.textSecondary,
                        ),
                      ),
                      style: AppTypographyMusium.bodyMedium.copyWith(
                        color: AppColorMusium.textPrimary,
                      ),
                      cursorColor: AppColorMusium.accentTeal,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Featured section
                  Text(
                    'Featured Now',
                    style: AppTypographyMusium.heading4.copyWith(
                      color: AppColorMusium.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Featured card
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColorMusium.accentTeal,
                          AppColorMusium.accentTeal.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -40,
                          bottom: -40,
                          child: Icon(
                            Icons.music_note,
                            size: 200,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'New Release',
                                    style:
                                        AppTypographyMusium.labelSmall.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Summer Vibes',
                                    style:
                                        AppTypographyMusium.heading4.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '24 tracks',
                                    style:
                                        AppTypographyMusium.bodySmall.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: AppColorMusium.accentTeal,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Now playing
                  Text(
                    'Now Playing',
                    style: AppTypographyMusium.heading4.copyWith(
                      color: AppColorMusium.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Now playing card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColorMusium.darkSurfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColorMusium.accentTeal.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Album art placeholder
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColorMusium.accentTeal,
                                AppColorMusium.accentPurple,
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Song info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Awesome Track',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypographyMusium.labelLarge.copyWith(
                                  color: AppColorMusium.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Cool Artist',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypographyMusium.bodySmall.copyWith(
                                  color: AppColorMusium.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Play button
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColorMusium.accentTeal,
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: AppColorMusium.darkBg,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Browse categories
                  Text(
                    'Browse All',
                    style: AppTypographyMusium.heading4.copyWith(
                      color: AppColorMusium.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Category grid
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _categoryCard(
                          'Pop', Icons.music_note, AppColorMusium.accentTeal),
                      _categoryCard('Rock', Icons.electric_bolt,
                          AppColorMusium.accentPurple),
                      _categoryCard(
                          'Jazz', Icons.graphic_eq, AppColorMusium.accentPink),
                      _categoryCard('Classical', Icons.piano,
                          AppColorMusium.accentPurple),
                    ],
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

  Widget _categoryCard(String title, IconData icon, Color color) {
    return Container(
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
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              icon,
              size: 100,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
                Text(
                  title,
                  style: AppTypographyMusium.heading5.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
