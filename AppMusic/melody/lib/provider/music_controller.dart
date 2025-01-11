import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melody/models/genre.dart';
import 'package:melody/models/music.dart';
import 'package:melody/services/music_service.dart';
import 'package:melody/screens/player_screen.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:dio/dio.dart';
import 'package:melody/constants/api_constants.dart';

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
  final RxString currentYoutubeId = ''.obs;
  final RxString currentTitle = ''.obs;
  final RxString currentArtist = ''.obs;
  final RxString currentImageUrl = ''.obs;
  var isChangingAudio = false.obs;
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;
  var isPlaying = false.obs;
  var showMiniPlayer = false.obs;
  var isShuffleEnabled = false.obs;
  var isSmartShuffleEnabled = false.obs;
  var repeatMode = RepeatMode.off.obs;
  final RxBool isQueueMode = false.obs;
  final _yt = YoutubeExplode();
  final currentMusic = Rx<Music?>(null);
  final RxBool isLoadingRankings = true.obs;
  final Dio dio = Dio();
  final RxList<Music> startedMusic = <Music>[].obs;
  final RxList<Music> randomMusic = <Music>[].obs;
  final Rx<Music?> currentSong = Rx<Music?>(null);
  final RxList<Music> recentMusic = <Music>[].obs;

  @override
  void onInit() {
    super.onInit();
    selectedRegion.value = 'VN';
    loadBiggestHits('VN');
    loadGenres();
    loadData();
    _initAudioPlayer();
    loadRandomMusic();
    // Xử lý các sự kiện của audioPlayer
    audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        playNext();
      }
    });

    // Xử lý lỗi
    audioPlayer.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace st) {
        print('A stream error occurred: $e');
      },
    );

    loadRandomMusic();
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    _musicService.dispose();
    _yt.close();
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
      isLoadingRankings.value = true;
      final response =
          await dio.get('${ApiConstants.baseUrl}/api/music/rankings/$region');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final rankingsData = response.data['data']['rankings'] as List;
        rankings.clear();
        rankings.addAll(rankingsData.map((song) {
          String youtubeId = _extractYoutubeId(song['youtube_url'] ?? '');
          String thumbnail = song['youtube_thumbnail'] ?? '';

          // Tạo thumbnail URL nếu chưa có
          if (thumbnail.isEmpty && youtubeId.isNotEmpty) {
            thumbnail = 'https://img.youtube.com/vi/$youtubeId/mqdefault.jpg';
          }

          return Music(
            id: song['id'].toString(),
            title: song['title'] ?? 'Unknown',
            artistName: song['artist_name'] ?? 'Unknown Artist',
            youtubeId: youtubeId,
            youtubeThumbnail: thumbnail,
            playCount: (song['play_count'] ?? 0).toString(),
            position: song['position'] as int,
            duration: song['duration']?.toString() ?? '0',
            genre: (song['genres'] as List?)?.join(', ') ?? '',
            isLiked: false,
          );
        }));
      }
    } catch (e) {
      print('Error loading biggest hits: $e');
    } finally {
      isLoadingRankings.value = false;
    }
  }

  String _extractYoutubeId(String url) {
    if (url.isEmpty) return '';

    // Xử lý các định dạng URL YouTube phổ biến
    RegExp regExp = RegExp(
        r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*/');
    Match? match = regExp.firstMatch(url);

    if (match != null && match.groupCount >= 7) {
      return match.group(7) ?? '';
    }

    // Nếu URL đã là ID
    if (url.length == 11) return url;

    return '';
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
    currentQueue.clear();
    currentQueue.addAll(playlist);
    currentQueueIndex.value = currentIndex;
    isQueueMode.value = true;
    if (playlist.isNotEmpty) {
      updateCurrentMusic(playlist[currentIndex]);
    }
  }

  Future<void> playFromQueue(int index) async {
    if (index >= 0 && index < currentQueue.length) {
      try {
        final music = currentQueue[index];
        currentQueueIndex.value = index;

        // Cập nhật UI ngay lập tức
        currentTitle.value = music.title;
        currentArtist.value = music.artistName;
        currentImageUrl.value = music.youtubeThumbnail;
        currentYoutubeId.value = music.youtubeId;
        currentMusic.value = music;
        showMiniPlayer.value = true;

        // Load audio trong background
        await _loadAudioUrl(music.youtubeId);
      } catch (e) {
        print('Error playing from queue: $e');
        Get.snackbar(
          'Error',
          'Failed to play the song',
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    }
  }

  // Helper method để load audio URL
  Future<void> _loadAudioUrl(String youtubeId) async {
    int retryCount = 0;
    while (retryCount < 3) {
      try {
        final audioUrl = await getAudioUrl(youtubeId);
        if (audioUrl != null) {
          await audioPlayer.setUrl(audioUrl);
          await audioPlayer.play();
          break;
        }
        retryCount++;
      } catch (e) {
        print('Retry $retryCount failed: $e');
        await Future.delayed(Duration(seconds: 1));
        retryCount++;
      }
    }
  }

  // Thêm phương thức để cập nhật UI khi chuyển bài
  void updatePlayerUI() {
    if (currentQueueIndex.value >= 0 &&
        currentQueueIndex.value < currentQueue.length) {
      final music = currentQueue[currentQueueIndex.value];
      currentMusic.value = music;
      Get.to(() => PlayerScreen(
            title: music.title,
            artist: music.artistName,
            imageUrl: music.youtubeThumbnail,
            youtubeId: music.youtubeId,
          ));
    }
  }

  // Sửa lại phương thức playNext
  Future<void> playNext() async {
    if (currentQueueIndex.value < currentQueue.length - 1) {
      currentQueueIndex.value++;
      final nextMusic = currentQueue[currentQueueIndex.value];

      // Cập nhật UI trước
      updatePlayerUI();

      // Sau đó mới load và phát nhạc
      try {
        await changeMusic(
          nextMusic.youtubeId,
          nextMusic.title,
          nextMusic.artistName,
          nextMusic.youtubeThumbnail,
        );
        update(['player_screen', 'mini_player']);
      } catch (e) {
        print('Error playing next song: $e');
      }
    }
  }

  // Tương tự cho playPrevious
  Future<void> playPrevious() async {
    if (currentQueueIndex.value > 0) {
      currentQueueIndex.value--;
      final previousMusic = currentQueue[currentQueueIndex.value];

      // Cập nhật UI trước
      updatePlayerUI();

      // Sau đó mới load và phát nhạc
      try {
        await changeMusic(
          previousMusic.youtubeId,
          previousMusic.title,
          previousMusic.artistName,
          previousMusic.youtubeThumbnail,
        );
        update(['player_screen', 'mini_player']);
      } catch (e) {
        print('Error playing previous song: $e');
      }
    }
  }

  Future<void> changeMusic(
      String youtubeId, String title, String artist, String imageUrl) async {
    try {
      isChangingAudio.value = true;

      // Dừng audio hiện tại trước khi load audio mới
      await audioPlayer.stop();

      // Cập nhật UI trước
      currentYoutubeId.value = youtubeId;
      currentTitle.value = title;
      currentArtist.value = artist;
      currentImageUrl.value = imageUrl;

      // Load audio với retry mechanism
      int retryCount = 0;
      while (retryCount < 3) {
        try {
          final audioUrl = await getAudioUrl(youtubeId);
          if (audioUrl != null) {
            await audioPlayer.setUrl(audioUrl);
            await audioPlayer.play();
            break;
          }
          retryCount++;
        } catch (e) {
          print('Retry $retryCount failed: $e');
          await Future.delayed(Duration(seconds: 1));
          retryCount++;
        }
      }

      isChangingAudio.value = false;
    } catch (e) {
      print('Error changing music: $e');
      isChangingAudio.value = false;
      rethrow;
    }
  }

  Future<String?> getAudioUrl(String youtubeId) async {
    try {
      final url = await _musicService.getAudioUrl(youtubeId);
      return url;
    } catch (e) {
      print('Error getting audio URL: $e');
      return null;
    }
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
    currentImageUrl.value = _musicService.validateImageUrl(imageUrl);
    currentYoutubeId.value = youtubeId;
  }

  // Xử lý thay đổi audio
  Future<void> handleAudioChange() async {
    try {
      if (currentYoutubeId.value.isEmpty) return;

      final uri = Uri.parse(currentYoutubeId.value);
      final videoId = uri.queryParameters['v'] ?? currentYoutubeId.value;

      final audioUrl = await _musicService.getAudioUrl(videoId);
      if (audioUrl != null && audioUrl.isNotEmpty) {
        await audioPlayer.setUrl(audioUrl);
        await audioPlayer.play();
        isPlaying.value = true;
        showMiniPlayer.value = true;
      }
    } catch (e) {
      print('Error handling audio change: $e');
      Get.snackbar(
        'Error',
        'Cannot play this song',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
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
  void toggleMiniPlayer(bool value) {
    showMiniPlayer.value = value;
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

  // Method để thêm bài hát vào queue
  void addToQueue(Music song) {
    if (!isQueueMode.value) {
      // Nếu chưa có queue, tạo queue mới với bài hát hiện tại và bài hát mới
      final currentSong = Music(
        id: currentYoutubeId.value,
        title: currentTitle.value,
        artistName: currentArtist.value,
        youtubeThumbnail: currentImageUrl.value,
        youtubeId: currentYoutubeId.value,
        // displayImage: currentImageUrl.value,
      );

      currentQueue.clear();
      currentQueue.add(currentSong);
      currentQueue.add(song);
      currentQueueIndex.value = 0;
      isQueueMode.value = true;
    } else {
      // Thêm vào cuối hàng chờ
      currentQueue.add(song);
    }
  }

  Future<void> playQueueItem(int index) async {
    if (index >= 0 && index < currentQueue.length) {
      currentQueueIndex.value = index;
      final song = currentQueue[index];

      // Cập nhật bài hát hiện tại
      currentMusic.value = song;

      // Cập nhật các thông tin khác
      currentTitle.value = song.title;
      currentArtist.value = song.artistName;
      currentImageUrl.value = song.youtubeThumbnail;
      currentYoutubeId.value = song.youtubeId;

      // Phát nhạc
      final audioUrl = await _getAudioUrl(song.youtubeId);
      if (audioUrl != null) {
        await audioPlayer.stop();
        await audioPlayer.setUrl(audioUrl);
        await audioPlayer.play();
        isPlaying.value = true;
      }

      // Cập nhật UI
      update(['player_screen', 'mini_player']);
    }
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < currentQueue.length && newIndex < currentQueue.length) {
      if (newIndex > oldIndex) newIndex--;
      final item = currentQueue.removeAt(oldIndex);
      currentQueue.insert(newIndex, item);
    }
  }

  void clearQueue() {
    currentQueue.clear();
    isQueueMode.value = false;
    Get.back();
  }

  // Method để xóa bài hát khỏi queue
  void removeFromQueue(int index) {
    if (index < currentQueue.length) {
      currentQueue.removeAt(index);
      if (currentQueue.isEmpty) {
        isQueueMode.value = false;
      }
    }
  }

  Future<void> playMusic(
    Music song, {
    List<Music>? playlist,
    int? currentIndex,
    String? playlistName,
  }) async {
    try {
      // Set current queue if playlist is provided
      if (playlist != null) {
        currentQueue.assignAll(playlist);
        currentQueueIndex.value = currentIndex ?? 0;
        currentPlaylistName.value = playlistName ?? '';
      } else {
        // If no playlist, create single song queue
        currentQueue.assignAll([song]);
        currentQueueIndex.value = 0;
        currentPlaylistName.value = '';
      }

      // Update current music
      currentMusic.value = song;
      
      // Update UI values
      currentTitle.value = song.title;
      currentArtist.value = song.artistName;
      currentImageUrl.value = song.youtubeThumbnail;
      currentYoutubeId.value = song.youtubeId;

      // Handle audio change
      await handleAudioChange();
      
      // Show mini player
      showMiniPlayer.value = true;
      
    } catch (e) {
      print('Error playing music: $e');
      Get.snackbar(
        'Error',
        'Failed to play the song',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  // Helper method để lấy audio URL từ YouTube ID
  Future<String?> _getAudioUrl(String youtubeId) async {
    try {
      // Lấy manifest của video
      final manifest = await _yt.videos.streamsClient.getManifest(youtubeId);

      // Lấy audio stream với chất lượng cao nhất
      final audioStream = manifest.audioOnly.withHighestBitrate();

      if (audioStream != null) {
        return audioStream.url.toString();
      }

      return null;
    } catch (e) {
      print('Error getting audio URL: $e');
      return null;
    }
  }

  void updateQueueCount() {
    final remainingSongs = currentQueue.length - (currentQueueIndex.value + 1);
    update(['queue_screen']);
  }

  Future<void> playMusicDirectly(Music music) async {
    try {
      // Cập nhật thông tin bài hát hiện tại
      currentMusic.value = music;
      currentYoutubeId.value = music.youtubeId;

      // Hiển thị mini player
      showMiniPlayer.value = true;

      // Lấy và phát audio
      final audioUrl = await _getAudioUrl(music.youtubeId);
      if (audioUrl != null) {
        await audioPlayer.stop();
        await audioPlayer.setUrl(audioUrl);
        await audioPlayer.play();
        isPlaying.value = true;
      } else {
        throw Exception('Could not get audio URL');
      }

      // Cập nhật UI
      update(['player_screen', 'mini_player']);
    } catch (e) {
      print('Error playing music directly: $e');
      Get.snackbar(
        'Error',
        'Failed to play the song',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  // Thêm method để xử lý khi thu nhỏ player
  void minimizePlayer() {
    showMiniPlayer.value = true;
    Get.back();
  }

  void updateCurrentMusic(Music? music) {
    if (music != null) {
      currentMusic.value = music;
      currentTitle.value = music.title;
      currentArtist.value = music.artistName;
      currentImageUrl.value = music.youtubeThumbnail;
      currentYoutubeId.value = music.youtubeId;
      update();
    }
  }

  Music? getCurrentMusic() {
    return currentMusic.value;
  }

  Future<void> loadStartedMusic() async {
    try {
      final response = await dio.get('${ApiConstants.baseUrl}/api/music');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final musicData = response.data['data']['items'] as List;
        startedMusic.clear();
        startedMusic.addAll(musicData.map((song) => Music(
              id: song['id'].toString(),
              title: song['title'] ?? 'Unknown',
              artistName: song['artist_name'] ?? 'Unknown Artist',
              youtubeId: song['youtube_url']?.split('watch?v=').last ?? '',
              youtubeThumbnail: song['youtube_thumbnail'] ?? '',
              playCount: song['play_count']?.toString(),
              duration: song['duration']?.toString(),
              genre: song['genres']?.join(', '),
              isLiked: false,
            )));
      }
    } catch (e) {
      print('Error loading started music: $e');
    }
  }

  Future<void> loadRandomMusic() async {
    try {
      final response = await dio.get('${ApiConstants.baseUrl}/api/music/random',
          queryParameters: {'limit': 10});

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final musicData = response.data['data'] as List;
        randomMusic.clear();
        randomMusic.addAll(musicData.map((song) => Music.fromJson(song)));
      }
    } catch (e) {
      print('Error loading random music: $e');
    }
  }

  Future<void> loadAndPlayMusic(Music music) async {
    try {
      isLoading.value = true;
      updateCurrentTrack(
        music.title,
        music.artistName,
        music.youtubeThumbnail,
        music.youtubeId,
      );

      final audioUrl = await _musicService.getAudioUrl(music.youtubeId);
      if (audioUrl != null) {
        await audioPlayer.stop();
        await audioPlayer.setUrl(audioUrl);
        await audioPlayer.play();

        isPlaying.value = true;
        showMiniPlayer.value = true;
      } else {
        throw Exception('Could not get audio URL');
      }
    } catch (e) {
      print('Error playing music: $e');
      Get.snackbar(
        'Error',
        'Cannot play this song',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Thêm method để update state
  void updateCurrentTrack(
      String title, String artist, String imageUrl, String youtubeId) {
    currentTitle.value = title;
    currentArtist.value = artist;
    currentImageUrl.value = imageUrl;
    currentYoutubeId.value = youtubeId;
  }

  String get value => currentMusic.value?.title ?? '';
  bool get isNotEmpty => currentMusic.value != null;

  void navigateToPlayer() {
    if (currentMusic.value != null) {
      final music = currentMusic.value!;
      Get.to(() => PlayerScreen(
            title: music.title,
            artist: music.artistName,
            imageUrl: music.youtubeThumbnail,
            youtubeId: music.youtubeId,
          ));
    }
  }

  Future<void> changeRegion(String region) async {
    try {
      selectedRegion.value = region;
      isLoadingRankings.value = true;

      // Load rankings for new region
      await loadBiggestHits(region);

      // Reload data if needed
      await loadData();
    } catch (e) {
      print('Error changing region: $e');
      Get.snackbar(
        'Error',
        'Failed to change region',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoadingRankings.value = false;
    }
  }

  // Add method to update recent music
  void addToRecentMusic(Music song) {
    // Remove song if it already exists
    recentMusic.removeWhere((m) => m.id == song.id);
    
    // Add to beginning of list
    recentMusic.insert(0, song);
    
    // Keep only last 20 songs
    if (recentMusic.length > 20) {
      recentMusic.removeLast();
    }
  }
}
