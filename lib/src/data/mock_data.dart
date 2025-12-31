import '../models/models.dart';

/// Mock data for development and testing
/// This simulates what would come from Supabase backend
class MockData {
  MockData._();

  // Mock Hospitals
  static final Hospital luth = Hospital(
    id: 'hosp_001',
    name: 'Lagos University Teaching Hospital',
    code: 'LUTH',
    address: 'Idi-Araba, Surulere, Lagos',
    logoUrl: null,
    isVerified: true,
    bankAccountNumber: '0123456789',
    bankName: 'First Bank',
    paystackSubaccountCode: 'ACCT_luth001',
    createdAt: DateTime(2024, 1, 1),
  );

  static final Hospital uch = Hospital(
    id: 'hosp_002',
    name: 'University College Hospital',
    code: 'UCH',
    address: 'Queen Elizabeth Road, Ibadan',
    logoUrl: null,
    isVerified: true,
    bankAccountNumber: '0987654321',
    bankName: 'GTBank',
    paystackSubaccountCode: 'ACCT_uch001',
    createdAt: DateTime(2024, 2, 15),
  );

  static final Hospital nhi = Hospital(
    id: 'hosp_003',
    name: 'National Hospital Abuja',
    code: 'NHA',
    address: 'Plot 132, Central District, Abuja',
    logoUrl: null,
    isVerified: true,
    bankAccountNumber: '1122334455',
    bankName: 'Zenith Bank',
    paystackSubaccountCode: 'ACCT_nha001',
    createdAt: DateTime(2024, 3, 20),
  );

  static List<Hospital> get hospitals => [luth, uch, nhi];

  // Mock Invoices
  static final Invoice invoice1 = Invoice(
    id: 'INV-3921',
    hospitalId: 'hosp_001',
    hospital: luth,
    hospitalFileId: 'LUTH/2024/PAT/3921',
    category: TreatmentCategory.surgery,
    amountTotal: 2500000,
    amountPaid: 1750000,
    status: InvoiceStatus.partiallyPaid,
    issueDate: DateTime(2024, 12, 15),
    verifiedAt: DateTime(2024, 12, 16),
    verifiedByDoctorId: 'doc_001',
    verifiedByDoctorName: 'Dr. Adeyemi Okonkwo',
    patientPrivacyEnabled: true,
    patientInitials: 'A.O.',
    uploadedById: 'user_sw_001',
    createdAt: DateTime(2024, 12, 15),
    updatedAt: DateTime(2024, 12, 28),
  );

  static final Invoice invoice2 = Invoice(
    id: 'INV-4102',
    hospitalId: 'hosp_002',
    hospital: uch,
    hospitalFileId: 'UCH/2024/PAT/4102',
    category: TreatmentCategory.dialysis,
    amountTotal: 850000,
    amountPaid: 0,
    status: InvoiceStatus.verified,
    issueDate: DateTime(2024, 12, 20),
    verifiedAt: DateTime(2024, 12, 21),
    verifiedByDoctorId: 'doc_002',
    verifiedByDoctorName: 'Dr. Funke Adesanya',
    patientPrivacyEnabled: true,
    patientInitials: 'E.N.',
    uploadedById: 'user_sw_002',
    createdAt: DateTime(2024, 12, 20),
    updatedAt: DateTime(2024, 12, 21),
  );

  static final Invoice invoice3 = Invoice(
    id: 'INV-4055',
    hospitalId: 'hosp_001',
    hospital: luth,
    hospitalFileId: 'LUTH/2024/PAT/4055',
    category: TreatmentCategory.chemotherapy,
    amountTotal: 1200000,
    amountPaid: 1200000,
    status: InvoiceStatus.fullyPaid,
    issueDate: DateTime(2024, 12, 10),
    verifiedAt: DateTime(2024, 12, 11),
    verifiedByDoctorId: 'doc_003',
    verifiedByDoctorName: 'Dr. Ibrahim Musa',
    patientPrivacyEnabled: false,
    patientInitials: null,
    uploadedById: 'user_sw_001',
    createdAt: DateTime(2024, 12, 10),
    updatedAt: DateTime(2024, 12, 25),
  );

  static final Invoice invoice4 = Invoice(
    id: 'INV-4200',
    hospitalId: 'hosp_003',
    hospital: nhi,
    hospitalFileId: 'NHA/2024/PAT/4200',
    category: TreatmentCategory.cardiology,
    amountTotal: 3500000,
    amountPaid: 500000,
    status: InvoiceStatus.partiallyPaid,
    issueDate: DateTime(2024, 12, 22),
    verifiedAt: DateTime(2024, 12, 23),
    verifiedByDoctorId: 'doc_004',
    verifiedByDoctorName: 'Dr. Amina Bello',
    patientPrivacyEnabled: true,
    patientInitials: 'K.A.',
    uploadedById: 'user_sw_003',
    createdAt: DateTime(2024, 12, 22),
    updatedAt: DateTime(2024, 12, 29),
  );

