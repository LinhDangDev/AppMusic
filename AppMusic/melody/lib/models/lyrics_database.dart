// Lyrics database model (stores lyrics from external sources)

class LyricsDatabase {
  final int id;
  final String title;
  final String artist;
  final String? lyrics;
  final String? source;
  final DateTime createdAt;

  LyricsDatabase({
    required this.id,
    required this.title,
    required this.artist,
    this.lyrics,
    this.source,
    required this.createdAt,
  });

  factory LyricsDatabase.fromJson(Map<String, dynamic> json) {
    return LyricsDatabase(
      id: json['id'] as int,
      title: json['title'] as String,
      artist: json['artist'] as String,
      lyrics: json['lyrics'] as String?,
      source: json['source'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'lyrics': lyrics,
        'source': source,
        'created_at': createdAt.toIso8601String(),
      };

  /// Check if lyrics are available
  bool get hasLyrics => lyrics != null && lyrics!.isNotEmpty;

  /// Get lyrics line count
  int get lineCount => hasLyrics ? lyrics!.split('\n').length : 0;
}
