import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/invoice_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/widgets.dart';

/// Screen 6: Hospital Verification
/// User: Hospital Admin
/// Purpose: Fraud prevention
///
/// Elements:
/// - invoice_review
/// - approve_reject
/// - assign_doctor
/// - generate_public_payment_link
class HospitalVerificationScreen extends StatefulWidget {
  final User currentUser;

  const HospitalVerificationScreen({super.key, required this.currentUser});

  @override
  State<HospitalVerificationScreen> createState() =>
      _HospitalVerificationScreenState();
}

class _HospitalVerificationScreenState
    extends State<HospitalVerificationScreen> {
  List<Invoice> _pendingInvoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingInvoices();
  }

  Future<void> _loadPendingInvoices() async {
    final invoiceProvider = context.read<InvoiceProvider>();
    await invoiceProvider.loadHospitalInvoices(
      widget.currentUser.hospitalId!,
      status: InvoiceStatus.pending,
    );

    if (!mounted) return;

    setState(() {
      _pendingInvoices = invoiceProvider.invoices;
      _isLoading = false;
    });
  }

  void _openInvoiceReview(Invoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InvoiceReviewSheet(
        invoice: invoice,
        onApprove: () => _approveInvoice(invoice),
        onReject: () => _rejectInvoice(invoice),
      ),
    );
  }

  Future<void> _approveInvoice(Invoice invoice) async {
    Navigator.of(context).pop();

    // Show doctor assignment dialog
    final doctor = await showDialog<String>(
      context: context,
      builder: (context) => _DoctorAssignmentDialog(),
    );

    if (doctor != null && mounted) {
      // TODO: Update invoice status
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invoice ${invoice.id} approved and assigned to $doctor',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      _loadPendingInvoices();
    }
  }

  void _rejectInvoice(Invoice invoice) {
    Navigator.of(context).pop();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Invoice'),
        content: const TextField(
          maxLines: 3,
          decoration: InputDecoration(hintText: 'Reason for rejection'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invoice ${invoice.id} rejected'),
                  backgroundColor: AppColors.error,
                ),
              );
              _loadPendingInvoices();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Invoice Verification')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _pendingInvoices.isEmpty
            ? CLEmptyState(
                icon: Icons.check_circle_outline,
                title: 'No Pending Invoices',
                description: 'All invoices have been reviewed',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                itemCount: _pendingInvoices.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final invoice = _pendingInvoices[index];
                  return _PendingInvoiceCard(
                    invoice: invoice,
                    onTap: () => _openInvoiceReview(invoice),
                  );
                },
              ),
      ),
    );
  }
}

class _PendingInvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onTap;

  const _PendingInvoiceCard({required this.invoice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CLCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                invoice.id,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              CLStatusBadge(
                label: invoice.status.displayName,
                type: invoice.status == InvoiceStatus.pending
                    ? CLStatusType.warning
                    : CLStatusType.neutral,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          CLInfoRow(label: 'Hospital File', value: invoice.hospitalFileId),
          CLInfoRow(label: 'Category', value: invoice.category.displayName),
          CLInfoRow(
            label: 'Amount',
            value: CurrencyFormatter.format(invoice.amountTotal),
            valueStyle: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          CLInfoRow(
            label: 'Uploaded',
            value: DateFormatter.formatRelative(invoice.createdAt),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.touch_app_outlined,
                size: 16,
                color: AppColors.secondaryText,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                'Tap to review',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvoiceReviewSheet extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _InvoiceReviewSheet({
    required this.invoice,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Review Invoice',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CLCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              invoice.id,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            CLInfoRow(
                              label: 'Hospital File ID',
                              value: invoice.hospitalFileId,
                            ),
                            CLInfoRow(
                              label: 'Treatment Category',
                              value: invoice.category.displayName,
                            ),
                            CLInfoRow(
                              label: 'Amount',
                              value: CurrencyFormatter.format(
                                invoice.amountTotal,
                              ),
                              valueStyle: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            CLInfoRow(
                              label: 'Issue Date',
                              value: DateFormatter.formatShort(
                                invoice.issueDate,
                              ),
                            ),
                            CLInfoRow(
                              label: 'Patient Privacy',
                              value: invoice.patientPrivacyEnabled
                                  ? 'Enabled (${invoice.patientInitials})'
                                  : 'Disabled',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Invoice Document Preview
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 48,
                                color: AppColors.secondaryText,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Invoice Document',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              CLTextButton(
                                label: 'View Full Document',
                                icon: Icons.open_in_new,
                                iconAfter: true,
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: CLPrimaryButton(
                        label: 'Approve & Assign Doctor',
                        onPressed: onApprove,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DoctorAssignmentDialog extends StatefulWidget {
  @override
  State<_DoctorAssignmentDialog> createState() =>
      _DoctorAssignmentDialogState();
}

class _DoctorAssignmentDialogState extends State<_DoctorAssignmentDialog> {
  String? _selectedDoctor;

  final List<String> _doctors = [
    'Dr. Adeyemi Okonkwo',
    'Dr. Funke Adesanya',
    'Dr. Ibrahim Musa',
    'Dr. Amina Bello',
    'Dr. Chukwuemeka Eze',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      title: const Text('Assign Verifying Doctor'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _doctors.map((doctor) {
          return RadioListTile<String>(
            title: Text(doctor),
            value: doctor,
            groupValue: _selectedDoctor,
            onChanged: (value) {
              setState(() => _selectedDoctor = value);
            },
            activeColor: AppColors.primaryText,
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _selectedDoctor != null
              ? () => Navigator.of(context).pop(_selectedDoctor)
              : null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
