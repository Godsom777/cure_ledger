import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Amount input with preset buttons
class CLAmountInput extends StatefulWidget {
  final double? initialAmount;
  final double maxAmount;
  final List<double> presetAmounts;
  final ValueChanged<double?> onAmountChanged;
  final String currencySymbol;

  const CLAmountInput({
    super.key,
    this.initialAmount,
    required this.maxAmount,
    this.presetAmounts = const [5000, 10000, 25000, 50000],
    required this.onAmountChanged,
    this.currencySymbol = '₦',
  });

  @override
  State<CLAmountInput> createState() => _CLAmountInputState();
}

class _CLAmountInputState extends State<CLAmountInput> {
  late TextEditingController _controller;
  double? _selectedPreset;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialAmount?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPresetSelected(double amount) {
    setState(() {
      _selectedPreset = amount;
      _controller.text = amount.toStringAsFixed(0);
      _errorText = null;
    });
    widget.onAmountChanged(amount);
  }

  void _onCustomAmountChanged(String value) {
    setState(() {
      _selectedPreset = null;
    });

    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null && value.isNotEmpty) {
      setState(() => _errorText = 'Enter a valid amount');
      widget.onAmountChanged(null);
    } else if (amount != null && amount > widget.maxAmount) {
      setState(() => _errorText = 'Amount exceeds balance');
      widget.onAmountChanged(null);
    } else if (amount != null && amount < 100) {
      setState(
        () => _errorText = 'Minimum amount is ${widget.currencySymbol}100',
      );
      widget.onAmountChanged(null);
    } else {
      setState(() => _errorText = null);
      widget.onAmountChanged(amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter presets to only show amounts <= maxAmount
    final validPresets = widget.presetAmounts
        .where((amount) => amount <= widget.maxAmount)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preset amount buttons
        if (validPresets.isNotEmpty) ...[
          Text('Quick amounts', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: validPresets.map((amount) {
              final isSelected = _selectedPreset == amount;
              return _PresetButton(
                amount: amount,
                currencySymbol: widget.currencySymbol,
                isSelected: isSelected,
                onTap: () => _onPresetSelected(amount),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Custom amount input
        Text(
          'Or enter custom amount',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixText: '${widget.currencySymbol} ',
            prefixStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
            hintText: '0',
            errorText: _errorText,
            filled: true,
            fillColor: AppColors.white,
          ),
          onChanged: _onCustomAmountChanged,
        ),
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  final double amount;
  final String currencySymbol;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetButton({
    required this.amount,
    required this.currencySymbol,
    required this.isSelected,
    required this.onTap,
  });

  String get _formattedAmount {
    if (amount >= 1000) {
      return '$currencySymbol${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '$currencySymbol${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryText : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isSelected ? AppColors.primaryText : AppColors.border,
          ),
        ),
        child: Text(
          _formattedAmount,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.primaryText,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}
