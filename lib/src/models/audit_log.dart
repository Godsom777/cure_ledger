/// Audit log entry for platform-level tracking
/// Super Admin has read-only access to these logs
enum AuditAction {
  hospitalCreated,
  hospitalActivated,
  hospitalSuspended,
  hospitalUnsuspended,
  hospitalFlagged,
  adminAssigned,
  adminRevoked,
  adminAccessReset,
  platformFeeChanged,
  paymentGatewayConfigured,
  invoiceCreated,
  invoiceVerified,
  invoiceRejected,
  paymentReceived,
  paymentSettled,
  disputeEscalated,
}

extension AuditActionExtension on AuditAction {
  String get displayName {
    switch (this) {
      case AuditAction.hospitalCreated:
        return 'Hospital Created';
      case AuditAction.hospitalActivated:
        return 'Hospital Activated';
      case AuditAction.hospitalSuspended:
        return 'Hospital Suspended';
      case AuditAction.hospitalUnsuspended:
        return 'Hospital Unsuspended';
      case AuditAction.hospitalFlagged:
        return 'Hospital Flagged';
      case AuditAction.adminAssigned:
        return 'Admin Assigned';
      case AuditAction.adminRevoked:
        return 'Admin Revoked';
      case AuditAction.adminAccessReset:
        return 'Admin Access Reset';
      case AuditAction.platformFeeChanged:
        return 'Platform Fee Changed';
      case AuditAction.paymentGatewayConfigured:
        return 'Payment Gateway Configured';
      case AuditAction.invoiceCreated:
        return 'Invoice Created';
      case AuditAction.invoiceVerified:
        return 'Invoice Verified';
      case AuditAction.invoiceRejected:
        return 'Invoice Rejected';
      case AuditAction.paymentReceived:
        return 'Payment Received';
      case AuditAction.paymentSettled:
        return 'Payment Settled';
      case AuditAction.disputeEscalated:
        return 'Dispute Escalated';
    }
  }

  /// Category for filtering
  String get category {
    switch (this) {
      case AuditAction.hospitalCreated:
      case AuditAction.hospitalActivated:
      case AuditAction.hospitalSuspended:
      case AuditAction.hospitalUnsuspended:
      case AuditAction.hospitalFlagged:
        return 'Hospital Management';
      case AuditAction.adminAssigned:
      case AuditAction.adminRevoked:
      case AuditAction.adminAccessReset:
        return 'Access Control';
      case AuditAction.platformFeeChanged:
      case AuditAction.paymentGatewayConfigured:
        return 'Configuration';
      case AuditAction.invoiceCreated:
      case AuditAction.invoiceVerified:
      case AuditAction.invoiceRejected:
        return 'Invoice Activity';
      case AuditAction.paymentReceived:
      case AuditAction.paymentSettled:
        return 'Payment Activity';
      case AuditAction.disputeEscalated:
        return 'Exception Handling';
    }
  }
}

class AuditLog {
  final String id;
  final AuditAction action;
  final String actorId;
  final String actorName;
  final String? hospitalId;
  final String? hospitalName;
  final String? targetId;
  final String? targetType;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final String? ipAddress;

  const AuditLog({
    required this.id,
    required this.action,
    required this.actorId,
    required this.actorName,
    this.hospitalId,
    this.hospitalName,
    this.targetId,
    this.targetType,
    this.metadata,
    required this.timestamp,
    this.ipAddress,
  });

  /// Human-readable description of the audit event
  String get description {
    final hospital = hospitalName ?? 'Unknown Hospital';
    switch (action) {
      case AuditAction.hospitalCreated:
        return '$actorName created hospital account: $hospital';
      case AuditAction.hospitalActivated:
        return '$actorName activated hospital: $hospital';
      case AuditAction.hospitalSuspended:
        return '$actorName suspended hospital: $hospital';
      case AuditAction.hospitalUnsuspended:
        return '$actorName unsuspended hospital: $hospital';
      case AuditAction.hospitalFlagged:
        return '$actorName flagged hospital for review: $hospital';
      case AuditAction.adminAssigned:
        return '$actorName assigned admin to $hospital';
      case AuditAction.adminRevoked:
        return '$actorName revoked admin from $hospital';
      case AuditAction.adminAccessReset:
        return '$actorName reset admin access for $hospital';
      case AuditAction.platformFeeChanged:
        return '$actorName changed platform fee to ${metadata?['newFee']}%';
      case AuditAction.paymentGatewayConfigured:
        return '$actorName updated payment gateway settings';
      case AuditAction.invoiceCreated:
        return 'Invoice created at $hospital';
      case AuditAction.invoiceVerified:
        return 'Invoice verified at $hospital';
      case AuditAction.invoiceRejected:
        return 'Invoice rejected at $hospital';
      case AuditAction.paymentReceived:
        return 'Payment received for invoice at $hospital';
      case AuditAction.paymentSettled:
        return 'Payment settled to $hospital';
      case AuditAction.disputeEscalated:
        return '$actorName escalated dispute for $hospital';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action.name,
      'actorId': actorId,
      'actorName': actorName,
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'targetId': targetId,
      'targetType': targetType,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'ipAddress': ipAddress,
    };
  }

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String,
      action: AuditAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => AuditAction.hospitalCreated,
      ),
      actorId: json['actorId'] as String,
      actorName: json['actorName'] as String,
      hospitalId: json['hospitalId'] as String?,
      hospitalName: json['hospitalName'] as String?,
      targetId: json['targetId'] as String?,
      targetType: json['targetType'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      ipAddress: json['ipAddress'] as String?,
    );
  }
}
