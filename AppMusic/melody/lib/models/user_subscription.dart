import 'enums.dart';

// User subscriptions model (tracks user's active subscriptions)

class UserSubscription {
  final int id;
  final int userId;
  final int planId;
  final DateTime startDate;
  final DateTime endDate;
  final bool autoRenewal;
  final SubscriptionStatus status;

  UserSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.autoRenewal,
    required this.status,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      planId: json['plan_id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      autoRenewal: json['auto_renewal'] as bool? ?? false,
      status: SubscriptionStatus.values
          .byName((json['status'] as String).toLowerCase()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'plan_id': planId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'auto_renewal': autoRenewal,
        'status': status.name.toUpperCase(),
      };

  /// Check if subscription is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        status == SubscriptionStatus.active;
  }

  /// Check if subscription has expired
  bool get isExpired => DateTime.now().isAfter(endDate);

  /// Get days remaining
  int get daysRemaining {
    final remaining = endDate.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Check if subscription expires soon (within 7 days)
  bool get expiresSoon => daysRemaining <= 7 && daysRemaining > 0;

  /// Get renewal info
  String get renewalInfo {
    if (!autoRenewal) return 'No auto-renewal';
    return 'Auto-renews in ${daysRemaining} days';
  }
}
