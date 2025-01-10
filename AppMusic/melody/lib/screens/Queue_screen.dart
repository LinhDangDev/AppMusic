import 'package:flutter/material.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ĐANG PHÁT',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            Text(
              '"Nơi Này Có Anh" Radio',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
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
                Text(
                  'Đang phát',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      'URL_HINH_ANH_BAI_HAT',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    'Nơi Này Có Anh',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Sơn Tùng M-TP, 389 Tr lượt phát',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Hàng đợi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text(
                    '${index + 1}',
                    style: TextStyle(color: Colors.white),
                  ),
                  title: Text(
                    _getSongTitle(index),
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    _getArtistName(index),
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getSongTitle(int index) {
    final songs = [
      'Nơi Này Có Anh',
      'Đừng Làm Trái Tim Anh Đau',
      'Ngày Đẹp Trời Để Nói Chia Tay',
      'Từng Là',
      'Yêu 5',
      'Ngày Mai Em Đi',
      'Phía Sau Em',
      'Tết Này Con Sẽ Về',
      'Đã Lỡ Yêu Em Nhiều',
      'Sai Lầm (cùng với Nguyễn Đình)',
    ];
    return songs[index];
  }

  String _getArtistName(int index) {
    final artists = [
      'Sơn Tùng M-TP, 389 Tr lượt phát',
      'Sơn Tùng M-TP',
      'Lưu Hoàng',
      'Vũ Cát Tường',
      'Rhymastic',
      'Lê Hiếu, Soobin Hoàng Sơn, Touliver',
      'Kay Trần, Binz',
      'Bùi Công Nam',
      'JustaTee',
      'Nguyễn Đình',
    ];
    return artists[index];
  }
}
