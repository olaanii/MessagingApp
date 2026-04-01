import 'package:flutter/material.dart';
import 'device_category.dart';
import 'responsive_config.dart';

/// Core utility class providing MediaQuery-based responsive dimension calculations.
///
/// This class serves as the central engine for all responsive UI calculations in the
/// application. It accepts a BuildContext to access MediaQuery data and provides
/// methods for calculating responsive widths, heights, font sizes, spacing, and more.
///
/// The system automatically detects device category (mobile/tablet/desktop) based on
/// screen width breakpoints and applies appropriate scale factors for typography and
/// spacing.
///
/// Example usage:
/// ```dart
/// final responsive = ResponsiveSystem(context);
/// final buttonWidth = responsive.width(200); // Responsive width
/// final fontSize = responsive.fontSize(16);   // Responsive font size
/// ```
class ResponsiveSystem {
  /// The BuildContext used to access MediaQuery data
  final BuildContext context;

  /// Cached MediaQueryData for efficient access
  final MediaQueryData _mediaQuery;

  /// Cached device category classification
  final DeviceCategory _deviceCategory;

  /// Creates a ResponsiveSystem instance with the given BuildContext.
  ///
  /// Immediately caches MediaQueryData and determines device category
  /// to avoid redundant calculations during the build cycle.
  ResponsiveSystem(this.context)
      : _mediaQuery = MediaQuery.of(context),
        _deviceCategory = _determineDeviceCategory(MediaQuery.of(context));

  /// Determines device category based on screen width breakpoints.
  ///
  /// Classification rules:
  /// - Mobile: width < 600 logical pixels
  /// - Tablet: width >= 600 and < 1024 logical pixels
  /// - Desktop: width >= 1024 logical pixels
  static DeviceCategory _determineDeviceCategory(MediaQueryData mq) {
    final width = mq.size.width;

    if (width < ResponsiveConfig.mobileBreakpoint) {
      return DeviceCategory.mobile;
    } else if (width < ResponsiveConfig.tabletBreakpoint) {
      return DeviceCategory.tablet;
    } else {
      return DeviceCategory.desktop;
    }
  }

  // Device category getters

  /// Returns the current device category classification
  DeviceCategory get deviceCategory => _deviceCategory;

  /// Returns true if the current device is classified as mobile
  bool get isMobile => _deviceCategory.isMobile;

  /// Returns true if the current device is classified as tablet
  bool get isTablet => _deviceCategory.isTablet;

  /// Returns true if the current device is classified as desktop
  bool get isDesktop => _deviceCategory.isDesktop;

  // Screen dimension getters

  /// Returns the current screen width in logical pixels
  double get screenWidth => _mediaQuery.size.width;

  /// Returns the current screen height in logical pixels
  double get screenHeight => _mediaQuery.size.height;

  /// Returns true if the device is in portrait orientation
  bool get isPortrait => _mediaQuery.orientation == Orientation.portrait;

  /// Returns true if the device is in landscape orientation
  bool get isLandscape => _mediaQuery.orientation == Orientation.landscape;

  // Responsive dimension calculations

  /// Calculates responsive width based on design width.
  ///
  /// This method scales a design width value to the current screen size using
  /// the formula: designWidth * (screenWidth / referenceWidth) * deviceMultiplier
  ///
  /// The device category multiplier is currently 1.0 for all device types
  /// (mobile, tablet, desktop) as specified in the design.
  ///
  /// Example:
  /// ```dart
  /// final buttonWidth = responsive.width(200); // Scales 200px design width
  /// ```
  ///
  /// Parameters:
  /// - [designWidth]: The width value from the design specification
  ///
  /// Returns: The calculated responsive width in logical pixels
  double width(double designWidth) {
    // Calculate width scale factor
    final widthScale = screenWidth / ResponsiveConfig.referenceWidth;

    // Apply device category multiplier (1.0 for all categories)
    final deviceMultiplier = 1.0;

    // Return scaled width
    return designWidth * widthScale * deviceMultiplier;
  }

