// Playlist-Song junction table model (stores order of songs in playlist)

class PlaylistSong {
  final int playlistId;
  final int musicId;
  final int? position;
  final DateTime addedAt;

  PlaylistSong({
    required this.playlistId,
    required this.musicId,
    this.position,
    required this.addedAt,
  });

  factory PlaylistSong.fromJson(Map<String, dynamic> json) {
    return PlaylistSong(
      playlistId: json['playlist_id'] as int,
      musicId: json['music_id'] as int,
      position: json['position'] as int?,
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'playlist_id': playlistId,
        'music_id': musicId,
        'position': position,
        'added_at': addedAt.toIso8601String(),
      };
}
