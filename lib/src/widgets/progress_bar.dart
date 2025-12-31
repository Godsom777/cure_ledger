import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Progress bar with real-time updates
/// Apple-like minimal design
class CLProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color? backgroundColor;
  final Color? fillColor;
  final bool showPercentage;
  final bool animate;

  const CLProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.backgroundColor,
    this.fillColor,
    this.showPercentage = false,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.progressBackground,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: animate
                        ? const Duration(milliseconds: 300)
                        : Duration.zero,
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * clampedProgress,
                    height: height,
                    decoration: BoxDecoration(
                      color: fillColor ?? AppColors.progressFill,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '${(clampedProgress * 100).round()}%',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );
  }
}

/// Large progress indicator with amount display
class CLProgressIndicator extends StatelessWidget {
  final double amountPaid;
  final double amountTotal;
  final String? label;

  const CLProgressIndicator({
    super.key,
    required this.amountPaid,
    required this.amountTotal,
    this.label,
  });

  double get progress => amountTotal > 0 ? amountPaid / amountTotal : 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
        ],
        CLProgressBar(progress: progress, height: 10, showPercentage: true),
      ],
    );
  }
}
