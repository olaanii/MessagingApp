import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/create_profile_screen.dart';
import '../auth/otp_verification_screen.dart';
import '../auth/phone_entry_screen.dart';
import '../chat/backup_restore_screen.dart';
import '../chat/chat_detail_screen.dart';
import '../chat/contacts_screen.dart';
import '../chat/device_manager_screen.dart';
import '../chat/global_search_screen.dart';
import '../chat/group_creation_screen.dart';
import '../chat/inbox_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../settings/settings_screen.dart';
import 'app_providers.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.read(authNotifierProvider);
  final onboarding = ref.read(onboardingHolderProvider);
  final router = GoRouter(
    initialLocation: onboarding.completed ? '/' : '/onboarding',
    refreshListenable: Listenable.merge([auth, onboarding]),
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = auth.isAuthenticated;
      final String loc = state.matchedLocation;

      if (loggedIn) {
        if (loc == '/onboarding') {
          return '/inbox';
        }
        final bool onPhoneAuth = loc == '/' || loc == '/otp' || loc == '/profile';
        if (onPhoneAuth) {
          return '/inbox';
        }
        return null;
      }

      if (!onboarding.completed) {
        if (loc != '/onboarding') {
          return '/onboarding';
        }
        return null;
      }

      final bool isAuthRoute =
          loc == '/' || loc == '/otp' || loc == '/profile';
      if (!isAuthRoute) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const PhoneEntryScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const CreateProfileScreen(),
      ),
      GoRoute(
        path: '/inbox',
        builder: (context, state) => const InboxScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const GlobalSearchScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ChatDetailScreen(chatId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/devices',
        builder: (context, state) => const DeviceManagerScreen(),
      ),
      GoRoute(
        path: '/settings/backup',
        builder: (context, state) => const BackupRestoreScreen(),
      ),
      GoRoute(
        path: '/contacts',
        builder: (context, state) => const ContactsScreen(),
      ),
      GoRoute(
        path: '/new-group',
        builder: (context, state) => const GroupCreationScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
