import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Hospital identity header with logo and name
/// Always visible on donor-facing screens
class CLHospitalHeader extends StatelessWidget {
  final String hospitalName;
  final String? logoUrl;
  final bool isVerified;
  final bool compact;

  const CLHospitalHeader({
    super.key,
    required this.hospitalName,
    this.logoUrl,
    required this.isVerified,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Hospital Logo
        Container(
          width: compact ? 40 : 48,
          height: compact ? 40 : 48,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(compact ? 8 : 10),
            border: Border.all(color: AppColors.divider),
          ),
          child: logoUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(compact ? 7 : 9),
                  child: Image.network(
                    logoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  ),
                )
              : _buildPlaceholder(),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Hospital Name & Verification
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hospitalName,
                style: compact
                    ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )
                    : Theme.of(context).textTheme.headlineMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isVerified) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.verified,
                      size: compact ? 12 : 14,
                      color: AppColors.verified,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Verified Hospital',
                      style: TextStyle(
                        fontSize: compact ? 11 : 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.verified,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.local_hospital_outlined,
        size: compact ? 20 : 24,
        color: AppColors.secondaryText,
      ),
    );
  }
}
