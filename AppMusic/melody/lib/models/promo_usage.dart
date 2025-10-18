// Promo usage model (tracks when promos are used for subscriptions)

class PromoUsage {
  final int id;
  final int promoId;
  final int userId;
  final int subscriptionId;
  final DateTime usedAt;

  PromoUsage({
    required this.id,
    required this.promoId,
    required this.userId,
    required this.subscriptionId,
    required this.usedAt,
  });

  factory PromoUsage.fromJson(Map<String, dynamic> json) {
    return PromoUsage(
      id: json['id'] as int,
      promoId: json['promo_id'] as int,
      userId: json['user_id'] as int,
      subscriptionId: json['subscription_id'] as int,
      usedAt: DateTime.parse(json['used_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'promo_id': promoId,
        'user_id': userId,
        'subscription_id': subscriptionId,
        'used_at': usedAt.toIso8601String(),
      };
}
