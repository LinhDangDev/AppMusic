import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors.dart';
import 'package:melody/widgets/bottom_player_nav.dart';
import 'package:melody/models/playlist.dart';
import 'package:melody/services/playlist_service.dart';
import 'package:get/get.dart';
import 'package:melody/screens/playlist_detail_screen.dart';

class LibraryScreen extends StatelessWidget {
  final PlaylistService _playlistService = PlaylistService();
  final RxList<Playlist> playlists = <Playlist>[].obs;
  final RxBool isLoading = true.obs;

  LibraryScreen({Key? key}) : super(key: key) {
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    try {
      isLoading.value = true;
      final loadedPlaylists = await _playlistService.getAllPlaylists();
      playlists.assignAll(loadedPlaylists);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load playlists',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Error loading playlists: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Text(
                  'S',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Your Library',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search, color: Colors.black),
                onPressed: () {},
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: () => _showCreatePlaylistDialog(Get.context!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Chip(
            label: Text('Playlists'),
            backgroundColor: Colors.grey[200],
            labelStyle: TextStyle(color: Colors.black),
          ),
          SizedBox(width: 8),
          Chip(
            label: Text('Albums'),
            backgroundColor: Colors.grey[200],
            labelStyle: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final RxBool isCreating = false.obs;

    Get.dialog(
      AlertDialog(
        title: Text('Create New Playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Playlist Name',
                hintText: 'Enter playlist name',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter playlist description',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
                onPressed: isCreating.value
                    ? null
                    : () async {
                        if (nameController.text.isNotEmpty) {
                          try {
                            isCreating.value = true;
                            await _playlistService.createPlaylist(
                              nameController.text,
                              descController.text,
                            );
                            Get.back();
                            await _loadPlaylists(); // Reload playlists after creating
                            Get.snackbar(
                              'Success',
                              'Playlist created successfully',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          } catch (e) {
                            Get.snackbar(
                              'Error',
                              'Failed to create playlist',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            print('Error creating playlist: $e');
                          } finally {
                            isCreating.value = false;
                          }
                        }
                      },
                child: isCreating.value
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Create'),
              )),
        ],
      ),
    );
  }

  void _openPlaylist(Playlist playlist) {
    Get.to(() => PlaylistDetailScreen(playlist: playlist));
  }

  void _showDeleteConfirmation(Playlist playlist) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Playlist'),
        content: Text('Are you sure you want to delete "${playlist.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final success = await _playlistService.deletePlaylist(playlist.id);
                
                // Đóng tất cả dialog đang mở
                Get.until((route) => !Get.isDialogOpen!);
                
                if (success) {
                  // Xóa khỏi danh sách local
                  playlists.removeWhere((p) => p.id == playlist.id);
                  
                  Get.snackbar(
                    'Success',
                    'Playlist deleted successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                    duration: Duration(seconds: 2),
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    'Failed to delete playlist',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                    duration: Duration(seconds: 2),
                  );
                }
              } catch (e) {
                // Đóng tất cả dialog trong trường hợp lỗi
                Get.until((route) => !Get.isDialogOpen!);
                
                print('Error during delete: $e');
                Get.snackbar(
                  'Error',
                  'Failed to delete playlist',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                  duration: Duration(seconds: 2),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return Card(
          elevation: 0,
          color: Colors.grey[100],
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                'assets/playlist1.png',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              playlist.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              '${playlist.songCount} songs',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            trailing: PopupMenuButton(
              icon: Icon(Icons.more_vert, color: Colors.black),
              onSelected: (value) async {
                if (value == 'delete') {
                  _showDeleteConfirmation(playlist);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => _openPlaylist(playlist),
          ),
        );
      },
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
              child: Column(
                children: [
                  _buildHeader(),
                  _buildCategories(),
                  Expanded(
                    child: Obx(() {
                      if (isLoading.value) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (playlists.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'No playlists yet',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => _showCreatePlaylistDialog(context),
                                child: Text('Create Playlist'),
                              ),
                            ],
                          ),
                        );
                      }
                      return _buildPlaylistList();
                    }),
                  ),
                ],
              ),
            ),
            const Positioned(
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
