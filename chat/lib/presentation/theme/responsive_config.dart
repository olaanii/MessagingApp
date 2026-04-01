/// Configuration class defining system-wide responsive behavior.
///
/// This class contains all constants used by the responsive system including:
/// - Screen breakpoints for device category detection
/// - Reference design dimensions for scaling calculations
/// - Typography scale factors by device category
/// - Spacing scale factors by device category
/// - Constraints for minimum/maximum values
///
/// Example usage:
/// ```dart
/// // Check if screen width is mobile
/// if (screenWidth < ResponsiveConfig.mobileBreakpoint) {
///   // Apply mobile layout
/// }
///
/// // Use typography scale factor
/// final scaledSize = baseSize * ResponsiveConfig.tabletTypographyScale;
/// ```
class ResponsiveConfig {
  // Private constructor to prevent instantiation
  ResponsiveConfig._();

  // Screen breakpoints (logical pixels)
  
  /// Breakpoint for mobile devices.
  /// Screens with width less than this value are classified as mobile.
  static const double mobileBreakpoint = 600.0;

  /// Breakpoint for tablet devices.
  /// Screens with width between [mobileBreakpoint] and this value are tablets.
  /// Screens with width greater than this value are classified as desktop.
  static const double tabletBreakpoint = 1024.0;

  // Reference design dimensions
  
  /// Reference design width in logical pixels.
  /// Based on iPhone design reference (375px).
  /// All width calculations are scaled relative to this value.
  static const double referenceWidth = 375.0;

  /// Reference design height in logical pixels.
  /// Based on iPhone design reference (812px).
  /// All height calculations are scaled relative to this value.
  static const double referenceHeight = 812.0;

  // Typography scale factors by device category
  
  /// Typography scale factor for mobile devices.
  /// Base scale with no additional multiplier.
  static const double mobileTypographyScale = 1.0;

  /// Typography scale factor for tablet devices.
  /// Increases font sizes by 15% compared to mobile.
  static const double tabletTypographyScale = 1.15;

  /// Typography scale factor for desktop devices.
  /// Increases font sizes by 25% compared to mobile.
  static const double desktopTypographyScale = 1.25;

  // Spacing scale factors by device category
  
  /// Spacing scale factor for mobile devices.
  /// Base scale with no additional multiplier.
  static const double mobileSpacingScale = 1.0;

  /// Spacing scale factor for tablet devices.
  /// Increases spacing by 20% compared to mobile.
  static const double tabletSpacingScale = 1.2;

  /// Spacing scale factor for desktop devices.
  /// Increases spacing by 40% compared to mobile.
  static const double desktopSpacingScale = 1.4;

  // Constraints
  
  /// Minimum font size in logical pixels.
  /// Ensures text remains readable even on small screens or with scaling.
  static const double minFontSize = 12.0;

  /// Maximum font size in logical pixels.
  /// Prevents oversized text on large screens or with accessibility scaling.
  static const double maxFontSize = 48.0;

  /// Minimum touch target size in logical pixels.
  /// Ensures interactive elements meet accessibility guidelines (44x44).
  static const double minTouchTarget = 44.0;

  /// Maximum text scale factor for accessibility.
  /// Limits system text scaling to prevent layout overflow.
  static const double maxtextScaler = 2.0;
}
