import 'package:chat/presentation/auth/phone_entry_screen.dart';
import 'package:chat/presentation/onboarding/onboarding_holder.dart';
import 'package:chat/presentation/onboarding/onboarding_screen.dart';
import 'package:chat/presentation/providers/app_providers.dart';
import 'package:chat/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Onboarding welcome screen shows', (WidgetTester tester) async {
    final holder = OnboardingHolder(false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingHolderProvider.overrideWith(
            (ref) => holder,
            disposeNotifier: false,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const OnboardingScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Connect Smarter'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Phone entry screen loads (onboarding completed)', (
    WidgetTester tester,
  ) async {
    final onboardingDone = OnboardingHolder(true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingHolderProvider.overrideWith(
            (ref) => onboardingDone,
            disposeNotifier: false,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const PhoneEntryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Enter phone number'), findsOneWidget);
  });
}
