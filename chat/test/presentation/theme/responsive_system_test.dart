import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat/presentation/theme/responsive_system.dart';
import 'package:chat/presentation/theme/responsive_config.dart';
import 'package:chat/presentation/theme/device_category.dart';

void main() {
  group('ResponsiveSystem', () {
    group('width()', () {
      testWidgets('should scale width proportionally to screen width',
          (WidgetTester tester) async {
        // Reference width is 375px
        // Test with 750px screen (2x scale)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 1334)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final width = responsive.width(100);
                
                // 100 * (750/375) * 1.0 = 200
                expect(width, 200.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should return design width on reference screen size',
          (WidgetTester tester) async {
        // Test with reference width (375px)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: Size(ResponsiveConfig.referenceWidth, 812)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final width = responsive.width(200);
                
                // 200 * (375/375) * 1.0 = 200
                expect(width, 200.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should apply mobile multiplier (1.0) on mobile devices',
          (WidgetTester tester) async {
        // Mobile screen: 400px (< 600px)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.mobile);
                
                final width = responsive.width(100);
                // 100 * (400/375) * 1.0 = 106.666...
                expect(width, closeTo(106.67, 0.01));
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should apply tablet multiplier (1.0) on tablet devices',
          (WidgetTester tester) async {
        // Tablet screen: 768px (between 600 and 1024)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.tablet);
                
                final width = responsive.width(100);
                // 100 * (768/375) * 1.0 = 204.8
                expect(width, closeTo(204.8, 0.01));
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should apply desktop multiplier (1.0) on desktop devices',
          (WidgetTester tester) async {
        // Desktop screen: 1920px (> 1024px)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1920, 1080)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.desktop);
                
                final width = responsive.width(100);
                // 100 * (1920/375) * 1.0 = 512
                expect(width, 512.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should handle zero design width',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 1334)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final width = responsive.width(0);
                
                expect(width, 0.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should handle fractional design widths',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 1334)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final width = responsive.width(50.5);
                
                // 50.5 * (750/375) * 1.0 = 101.0
                expect(width, 101.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should recalculate on screen width change',
          (WidgetTester tester) async {
        // First render with 375px width
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final width = responsive.width(100);
                expect(width, 100.0);
                return const SizedBox();
              },
            ),
          ),
        );

        // Update to 750px width
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 812)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final width = responsive.width(100);
                expect(width, 200.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('height()', () {
      testWidgets('should scale height proportionally to screen height',
          (WidgetTester tester) async {
        // Reference height is 812px
        // Test with 1624px screen (2x scale)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(375, 1624)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final height = responsive.height(100);
                
                // 100 * (1624/812) * 1.0 = 200
                expect(height, 200.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should return design height on reference screen size',
          (WidgetTester tester) async {
        // Test with reference height (812px)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: Size(375, ResponsiveConfig.referenceHeight)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final height = responsive.height(200);
                
                // 200 * (812/812) * 1.0 = 200
                expect(height, 200.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should apply mobile multiplier (1.0) on mobile devices',
          (WidgetTester tester) async {
        // Mobile screen: 400x800
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.mobile);
                
                final height = responsive.height(100);
                // 100 * (800/812) * 1.0 = 98.522...
                expect(height, closeTo(98.52, 0.01));
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should apply tablet multiplier (1.0) on tablet devices',
          (WidgetTester tester) async {
        // Tablet screen: 768x1024
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.tablet);
                
                final height = responsive.height(100);
                // 100 * (1024/812) * 1.0 = 126.108...
                expect(height, closeTo(126.11, 0.01));
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should apply desktop multiplier (1.0) on desktop devices',
          (WidgetTester tester) async {
        // Desktop screen: 1920x1080
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1920, 1080)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.desktop);
                
                final height = responsive.height(100);
                // 100 * (1080/812) * 1.0 = 133.004...
                expect(height, closeTo(133.00, 0.01));
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should handle zero design height',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(375, 1624)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final height = responsive.height(0);
                
                expect(height, 0.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should handle fractional design heights',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(375, 1624)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final height = responsive.height(50.5);
                
                // 50.5 * (1624/812) * 1.0 = 101.0
                expect(height, 101.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should recalculate on screen height change',
          (WidgetTester tester) async {
        // First render with 812px height
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final height = responsive.height(100);
                expect(height, 100.0);
                return const SizedBox();
              },
            ),
          ),
        );

        // Update to 1624px height
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(375, 1624)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final height = responsive.height(100);
                expect(height, 200.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('spacing()', () {
      testWidgets('should scale spacing proportionally to screen width',
          (WidgetTester tester) async {
        // Reference width is 375px
        // Test with 750px tablet screen (2x scale, 1.2 spacing scale)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 1334)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.tablet);
                
                final spacing = responsive.spacing(16);
                // 16 * (750/375) * 1.2 = 38.4
                expect(spacing, 38.4);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should return design spacing on reference screen size',
          (WidgetTester tester) async {
        // Test with reference width (375px) - mobile device
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: Size(ResponsiveConfig.referenceWidth, 812)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.mobile);
                
                final spacing = responsive.spacing(16);
                // 16 * (375/375) * 1.0 = 16
                expect(spacing, 16.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should apply mobile spacing scale (1.0) on mobile devices',
          (WidgetTester tester) async {
        // Mobile screen: 400px (< 600px)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.mobile);
                
                final spacing = responsive.spacing(16);
                // 16 * (400/375) * 1.0 = 17.066...
                expect(spacing, closeTo(17.07, 0.01));
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should apply tablet spacing scale (1.2) on tablet devices',
          (WidgetTester tester) async {
        // Tablet screen: 768px (between 600 and 1024)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.tablet);
                
                final spacing = responsive.spacing(16);
                // 16 * (768/375) * 1.2 = 39.3216
                expect(spacing, closeTo(39.32, 0.01));
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should apply desktop spacing scale (1.4) on desktop devices',
          (WidgetTester tester) async {
        // Desktop screen: 1440px (> 1024px)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1440, 900)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.desktop);
                
                final spacing = responsive.spacing(16);
                // 16 * (1440/375) * 1.4 = 86.016
                expect(spacing, closeTo(86.02, 0.01));
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should handle zero design spacing',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 1334)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final spacing = responsive.spacing(0);
                
                expect(spacing, 0.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should handle fractional design spacing',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 1334)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.tablet);
                
                final spacing = responsive.spacing(8.5);
                // 8.5 * (750/375) * 1.2 = 20.4
                expect(spacing, 20.4);
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
            data: const MediaQueryData(size: Size(375, 812)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.mobile);
                
                final spacing = responsive.spacing(16);
                // 16 * (375/375) * 1.0 = 16
                expect(spacing, 16.0);
                return const SizedBox();
              },
            ),
          ),
        );

        // Update to 768px width (tablet)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.tablet);
                
                final spacing = responsive.spacing(16);
                // 16 * (768/375) * 1.2 = 39.3216
                expect(spacing, closeTo(39.32, 0.01));
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
            data: const MediaQueryData(size: Size(500, 800)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.mobile);
                
                final spacing = responsive.spacing(16);
                // 16 * (500/375) * 1.0 = 21.333...
                expect(spacing, closeTo(21.33, 0.01));
                return const SizedBox();
              },
            ),
          ),
        );

        // Desktop device (> 1024px)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1440, 900)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.desktop);
                
                final spacing = responsive.spacing(16);
                // 16 * (1440/375) * 1.4 = 86.016
                expect(spacing, closeTo(86.02, 0.01));
                return const SizedBox();
              },
            ),
          ),
        );
      });

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
                // 16 * (1024/375) * 1.2 = 52.4288
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

    group('iconSize()', () {
      testWidgets('should scale icon size proportionally to screen width',
          (WidgetTester tester) async {
        // Reference width is 375px
        // Test with 750px screen (2x scale)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 1334)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final iconSize = responsive.iconSize(24);
                
                // 24 * (750/375) * 1.0 = 48
                expect(iconSize, 48.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should return design icon size on reference screen size',
          (WidgetTester tester) async {
        // Test with reference width (375px)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: Size(ResponsiveConfig.referenceWidth, 812)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final iconSize = responsive.iconSize(24);
                
                // 24 * (375/375) * 1.0 = 24
                expect(iconSize, 24.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should apply mobile multiplier (1.0) on mobile devices',
          (WidgetTester tester) async {
        // Mobile screen: 400px (< 600px)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.mobile);
                
                final iconSize = responsive.iconSize(24);
                // 24 * (400/375) * 1.0 = 25.6
                expect(iconSize, 25.6);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should apply tablet multiplier (1.0) on tablet devices',
          (WidgetTester tester) async {
        // Tablet screen: 768px (between 600 and 1024)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.tablet);
                
                final iconSize = responsive.iconSize(24);
                // 24 * (768/375) * 1.0 = 49.152
                expect(iconSize, closeTo(49.15, 0.01));
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should apply desktop multiplier (1.0) on desktop devices',
          (WidgetTester tester) async {
        // Desktop screen: 1920px (> 1024px)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1920, 1080)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.desktop);
                
                final iconSize = responsive.iconSize(24);
                // 24 * (1920/375) * 1.0 = 122.88
                expect(iconSize, 122.88);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should handle zero design icon size',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 1334)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final iconSize = responsive.iconSize(0);
                
                expect(iconSize, 0.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should handle fractional design icon sizes',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 1334)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final iconSize = responsive.iconSize(20.5);
                
                // 20.5 * (750/375) * 1.0 = 41.0
                expect(iconSize, 41.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should recalculate on screen width change',
          (WidgetTester tester) async {
        // First render with 375px width
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final iconSize = responsive.iconSize(24);
                expect(iconSize, 24.0);
                return const SizedBox();
              },
            ),
          ),
        );

        // Update to 750px width
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 812)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final iconSize = responsive.iconSize(24);
                expect(iconSize, 48.0);
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
            data: const MediaQueryData(size: Size(500, 800)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.mobile);
                
                final iconSize = responsive.iconSize(24);
                // 24 * (500/375) * 1.0 = 32
                expect(iconSize, 32.0);
                return const SizedBox();
              },
            ),
          ),
        );

        // Desktop device (> 1024px)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1440, 900)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.desktop);
                
                final iconSize = responsive.iconSize(24);
                // 24 * (1440/375) * 1.0 = 92.16
                expect(iconSize, 92.16);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('radius()', () {
      testWidgets('should scale radius proportionally to screen width',
          (WidgetTester tester) async {
        // Reference width is 375px
        // Test with 750px screen (2x scale)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 1334)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final radius = responsive.radius(8);
                
                // 8 * (750/375) * 1.0 = 16
                expect(radius, 16.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should return design radius on reference screen size',
          (WidgetTester tester) async {
        // Test with reference width (375px)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: Size(ResponsiveConfig.referenceWidth, 812)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final radius = responsive.radius(8);
                
                // 8 * (375/375) * 1.0 = 8
                expect(radius, 8.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should apply mobile multiplier (1.0) on mobile devices',
          (WidgetTester tester) async {
        // Mobile screen: 400px (< 600px)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.mobile);
                
                final radius = responsive.radius(8);
                // 8 * (400/375) * 1.0 = 8.533...
                expect(radius, closeTo(8.53, 0.01));
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should apply tablet multiplier (1.0) on tablet devices',
          (WidgetTester tester) async {
        // Tablet screen: 768px (between 600 and 1024)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.tablet);
                
                final radius = responsive.radius(8);
                // 8 * (768/375) * 1.0 = 16.384
                expect(radius, closeTo(16.38, 0.01));
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should apply desktop multiplier (1.0) on desktop devices',
          (WidgetTester tester) async {
        // Desktop screen: 1920px (> 1024px)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1920, 1080)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.desktop);
                
                final radius = responsive.radius(8);
                // 8 * (1920/375) * 1.0 = 40.96
                expect(radius, 40.96);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should handle zero design radius',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 1334)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final radius = responsive.radius(0);
                
                expect(radius, 0.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should handle fractional design radius',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 1334)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final radius = responsive.radius(4.5);
                
                // 4.5 * (750/375) * 1.0 = 9.0
                expect(radius, 9.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should recalculate on screen width change',
          (WidgetTester tester) async {
        // First render with 375px width
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final radius = responsive.radius(8);
                expect(radius, 8.0);
                return const SizedBox();
              },
            ),
          ),
        );

        // Update to 750px width
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 812)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final radius = responsive.radius(8);
                expect(radius, 16.0);
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
            data: const MediaQueryData(size: Size(500, 800)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.mobile);
                
                final radius = responsive.radius(8);
                // 8 * (500/375) * 1.0 = 10.666...
                expect(radius, closeTo(10.67, 0.01));
                return const SizedBox();
              },
            ),
          ),
        );

        // Desktop device (> 1024px)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1440, 900)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.desktop);
                
                final radius = responsive.radius(8);
                // 8 * (1440/375) * 1.0 = 30.72
                expect(radius, 30.72);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('safePadding', () {
      testWidgets('should return MediaQuery padding',
          (WidgetTester tester) async {
        // Test with specific padding values
        const testPadding = EdgeInsets.only(
          top: 44.0,
          bottom: 34.0,
          left: 0.0,
          right: 0.0,
        );

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812),
              padding: testPadding,
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final padding = responsive.safePadding;

                expect(padding, testPadding);
                expect(padding.top, 44.0);
                expect(padding.bottom, 34.0);
                expect(padding.left, 0.0);
                expect(padding.right, 0.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should return zero padding when no safe areas',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812),
              padding: EdgeInsets.zero,
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final padding = responsive.safePadding;

                expect(padding, EdgeInsets.zero);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should update when MediaQuery padding changes',
          (WidgetTester tester) async {
        // First render with specific padding
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812),
              padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final padding = responsive.safePadding;

                expect(padding.top, 20.0);
                expect(padding.bottom, 10.0);
                return const SizedBox();
              },
            ),
          ),
        );

        // Update with different padding
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812),
              padding: EdgeInsets.only(top: 44.0, bottom: 34.0),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final padding = responsive.safePadding;

                expect(padding.top, 44.0);
                expect(padding.bottom, 34.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('bottomSafeArea', () {
      testWidgets('should return bottom padding from MediaQuery',
          (WidgetTester tester) async {
        // Test with iPhone X-style bottom safe area (34px)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812),
              padding: EdgeInsets.only(bottom: 34.0),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final bottomSafeArea = responsive.bottomSafeArea;

                expect(bottomSafeArea, 34.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should return zero when no bottom safe area',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812),
              padding: EdgeInsets.zero,
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final bottomSafeArea = responsive.bottomSafeArea;

                expect(bottomSafeArea, 0.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should update when bottom padding changes',
          (WidgetTester tester) async {
        // First render with 10px bottom padding
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812),
              padding: EdgeInsets.only(bottom: 10.0),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.bottomSafeArea, 10.0);
                return const SizedBox();
              },
            ),
          ),
        );

        // Update to 34px bottom padding
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812),
              padding: EdgeInsets.only(bottom: 34.0),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.bottomSafeArea, 34.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should work across different device categories',
          (WidgetTester tester) async {
        // Mobile device with bottom safe area
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(400, 800),
              padding: EdgeInsets.only(bottom: 34.0),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.mobile);
                expect(responsive.bottomSafeArea, 34.0);
                return const SizedBox();
              },
            ),
          ),
        );

        // Tablet device with bottom safe area
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(768, 1024),
              padding: EdgeInsets.only(bottom: 20.0),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.tablet);
                expect(responsive.bottomSafeArea, 20.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('topSafeArea', () {
      testWidgets('should return top padding from MediaQuery',
          (WidgetTester tester) async {
        // Test with status bar height (44px on iPhone X)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812),
              padding: EdgeInsets.only(top: 44.0),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final topSafeArea = responsive.topSafeArea;

                expect(topSafeArea, 44.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should return zero when no top safe area',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812),
              padding: EdgeInsets.zero,
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final topSafeArea = responsive.topSafeArea;

                expect(topSafeArea, 0.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should update when top padding changes',
          (WidgetTester tester) async {
        // First render with 20px top padding
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812),
              padding: EdgeInsets.only(top: 20.0),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.topSafeArea, 20.0);
                return const SizedBox();
              },
            ),
          ),
        );

        // Update to 44px top padding
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812),
              padding: EdgeInsets.only(top: 44.0),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.topSafeArea, 44.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should work across different device categories',
          (WidgetTester tester) async {
        // Mobile device with top safe area
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(400, 800),
              padding: EdgeInsets.only(top: 44.0),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.mobile);
                expect(responsive.topSafeArea, 44.0);
                return const SizedBox();
              },
            ),
          ),
        );

        // Tablet device with top safe area
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(768, 1024),
              padding: EdgeInsets.only(top: 24.0),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.tablet);
                expect(responsive.topSafeArea, 24.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('textScaleFactor', () {
      testWidgets('should return textScaleFactor from MediaQuery when within bounds',
          (WidgetTester tester) async {
        // Test with normal text scale factor (1.5)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812), textScaler: TextScaler.linear(1.5),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final textScale = responsive.textScaleFactor;

                expect(textScale, 1.5);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should clamp textScaleFactor to minimum of 1.0',
          (WidgetTester tester) async {
        // Test with text scale factor below minimum (0.8)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812), textScaler: TextScaler.linear(0.8),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final textScale = responsive.textScaleFactor;

                // Should be clamped to 1.0
                expect(textScale, 1.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should clamp textScaleFactor to maximum of 2.0',
          (WidgetTester tester) async {
        // Test with text scale factor above maximum (2.5)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812), textScaler: TextScaler.linear(2.5),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final textScale = responsive.textScaleFactor;

                // Should be clamped to 2.0 (ResponsiveConfig.maxTextScaleFactor)
                expect(textScale, 2.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should return 1.0 for default textScaleFactor',
          (WidgetTester tester) async {
        // Test with default text scale factor (1.0)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812), textScaler: TextScaler.linear(1.0),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final textScale = responsive.textScaleFactor;

                expect(textScale, 1.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should return 2.0 for textScaleFactor at maximum boundary',
          (WidgetTester tester) async {
        // Test with text scale factor exactly at maximum (2.0)
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812), textScaler: TextScaler.linear(2.0),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                final textScale = responsive.textScaleFactor;

                expect(textScale, 2.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should update when textScaleFactor changes',
          (WidgetTester tester) async {
        // First render with 1.0 text scale
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812), textScaler: TextScaler.linear(1.0),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.textScaleFactor, 1.0);
                return const SizedBox();
              },
            ),
          ),
        );

        // Update to 1.5 text scale
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812), textScaler: TextScaler.linear(1.5),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.textScaleFactor, 1.5);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('should work across different device categories',
          (WidgetTester tester) async {
        // Mobile device with text scale factor
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(400, 800), textScaler: TextScaler.linear(1.5),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.mobile);
                expect(responsive.textScaleFactor, 1.5);
                return const SizedBox();
              },
            ),
          ),
        );

        // Tablet device with text scale factor
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(768, 1024), textScaler: TextScaler.linear(1.8),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.tablet);
                expect(responsive.textScaleFactor, 1.8);
                return const SizedBox();
              },
            ),
          ),
        );

        // Desktop device with text scale factor above max
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(1920, 1080), textScaler: TextScaler.linear(3.0),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                expect(responsive.deviceCategory, DeviceCategory.desktop);
                // Should be clamped to 2.0
                expect(responsive.textScaleFactor, 2.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('ResponsiveExtension', () {
    group('responsive getter', () {
      testWidgets('should return ResponsiveSystem instance',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)),
            child: Builder(
              builder: (context) {
                final responsive = context.responsive;
                expect(responsive, isA<ResponsiveSystem>());
                expect(responsive.screenWidth, 375.0);
                expect(responsive.screenHeight, 812.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('shorthand methods', () {
      testWidgets('rw() should calculate responsive width',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 1334)),
            child: Builder(
              builder: (context) {
                final width = context.rw(100);
                // 100 * (750/375) * 1.0 = 200
                expect(width, 200.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('rh() should calculate responsive height',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(375, 1624)),
            child: Builder(
              builder: (context) {
                final height = context.rh(100);
                // 100 * (1624/812) * 1.0 = 200
                expect(height, 200.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('rf() should calculate responsive font size',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(750, 1334), textScaler: TextScaler.linear(1.0),
            ),
            child: Builder(
              builder: (context) {
                final fontSize = context.rf(16);
                // 16 * (750/375) * 1.2 * 1.0 = 38.4
                expect(fontSize, 38.4);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('rs() should calculate responsive spacing',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 1334)),
            child: Builder(
              builder: (context) {
                final spacing = context.rs(16);
                // 16 * (750/375) * 1.2 = 38.4
                expect(spacing, 38.4);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('ri() should calculate responsive icon size',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 1334)),
            child: Builder(
              builder: (context) {
                final iconSize = context.ri(24);
                // 24 * (750/375) * 1.0 = 48
                expect(iconSize, 48.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('rr() should calculate responsive border radius',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 1334)),
            child: Builder(
              builder: (context) {
                final radius = context.rr(8);
                // 8 * (750/375) * 1.0 = 16
                expect(radius, 16.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('shorthand methods should match ResponsiveSystem methods',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(768, 1024), textScaler: TextScaler.linear(1.0),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                
                // Verify all shorthand methods match ResponsiveSystem methods
                expect(context.rw(100), responsive.width(100));
                expect(context.rh(100), responsive.height(100));
                expect(context.rf(16), responsive.fontSize(16));
                expect(context.rs(16), responsive.spacing(16));
                expect(context.ri(24), responsive.iconSize(24));
                expect(context.rr(8), responsive.radius(8));
                
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('device category check getters', () {
      testWidgets('isMobile should return true for mobile devices',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                expect(context.isMobile, true);
                expect(context.isTablet, false);
                expect(context.isDesktop, false);
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
                expect(context.isMobile, false);
                expect(context.isTablet, true);
                expect(context.isDesktop, false);
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
                expect(context.isMobile, false);
                expect(context.isTablet, false);
                expect(context.isDesktop, true);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('device category getters should match ResponsiveSystem',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                
                // Verify all device category getters match ResponsiveSystem
                expect(context.isMobile, responsive.isMobile);
                expect(context.isTablet, responsive.isTablet);
                expect(context.isDesktop, responsive.isDesktop);
                
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('device category getters should update on screen size change',
          (WidgetTester tester) async {
        // Mobile device
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                expect(context.isMobile, true);
                expect(context.isTablet, false);
                expect(context.isDesktop, false);
                return const SizedBox();
              },
            ),
          ),
        );

        // Tablet device
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                expect(context.isMobile, false);
                expect(context.isTablet, true);
                expect(context.isDesktop, false);
                return const SizedBox();
              },
            ),
          ),
        );

        // Desktop device
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1920, 1080)),
            child: Builder(
              builder: (context) {
                expect(context.isMobile, false);
                expect(context.isTablet, false);
                expect(context.isDesktop, true);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('integration with ResponsiveSystem', () {
      testWidgets('extension should provide same results as direct ResponsiveSystem usage',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(1440, 900), textScaler: TextScaler.linear(1.2),
            ),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveSystem(context);
                
                // Test all methods
                expect(context.rw(200), responsive.width(200));
                expect(context.rh(150), responsive.height(150));
                expect(context.rf(18), responsive.fontSize(18));
                expect(context.rs(24), responsive.spacing(24));
                expect(context.ri(32), responsive.iconSize(32));
                expect(context.rr(12), responsive.radius(12));
                
                // Test device category
                expect(context.isMobile, responsive.isMobile);
                expect(context.isTablet, responsive.isTablet);
                expect(context.isDesktop, responsive.isDesktop);
                
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('extension should work in real widget tree',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(750, 1334)),
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Container(
                      width: context.rw(200),
                      height: context.rh(100),
                      padding: EdgeInsets.all(context.rs(16)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(context.rr(8)),
                      ),
                      child: Text(
                        'Test',
                        style: TextStyle(fontSize: context.rf(16)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Verify widget renders without errors
        expect(find.text('Test'), findsOneWidget);
        });
      });
    });
  });
}
