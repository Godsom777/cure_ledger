import 'package:flutter/foundation.dart';
import '../core/result.dart';
import '../models/models.dart';
import '../services/auth_service.dart';

/// Authentication state provider
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService);

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  /// Get current user role
  UserRole? get userRole => _currentUser?.role;

  /// Check if user is super admin
  bool get isSuperAdmin => _currentUser?.role == UserRole.platformSuperAdmin;

  /// Check if user is hospital staff
  bool get isHospitalStaff =>
      _currentUser?.role == UserRole.hospitalAdmin ||
      _currentUser?.role == UserRole.socialWorker ||
      _currentUser?.role == UserRole.hospitalFinance;

  /// Login with access code
  Future<bool> loginWithAccessCode(String code) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.loginWithAccessCode(code);

    if (result is Success<User>) {
      _currentUser = result.data;
      _setLoading(false);
      return true;
    } else {
      _errorMessage = (result as Failure).error.message;
      _setLoading(false);
      return false;
    }
  }

  /// Login as super admin
  Future<bool> loginSuperAdmin(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.loginSuperAdmin(email, password);

    if (result is Success<User>) {
      _currentUser = result.data;
      _setLoading(false);
      return true;
    } else {
      _errorMessage = (result as Failure).error.message;
      _setLoading(false);
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Restore session from storage
  Future<void> restoreSession() async {
    _setLoading(true);

    final result = await _authService.restoreSession();

    if (result is Success<User?>) {
      _currentUser = result.data;
    }

    _setLoading(false);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
