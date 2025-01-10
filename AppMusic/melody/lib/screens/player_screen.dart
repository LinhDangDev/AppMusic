import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class PlayerScreen extends StatefulWidget {
  final String? songTitle;
  final String? artistName;
  final String? imageUrl;
  final bool isPlaying;
  final VoidCallback? onPlayPause;

  const PlayerScreen({
    Key? key,
    this.songTitle,
    this.artistName,
    this.imageUrl,
    this.isPlaying = false,
    this.onPlayPause,
  }) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioHandler _audioHandler;
  double _currentSliderValue = 0.0;
  bool _isLyricsVisible = true;

  @override
  void initState() {
    super.initState();
    // _setupAudioHandler();
  }

  // Future<void> _setupAudioHandler() async {
  //   _audioHandler = await AudioService.init(
  //     builder: () => MyAudioHandler(),
  //     config: const AudioServiceConfig(
  //       androidNotificationChannelId: 'com.myapp.audio',
  //       androidNotificationChannelName: 'Audio Service',
  //       androidNotificationOngoing: true,
  //     ),
  //   );
  // }

  void _handlePlayPause() async {
    final playbackState = _audioHandler.playbackState.value;
    if (playbackState.playing) {
      await _audioHandler.pause();
    } else {
      if (_audioHandler.mediaItem.value == null) {
        await _audioHandler.addQueueItem(
          MediaItem(
            id: '1',
            album: 'Album Name',
            title: 'Song Title',
            artist: 'Artist Name',
            duration: const Duration(minutes: 4, seconds: 9),
            artUri: Uri.parse('https://example.com/albumart.jpg'),
          ),
        );
      }
      await _audioHandler.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Title Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ĐANG PHÁT TỪ DANH SÁCH PHÁT',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Nhạc Tết',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () => _showOptionsModal(),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header Image
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/playlist1.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Song Info
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Die With A Smile',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Lady Gaga & Bruno Mars',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 28,
                          ),
                        ],
                      ),
                    ),

                    // Progress Bar
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 2,
                              thumbShape:
                                  RoundSliderThumbShape(enabledThumbRadius: 4),
                              overlayShape:
                                  RoundSliderOverlayShape(overlayRadius: 8),
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.grey[800],
                              thumbColor: Colors.white,
                            ),
                            child: Slider(
                              value: _currentSliderValue,
                              onChanged: (value) {
                                setState(() {
                                  _currentSliderValue = value;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('0:01',
                                    style: TextStyle(color: Colors.grey)),
                                Text('4:09',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Controls
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.shuffle, color: Colors.white),
                          Icon(Icons.skip_previous,
                              color: Colors.white, size: 40),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: IconButton(
                              icon: StreamBuilder<PlaybackState>(
                                stream: _audioHandler.playbackState,
                                builder: (context, snapshot) {
                                  final playing =
                                      snapshot.data?.playing ?? false;
                                  return Icon(
                                    playing ? Icons.pause : Icons.play_arrow,
                                    size: 40,
                                    color: Colors.black,
                                  );
                                },
                              ),
                              onPressed: _handlePlayPause,
                            ),
                          ),
                          Icon(Icons.skip_next, color: Colors.white, size: 40),
                          Icon(Icons.repeat, color: Colors.white),
                        ],
                      ),
                    ),

                    // Bottom Controls
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.speaker, color: Colors.white),
                          Icon(Icons.share, color: Colors.white),
                        ],
                      ),
                    ),

                    // Lyrics Section
                    Container(
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bản xem trước lời bài hát',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'I\'m gonna die with a smile',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () {},
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Hiện lời bài hát',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF282828),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with song info
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    'assets/playlist1.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  "Don't Forget Your Roots - 2021",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Six 60',
                  style: TextStyle(color: Colors.grey),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Divider(color: Colors.grey[800], height: 1),

              // Options list
              _buildOptionTile(Icons.music_note, 'Listen to music ad-free',
                  trailing: TextButton(
                    onPressed: () {},
                    child:
                        Text('Premium', style: TextStyle(color: Colors.blue)),
                  )),
              _buildOptionTile(Icons.favorite_border, 'Like'),
              _buildOptionTile(Icons.remove_circle_outline, 'Hide this song'),
              _buildOptionTile(Icons.playlist_add, 'Add to playlist'),
              _buildOptionTile(Icons.queue_music, 'Add to queue'),
              _buildOptionTile(Icons.album, 'View album'),
              _buildOptionTile(Icons.person, 'View artist'),
              _buildOptionTile(Icons.share, 'Share'),
              _buildOptionTile(Icons.info_outline, 'Show credits'),
              _buildOptionTile(Icons.bar_chart, 'Show spotify code'),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(IconData icon, String text, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
      trailing: trailing,
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  void dispose() {
    // Clean up if needed
    super.dispose();
  }
}

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();

  MyAudioHandler() {
    _player.playbackEventStream.listen(_broadcastState);
    _player.playerStateStream.listen((playerState) {
      _broadcastState(_player.playbackEvent);
    });
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    try {
      // Thay thế URL này bằng URL thực từ backend của bạn
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse('YOUR_AUDIO_URL_HERE'),
          tag: mediaItem,
        ),
      );
      this.mediaItem.add(mediaItem);
    } catch (e) {
      print('Error loading audio source: $e');
    }
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: 0,
      ),
    );
  }
}
