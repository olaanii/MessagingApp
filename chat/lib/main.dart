import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/platform/fcm_background_handler.dart';
import 'core/platform/fcm_platform_service.dart';
import 'data/services/fcm_token_sync.dart';
import 'firebase_options.dart';
import 'presentation/auth/auth_provider.dart';
import 'presentation/onboarding/onboarding_holder.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/providers/go_router_provider.dart';
import 'presentation/theme/app_theme.dart';

bool _isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final onboardingDone =
      prefs.getBool(OnboardingHolder.prefsKey) ?? false;
  final onboardingHolder = OnboardingHolder(onboardingDone);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _isFirebaseInitialized = true;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
    _isFirebaseInitialized = false;
  }

  runApp(
    ProviderScope(
      overrides: [
        onboardingHolderProvider.overrideWith(
          (ref) => onboardingHolder,
          disposeNotifier: false,
        ),
      ],
      child: MessagingApp(isFirebaseInitialized: _isFirebaseInitialized),
    ),
  );
}

class MessagingApp extends ConsumerStatefulWidget {
  final bool isFirebaseInitialized;
  const MessagingApp({super.key, required this.isFirebaseInitialized});

  @override
  ConsumerState<MessagingApp> createState() => _MessagingAppState();
}

class _MessagingAppState extends ConsumerState<MessagingApp> {
  FcmPlatformService? _push;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isFirebaseInitialized) return;
      unawaited(_syncPushFromAuth(ref.read(authNotifierProvider)));
    });
  }

  @override
  void dispose() {
    _push?.dispose();
    super.dispose();
  }

  Future<void> _syncPushFromAuth(AuthProvider auth) async {
    if (!widget.isFirebaseInitialized || _push == null) {
      return;
    }
    if (!auth.isAuthenticated) {
      await _push!.resetSession();
      return;
    }
    final uid = auth.user?.id ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }
    await _push!.startSession(uid);
    _push!.flushPendingNavigation();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isFirebaseInitialized && identical(0, 0.0)) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 64, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    'Firebase Config Missing',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please run "flutterfire configure" to set up your web configurations.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Continue (Services will be disabled)'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final router = ref.watch(goRouterProvider);

    if (widget.isFirebaseInitialized) {
      _push ??= FcmPlatformService(
        router: router,
        isAuthenticated: () => ref.read(authNotifierProvider).isAuthenticated,
        publishToken: (userId, token) => syncFcmTokenToFirestore(
          userId: userId,
          token: token,
        ),
      );
    }

    ref.listen<AuthProvider>(authNotifierProvider, (previous, auth) {
      if (!widget.isFirebaseInitialized) return;
      unawaited(_syncPushFromAuth(auth));
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Messaging App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
