import 'music.dart';

// Playlists table model
class Playlist {
  final int id;
  final int userId;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isShared;
  final int songCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Playlist({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.isShared,
    required this.songCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      isShared: json['is_shared'] as bool? ?? false,
      songCount: json['song_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'description': description,
        'image_url': imageUrl,
        'is_shared': isShared,
        'song_count': songCount,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

// Extended Playlist with songs
class PlaylistWithSongs extends Playlist {
  final List<Music>? songs;

  PlaylistWithSongs({
    required int id,
    required int userId,
    required String name,
    String? description,
    required bool isShared,
    required int songCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.songs,
  }) : super(
          id: id,
          userId: userId,
          name: name,
          description: description,
          isShared: isShared,
          songCount: songCount,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory PlaylistWithSongs.fromJson(Map<String, dynamic> json) {
    final playlist = Playlist.fromJson(json);
    return PlaylistWithSongs(
      id: playlist.id,
      userId: playlist.userId,
      name: playlist.name,
      description: playlist.description,
      isShared: playlist.isShared,
      songCount: playlist.songCount,
      createdAt: playlist.createdAt,
      updatedAt: playlist.updatedAt,
      songs: (json['songs'] as List<dynamic>?)
          ?.map((s) => Music.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'songs': songs?.map((s) => s.toJson()).toList(),
      };
}
