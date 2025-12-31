import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';
import '../../providers/audit_provider.dart';

/// Audit Logs Screen for Super Admin
///
/// Read-only view of all platform activity.
/// Supports:
/// - Filtering by action category
/// - Search by actor or hospital
/// - Export logs (simulated)
///
/// Cannot modify logs - read-only for compliance.
class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  String _filterCategory = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditProvider>().loadLogs();
    });
  }

  List<AuditLog> _getFilteredLogs(List<AuditLog> logs) {
    var filteredLogs = List<AuditLog>.from(logs);

    // Filter by category
    if (_filterCategory != 'all') {
      filteredLogs = filteredLogs
          .where((log) => log.action.category == _filterCategory)
          .toList();
    }

    // Filter by search
    final search = _searchController.text.toLowerCase();
    if (search.isNotEmpty) {
      filteredLogs = filteredLogs
          .where(
            (log) =>
                log.actorName.toLowerCase().contains(search) ||
                (log.hospitalName?.toLowerCase().contains(search) ?? false) ||
                log.action.displayName.toLowerCase().contains(search),
          )
          .toList();
    }

    // Sort by most recent
    filteredLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return filteredLogs;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final auditProvider = context.watch<AuditProvider>();
    final filteredLogs = _getFilteredLogs(auditProvider.logs);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        title: Text('Audit Logs', style: textTheme.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.download_outlined,
              color: AppColors.primaryText,
            ),
            onPressed: _exportLogs,
            tooltip: 'Export Logs',
          ),
        ],
      ),
      body: auditProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by actor or hospital...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),

                // Filter chips
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'All'),
                        const SizedBox(width: AppSpacing.xs),
                        _buildFilterChip('Hospital Management', 'Hospitals'),
                        const SizedBox(width: AppSpacing.xs),
                        _buildFilterChip('Access Control', 'Access'),
                        const SizedBox(width: AppSpacing.xs),
                        _buildFilterChip('Configuration', 'Config'),
                        const SizedBox(width: AppSpacing.xs),
                        _buildFilterChip('Invoice Activity', 'Invoices'),
                        const SizedBox(width: AppSpacing.xs),
                        _buildFilterChip('Payment Activity', 'Payments'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Results count
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${filteredLogs.length} entries',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Log list
                Expanded(
                  child: filteredLogs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history_outlined,
                                size: 48,
                                color: AppColors.secondaryText,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'No logs found',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          itemCount: filteredLogs.length,
                          itemBuilder: (context, index) {
                            final log = filteredLogs[index];
                            return _buildLogEntry(context, log);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filterCategory == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterCategory = selected ? value : 'all';
        });
      },
      backgroundColor: AppColors.cardBackground,
      selectedColor: AppColors.primaryText,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.white : AppColors.primaryText,
        fontSize: 12,
      ),
      checkmarkColor: AppColors.white,
      side: BorderSide(color: AppColors.border),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildLogEntry(BuildContext context, AuditLog log) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogDetails(log),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _getActionColor(log.action).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    _getActionIcon(log.action),
                    color: _getActionColor(log.action),
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Log content
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
                      const SizedBox(height: 2),
                      Text(
                        log.actorName,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      if (log.hospitalName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          log.hospitalName!,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Timestamp
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(log.timestamp),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      _formatTime(log.timestamp),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogDetails(AuditLog log) {
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getActionColor(log.action).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    _getActionIcon(log.action),
                    color: _getActionColor(log.action),
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.action.displayName,
                        style: textTheme.headlineMedium,
                      ),
                      Text(
                        log.action.category,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Details
            _buildDetailRow('Actor', log.actorName),
            _buildDetailRow('Actor ID', log.actorId),
            if (log.hospitalName != null)
              _buildDetailRow('Hospital', log.hospitalName!),
            if (log.hospitalId != null)
              _buildDetailRow('Hospital ID', log.hospitalId!),
            if (log.targetType != null)
              _buildDetailRow('Target Type', log.targetType!),
            if (log.targetId != null)
              _buildDetailRow('Target ID', log.targetId!),
            _buildDetailRow(
              'Timestamp',
              '${_formatDate(log.timestamp)} ${_formatTime(log.timestamp)}',
            ),
            if (log.ipAddress != null)
              _buildDetailRow('IP Address', log.ipAddress!),
            if (log.metadata != null && log.metadata!.isNotEmpty)
              _buildDetailRow('Metadata', log.metadata.toString()),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ),
          Expanded(child: Text(value, style: textTheme.bodyMedium)),
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

  String _formatDate(DateTime time) {
    return '${time.day}/${time.month}/${time.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _exportLogs() {
    // Simulate export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export initiated. CSV will be sent to your email.'),
      ),
    );
  }
}
