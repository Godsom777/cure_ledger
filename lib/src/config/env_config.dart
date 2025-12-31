/// Environment configuration for CureLedger
/// Uses compile-time constants from dart-define or .env
class EnvConfig {
  EnvConfig._();

  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Paystack Configuration
  static const String paystackPublicKey = String.fromEnvironment(
    'PAYSTACK_PUBLIC_KEY',
    defaultValue: '',
  );

  // App Configuration
  static const bool isProduction =
      String.fromEnvironment('ENV', defaultValue: 'development') ==
      'production';

  static const String appName = 'CureLedger';
  static const String appVersion = '1.0.0';

  // Platform Fee (loaded from backend, fallback only)
  static const double defaultPlatformFeePercent = 5.0;
  static const double defaultHospitalSettlementPercent = 95.0;

  /// Validate required configuration
  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw ConfigurationException('SUPABASE_URL is not configured');
    }
    if (supabaseAnonKey.isEmpty) {
      throw ConfigurationException('SUPABASE_ANON_KEY is not configured');
    }
    if (paystackPublicKey.isEmpty) {
      throw ConfigurationException('PAYSTACK_PUBLIC_KEY is not configured');
    }
  }

  /// Check if app is properly configured
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      paystackPublicKey.isNotEmpty;
}

class ConfigurationException implements Exception {
  final String message;
  ConfigurationException(this.message);

  @override
  String toString() => 'ConfigurationException: $message';
}
