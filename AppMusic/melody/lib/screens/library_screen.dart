import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors.dart';
import 'package:melody/widgets/bottom_player_nav.dart';

class LibraryScreen extends StatelessWidget {
  final List<Artist> artists = [
    Artist(
      name: "Abhijeet",
      type: "Artist",
      imageUrl: "assets/playlist1.png",
    ),
    Artist(
      name: "A.R.Rahman",
      type: "Artist",
      imageUrl: "assets/playlist1.png",
    ),
    Artist(
      name: "Sunidhi chauhan",
      type: "Artist",
      imageUrl: "assets/playlist1.png",
    ),
  ];

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
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey[800],
                              child: Text(
                                'S',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Your Library',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.search, color: Colors.white),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.add, color: Colors.white),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Categories
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Chip(
                          label: Text('Artists'),
                          backgroundColor: Colors.grey[900],
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Chip(
                          label: Text('Recents'),
                          backgroundColor: Colors.grey[900],
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Artists List
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: artists.length + 2,
                      itemBuilder: (context, index) {
                        if (index < artists.length) {
                          return ArtistListTile(artist: artists[index]);
                        } else if (index == artists.length) {
                          return AddButton(
                            title: "Add artist",
                            icon: Icons.add,
                            onTap: () {},
                          );
                        } else {
                          return AddButton(
                            title: "Add podcasts & shows",
                            icon: Icons.add,
                            onTap: () {},
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomPlayerNav(currentIndex: 2),
            ),
          ],
        ),
      ),
    );
  }
}

class Artist {
  final String name;
  final String type;
  final String imageUrl;

  Artist({
    required this.name,
    required this.type,
    required this.imageUrl,
  });
}

class ArtistListTile extends StatelessWidget {
  final Artist artist;

  const ArtistListTile({required this.artist});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          artist.imageUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        artist.name,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        artist.type,
        style: TextStyle(
          color: Colors.grey[400],
        ),
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const AddButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
