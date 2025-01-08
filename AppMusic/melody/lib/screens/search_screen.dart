import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors.dart';
import 'package:melody/widgets/bottom_player_nav.dart';

class SearchScreen extends StatelessWidget {
  final List<SearchCategory> categories = [
    SearchCategory(
      title: "Podcasts",
      icon: "assets/playlist1.png",
      color: Colors.purple,
    ),
    SearchCategory(
      title: "Live Events",
      icon: "assets/playlist1.png",
      color: Colors.blue,
    ),
    SearchCategory(
      title: "Made for you",
      icon: "assets/playlist1.png",
      color: Colors.orange,
    ),
    SearchCategory(
      title: "New Releases",
      icon: "assets/playlist1.png",
      color: Colors.pink,
    ),
    SearchCategory(
      title: "Hindi",
      icon: "assets/playlist1.png",
      color: Colors.brown,
    ),
    SearchCategory(
      title: "Punjabi",
      icon: "assets/playlist1.png",
      color: Colors.red,
    ),
    // Thêm các category khác tương tự
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Search",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "What do you want to listen to?",
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Browse all",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return CategoryCard(category: categories[index]);
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
              child: BottomPlayerNav(currentIndex: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchCategory {
  final String title;
  final String icon;
  final Color color;

  SearchCategory({
    required this.title,
    required this.icon,
    required this.color,
  });
}

class CategoryCard extends StatelessWidget {
  final SearchCategory category;

  const CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: category.color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Transform.rotate(
              angle: 25 * 3.14 / 180,
              child: Image.asset(
                category.icon,
                width: 50,
                height: 50,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              category.title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
