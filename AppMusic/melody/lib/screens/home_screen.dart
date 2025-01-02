import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController _scrollController = ScrollController();
  double _scrollOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    // Điều chỉnh độ trong suốt dựa trên vị trí cuộn
    final opacity = (offset / 350).clamp(0.0, 1.0);
    setState(() {
      _scrollOpacity = opacity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF353340),
                  Color(0xFF161718),
                  Color(0xFF353340),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // Main content with sticky header
          SafeArea(
            child: CustomScrollView(
              controller: _scrollController, // Thêm controller
              slivers: [
                // Sticky header với background color
                SliverAppBar(
                  backgroundColor: Color(0xFF161718).withOpacity(
                      _scrollOpacity), // Màu nền thay đổi theo scroll
                  pinned: true,
                  elevation: 0,
                  flexibleSpace: Container(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Good afternoon',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey[800],
                              child: Icon(Icons.notifications,
                                  color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            CircleAvatar(
                              backgroundColor: Colors.grey[800],
                              child: Icon(Icons.settings, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Scrollable content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recently played section
                        SectionTitle('Recently played'),
                        SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              RecentlyPlayedCard(
                                imageUrl: 'assets/playlist1.png',
                                title: 'Mega Hit Mix',
                              ),
                              // Add more cards...

                              RecentlyPlayedCard(
                                imageUrl: 'assets/playlist1.png',
                                title: 'Mega Hit Mix',
                              ),
                              RecentlyPlayedCard(
                                imageUrl: 'assets/playlist1.png',
                                title: 'Mega Hit Mix',
                              ),
                              RecentlyPlayedCard(
                                imageUrl: 'assets/playlist1.png',
                                title: 'Mega Hit Mix',
                              ),
                            ],
                          ),
                        ),

                        // To get you started section
                        SectionTitle('To get you started'),
                        SizedBox(height: 15),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              PlaylistCard(
                                imageUrl: 'assets/playlist1.png',
                                title: 'Daily Mix 1',
                                subtitle:
                                    'Six60, Mitch James, Tiki Taane And More',
                              ),
                              SizedBox(width: 12),
                              PlaylistCard(
                                imageUrl: 'assets/playlist1.png',
                                title: 'Daily Mix 2',
                                subtitle:
                                    'Six60, Mitch James, Tiki Taane And More',
                              ),
                              SizedBox(width: 12),
                              PlaylistCard(
                                imageUrl: 'assets/playlist1.png',
                                title: 'Daily Mix 3',
                                subtitle:
                                    'Six60, Mitch James, Tiki Taane And More',
                              ),
                              SizedBox(width: 12),
                              PlaylistCard(
                                imageUrl: 'assets/playlist1.png',
                                title: 'Daily Mix 4',
                                subtitle:
                                    'Six60, Mitch James, Tiki Taane And More',
                              ),
                            ],
                          ),
                        ),

                        // Today's Biggest Hits section
                        SizedBox(height: 32),
                        SectionTitle("Today's Biggest Hits"),
                        SizedBox(height: 15),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              PlaylistCard(
                                imageUrl: 'assets/playlist1.png',
                                title: 'Adam French, Bella',
                                subtitle: 'M1, Twiceyoung And',
                              ),
                              SizedBox(width: 12),
                              PlaylistCard(
                                imageUrl: 'assets/playlist1.png',
                                title: 'Canyon City, Marc',
                                subtitle: 'Scibilia, Oh Honey And',
                              ),
                              SizedBox(width: 12),
                              PlaylistCard(
                                imageUrl: 'assets/playlist1.png',
                                title: 'Six60',
                                subtitle: 'Tiki Taa',
                              ),
                              SizedBox(width: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom navigation area with blur effect
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mini Player
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.black.withOpacity(0.5),
                      child: Row(
                        children: [
                          // Album art
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              'assets/playlist1.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 12),
                          // Song info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Die With A Smile ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "Lady Gaga & Bruno Mars",
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Control buttons
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.pause, color: Colors.white),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Icon(Icons.favorite_border,
                                    color: Colors.white),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Progress bar
                    Container(
                      height: 2,
                      child: LinearProgressIndicator(
                        value: 0.7,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    // Navigation bar
                    Container(
                      margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Colors.transparent,
                        ),
                        child: BottomNavigationBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          selectedItemColor: Colors.white,
                          unselectedItemColor: Colors.grey,
                          type: BottomNavigationBarType.fixed,
                          items: [
                            BottomNavigationBarItem(
                              icon: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900]?.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.home),
                              ),
                              label: 'Home',
                            ),
                            BottomNavigationBarItem(
                              icon: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900]?.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.search),
                              ),
                              label: 'Search',
                            ),
                            BottomNavigationBarItem(
                              icon: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900]?.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.library_music),
                              ),
                              label: 'Your Library',
                            ),
                            BottomNavigationBarItem(
                              icon: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900]?.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.person),
                              ),
                              label: 'Premium',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom widgets
class SectionTitle extends StatelessWidget {
  final String title;

  SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class RecentlyPlayedCard extends StatelessWidget {
  final String imageUrl;
  final String title;

  RecentlyPlayedCard({required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 4), // Reduced from 8 to 4 to fix overflow
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class PlaylistCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;

  PlaylistCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Giữ nguyên chiều rộng
      height: 260, // Giảm chiều cao xuống
      decoration: BoxDecoration(
        color: Color(0xFF282828),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Phần hình ảnh
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Phần text
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4), // Giảm padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13, // Giảm font size
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2), // Giảm khoảng cách
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 11, // Giảm font size
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
