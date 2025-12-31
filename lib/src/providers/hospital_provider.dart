import 'package:flutter/foundation.dart';
import '../core/result.dart';
import '../models/models.dart';
import '../repositories/hospital_repository.dart';

/// Hospital state provider
class HospitalProvider extends ChangeNotifier {
  final HospitalRepository _repository;

  HospitalProvider(this._repository);

  List<Hospital> _hospitals = [];
  Hospital? _currentHospital;
  bool _isLoading = false;
  String? _errorMessage;

  List<Hospital> get hospitals => _hospitals;
  Hospital? get currentHospital => _currentHospital;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Filter hospitals by status
  List<Hospital> getHospitalsByStatus(HospitalStatus status) {
    return _hospitals.where((h) => h.status == status).toList();
  }

  /// Load all hospitals (Super Admin)
  Future<void> loadHospitals() async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.getHospitals();

    if (result is Success<List<Hospital>>) {
      _hospitals = result.data;
    } else {
      _errorMessage = (result as Failure).error.message;
      _hospitals = [];
    }

    _setLoading(false);
  }

  /// Load hospital by ID
  Future<void> loadHospital(String id) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.getHospitalById(id);

    if (result is Success<Hospital>) {
      _currentHospital = result.data;
    } else {
      _errorMessage = (result as Failure).error.message;
      _currentHospital = null;
    }

    _setLoading(false);
  }

  /// Create new hospital (Super Admin)
  Future<bool> createHospital(Hospital hospital) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.createHospital(hospital);

    if (result is Success<Hospital>) {
      _hospitals.add(result.data);
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _errorMessage = (result as Failure).error.message;
      _setLoading(false);
      return false;
    }
  }

  /// Update hospital status (Super Admin)
  Future<bool> updateHospitalStatus(
    String id,
    HospitalStatus status, {
    String? reason,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.updateHospitalStatus(
      id,
      status,
      reason: reason,
    );

    if (result is Success<Hospital>) {
      _updateHospitalInList(result.data);
      _setLoading(false);
      return true;
    } else {
      _errorMessage = (result as Failure).error.message;
      _setLoading(false);
      return false;
    }
  }

  /// Activate hospital
  Future<bool> activateHospital(String id) async {
    return updateHospitalStatus(id, HospitalStatus.active);
  }

  /// Suspend hospital
  Future<bool> suspendHospital(String id, String reason) async {
    return updateHospitalStatus(id, HospitalStatus.suspended, reason: reason);
  }

  /// Flag hospital for review
  Future<bool> flagHospital(String id, String reason) async {
    return updateHospitalStatus(id, HospitalStatus.flagged, reason: reason);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _updateHospitalInList(Hospital updated) {
    final index = _hospitals.indexWhere((h) => h.id == updated.id);
    if (index != -1) {
      _hospitals[index] = updated;
    }
    if (_currentHospital?.id == updated.id) {
      _currentHospital = updated;
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