  static List<Invoice> get invoices => [invoice1, invoice2, invoice3, invoice4];

  // Get invoice by ID
  static Invoice? getInvoice(String id) {
    try {
      return invoices.firstWhere((inv) => inv.id == id);
    } catch (_) {
      return null;
    }
  }

  // Mock Payments
  static final List<Payment> payments = [
    Payment(
      id: 'pay_001',
      invoiceId: 'INV-3921',
      amount: 500000,
      status: PaymentStatus.successful,
      method: PaymentMethod.card,
      paystackReference: 'PSK_ref_001',
      donorEmail: 'donor1@email.com',
      bankNarration: 'CURE-LUTH-INV-3921',
      createdAt: DateTime(2024, 12, 18),
      settledAt: DateTime(2024, 12, 18),
    ),
    Payment(
      id: 'pay_002',
      invoiceId: 'INV-3921',
      amount: 750000,
      status: PaymentStatus.successful,
      method: PaymentMethod.bankTransfer,
      paystackReference: 'PSK_ref_002',
      donorEmail: 'donor2@email.com',
      bankNarration: 'CURE-LUTH-INV-3921',
      createdAt: DateTime(2024, 12, 22),
      settledAt: DateTime(2024, 12, 22),
    ),
    Payment(
      id: 'pay_003',
      invoiceId: 'INV-3921',
      amount: 500000,
      status: PaymentStatus.successful,
      method: PaymentMethod.card,
      paystackReference: 'PSK_ref_003',
      donorEmail: 'donor3@email.com',
      bankNarration: 'CURE-LUTH-INV-3921',
      createdAt: DateTime(2024, 12, 28),
      settledAt: DateTime(2024, 12, 28),
    ),
  ];

  // Mock Users
  static final User hospitalAdmin = User(
    id: 'user_admin_001',
    email: 'admin@luth.gov.ng',
    role: UserRole.hospitalAdmin,
    hospitalId: 'hosp_001',
    name: 'Dr. Olusegun Adebayo',
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    lastLoginAt: DateTime.now(),
  );

  static final User socialWorker = User(
    id: 'user_sw_001',
    email: null,
    role: UserRole.socialWorker,
    hospitalId: 'hosp_001',
    name: 'Mrs. Grace Obi',
    isActive: true,
    createdAt: DateTime(2024, 6, 15),
    lastLoginAt: DateTime.now(),
  );

  static final User financeOfficer = User(
    id: 'user_fin_001',
    email: 'finance@luth.gov.ng',
    role: UserRole.hospitalFinance,
    hospitalId: 'hosp_001',
    name: 'Mr. Tunde Bakare',
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    lastLoginAt: DateTime.now(),
  );

  // Super Admin User
  static final User superAdmin = User(
    id: 'user_super_001',
    email: 'admin@cureledger.com',
    role: UserRole.platformSuperAdmin,
    hospitalId: null,
    name: 'Platform Administrator',
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    lastLoginAt: DateTime.now(),
  );

  // Platform Configuration
  static final PlatformConfig platformConfig = PlatformConfig(
    id: 'config_001',
    platformFeePercentage: 5.0,
    hospitalSettlementPercentage: 95.0,
    paystackPublicKey: 'pk_test_xxxxxxxxxxxxx',
    paystackSecretKeyHint: '••••••••xxxx',
    paystackTestMode: true,
    lastUpdated: DateTime(2024, 12, 1),
    lastUpdatedBy: 'Platform Administrator',
  );

  // System Settlement Totals
  static SystemSettlementTotals get systemTotals {
    double totalReceived = 0;
    for (final payment in payments) {
      if (payment.status == PaymentStatus.successful) {
        totalReceived += payment.amount;
      }
    }
    return SystemSettlementTotals(
      totalPaymentsReceived: totalReceived,
      totalPlatformFees: totalReceived * 0.05,
      totalHospitalSettlements: totalReceived * 0.95,
      totalTransactions: payments
          .where((p) => p.status == PaymentStatus.successful)
          .length,
      totalHospitals: hospitals.length,
      totalInvoices: invoices.length,
      asOf: DateTime.now(),
    );
  }

