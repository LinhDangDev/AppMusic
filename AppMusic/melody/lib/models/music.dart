class Music {
  final String id;
  final String title;
  final String artistName;
  final String youtubeId;
  final String youtubeThumbnail;
  final String? playCount;
  final int? position;
  final String? duration;
  final String? genre;
  final bool isLiked;

  Music({
    required this.id,
    required this.title,
    required this.artistName,
    required this.youtubeId,
    required this.youtubeThumbnail,
    this.playCount,
    this.position,
    this.duration,
    this.genre,
    this.isLiked = false,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    String youtubeId = '';
    String thumbnail = '';
    
    // Xử lý YouTube URL để lấy ID
    final youtubeUrl = json['youtube_url'] ?? '';
    if (youtubeUrl.isNotEmpty) {
      Uri uri = Uri.parse(youtubeUrl);
      if (uri.host.contains('youtube.com')) {
        youtubeId = uri.queryParameters['v'] ?? '';
      } else if (uri.host.contains('youtu.be')) {
        youtubeId = uri.pathSegments.last;
      }
    }

    // Xử lý thumbnail
    thumbnail = json['youtube_thumbnail'] ?? '';
    if (thumbnail.isEmpty && youtubeId.isNotEmpty) {
      thumbnail = 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';
    }

    return Music(
      id: json['id'].toString(),
      title: json['title'] ?? 'Unknown',
      artistName: json['artist_name'] ?? 'Unknown Artist',
      youtubeId: youtubeId,
      youtubeThumbnail: thumbnail,
      playCount: json['play_count']?.toString(),
      duration: json['duration']?.toString(),
      genre: (json['genres'] as List?)?.join(', '),
      isLiked: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist_name': artistName,
      'youtube_url': youtubeId,
      'youtube_thumbnail': youtubeThumbnail,
      'play_count': playCount,
      'position': position,
      'duration': duration,
      'genre': genre,
      'is_liked': isLiked,
    };
  }
}
