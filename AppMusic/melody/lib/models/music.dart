class Music {
  final int id;
  final String title;
  final String artistName;
  final String? imageUrl;
  final String? youtubeThumbnail;

  String get displayImage => youtubeThumbnail ?? imageUrl ?? 'assets/playlist1.png';

  Music({
    required this.id,
    required this.title,
    required this.artistName,
    this.imageUrl,
    this.youtubeThumbnail,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      artistName: json['artist_name'] ?? 'Unknown Artist',
      imageUrl: json['image_url'],
      youtubeThumbnail: json['youtube_thumbnail'],
    );
  }
} 