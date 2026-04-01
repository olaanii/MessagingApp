import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat/presentation/theme/responsive_system.dart';

void main() {
  group('ResponsiveSystem - Safe Area Padding', () {
    group('safePadding', () {
      testWidgets('should return MediaQuery padding',
          (WidgetTester tester) async {
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
    });

    group('bottomSafeArea', () {
      testWidgets('should return bottom padding from MediaQuery',
          (WidgetTester tester) async {
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
    });

    group('topSafeArea', () {
      testWidgets('should return top padding from MediaQuery',
          (WidgetTester tester) async {
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
    });
  });
}
