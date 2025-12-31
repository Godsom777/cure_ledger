import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/env_config.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';
import '../../providers/hospital_provider.dart';
import '../../providers/audit_provider.dart';
import 'hospital_management_screen.dart';
import 'audit_logs_screen.dart';
import 'platform_config_screen.dart';

/// Super Admin Dashboard
///
/// Minimal UI for rare, high-privilege interactions.
/// Provides read-only governance overview with navigation to:
/// - Hospital Management (provisioning)
/// - Audit Logs (compliance)
/// - Platform Configuration (financial settings)
class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final hospitalProvider = context.read<HospitalProvider>();
    final auditProvider = context.read<AuditProvider>();

    await Future.wait([
      hospitalProvider.loadHospitals(),
      auditProvider.loadLogs(limit: 10),
    ]);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hospitalProvider = context.watch<HospitalProvider>();
    final auditProvider = context.watch<AuditProvider>();
    final hospitals = hospitalProvider.hospitals;
    final recentLogs = auditProvider.getRecentLogs(3);
    final textTheme = Theme.of(context).textTheme;

    // Calculate system totals from hospital data
    final totalInvoices =
        hospitals.length * 10; // Placeholder - would come from real data
    final totalTransactions = hospitals.length * 25; // Placeholder

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Super Admin',
              style: textTheme.headlineMedium?.copyWith(fontSize: 18),
            ),
            Text(
              'Platform Administrator',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout_outlined,
              color: AppColors.primaryText,
            ),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Platform Overview Card
                    _buildOverviewCard(context, hospitals),

                    const SizedBox(height: AppSpacing.lg),

                    // Quick Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Hospitals',
                            hospitals.length.toString(),
                            Icons.local_hospital_outlined,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Invoices',
                            totalInvoices.toString(),
                            Icons.receipt_long_outlined,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Transactions',
                            totalTransactions.toString(),
                            Icons.payments_outlined,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Admin Actions
                    Text('Administration', style: textTheme.headlineMedium),

                    const SizedBox(height: AppSpacing.md),

                    _buildAdminActionCard(
                      context,
                      icon: Icons.business_outlined,
                      title: 'Hospital Management',
                      subtitle: 'Provision, activate, and manage hospitals',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HospitalManagementScreen(),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    _buildAdminActionCard(
                      context,
                      icon: Icons.history_outlined,
                      title: 'Audit Logs',
                      subtitle: 'View platform activity and compliance logs',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AuditLogsScreen(),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    _buildAdminActionCard(
                      context,
                      icon: Icons.settings_outlined,
                      title: 'Platform Configuration',
                      subtitle: 'Fee percentages and payment gateway settings',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PlatformConfigScreen(),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Recent Audit Activity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: textTheme.headlineMedium,
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AuditLogsScreen(),
                            ),
                          ),
                          child: Text(
                            'View All',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    if (recentLogs.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'No recent activity',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                      )
                    else
                      ...recentLogs.map(
                        (log) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: _buildAuditLogTile(context, log),
                        ),
                      ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, List<Hospital> hospitals) {
    final textTheme = Theme.of(context).textTheme;

    // Calculate from real data
    final activeHospitals = hospitals
        .where((h) => h.status == HospitalStatus.active)
        .length;
    final pendingHospitals = hospitals
        .where((h) => h.status == HospitalStatus.pending)
        .length;

    // Default config values (would come from a config provider in production)
    const platformFeePercentage = 5.0;
    const hospitalSettlementPercentage = 95.0;
    final isTestMode = !EnvConfig.isProduction;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_outlined,
                color: AppColors.primaryText,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('Platform Overview', style: textTheme.titleMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: isTestMode
                      ? AppColors.warning.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  isTestMode ? 'Test Mode' : 'Live',
                  style: textTheme.bodySmall?.copyWith(
                    color: isTestMode ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Hospital status breakdown
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Hospitals',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      activeHospitals.toString(),
                      style: textTheme.headlineMedium?.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Activation',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      pendingHospitals.toString(),
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 20,
                        color: pendingHospitals > 0 ? AppColors.warning : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Container(height: 1, color: AppColors.border),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hospital Settlement',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${hospitalSettlementPercentage.toInt()}%',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform Fee',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${platformFeePercentage.toInt()}%',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.secondaryText, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: textTheme.headlineMedium),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, color: AppColors.primaryText, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.secondaryText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuditLogTile(BuildContext context, AuditLog log) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: _getActionColor(log.action).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              _getActionIcon(log.action),
              color: _getActionColor(log.action),
              size: 16,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.action.displayName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${log.actorName} • ${_formatTime(log.timestamp)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(AuditAction action) {
    switch (action) {
      case AuditAction.hospitalCreated:
      case AuditAction.hospitalActivated:
      case AuditAction.hospitalUnsuspended:
        return Icons.add_business;
      case AuditAction.hospitalSuspended:
      case AuditAction.hospitalFlagged:
        return Icons.block;
      case AuditAction.adminAssigned:
      case AuditAction.adminRevoked:
      case AuditAction.adminAccessReset:
        return Icons.person;
      case AuditAction.invoiceCreated:
      case AuditAction.invoiceVerified:
      case AuditAction.invoiceRejected:
        return Icons.receipt_long;
      case AuditAction.paymentReceived:
      case AuditAction.paymentSettled:
        return Icons.payments;
      case AuditAction.platformFeeChanged:
      case AuditAction.paymentGatewayConfigured:
        return Icons.settings;
      case AuditAction.disputeEscalated:
        return Icons.flag;
    }
  }

  Color _getActionColor(AuditAction action) {
    switch (action) {
      case AuditAction.hospitalCreated:
      case AuditAction.hospitalActivated:
      case AuditAction.hospitalUnsuspended:
      case AuditAction.paymentReceived:
      case AuditAction.paymentSettled:
      case AuditAction.invoiceVerified:
        return AppColors.success;
      case AuditAction.hospitalSuspended:
      case AuditAction.hospitalFlagged:
      case AuditAction.invoiceRejected:
      case AuditAction.disputeEscalated:
        return AppColors.error;
      case AuditAction.adminAssigned:
      case AuditAction.adminRevoked:
      case AuditAction.adminAccessReset:
      case AuditAction.platformFeeChanged:
      case AuditAction.paymentGatewayConfigured:
        return AppColors.warning;
      case AuditAction.invoiceCreated:
        return AppColors.secondaryText;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 30) {
      return '${time.day}/${time.month}/${time.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    }
    return 'Just now';
  }
}
