import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melody/models/genre.dart';
import 'package:melody/models/music.dart';
import 'package:melody/services/music_service.dart';
import 'package:melody/screens/player_screen.dart';
import 'package:melody/widgets/mini_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

enum RepeatMode {
  off,
  all,
  one,
}

class MusicController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();
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
  var currentYoutubeId = ''.obs;
  var currentTitle = ''.obs;
  var currentArtist = ''.obs;
  var currentImageUrl = ''.obs;
  var isChangingAudio = false.obs;
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;
  var isPlaying = false.obs;
  var showMiniPlayer = false.obs;
  var isShuffleEnabled = false.obs;
  var isSmartShuffleEnabled = false.obs;
  var repeatMode = RepeatMode.off.obs;
  final isMiniPlayerVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    selectedRegion.value = 'VN';
    loadBiggestHits('VN');
    loadGenres();
    loadData();
    _initAudioPlayer();
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    _musicService.dispose();
    super.onClose();
  }

  void _initAudioPlayer() {
    audioPlayer.playerStateStream.listen((state) {
      // Xử lý các thay đổi trạng thái của player
    });

    // Lắng nghe thay đổi duration
    audioPlayer.durationStream.listen((d) {
      duration.value = d ?? Duration.zero;
    });

    // Lắng nghe thay đổi position
    audioPlayer.positionStream.listen((p) {
      position.value = p;
    });

    // Lắng nghe trạng thái playing
    audioPlayer.playingStream.listen((playing) {
      isPlaying.value = playing;
    });
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;

      // Load rankings (VN by default)
      final rankingsData = await _musicService.getMusicRankings('VN');
      rankings.assignAll(rankingsData);

      // Load all music (if needed for other sections)
      final musicList = await _musicService.getAllMusic();
      allMusic.assignAll(musicList);

      isLoading.value = false;
    } catch (e) {
      print('Error loading data: $e');
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

  Future<void> loadGenres() async {
    try {
      isLoading(true);
      final genresList = await _musicService.getGenres();
      genres.assignAll(genresList);
      print('Loaded ${genres.length} genres');
    } catch (e) {
      print('Error loading genres: $e');
    } finally {
      isLoading(false);
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

  Future<void> changeMusic(
      String youtubeId, String title, String artist, String imageUrl) async {
    try {
      if (currentYoutubeId.value == youtubeId) return;

      await audioPlayer.stop();

      // Cập nhật thông tin bài hát
      updateCurrentSong(
        title: title,
        artist: artist,
        imageUrl: imageUrl,
        youtubeId: youtubeId,
      );

      isLoading.value = true;
      showMiniPlayer.value = true; // Hiển thị mini player

      final audioUrl = await getAudioUrl(youtubeId);
      await audioPlayer.setUrl(audioUrl);
      await audioPlayer.play();

      isLoading.value = false;
    } catch (e) {
      print('Error changing music: $e');
      isLoading.value = false;
    }
  }

  Future<String> getAudioUrl(String youtubeId) async {
    return await MusicService().getAudioUrl(youtubeId);
  }

  // Cập nhật thông tin bài hát hiện tại
  void updateCurrentSong({
    required String title,
    required String artist,
    required String imageUrl,
    required String youtubeId,
  }) {
    currentTitle.value = title;
    currentArtist.value = artist;
    currentImageUrl.value = imageUrl;
    currentYoutubeId.value = youtubeId;
  }

  // Xử lý thay đổi audio
  Future<void> handleAudioChange() async {
    try {
      isLoading.value = true;

      // Dừng bài hát hiện tại nếu đang phát
      await audioPlayer.stop();

      // Lấy URL audio từ YouTube
      final yt = YoutubeExplode();
      try {
        final manifest =
            await yt.videos.streamsClient.getManifest(currentYoutubeId.value);
        final audioStream = manifest.audioOnly.withHighestBitrate();

        if (audioStream != null) {
          // Set audio source và phát
          await audioPlayer.setUrl(audioStream.url.toString());
          await audioPlayer.play();
        }
      } finally {
        yt.close();
      }
    } catch (e) {
      print('Error changing audio: $e');
      Get.snackbar(
        'Error',
        'Failed to play the song',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Cập nhật method seek
  Future<void> seek(Duration position) async {
    try {
      await audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  // Cập nhật method togglePlay
  Future<void> togglePlay() async {
    try {
      if (isPlaying.value) {
        await audioPlayer.pause();
      } else {
        await audioPlayer.play();
      }
    } catch (e) {
      print('Error toggling play: $e');
    }
  }

  // Method để ẩn/hiện mini player
  void toggleMiniPlayer(bool show) {
    isMiniPlayerVisible.value = show;
    if (show) {
      // Cập nhật thông tin cho mini player
      currentTitle.value = currentTitle.value;
      currentArtist.value = currentArtist.value;
      currentImageUrl.value = currentImageUrl.value;
      currentYoutubeId.value = currentYoutubeId.value;
    }
  }

  // Toggle shuffle mode
  void toggleShuffle() {
    if (isShuffleEnabled.value) {
      // Nếu shuffle đang bật, tắt nó
      isShuffleEnabled.value = false;
    } else {
      // Nếu shuffle đang tắt, bật nó và tắt smart shuffle
      isShuffleEnabled.value = true;
      isSmartShuffleEnabled.value = false;
    }
    // Có thể thêm logic xử lý queue ở đây
  }

  // Toggle smart shuffle
  void toggleSmartShuffle() {
    if (isSmartShuffleEnabled.value) {
      // Nếu smart shuffle đang bật, tắt nó
      isSmartShuffleEnabled.value = false;
    } else {
      // Nếu smart shuffle đang tắt, bật nó và tắt shuffle thường
      isSmartShuffleEnabled.value = true;
      isShuffleEnabled.value = false;
    }
    // Có thể thêm logic xử lý queue ở đây
  }

  // Toggle repeat mode
  void toggleRepeatMode() {
    if (repeatMode.value == RepeatMode.off) {
      repeatMode.value = RepeatMode.all;
    } else if (repeatMode.value == RepeatMode.all) {
      repeatMode.value = RepeatMode.one;
    } else {
      repeatMode.value = RepeatMode.off;
    }
    _updatePlayerRepeatMode();
  }

  void _updatePlayerRepeatMode() {
    switch (repeatMode.value) {
      case RepeatMode.off:
        audioPlayer.setLoopMode(LoopMode.off);
        break;
      case RepeatMode.one:
        audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.all:
        audioPlayer.setLoopMode(LoopMode.all);
        break;
    }
  }

  // Resume playback
  Future<void> resume() async {
    await audioPlayer.play();
  }

  // Pause playback
  Future<void> pause() async {
    await audioPlayer.pause();
  }
}
