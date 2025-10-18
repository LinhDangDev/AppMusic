// User search history model

class SearchHistory {
  final int id;
  final int userId;
  final String query;
  final int? resultCount;
  final DateTime searchedAt;

  SearchHistory({
    required this.id,
    required this.userId,
    required this.query,
    this.resultCount,
    required this.searchedAt,
  });

  factory SearchHistory.fromJson(Map<String, dynamic> json) {
    return SearchHistory(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      query: json['query'] as String,
      resultCount: json['result_count'] as int?,
      searchedAt: DateTime.parse(json['searched_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'query': query,
        'result_count': resultCount,
        'searched_at': searchedAt.toIso8601String(),
      };

  /// Check if search returned results
  bool get hasResults => resultCount != null && resultCount! > 0;
}
