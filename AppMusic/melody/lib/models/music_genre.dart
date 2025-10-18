// Music-Genre junction table model (many-to-many relationship)

class MusicGenre {
  final int musicId;
  final int genreId;

  MusicGenre({
    required this.musicId,
    required this.genreId,
  });

  factory MusicGenre.fromJson(Map<String, dynamic> json) {
    return MusicGenre(
      musicId: json['music_id'] as int,
      genreId: json['genre_id'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'music_id': musicId,
        'genre_id': genreId,
      };
}
