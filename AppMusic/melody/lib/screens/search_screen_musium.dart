import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';

/// Search Screen with Trending & Results
class SearchScreenMusium extends StatefulWidget {
  const SearchScreenMusium({Key? key}) : super(key: key);

  @override
  State<SearchScreenMusium> createState() => _SearchScreenMusiumState();
}

class _SearchScreenMusiumState extends State<SearchScreenMusium> {
  late TextEditingController _searchController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorMusium.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColorMusium.darkSurfaceLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isSearching
                        ? AppColorMusium.accentTeal
                        : AppColorMusium.textTertiary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _isSearching = value.isNotEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search songs, artists, albums...',
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
                    suffixIcon: _isSearching
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _isSearching = false);
                            },
                            child: Icon(
                              Icons.clear,
                              color: AppColorMusium.textSecondary,
                            ),
                          )
                        : null,
                  ),
                  style: AppTypographyMusium.bodyMedium.copyWith(
                    color: AppColorMusium.textPrimary,
                  ),
                  cursorColor: AppColorMusium.accentTeal,
                ),
              ),
            ),

            // Content
            Expanded(
              child: _isSearching ? _buildSearchResults() : _buildTrending(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrending() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Section title
        Text(
          'Trending Now',
          style: AppTypographyMusium.heading4.copyWith(
            color: AppColorMusium.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Trending tracks
        _trendingTrack('1', 'Hit Song 1', 'Artist Name', Colors.red),
        _trendingTrack('2', 'Hit Song 2', 'Artist Name', Colors.orange),
        _trendingTrack('3', 'Hit Song 3', 'Artist Name', Colors.blue),
        _trendingTrack('4', 'Hit Song 4', 'Artist Name', Colors.purple),
        _trendingTrack('5', 'Hit Song 5', 'Artist Name', Colors.green),
      ],
    );
  }

  Widget _buildSearchResults() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Results found
        Text(
          'Results for "${_searchController.text}"',
          style: AppTypographyMusium.heading5.copyWith(
            color: AppColorMusium.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Result tracks
        _resultTrack('Result 1', 'Artist Name'),
        _resultTrack('Result 2', 'Artist Name'),
        _resultTrack('Result 3', 'Artist Name'),
        _resultTrack('Result 4', 'Artist Name'),
      ],
    );
  }

  Widget _trendingTrack(String rank, String title, String artist, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColorMusium.darkSurfaceLight,
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.5)],
              ),
            ),
            child: Center(
              child: Text(
                rank,
                style: AppTypographyMusium.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
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

          // Play button
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColorMusium.accentTeal.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.play_arrow,
              color: AppColorMusium.accentTeal,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultTrack(String title, String artist) {
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: AppColorMusium.accentTeal.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.music_note,
              color: AppColorMusium.accentTeal,
              size: 22,
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
          Icon(
            Icons.more_vert,
            color: AppColorMusium.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