  // Mock Audit Logs
  static List<AuditLog> get auditLogs => [
    AuditLog(
      id: 'audit_001',
      action: AuditAction.hospitalCreated,
      actorId: 'user_super_001',
      actorName: 'Platform Administrator',
      hospitalId: 'hosp_001',
      hospitalName: 'Lagos University Teaching Hospital',
      timestamp: DateTime(2024, 1, 1, 9, 0),
      ipAddress: '192.168.1.1',
    ),
    AuditLog(
      id: 'audit_002',
      action: AuditAction.hospitalActivated,
      actorId: 'user_super_001',
      actorName: 'Platform Administrator',
      hospitalId: 'hosp_001',
      hospitalName: 'Lagos University Teaching Hospital',
      timestamp: DateTime(2024, 1, 2, 10, 30),
      ipAddress: '192.168.1.1',
    ),
    AuditLog(
      id: 'audit_003',
      action: AuditAction.adminAssigned,
      actorId: 'user_super_001',
      actorName: 'Platform Administrator',
      hospitalId: 'hosp_001',
      hospitalName: 'Lagos University Teaching Hospital',
      targetId: 'user_admin_001',
      targetType: 'user',
      metadata: {'adminName': 'Dr. Olusegun Adebayo'},
      timestamp: DateTime(2024, 1, 2, 11, 0),
      ipAddress: '192.168.1.1',
    ),
    AuditLog(
      id: 'audit_004',
      action: AuditAction.hospitalCreated,
      actorId: 'user_super_001',
      actorName: 'Platform Administrator',
      hospitalId: 'hosp_002',
      hospitalName: 'University College Hospital',
      timestamp: DateTime(2024, 2, 15, 14, 0),
      ipAddress: '192.168.1.1',
    ),
    AuditLog(
      id: 'audit_005',
      action: AuditAction.hospitalActivated,
      actorId: 'user_super_001',
      actorName: 'Platform Administrator',
      hospitalId: 'hosp_002',
      hospitalName: 'University College Hospital',
      timestamp: DateTime(2024, 2, 16, 9, 0),
      ipAddress: '192.168.1.1',
    ),
    AuditLog(
      id: 'audit_006',
      action: AuditAction.invoiceCreated,
      actorId: 'user_sw_001',
      actorName: 'Mrs. Grace Obi',
      hospitalId: 'hosp_001',
      hospitalName: 'Lagos University Teaching Hospital',
      targetId: 'INV-3921',
      targetType: 'invoice',
      timestamp: DateTime(2024, 12, 15, 10, 0),
    ),
    AuditLog(
      id: 'audit_007',
      action: AuditAction.invoiceVerified,
      actorId: 'user_admin_001',
      actorName: 'Dr. Olusegun Adebayo',
      hospitalId: 'hosp_001',
      hospitalName: 'Lagos University Teaching Hospital',
      targetId: 'INV-3921',
      targetType: 'invoice',
      timestamp: DateTime(2024, 12, 16, 11, 30),
    ),
    AuditLog(
      id: 'audit_008',
      action: AuditAction.paymentReceived,
      actorId: 'system',
      actorName: 'System',
      hospitalId: 'hosp_001',
      hospitalName: 'Lagos University Teaching Hospital',
      targetId: 'pay_001',
      targetType: 'payment',
      metadata: {'amount': 500000, 'invoiceId': 'INV-3921'},
      timestamp: DateTime(2024, 12, 18, 14, 22),
    ),
    AuditLog(
      id: 'audit_009',
      action: AuditAction.paymentSettled,
      actorId: 'system',
      actorName: 'System',
      hospitalId: 'hosp_001',
      hospitalName: 'Lagos University Teaching Hospital',
      targetId: 'pay_001',
      targetType: 'payment',
      metadata: {'amount': 475000, 'bankNarration': 'CURE-LUTH-INV-3921'},
      timestamp: DateTime(2024, 12, 18, 14, 25),
    ),
    AuditLog(
      id: 'audit_010',
      action: AuditAction.platformFeeChanged,
      actorId: 'user_super_001',
      actorName: 'Platform Administrator',
      metadata: {'oldFee': 3.0, 'newFee': 5.0},
      timestamp: DateTime(2024, 12, 1, 9, 0),
      ipAddress: '192.168.1.1',
    ),
  ];

  // Dashboard stats for hospital
  static Map<String, dynamic> getDashboardStats(String hospitalId) {
    final hospitalInvoices = invoices.where((i) => i.hospitalId == hospitalId);
    final hospitalPayments = payments.where((p) {
      final invoice = getInvoice(p.invoiceId);
      return invoice?.hospitalId == hospitalId;
    });

    double totalReceived = 0;
    for (final payment in hospitalPayments) {
      if (payment.status == PaymentStatus.successful) {
        totalReceived += payment.hospitalSettlement;
      }
    }

    return {
      'totalInvoices': hospitalInvoices.length,
      'pendingVerification': hospitalInvoices
          .where((i) => i.status == InvoiceStatus.pending)
          .length,
      'activeInvoices': hospitalInvoices
          .where(
            (i) =>
                i.status == InvoiceStatus.verified ||
                i.status == InvoiceStatus.partiallyPaid,
          )
          .length,
      'fullyPaid': hospitalInvoices
          .where((i) => i.status == InvoiceStatus.fullyPaid)
          .length,
      'totalReceived': totalReceived,
      'totalPayments': hospitalPayments
          .where((p) => p.status == PaymentStatus.successful)
          .length,
    };
  }
}
