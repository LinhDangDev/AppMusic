import 'enums.dart';

// Music queue model (user's play queue)

class Queue {
  final int id;
  final int userId;
  final int musicId;
  final int position;
  final QueueType queueType;
  final int? sourceId;
  final DateTime createdAt;

  Queue({
    required this.id,
    required this.userId,
    required this.musicId,
    required this.position,
    required this.queueType,
    this.sourceId,
    required this.createdAt,
  });

  factory Queue.fromJson(Map<String, dynamic> json) {
    return Queue(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      musicId: json['music_id'] as int,
      position: json['position'] as int,
      queueType: QueueType.values
          .byName((json['queue_type'] as String? ?? 'manual').toLowerCase()),
      sourceId: json['source_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'music_id': musicId,
        'position': position,
        'queue_type': queueType.name.toUpperCase(),
        'source_id': sourceId,
        'created_at': createdAt.toIso8601String(),
      };
}
