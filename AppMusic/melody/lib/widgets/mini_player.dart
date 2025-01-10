import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/screens/player_screen.dart';
import 'package:melody/provider/audio_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';

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
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
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
            height: 64,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.grey[800]!.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.music_note,
                                      color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title ?? 'No song playing',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              artist ?? 'Unknown artist',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: onPlayPause,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
