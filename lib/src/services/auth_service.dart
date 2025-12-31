import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/result.dart';
import '../core/logger.dart';
import '../models/models.dart';
import 'supabase_service.dart';

/// Authentication service
/// Handles access code login and session management
class AuthService {
  final _secureStorage = const FlutterSecureStorage();

  static const _accessCodeKey = 'access_code';
  static const _userIdKey = 'user_id';
  static const _hospitalIdKey = 'hospital_id';
  static const _roleKey = 'user_role';

  User? _currentUser;
  User? get currentUser => _currentUser;

  /// Login with hospital-issued access code
  /// Format: HOSPITALCODE-ROLE-RANDOM (e.g., LUTH-SW-8842)
  Future<Result<User>> loginWithAccessCode(String code) async {
    try {
      AppLogger.i(
        'Attempting login with access code: ${code.substring(0, 4)}...',
      );

      // Validate code format
      final parts = code.split('-');
      if (parts.length != 3) {
        return const Failure(
          ValidationException(
            'Invalid access code format. Expected: HOSPITALCODE-ROLE-CODE',
          ),
        );
      }

      final hospitalCode = parts[0]; // Used for logging/validation
      final roleCode = parts[1]; // Used for logging/validation
      final _ = parts[2]; // Unique portion of code

      AppLogger.d('Access code parsed: hospital=$hospitalCode, role=$roleCode');

      // Query Supabase for valid access code
      final response = await SupabaseService.client
          .from('access_codes')
          .select('''
            *,
            hospital:hospitals(*)
          ''')
          .eq('code', code)
          .eq('is_used', false)
          .single();

      // Check if code exists - response won't be null due to .single() throwing
      if (response.isEmpty) {
        return const Failure(
          AuthException(
            'Access code not found or already used',
            code: 'INVALID_CODE',
          ),
        );
      }

      // Parse access code
      final accessCode = AccessCode.fromJson(response);

      // Check if code is expired
      if (accessCode.isExpired) {
        return const Failure(
          AuthException('Access code has expired', code: 'CODE_EXPIRED'),
        );
      }

      // Mark code as used
      await SupabaseService.client
          .from('access_codes')
          .update({
            'is_used': true,
            'used_at': DateTime.now().toIso8601String(),
          })
          .eq('id', accessCode.id);

      // Get or create user based on access code
      final userResponse = await SupabaseService.client
          .from('users')
          .select()
          .eq('hospital_id', accessCode.hospitalId)
          .eq('role', _mapRoleCode(roleCode))
          .maybeSingle();

      User user;
      if (userResponse != null) {
        user = User.fromJson(userResponse);
      } else {
        // Create new user from access code
        final newUserData = {
          'hospital_id': accessCode.hospitalId,
          'role': _mapRoleCode(roleCode),
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        };

        final insertResponse = await SupabaseService.client
            .from('users')
            .insert(newUserData)
            .select()
            .single();

        user = User.fromJson(insertResponse);
      }

      // Store session
      await _storeSession(user, code);
      _currentUser = user;

      AppLogger.i('Login successful for user: ${user.id}');
      return Success(user);
    } catch (e, stackTrace) {
      AppLogger.e('Login failed', e, stackTrace);
      return Failure(
        AuthException(
          'Login failed: ${e.toString()}',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Super Admin login with email/password
  Future<Result<User>> loginSuperAdmin(String email, String password) async {
    try {
      AppLogger.i('Attempting super admin login: $email');

      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return const Failure(
          AuthException(
            'Invalid email or password',
            code: 'INVALID_CREDENTIALS',
          ),
        );
      }

      // Get user profile
      final userResponse = await SupabaseService.client
          .from('users')
          .select()
          .eq('email', email)
          .eq('role', 'platform_super_admin')
          .single();

      final user = User.fromJson(userResponse);

      if (user.role != UserRole.platformSuperAdmin) {
        await SupabaseService.client.auth.signOut();
        return const Failure(
          PermissionException(
            'Access denied. Super admin privileges required.',
            code: 'INSUFFICIENT_PERMISSIONS',
          ),
        );
      }

      _currentUser = user;
      AppLogger.i('Super admin login successful');
      return Success(user);
    } catch (e, stackTrace) {
      AppLogger.e('Super admin login failed', e, stackTrace);
      return Failure(
        AuthException(
          'Login failed: ${e.toString()}',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await SupabaseService.client.auth.signOut();
      await _clearSession();
      _currentUser = null;
      AppLogger.i('Logout successful');
    } catch (e, stackTrace) {
      AppLogger.e('Logout error', e, stackTrace);
    }
  }

  /// Restore session from storage
  Future<Result<User?>> restoreSession() async {
    try {
      final userId = await _secureStorage.read(key: _userIdKey);
      if (userId == null) {
        return const Success(null);
      }

      final userResponse = await SupabaseService.client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (userResponse == null) {
        await _clearSession();
        return const Success(null);
      }

      final user = User.fromJson(userResponse);
      if (!user.isActive) {
        await _clearSession();
        return const Failure(
          AuthException(
            'Account has been deactivated',
            code: 'ACCOUNT_DEACTIVATED',
          ),
        );
      }

      _currentUser = user;
      return Success(user);
    } catch (e, stackTrace) {
      AppLogger.e('Session restore failed', e, stackTrace);
      return const Success(null);
    }
  }

  /// Store session data securely
  Future<void> _storeSession(User user, String accessCode) async {
    await _secureStorage.write(key: _userIdKey, value: user.id);
    await _secureStorage.write(key: _hospitalIdKey, value: user.hospitalId);
    await _secureStorage.write(key: _roleKey, value: user.role.name);
    await _secureStorage.write(key: _accessCodeKey, value: accessCode);
  }

  /// Clear stored session
  Future<void> _clearSession() async {
    await _secureStorage.deleteAll();
  }

  /// Map role code to UserRole
  String _mapRoleCode(String code) {
    switch (code.toUpperCase()) {
      case 'SW':
        return 'hospital_social_worker';
      case 'FIN':
        return 'hospital_finance';
      case 'ADM':
        return 'hospital_admin';
      default:
        return 'hospital_social_worker';
    }
  }
}
