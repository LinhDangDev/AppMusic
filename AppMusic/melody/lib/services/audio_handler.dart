import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _yt = YoutubeExplode();
  
  MyAudioHandler() {
    _player.playbackEventStream.listen((event) {
      _broadcastState();
    });
  }

  Future<void> playYoutubeMusic(String videoId, String title, String artist) async {
    try {
      // Get streaming URL from YouTube
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioStream = manifest.audioOnly.withHighestBitrate();
      
      // Set audio source
      await _player.setAudioSource(AudioSource.uri(
        Uri.parse(audioStream.url.toString()),
        tag: MediaItem(
          id: videoId,
          title: title,
          artist: artist,
        ),
      ));
      
      // Update metadata
      mediaItem.add(MediaItem(
        id: videoId,
        title: title,
        artist: artist,
      ));

      // Play
      play();
    } catch (e) {
      print("Error loading YouTube audio: $e");
    }
  }

  Future<void> playMusic(String url, String title, String artist) async {
    try {
      // Set audio source
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      
      // Update metadata
      mediaItem.add(MediaItem(
        id: url,
        title: title,
        artist: artist,
      ));

      // Play
      play();
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  void _broadcastState() {
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: 0,
    ));
  }
}
