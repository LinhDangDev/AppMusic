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

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOpacity = 0.0;
  final List<Genre> genres = [
    Genre(name: 'Romance', borderColor: Colors.red),
    Genre(name: 'Sad', borderColor: Colors.grey),
    Genre(name: 'R&B & Soul', borderColor: Colors.purple),
    Genre(name: 'Party', borderColor: Colors.deepPurple),
    Genre(name: 'Mandopop & Cantopop', borderColor: Colors.orange),
    Genre(name: 'Folk & Acoustic', borderColor: Colors.green),
    Genre(name: 'K-Pop', borderColor: Colors.purple),
    Genre(name: 'Feel Good', borderColor: Colors.lightGreen),
    Genre(name: 'Hip-Hop', borderColor: Colors.deepOrange),
    Genre(name: 'Sleep', borderColor: Colors.purple),
    Genre(name: 'Workout', borderColor: Colors.orange),
    Genre(name: 'Family', borderColor: Colors.cyan),
    Genre(name: 'Commute', borderColor: Colors.amber),
    Genre(name: 'Chill', borderColor: Colors.lightBlue),
    Genre(name: 'Focus', borderColor: Colors.white),
    Genre(name: 'Dance & Electronic', borderColor: Colors.cyan),
    Genre(name: 'Classical', borderColor: Colors.grey),
    Genre(name: '2000s', borderColor: Colors.green),
    Genre(name: 'Pop', borderColor: Colors.pink),
    Genre(name: 'Korean Hip-Hop', borderColor: Colors.orange),
    Genre(name: 'Energy Boosters', borderColor: Colors.yellow),
    Genre(name: 'Soundtracks & Musicals', borderColor: Colors.cyan),
    Genre(name: '1980s', borderColor: Colors.green),
    Genre(name: 'Indie & Alternative', borderColor: Colors.white),
  ];

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
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
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
      onTap: () => Navigator.pop(context),
    );
  }

  Widget _buildNotificationsSection() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "You don't have any updates, yet...",
            style: TextStyle(color: Colors.grey[400]),
          ),
          SizedBox(height: 8),
          Text(
            'When you get playlist likes, followers,\nand more, you ll get a notification here.',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {},
              child: Text(
                'Create a Blend',
                style: TextStyle(color: Colors.white),
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
                          SectionTitle('Recently played'),
                          SizedBox(height: 10),
                          _buildRecentlyPlayed(),
                          SectionTitle('To get you started'),
                          SizedBox(height: 15),
                          _buildPlaylists(),
                          SizedBox(height: 32),
                          SectionTitle("Today's Biggest Hits"),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPlaylistCard(
              'Daily Mix 1', 'Six60, Mitch James, Tiki Taane And More'),
          SizedBox(width: 12),
          _buildPlaylistCard(
              'Daily Mix 2', 'Six60, Mitch James, Tiki Taane And More'),
          SizedBox(width: 12),
          _buildPlaylistCard(
              'Daily Mix 3', 'Six60, Mitch James, Tiki Taane And More'),
          SizedBox(width: 12),
          _buildPlaylistCard(
              'Daily Mix 4', 'Six60, Mitch James, Tiki Taane And More'),
        ],
      ),
    );
  }

  Widget _buildPlaylistCard(String title, String subtitle) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PlayerScreen()),
        );
      },
      child: PlaylistCard(
        imageUrl: 'assets/playlist1.png',
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  Widget _buildBiggestHits() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPlaylistCard('Adam French, Bella', 'M1, Twiceyoung And'),
          SizedBox(width: 12),
          _buildPlaylistCard('Canyon City, Marc', 'Scibilia, Oh Honey And'),
          SizedBox(width: 12),
          _buildPlaylistCard('Six60', 'Tiki Taa'),
          SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildGenres() {
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
                for (var i = 0; i < genres.length; i += 2)
                  if (i + 1 < genres.length)
                    Container(
                      margin: EdgeInsets.only(right: 8),
                      child: Column(
                        children: [
                          GenreCard(genre: genres[i]),
                          SizedBox(height: 8),
                          if (i + 1 < genres.length)
                            GenreCard(genre: genres[i + 1]),
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
      width: 200,
      height: 260,
      decoration: BoxDecoration(
        color: Color(0xFF282828),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(0, 4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {},
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
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
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 11,
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
          ),
        ),
      ),
    );
  }
}
