import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
import 'package:melody/provider/music_controller.dart';
import 'package:melody/services/audio_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:melody/models/music.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  MyAudioHandler? _audioHandler;
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  // Thêm enum cho chế độ repeat
  RepeatMode repeatMode = RepeatMode.off;

  // Thông tin bài hát hiện tại
  String? currentSongTitle;
  String? currentArtist;
  String? currentImageUrl;
  String? currentYoutubeId;

  // Thêm biến để quản lý trạng thái shuffle
  bool isShuffleEnabled = false;
  bool isSmartShuffleEnabled = false;
  List<int> shuffledIndices = [];
  int currentShuffleIndex = 0;

  AudioProvider() {
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying = state.playing;
      notifyListeners();
    });

    _audioPlayer.positionStream.listen((pos) {
      position = pos;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((dur) {
      duration = dur ?? Duration.zero;
      notifyListeners();
    });
  }

  Future<void> initAudioHandler() async {
    if (_audioHandler == null) {
      _audioHandler = await AudioService.init(
        builder: () => MyAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.myapp.audio',
          androidNotificationChannelName: 'Audio Service',
          androidNotificationOngoing: true,
        ),
      );
    }
  }

  Future<void> playYoutubeAudio(String youtubeId, {
    required String title,
    required String artist,
    required String imageUrl,
  }) async {
    try {
      // Khởi tạo AudioHandler nếu chưa có
      if (_audioHandler == null) {
        await initAudioHandler();
      }

      // Cập nhật thông tin bài hát
      currentSongTitle = title;
      currentArtist = artist;
      currentImageUrl = imageUrl;
      currentYoutubeId = youtubeId;

      // Play audio thông qua AudioHandler
      await _audioHandler?.playYoutubeAudio(youtubeId);

      // Lắng nghe duration và position từ AudioHandler
      if (_audioHandler != null) {
        _audioHandler!.player.durationStream.listen((dur) {
          duration = dur ?? Duration.zero;
          notifyListeners();
        });

        _audioHandler!.player.positionStream.listen((pos) {
          position = pos;
          notifyListeners();
        });
      }

      isPlaying = true;
      notifyListeners();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> pause() async {
    await _audioHandler?.pause();
    isPlaying = false;
    notifyListeners();
  }

  Future<void> resume() async {
    await _audioHandler?.play();
    isPlaying = true;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    if (_audioHandler != null) {
      await _audioHandler!.player.seek(position);
      this.position = position;
      notifyListeners();
    }
  }

  Future<void> playNext() async {
    final musicController = Get.find<MusicController>();
    final queueLength = musicController.currentQueue.length;
    
    if (queueLength == 0) return;

    int nextIndex;
    
    if (isShuffleEnabled || isSmartShuffleEnabled) {
      currentShuffleIndex++;
      if (currentShuffleIndex >= shuffledIndices.length) {
        if (repeatMode == RepeatMode.all) {
          currentShuffleIndex = 0;
        } else {
          return;
        }
      }
      nextIndex = shuffledIndices[currentShuffleIndex];
    } else {
      nextIndex = musicController.currentQueueIndex.value + 1;
      if (nextIndex >= queueLength) {
        if (repeatMode == RepeatMode.all) {
          nextIndex = 0;
        } else {
          return;
        }
      }
    }

    final nextMusic = musicController.currentQueue[nextIndex];
    await playYoutubeAudio(
      nextMusic.youtubeId,
      title: nextMusic.title,
      artist: nextMusic.artistName,
      imageUrl: nextMusic.youtubeThumbnail,
    );
    
    musicController.currentQueueIndex.value = nextIndex;
  }

  Future<void> playPrevious() async {
    final musicController = Get.find<MusicController>();
    final queueLength = musicController.currentQueue.length;
    
    if (queueLength == 0) return;

    int previousIndex;
    
    if (isShuffleEnabled || isSmartShuffleEnabled) {
      currentShuffleIndex--;
      if (currentShuffleIndex < 0) {
        if (repeatMode == RepeatMode.all) {
          currentShuffleIndex = shuffledIndices.length - 1;
        } else {
          return;
        }
      }
      previousIndex = shuffledIndices[currentShuffleIndex];
    } else {
      previousIndex = musicController.currentQueueIndex.value - 1;
      if (previousIndex < 0) {
        if (repeatMode == RepeatMode.all) {
          previousIndex = queueLength - 1;
        } else {
          return;
        }
      }
    }

    final previousMusic = musicController.currentQueue[previousIndex];
    await playYoutubeAudio(
      previousMusic.youtubeId,
      title: previousMusic.title,
      artist: previousMusic.artistName,
      imageUrl: previousMusic.youtubeThumbnail,
    );
    
    musicController.currentQueueIndex.value = previousIndex;
  }

  // Thêm method để toggle repeat mode
  void toggleRepeatMode() {
    switch (repeatMode) {
      case RepeatMode.off:
        repeatMode = RepeatMode.single;
        _audioHandler?.player.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.single:
        repeatMode = RepeatMode.all;
        _audioHandler?.player.setLoopMode(LoopMode.all);
        break;
      case RepeatMode.all:
        repeatMode = RepeatMode.off;
        _audioHandler?.player.setLoopMode(LoopMode.off);
        break;
    }
    notifyListeners();
  }

  // Thêm method để toggle shuffle thường
  void toggleShuffle() {
    final musicController = Get.find<MusicController>();
    
    if (isSmartShuffleEnabled) {
      // Nếu đang bật smart shuffle thì tắt nó trước
      isSmartShuffleEnabled = false;
    }
    
    isShuffleEnabled = !isShuffleEnabled;
    
    if (isShuffleEnabled) {
      // Tạo danh sách index ngẫu nhiên
      shuffledIndices = List.generate(
        musicController.currentQueue.length, 
        (index) => index
      );
      shuffledIndices.shuffle();
      
      // Đặt vị trí hiện tại vào đầu danh sách
      int currentIndex = musicController.currentQueueIndex.value;
      shuffledIndices.remove(currentIndex);
      shuffledIndices.insert(0, currentIndex);
      currentShuffleIndex = 0;
    }
    
    notifyListeners();
  }

  // Thêm method để toggle smart shuffle
  void toggleSmartShuffle() {
    final musicController = Get.find<MusicController>();
    
    if (isShuffleEnabled) {
      // Nếu đang bật shuffle thường thì tắt nó trước
      isShuffleEnabled = false;
    }
    
    isSmartShuffleEnabled = !isSmartShuffleEnabled;
    
    if (isSmartShuffleEnabled) {
      // Tạo danh sách index theo thuật toán thông minh
      shuffledIndices = _generateSmartShuffleOrder(
        musicController.currentQueue.length,
        musicController.currentQueueIndex.value
      );
      currentShuffleIndex = 0;
    }
    
    notifyListeners();
  }

  // Thuật toán tạo thứ tự phát thông minh
  List<int> _generateSmartShuffleOrder(int totalSongs, int currentIndex) {
    List<int> indices = List.generate(totalSongs, (index) => index);
    indices.remove(currentIndex);
    
    // Chia playlist thành các nhóm
    int groupSize = (totalSongs / 3).ceil();
    List<List<int>> groups = [];
    
    // Nhóm 1: Các bài gần với bài hiện tại
    List<int> nearbySongs = indices.where((i) => 
      (i - currentIndex).abs() <= groupSize
    ).toList();
    nearbySongs.shuffle();
    groups.add(nearbySongs);
    
    // Nhóm 2: Các bài ở giữa
    List<int> middleSongs = indices.where((i) =>
      (i - currentIndex).abs() > groupSize && 
      (i - currentIndex).abs() <= groupSize * 2
    ).toList();
    middleSongs.shuffle();
    groups.add(middleSongs);
    
    // Nhóm 3: Các bài xa nhất
    List<int> farSongs = indices.where((i) =>
      (i - currentIndex).abs() > groupSize * 2
    ).toList();
    farSongs.shuffle();
    groups.add(farSongs);
    
    // Ghép các nhóm lại, đặt bài hiện tại lên đầu
    List<int> result = [currentIndex];
    for (var group in groups) {
      result.addAll(group);
    }
    
    return result;
  }

  Future<void> updateQueue(List<Map<String, String>> queue, int index) async {
    try {
      final musicController = Get.find<MusicController>();
      
      // Cập nhật queue trong MusicController
      musicController.currentQueue.clear();
      musicController.currentQueue.addAll(queue.map((song) => Music(
        id: '', // Có thể bỏ qua vì không cần thiết cho việc phát nhạc
        title: song['title']!,
        artistName: song['artist']!,
        displayImage: song['imageUrl']!,
        youtubeId: song['youtubeId']!,
        youtubeThumbnail: song['imageUrl']!,
      )).toList());
      
      musicController.currentQueueIndex.value = index;

      // Phát bài hát được chọn
      final selectedSong = queue[index];
      await playYoutubeAudio(
        selectedSong['youtubeId']!,
        title: selectedSong['title']!,
        artist: selectedSong['artist']!,
        imageUrl: selectedSong['imageUrl']!,
      );
    } catch (e) {
      print('Error updating queue: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

// Thêm enum cho các chế độ repeat
enum RepeatMode {
  off,
  single,
  all,
}
