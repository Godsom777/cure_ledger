/// System-wide settlement totals for Super Admin dashboard
/// This provides a read-only aggregate view of all platform activity
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

  /// Calculate total pending settlements
  double get pendingSettlements =>
      totalPaymentsReceived - totalPlatformFees - totalHospitalSettlements;

  /// Format totals for display
  Map<String, dynamic> toDisplayMap() {
    return {
      'totalPaymentsReceived': totalPaymentsReceived,
      'totalPlatformFees': totalPlatformFees,
      'totalHospitalSettlements': totalHospitalSettlements,
      'totalTransactions': totalTransactions,
      'totalHospitals': totalHospitals,
      'totalInvoices': totalInvoices,
      'asOf': asOf.toIso8601String(),
    };
  }
}
