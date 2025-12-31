import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';

/// Platform Configuration Screen for Super Admin
///
/// Allows configuration of:
/// - Platform fee percentage (default 5%)
/// - Hospital settlement percentage (default 95%)
/// - Payment gateway settings (Paystack)
///
/// Changes are logged to audit trail.
class PlatformConfigScreen extends StatefulWidget {
  const PlatformConfigScreen({super.key});

  @override
  State<PlatformConfigScreen> createState() => _PlatformConfigScreenState();
}

class _PlatformConfigScreenState extends State<PlatformConfigScreen> {
  late PlatformConfig _config;
  bool _isEditing = false;

  late TextEditingController _platformFeeController;
  late TextEditingController _publicKeyController;

  @override
  void initState() {
    super.initState();
    // Initialize with default config - in production, load from API
    _config = PlatformConfig(
      id: 'default',
      platformFeePercentage: 5.0,
      hospitalSettlementPercentage: 95.0,
      paystackPublicKey: '',
      paystackSecretKeyHint: '',
      paystackTestMode: true,
      lastUpdated: DateTime.now(),
      lastUpdatedBy: 'System',
    );
    _platformFeeController = TextEditingController(
      text: _config.platformFeePercentage.toString(),
    );
    _publicKeyController = TextEditingController(
      text: _config.paystackPublicKey,
    );
  }

  @override
  void dispose() {
    _platformFeeController.dispose();
    _publicKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        title: Text('Platform Configuration', style: textTheme.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primaryText,
              ),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit',
            )
          else ...[
            IconButton(
              icon: Icon(Icons.close, color: AppColors.secondaryText),
              onPressed: _cancelEditing,
              tooltip: 'Cancel',
            ),
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.success),
              onPressed: _saveChanges,
              tooltip: 'Save',
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fee Configuration Card
            _buildSectionCard(
              context,
              title: 'Fee Configuration',
              icon: Icons.percent,
              child: Column(
                children: [
                  _buildConfigRow(
                    context,
                    label: 'Platform Fee',
                    value: '${_config.platformFeePercentage}%',
                    subtitle: 'Percentage retained by CureLedger',
                    isEditable: _isEditing,
                    controller: _platformFeeController,
                    suffix: '%',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(height: 1, color: AppColors.divider),
                  const SizedBox(height: AppSpacing.md),
                  _buildConfigRow(
                    context,
                    label: 'Hospital Settlement',
                    value: '${_config.hospitalSettlementPercentage}%',
                    subtitle: 'Percentage sent to hospitals',
                    isEditable: false, // Auto-calculated
                    helperText: _isEditing
                        ? 'Auto-calculated (100% - Platform Fee)'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(height: 1, color: AppColors.divider),
                  const SizedBox(height: AppSpacing.md),
                  _buildValidationRow(context),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Payment Gateway Card
            _buildSectionCard(
              context,
              title: 'Payment Gateway',
              icon: Icons.payment,
              child: Column(
                children: [
                  _buildConfigRow(
                    context,
                    label: 'Provider',
                    value: 'Paystack',
                    subtitle: 'Nigerian payment gateway',
                    isEditable: false,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(height: 1, color: AppColors.divider),
                  const SizedBox(height: AppSpacing.md),
                  _buildConfigRow(
                    context,
                    label: 'Public Key',
                    value: _config.paystackPublicKey,
                    subtitle: 'Used for client-side initialization',
                    isEditable: _isEditing,
                    controller: _publicKeyController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(height: 1, color: AppColors.divider),
                  const SizedBox(height: AppSpacing.md),
                  _buildConfigRow(
                    context,
                    label: 'Secret Key',
                    value: _config.paystackSecretKeyHint,
                    subtitle: 'Stored securely, not displayed',
                    isEditable: false,
                    isSecure: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(height: 1, color: AppColors.divider),
                  const SizedBox(height: AppSpacing.md),
                  _buildModeToggle(context),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Last Updated Info
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.secondaryText,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Last updated: ${_formatDate(_config.lastUpdated)} by ${_config.lastUpdatedBy}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Warning notice
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuration Changes',
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Changes to fee percentages or gateway settings will be logged to the audit trail and may affect ongoing transactions. Ensure all changes are reviewed before saving.',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryText, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: textTheme.titleMedium),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.divider),
          Padding(padding: const EdgeInsets.all(AppSpacing.md), child: child),
        ],
      ),
    );
  }

  Widget _buildConfigRow(
    BuildContext context, {
    required String label,
    required String value,
    required String subtitle,
    bool isEditable = false,
    TextEditingController? controller,
    String? suffix,
    String? helperText,
    bool isSecure = false,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              if (helperText != null) ...[
                const SizedBox(height: 4),
                Text(
                  helperText,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: isEditable && controller != null
              ? TextField(
                  controller: controller,
                  keyboardType: suffix == '%'
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.text,
                  decoration: InputDecoration(
                    suffixText: suffix,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    isSecure ? value : value,
                    style: textTheme.bodyMedium?.copyWith(
                      fontFamily: isSecure ? 'monospace' : null,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildValidationRow(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final platformFee = double.tryParse(_platformFeeController.text) ?? 0;
    final hospitalSettlement = 100 - platformFee;
    final isValid =
        platformFee > 0 && platformFee <= 20 && hospitalSettlement >= 80;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isValid
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.error,
            color: isValid ? AppColors.success : AppColors.error,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              isValid
                  ? 'Valid: $platformFee% platform + $hospitalSettlement% hospital = 100%'
                  : 'Invalid: Platform fee must be between 0-20%',
              style: textTheme.bodySmall?.copyWith(
                color: isValid ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Environment Mode', style: textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(
                _config.paystackTestMode
                    ? 'Test mode - no real transactions'
                    : 'Live mode - real transactions',
                style: textTheme.bodySmall?.copyWith(
                  color: _config.paystackTestMode
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _config.paystackTestMode
                ? AppColors.warning.withValues(alpha: 0.1)
                : AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Text(
            _config.paystackTestMode ? 'TEST' : 'LIVE',
            style: textTheme.bodySmall?.copyWith(
              color: _config.paystackTestMode
                  ? AppColors.warning
                  : AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _platformFeeController.text = _config.platformFeePercentage.toString();
      _publicKeyController.text = _config.paystackPublicKey;
    });
  }

  void _saveChanges() {
    final platformFee = double.tryParse(_platformFeeController.text);

    if (platformFee == null || platformFee <= 0 || platformFee > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Platform fee must be between 0-20%'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Changes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('You are about to update the platform configuration:'),
            const SizedBox(height: AppSpacing.md),
            Text(
              '• Platform Fee: ${_config.platformFeePercentage}% → $platformFee%',
            ),
            Text(
              '• Hospital Settlement: ${_config.hospitalSettlementPercentage}% → ${100 - platformFee}%',
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'This change will be logged and may affect ongoing transactions.',
              style: TextStyle(color: AppColors.warning),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _config = _config.copyWith(
                  platformFeePercentage: platformFee,
                  hospitalSettlementPercentage: 100 - platformFee,
                  paystackPublicKey: _publicKeyController.text,
                  lastUpdated: DateTime.now(),
                  lastUpdatedBy: 'Super Admin',
                );
                _isEditing = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuration updated successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
