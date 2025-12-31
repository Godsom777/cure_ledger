/// Hospital status for platform governance
enum HospitalStatus {
  pending, // Awaiting activation
  active, // Fully operational
  suspended, // Temporarily frozen
  flagged, // Under review
}

extension HospitalStatusExtension on HospitalStatus {
  String get displayName {
    switch (this) {
      case HospitalStatus.pending:
        return 'Pending Activation';
      case HospitalStatus.active:
        return 'Active';
      case HospitalStatus.suspended:
        return 'Suspended';
      case HospitalStatus.flagged:
        return 'Under Review';
    }
  }
}

/// Hospital model for CureLedger
class Hospital {
  final String id;
  final String name;
  final String code;
  final String address;
  final String? logoUrl;
  final bool isVerified;
  final HospitalStatus status;
  final String bankAccountNumber;
  final String bankName;
  final String paystackSubaccountCode;
  final DateTime createdAt;
  final String? suspensionReason;
  final DateTime? suspendedAt;
  final String? adminUserId;

  const Hospital({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    this.logoUrl,
    required this.isVerified,
    this.status = HospitalStatus.active,
    required this.bankAccountNumber,
    required this.bankName,
    required this.paystackSubaccountCode,
    required this.createdAt,
    this.suspensionReason,
    this.suspendedAt,
    this.adminUserId,
  });

  /// Whether hospital can receive payments
  bool get isOperational => status == HospitalStatus.active && isVerified;

  /// Bank narration prefix for settlements
  String get narrationPrefix => 'CURE-$code';

  /// Full narration format: CURE-[HOSPITALCODE]-[INVOICEID]
  String getNarration(String invoiceId) => '$narrationPrefix-$invoiceId';

  Hospital copyWith({
    String? id,
    String? name,
    String? code,
    String? address,
    String? logoUrl,
    bool? isVerified,
    HospitalStatus? status,
    String? bankAccountNumber,
    String? bankName,
    String? paystackSubaccountCode,
    DateTime? createdAt,
    String? suspensionReason,
    DateTime? suspendedAt,
    String? adminUserId,
  }) {
    return Hospital(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      address: address ?? this.address,
      logoUrl: logoUrl ?? this.logoUrl,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankName: bankName ?? this.bankName,
      paystackSubaccountCode:
          paystackSubaccountCode ?? this.paystackSubaccountCode,
      createdAt: createdAt ?? this.createdAt,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      suspendedAt: suspendedAt ?? this.suspendedAt,
      adminUserId: adminUserId ?? this.adminUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'address': address,
      'logoUrl': logoUrl,
      'isVerified': isVerified,
      'status': status.name,
      'bankAccountNumber': bankAccountNumber,
      'bankName': bankName,
      'paystackSubaccountCode': paystackSubaccountCode,
      'createdAt': createdAt.toIso8601String(),
      'suspensionReason': suspensionReason,
      'suspendedAt': suspendedAt?.toIso8601String(),
      'adminUserId': adminUserId,
    };
  }

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      address: json['address'] as String,
      logoUrl: json['logoUrl'] as String?,
      isVerified: json['isVerified'] as bool,
      status: HospitalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => HospitalStatus.pending,
      ),
      bankAccountNumber: json['bankAccountNumber'] as String,
      bankName: json['bankName'] as String,
      paystackSubaccountCode: json['paystackSubaccountCode'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      suspensionReason: json['suspensionReason'] as String?,
      suspendedAt: json['suspendedAt'] != null
          ? DateTime.parse(json['suspendedAt'] as String)
          : null,
      adminUserId: json['adminUserId'] as String?,
    );
  }
}
