import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/screens/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  final String? title;
  final String? artist;
  final String? imageUrl;
  final String? youtubeId;
  final bool isPlaying;
  final VoidCallback? onPlayPause;

  const MiniPlayer({
    Key? key,
    this.title,
    this.artist,
    this.imageUrl,
    this.youtubeId,
    this.isPlaying = false,
    this.onPlayPause,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title != null &&
            artist != null &&
            imageUrl != null &&
            youtubeId != null) {
          Get.to(() => PlayerScreen(
                title: title!,
                artist: artist!,
                imageUrl: imageUrl!,
                youtubeId: youtubeId!,
              ));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border(
            top: BorderSide(
              color: Colors.grey[800]!,
              width: 0.5,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Album Art
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey[800],
                          child:
                              const Icon(Icons.music_note, color: Colors.white),
                        );
                      },
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[800],
                      child: const Icon(Icons.music_note, color: Colors.white),
                    ),
            ),
            const SizedBox(width: 12),

            // Song Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title ?? 'No song playing',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    artist ?? 'Unknown artist',
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

            // Controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
          ],
        ),
      ),
    );
  }
}
