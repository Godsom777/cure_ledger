import 'enums.dart';
import 'hospital.dart';

/// Invoice model for CureLedger
/// Represents a medical invoice in the double-entry ledger system
class Invoice {
  final String id;
  final String hospitalId;
  final Hospital? hospital;
  final String hospitalFileId;
  final TreatmentCategory category;
  final double amountTotal;
  final double amountPaid;
  final InvoiceStatus status;
  final DateTime issueDate;
  final DateTime? verifiedAt;
  final String? verifiedByDoctorId;
  final String? verifiedByDoctorName;
  final bool patientPrivacyEnabled;
  final String? patientInitials;
  final String uploadedById;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Invoice({
    required this.id,
    required this.hospitalId,
    this.hospital,
    required this.hospitalFileId,
    required this.category,
    required this.amountTotal,
    required this.amountPaid,
    required this.status,
    required this.issueDate,
    this.verifiedAt,
    this.verifiedByDoctorId,
    this.verifiedByDoctorName,
    required this.patientPrivacyEnabled,
    this.patientInitials,
    required this.uploadedById,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Balance remaining to be paid
  double get balanceRemaining => amountTotal - amountPaid;

  /// Progress percentage (0.0 to 1.0)
  double get progressPercentage =>
      amountTotal > 0 ? (amountPaid / amountTotal).clamp(0.0, 1.0) : 0.0;

  /// Progress percentage as integer (0 to 100)
  int get progressPercentageInt => (progressPercentage * 100).round();

  /// Whether the invoice is fully paid
  bool get isFullyPaid => balanceRemaining <= 0;

  /// Whether the invoice is verified
  bool get isVerified =>
      status != InvoiceStatus.pending && status != InvoiceStatus.rejected;

  /// Bank narration for this invoice
  String get bankNarration => hospital?.getNarration(id) ?? 'CURE-$id';

  Invoice copyWith({
    String? id,
    String? hospitalId,
    Hospital? hospital,
    String? hospitalFileId,
    TreatmentCategory? category,
    double? amountTotal,
    double? amountPaid,
    InvoiceStatus? status,
    DateTime? issueDate,
    DateTime? verifiedAt,
    String? verifiedByDoctorId,
    String? verifiedByDoctorName,
    bool? patientPrivacyEnabled,
    String? patientInitials,
    String? uploadedById,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      hospitalId: hospitalId ?? this.hospitalId,
      hospital: hospital ?? this.hospital,
      hospitalFileId: hospitalFileId ?? this.hospitalFileId,
      category: category ?? this.category,
      amountTotal: amountTotal ?? this.amountTotal,
      amountPaid: amountPaid ?? this.amountPaid,
      status: status ?? this.status,
      issueDate: issueDate ?? this.issueDate,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedByDoctorId: verifiedByDoctorId ?? this.verifiedByDoctorId,
      verifiedByDoctorName: verifiedByDoctorName ?? this.verifiedByDoctorName,
      patientPrivacyEnabled:
          patientPrivacyEnabled ?? this.patientPrivacyEnabled,
      patientInitials: patientInitials ?? this.patientInitials,
      uploadedById: uploadedById ?? this.uploadedById,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hospitalId': hospitalId,
      'hospitalFileId': hospitalFileId,
      'category': category.name,
      'amountTotal': amountTotal,
      'amountPaid': amountPaid,
      'status': status.name,
      'issueDate': issueDate.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'verifiedByDoctorId': verifiedByDoctorId,
      'verifiedByDoctorName': verifiedByDoctorName,
      'patientPrivacyEnabled': patientPrivacyEnabled,
      'patientInitials': patientInitials,
      'uploadedById': uploadedById,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String,
      hospitalId: json['hospitalId'] as String,
      hospitalFileId: json['hospitalFileId'] as String,
      category: TreatmentCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TreatmentCategory.other,
      ),
      amountTotal: (json['amountTotal'] as num).toDouble(),
      amountPaid: (json['amountPaid'] as num).toDouble(),
      status: InvoiceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InvoiceStatus.pending,
      ),
      issueDate: DateTime.parse(json['issueDate'] as String),
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
      verifiedByDoctorId: json['verifiedByDoctorId'] as String?,
      verifiedByDoctorName: json['verifiedByDoctorName'] as String?,
      patientPrivacyEnabled: json['patientPrivacyEnabled'] as bool,
      patientInitials: json['patientInitials'] as String?,
      uploadedById: json['uploadedById'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
