/// User roles in CureLedger system
enum UserRole {
  donor,
  hospitalAdmin,
  socialWorker,
  hospitalFinance,
  platformSuperAdmin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.donor:
        return 'Donor';
      case UserRole.hospitalAdmin:
        return 'Hospital Admin';
      case UserRole.socialWorker:
        return 'Social Worker';
      case UserRole.hospitalFinance:
        return 'Hospital Finance';
      case UserRole.platformSuperAdmin:
        return 'Platform Admin';
    }
  }

  List<String> get permissions {
    switch (this) {
      case UserRole.donor:
        return ['view_invoice', 'make_payment', 'receive_receipt'];
      case UserRole.hospitalAdmin:
        return [
          'verify_invoice',
          'issue_role_codes',
          'generate_campaign_link',
          'view_dashboard',
        ];
      case UserRole.socialWorker:
        return ['upload_invoice'];
      case UserRole.hospitalFinance:
        return ['view_dashboard', 'export_reports'];
      case UserRole.platformSuperAdmin:
        return [
          // Hospital Management
          'create_hospital_account',
          'activate_hospital',
          'suspend_hospital',
          'view_hospital_profile',
          'edit_hospital_metadata',
          // Access Control
          'assign_hospital_admin',
          'revoke_hospital_admin',
          'reset_hospital_admin_access',
          // Financial Configuration
          'configure_platform_fee_percentage',
          'configure_payment_gateway_settings',
          'view_system_wide_settlement_totals',
          // Audit and Compliance
          'view_read_only_audit_logs',
          'view_system_activity_logs',
          'export_audit_reports',
          // Exception Handling
          'flag_suspicious_hospitals',
          'freeze_hospital_on_fraud_signal',
          'escalate_disputes_for_manual_review',
        ];
    }
  }

  /// Explicit restrictions for Super Admin (documented for clarity)
  List<String> get restrictions {
    if (this == UserRole.platformSuperAdmin) {
      return [
        'cannot_create_invoices',
        'cannot_edit_or_delete_invoices',
        'cannot_upload_medical_documents',
        'cannot_initiate_or_reverse_payments',
        'cannot_access_patient_personal_data',
        'cannot_modify_hospital_ledgers',
      ];
    }
    return [];
  }
}

/// User model for CureLedger
class User {
  final String id;
  final String? email;
  final UserRole role;
  final String? hospitalId;
  final String? name;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    this.email,
    required this.role,
    this.hospitalId,
    this.name,
    required this.isActive,
    required this.createdAt,
    this.lastLoginAt,
  });

  /// Check if user has a specific permission
  bool hasPermission(String permission) {
    return role.permissions.contains(permission);
  }

  /// Check if user is hospital staff
  bool get isHospitalStaff =>
      role == UserRole.hospitalAdmin ||
      role == UserRole.socialWorker ||
      role == UserRole.hospitalFinance;

  User copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? hospitalId,
    String? name,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      hospitalId: hospitalId ?? this.hospitalId,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.name,
      'hospitalId': hospitalId,
      'name': name,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.donor,
      ),
      hospitalId: json['hospitalId'] as String?,
      name: json['name'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }
}
