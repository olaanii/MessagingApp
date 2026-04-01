/// Enum representing device classification based on screen width.
///
/// Used by the responsive system to determine appropriate layouts and scaling
/// factors for different device types.
enum DeviceCategory {
  /// Mobile devices with screen width < 600 logical pixels
  mobile,

  /// Tablet devices with screen width between 600 and 1024 logical pixels
  tablet,

  /// Desktop devices with screen width > 1024 logical pixels
  desktop;

  /// Returns true if this device category is mobile
  bool get isMobile => this == DeviceCategory.mobile;

  /// Returns true if this device category is tablet
  bool get isTablet => this == DeviceCategory.tablet;

  /// Returns true if this device category is desktop
  bool get isDesktop => this == DeviceCategory.desktop;
}