  /// Calculates responsive height based on design height.
  ///
  /// This method scales a design height value to the current screen size using
  /// the formula: designHeight * (screenHeight / referenceHeight) * deviceMultiplier
  ///
  /// The device category multiplier is currently 1.0 for all device types
  /// (mobile, tablet, desktop) as specified in the design.
  ///
  /// Example:
  /// ```dart
  /// final containerHeight = responsive.height(100); // Scales 100px design height
  /// ```
  ///
  /// Parameters:
  /// - [designHeight]: The height value from the design specification
  ///
  /// Returns: The calculated responsive height in logical pixels
  double height(double designHeight) {
    // Calculate height scale factor
    final heightScale = screenHeight / ResponsiveConfig.referenceHeight;

    // Apply device category multiplier (1.0 for all categories)
    final deviceMultiplier = 1.0;

    // Return scaled height
    return designHeight * heightScale * deviceMultiplier;
  }

  /// Calculates responsive font size based on design size.
  ///
  /// This method implements a multi-stage calculation:
  /// 1. Scale base font size using widthScale
  /// 2. Apply typography scale factor based on device category
  /// 3. Apply textScaler from MediaQuery for accessibility
  /// 4. Clamp result between minFontSize and maxFontSize
  ///
  /// Formula:
  /// ```
  /// baseFontSize = designSize * widthScale
  /// scaledFontSize = baseFontSize * typographyScaleFactor[deviceCategory]
  /// accessibleFontSize = textScaler.scale(scaledFontSize)
  /// finalFontSize = clamp(accessibleFontSize, minFontSize, maxFontSize)
  /// ```
  ///
  /// Example:
  /// ```dart
  /// final bodyTextSize = responsive.fontSize(16); // Scales 16px design font
  /// ```
  ///
  /// Parameters:
  /// - [designSize]: The font size value from the design specification
  ///
  /// Returns: The calculated responsive font size in logical pixels
  double fontSize(double designSize) {
    // Step 1: Calculate base font size using widthScale
    final widthScale = screenWidth / ResponsiveConfig.referenceWidth;
    final baseFontSize = designSize * widthScale;

    // Step 2: Apply typography scale factor based on device category
    final typographyScaleFactor = _getTypographyScaleFactor();
    final scaledFontSize = baseFontSize * typographyScaleFactor;

    // Step 3: Apply textScaler from MediaQuery for accessibility
    final textScaler = _mediaQuery.textScaler;
    final accessibleFontSize = textScaler.scale(scaledFontSize);

    // Step 4: Clamp result between minFontSize and maxFontSize
    final finalFontSize = accessibleFontSize.clamp(
      ResponsiveConfig.minFontSize,
      ResponsiveConfig.maxFontSize,
    );

    return finalFontSize;
  }

  /// Returns the typography scale factor for the current device category.
  ///
  /// Scale factors:
  /// - Mobile: 1.0 (base scale)
  /// - Tablet: 1.15 (15% increase)
  /// - Desktop: 1.25 (25% increase)
  double _getTypographyScaleFactor() {
    switch (_deviceCategory) {
      case DeviceCategory.mobile:
        return ResponsiveConfig.mobileTypographyScale;
      case DeviceCategory.tablet:
        return ResponsiveConfig.tabletTypographyScale;
      case DeviceCategory.desktop:
        return ResponsiveConfig.desktopTypographyScale;
    }
  }

