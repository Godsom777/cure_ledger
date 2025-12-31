/// Payment model for CureLedger
/// Represents a payment transaction in the double-entry ledger
enum PaymentStatus { pending, successful, failed }

enum PaymentMethod { card, bankTransfer, ussd }

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.ussd:
        return 'USSD';
    }
  }
}

class Payment {
  final String id;
  final String invoiceId;
  final double amount;
  final PaymentStatus status;
  final PaymentMethod method;
  final String? paystackReference;
  final String? donorEmail;
  final String bankNarration;
  final DateTime createdAt;
  final DateTime? settledAt;

  const Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.status,
    required this.method,
    this.paystackReference,
    this.donorEmail,
    required this.bankNarration,
    required this.createdAt,
    this.settledAt,
  });

  /// Platform fee (5%)
  double get platformFee => amount * 0.05;

  /// Hospital settlement amount (95%)
  double get hospitalSettlement => amount * 0.95;

  /// Whether payment is settled
  bool get isSettled => settledAt != null;

  Payment copyWith({
    String? id,
    String? invoiceId,
    double? amount,
    PaymentStatus? status,
    PaymentMethod? method,
    String? paystackReference,
    String? donorEmail,
    String? bankNarration,
    DateTime? createdAt,
    DateTime? settledAt,
  }) {
    return Payment(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      method: method ?? this.method,
      paystackReference: paystackReference ?? this.paystackReference,
      donorEmail: donorEmail ?? this.donorEmail,
      bankNarration: bankNarration ?? this.bankNarration,
      createdAt: createdAt ?? this.createdAt,
      settledAt: settledAt ?? this.settledAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'amount': amount,
      'status': status.name,
      'method': method.name,
      'paystackReference': paystackReference,
      'donorEmail': donorEmail,
      'bankNarration': bankNarration,
      'createdAt': createdAt.toIso8601String(),
      'settledAt': settledAt?.toIso8601String(),
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      invoiceId: json['invoiceId'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => PaymentMethod.card,
      ),
      paystackReference: json['paystackReference'] as String?,
      donorEmail: json['donorEmail'] as String?,
      bankNarration: json['bankNarration'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      settledAt: json['settledAt'] != null
          ? DateTime.parse(json['settledAt'] as String)
          : null,
    );
  }
}
