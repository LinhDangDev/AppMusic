import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'player_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'premium_screen.dart';
import 'package:melody/constants/app_colors.dart';
import 'package:melody/widgets/bottom_player_nav.dart';
import 'package:melody/models/genre.dart';
import 'package:melody/widgets/genre_card.dart';
import 'package:melody/models/music.dart';
import 'package:melody/services/music_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOpacity = 0.0;
  bool _isLoading = true;
  final MusicService _musicService = MusicService();
  List<Music> _allMusic = [];
  List<Music> _rankings = [];
  List<Genre> _genres = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final allMusic = await _musicService.getAllMusic();
      final rankings = await _musicService.getMusicRankings('VN');
      final genres = await _musicService.getAllGenres();

      setState(() {
        _allMusic = allMusic;
        _rankings = rankings;
        _genres = genres;
        _isLoading = false;
      });
    } catch (e) {
      print('Load data error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final opacity = (offset / 350).clamp(0.0, 1.0);
    setState(() {
      _scrollOpacity = opacity;
    });
  }

  void _showSettingsDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Color(0xFF282828),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildUserProfileSection(),
                      _buildMenuItems(),
                      SizedBox(height: 32),
                      _buildNotificationsSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Widget _buildUserProfileSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 30,
            child: Text(
              'S',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suchir',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '0 Followers • 84 Following',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        _buildMenuItem(Icons.person_outline, 'Profile'),
        _buildMenuItem(Icons.history, 'Recently played'),
        _buildMenuItem(Icons.settings, 'Settings and privacy'),
        // _buildMenuItem(Icons.logout, 'Logout', onTap: _handleLogout),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {Function()? onTap}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }

  Widget _buildNotificationsSection() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {},
              child: Text(
                'Upgrade to Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            SafeArea(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _buildSliverAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        top: 16.0,
                        bottom: 140.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SectionTitle('Recently played'),
                          SizedBox(height: 10),
                          _buildRecentlyPlayed(),
                          // SectionTitle('To get you started'),
                          SizedBox(height: 15),
                          _buildPlaylists(),
                          SizedBox(height: 32),
                          // SectionTitle("Today's Biggest Hits"),
                          SizedBox(height: 15),
                          _buildBiggestHits(),
                          SizedBox(height: 32),
                          _buildGenres(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomPlayerNav(currentIndex: 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Good afternoon',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.settings, color: Colors.white),
          onPressed: _showSettingsDrawer,
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildRecentlyPlayed() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildRecentlyPlayedCard(),
          _buildRecentlyPlayedCard(),
          _buildRecentlyPlayedCard(),
          _buildRecentlyPlayedCard(),
        ],
      ),
    );
  }

  Widget _buildRecentlyPlayedCard() {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Color(0xFF282828),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/playlist1.png',
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Mega Hit Mix',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylists() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Get You Started',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _allMusic.length,
            itemBuilder: (context, index) {
              final music = _allMusic[index];
              return Padding(
                padding: EdgeInsets.only(right: 16),
                child: MusicCard(
                  imageUrl: music.displayImage,
                  title: music.title,
                  subtitle: music.artistName,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBiggestHits() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Today\'s Biggest Hits',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _rankings.length,
            itemBuilder: (context, index) {
              final music = _rankings[index];
              return Padding(
                padding: EdgeInsets.only(right: 16),
                child: MusicCard(
                  imageUrl: music.displayImage,
                  title: music.title,
                  subtitle: music.artistName,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenres() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Moods & genres',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'More',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 152,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < _genres.length; i += 2)
                  if (i + 1 < _genres.length)
                    Container(
                      margin: EdgeInsets.only(right: 8),
                      child: Column(
                        children: [
                          GenreCard(genre: _genres[i]),
                          SizedBox(height: 8),
                          if (i + 1 < _genres.length)
                            GenreCard(genre: _genres[i + 1]),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

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

class MusicCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;

  const MusicCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle tap
      },
      child: Container(
        width: 150,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                imageUrl,
                height: 120,
                width: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    width: 150,
                    color: Colors.grey[800],
                    child: Icon(Icons.music_note, color: Colors.white),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
