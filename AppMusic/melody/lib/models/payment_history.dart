import 'enums.dart';

// Payment history model (tracks all payments)

class PaymentHistory {
  final int id;
  final int userId;
  final int subscriptionId;
  final double amount;
  final String? paymentMethod;
  final String? transactionId;
  final PaymentStatus status;
  final DateTime paymentDate;

  PaymentHistory({
    required this.id,
    required this.userId,
    required this.subscriptionId,
    required this.amount,
    this.paymentMethod,
    this.transactionId,
    required this.status,
    required this.paymentDate,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      subscriptionId: json['subscription_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String?,
      transactionId: json['transaction_id'] as String?,
      status:
          PaymentStatus.values.byName((json['status'] as String).toLowerCase()),
      paymentDate: DateTime.parse(json['payment_date'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'subscription_id': subscriptionId,
        'amount': amount,
        'payment_method': paymentMethod,
        'transaction_id': transactionId,
        'status': status.name.toUpperCase(),
        'payment_date': paymentDate.toIso8601String(),
      };

  /// Check if payment was successful
  bool get isSuccessful => status == PaymentStatus.success;

  /// Check if payment failed
  bool get isFailed => status == PaymentStatus.failed;

  /// Check if payment is pending
  bool get isPending => status == PaymentStatus.pending;

  /// Check if payment was refunded
  bool get isRefunded => status == PaymentStatus.refunded;

  /// Get status label
  String get statusLabel {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.success:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
}
