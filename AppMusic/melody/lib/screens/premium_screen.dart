import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors.dart';
import 'package:melody/widgets/bottom_player_nav.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: 150.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Image.asset('assets/playlist1.png', height: 40),
                        const SizedBox(height: 20),
                        const Text(
                          'Trải nghiệm âm nhạc đỉnh cao với gói Premium Individual.',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Mua Premium Individual',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Premium plans section
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Các gói có sẵn',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Mini plan
                  _buildPremiumPlan(
                    title: 'Mini',
                    price: '10.500 đ cho 1 tuần',
                    color: Colors.green,
                    features: [
                      '1 tài khoản Premium chỉ dành cho thiết bị di động',
                      'Nghe tối đa 30 bài hát trên 1 thiết bị khi không có kết nối mạng',
                      'Thanh toán một lần',
                      'Chất lượng âm thanh cơ bản',
                    ],
                    buttonText: 'Mua Premium Mini',
                    buttonColor: const Color(0xFFCEF264),
                  ),

                  // Individual plan
                  _buildPremiumPlan(
                    title: 'Individual',
                    price: '59.000 đ / tháng',
                    color: Colors.pink.shade100,
                    features: [
                      '1 tài khoản Premium',
                      'Hủy bất cứ lúc nào',
                      'Đăng ký hoặc thanh toán một lần',
                    ],
                    buttonText: 'Mua Premium Individual',
                    buttonColor: const Color(0xFFFFE1E7),
                  ),

                  // Student plan
                  _buildPremiumPlan(
                    title: 'Student',
                    price: '29.500 đ / tháng',
                    color: Colors.purple.shade100,
                    features: [
                      '1 tài khoản Premium đã xác minh',
                      'Giảm giá cho sinh viên đủ điều kiện',
                      'Hủy bất cứ lúc nào',
                      'Đăng ký hoặc thanh toán một lần',
                    ],
                    buttonText: 'Mua Premium Student',
                    buttonColor: const Color(0xFFE6D9F2),
                  ),

                  // Benefits section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lý do nên dùng gói Premium',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildBenefitItem(
                          icon: Icons.block,
                          text: 'Nghe nhạc không quảng cáo',
                        ),
                        _buildBenefitItem(
                          icon: Icons.download,
                          text: 'Tải xuống để nghe không cần mạng',
                        ),
                        _buildBenefitItem(
                          icon: Icons.shuffle,
                          text: 'Phát nhạc theo thứ tự bất kỳ',
                        ),
                        _buildBenefitItem(
                          icon: Icons.headphones,
                          text: 'Chất lượng âm thanh cao',
                        ),
                        _buildBenefitItem(
                          icon: Icons.group,
                          text: 'Nghe cùng bạn bè theo thời gian thực',
                        ),
                        _buildBenefitItem(
                          icon: Icons.playlist_play,
                          text: 'Sắp xếp danh sách chờ nghe',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomPlayerNav(currentIndex: 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumPlan({
    required String title,
    required String price,
    required Color color,
    required List<String> features,
    required String buttonText,
    required Color buttonColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/playlist1.png', height: 24),
              const SizedBox(width: 8),
              Text(
                'Premium',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.white)),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 15),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
