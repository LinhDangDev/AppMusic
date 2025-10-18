// Music rankings model (from charts - Billboard, Spotify, iTunes, etc)

class Ranking {
  final int id;
  final String platform;
  final String? region;
  final int musicId;
  final int rankPosition;
  final int? position;
  final DateTime rankingDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Ranking({
    required this.id,
    required this.platform,
    this.region,
    required this.musicId,
    required this.rankPosition,
    this.position,
    required this.rankingDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ranking.fromJson(Map<String, dynamic> json) {
    return Ranking(
      id: json['id'] as int,
      platform: json['platform'] as String,
      region: json['region'] as String?,
      musicId: json['music_id'] as int,
      rankPosition: json['rank_position'] as int,
      position: json['position'] as int?,
      rankingDate: DateTime.parse(json['ranking_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'platform': platform,
        'region': region,
        'music_id': musicId,
        'rank_position': rankPosition,
        'position': position,
        'ranking_date': rankingDate.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
