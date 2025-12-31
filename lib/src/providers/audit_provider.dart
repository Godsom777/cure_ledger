import 'package:flutter/foundation.dart';
import '../core/result.dart';
import '../models/models.dart';
import '../repositories/audit_repository.dart';

/// Audit logs state provider (Super Admin only)
class AuditProvider extends ChangeNotifier {
  final AuditRepository _repository;

  AuditProvider(this._repository);

  List<AuditLog> _logs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AuditLog> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all audit logs
  Future<void> loadLogs({
    AuditAction? action,
    String? hospitalId,
    String? actorId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 100,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.getAuditLogs(
      action: action,
      hospitalId: hospitalId,
      actorId: actorId,
      fromDate: fromDate,
      toDate: toDate,
      limit: limit,
    );

    if (result is Success<List<AuditLog>>) {
      _logs = result.data;
    } else {
      _errorMessage = (result as Failure).error.message;
      _logs = [];
    }

    _setLoading(false);
  }

  /// Get recent logs (for dashboard preview)
  List<AuditLog> getRecentLogs(int count) {
    return _logs.take(count).toList();
  }

  /// Filter logs by action type
  List<AuditLog> filterByAction(AuditAction action) {
    return _logs.where((log) => log.action == action).toList();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
