import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/invoice_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/widgets.dart';
import '../invoice_detail/invoice_detail_screen.dart';

/// Screen 1: Invoice Landing
/// User: Donor
/// Purpose: Immediate trust
///
/// Elements:
/// - hospital_name_verified
/// - invoice_id
/// - treatment_category
/// - amount_needed
/// - amount_paid
/// - balance_remaining
/// - real_time_progress_bar
///
/// CTA: "Pay Part of This Bill"
class InvoiceLandingScreen extends StatefulWidget {
  final String? invoiceId;

  const InvoiceLandingScreen({super.key, this.invoiceId});

  @override
  State<InvoiceLandingScreen> createState() => _InvoiceLandingScreenState();
}

class _InvoiceLandingScreenState extends State<InvoiceLandingScreen> {
  Invoice? _invoice;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    if (widget.invoiceId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No invoice ID provided';
      });
      return;
    }

    final invoiceProvider = context.read<InvoiceProvider>();
    await invoiceProvider.loadInvoice(widget.invoiceId!);

    if (!mounted) return;

    setState(() {
      _invoice = invoiceProvider.currentInvoice;
      _isLoading = false;
      _errorMessage = invoiceProvider.errorMessage;
    });
  }

  void _navigateToDetail() {
    if (_invoice == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InvoiceDetailScreen(invoice: _invoice!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : (_invoice != null ? _buildContent() : _buildErrorState()),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.secondaryText),
            const SizedBox(height: AppSpacing.md),
            Text(
              _errorMessage ?? 'Invoice not found',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.screenHorizontal),
      child: CLInvoiceCardSkeleton(),
    );
  }

  Widget _buildContent() {
    final invoice = _invoice!;
    final hospital = invoice.hospital!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),

          // Hospital Header with Verification
          CLHospitalHeader(
            hospitalName: hospital.name,
            logoUrl: hospital.logoUrl,
            isVerified: hospital.isVerified,
          ),

          const SizedBox(height: AppSpacing.xl),

          // Main Invoice Card
          CLCard(
            padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Invoice ID & Category
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      invoice.id,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CLStatusBadge(
                      label: invoice.category.displayName,
                      type: CLStatusType.neutral,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Balance Remaining (Primary Focus)
                Text(
                  'Balance Remaining',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  CurrencyFormatter.format(invoice.balanceRemaining),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Progress Bar
                CLProgressBar(progress: invoice.progressPercentage, height: 10),

                const SizedBox(height: AppSpacing.md),

                // Amount Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAmountDetail(
                      context,
                      'Paid',
                      CurrencyFormatter.formatNoDecimal(invoice.amountPaid),
                      AppColors.success,
                    ),
                    _buildAmountDetail(
                      context,
                      'Total Bill',
                      CurrencyFormatter.formatNoDecimal(invoice.amountTotal),
                      AppColors.primaryText,
                      alignment: CrossAxisAlignment.end,
                    ),
                  ],
                ),

                if (invoice.isFullyPaid) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'This invoice has been fully paid',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Direct Settlement Notice
          _buildTrustNotice(),

          const SizedBox(height: AppSpacing.xl),

          // CTA Button
          if (!invoice.isFullyPaid)
            CLPrimaryButton(
              label: 'Pay Part of This Bill',
              onPressed: _navigateToDetail,
            ),

          if (invoice.isFullyPaid)
            CLSecondaryButton(
              label: 'View Payment History',
              onPressed: _navigateToDetail,
            ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildAmountDetail(
    BuildContext context,
    String label,
    String amount,
    Color color, {
    CrossAxisAlignment alignment = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 2),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTrustNotice() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 20,
            color: AppColors.secondaryText,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Payments settle directly to the hospital account. Funds never pass through patients.',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
