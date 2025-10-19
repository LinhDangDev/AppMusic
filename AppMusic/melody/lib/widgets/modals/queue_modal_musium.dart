import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';

/// Queue Modal - Full screen queue list with drag reorder
class QueueModalMusium extends StatefulWidget {
  final int currentTrackIndex;

  const QueueModalMusium({
    Key? key,
    required this.currentTrackIndex,
  }) : super(key: key);

  @override
  State<QueueModalMusium> createState() => _QueueModalMusiumState();
}

class _QueueModalMusiumState extends State<QueueModalMusium> {
  late List<Map<String, String>> queueTracks;

  @override
  void initState() {
    super.initState();
    // Initialize sample queue
    queueTracks = List.generate(
      15,
      (index) => {
        'title': 'Track ${index + 1}',
        'artist': 'Artist Name ${(index % 5) + 1}',
        'duration': '${3 + (index % 3)}:${45 - (index % 30)}',
      },
    );
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Queue',
                  style: AppTypographyMusium.heading4.copyWith(
                    color: AppColorMusium.accentTeal,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${queueTracks.length} songs',
                  style: AppTypographyMusium.bodySmall.copyWith(
                    color: AppColorMusium.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            color: AppColorMusium.textTertiary,
            height: 1,
          ),

          // Queue list
          Expanded(
            child: ReorderableListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = queueTracks.removeAt(oldIndex);
                  queueTracks.insert(newIndex, item);
                });
              },
              children: List.generate(
                queueTracks.length,
                (index) => _buildQueueItem(index),
              ),
            ),
          ),

          // Clear queue button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColorMusium.error,
                  width: 2,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColorMusium.darkSurface,
                        title: Text(
                          'Clear Queue?',
                          style: AppTypographyMusium.heading5.copyWith(
                            color: AppColorMusium.textPrimary,
                          ),
                        ),
                        content: Text(
                          'This will remove all songs from the queue.',
                          style: AppTypographyMusium.bodyMedium.copyWith(
                            color: AppColorMusium.textSecondary,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: AppTypographyMusium.labelMedium.copyWith(
                                color: AppColorMusium.accentTeal,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() => queueTracks.clear());
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Clear',
                              style: AppTypographyMusium.labelMedium.copyWith(
                                color: AppColorMusium.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: AppColorMusium.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Clear Queue',
                        style: AppTypographyMusium.labelLarge.copyWith(
                          color: AppColorMusium.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueItem(int index) {
    final track = queueTracks[index];
    final isCurrentTrack = index == widget.currentTrackIndex;

    return Container(
      key: ValueKey(index),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isCurrentTrack
            ? AppColorMusium.accentTeal.withValues(alpha: 0.2)
            : AppColorMusium.darkSurfaceLight.withValues(alpha: 0.5),
        border: isCurrentTrack
            ? Border.all(
                color: AppColorMusium.accentTeal,
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          // Drag handle
          ReorderableDragStartListener(
            index: index,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isCurrentTrack
                    ? AppColorMusium.accentTeal.withValues(alpha: 0.3)
                    : AppColorMusium.darkSurface,
              ),
              child: Icon(
                Icons.drag_handle,
                color: isCurrentTrack
                    ? AppColorMusium.accentTeal
                    : AppColorMusium.textSecondary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Track info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        track['title'] ?? '',
                        style: AppTypographyMusium.bodyMedium.copyWith(
                          color: isCurrentTrack
                              ? AppColorMusium.accentTeal
                              : AppColorMusium.textPrimary,
                          fontWeight: isCurrentTrack ? FontWeight.w600 : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentTrack)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.play_circle_filled,
                          color: AppColorMusium.accentTeal,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  track['artist'] ?? '',
                  style: AppTypographyMusium.bodySmall.copyWith(
                    color: AppColorMusium.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Duration & remove button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                track['duration'] ?? '',
                style: AppTypographyMusium.bodySmall.copyWith(
                  color: AppColorMusium.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  setState(() => queueTracks.removeAt(index));
                },
                child: Icon(
                  Icons.close,
                  color: AppColorMusium.textSecondary,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Show queue modal bottom sheet
Future<void> showQueueModal(
  BuildContext context, {
  required int currentTrackIndex,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => QueueModalMusium(
        currentTrackIndex: currentTrackIndex,
      ),
    ),
  );
}