  /// Calculates responsive spacing based on design spacing.
  ///
  /// This method implements a multi-stage calculation:
  /// 1. Scale base spacing using widthScale
  /// 2. Apply spacing scale factor based on device category
  /// 3. Apply compact spacing multiplier (0.8) for landscape on mobile only
  ///
  /// Formula:
  /// ```
  /// baseSpacing = designSpacing * widthScale
  /// scaledSpacing = baseSpacing * spacingScaleFactor[deviceCategory]
  /// finalSpacing = scaledSpacing * orientationMultiplier (0.8 for mobile landscape, 1.0 otherwise)
  /// ```
  ///
  /// Example:
  /// ```dart
  /// final padding = responsive.spacing(16); // Scales 16px design spacing
  /// ```
  ///
  /// Parameters:
  /// - [designSpacing]: The spacing value from the design specification
  ///
  /// Returns: The calculated responsive spacing in logical pixels
  double spacing(double designSpacing) {
    // Step 1: Calculate base spacing using widthScale
    final widthScale = screenWidth / ResponsiveConfig.referenceWidth;
    final baseSpacing = designSpacing * widthScale;

    // Step 2: Apply spacing scale factor based on device category
    final spacingScaleFactor = _getSpacingScaleFactor();
    final scaledSpacing = baseSpacing * spacingScaleFactor;

    // Step 3: Apply compact spacing multiplier for landscape on mobile only
    final orientationMultiplier = (isMobile && isLandscape) ? 0.8 : 1.0;
    final finalSpacing = scaledSpacing * orientationMultiplier;

    return finalSpacing;
  }

  /// Returns the spacing scale factor for the current device category.
  ///
  /// Scale factors:
  /// - Mobile: 1.0 (base scale)
  /// - Tablet: 1.2 (20% increase)
  /// - Desktop: 1.4 (40% increase)
  double _getSpacingScaleFactor() {
    switch (_deviceCategory) {
      case DeviceCategory.mobile:
        return ResponsiveConfig.mobileSpacingScale;
      case DeviceCategory.tablet:
        return ResponsiveConfig.tabletSpacingScale;
      case DeviceCategory.desktop:
        return ResponsiveConfig.desktopSpacingScale;
    }
  }

  // Platform-specific safe area padding

  /// Returns the safe area padding for the current device.
  ///
  /// This includes insets for system UI elements like notches, status bars,
  /// and navigation bars.
  EdgeInsets get safePadding => _mediaQuery.padding;

  /// Returns the bottom safe area padding in logical pixels.
  ///
  /// Useful for avoiding system navigation bars and home indicators.
  double get bottomSafeArea => _mediaQuery.padding.bottom;

  /// Returns the top safe area padding in logical pixels.
  ///
  /// Useful for avoiding status bars and notches.
  double get topSafeArea => _mediaQuery.padding.top;

  // Accessibility

  /// Returns the user's text scale factor preference, clamped to maximum.
  ///
  /// The text scale factor represents the user's system-wide text size
  /// preference for accessibility. This value is clamped to prevent
  /// layout overflow on extreme settings.
  ///
  /// Note: This uses the new TextScaler API which supports nonlinear scaling.
  /// For a reference font size of 14.0, the scale factor is extracted and clamped.
  ///
  /// Returns: Text scale factor clamped between 1.0 and maxTextScaleFactor (2.0)
  double get textScaleFactor {
    final textScaler = _mediaQuery.textScaler;
    // Use a reference size to extract the scale factor
    final scaledSize = textScaler.scale(14.0);
    final scaleFactor = scaledSize / 14.0;
    
    return scaleFactor.clamp(
      1.0,
      ResponsiveConfig.maxTextScaleFactor,
    );
  }

  /// Calculates responsive icon size based on design size.
  ///
  /// This method scales an icon size value to the current screen size using
  /// the formula: designSize * (screenWidth / referenceWidth) * deviceMultiplier
  ///
  /// The device category multiplier is currently 1.0 for all device types
  /// (mobile, tablet, desktop) as specified in the design.
  ///
  /// Example:
  /// ```dart
  /// final iconSize = responsive.iconSize(24); // Scales 24px design icon
  /// ```
  ///
  /// Parameters:
  /// - [designSize]: The icon size value from the design specification
  ///
  /// Returns: The calculated responsive icon size in logical pixels
  double iconSize(double designSize) {
    // Calculate width scale factor
    final widthScale = screenWidth / ResponsiveConfig.referenceWidth;

    // Apply device category multiplier (1.0 for all categories)
    final deviceMultiplier = 1.0;

    // Return scaled icon size
    return designSize * widthScale * deviceMultiplier;
  }

