import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/models/music.dart';
import 'package:melody/provider/music_controller.dart';
import 'package:melody/screens/player_screen.dart';
import 'package:flutter/rendering.dart';

class MiniPlayer extends GetView<MusicController> {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.showMiniPlayer.value
        ? GestureDetector(
            onTap: () {
              Get.to(
                () => PlayerScreen(
                  title: controller.currentTitle.value,
                  artist: controller.currentArtist.value,
                  imageUrl: controller.currentImageUrl.value,
                  youtubeId: controller.currentYoutubeId.value,
                ),
                transition: Transition.downToUp,
              );
              controller.showMiniPlayer.value = false;
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Thumbnail với xử lý lỗi
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: Image.network(
                              controller.currentImageUrl.value,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[900],
                                  child: const Icon(
                                    Icons.music_note,
                                    color: Colors.white,
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[900],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Song info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                controller.currentTitle.value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                controller.currentArtist.value,
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
                        // Controls
                        Row(
                          children: [
                            IconButton(
                              icon: Obx(() => Icon(
                                    controller.isPlaying.value
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 28,
                                  )),
                              onPressed: controller.togglePlay,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.skip_next,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: controller.playNext,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : const SizedBox.shrink());
  }
}
