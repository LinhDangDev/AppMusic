class SearchResult {
  final String id;
  final String title;
  final String artistName;
  final String displayImage;
  final String youtubeId;

  SearchResult({
    required this.id,
    required this.title,
    required this.artistName,
    required this.displayImage,
    required this.youtubeId,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'],
      title: json['title'],
      artistName: json['artist_name'],
      displayImage: json['image_url'],
      youtubeId: json['id'].toString().replaceAll('yt_', ''),
    );
  }
} 