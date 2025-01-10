class Music {
  final String id;
  final String title;
  final String artistName;
  final String displayImage;
  final String youtubeId;
  final String youtubeThumbnail;

  Music({
    required this.id,
    required this.title,
    required this.artistName,
    required this.displayImage,
    required this.youtubeId,
    required this.youtubeThumbnail,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      artistName: json['artist_name'] ?? '',
      displayImage: json['image_url'] ?? '',
      youtubeId: json['youtube_url']?.toString().replaceAll('https://www.youtube.com/watch?v=', '') ?? '',
      youtubeThumbnail: json['youtube_thumbnail'] ?? '',
    );
  }
} 