  /// Calculates responsive border radius based on design radius.
  ///
  /// This method scales a border radius value to the current screen size using
  /// the formula: designRadius * (screenWidth / referenceWidth) * deviceMultiplier
  ///
  /// The device category multiplier is currently 1.0 for all device types
  /// (mobile, tablet, desktop) as specified in the design.
  ///
  /// Example:
  /// ```dart
  /// final borderRadius = responsive.radius(8); // Scales 8px design radius
  /// ```
  ///
  /// Parameters:
  /// - [designRadius]: The border radius value from the design specification
  ///
  /// Returns: The calculated responsive border radius in logical pixels
  double radius(double designRadius) {
    // Calculate width scale factor
    final widthScale = screenWidth / ResponsiveConfig.referenceWidth;

    // Apply device category multiplier (1.0 for all categories)
    final deviceMultiplier = 1.0;

    // Return scaled radius
    return designRadius * widthScale * deviceMultiplier;
  }
}

/// Extension on BuildContext for convenient access to responsive values.
///
/// This extension provides shorthand methods to access the ResponsiveSystem
/// without needing to create an instance manually. It also provides quick
/// access to device category checks.
///
/// Example usage:
/// ```dart
/// Widget build(BuildContext context) {
///   return Container(
///     width: context.rw(200),        // Responsive width
///     height: context.rh(100),       // Responsive height
///     padding: EdgeInsets.all(context.rs(16)), // Responsive spacing
///     child: Text(
///       'Hello',
///       style: TextStyle(fontSize: context.rf(16)), // Responsive font
///     ),
///   );
/// }
/// ```
extension ResponsiveExtension on BuildContext {
  /// Returns a ResponsiveSystem instance for this context.
  ///
  /// This creates a new ResponsiveSystem instance each time it's called.
  /// For multiple calculations, consider storing the instance in a variable.
  ResponsiveSystem get responsive => ResponsiveSystem(this);

  // Shorthand methods for dimension calculations

  /// Shorthand for responsive width calculation.
  ///
  /// Equivalent to: `ResponsiveSystem(context).width(width)`
  double rw(double width) => responsive.width(width);

  /// Shorthand for responsive height calculation.
  ///
  /// Equivalent to: `ResponsiveSystem(context).height(height)`
  double rh(double height) => responsive.height(height);

  /// Shorthand for responsive font size calculation.
  ///
  /// Equivalent to: `ResponsiveSystem(context).fontSize(fontSize)`
  double rf(double fontSize) => responsive.fontSize(fontSize);

  /// Shorthand for responsive spacing calculation.
  ///
  /// Equivalent to: `ResponsiveSystem(context).spacing(spacing)`
  double rs(double spacing) => responsive.spacing(spacing);

  /// Shorthand for responsive icon size calculation.
  ///
  /// Equivalent to: `ResponsiveSystem(context).iconSize(iconSize)`
  double ri(double iconSize) => responsive.iconSize(iconSize);

  /// Shorthand for responsive border radius calculation.
  ///
  /// Equivalent to: `ResponsiveSystem(context).radius(radius)`
  double rr(double radius) => responsive.radius(radius);

  // Device category check getters

  /// Returns true if the current device is classified as mobile.
  ///
  /// Equivalent to: `ResponsiveSystem(context).isMobile`
  bool get isMobile => responsive.isMobile;

  /// Returns true if the current device is classified as tablet.
  ///
  /// Equivalent to: `ResponsiveSystem(context).isTablet`
  bool get isTablet => responsive.isTablet;

  /// Returns true if the current device is classified as desktop.
  ///
  /// Equivalent to: `ResponsiveSystem(context).isDesktop`
  bool get isDesktop => responsive.isDesktop;
}
