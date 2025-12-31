import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/widgets.dart';
import '../payment_confirmation/payment_confirmation_screen.dart';

/// Screen 3: Payment
/// User: Donor
/// Purpose: Low-friction payment
///
/// Elements:
/// - preset_amounts
/// - custom_amount
/// - payment_methods_card_ussd_transfer
///
/// Rules:
/// - partial_payments_allowed: true
/// - payments_non_refundable: true
/// - funds_treated_as_hospital_credit: true
class PaymentScreen extends StatefulWidget {
  final Invoice invoice;

  const PaymentScreen({super.key, required this.invoice});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  double? _selectedAmount;
  PaymentMethod _selectedMethod = PaymentMethod.card;
  bool _isProcessing = false;
  bool _agreedToTerms = false;

  List<double> get _presetAmounts {
    final balance = widget.invoice.balanceRemaining;
    // Generate presets based on balance
    if (balance >= 100000) {
      return [5000, 10000, 25000, 50000];
    } else if (balance >= 50000) {
      return [2000, 5000, 10000, 25000];
    } else if (balance >= 10000) {
      return [1000, 2000, 5000];
    } else {
      return [500, 1000, 2000];
    }
  }

  bool get _canProceed =>
      _selectedAmount != null &&
      _selectedAmount! >= 100 &&
      _selectedAmount! <= widget.invoice.balanceRemaining &&
      _agreedToTerms;

  Future<void> _processPayment() async {
    if (!_canProceed) return;

    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Create mock payment
    final payment = Payment(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      invoiceId: widget.invoice.id,
      amount: _selectedAmount!,
      status: PaymentStatus.successful,
      method: _selectedMethod,
      paystackReference: 'PSK_${DateTime.now().millisecondsSinceEpoch}',
      bankNarration: widget.invoice.bankNarration,
      createdAt: DateTime.now(),
      settledAt: DateTime.now(),
    );

    // Navigate to confirmation
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PaymentConfirmationScreen(
          invoice: widget.invoice,
          payment: payment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Make Payment'),
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
                    // Balance Summary
                    CLCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice ${widget.invoice.id}',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Balance Remaining',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                CurrencyFormatter.format(
                                  widget.invoice.balanceRemaining,
                                ),
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Amount Selection
                    Text(
                      'Select Amount',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    CLCard(
                      child: CLAmountInput(
                        maxAmount: widget.invoice.balanceRemaining,
                        presetAmounts: _presetAmounts,
                        onAmountChanged: (amount) {
                          setState(() => _selectedAmount = amount);
                        },
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Payment Method Selection
                    Text(
                      'Payment Method',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    CLCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: PaymentMethod.values.map((method) {
                          return _PaymentMethodTile(
                            method: method,
                            isSelected: _selectedMethod == method,
                            onTap: () {
                              setState(() => _selectedMethod = method);
                            },
                            isLast: method == PaymentMethod.values.last,
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Terms Agreement
                    GestureDetector(
                      onTap: () {
                        setState(() => _agreedToTerms = !_agreedToTerms);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreedToTerms,
                                onChanged: (value) {
                                  setState(
                                    () => _agreedToTerms = value ?? false,
                                  );
                                },
                                activeColor: AppColors.primaryText,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'I understand that all payments are irrevocable and are treated as hospital credit for the patient. Payments are non-refundable.',
                                style: Theme.of(
                                  context,
                                ).textTheme.labelLarge?.copyWith(height: 1.5),
                              ),
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

            // Bottom CTA
            Container(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Column(
                children: [
                  if (_selectedAmount != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'You\'re paying',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          CurrencyFormatter.format(_selectedAmount!),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  CLPrimaryButton(
                    label: _isProcessing ? 'Processing...' : 'Pay Now',
                    isLoading: _isProcessing,
                    onPressed: _canProceed ? _processPayment : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLast;

  const _PaymentMethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
    required this.isLast,
  });

  IconData get _icon {
    switch (method) {
      case PaymentMethod.card:
        return Icons.credit_card_outlined;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance_outlined;
      case PaymentMethod.ussd:
        return Icons.dialpad_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryText.withValues(alpha: 0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    _icon,
                    size: 22,
                    color: isSelected
                        ? AppColors.primaryText
                        : AppColors.secondaryText,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    method.displayName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                Radio<PaymentMethod>(
                  value: method,
                  groupValue: isSelected ? method : null,
                  onChanged: (_) => onTap(),
                  activeColor: AppColors.primaryText,
                ),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}
