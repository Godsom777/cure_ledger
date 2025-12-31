import '../core/result.dart';
import '../core/logger.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

/// Repository for invoice data operations
class InvoiceRepository {
  /// Get invoice by ID (public access for donors)
  Future<Result<Invoice>> getInvoiceById(String id) async {
    try {
      final response = await SupabaseService.client
          .from('invoices')
          .select('''
            *,
            hospital:hospitals(id, name, code, logo_url, is_verified, paystack_subaccount_code)
          ''')
          .eq('id', id)
          .single();

      return Success(Invoice.fromJson(response));
    } catch (e, stackTrace) {
      AppLogger.e('Failed to fetch invoice: $id', e, stackTrace);
      return Failure(
        NotFoundException(
          'Invoice not found',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Get invoices for a hospital
  Future<Result<List<Invoice>>> getHospitalInvoices(
    String hospitalId, {
    InvoiceStatus? status,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = SupabaseService.client
          .from('invoices')
          .select('''
            *,
            hospital:hospitals(id, name, code)
          ''')
          .eq('hospital_id', hospitalId);

      if (status != null) {
        query = query.eq('status', status.name);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final invoices = (response as List)
          .map((json) => Invoice.fromJson(json))
          .toList();

      return Success(invoices);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to fetch hospital invoices', e, stackTrace);
      return Failure(
        NetworkException(
          'Failed to load invoices',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Get pending invoices for verification
  Future<Result<List<Invoice>>> getPendingInvoices(String hospitalId) async {
    return getHospitalInvoices(hospitalId, status: InvoiceStatus.pending);
  }

  /// Create new invoice (Hospital staff only)
  Future<Result<Invoice>> createInvoice({
    required String hospitalId,
    required String patientInitials,
    required String description,
    required double amount,
    required String createdById,
    String? wardType,
    String? department,
  }) async {
    try {
      // Generate invoice ID: INV-XXXX
      final invoiceId =
          'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final invoiceData = {
        'id': invoiceId,
        'hospital_id': hospitalId,
        'patient_initials': patientInitials,
        'description': description,
        'amount_total': amount,
        'amount_paid': 0.0,
        'status': InvoiceStatus.pending.name,
        'created_at': DateTime.now().toIso8601String(),
        'uploaded_by_id': createdById,
        'ward_type': wardType,
        'department': department,
      };

      final response = await SupabaseService.client
          .from('invoices')
          .insert(invoiceData)
          .select('''
            *,
            hospital:hospitals(id, name, code)
          ''')
          .single();

      AppLogger.i('Invoice created: $invoiceId');
      return Success(Invoice.fromJson(response));
    } catch (e, stackTrace) {
      AppLogger.e('Failed to create invoice', e, stackTrace);
      return Failure(
        NetworkException(
          'Failed to create invoice',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Update invoice status (verification)
  Future<Result<Invoice>> updateInvoiceStatus(
    String id, {
    required InvoiceStatus status,
    String? verifiedById,
    String? rejectionReason,
  }) async {
    try {
      final updateData = {
        'status': status.name,
        if (status == InvoiceStatus.verified) ...{
          'verified_at': DateTime.now().toIso8601String(),
          'verified_by_id': verifiedById,
        },
        if (status == InvoiceStatus.rejected) ...{
          'rejection_reason': rejectionReason,
        },
      };

      final response = await SupabaseService.client
          .from('invoices')
          .update(updateData)
          .eq('id', id)
          .select('''
            *,
            hospital:hospitals(id, name, code)
          ''')
          .single();

      AppLogger.i('Invoice status updated: $id -> ${status.name}');
      return Success(Invoice.fromJson(response));
    } catch (e, stackTrace) {
      AppLogger.e('Failed to update invoice status', e, stackTrace);
      return Failure(
        NetworkException(
          'Failed to update invoice',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Record payment on invoice
  Future<Result<Invoice>> recordPayment(
    String id, {
    required double amount,
    required String paymentReference,
  }) async {
    try {
      // Get current invoice
      final currentResult = await getInvoiceById(id);
      if (currentResult is Failure) {
        return currentResult;
      }

      final current = (currentResult as Success<Invoice>).data;
      final newAmountPaid = current.amountPaid + amount;
      final isFullyPaid = newAmountPaid >= current.amountTotal;

      final updateData = {
        'amount_paid': newAmountPaid,
        'status': isFullyPaid
            ? InvoiceStatus.fullyPaid.name
            : InvoiceStatus.partiallyPaid.name,
        if (isFullyPaid) 'paid_at': DateTime.now().toIso8601String(),
      };

      final response = await SupabaseService.client
          .from('invoices')
          .update(updateData)
          .eq('id', id)
          .select('''
            *,
            hospital:hospitals(id, name, code)
          ''')
          .single();

      AppLogger.i('Payment recorded on invoice: $id, amount: $amount');
      return Success(Invoice.fromJson(response));
    } catch (e, stackTrace) {
      AppLogger.e('Failed to record payment', e, stackTrace);
      return Failure(
        NetworkException(
          'Failed to record payment',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
