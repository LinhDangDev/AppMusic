import 'enums.dart';

// Music updates tracking model (logs changes to music metadata)

class MusicUpdate {
  final int id;
  final int musicId;
  final UpdateType updateType;
  final dynamic oldValue;
  final dynamic newValue;
  final DateTime updatedAt;

  MusicUpdate({
    required this.id,
    required this.musicId,
    required this.updateType,
    this.oldValue,
    this.newValue,
    required this.updatedAt,
  });

  factory MusicUpdate.fromJson(Map<String, dynamic> json) {
    return MusicUpdate(
      id: json['id'] as int,
      musicId: json['music_id'] as int,
      updateType: UpdateType.values
          .byName((json['update_type'] as String).toLowerCase()),
      oldValue: json['old_value'],
      newValue: json['new_value'],
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'music_id': musicId,
        'update_type': updateType.name.toUpperCase(),
        'old_value': oldValue,
        'new_value': newValue,
        'updated_at': updatedAt.toIso8601String(),
      };

  /// Get update type as readable string
  String get updateTypeLabel {
    switch (updateType) {
      case UpdateType.playCount:
        return 'Play Count Update';
      case UpdateType.popularity:
        return 'Popularity Update';
      case UpdateType.metadata:
        return 'Metadata Update';
    }
  }
}
