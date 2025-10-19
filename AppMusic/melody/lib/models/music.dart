import 'enums.dart';
import 'genre.dart';

/// Core Music Model
/// Represents a music track with all necessary metadata
class Music {
  final int? id;
  final String title;
  final int? artistId;
  final String? artistName;
  final String? album;
  final int? duration; // Duration in seconds
  final DateTime? releaseDate;
  final String? youtubeThumbnail;
  final String? youtubeId;
  final String? youtubeUrl;
  final String? imageUrl;
  final String? previewUrl;
  final MusicSource? source;
  final String? sourceId;
  final int playCount;
  final String? lyrics;
  final String? geniusId;
  final LyricsState lyricsState;
  final bool isLiked;
  final int? position; // Chart position
  final String? genre;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Music({
    this.id,
    required this.title,
    this.artistId,
    this.artistName,
    this.album,
    this.duration,
    this.releaseDate,
    this.youtubeThumbnail,
    this.youtubeId,
    this.youtubeUrl,
    this.imageUrl,
    this.previewUrl,
    this.source,
    this.sourceId,
    this.playCount = 0,
    this.lyrics,
    this.geniusId,
    this.lyricsState = LyricsState.pending,
    this.isLiked = false,
    this.position,
    this.genre,
    this.createdAt,
    this.updatedAt,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id'] as int?,
      title: json['title'] as String? ?? 'Unknown',
      artistId: json['artist_id'] as int?,
      artistName: json['artist_name'] as String?,
      album: json['album'] as String?,
      duration: json['duration'] as int?,
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'] as String)
          : null,
      youtubeThumbnail: json['youtube_thumbnail'] as String?,
      youtubeId: json['youtube_id'] as String?,
      youtubeUrl: json['youtube_url'] as String?,
      imageUrl: json['image_url'] as String?,
      previewUrl: json['preview_url'] as String?,
      source: json['source'] != null
          ? MusicSource.values.byName(json['source'] as String)
          : null,
      sourceId: json['source_id'] as String?,
      playCount: json['play_count'] as int? ?? 0,
      lyrics: json['lyrics'] as String?,
      geniusId: json['genius_id'] as String?,
      lyricsState: json['lyrics_state'] != null
          ? LyricsState.values
              .byName((json['lyrics_state'] as String).toLowerCase())
          : LyricsState.pending,
      isLiked: json['is_liked'] as bool? ?? false,
      position: json['position'] as int?,
      genre: json['genre'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist_id': artistId,
        'artist_name': artistName,
        'album': album,
        'duration': duration,
        'release_date': releaseDate?.toIso8601String(),
        'youtube_thumbnail': youtubeThumbnail,
        'youtube_id': youtubeId,
        'youtube_url': youtubeUrl,
        'image_url': imageUrl,
        'preview_url': previewUrl,
        'source': source?.name,
        'source_id': sourceId,
        'play_count': playCount,
        'lyrics': lyrics,
        'genius_id': geniusId,
        'lyrics_state': lyricsState.name.toUpperCase(),
        'is_liked': isLiked,
        'position': position,
        'genre': genre,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  // ============================================================================
  // COMPUTED PROPERTIES FOR UI
  // ============================================================================

  /// Get thumbnail URL - prefers high quality image
  String? get imageSource => imageUrl ?? youtubeThumbnail;

  /// Format duration as MM:SS
  String get formattedDuration {
    if (duration == null) return '00:00';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Display name (title - artist)
  String get displayName =>
      '${title}${artistName != null ? ' - $artistName' : ''}';

  /// Short display name (just title if short, else truncate)
  String get shortDisplayName {
    if (title.length > 30) {
      return '${title.substring(0, 27)}...';
    }
    return title;
  }

  /// Artist display (fallback to 'Unknown Artist')
  String get displayArtist => artistName ?? 'Unknown Artist';

  /// Check if music has valid streaming source
  bool get isPlayable =>
      (youtubeId?.isNotEmpty ?? false) || (youtubeUrl?.isNotEmpty ?? false);

  /// Check if music has metadata
  bool get hasMetadata =>
      (imageUrl?.isNotEmpty ?? false) ||
      (youtubeThumbnail?.isNotEmpty ?? false) ||
      (album?.isNotEmpty ?? false);

  /// Create a copy with modified fields
  Music copyWith({
    int? id,
    String? title,
    int? artistId,
    String? artistName,
    String? album,
    int? duration,
    DateTime? releaseDate,
    String? youtubeThumbnail,
    String? youtubeId,
    String? youtubeUrl,
    String? imageUrl,
    String? previewUrl,
    MusicSource? source,
    String? sourceId,
    int? playCount,
    String? lyrics,
    String? geniusId,
    LyricsState? lyricsState,
    bool? isLiked,
    int? position,
    String? genre,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Music(
      id: id ?? this.id,
      title: title ?? this.title,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      releaseDate: releaseDate ?? this.releaseDate,
      youtubeThumbnail: youtubeThumbnail ?? this.youtubeThumbnail,
      youtubeId: youtubeId ?? this.youtubeId,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      previewUrl: previewUrl ?? this.previewUrl,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      playCount: playCount ?? this.playCount,
      lyrics: lyrics ?? this.lyrics,
      geniusId: geniusId ?? this.geniusId,
      lyricsState: lyricsState ?? this.lyricsState,
      isLiked: isLiked ?? this.isLiked,
      position: position ?? this.position,
      genre: genre ?? this.genre,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Music &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          youtubeId == other.youtubeId;

  @override
  int get hashCode => id.hashCode ^ youtubeId.hashCode;
}

/// Extended Music model with additional data from API
class MusicWithDetails extends Music {
  final List<Genre>? genres;
  final int? favoriteCount;
  final bool? isFavorited;

  MusicWithDetails({
    int? id,
    required String title,
    int? artistId,
    String? artistName,
    String? album,
    int? duration,
    DateTime? releaseDate,
    String? youtubeThumbnail,
    String? youtubeId,
    String? youtubeUrl,
    String? imageUrl,
    String? previewUrl,
    MusicSource? source,
    String? sourceId,
    int playCount = 0,
    String? lyrics,
    String? geniusId,
    LyricsState lyricsState = LyricsState.pending,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.genres,
    this.favoriteCount,
    this.isFavorited,
  }) : super(
          id: id,
          title: title,
          artistId: artistId,
          artistName: artistName,
          album: album,
          duration: duration,
          releaseDate: releaseDate,
          youtubeThumbnail: youtubeThumbnail,
          youtubeId: youtubeId,
          youtubeUrl: youtubeUrl,
          imageUrl: imageUrl,
          previewUrl: previewUrl,
          source: source,
          sourceId: sourceId,
          playCount: playCount,
          lyrics: lyrics,
          geniusId: geniusId,
          lyricsState: lyricsState,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory MusicWithDetails.fromJson(Map<String, dynamic> json) {
    final music = Music.fromJson(json);
    return MusicWithDetails(
      id: music.id,
      title: music.title,
      artistId: music.artistId,
      artistName: music.artistName,
      album: music.album,
      duration: music.duration,
      releaseDate: music.releaseDate,
      youtubeThumbnail: music.youtubeThumbnail,
      youtubeId: music.youtubeId,
      youtubeUrl: music.youtubeUrl,
      imageUrl: music.imageUrl,
      previewUrl: music.previewUrl,
      source: music.source,
      sourceId: music.sourceId,
      playCount: music.playCount,
      lyrics: music.lyrics,
      geniusId: music.geniusId,
      lyricsState: music.lyricsState,
      createdAt: music.createdAt,
      updatedAt: music.updatedAt,
      genres: (json['genres'] as List<dynamic>?)
          ?.map((g) => Genre.fromJson(g as Map<String, dynamic>))
          .toList(),
      favoriteCount: json['favorite_count'] as int?,
      isFavorited: json['is_favorited'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'genres': genres?.map((g) => g.toJson()).toList(),
        'favorite_count': favoriteCount,
        'is_favorited': isFavorited,
      };
}
