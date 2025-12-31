import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Verified badge for hospitals and doctors
/// Monochrome, subtle design (no bright colors)
class CLVerifiedBadge extends StatelessWidget {
  final String? label;
  final bool isLarge;

  const CLVerifiedBadge({super.key, this.label, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    final iconSize = isLarge ? 18.0 : 14.0;
    final fontSize = isLarge ? 14.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? AppSpacing.sm : AppSpacing.xs,
        vertical: isLarge ? AppSpacing.xxs + 2 : AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.verified.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_outlined,
            size: iconSize,
            color: AppColors.verified,
          ),
          if (label != null) ...[
            const SizedBox(width: AppSpacing.xxs),
            Text(
              label!,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: AppColors.verified,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Status badge for invoices and payments
class CLStatusBadge extends StatelessWidget {
  final String label;
  final CLStatusType type;
  final bool isLarge;

  const CLStatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.isLarge = false,
  });

  Color get _backgroundColor {
    switch (type) {
      case CLStatusType.success:
        return AppColors.success.withValues(alpha: 0.1);
      case CLStatusType.warning:
        return AppColors.warning.withValues(alpha: 0.1);
      case CLStatusType.error:
        return AppColors.error.withValues(alpha: 0.1);
      case CLStatusType.neutral:
        return AppColors.primaryText.withValues(alpha: 0.08);
    }
  }

  Color get _textColor {
    switch (type) {
      case CLStatusType.success:
        return AppColors.success;
      case CLStatusType.warning:
        return AppColors.warning;
      case CLStatusType.error:
        return AppColors.error;
      case CLStatusType.neutral:
        return AppColors.secondaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? AppSpacing.sm : AppSpacing.xs,
        vertical: isLarge ? AppSpacing.xxs + 2 : AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isLarge ? 14.0 : 12.0,
          fontWeight: FontWeight.w500,
          color: _textColor,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

enum CLStatusType { success, warning, error, neutral }
