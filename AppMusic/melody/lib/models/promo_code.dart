// Promo codes model (discount and promotional codes)

class PromoCode {
  final int id;
  final String code;
  final int? discountPercent;
  final double? discountAmount;
  final DateTime validFrom;
  final DateTime? validUntil;
  final int? maxUses;
  final int currentUses;
  final bool isActive;

  PromoCode({
    required this.id,
    required this.code,
    this.discountPercent,
    this.discountAmount,
    required this.validFrom,
    this.validUntil,
    this.maxUses,
    required this.currentUses,
    required this.isActive,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id'] as int,
      code: json['code'] as String,
      discountPercent: json['discount_percent'] as int?,
      discountAmount: (json['discount_amount'] as num?)?.toDouble(),
      validFrom: DateTime.parse(json['valid_from'] as String),
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'] as String)
          : null,
      maxUses: json['max_uses'] as int?,
      currentUses: json['current_uses'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'discount_percent': discountPercent,
        'discount_amount': discountAmount,
        'valid_from': validFrom.toIso8601String(),
        'valid_until': validUntil?.toIso8601String(),
        'max_uses': maxUses,
        'current_uses': currentUses,
        'is_active': isActive,
      };

  /// Check if promo code is currently valid
  bool get isValid {
    if (!isActive) return false;
    final now = DateTime.now();
    if (now.isBefore(validFrom)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    if (maxUses != null && currentUses >= maxUses!) return false;
    return true;
  }

  /// Check if promo code has expired
  bool get isExpired {
    if (validUntil == null) return false;
    return DateTime.now().isAfter(validUntil!);
  }

  /// Check if max uses reached
  bool get maxUsesReached => maxUses != null && currentUses >= maxUses!;

  /// Get remaining uses
  int? get remainingUses {
    if (maxUses == null) return null;
    final remaining = maxUses! - currentUses;
    return remaining > 0 ? remaining : 0;
  }

  /// Get discount type label
  String get discountLabel {
    if (discountPercent != null) {
      return '$discountPercent%';
    } else if (discountAmount != null) {
      return '\$$discountAmount';
    }
    return 'Unknown';
  }
}
