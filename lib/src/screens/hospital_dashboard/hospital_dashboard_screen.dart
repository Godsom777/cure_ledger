import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/invoice_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/widgets.dart';

/// Screen 7: Hospital Dashboard
/// User: Hospital Finance
/// Purpose: Reconciliation
///
/// Elements:
/// - total_received
/// - invoice_level_breakdown
/// - settlement_timestamps
/// - bank_narration
/// - export_reports
class HospitalDashboardScreen extends StatefulWidget {
  final User currentUser;

  const HospitalDashboardScreen({super.key, required this.currentUser});

  @override
  State<HospitalDashboardScreen> createState() =>
      _HospitalDashboardScreenState();
}

class _HospitalDashboardScreenState extends State<HospitalDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<Payment> _recentPayments = [];
  List<Invoice> _invoices = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final invoiceProvider = context.read<InvoiceProvider>();
    await invoiceProvider.loadHospitalInvoices(widget.currentUser.hospitalId!);

    if (!mounted) return;

    final invoices = invoiceProvider.invoices;

    // Calculate stats from real data
    final totalReceived = invoices.fold<double>(
      0,
      (sum, inv) => sum + inv.amountPaid,
    );
    final pendingCount = invoices
        .where((i) => i.status == InvoiceStatus.pending)
        .length;
    final verifiedCount = invoices
        .where((i) => i.status == InvoiceStatus.verified)
        .length;

    setState(() {
      _stats = {
        'totalReceived': totalReceived,
        'pendingCount': pendingCount,
        'verifiedCount': verifiedCount,
        'invoiceCount': invoices.length,
      };
      _recentPayments = []; // TODO: Load from payment repository when available
      _invoices = invoices;
      _isLoading = false;
    });
  }

  void _exportReports() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Generating report...')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: _exportReports,
            tooltip: 'Export Reports',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total Received Card
                      CLCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Received',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const CLVerifiedBadge(label: 'Settled'),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              CurrencyFormatter.format(
                                _stats['totalReceived'] ?? 0,
                              ),
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              '${_stats['totalPayments'] ?? 0} payments received',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Stats Grid
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Active Invoices',
                              value: '${_stats['activeInvoices'] ?? 0}',
                              icon: Icons.receipt_long_outlined,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _StatCard(
                              label: 'Pending Review',
                              value: '${_stats['pendingVerification'] ?? 0}',
                              icon: Icons.pending_outlined,
                              valueColor: AppColors.warning,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Fully Paid',
                              value: '${_stats['fullyPaid'] ?? 0}',
                              icon: Icons.check_circle_outline,
                              valueColor: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _StatCard(
                              label: 'Total Invoices',
                              value: '${_stats['totalInvoices'] ?? 0}',
                              icon: Icons.folder_outlined,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Recent Payments Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Payments',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          CLTextButton(
                            label: 'View All',
                            icon: Icons.arrow_forward_ios,
                            iconAfter: true,
                            onPressed: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      CLCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            // Table Header
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.background.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppSpacing.radiusMd),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Bank Narration',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Amount',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Status',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Table Rows
                            ..._recentPayments.map((payment) {
                              return _PaymentRow(payment: payment);
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Invoice Breakdown Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Invoice Breakdown',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          CLTextButton(
                            label: 'Export',
                            icon: Icons.download_outlined,
                            onPressed: _exportReports,
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      ...(_invoices.map((invoice) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _InvoiceBreakdownCard(invoice: invoice),
                        );
                      })),

                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return CLCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: AppColors.secondaryText),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final Payment payment;

  const _PaymentRow({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.bankNarration,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  payment.settledAt != null
                      ? DateFormatter.formatDateTime(payment.settledAt!)
                      : 'Pending',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              CurrencyFormatter.formatNoDecimal(payment.hospitalSettlement),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: CLStatusBadge(
                label: payment.isSettled ? 'Cleared' : 'Pending',
                type: payment.isSettled
                    ? CLStatusType.success
                    : CLStatusType.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceBreakdownCard extends StatelessWidget {
  final Invoice invoice;

  const _InvoiceBreakdownCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return CLCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                invoice.id,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              CLStatusBadge(
                label: invoice.status.displayName,
                type: invoice.isFullyPaid
                    ? CLStatusType.success
                    : CLStatusType.neutral,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          CLProgressBar(progress: invoice.progressPercentage, height: 8),

          const SizedBox(height: AppSpacing.md),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(
                context,
                'Received',
                CurrencyFormatter.formatCompact(invoice.amountPaid * 0.95),
                AppColors.success,
              ),
              _buildStat(
                context,
                'Balance',
                CurrencyFormatter.formatCompact(invoice.balanceRemaining),
                AppColors.primaryText,
              ),
              _buildStat(
                context,
                'Total',
                CurrencyFormatter.formatCompact(invoice.amountTotal),
                AppColors.secondaryText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
