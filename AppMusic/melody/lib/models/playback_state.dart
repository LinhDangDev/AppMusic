import 'enums.dart';

// User's playback state model (current song, repeat mode, shuffle, etc)

class PlaybackState {
  final int userId;
  final int? currentMusicId;
  final int? currentPlaylistId;
  final RepeatMode repeatMode;
  final bool shuffleMode;
  final int? lastPosition;
  final DateTime updatedAt;

  PlaybackState({
    required this.userId,
    this.currentMusicId,
    this.currentPlaylistId,
    required this.repeatMode,
    required this.shuffleMode,
    this.lastPosition,
    required this.updatedAt,
  });

  factory PlaybackState.fromJson(Map<String, dynamic> json) {
    return PlaybackState(
      userId: json['user_id'] as int,
      currentMusicId: json['current_music_id'] as int?,
      currentPlaylistId: json['current_playlist_id'] as int?,
      repeatMode: RepeatMode.values
          .byName((json['repeat_mode'] as String? ?? 'off').toLowerCase()),
      shuffleMode: json['shuffle_mode'] as bool? ?? false,
      lastPosition: json['last_position'] as int?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'current_music_id': currentMusicId,
        'current_playlist_id': currentPlaylistId,
        'repeat_mode': repeatMode.name.toUpperCase(),
        'shuffle_mode': shuffleMode,
        'last_position': lastPosition,
        'updated_at': updatedAt.toIso8601String(),
      };
}
