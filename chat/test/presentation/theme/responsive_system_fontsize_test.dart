import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat/presentation/theme/responsive_system.dart';
import 'package:chat/presentation/theme/responsive_config.dart';
import 'package:chat/presentation/theme/device_category.dart';

void main() {
  group('ResponsiveSystem - fontSize()', () {
    testWidgets('should calculate base font size using widthScale',
        (WidgetTester tester) async {
      // Reference width is 375px
      // Test with 750px screen (2x scale)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(750, 1334),
            textScaler: 1.0,
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              final fontSize = responsive.fontSize(16);

              // Step 1: baseFontSize = 16 * (750/375) = 32
              // Step 2: scaledFontSize = 32 * 1.15 (tablet scale) = 36.8
              // Step 3: accessibleFontSize = 36.8 * 1.0 = 36.8
              // Step 4: finalFontSize = clamp(36.8, 12, 48) = 36.8
              expect(fontSize, 36.8);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should apply mobile typography scale factor (1.0)',
        (WidgetTester tester) async {
      // Mobile screen: 400px (< 600px)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(400, 800),
            textScaler: 1.0,
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              expect(responsive.deviceCategory, DeviceCategory.mobile);

              final fontSize = responsive.fontSize(16);
              // Step 1: baseFontSize = 16 * (400/375) = 17.066...
              // Step 2: scaledFontSize = 17.066... * 1.0 (mobile scale) = 17.066...
              // Step 3: accessibleFontSize = 17.066... * 1.0 = 17.066...
              // Step 4: finalFontSize = clamp(17.066..., 12, 48) = 17.066...
              expect(fontSize, closeTo(17.07, 0.01));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should apply tablet typography scale factor (1.15)',
        (WidgetTester tester) async {
      // Tablet screen: 768px (between 600 and 1024)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(768, 1024),
            textScaler: 1.0,
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              expect(responsive.deviceCategory, DeviceCategory.tablet);

              final fontSize = responsive.fontSize(16);
              // Step 1: baseFontSize = 16 * (768/375) = 32.768
              // Step 2: scaledFontSize = 32.768 * 1.15 (tablet scale) = 37.6832
              // Step 3: accessibleFontSize = 37.6832 * 1.0 = 37.6832
              // Step 4: finalFontSize = clamp(37.6832, 12, 48) = 37.6832
              expect(fontSize, closeTo(37.68, 0.01));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should apply desktop typography scale factor (1.25)',
        (WidgetTester tester) async {
      // Desktop screen: 1440px (> 1024px)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(1440, 900),
            textScaler: 1.0,
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              expect(responsive.deviceCategory, DeviceCategory.desktop);

              final fontSize = responsive.fontSize(16);
              // Step 1: baseFontSize = 16 * (1440/375) = 61.44
              // Step 2: scaledFontSize = 61.44 * 1.25 (desktop scale) = 76.8
              // Step 3: accessibleFontSize = 76.8 * 1.0 = 76.8
              // Step 4: finalFontSize = clamp(76.8, 12, 48) = 48 (clamped to max)
              expect(fontSize, 48.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should apply textScaler from MediaQuery',
        (WidgetTester tester) async {
      // Test with 1.5x text scale factor for accessibility
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(375, 812),
            textScaler: 1.5,
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              final fontSize = responsive.fontSize(16);

              // Step 1: baseFontSize = 16 * (375/375) = 16
              // Step 2: scaledFontSize = 16 * 1.0 (mobile scale) = 16
              // Step 3: accessibleFontSize = 16 * 1.5 = 24
              // Step 4: finalFontSize = clamp(24, 12, 48) = 24
              expect(fontSize, 24.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should clamp textScaler to maxtextScaler',
        (WidgetTester tester) async {
      // Test with 3.0x text scale factor (should be clamped to 2.0)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(375, 812),
            textScaler: 3.0,
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              final fontSize = responsive.fontSize(16);

              // Step 1: baseFontSize = 16 * (375/375) = 16
              // Step 2: scaledFontSize = 16 * 1.0 (mobile scale) = 16
              // Step 3: accessibleFontSize = 16 * 2.0 (clamped from 3.0) = 32
              // Step 4: finalFontSize = clamp(32, 12, 48) = 32
              expect(fontSize, 32.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should clamp result to minFontSize',
        (WidgetTester tester) async {
      // Test with very small screen and font size
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(200, 400),
            textScaler: 1.0,
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              final fontSize = responsive.fontSize(8);

              // Step 1: baseFontSize = 8 * (200/375) = 4.266...
              // Step 2: scaledFontSize = 4.266... * 1.0 (mobile scale) = 4.266...
              // Step 3: accessibleFontSize = 4.266... * 1.0 = 4.266...
              // Step 4: finalFontSize = clamp(4.266..., 12, 48) = 12 (clamped to min)
              expect(fontSize, ResponsiveConfig.minFontSize);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should clamp result to maxFontSize',
        (WidgetTester tester) async {
      // Test with very large screen and font size
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(2560, 1440),
            textScaler: 1.0,
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              final fontSize = responsive.fontSize(32);

              // Step 1: baseFontSize = 32 * (2560/375) = 218.453...
              // Step 2: scaledFontSize = 218.453... * 1.25 (desktop scale) = 273.066...
              // Step 3: accessibleFontSize = 273.066... * 1.0 = 273.066...
              // Step 4: finalFontSize = clamp(273.066..., 12, 48) = 48 (clamped to max)
              expect(fontSize, ResponsiveConfig.maxFontSize);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return design font size on reference screen size',
        (WidgetTester tester) async {
      // Test with reference width (375px) - mobile device
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(ResponsiveConfig.referenceWidth, 812),
            textScaler: 1.0,
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              expect(responsive.deviceCategory, DeviceCategory.mobile);

              final fontSize = responsive.fontSize(16);
              // Step 1: baseFontSize = 16 * (375/375) = 16
              // Step 2: scaledFontSize = 16 * 1.0 (mobile scale) = 16
              // Step 3: accessibleFontSize = 16 * 1.0 = 16
              // Step 4: finalFontSize = clamp(16, 12, 48) = 16
              expect(fontSize, 16.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should handle zero design font size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(750, 1334),
            textScaler: 1.0,
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              final fontSize = responsive.fontSize(0);

              // Step 1: baseFontSize = 0 * (750/375) = 0
              // Step 2: scaledFontSize = 0 * 1.2 = 0
              // Step 3: accessibleFontSize = 0 * 1.0 = 0
              // Step 4: finalFontSize = clamp(0, 12, 48) = 12 (clamped to min)
              expect(fontSize, ResponsiveConfig.minFontSize);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should handle fractional design font sizes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(750, 1334),
            textScaler: 1.0,
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              final fontSize = responsive.fontSize(14.5);

              // Step 1: baseFontSize = 14.5 * (750/375) = 29
              // Step 2: scaledFontSize = 29 * 1.15 (tablet scale) = 33.35
              // Step 3: accessibleFontSize = 33.35 * 1.0 = 33.35
              // Step 4: finalFontSize = clamp(33.35, 12, 48) = 33.35
              expect(fontSize, closeTo(33.35, 0.01));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should recalculate on screen width change',
        (WidgetTester tester) async {
      // First render with 375px width (mobile)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(375, 812),
            textScaler: 1.0,
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              final fontSize = responsive.fontSize(16);
              expect(fontSize, 16.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Update to 768px width (tablet)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(768, 1024),
            textScaler: 1.0,
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              final fontSize = responsive.fontSize(16);
              // 16 * (768/375) * 1.15 = 37.6832
              expect(fontSize, closeTo(37.68, 0.01));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should recalculate on device category change',
        (WidgetTester tester) async {
      // Mobile device (< 600px)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(500, 800),
            textScaler: 1.0,
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              expect(responsive.deviceCategory, DeviceCategory.mobile);

              final fontSize = responsive.fontSize(16);
              // 16 * (500/375) * 1.0 = 21.333...
              expect(fontSize, closeTo(21.33, 0.01));
              return const SizedBox();
            },
          ),
        ),
      );

      // Desktop device (> 1024px)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(1440, 900),
            textScaler: 1.0,
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              expect(responsive.deviceCategory, DeviceCategory.desktop);

              final fontSize = responsive.fontSize(16);
              // 16 * (1440/375) * 1.25 = 76.8, clamped to 48
              expect(fontSize, 48.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should combine all factors correctly',
        (WidgetTester tester) async {
      // Test with tablet screen, 1.5x text scale
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(768, 1024),
            textScaler: 1.5,
          ),
          child: Builder(
            builder: (context) {
              final responsive = ResponsiveSystem(context);
              expect(responsive.deviceCategory, DeviceCategory.tablet);

              final fontSize = responsive.fontSize(14);
              // Step 1: baseFontSize = 14 * (768/375) = 28.672
              // Step 2: scaledFontSize = 28.672 * 1.15 (tablet scale) = 32.9728
              // Step 3: accessibleFontSize = 32.9728 * 1.5 = 49.4592
              // Step 4: finalFontSize = clamp(49.4592, 12, 48) = 48 (clamped to max)
              expect(fontSize, 48.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
