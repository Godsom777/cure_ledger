import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Skeleton loader for content loading states
/// Apple-like shimmer effect
class CLSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const CLSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  /// Creates a text skeleton with natural text proportions
  factory CLSkeleton.text({double width = 120, double height = 16}) {
    return CLSkeleton(width: width, height: height, borderRadius: 4);
  }

  /// Creates a circular skeleton (e.g., for avatars)
  factory CLSkeleton.circle({double size = 48}) {
    return CLSkeleton(width: size, height: size, borderRadius: size / 2);
  }

  @override
  State<CLSkeleton> createState() => _CLSkeletonState();
}

class _CLSkeletonState extends State<CLSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                AppColors.primaryText.withValues(alpha: 0.06),
                AppColors.primaryText.withValues(alpha: 0.1),
                AppColors.primaryText.withValues(alpha: 0.06),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton loader for invoice cards
class CLInvoiceCardSkeleton extends StatelessWidget {
  const CLInvoiceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hospital header skeleton
          Row(
            children: [
              CLSkeleton.circle(size: 48),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CLSkeleton.text(width: 150, height: 18),
                  const SizedBox(height: AppSpacing.xxs),
                  CLSkeleton.text(width: 100, height: 14),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Amount skeleton
          CLSkeleton.text(width: 180, height: 28),
          const SizedBox(height: AppSpacing.sm),
          // Progress bar skeleton
          const CLSkeleton(width: double.infinity, height: 10),
          const SizedBox(height: AppSpacing.md),
          // Details skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CLSkeleton.text(width: 80, height: 14),
              CLSkeleton.text(width: 60, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}
