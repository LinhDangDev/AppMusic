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
  final RxList<Music> getYouStarted = <Music>[].obs;
  final RxBool isLoadingGetYouStarted = true.obs;

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
        // Error handling
      },
    );
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

        // Xóa danh sách cũ và thêm danh sách mới
        rankings.clear();

        // Chuyển đổi dữ liệu và thêm vào danh sách rankings
        final newRankings = rankingsData.map((song) {
          // Đảm bảo lấy được youtube_id từ youtube_url
          String youtubeId = _extractYoutubeId(song['youtube_url'] ?? '');
          String thumbnail = song['youtube_thumbnail'] ?? '';

          // Nếu không có thumbnail nhưng có youtube_id thì tạo thumbnail từ youtube_id
          if (thumbnail.isEmpty && youtubeId.isNotEmpty) {
            thumbnail = 'https://img.youtube.com/vi/$youtubeId/mqdefault.jpg';
          }

          return Music(
            id: int.tryParse(song['id']?.toString() ?? '') ?? 0,
            title: song['title'] ?? '',
            artistName: song['artist_name'] ?? '',
            youtubeId: youtubeId,
            youtubeThumbnail: thumbnail,
            playCount: int.tryParse(song['play_count']?.toString() ?? '') ?? 0,
            position: song['position'] as int?,
            duration: int.tryParse(song['duration']?.toString() ?? '') ?? 0,
            genre: (song['genres'] as List?)?.join(', '),
          );
        }).toList();

        rankings.addAll(newRankings);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load rankings',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoadingRankings.value = false;
    }
  }

  // Helper method để extract youtube_id từ youtube_url
  String _extractYoutubeId(String url) {
    try {
      if (url.isEmpty) return '';

      if (url.contains('youtu.be/')) {
        return url.split('youtu.be/')[1].split('?')[0];
      } else if (url.contains('youtube.com/watch')) {
        return Uri.parse(url).queryParameters['v'] ?? '';
      } else if (url.length == 11) {
        // Nếu url đã là youtube_id
        return url;
      }
      return '';
    } catch (e) {
      return '';
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
    currentQueue.clear();
    currentQueue.addAll(playlist);
    currentQueueIndex.value = currentIndex;
    isQueueMode.value = true; // Explicitly set to true
    currentPlaylistName.value = playlistName;
    if (playlist.isNotEmpty &&
        currentIndex >= 0 &&
        currentIndex < playlist.length) {
      updateCurrentMusic(playlist[currentIndex]);
    }
  }

  Future<void> playFromQueue(int index) async {
    if (index >= 0 && index < currentQueue.length) {
      try {
        final music = currentQueue[index];
        currentQueueIndex.value = index;
        isQueueMode.value = true; // Ensure queue mode is active

        // Cập nhật UI ngay lập tức
        currentTitle.value = music.title;
        currentArtist.value = music.artistName ?? '';
        currentImageUrl.value = music.youtubeThumbnail ?? '';
        currentYoutubeId.value = music.youtubeId ?? '';
        currentMusic.value = music;
        showMiniPlayer.value = true;

        // Load audio trong background
        await _loadAudioUrl(music.youtubeId ?? '');
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
            artist: music.artistName ?? '',
            imageUrl: music.youtubeThumbnail ?? '',
            youtubeId: music.youtubeId ?? '',
          ));
    }
  }

  // Sửa lại phương thức playNext with better error handling and bounds checking
  Future<void> playNext() async {
    // Verify we're in queue mode and have valid state
    if (!isQueueMode.value || currentQueue.isEmpty) {
      print('Cannot play next: not in queue mode or queue is empty');
      return;
    }

    if (currentQueueIndex.value < currentQueue.length - 1) {
      currentQueueIndex.value++;

      // Bounds check before accessing
      if (currentQueueIndex.value >= currentQueue.length) {
        print('Error: Queue index out of bounds');
        currentQueueIndex.value = currentQueue.length - 1;
        return;
      }

      final nextMusic = currentQueue[currentQueueIndex.value];

      // Cập nhật UI trước
      updatePlayerUI();

      // Sau đó mới load và phát nhạc
      try {
        await changeMusic(
          nextMusic.youtubeId ?? '',
          nextMusic.title,
          nextMusic.artistName ?? '',
          nextMusic.youtubeThumbnail ?? '',
        );
        update(['player_screen', 'mini_player']);
      } catch (e) {
        print('Error playing next song: $e');
        // Rollback on error
        if (currentQueueIndex.value > 0) {
          currentQueueIndex.value--;
        }
      }
    } else {
      // Reached end of queue
      print('Reached end of queue');
      if (repeatMode.value == RepeatMode.all) {
        currentQueueIndex.value = 0;
        await playNext();
      }
    }
  }

  // Tương tự cho playPrevious with better error handling
  Future<void> playPrevious() async {
    // Verify we're in queue mode and have valid state
    if (!isQueueMode.value || currentQueue.isEmpty) {
      print('Cannot play previous: not in queue mode or queue is empty');
      return;
    }

    if (currentQueueIndex.value > 0) {
      currentQueueIndex.value--;

      // Bounds check before accessing
      if (currentQueueIndex.value < 0) {
        print('Error: Queue index below zero');
        currentQueueIndex.value = 0;
        return;
      }

      final previousMusic = currentQueue[currentQueueIndex.value];

      // Cập nhật UI trước
      updatePlayerUI();

      // Sau đó mới load và phát nhạc
      try {
        await changeMusic(
          previousMusic.youtubeId ?? '',
          previousMusic.title,
          previousMusic.artistName ?? '',
          previousMusic.youtubeThumbnail ?? '',
        );
        update(['player_screen', 'mini_player']);
      } catch (e) {
        print('Error playing previous song: $e');
        // Rollback on error
        if (currentQueueIndex.value < currentQueue.length - 1) {
          currentQueueIndex.value++;
        }
      }
    } else {
      // At beginning of queue
      print('Already at beginning of queue');
    }
  }

  Future<void> changeMusic(
      String youtubeId, String title, String artist, String imageUrl) async {
    // Validate inputs
    if (youtubeId.isEmpty) {
      print('Error: Empty YouTube ID');
      Get.snackbar(
        'Error',
        'Invalid video ID',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return;
    }

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
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          final audioUrl = await getAudioUrl(youtubeId);
          if (audioUrl != null && audioUrl.isNotEmpty) {
            await audioPlayer.setUrl(audioUrl);
            await audioPlayer.play();
            isChangingAudio.value = false;
            return; // Success
          }
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: 1));
          }
        } catch (e) {
          print('Retry $retryCount failed: $e');
          await Future.delayed(Duration(seconds: 1));
          retryCount++;
        }
      }

      // All retries failed
      isChangingAudio.value = false;
      throw Exception('Failed to load audio after $maxRetries retries');
    } catch (e) {
      isChangingAudio.value = false;
      print('Error changing music: $e');
      Get.snackbar(
        'Error',
        'Failed to play song: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  // Consolidated audio URL loading method with retry and fallback logic
  Future<String?> getAudioUrl(String youtubeId) async {
    if (youtubeId.isEmpty) {
      print('Error: Empty YouTube ID provided');
      return null;
    }

    try {
      // First try: Use MusicService (faster, API-based)
      try {
        final url = await _musicService.getAudioUrl(youtubeId);
        if (url != null && url.isNotEmpty) {
          return url;
        }
      } catch (e) {
        print('MusicService failed, trying fallback: $e');
      }

      // Fallback: Use youtube_explode (slower but reliable)
      try {
        final manifest = await _yt.videos.streamsClient.getManifest(youtubeId);
        final audioStream = manifest.audioOnly.withHighestBitrate();
        return audioStream.url.toString();
      } catch (e) {
        // Fallback audio extraction failed
      }

      return null;
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
      // Nếu đang pause, giữ nguyên trạng thái pause
      if (!isPlaying.value) {
        await audioPlayer.pause();
      }
      update(['player_screen', 'mini_player']);
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  // Cập nhật method togglePlay
  Future<void> togglePlay() async {
    try {
      if (isPlaying.value) {
        // Khi pause, lưu lại vị trí hiện tại
        await audioPlayer.pause();
        isPlaying.value = false;
      } else {
        // Khi play lại, lấy vị trí đã lưu
        final currentPos = position.value;
        await audioPlayer.play();

        // Seek về vị trí đã lưu nếu có
        if (currentPos != Duration.zero) {
          await audioPlayer.seek(currentPos);
        }

        isPlaying.value = true;
      }
      update(['player_screen', 'mini_player']);
    } catch (e) {
      print('Error toggling play state: $e');
      Get.snackbar(
        'Error',
        'Failed to toggle playback',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
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
        id: null,
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
      currentArtist.value = song.artistName ?? '';
      currentImageUrl.value = song.youtubeThumbnail ?? '';
      currentYoutubeId.value = song.youtubeId ?? '';

      // Phát nhạc
      final audioUrl = await getAudioUrl(song.youtubeId ?? '');
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
      // Validate song has required fields
      if (song.youtubeId == null || song.youtubeId!.isEmpty) {
        throw Exception('Invalid song: missing YouTube ID');
      }

      // Set current queue if playlist is provided
      if (playlist != null && playlist.isNotEmpty) {
        currentQueue.assignAll(playlist);
        currentQueueIndex.value = currentIndex ?? 0;
        currentPlaylistName.value = playlistName ?? '';
        isQueueMode.value = true; // Set queue mode
      } else {
        // If no playlist, create single song queue
        currentQueue.assignAll([song]);
        currentQueueIndex.value = 0;
        currentPlaylistName.value = '';
        isQueueMode.value = true; // Set queue mode even for single song
      }

      // Update current music
      currentMusic.value = song;

      // Update UI values
      currentTitle.value = song.title;
      currentArtist.value = song.artistName ?? '';
      currentImageUrl.value = song.youtubeThumbnail ?? '';
      currentYoutubeId.value = song.youtubeId ?? '';

      // Show mini player
      showMiniPlayer.value = true;

      // Handle audio change
      await handleAudioChange();
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

  void updateQueueCount() {
    update(['queue_screen']);
  }

  Future<void> playMusicDirectly(Music music) async {
    try {
      // Cập nhật thông tin bài hát hiện tại
      currentMusic.value = music;
      currentTitle.value = music.title;
      currentArtist.value = music.artistName ?? '';
      currentImageUrl.value = music.youtubeThumbnail ?? '';
      currentYoutubeId.value = music.youtubeId ?? '';

      // Hiển thị mini player trước khi phát nhạc
      showMiniPlayer.value = true;

      // Thêm vào queue nếu chưa có
      if (currentQueue.isEmpty) {
        currentQueue.add(music);
        currentQueueIndex.value = 0;
      }

      // Lấy và phát audio
      final audioUrl = await getAudioUrl(music.youtubeId ?? '');
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
      currentArtist.value = music.artistName ?? '';
      currentImageUrl.value = music.youtubeThumbnail ?? '';
      currentYoutubeId.value = music.youtubeId ?? '';
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
              id: int.tryParse(song['id']?.toString() ?? '') ?? 0,
              title: song['title'] ?? 'Unknown',
              artistName: song['artist_name'] ?? 'Unknown Artist',
              youtubeId: song['youtube_url']?.split('watch?v=').last ?? '',
              youtubeThumbnail: song['youtube_thumbnail'] ?? '',
              playCount:
                  int.tryParse(song['play_count']?.toString() ?? '') ?? 0,
              duration: int.tryParse(song['duration']?.toString() ?? '') ?? 0,
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
      final response =
          await dio.get('${ApiConstants.baseUrl}/api/music/random?limit=10');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final songsData = response.data['data'] as List;

        // Xóa danh sách cũ
        randomMusic.clear();

        // Chuyển đổi dữ liệu và thêm vào danh sách
        final newSongs = songsData.map((song) {
          String youtubeId = _extractYoutubeId(song['youtube_url'] ?? '');
          String thumbnail = song['youtube_thumbnail'] ?? '';

          if (thumbnail.isEmpty && youtubeId.isNotEmpty) {
            thumbnail = 'https://img.youtube.com/vi/$youtubeId/mqdefault.jpg';
          }

          return Music(
            id: int.tryParse(song['id']?.toString() ?? '') ?? 0,
            title: song['title'] ?? '',
            artistName: song['artist_name'] ?? '',
            youtubeId: youtubeId,
            youtubeThumbnail: thumbnail,
            playCount: int.tryParse(song['play_count']?.toString() ?? '') ?? 0,
            duration: int.tryParse(song['duration']?.toString() ?? '') ?? 0,
            genre: (song['genres'] as List?)?.join(', '),
          );
        }).toList();

        randomMusic.addAll(newSongs);
      }
    } catch (e) {
      print('Error loading random music: $e');
    }
  }

  Future<void> loadAndPlayMusic(Music music) async {
    try {
      // Validate music has required fields
      if (music.youtubeId == null || music.youtubeId!.isEmpty) {
        throw Exception('Invalid music: missing YouTube ID');
      }

      isLoading.value = true;
      updateCurrentTrack(
        music.title,
        music.artistName ?? '',
        music.youtubeThumbnail ?? '',
        music.youtubeId ?? '',
      );

      // Ensure the song is in the queue
      if (currentQueue.isEmpty ||
          (currentQueue.isNotEmpty &&
              currentQueue[currentQueueIndex.value].youtubeId !=
                  music.youtubeId)) {
        // Add to queue if not already there
        currentQueue.add(music);
        currentQueueIndex.value = currentQueue.length - 1;
        isQueueMode.value = true;
      }

      final audioUrl = await getAudioUrl(music.youtubeId ?? '');
      if (audioUrl != null && audioUrl.isNotEmpty) {
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
        'Cannot play this song: ${e.toString()}',
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
            artist: music.artistName ?? '',
            imageUrl: music.youtubeThumbnail ?? '',
            youtubeId: music.youtubeId ?? '',
          ));
    }
  }

  Future<void> changeRegion(String region) async {
    try {
      isChangingAudio.value = true;

      // Lưu lại trạng thái phát nhạc hiện tại
      final wasPlaying = isPlaying.value;
      final currentSongId = currentYoutubeId.value ?? '';

      // Cập nhật region và load danh sách mới
      selectedRegion.value = region;
      await loadBiggestHits(region);

      // Nếu đang phát nhạc, tìm bài hát tương ứng trong danh sách mới
      if (wasPlaying && currentSongId.isNotEmpty) {
        final newSongIndex = rankings
            .indexWhere((song) => (song.youtubeId ?? '') == currentSongId);
        if (newSongIndex != -1) {
          // Nếu tìm thấy bài hát, tiếp tục phát
          await playMusic(rankings[newSongIndex],
              playlist: rankings,
              currentIndex: newSongIndex,
              playlistName: "Top Songs ${selectedRegion.value}");
        } else {
          // Nếu không tìm thấy, dừng phát
          await audioPlayer.stop();
          resetCurrentTrack();
        }
      }
    } catch (e) {
      print('Error changing region: $e');
    } finally {
      isChangingAudio.value = false;
    }
  }

  // Thêm method mới để reset thông tin bài hát hiện tại
  void resetCurrentTrack() {
    currentTitle.value = '';
    currentArtist.value = '';
    currentImageUrl.value = '';
    currentYoutubeId.value = '';
    showMiniPlayer.value = false;
    isPlaying.value = false;
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

  Future<void> loadGetYouStarted() async {
    try {
      isLoadingGetYouStarted.value = true;
      final response =
          await dio.get('${ApiConstants.baseUrl}/api/music/random?limit=10');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final songsData = response.data['data'] as List;

        // Xóa danh sách cũ
        getYouStarted.clear();

        // Chuyển đổi dữ liệu và thêm vào danh sách
        final newSongs = songsData.map((song) {
          String youtubeId = _extractYoutubeId(song['youtube_url'] ?? '');
          String thumbnail = song['youtube_thumbnail'] ?? '';

          if (thumbnail.isEmpty && youtubeId.isNotEmpty) {
            thumbnail = 'https://img.youtube.com/vi/$youtubeId/mqdefault.jpg';
          }

          return Music(
            id: int.tryParse(song['id']?.toString() ?? '') ?? 0,
            title: song['title'] ?? '',
            artistName: song['artist_name'] ?? '',
            youtubeId: youtubeId,
            youtubeThumbnail: thumbnail,
            playCount: int.tryParse(song['play_count']?.toString() ?? '') ?? 0,
            duration: int.tryParse(song['duration']?.toString() ?? '') ?? 0,
            genre: (song['genres'] as List?)?.join(', '),
          );
        }).toList();

        getYouStarted.addAll(newSongs);
      }
    } catch (e) {
      print('Error loading Get You Started: $e');
      Get.snackbar(
        'Error',
        'Failed to load recommended songs',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoadingGetYouStarted.value = false;
    }
  }
}
