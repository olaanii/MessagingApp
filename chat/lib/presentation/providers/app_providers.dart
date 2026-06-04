import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../auth/auth_provider.dart';
import '../../features/auth/application/auth_notifier.dart';
import '../../features/chat/application/chat_ui_notifier.dart';
import '../chat/chat_provider.dart';
import '../onboarding/onboarding_holder.dart';

/// Root auth state; keep alive for the whole app (GoRouter listens for redirects).
final authNotifierProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  final bridge = AuthProvider(ref);
  bridge.syncState(ref.read(authNotifierV2Provider));
  ref.listen<AsyncValue<AuthState>>(authNotifierV2Provider, (_, next) {
    bridge.syncState(next);
  });
  return bridge;
});

/// Chat / inbox / messaging UI state (streams + Firestore-backed lists for now).
final chatNotifierProvider = ChangeNotifierProvider<ChatProvider>((ref) {
  final bridge = ChatProvider(ref);
  bridge.syncState(ref.read(chatUiNotifierProvider));
  ref.listen<ChatUiState>(chatUiNotifierProvider, (_, next) {
    bridge.syncState(next);
  });
  return bridge;
});

/// Overridden in [main] with prefs-backed instance for correct first launch.
final onboardingHolderProvider = ChangeNotifierProvider<OnboardingHolder>((ref) {
  return OnboardingHolder(false);
});
