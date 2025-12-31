/// Invoice status in the CureLedger system
enum InvoiceStatus { pending, verified, partiallyPaid, fullyPaid, rejected }

/// Treatment categories for medical invoices
enum TreatmentCategory {
  surgery,
  chemotherapy,
  dialysis,
  emergency,
  maternity,
  pediatric,
  cardiology,
  orthopedic,
  neurology,
  general,
  other,
}

extension TreatmentCategoryExtension on TreatmentCategory {
  String get displayName {
    switch (this) {
      case TreatmentCategory.surgery:
        return 'Surgery';
      case TreatmentCategory.chemotherapy:
        return 'Chemotherapy';
      case TreatmentCategory.dialysis:
        return 'Dialysis';
      case TreatmentCategory.emergency:
        return 'Emergency Care';
      case TreatmentCategory.maternity:
        return 'Maternity';
      case TreatmentCategory.pediatric:
        return 'Pediatric Care';
      case TreatmentCategory.cardiology:
        return 'Cardiology';
      case TreatmentCategory.orthopedic:
        return 'Orthopedic';
      case TreatmentCategory.neurology:
        return 'Neurology';
      case TreatmentCategory.general:
        return 'General Medicine';
      case TreatmentCategory.other:
        return 'Other';
    }
  }
}

extension InvoiceStatusExtension on InvoiceStatus {
  String get displayName {
    switch (this) {
      case InvoiceStatus.pending:
        return 'Pending Verification';
      case InvoiceStatus.verified:
        return 'Verified';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
      case InvoiceStatus.fullyPaid:
        return 'Fully Paid';
      case InvoiceStatus.rejected:
        return 'Rejected';
    }
  }
}
