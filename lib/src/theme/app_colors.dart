import 'package:flutter/material.dart';

/// CureLedger Design System Colors
/// Apple-like, calm, institutional palette
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color background = Color(0xFFE5E5E5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF1C1C1C);

  // Secondary Colors (with opacity)
  static Color get secondaryText => primaryText.withValues(alpha: 0.65);
  static Color get tertiaryText => primaryText.withValues(alpha: 0.4);
  static Color get divider => primaryText.withValues(alpha: 0.08);
  static Color get border => primaryText.withValues(alpha: 0.2);

  // Semantic Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFB26A00);
  static const Color error = Color(0xFFB00020);

  // Card Colors
  static const Color cardBackground = white;
  static Color get cardShadow => primaryText.withValues(alpha: 0.06);

  // Status Colors
  static const Color verified = Color(0xFF2E7D32);
  static const Color pending = Color(0xFFB26A00);
  static const Color rejected = Color(0xFFB00020);

  // Progress Bar Colors
  static Color get progressBackground => primaryText.withValues(alpha: 0.1);
  static const Color progressFill = primaryText;
}
