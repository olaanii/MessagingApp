import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat/presentation/theme/responsive_system.dart';
import 'package:chat/presentation/theme/device_category.dart';

/// Standalone test file for task 3.3: Orientation-specific spacing adjustments
/// 
/// This test verifies that the spacing() method:
/// - Detects landscape orientation
/// - Applies compact vertical spacing multiplier (0.8) for landscape on mobile
/// - Does NOT apply the multiplier for portrait or for tablet/desktop devices
void main() {
  group('Task 3.3: Orientation-specific spacing adjustments', () {
    testWidgets('should apply compact spacing (0.8x) for landscape on mobile',
        (WidgetTester tester) async {
      // Mobile device in landscape orientation (width > height, width < 600)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(568, 320), // iPhone SE landscape (width > height)
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              expect(responsive.deviceCategory, DeviceCategory.mobile);
              expect(responsive.isLandscape, true);
              
              final spacing = responsive.spacing(16);
              // 16 * (568/375) * 1.0 * 0.8 = 19.387733...
              expect(spacing, closeTo(19.39, 0.01));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should NOT apply compact spacing for portrait on mobile',
        (WidgetTester tester) async {
      // Mobile device in portrait orientation (height > width)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(375, 812), // iPhone portrait (height > width)
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              expect(responsive.deviceCategory, DeviceCategory.mobile);
              expect(responsive.isPortrait, true);
              
              final spacing = responsive.spacing(16);
              // 16 * (375/375) * 1.0 = 16 (no 0.8x multiplier)
              expect(spacing, 16.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should NOT apply compact spacing for landscape on tablet',
        (WidgetTester tester) async {
      // Tablet device in landscape orientation (width > height)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(1024, 768), // iPad landscape (width > height)
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              expect(responsive.deviceCategory, DeviceCategory.tablet);
              expect(responsive.isLandscape, true);
              
              final spacing = responsive.spacing(16);
              // 16 * (1024/375) * 1.2 = 52.4288 (no 0.8x multiplier for tablet)
              expect(spacing, closeTo(52.43, 0.01));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should NOT apply compact spacing for landscape on desktop',
        (WidgetTester tester) async {
      // Desktop device in landscape orientation (width > height)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(1920, 1080), // Desktop landscape (width > height)
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              expect(responsive.deviceCategory, DeviceCategory.desktop);
              expect(responsive.isLandscape, true);
              
              final spacing = responsive.spacing(16);
              // 16 * (1920/375) * 1.4 = 114.688 (no 0.8x multiplier for desktop)
              expect(spacing, closeTo(114.69, 0.01));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should recalculate spacing when orientation changes from portrait to landscape on mobile',
        (WidgetTester tester) async {
      // First render in portrait (height > width)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568), // iPhone SE portrait (height > width, width < 600)
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              expect(responsive.deviceCategory, DeviceCategory.mobile);
              expect(responsive.isPortrait, true);
              
              final spacing = responsive.spacing(16);
              // 16 * (320/375) * 1.0 = 13.653...
              expect(spacing, closeTo(13.65, 0.01));
              return const SizedBox();
            },
          ),
        ),
      );

      // Rotate to landscape (swap width and height, width > height, still < 600)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(568, 320), // iPhone SE landscape (width > height, width < 600)
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              expect(responsive.deviceCategory, DeviceCategory.mobile);
              expect(responsive.isLandscape, true);
              
              final spacing = responsive.spacing(16);
              // 16 * (568/375) * 1.0 * 0.8 = 19.387733...
              expect(spacing, closeTo(19.39, 0.01));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should recalculate spacing when orientation changes from landscape to portrait on mobile',
        (WidgetTester tester) async {
      // First render in landscape (width > height)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(568, 320), // iPhone SE landscape (width > height, < 600)
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              expect(responsive.deviceCategory, DeviceCategory.mobile);
              expect(responsive.isLandscape, true);
              
              final spacing = responsive.spacing(16);
              // 16 * (568/375) * 1.0 * 0.8 = 19.387733...
              expect(spacing, closeTo(19.39, 0.01));
              return const SizedBox();
            },
          ),
        ),
      );

      // Rotate to portrait (height > width)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568), // iPhone SE portrait (height > width)
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              expect(responsive.deviceCategory, DeviceCategory.mobile);
              expect(responsive.isPortrait, true);
              
              final spacing = responsive.spacing(16);
              // 16 * (320/375) * 1.0 = 13.653...
              expect(spacing, closeTo(13.65, 0.01));
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
