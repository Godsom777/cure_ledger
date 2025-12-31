import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/widgets.dart';
import '../access_code_login/access_code_login_screen.dart';
import '../invoice_landing/invoice_landing_screen.dart';
import '../super_admin/super_admin_dashboard_screen.dart';

/// Home screen for CureLedger
/// Provides navigation to donor view or staff portal
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openDonorView(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const InvoiceLandingScreen()));
  }

  void _openStaffPortal(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AccessCodeLoginScreen()));
  }

  void _openSuperAdmin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SuperAdminDashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            children: [
              const Spacer(),

              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_hospital_outlined,
                  size: 48,
                  color: AppColors.primaryText,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Title
              Text(
                'CureLedger',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Medical payment rail for settling\nverified hospital invoices directly',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Core Principle
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: const Icon(
                        Icons.verified_outlined,
                        color: AppColors.success,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Direct Hospital Settlement',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Funds never touch patients. All payments go directly to hospital accounts.',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Action Buttons
              CLPrimaryButton(
                label: 'I want to help pay a bill',
                onPressed: () => _openDonorView(context),
              ),

              const SizedBox(height: AppSpacing.md),

              CLSecondaryButton(
                label: 'Hospital Staff Portal',
                icon: Icons.lock_outline,
                onPressed: () => _openStaffPortal(context),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Footer
              Text(
                'No gamification. No storytelling. Just payments.',
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.md),

              // Super Admin (Demo Access - would be protected in production)
              GestureDetector(
                onTap: () => _openSuperAdmin(context),
                child: Text(
                  'Admin Portal',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.tertiaryText,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
