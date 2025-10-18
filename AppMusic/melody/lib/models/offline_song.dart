// Offline songs model (tracks downloaded music for offline playback)

class OfflineSong {
  final int userId;
  final int musicId;
  final DateTime downloadedAt;
  final DateTime? expirationDate;

  OfflineSong({
    required this.userId,
    required this.musicId,
    required this.downloadedAt,
    this.expirationDate,
  });

  factory OfflineSong.fromJson(Map<String, dynamic> json) {
    return OfflineSong(
      userId: json['user_id'] as int,
      musicId: json['music_id'] as int,
      downloadedAt: DateTime.parse(json['downloaded_at'] as String),
      expirationDate: json['expiration_date'] != null
          ? DateTime.parse(json['expiration_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'music_id': musicId,
        'downloaded_at': downloadedAt.toIso8601String(),
        'expiration_date': expirationDate?.toIso8601String(),
      };

  /// Check if offline song has expired
  bool get isExpired {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  /// Check if offline song is still valid
  bool get isValid => !isExpired;

  /// Get days until expiration
  int? get daysUntilExpiration {
    if (expirationDate == null) return null;
    return expirationDate!.difference(DateTime.now()).inDays;
  }
}
