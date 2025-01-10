import 'package:get/get.dart';
import 'package:melody/models/genre.dart';
import 'package:melody/models/music.dart';
import 'package:melody/services/music_service.dart';

class MusicController extends GetxController {
  final MusicService _musicService = MusicService();
  final RxList<Music> allMusic = <Music>[].obs;
  final RxList<Music> rankings = <Music>[].obs;
  final RxList<Genre> genres = <Genre>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      
      // Load all music for "Get You Started" and "Biggest Hits"
      final musicList = await _musicService.getAllMusic();
      allMusic.assignAll(musicList);

      // Load rankings for "Recently Played"
      final rankingsList = await _musicService.getMusicRankings('VN');
      rankings.assignAll(rankingsList);

      // Load genres
      final genresList = await _musicService.getAllGenres();
      genres.assignAll(genresList);
      
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
