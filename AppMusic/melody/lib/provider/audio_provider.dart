import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioProvider with ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  String? currentSongTitle;
  String? currentArtist;
  String? currentImageUrl;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  void play(String url, String title, String artist, String? imageUrl) {
    currentSongTitle = title;
    currentArtist = artist;
    currentImageUrl = imageUrl;
    _player.setUrl(url);
    _player.play();
    isPlaying = true;
    notifyListeners();
  }

  void pause() {
    _player.pause();
    isPlaying = false;
    notifyListeners();
  }
}
