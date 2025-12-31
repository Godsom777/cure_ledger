import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';
import '../../providers/hospital_provider.dart';

/// Hospital Management Screen for Super Admin
///
/// Allows:
/// - View all hospitals (list with status)
/// - Create new hospital (provisioning)
/// - Activate/Suspend hospitals
/// - View hospital details
///
/// Does NOT allow:
/// - Modifying invoices
/// - Accessing patient data
/// - Processing payments
class HospitalManagementScreen extends StatefulWidget {
  const HospitalManagementScreen({super.key});

  @override
  State<HospitalManagementScreen> createState() =>
      _HospitalManagementScreenState();
}

class _HospitalManagementScreenState extends State<HospitalManagementScreen> {
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    // Load hospitals if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HospitalProvider>().loadHospitals();
    });
  }

  List<Hospital> _getFilteredHospitals(List<Hospital> hospitals) {
    if (_filterStatus == 'all') return hospitals;
    return hospitals.where((h) {
      switch (_filterStatus) {
        case 'active':
          return h.status == HospitalStatus.active;
        case 'pending':
          return h.status == HospitalStatus.pending;
        case 'suspended':
          return h.status == HospitalStatus.suspended;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hospitalProvider = context.watch<HospitalProvider>();
    final hospitals = hospitalProvider.hospitals;
    final filteredHospitals = _getFilteredHospitals(hospitals);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        title: Text('Hospital Management', style: textTheme.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primaryText),
            onPressed: _showCreateHospitalDialog,
            tooltip: 'Add Hospital',
          ),
        ],
      ),
      body: hospitalProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter chips
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'All'),
                        const SizedBox(width: AppSpacing.xs),
                        _buildFilterChip('active', 'Active'),
                        const SizedBox(width: AppSpacing.xs),
                        _buildFilterChip('pending', 'Pending'),
                        const SizedBox(width: AppSpacing.xs),
                        _buildFilterChip('suspended', 'Suspended'),
                      ],
                    ),
                  ),
                ),

                // Hospital list
                Expanded(
                  child: filteredHospitals.isEmpty
                      ? Center(
                          child: Text(
                            'No hospitals found',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          itemCount: filteredHospitals.length,
                          itemBuilder: (context, index) {
                            final hospital = filteredHospitals[index];
                            return _buildHospitalCard(context, hospital);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filterStatus == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = selected ? value : 'all';
        });
      },
      backgroundColor: AppColors.cardBackground,
      selectedColor: AppColors.primaryText,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.white : AppColors.primaryText,
      ),
      checkmarkColor: AppColors.white,
      side: BorderSide(color: AppColors.border),
    );
  }

  Widget _buildHospitalCard(BuildContext context, Hospital hospital) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showHospitalDetails(hospital),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Hospital Logo/Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Center(
                    child: hospital.logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                            child: Image.network(
                              hospital.logoUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            hospital.code.substring(0, 2),
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Hospital Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              hospital.name,
                              style: textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hospital.isVerified)
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: AppColors.verified,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Row(
                        children: [
                          Text(
                            hospital.code,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _buildStatusBadge(hospital.status),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppColors.secondaryText),
                  onSelected: (value) => _handleHospitalAction(hospital, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 20),
                          SizedBox(width: AppSpacing.sm),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    if (hospital.status == HospitalStatus.pending)
                      const PopupMenuItem(
                        value: 'activate',
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 20,
                              color: AppColors.success,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text('Activate'),
                          ],
                        ),
                      ),
                    if (hospital.status == HospitalStatus.active)
                      const PopupMenuItem(
                        value: 'suspend',
                        child: Row(
                          children: [
                            Icon(
                              Icons.pause_circle_outline,
                              size: 20,
                              color: AppColors.warning,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text('Suspend'),
                          ],
                        ),
                      ),
                    if (hospital.status == HospitalStatus.suspended)
                      const PopupMenuItem(
                        value: 'unsuspend',
                        child: Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 20,
                              color: AppColors.success,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text('Unsuspend'),
                          ],
                        ),
                      ),
                    if (hospital.status != HospitalStatus.flagged)
                      const PopupMenuItem(
                        value: 'flag',
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              size: 20,
                              color: AppColors.error,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text('Flag for Review'),
                          ],
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

  Widget _buildStatusBadge(HospitalStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case HospitalStatus.active:
        bgColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        label = 'Active';
        break;
      case HospitalStatus.pending:
        bgColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
        label = 'Pending';
        break;
      case HospitalStatus.suspended:
        bgColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        label = 'Suspended';
        break;
      case HospitalStatus.flagged:
        bgColor = AppColors.error.withValues(alpha: 0.2);
        textColor = AppColors.error;
        label = 'Flagged';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  void _handleHospitalAction(Hospital hospital, String action) {
    switch (action) {
      case 'view':
        _showHospitalDetails(hospital);
        break;
      case 'activate':
        _showConfirmationDialog(
          'Activate Hospital',
          'Are you sure you want to activate ${hospital.name}?',
          () {
            // In real app, this would call an API
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${hospital.name} activated')),
            );
          },
        );
        break;
      case 'suspend':
        _showConfirmationDialog(
          'Suspend Hospital',
          'Are you sure you want to suspend ${hospital.name}? This will prevent new invoices and payments.',
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${hospital.name} suspended')),
            );
          },
        );
        break;
      case 'unsuspend':
        _showConfirmationDialog(
          'Unsuspend Hospital',
          'Are you sure you want to unsuspend ${hospital.name}?',
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${hospital.name} unsuspended')),
            );
          },
        );
        break;
      case 'flag':
        _showConfirmationDialog(
          'Flag Hospital',
          'Are you sure you want to flag ${hospital.name} for review? This will trigger a compliance audit.',
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${hospital.name} flagged for review')),
            );
          },
        );
        break;
    }
  }

  void _showConfirmationDialog(
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showHospitalDetails(Hospital hospital) {
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
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

              // Hospital header
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Center(
                      child: Text(
                        hospital.code.substring(0, 2),
                        style: textTheme.headlineMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hospital.name, style: textTheme.headlineMedium),
                        const SizedBox(height: AppSpacing.xxs),
                        Row(
                          children: [
                            Text(hospital.code, style: textTheme.bodySmall),
                            const SizedBox(width: AppSpacing.sm),
                            _buildStatusBadge(hospital.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Details section
              _buildDetailSection('Address', hospital.address),
              _buildDetailSection('Bank Name', hospital.bankName),
              _buildDetailSection(
                'Account Number',
                _maskAccountNumber(hospital.bankAccountNumber),
              ),
              _buildDetailSection(
                'Paystack Subaccount',
                hospital.paystackSubaccountCode,
              ),
              _buildDetailSection(
                'Created',
                hospital.createdAt.toString().substring(0, 10),
              ),

              if (hospital.status == HospitalStatus.flagged) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: AppColors.error),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'This hospital is flagged for compliance review',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String label, String value) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length < 4) return accountNumber;
    return '****${accountNumber.substring(accountNumber.length - 4)}';
  }

  void _showCreateHospitalDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final addressController = TextEditingController();
    final bankNameController = TextEditingController();
    final accountNumberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Hospital'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Hospital Name',
                  hintText: 'e.g., Lagos University Teaching Hospital',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Hospital Code',
                  hintText: 'e.g., LUTH',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: bankNameController,
                decoration: const InputDecoration(labelText: 'Bank Name'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Bank Account Number',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // In real app, validate and create hospital via API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hospital created (demo only)')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
