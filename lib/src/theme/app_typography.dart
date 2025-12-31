import 'package:flutter/material.dart';
import 'app_colors.dart';

/// CureLedger Typography System
/// SF Pro / Inter / System UI inspired
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  // Font Weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;

  // Text Theme
  static TextTheme get textTheme => TextTheme(
    // Large Title - for major headers
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 34,
      fontWeight: semibold,
      color: AppColors.primaryText,
      letterSpacing: -0.4,
      height: 1.2,
    ),

    // Title 1
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: semibold,
      color: AppColors.primaryText,
      letterSpacing: -0.4,
      height: 1.2,
    ),

    // Title 2
    displaySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      fontWeight: semibold,
      color: AppColors.primaryText,
      letterSpacing: -0.4,
      height: 1.3,
    ),

    // Title 3
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      fontWeight: semibold,
      color: AppColors.primaryText,
      letterSpacing: -0.4,
      height: 1.3,
    ),

    // Headline
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 17,
      fontWeight: semibold,
      color: AppColors.primaryText,
      letterSpacing: -0.4,
      height: 1.4,
    ),

    // Body
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 17,
      fontWeight: regular,
      color: AppColors.primaryText,
      letterSpacing: -0.4,
      height: 1.5,
    ),

    // Callout
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: regular,
      color: AppColors.primaryText,
      letterSpacing: -0.4,
      height: 1.5,
    ),

    // Subheadline
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: regular,
      color: AppColors.secondaryText,
      letterSpacing: -0.4,
      height: 1.5,
    ),

    // Footnote
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,
      fontWeight: regular,
      color: AppColors.secondaryText,
      letterSpacing: -0.4,
      height: 1.4,
    ),

    // Caption 1
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: regular,
      color: AppColors.secondaryText,
      letterSpacing: -0.4,
      height: 1.4,
    ),

    // Caption 2
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: regular,
      color: AppColors.tertiaryText,
      letterSpacing: -0.4,
      height: 1.4,
    ),
  );

  // Amount/Number Styles (Medium or Semibold for emphasis)
  static TextStyle get amountLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: semibold,
    color: AppColors.primaryText,
    letterSpacing: -0.4,
    height: 1.1,
  );

  static TextStyle get amountMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: semibold,
    color: AppColors.primaryText,
    letterSpacing: -0.4,
    height: 1.2,
  );

  static TextStyle get amountSmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: medium,
    color: AppColors.primaryText,
    letterSpacing: -0.4,
    height: 1.3,
  );
}
