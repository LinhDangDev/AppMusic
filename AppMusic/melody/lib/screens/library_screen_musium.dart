import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';

/// Library Screen with Tabs
class LibraryScreenMusium extends StatefulWidget {
  const LibraryScreenMusium({Key? key}) : super(key: key);

  @override
  State<LibraryScreenMusium> createState() => _LibraryScreenMusiumState();
}

class _LibraryScreenMusiumState extends State<LibraryScreenMusium>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorMusium.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Your Library',
                style: AppTypographyMusium.heading3.copyWith(
                  color: AppColorMusium.accentTeal,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            // Tabs
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColorMusium.textTertiary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColorMusium.accentTeal,
                indicatorWeight: 3,
                labelColor: AppColorMusium.accentTeal,
                unselectedLabelColor: AppColorMusium.textSecondary,
                labelStyle: AppTypographyMusium.labelLarge,
                unselectedLabelStyle: AppTypographyMusium.labelMedium,
                tabs: const [
                  Tab(text: 'Playlists'),
                  Tab(text: 'Downloaded'),
                  Tab(text: 'Recently Played'),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Playlists tab
                  _buildPlaylistsTab(),

                  // Downloaded tab
                  _buildDownloadedTab(),

                  // Recently Played tab
                  _buildRecentlyPlayedTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _playlistCard('Favorites', '23 songs', Colors.red),
        _playlistCard('Workout Mix', '15 songs', Colors.orange),
        _playlistCard('Chill Vibes', '45 songs', Colors.blue),
        _playlistCard('Road Trip', '38 songs', Colors.purple),
      ],
    );
  }

  Widget _buildDownloadedTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _downloadedTrack('Song 1', 'Artist Name', '4:32'),
        _downloadedTrack('Song 2', 'Artist Name', '3:45'),
        _downloadedTrack('Song 3', 'Artist Name', '5:12'),
      ],
    );
  }

  Widget _buildRecentlyPlayedTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _recentTrack('Recently Played 1', 'Artist', '2 hours ago'),
        _recentTrack('Recently Played 2', 'Artist', '5 hours ago'),
        _recentTrack('Recently Played 3', 'Artist', 'Yesterday'),
      ],
    );
  }

  Widget _playlistCard(String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColorMusium.darkSurfaceLight,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withValues(alpha: 0.5)],
              ),
            ),
            child: Icon(
              Icons.music_note,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypographyMusium.labelLarge.copyWith(
                    color: AppColorMusium.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypographyMusium.bodySmall.copyWith(
                    color: AppColorMusium.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.play_circle_filled,
            color: AppColorMusium.accentTeal,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _downloadedTrack(String title, String artist, String duration) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColorMusium.darkSurfaceLight.withValues(alpha: 0.5),
      ),
      child: Row(
        children: [
          Icon(
            Icons.download_done,
            color: AppColorMusium.accentTeal,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypographyMusium.bodyMedium.copyWith(
                    color: AppColorMusium.textPrimary,
                  ),
                ),
                Text(
                  artist,
                  style: AppTypographyMusium.bodySmall.copyWith(
                    color: AppColorMusium.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            duration,
            style: AppTypographyMusium.bodySmall.copyWith(
              color: AppColorMusium.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentTrack(String title, String artist, String time) {
    return Container(
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
              color: AppColorMusium.accentTeal.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.music_note,
              color: AppColorMusium.accentTeal,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypographyMusium.bodyMedium.copyWith(
                    color: AppColorMusium.textPrimary,
                  ),
                ),
                Text(
                  artist,
                  style: AppTypographyMusium.bodySmall.copyWith(
                    color: AppColorMusium.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTypographyMusium.bodySmall.copyWith(
              color: AppColorMusium.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
