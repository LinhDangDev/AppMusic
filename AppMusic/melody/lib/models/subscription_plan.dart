// Subscription plans model (different subscription packages)

class SubscriptionPlan {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int durationDays;
  final dynamic features;
  final bool isActive;
  final DateTime createdAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.durationDays,
    this.features,
    required this.isActive,
    required this.createdAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      durationDays: json['duration_days'] as int,
      features: json['features'],
      isActive: json['is_active'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'duration_days': durationDays,
        'features': features,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };

  /// Get price per day
  double get pricePerDay => price / durationDays;

  /// Check if plan is available
  bool get isAvailable => isActive;

  /// Get monthly equivalent price (assuming 30 days)
  double get monthlyEquivalent => pricePerDay * 30;
}
