import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';

/// Navigation state controller for GetX
class NavigationController extends GetxController {
  final Rx<int> currentIndex = 0.obs;

  void navigateTo(int index) {
    currentIndex.value = index;
  }

  void goToHome() => navigateTo(0);
  void goToExplore() => navigateTo(1);
  void goToLibrary() => navigateTo(2);
  void goToSearch() => navigateTo(3);
  void goToProfile() => navigateTo(4);
}

/// Bottom Navigation Bar with Musium Design
/// 5 tabs: Home, Explore, Library, Search, Profile
class BottomNavBarMusium extends StatefulWidget {
  final Function(int) onTabChanged;
  final int currentIndex;

  const BottomNavBarMusium({
    Key? key,
    required this.onTabChanged,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<BottomNavBarMusium> createState() => _BottomNavBarMusiumState();
}

class _BottomNavBarMusiumState extends State<BottomNavBarMusium>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;

  @override
  void initState() {
    super.initState();
    _animationControllers = List<AnimationController>.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
  }

  @override
  void didUpdateWidget(BottomNavBarMusium oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animationControllers[oldWidget.currentIndex].reverse();
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorMusium.darkSurface,
        border: Border(
          top: BorderSide(
            color: AppColorMusium.textTertiary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Home',
                animation: _animationControllers[0],
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.compass_calibration_rounded,
                label: 'Explore',
                animation: _animationControllers[1],
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.library_music_rounded,
                label: 'Library',
                animation: _animationControllers[2],
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.search_rounded,
                label: 'Search',
                animation: _animationControllers[3],
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.person_rounded,
                label: 'Profile',
                animation: _animationControllers[4],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required AnimationController animation,
  }) {
    final isActive = widget.currentIndex == index;

    return GestureDetector(
      onTap: () {
        widget.onTabChanged(index);
      },
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        ),
        child: SizedBox(
          height: 54,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with background
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? AppColorMusium.accentTeal.withValues(alpha: 0.2)
                      : Colors.transparent,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isActive
                      ? AppColorMusium.accentTeal
                      : AppColorMusium.textSecondary,
                ),
              ),

              const SizedBox(height: 1),

              // Label
              Text(
                label,
                style: AppTypographyMusium.labelSmall.copyWith(
                  color: isActive
                      ? AppColorMusium.accentTeal
                      : AppColorMusium.textTertiary,
                  fontSize: 8,
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main app container with bottom navigation
class MainAppContainer extends StatefulWidget {
  const MainAppContainer({Key? key}) : super(key: key);

  @override
  State<MainAppContainer> createState() => _MainAppContainerState();
}

class _MainAppContainerState extends State<MainAppContainer> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    // TODO: Replace with actual screens
    _PlaceholderScreen(title: 'Home', color: Colors.blueAccent),
    _PlaceholderScreen(title: 'Explore', color: Colors.purpleAccent),
    _PlaceholderScreen(title: 'Library', color: Colors.pinkAccent),
    _PlaceholderScreen(title: 'Search', color: Colors.greenAccent),
    _PlaceholderScreen(title: 'Profile', color: Colors.orangeAccent),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorMusium.darkBg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBarMusium(
        currentIndex: _currentIndex,
        onTabChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

/// Placeholder screen for development
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final Color color;

  const _PlaceholderScreen({
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.3),
            ),
            child: Icon(
              Icons.music_note,
              size: 50,
              color: color,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: AppTypographyMusium.heading3.copyWith(
              color: AppColorMusium.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Screen coming soon...',
            style: AppTypographyMusium.bodyMedium.copyWith(
              color: AppColorMusium.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
