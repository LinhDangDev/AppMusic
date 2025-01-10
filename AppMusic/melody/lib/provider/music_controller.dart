import 'package:get/get.dart';
import 'package:melody/models/genre.dart';
import 'package:melody/models/music.dart';
import 'package:melody/services/music_service.dart';
import 'package:melody/screens/player_screen.dart';

class MusicController extends GetxController {
  final MusicService _musicService = MusicService();
  final RxList<Music> allMusic = <Music>[].obs;
  final RxList<Music> rankings = <Music>[].obs;
  final RxList<Music> biggestHits = <Music>[].obs;
  final RxList<Genre> genres = <Genre>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedRegion = 'VN'.obs;
  final RxList<Music> currentQueue = <Music>[].obs;
  final RxInt currentQueueIndex = 0.obs;
  final RxString currentPlaylistName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      
      // Load all music
      final musicList = await _musicService.getAllMusic();
      allMusic.assignAll(musicList);

      // Load rankings for VN
      final rankingsList = await _musicService.getMusicRankings('VN');
      rankings.assignAll(rankingsList);

      // Load biggest hits với region mặc định
      await loadBiggestHits(selectedRegion.value);

      // Load genres
      final genresList = await _musicService.getAllGenres();
      genres.assignAll(genresList);
      
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadBiggestHits(String region) async {
    try {
      final hits = await _musicService.getMusicRankings(region);
      biggestHits.assignAll(hits);
      selectedRegion.value = region;
    } catch (e) {
      print('Error loading biggest hits: $e');
    }
  }

  void setCurrentQueue({
    required List<Music> playlist,
    required int currentIndex,
    required String playlistName,
  }) {
    currentQueue.assignAll(playlist);
    currentQueueIndex.value = currentIndex;
    currentPlaylistName.value = playlistName;
  }

  void playFromQueue(int index) {
    if (index >= 0 && index < currentQueue.length) {
      currentQueueIndex.value = index;
      final music = currentQueue[index];
      
      // Cập nhật player screen với bài hát mới
      Get.to(() => PlayerScreen(
        title: music.title,
        artist: music.artistName,
        imageUrl: music.youtubeThumbnail,
        youtubeId: music.youtubeId,
      ));
    }
  }

  // Phương thức để chuyển bài tiếp theo
  void playNext() {
    if (currentQueueIndex.value < currentQueue.length - 1) {
      playFromQueue(currentQueueIndex.value + 1);
    }
  }

  // Phương thức để chuyển bài trước đó
  void playPrevious() {
    if (currentQueueIndex.value > 0) {
      playFromQueue(currentQueueIndex.value - 1);
    }
  }
}
