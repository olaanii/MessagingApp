import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat/presentation/theme/responsive_system.dart';
import 'package:chat/presentation/theme/device_category.dart';

/// Tests for ResponsiveSystem core class (Task 1.3)
/// This test file validates the basic structure implemented in task 1.3:
/// - Constructor accepting BuildContext
/// - MediaQueryData caching
/// - Device category detection
/// - Device category getters
/// - Screen dimension getters
void main() {
  group('ResponsiveSystem Core (Task 1.3)', () {
    group('Constructor and MediaQuery caching', () {
      testWidgets('should accept BuildContext and cache MediaQueryData',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive, isNotNull);
                expect(responsive.context, equals(context));
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('_determineDeviceCategory', () {
      testWidgets('should classify width < 600 as mobile',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(599, 800)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.mobile);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should classify width >= 600 and < 1024 as tablet',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(600, 1024)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.tablet);
                return const SizedBox();
              },
            ),
          ),
        );

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1023, 1024)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.tablet);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should classify width >= 1024 as desktop',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1024, 768)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.desktop);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('Device category getters', () {
      testWidgets('isMobile should return true for mobile devices',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.isMobile, true);
                expect(responsive.isTablet, false);
                expect(responsive.isDesktop, false);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('isTablet should return true for tablet devices',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.isMobile, false);
                expect(responsive.isTablet, true);
                expect(responsive.isDesktop, false);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('isDesktop should return true for desktop devices',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1920, 1080)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.isMobile, false);
                expect(responsive.isTablet, false);
                expect(responsive.isDesktop, true);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('Screen dimension getters', () {
      testWidgets('screenWidth should return current screen width',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.screenWidth, 375.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('screenHeight should return current screen height',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.screenHeight, 812.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('isPortrait should return true when height > width',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812),
              // Flutter automatically sets orientation based on size
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.isPortrait, true);
                expect(responsive.isLandscape, false);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('isLandscape should return true when width > height',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(812, 375),
              // Flutter automatically sets orientation based on size
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.isLandscape, true);
                expect(responsive.isPortrait, false);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('Device category updates on screen size change', () {
      testWidgets('should update device category when screen width changes',
          (WidgetTester tester) async {
        // Start with mobile
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.mobile);
                return const SizedBox();
              },
            ),
          ),
        );

        // Change to tablet
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.tablet);
                return const SizedBox();
              },
            ),
          ),
        );

        // Change to desktop
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1920, 1080)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.desktop);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });
  });
}
