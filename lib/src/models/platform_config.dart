/// Platform configuration managed by Super Admin
class PlatformConfig {
  final String id;
  final double platformFeePercentage; // Default: 5%
  final double hospitalSettlementPercentage; // Default: 95%
  final String paystackPublicKey;
  final String paystackSecretKeyHint; // Only show last 4 chars
  final bool paystackTestMode;
  final DateTime lastUpdated;
  final String lastUpdatedBy;

  const PlatformConfig({
    required this.id,
    this.platformFeePercentage = 5.0,
    this.hospitalSettlementPercentage = 95.0,
    required this.paystackPublicKey,
    required this.paystackSecretKeyHint,
    this.paystackTestMode = true,
    required this.lastUpdated,
    required this.lastUpdatedBy,
  });

  /// Validate fee percentages sum to 100
  bool get isValidFeeConfig =>
      (platformFeePercentage + hospitalSettlementPercentage) == 100.0;

  PlatformConfig copyWith({
    String? id,
    double? platformFeePercentage,
    double? hospitalSettlementPercentage,
    String? paystackPublicKey,
    String? paystackSecretKeyHint,
    bool? paystackTestMode,
    DateTime? lastUpdated,
    String? lastUpdatedBy,
  }) {
    return PlatformConfig(
      id: id ?? this.id,
      platformFeePercentage:
          platformFeePercentage ?? this.platformFeePercentage,
      hospitalSettlementPercentage:
          hospitalSettlementPercentage ?? this.hospitalSettlementPercentage,
      paystackPublicKey: paystackPublicKey ?? this.paystackPublicKey,
      paystackSecretKeyHint:
          paystackSecretKeyHint ?? this.paystackSecretKeyHint,
      paystackTestMode: paystackTestMode ?? this.paystackTestMode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platformFeePercentage': platformFeePercentage,
      'hospitalSettlementPercentage': hospitalSettlementPercentage,
      'paystackPublicKey': paystackPublicKey,
      'paystackSecretKeyHint': paystackSecretKeyHint,
      'paystackTestMode': paystackTestMode,
      'lastUpdated': lastUpdated.toIso8601String(),
      'lastUpdatedBy': lastUpdatedBy,
    };
  }

  factory PlatformConfig.fromJson(Map<String, dynamic> json) {
    return PlatformConfig(
      id: json['id'] as String,
      platformFeePercentage: (json['platformFeePercentage'] as num).toDouble(),
      hospitalSettlementPercentage:
          (json['hospitalSettlementPercentage'] as num).toDouble(),
      paystackPublicKey: json['paystackPublicKey'] as String,
      paystackSecretKeyHint: json['paystackSecretKeyHint'] as String,
      paystackTestMode: json['paystackTestMode'] as bool,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      lastUpdatedBy: json['lastUpdatedBy'] as String,
    );
  }
}

/// System-wide settlement totals (read-only for Super Admin)
class SystemSettlementTotals {
  final double totalPaymentsReceived;
  final double totalPlatformFees;
  final double totalHospitalSettlements;
  final int totalTransactions;
  final int totalHospitals;
  final int totalInvoices;
  final DateTime asOf;

  const SystemSettlementTotals({
    required this.totalPaymentsReceived,
    required this.totalPlatformFees,
    required this.totalHospitalSettlements,
    required this.totalTransactions,
    required this.totalHospitals,
    required this.totalInvoices,
    required this.asOf,
  });

  factory SystemSettlementTotals.fromJson(Map<String, dynamic> json) {
    return SystemSettlementTotals(
      totalPaymentsReceived: (json['totalPaymentsReceived'] as num).toDouble(),
      totalPlatformFees: (json['totalPlatformFees'] as num).toDouble(),
      totalHospitalSettlements: (json['totalHospitalSettlements'] as num)
          .toDouble(),
      totalTransactions: json['totalTransactions'] as int,
      totalHospitals: json['totalHospitals'] as int,
      totalInvoices: json['totalInvoices'] as int,
      asOf: DateTime.parse(json['asOf'] as String),
    );
  }
}
