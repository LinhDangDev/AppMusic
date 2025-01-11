import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors.dart';
import 'package:melody/widgets/bottom_player_nav.dart';
import 'package:melody/services/music_service.dart';
// import 'package:melody/models/music.dart';
import 'package:melody/models/search_result.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:melody/screens/player_screen.dart';
import 'package:melody/screens/home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final MusicService _musicService = MusicService();
  bool _isLoading = false;
  List<SearchResult> _searchResults = [];
  String _error = '';
  Timer? _debounce;
  Timer? _clearTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  _onSearchChanged() {
    _clearTimer?.cancel();
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _handleSearch(_searchController.text);
    });
  }

  Future<void> _handleSearch(String query) async {
    _clearTimer?.cancel();

    if (query.isEmpty) {
      _clearTimer = Timer(const Duration(minutes: 5), () {
        if (mounted) {
          setState(() {
            _searchResults = [];
            _error = '';
          });
        }
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final results = await _musicService.searchMusic(query);
      if (mounted) {
        setState(() {
          _searchResults = results.cast<SearchResult>();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Có lỗi xảy ra khi tìm kiếm';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _clearTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search UI
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm bài hát, nghệ sĩ...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                  onChanged: (value) => _handleSearch(value),
                ),
              ),

              // Search Results
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return SearchResultItem(
                      result: result,
                      onTap: () {
                        Get.to(
                          () => PlayerScreen(
                            title: result.title,
                            artist: result.artistName,
                            imageUrl: result.displayImage,
                            youtubeId: result.youtubeId,
                          ),
                          transition: Transition.downToUp,
                        );
                      },
                    );
                  },
                ),
              ),

              // Bottom Navigation
              const BottomPlayerNav(currentIndex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchResultItem extends StatelessWidget {
  final SearchResult result;
  final VoidCallback? onTap;

  const SearchResultItem({
    Key? key,
    required this.result,
    this.onTap,
  }) : super(key: key);

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header với tên bài hát và nghệ sĩ
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      result.displayImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[800],
                        child: Icon(Icons.music_note, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          result.artistName,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[800], height: 1),
            // Menu options
            _buildMenuItem(
              icon: Icons.play_circle_outline,
              title: 'Phát',
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement play functionality
              },
            ),
            _buildMenuItem(
              icon: Icons.playlist_add,
              title: 'Thêm vào playlist',
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement add to playlist
              },
            ),
            _buildMenuItem(
              icon: Icons.favorite_border,
              title: 'Thêm vào yêu thích',
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement add to favorites
              },
            ),
            _buildMenuItem(
              icon: Icons.share_outlined,
              title: 'Chia sẻ',
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share functionality
              },
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          result.displayImage,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 56,
            height: 56,
            color: Colors.grey[800],
            child: Icon(Icons.music_note, color: Colors.white),
          ),
        ),
      ),
      title: Text(
        result.title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        result.artistName,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(Icons.more_vert, color: Colors.black),
        onPressed: () => _showOptions(context),
      ),
      onTap: onTap,
    );
  }
}
