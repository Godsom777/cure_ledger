import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/widgets.dart';
import '../payment/payment_screen.dart';

/// Screen 2: Invoice Detail
/// User: Donor
/// Purpose: Transparency
///
/// Elements:
/// - invoice_breakdown
/// - issue_date
/// - doctor_verification_badge
/// - patient_privacy_status
/// - direct_hospital_settlement_notice
///
/// CTA: "Continue to Pay"
class InvoiceDetailScreen extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  void _navigateToPayment(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PaymentScreen(invoice: invoice)));
  }

  @override
  Widget build(BuildContext context) {
    final hospital = invoice.hospital!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Invoice ${invoice.id}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hospital Header (Compact)
                    CLHospitalHeader(
                      hospitalName: hospital.name,
                      logoUrl: hospital.logoUrl,
                      isVerified: hospital.isVerified,
                      compact: true,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Invoice Summary Card
                    CLCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice Summary',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          CLInfoRow(label: 'Invoice ID', value: invoice.id),
                          CLInfoRow(
                            label: 'Hospital File ID',
                            value: invoice.hospitalFileId,
                          ),
                          CLInfoRow(
                            label: 'Treatment Category',
                            value: invoice.category.displayName,
                          ),
                          CLInfoRow(
                            label: 'Issue Date',
                            value: DateFormatter.formatShort(invoice.issueDate),
                          ),

                          const Divider(height: AppSpacing.lg),

                          CLInfoRow(
                            label: 'Total Amount',
                            value: CurrencyFormatter.format(
                              invoice.amountTotal,
                            ),
                            valueStyle: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          CLInfoRow(
                            label: 'Amount Paid',
                            value: CurrencyFormatter.format(invoice.amountPaid),
                            valueStyle: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                          ),
                          CLInfoRow(
                            label: 'Balance Remaining',
                            value: CurrencyFormatter.format(
                              invoice.balanceRemaining,
                            ),
                            valueStyle: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          CLProgressBar(
                            progress: invoice.progressPercentage,
                            height: 8,
                            showPercentage: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Verification Card
                    CLCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Verification',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const Spacer(),
                              const CLVerifiedBadge(label: 'Verified'),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          if (invoice.verifiedByDoctorName != null)
                            CLInfoRow(
                              label: 'Verified By',
                              value: invoice.verifiedByDoctorName!,
                              trailing: const Icon(
                                Icons.verified,
                                size: 16,
                                color: AppColors.verified,
                              ),
                            ),
                          if (invoice.verifiedAt != null)
                            CLInfoRow(
                              label: 'Verified On',
                              value: DateFormatter.formatShort(
                                invoice.verifiedAt!,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Privacy Status Card
                    CLCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patient Privacy',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          Row(
                            children: [
                              Icon(
                                invoice.patientPrivacyEnabled
                                    ? Icons.shield_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                                color: AppColors.secondaryText,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  invoice.patientPrivacyEnabled
                                      ? 'Patient identity is protected. Only initials shown: ${invoice.patientInitials ?? "N/A"}'
                                      : 'Patient has opted for public visibility',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Direct Settlement Notice
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primaryText.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance_outlined,
                                size: 18,
                                color: AppColors.primaryText,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Direct Hospital Settlement',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'All payments are settled directly to ${hospital.name}\'s bank account (${hospital.bankName}). Funds never pass through patients.',
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(height: 1.5),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Bank Narration: ${invoice.bankNarration}',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // Bottom CTA
            if (!invoice.isFullyPaid)
              Container(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: CLPrimaryButton(
                  label: 'Continue to Pay',
                  onPressed: () => _navigateToPayment(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
