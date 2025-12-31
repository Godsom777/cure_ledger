import 'package:flutter/foundation.dart';
import '../core/result.dart';
import '../models/models.dart';
import '../repositories/invoice_repository.dart';

/// Invoice state provider
class InvoiceProvider extends ChangeNotifier {
  final InvoiceRepository _repository;

  InvoiceProvider(this._repository);

  List<Invoice> _invoices = [];
  Invoice? _currentInvoice;
  bool _isLoading = false;
  String? _errorMessage;

  List<Invoice> get invoices => _invoices;
  Invoice? get currentInvoice => _currentInvoice;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load invoice by ID (for donor view)
  Future<void> loadInvoice(String id) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.getInvoiceById(id);

    if (result is Success<Invoice>) {
      _currentInvoice = result.data;
    } else {
      _errorMessage = (result as Failure).error.message;
      _currentInvoice = null;
    }

    _setLoading(false);
  }

  /// Load invoices for hospital
  Future<void> loadHospitalInvoices(
    String hospitalId, {
    InvoiceStatus? status,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.getHospitalInvoices(
      hospitalId,
      status: status,
    );

    if (result is Success<List<Invoice>>) {
      _invoices = result.data;
    } else {
      _errorMessage = (result as Failure).error.message;
      _invoices = [];
    }

    _setLoading(false);
  }

  /// Load pending invoices for verification
  Future<void> loadPendingInvoices(String hospitalId) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.getPendingInvoices(hospitalId);

    if (result is Success<List<Invoice>>) {
      _invoices = result.data;
    } else {
      _errorMessage = (result as Failure).error.message;
      _invoices = [];
    }

    _setLoading(false);
  }

  /// Create new invoice
  Future<bool> createInvoice({
    required String hospitalId,
    required String patientInitials,
    required String description,
    required double amount,
    required String createdById,
    String? wardType,
    String? department,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.createInvoice(
      hospitalId: hospitalId,
      patientInitials: patientInitials,
      description: description,
      amount: amount,
      createdById: createdById,
      wardType: wardType,
      department: department,
    );

    if (result is Success<Invoice>) {
      _invoices.insert(0, result.data);
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _errorMessage = (result as Failure).error.message;
      _setLoading(false);
      return false;
    }
  }

  /// Verify invoice
  Future<bool> verifyInvoice(String id, String verifiedById) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.updateInvoiceStatus(
      id,
      status: InvoiceStatus.verified,
      verifiedById: verifiedById,
    );

    if (result is Success<Invoice>) {
      _updateInvoiceInList(result.data);
      _setLoading(false);
      return true;
    } else {
      _errorMessage = (result as Failure).error.message;
      _setLoading(false);
      return false;
    }
  }

  /// Reject invoice
  Future<bool> rejectInvoice(String id, String reason) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.updateInvoiceStatus(
      id,
      status: InvoiceStatus.rejected,
      rejectionReason: reason,
    );

    if (result is Success<Invoice>) {
      _updateInvoiceInList(result.data);
      _setLoading(false);
      return true;
    } else {
      _errorMessage = (result as Failure).error.message;
      _setLoading(false);
      return false;
    }
  }

  /// Clear current invoice
  void clearCurrentInvoice() {
    _currentInvoice = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _updateInvoiceInList(Invoice updated) {
    final index = _invoices.indexWhere((inv) => inv.id == updated.id);
    if (index != -1) {
      _invoices[index] = updated;
    }
    if (_currentInvoice?.id == updated.id) {
      _currentInvoice = updated;
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
