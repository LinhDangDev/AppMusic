class Playlist {
  final int id;
  final int userId;
  final String name;
  final String description;
  final String createdAt;
  final String updatedAt;
  final int songCount;
  final String? imageUrl;

  Playlist({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.songCount,
    this.imageUrl,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      songCount: json['song_count'],
      imageUrl: json['image_url'],
    );
  }
} 