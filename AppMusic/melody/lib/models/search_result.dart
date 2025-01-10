class SearchResult {
  final String id;
  final String title;
  final String artistName;
  final String? imageUrl;
  final String? youtubeThumbnail;

  String get displayImage => youtubeThumbnail ?? imageUrl ?? 'assets/default_music.png';

  SearchResult({
    required this.id,
    required this.title,
    required this.artistName,
    this.imageUrl,
    this.youtubeThumbnail,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'].toString(),
      title: json['title'] as String,
      artistName: json['artist_name'] as String,
      imageUrl: json['image_url'] as String?,
      youtubeThumbnail: json['youtube_thumbnail'] as String?,
    );
  }
} 