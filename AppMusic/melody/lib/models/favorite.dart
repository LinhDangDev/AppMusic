// User favorites model (junction table - user to music many-to-many)

class Favorite {
  final int userId;
  final int musicId;
  final DateTime createdAt;

  Favorite({
    required this.userId,
    required this.musicId,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      userId: json['user_id'] as int,
      musicId: json['music_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'music_id': musicId,
        'created_at': createdAt.toIso8601String(),
      };
}
