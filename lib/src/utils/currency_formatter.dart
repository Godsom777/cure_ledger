import 'package:intl/intl.dart';

/// Currency formatting utilities for Nigerian Naira
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _nairaFormat = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 2,
  );

  static final _nairaCompactFormat = NumberFormat.compactCurrency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 0,
  );

  static final _nairaNoDecimalFormat = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 0,
  );

  /// Format amount as currency (e.g., ₦1,234,567.89)
  static String format(double amount) {
    return _nairaFormat.format(amount);
  }

  /// Format amount without decimals (e.g., ₦1,234,567)
  static String formatNoDecimal(double amount) {
    return _nairaNoDecimalFormat.format(amount);
  }

  /// Format amount in compact form (e.g., ₦1.2M)
  static String formatCompact(double amount) {
    return _nairaCompactFormat.format(amount);
  }

  /// Format amount with custom decimal places
  static String formatWithDecimals(double amount, int decimals) {
    final format = NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: decimals,
    );
    return format.format(amount);
  }

  /// Parse currency string to double
  static double? parse(String value) {
    try {
      final cleaned = value.replaceAll(RegExp(r'[₦,\s]'), '');
      return double.tryParse(cleaned);
    } catch (_) {
      return null;
    }
  }
}
