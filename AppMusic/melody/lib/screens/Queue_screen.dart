import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/provider/music_controller.dart';

class QueueScreen extends GetView<MusicController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hàng chờ phát',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(() {
              final remainingSongs = controller.currentQueue.length - 
                                   (controller.currentQueueIndex.value + 1);
              return Text(
                '$remainingSongs bài hát trong hàng chờ',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              );
            }),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all, color: Colors.white),
            onPressed: () => _showClearQueueDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        final currentIndex = controller.currentQueueIndex.value;
        final queue = controller.currentQueue;
        
        return Column(
          children: [
            // Phần bài đang phát
            if (queue.isNotEmpty && currentIndex < queue.length) ...[
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.grey[900],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đang phát',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListTile(
                      onTap: () => controller.playQueueItem(currentIndex),
                      leading: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              queue[currentIndex].youtubeThumbnail,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      title: Text(
                        queue[currentIndex].title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        queue[currentIndex].artistName,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey[800]),
            ],

            // Phần hàng chờ
            if (queue.length > currentIndex + 1) ...[
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Tiếp theo',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '${queue.length - currentIndex - 1} bài hát',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  onReorder: (oldIndex, newIndex) {
                    controller.reorderQueue(oldIndex + currentIndex + 1, newIndex + currentIndex + 1);
                  },
                  itemCount: queue.length - currentIndex - 1,
                  itemBuilder: (context, index) {
                    final actualIndex = index + currentIndex + 1;
                    final song = queue[actualIndex];
                    
                    return Dismissible(
                      key: Key(song.id + actualIndex.toString()),
                      background: Container(
                        color: Colors.red[900],
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => controller.removeFromQueue(actualIndex),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[900]!, width: 0.5),
                          ),
                        ),
                        child: ListTile(
                          onTap: () => controller.playQueueItem(actualIndex),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              song.youtubeThumbnail,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            song.title,
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            song.artistName,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          trailing: Icon(Icons.drag_handle, color: Colors.grey[600]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  void _showClearQueueDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Xóa hàng chờ', style: TextStyle(color: Colors.white)),
        content: Text(
          'Bạn có chắc muốn xóa tất cả bài hát khỏi hàng chờ?',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            child: Text('Hủy', style: TextStyle(color: Colors.grey[400])),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
            onPressed: () {
              controller.clearQueue();
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
