import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';

/// Add to Playlist Modal
class AddToPlaylistModalMusium extends StatefulWidget {
  final String songTitle;
  final String artistName;

  const AddToPlaylistModalMusium({
    Key? key,
    required this.songTitle,
    required this.artistName,
  }) : super(key: key);

  @override
  State<AddToPlaylistModalMusium> createState() =>
      _AddToPlaylistModalMusiumState();
}

class _AddToPlaylistModalMusiumState extends State<AddToPlaylistModalMusium> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> playlists = [];
  List<Map<String, dynamic>> filteredPlaylists = [];
  Set<String> selectedPlaylists = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Initialize sample playlists
    playlists = [
      {'name': 'Favorites', 'count': 45, 'id': '1'},
      {'name': 'Workout Mix', 'count': 28, 'id': '2'},
      {'name': 'Chill Vibes', 'count': 62, 'id': '3'},
      {'name': 'Road Trip', 'count': 38, 'id': '4'},
      {'name': 'Study Session', 'count': 51, 'id': '5'},
      {'name': 'Party Hits', 'count': 73, 'id': '6'},
      {'name': 'Sleep Sounds', 'count': 25, 'id': '7'},
      {'name': 'New Discoveries', 'count': 19, 'id': '8'},
    ];

    filteredPlaylists = List.from(playlists);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPlaylists(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPlaylists = List.from(playlists);
      } else {
        filteredPlaylists = playlists
            .where((p) => p['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorMusium.darkBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: AppColorMusium.textTertiary.withValues(alpha: 0.3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add to Playlist',
                  style: AppTypographyMusium.heading4.copyWith(
                    color: AppColorMusium.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.songTitle} • ${widget.artistName}',
                  style: AppTypographyMusium.bodySmall.copyWith(
                    color: AppColorMusium.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const Divider(
            color: AppColorMusium.textTertiary,
            height: 1,
          ),

          const SizedBox(height: 12),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColorMusium.darkSurfaceLight,
                border: Border.all(
                  color: AppColorMusium.textTertiary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterPlaylists,
                decoration: InputDecoration(
                  hintText: 'Search playlists...',
                  hintStyle: AppTypographyMusium.bodyMedium.copyWith(
                    color: AppColorMusium.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColorMusium.textSecondary,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _filterPlaylists('');
                          },
                          child: Icon(
                            Icons.close,
                            color: AppColorMusium.textSecondary,
                            size: 20,
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

          const SizedBox(height: 12),

          // Playlists list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredPlaylists.length,
              itemBuilder: (context, index) =>
                  _buildPlaylistItem(filteredPlaylists[index]),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Cancel button
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColorMusium.textSecondary,
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: AppTypographyMusium.labelLarge.copyWith(
                              color: AppColorMusium.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Add button
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          AppColorMusium.accentTeal,
                          AppColorMusium.accentPurple,
                        ],
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: selectedPlaylists.isEmpty
                            ? null
                            : () {
                                // Handle add to playlists
                                Navigator.pop(context, selectedPlaylists);
                              },
                        child: Center(
                          child: Text(
                            'Add (${selectedPlaylists.length})',
                            style: AppTypographyMusium.labelLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildPlaylistItem(Map<String, dynamic> playlist) {
    final isSelected = selectedPlaylists.contains(playlist['id']);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedPlaylists.remove(playlist['id']);
          } else {
            selectedPlaylists.add(playlist['id']);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? AppColorMusium.accentTeal.withValues(alpha: 0.2)
              : AppColorMusium.darkSurfaceLight.withValues(alpha: 0.5),
          border: isSelected
              ? Border.all(
                  color: AppColorMusium.accentTeal,
                  width: 2,
                )
              : null,
        ),
        child: Row(
          children: [
            // Playlist icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorMusium.accentTeal.withValues(alpha: 0.6),
                    AppColorMusium.accentPurple.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Icon(
                Icons.music_note,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Playlist info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist['name'],
                    style: AppTypographyMusium.bodyMedium.copyWith(
                      color: isSelected
                          ? AppColorMusium.accentTeal
                          : AppColorMusium.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${playlist['count']} songs',
                    style: AppTypographyMusium.bodySmall.copyWith(
                      color: AppColorMusium.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColorMusium.accentTeal
                      : AppColorMusium.textSecondary,
                  width: 2,
                ),
                color:
                    isSelected ? AppColorMusium.accentTeal : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Show add to playlist modal
Future<Set<String>?> showAddToPlaylistModal(
  BuildContext context, {
  required String songTitle,
  required String artistName,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => AddToPlaylistModalMusium(
        songTitle: songTitle,
        artistName: artistName,
      ),
    ),
  );
}
