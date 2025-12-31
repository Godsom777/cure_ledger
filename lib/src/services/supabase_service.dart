import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';
import '../core/result.dart';
import '../core/logger.dart';

/// Supabase client service
/// Handles all database operations
class SupabaseService {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    if (_client == null) {
      throw const AppException(
        'Supabase not initialized. Call initialize() first.',
      );
    }
    return _client!;
  }

  /// Initialize Supabase
  static Future<void> initialize() async {
    if (_client != null) return;

    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
    AppLogger.i('Supabase initialized successfully');
  }

  /// Get current authenticated user
  static User? get currentUser => _client?.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Auth state changes stream
  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;
}
