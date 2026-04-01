import 'package:flutter_test/flutter_test.dart';
import 'package:chat/presentation/theme/device_category.dart';

void main() {
  group('DeviceCategory', () {
    test('should have three enum values', () {
      expect(DeviceCategory.values.length, 3);
      expect(DeviceCategory.values, contains(DeviceCategory.mobile));
      expect(DeviceCategory.values, contains(DeviceCategory.tablet));
      expect(DeviceCategory.values, contains(DeviceCategory.desktop));
    });

    group('isMobile getter', () {
      test('should return true for mobile category', () {
        expect(DeviceCategory.mobile.isMobile, isTrue);
      });

      test('should return false for tablet category', () {
        expect(DeviceCategory.tablet.isMobile, isFalse);
      });

      test('should return false for desktop category', () {
        expect(DeviceCategory.desktop.isMobile, isFalse);
      });
    });

    group('isTablet getter', () {
      test('should return false for mobile category', () {
        expect(DeviceCategory.mobile.isTablet, isFalse);
      });

      test('should return true for tablet category', () {
        expect(DeviceCategory.tablet.isTablet, isTrue);
      });

      test('should return false for desktop category', () {
        expect(DeviceCategory.desktop.isTablet, isFalse);
      });
    });

    group('isDesktop getter', () {
      test('should return false for mobile category', () {
        expect(DeviceCategory.mobile.isDesktop, isFalse);
      });

      test('should return false for tablet category', () {
        expect(DeviceCategory.tablet.isDesktop, isFalse);
      });

      test('should return true for desktop category', () {
        expect(DeviceCategory.desktop.isDesktop, isTrue);
      });
    });
  });
}
