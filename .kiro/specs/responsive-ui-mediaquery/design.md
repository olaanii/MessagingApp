# Design Document: Responsive UI with MediaQuery

## Overview

This design implements a comprehensive responsive UI system for the Flutter chat application using MediaQuery. The system replaces hardcoded dimension values throughout the application with dynamic calculations that adapt to screen size, orientation, and platform. This ensures optimal user experience across mobile phones, tablets, and desktop devices.

The design centers around a centralized `ResponsiveSystem` utility class that provides MediaQuery-based calculations for all UI dimensions including widths, heights, padding, margins, font sizes, icon sizes, and border radii. The system integrates seamlessly with the existing design token architecture while adding responsive capabilities.

Key design principles:
- Single source of truth for responsive calculations
- Minimal performance overhead through efficient caching
- Backward compatibility with existing design tokens
- Platform-aware adaptations for iOS, Android, and Web
- Accessibility compliance with system font scaling

## Architecture

### System Components

The responsive system consists of three primary components:

1. **ResponsiveSystem**: Core utility class providing MediaQuery-based dimension calculations
2. **ResponsiveExtension**: BuildContext extension methods for convenient access to responsive values
3. **ResponsiveConfig**: Configuration class defining breakpoints, scale factors, and constraints

### Component Relationships

```
┌─────────────────────────────────────────────────────────┐
│                    BuildContext                          │
│                  (MediaQuery source)                     │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              ResponsiveExtension                         │
│         (Convenience access methods)                     │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│               ResponsiveSystem                           │
│         (Core calculation engine)                        │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  Dimension   │  │  Typography  │  │   Platform   │ │
│  │ Calculations │  │   Scaling    │  │  Adaptation  │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              ResponsiveConfig                            │
│    (Breakpoints, scale factors, constraints)             │
└─────────────────────────────────────────────────────────┘
```

### Data Flow

1. UI widget requests responsive dimension via BuildContext extension
2. Extension delegates to ResponsiveSystem with MediaQuery data
3. ResponsiveSystem retrieves screen metrics and device category
4. System applies appropriate scale factors from ResponsiveConfig
5. Calculated dimension is returned to widget for rendering

### Integration with Existing Architecture

The responsive system integrates with existing components:

- **AppDesignTokens**: Provides base values for responsive calculations
- **AppTheme**: Remains unchanged, responsive values applied at widget level
- **UI Components**: Updated to use ResponsiveExtension methods instead of hardcoded values

## Components and Interfaces

### ResponsiveConfig

Configuration class defining system-wide responsive behavior:

```dart
class ResponsiveConfig {
  // Screen breakpoints (logical pixels)
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  
  // Reference design dimensions
  static const double referenceWidth = 375.0;  // iPhone design reference
  static const double referenceHeight = 812.0;
  
  // Typography scale factors by device category
  static const double mobileTypographyScale = 1.0;
  static const double tabletTypographyScale = 1.15;
  static const double desktopTypographyScale = 1.25;
  
  // Spacing scale factors by device category
  static const double mobileSpacingScale = 1.0;
  static const double tabletSpacingScale = 1.2;
  static const double desktopSpacingScale = 1.4;
  
  // Constraints
  static const double minFontSize = 12.0;
  static const double maxFontSize = 48.0;
  static const double minTouchTarget = 44.0;
  static const double maxTextScaleFactor = 2.0;
}
```

### DeviceCategory

Enum representing device classification:

```dart
enum DeviceCategory {
  mobile,
  tablet,
  desktop;
  
  bool get isMobile => this == DeviceCategory.mobile;
  bool get isTablet => this == DeviceCategory.tablet;
  bool get isDesktop => this == DeviceCategory.desktop;
}
```

### ResponsiveSystem

Core utility class providing all responsive calculations:

```dart
class ResponsiveSystem {
  final BuildContext context;
  final MediaQueryData _mediaQuery;
  final DeviceCategory _deviceCategory;
  
  ResponsiveSystem(this.context) 
    : _mediaQuery = MediaQuery.of(context),
      _deviceCategory = _determineDeviceCategory(MediaQuery.of(context));
  
  // Device category detection
  static DeviceCategory _determineDeviceCategory(MediaQueryData mq);
  DeviceCategory get deviceCategory => _deviceCategory;
  bool get isMobile => _deviceCategory.isMobile;
  bool get isTablet => _deviceCategory.isTablet;
  bool get isDesktop => _deviceCategory.isDesktop;
  
  // Screen dimensions
  double get screenWidth => _mediaQuery.size.width;
  double get screenHeight => _mediaQuery.size.height;
  bool get isPortrait => _mediaQuery.orientation == Orientation.portrait;
  bool get isLandscape => _mediaQuery.orientation == Orientation.landscape;
  
  // Responsive dimension calculations
  double width(double designWidth);
  double height(double designHeight);
  double fontSize(double designSize);
  double spacing(double designSpacing);
  double iconSize(double designSize);
  double radius(double designRadius);
  
  // Platform-specific safe area padding
  EdgeInsets get safePadding => _mediaQuery.padding;
  double get bottomSafeArea => _mediaQuery.padding.bottom;
  double get topSafeArea => _mediaQuery.padding.top;
  
  // Accessibility
  double get textScaleFactor => _mediaQuery.textScaleFactor.clamp(
    1.0, 
    ResponsiveConfig.maxTextScaleFactor
  );
}
```

### ResponsiveExtension

BuildContext extension for convenient access:

```dart
extension ResponsiveExtension on BuildContext {
  ResponsiveSystem get responsive => ResponsiveSystem(this);
  
  // Quick access methods
  double rw(double width) => responsive.width(width);
  double rh(double height) => responsive.height(height);
  double rf(double fontSize) => responsive.fontSize(fontSize);
  double rs(double spacing) => responsive.spacing(spacing);
  double ri(double iconSize) => responsive.iconSize(iconSize);
  double rr(double radius) => responsive.radius(radius);
  
  // Device category checks
  bool get isMobile => responsive.isMobile;
  bool get isTablet => responsive.isTablet;
  bool get isDesktop => responsive.isDesktop;
}
```

## Data Models

### MediaQueryData (Flutter built-in)

The system relies on Flutter's MediaQueryData which provides:

```dart
class MediaQueryData {
  Size size;                    // Screen dimensions
  double devicePixelRatio;      // Physical to logical pixel ratio
  double textScaleFactor;       // User's text size preference
  EdgeInsets padding;           // Safe area insets
  EdgeInsets viewInsets;        // Keyboard and system UI insets
  Orientation orientation;      // Portrait or landscape
  // ... other properties
}
```

### Calculation Models

The system uses these internal calculation models:

**Scale Factor Calculation**:
```
widthScale = currentScreenWidth / referenceWidth
heightScale = currentScreenHeight / referenceHeight
```

**Responsive Width**:
```
responsiveWidth = designWidth * widthScale * deviceCategoryMultiplier
```

**Responsive Font Size**:
```
baseFontSize = designSize * widthScale
scaledFontSize = baseFontSize * typographyScaleFactor[deviceCategory]
accessibleFontSize = scaledFontSize * textScaleFactor
finalFontSize = clamp(accessibleFontSize, minFontSize, maxFontSize)
```

**Responsive Spacing**:
```
baseSpacing = designSpacing * widthScale
responsiveSpacing = baseSpacing * spacingScaleFactor[deviceCategory]
```

## Correctness Properties

