import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/widgets.dart';
import '../hospital_dashboard/hospital_dashboard_screen.dart';
import '../hospital_verification/hospital_verification_screen.dart';
import '../invoice_upload/invoice_upload_screen.dart';

/// Access Code Login Screen
///
/// No email/password signup
/// No Google login
/// No phone OTP
///
/// Access Method:
/// - Hospital Admin generates one-time role codes
/// - e.g. LUTH-SW-8842
/// - Code is:
///   - Time-limited
///   - Role-bound
///   - Hospital-bound
class AccessCodeLoginScreen extends StatefulWidget {
  const AccessCodeLoginScreen({super.key});

  @override
  State<AccessCodeLoginScreen> createState() => _AccessCodeLoginScreenState();
}

class _AccessCodeLoginScreenState extends State<AccessCodeLoginScreen> {
  final _codeController = TextEditingController();
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter your access code');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    // Use AuthProvider for real authentication
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithAccessCode(code);

    if (!mounted) return;

    if (success) {
      final user = authProvider.currentUser;
      if (user != null) {
        _navigateToRoleScreen(user);
      }
    } else {
      setState(() {
        _isVerifying = false;
        _errorMessage =
            authProvider.errorMessage ?? 'Invalid or expired access code';
      });
    }
  }

  void _navigateToRoleScreen(User user) {
    Widget screen;

    switch (user.role) {
      case UserRole.hospitalAdmin:
        screen = HospitalVerificationScreen(currentUser: user);
        break;
      case UserRole.socialWorker:
        screen = InvoiceUploadScreen(currentUser: user);
        break;
      case UserRole.hospitalFinance:
        screen = HospitalDashboardScreen(currentUser: user);
        break;
      default:
        screen = HospitalDashboardScreen(currentUser: user);
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxxl),

              // Logo / Title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.local_hospital_outlined,
                        size: 40,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'CureLedger',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Hospital Staff Portal',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Access Code Input
              Text(
                'Enter Access Code',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Use the one-time code provided by your hospital administrator',
                style: Theme.of(context).textTheme.bodySmall,
              ),

              const SizedBox(height: AppSpacing.lg),

              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'LUTH-SW-8842',
                  hintStyle: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                        color: AppColors.tertiaryText,
                      ),
                  errorText: _errorMessage,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                ),
                onSubmitted: (_) => _verifyCode(),
              ),

              const SizedBox(height: AppSpacing.lg),

              CLPrimaryButton(
                label: _isVerifying ? 'Verifying...' : 'Continue',
                isLoading: _isVerifying,
                onPressed: _isVerifying ? null : _verifyCode,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Info Section
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppColors.secondaryText,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'How it works',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildInfoItem(
                      context,
                      '1',
                      'Your hospital admin issues a unique access code',
                    ),
                    _buildInfoItem(
                      context,
                      '2',
                      'The code is time-limited and role-specific',
                    ),
                    _buildInfoItem(
                      context,
                      '3',
                      'Enter the code above to access your portal',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Demo codes for testing
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryText.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo Access Codes',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildDemoCode(context, 'LUTH-ADMIN-001', 'Hospital Admin'),
                    _buildDemoCode(context, 'LUTH-SW-8842', 'Social Worker'),
                    _buildDemoCode(context, 'LUTH-FIN-2024', 'Finance Officer'),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primaryText.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.labelLarge),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoCode(BuildContext context, String code, String role) {
    return GestureDetector(
      onTap: () {
        _codeController.text = code;
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                code,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(role, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
