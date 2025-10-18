import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/provider/music_controller.dart';

class QueueScreen extends GetView<MusicController> {
  const QueueScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
        backgroundColor: Colors.black87,
      ),
      body: Obx(() {
        if (controller.currentQueue.isEmpty) {
          return const Center(
            child: Text('Queue is empty'),
          );
        }

        return ListView.builder(
          itemCount: controller.currentQueue.length,
          itemBuilder: (context, index) {
            final music = controller.currentQueue[index];
            final isCurrentSong = index == controller.currentQueueIndex.value;

            return ListTile(
              leading: isCurrentSong
                  ? const Icon(Icons.play_arrow, color: Colors.blue)
                  : Text('${index + 1}'),
              title: Text(music.title),
              subtitle: Text(music.artistName ?? 'Unknown Artist'),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  controller.currentQueue.removeAt(index);
                },
              ),
              onTap: () {
                controller.currentQueueIndex.value = index;
                controller.playFromQueue(index);
              },
            );
          },
        );
      }),
    );
  }
}
