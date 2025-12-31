import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/widgets.dart';
import '../invoice_landing/invoice_landing_screen.dart';

/// Screen 4: Payment Confirmation
/// User: Donor
/// Purpose: Trust reinforcement
///
/// Elements:
/// - confirmation_message
/// - hospital_name
/// - invoice_id
/// - updated_balance
/// - downloadable_receipt
/// - share_link
class PaymentConfirmationScreen extends StatelessWidget {
  final Invoice invoice;
  final Payment payment;

  const PaymentConfirmationScreen({
    super.key,
    required this.invoice,
    required this.payment,
  });

  // Calculate new balance after payment
  double get _newBalance => invoice.balanceRemaining - payment.amount;
  double get _newAmountPaid => invoice.amountPaid + payment.amount;
  double get _newProgress => _newAmountPaid / invoice.amountTotal;

  void _sharePaymentLink() {
    final shareText =
        '''
I just contributed ${CurrencyFormatter.format(payment.amount)} towards a medical bill at ${invoice.hospital!.name}.

Invoice: ${invoice.id}
Remaining: ${CurrencyFormatter.format(_newBalance)}

Help complete this payment:
https://cureledger.com/invoice/${invoice.id}
''';
    Share.share(shareText);
  }

  void _downloadReceipt() {
    // TODO: Implement PDF receipt generation
  }

  void _goToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const InvoiceLandingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 40,
                  color: AppColors.success,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Confirmation Message
              Text(
                'Payment Successful',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Thank you for your contribution',
                style: Theme.of(context).textTheme.bodySmall,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Payment Details Card
              CLCard(
                child: Column(
                  children: [
                    // Amount Paid
                    Text(
                      CurrencyFormatter.format(payment.amount),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Amount Paid',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),

                    // Transaction Details
                    CLInfoRow(label: 'Hospital', value: invoice.hospital!.name),
                    CLInfoRow(label: 'Invoice ID', value: invoice.id),
                    CLInfoRow(
                      label: 'Payment Method',
                      value: payment.method.displayName,
                    ),
                    CLInfoRow(
                      label: 'Reference',
                      value: payment.paystackReference ?? 'N/A',
                    ),
                    CLInfoRow(
                      label: 'Date',
                      value: DateFormatter.formatDateTime(payment.createdAt),
                    ),
                    CLInfoRow(
                      label: 'Bank Narration',
                      value: payment.bankNarration,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Updated Balance Card
              CLCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Updated Invoice Status',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New Balance',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(_newBalance),
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        if (_newBalance <= 0)
                          const CLStatusBadge(
                            label: 'Fully Paid',
                            type: CLStatusType.success,
                            isLarge: true,
                          ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    CLProgressBar(
                      progress: _newProgress,
                      height: 10,
                      showPercentage: true,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Paid: ${CurrencyFormatter.formatNoDecimal(_newAmountPaid)}',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppColors.success),
                        ),
                        Text(
                          'of ${CurrencyFormatter.formatNoDecimal(invoice.amountTotal)}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CLSecondaryButton(
                      label: 'Download Receipt',
                      icon: Icons.download_outlined,
                      onPressed: _downloadReceipt,
                      isExpanded: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: CLSecondaryButton(
                      label: 'Share',
                      icon: Icons.share_outlined,
                      onPressed: _sharePaymentLink,
                      isExpanded: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              CLPrimaryButton(
                label: 'Done',
                onPressed: () => _goToHome(context),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
