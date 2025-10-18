// Elasticsearch sync queue model (infrastructure - tracks sync operations)

class ElasticsearchSyncQueue {
  final int id;
  final String entityType;
  final int entityId;
  final String operation;
  final dynamic payload;
  final String status;
  final int retryCount;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? syncedAt;

  ElasticsearchSyncQueue({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    this.payload,
    required this.status,
    required this.retryCount,
    this.errorMessage,
    required this.createdAt,
    this.syncedAt,
  });

  factory ElasticsearchSyncQueue.fromJson(Map<String, dynamic> json) {
    return ElasticsearchSyncQueue(
      id: json['id'] as int,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as int,
      operation: json['operation'] as String,
      payload: json['payload'],
      status: json['status'] as String? ?? 'PENDING',
      retryCount: json['retry_count'] as int? ?? 0,
      errorMessage: json['error_message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'entity_type': entityType,
        'entity_id': entityId,
        'operation': operation,
        'payload': payload,
        'status': status,
        'retry_count': retryCount,
        'error_message': errorMessage,
        'created_at': createdAt.toIso8601String(),
        'synced_at': syncedAt?.toIso8601String(),
      };

  /// Check if sync is pending
  bool get isPending => status == 'PENDING';

  /// Check if sync has synced
  bool get isSynced => status == 'SYNCED';

  /// Check if sync failed
  bool get isFailed => status == 'FAILED';

  /// Check if should retry (max 3 retries)
  bool get shouldRetry => retryCount < 3 && status != 'SYNCED';

  /// Get operation label
  String get operationLabel => operation.toUpperCase();

  /// Get entity reference string
  String get entityReference => '$entityType#$entityId';
}
