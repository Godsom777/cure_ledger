import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/widgets.dart';

/// Screen 5: Invoice Upload
/// User: Hospital Staff (Admin or Social Worker)
/// Purpose: Case creation
///
/// Access Control: hospital_admin_or_social_worker_only
/// Access Method: Hospital-issued one-time code (no email/password signup)
///
/// Elements:
/// - invoice_upload
/// - hospital_file_id
/// - treatment_category
/// - amount
/// - patient_privacy_toggle
///
/// Status after upload: pending_hospital_verification
class InvoiceUploadScreen extends StatefulWidget {
  final User currentUser;

  const InvoiceUploadScreen({super.key, required this.currentUser});

  @override
  State<InvoiceUploadScreen> createState() => _InvoiceUploadScreenState();
}

class _InvoiceUploadScreenState extends State<InvoiceUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalFileIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _patientInitialsController = TextEditingController();

  TreatmentCategory _selectedCategory = TreatmentCategory.general;
  bool _patientPrivacyEnabled = true;
  bool _isSubmitting = false;
  bool _hasUploadedInvoice = false;

  @override
  void dispose() {
    _hospitalFileIdController.dispose();
    _amountController.dispose();
    _patientInitialsController.dispose();
    super.dispose();
  }

  void _uploadInvoiceFile() {
    // TODO: Implement file picker
    setState(() => _hasUploadedInvoice = true);
  }

  Future<void> _submitInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasUploadedInvoice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an invoice document')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate submission
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Show success
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.success,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text('Invoice Submitted'),
          ],
        ),
        content: const Text(
          'The invoice has been submitted for verification. A hospital admin will review and approve it.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Upload Invoice'),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Access Notice
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              size: 20,
                              color: AppColors.verified,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Logged in as ${widget.currentUser.name ?? "Staff"}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    widget.currentUser.role.displayName,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Invoice Document Upload
                      Text(
                        'Invoice Document',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      GestureDetector(
                        onTap: _uploadInvoiceFile,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            border: Border.all(
                              color: _hasUploadedInvoice
                                  ? AppColors.success
                                  : AppColors.border,
                              style: _hasUploadedInvoice
                                  ? BorderStyle.solid
                                  : BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _hasUploadedInvoice
                                    ? Icons.check_circle_outline
                                    : Icons.cloud_upload_outlined,
                                size: 48,
                                color: _hasUploadedInvoice
                                    ? AppColors.success
                                    : AppColors.secondaryText,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                _hasUploadedInvoice
                                    ? 'Invoice uploaded'
                                    : 'Tap to upload invoice',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: _hasUploadedInvoice
                                          ? AppColors.success
                                          : AppColors.secondaryText,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              if (!_hasUploadedInvoice) ...[
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  'PDF, JPG, or PNG',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Hospital File ID
                      Text(
                        'Hospital File ID',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _hospitalFileIdController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., LUTH/2024/PAT/4055',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Hospital file ID is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Treatment Category
                      Text(
                        'Treatment Category',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<TreatmentCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(),
                        items: TreatmentCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Amount
                      Text(
                        'Invoice Amount (₦)',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          prefixText: '₦ ',
                          hintText: '0.00',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Amount is required';
                          }
                          final amount = double.tryParse(
                            value.replaceAll(',', ''),
                          );
                          if (amount == null || amount <= 0) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Patient Privacy Toggle
                      Text(
                        'Patient Privacy',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      CLCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Protect patient identity',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Only initials will be shown to donors',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _patientPrivacyEnabled,
                                  onChanged: (value) {
                                    setState(
                                      () => _patientPrivacyEnabled = value,
                                    );
                                  },
                                  activeColor: AppColors.primaryText,
                                ),
                              ],
                            ),
                            if (_patientPrivacyEnabled) ...[
                              const SizedBox(height: AppSpacing.md),
                              TextFormField(
                                controller: _patientInitialsController,
                                decoration: const InputDecoration(
                                  hintText: 'Patient initials (e.g., A.O.)',
                                  isDense: true,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Notice
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'This invoice will require verification by a hospital administrator before it becomes visible to donors.',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: AppColors.warning,
                                      height: 1.4,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ),

            // Submit Button
            Container(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: CLPrimaryButton(
                label: _isSubmitting
                    ? 'Submitting...'
                    : 'Submit for Verification',
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submitInvoice,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
