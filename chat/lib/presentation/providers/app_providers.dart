import 'package:flutter_riverpod/legacy.dart';

import '../auth/auth_provider.dart';
import '../chat/chat_provider.dart';
import '../onboarding/onboarding_holder.dart';

/// Root auth state; keep alive for the whole app (GoRouter listens for redirects).
final authNotifierProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider();
});

/// Chat / inbox / messaging UI state (streams + Firestore-backed lists for now).
final chatNotifierProvider = ChangeNotifierProvider<ChatProvider>((ref) {
  return ChatProvider();
});

/// Overridden in [main] with prefs-backed instance for correct first launch.
final onboardingHolderProvider = ChangeNotifierProvider<OnboardingHolder>((ref) {
  return OnboardingHolder(false);
});
