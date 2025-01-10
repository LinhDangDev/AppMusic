import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/provider/music_controller.dart';

class QueueScreen extends GetView<MusicController> {
  const QueueScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ĐANG PHÁT',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
            Obx(() => Text(
                  controller.currentPlaylistName.value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                )),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                      'Đang phát từ ${controller.currentPlaylistName.value}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                SizedBox(height: 4),
                Obx(() => Text(
                      '${controller.currentQueue.length} bài hát',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: controller.currentQueue.length,
                  itemBuilder: (context, index) {
                    final music = controller.currentQueue[index];
                    final isPlaying =
                        index == controller.currentQueueIndex.value;

                    return ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 30,
                            child: isPlaying
                                ? _buildPlayingAnimation()
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isPlaying
                                          ? Colors.green
                                          : Colors.grey,
                                      fontWeight: isPlaying
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              music.youtubeThumbnail,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                      title: Text(
                        music.title,
                        style: TextStyle(
                          color: isPlaying ? Colors.green : Colors.black,
                          fontWeight:
                              isPlaying ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        music.artistName,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      onTap: () {
                        controller.playFromQueue(index);
                        Get.back(); // Quay lại màn hình player
                      },
                      trailing: IconButton(
                        icon: Icon(Icons.more_vert, color: Colors.black),
                        onPressed: () {},
                      ),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayingAnimation() {
    return SizedBox(
      width: 30,
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          3,
          (index) => _buildAnimatedBar(index),
        ),
      ),
    );
  }

  Widget _buildAnimatedBar(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 2.0, end: 15.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 2,
          height: value,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      },
    );
  }
}
