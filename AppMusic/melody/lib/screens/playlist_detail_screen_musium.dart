import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';

/// Playlist Detail Screen
/// Shows full playlist info and all tracks
class PlaylistDetailScreenMusium extends StatelessWidget {
  final String playlistName;
  final String playlistImage;
  final Color playlistColor;

  const PlaylistDetailScreenMusium({
    Key? key,
    required this.playlistName,
    required this.playlistImage,
    required this.playlistColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorMusium.darkBg,
      body: CustomScrollView(
        slivers: [
          // Header with gradient background
          SliverAppBar(
            backgroundColor: playlistColor.withValues(alpha: 0.3),
            elevation: 0,
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      playlistColor.withValues(alpha: 0.4),
                      AppColorMusium.darkBg,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Playlist image
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            playlistColor,
                            playlistColor.withValues(alpha: 0.5)
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: playlistColor.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.music_note,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Playlist name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        playlistName,
                        textAlign: TextAlign.center,
                        style: AppTypographyMusium.heading2.copyWith(
                          color: AppColorMusium.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Playlist info
                    Text(
                      '42 songs • 3.2 hours',
                      style: AppTypographyMusium.bodyMedium.copyWith(
                        color: AppColorMusium.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColorMusium.darkSurface.withValues(alpha: 0.8),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColorMusium.textPrimary,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColorMusium.darkSurface.withValues(alpha: 0.8),
                  ),
                  child: Icon(
                    Icons.more_vert,
                    color: AppColorMusium.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Play button
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        playlistColor,
                        playlistColor.withValues(alpha: 0.7)
                      ],
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Play All',
                            style: AppTypographyMusium.labelLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Tracks section
                Text(
                  'Songs',
                  style: AppTypographyMusium.heading5.copyWith(
                    color: AppColorMusium.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                // Track list
                ..._buildTrackList(),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTrackList() {
    return List.generate(
      10,
      (index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColorMusium.darkSurfaceLight.withValues(alpha: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: [
                    playlistColor,
                    playlistColor.withValues(alpha: 0.5),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTypographyMusium.labelMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track Title ${index + 1}',
                    style: AppTypographyMusium.bodyMedium.copyWith(
                      color: AppColorMusium.textPrimary,
                    ),
                  ),
                  Text(
                    'Artist Name',
                    style: AppTypographyMusium.bodySmall.copyWith(
                      color: AppColorMusium.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '3:45',
              style: AppTypographyMusium.bodySmall.copyWith(
                color: AppColorMusium.textTertiary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.more_vert,
              color: AppColorMusium.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
