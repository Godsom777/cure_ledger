/// CureLedger Spacing System
/// 8pt grid system for consistent spacing
class AppSpacing {
  AppSpacing._();

  // Base unit
  static const double unit = 8.0;

  // Spacing scale
  static const double xxs = 4.0; // 0.5x
  static const double xs = 8.0; // 1x
  static const double sm = 12.0; // 1.5x
  static const double md = 16.0; // 2x
  static const double lg = 24.0; // 3x
  static const double xl = 32.0; // 4x
  static const double xxl = 48.0; // 6x
  static const double xxxl = 64.0; // 8x

  // Screen padding
  static const double screenHorizontal = 20.0;
  static const double screenVertical = 24.0;

  // Card padding
  static const double cardPadding = 16.0;
  static const double cardPaddingLarge = 20.0;

  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 999.0;

  // Minimum tap target (WCAG)
  static const double minTapTarget = 44.0;
}
