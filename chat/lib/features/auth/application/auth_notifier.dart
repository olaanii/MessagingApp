import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/crypto/e2ee_identity_store.dart';
import '../../../core/device/device_id_service.dart';
import '../../../core/serverpod/serverpod_auth_key_manager.dart';
import '../../../core/serverpod/serverpod_client_provider.dart';
import '../../../core/sync/messaging_backend.dart';
import '../../../data/services/auth_service.dart';
import '../../../domain/models/user_model.dart';
import '../data/serverpod_auth_repository.dart';

// ── AuthState ─────────────────────────────────────────────────────────────────

/// Immutable snapshot of the authentication state.
sealed class AuthState {
  const AuthState();
}

/// No user is signed in.
final class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

/// OTP has been sent, waiting for user to enter code.
final class AuthStateCodeSent extends AuthState {
  const AuthStateCodeSent();
}

/// Sign-in is in progress (OTP send or verify).
final class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

/// A user is fully signed in.
final class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated(this.user);
  final UserModel user;
}

/// An error occurred during sign-in.
final class AuthStateError extends AuthState {
  const AuthStateError(this.message);
  final String message;
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// Provides the [ServerpodAuthKeyManager] singleton.
///
/// Overridable in tests.
final serverpodAuthKeyManagerProvider = Provider<ServerpodAuthKeyManager>(
  (ref) => ServerpodAuthKeyManager(const FlutterSecureStorage()),
);

/// Provides the [E2eeIdentityStore] singleton.
final e2eeIdentityStoreProvider = Provider<E2eeIdentityStore>(
  (ref) => E2eeIdentityStore(),
);

/// Provides the [ServerpodAuthRepository] singleton.
///
/// Overridable in tests via [ProviderScope] overrides.
final serverpodAuthRepositoryProvider = Provider<ServerpodAuthRepository>(
  (ref) {
    final client = ref.watch(serverpodClientProvider);
    final keyManager = ref.watch(serverpodAuthKeyManagerProvider);
    return ServerpodAuthRepositoryImpl(
      client: client,
      authKeyManager: keyManager,
    );
  },
);

/// Provides the [TokenRefreshInterceptor] singleton.
final tokenRefreshInterceptorProvider = Provider<TokenRefreshInterceptor>(
  (ref) {
    final repo = ref.watch(serverpodAuthRepositoryProvider);
    final keyManager = ref.watch(serverpodAuthKeyManagerProvider);
    final interceptor = TokenRefreshInterceptor(
      repository: repo,
      authKeyManager: keyManager,
    );
    ref.onDispose(interceptor.dispose);
    return interceptor;
  },
);

// ── AuthNotifier ──────────────────────────────────────────────────────────────

/// Riverpod notifier that owns the authentication lifecycle.
///
/// Replaces the legacy [AuthProvider] (ChangeNotifier) with an
/// [AsyncNotifier]-based implementation that supports both the Firestore
/// path (legacy) and the Serverpod path (new).
///
/// Requirements: 2.1, 2.7
class AuthNotifier extends AsyncNotifier<AuthState> {
  late final AuthService _authService;
  late final MessagingSyncMode _syncMode;
  StreamSubscription<User?>? _firebaseAuthSub;
  StreamSubscription<AuthEvent>? _authEventSub;

  @override
  Future<AuthState> build() async {
    _authService = AuthService();
    _syncMode = MessagingSyncMode();

    // Listen for session-expired events from the interceptor.
    final interceptor = ref.watch(tokenRefreshInterceptorProvider);
    _authEventSub = interceptor.authEventStream.listen(_onAuthEvent);

    // Mirror Firebase auth state changes.
    _firebaseAuthSub = _authService.authStateChanges.listen(_onFirebaseUser);

    ref.onDispose(() {
      _firebaseAuthSub?.cancel();
      _authEventSub?.cancel();
    });

    // Resolve initial state from Firebase.
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) return const AuthStateUnauthenticated();

    final userModel = await _authService.getUser(firebaseUser.uid);
    if (userModel == null) return const AuthStateUnauthenticated();
    return AuthStateAuthenticated(userModel);
  }

  // ── Firebase auth state listener ──────────────────────────────────────────

  void _onFirebaseUser(User? firebaseUser) async {
    if (firebaseUser == null) {
      state = const AsyncData(AuthStateUnauthenticated());
      return;
    }
    final userModel = await _authService.getUser(firebaseUser.uid);
    if (userModel != null) {
      state = AsyncData(AuthStateAuthenticated(userModel));
    }
  }

  // ── AuthEvent listener ────────────────────────────────────────────────────

  void _onAuthEvent(AuthEvent event) {
    switch (event) {
      case AuthEvent.sessionExpired:
        state = const AsyncData(AuthStateUnauthenticated());
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Send OTP to [phoneNumber].
  Future<void> sendOtp(String phoneNumber) async {
    state = const AsyncLoading();
    await _authService.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (_) {
        state = const AsyncData(AuthStateCodeSent());
      },
      onError: (msg) {
        state = AsyncData(AuthStateError(msg));
      },
    );
  }

  /// Verify OTP and sign in.
  ///
  /// On success with [MessagingSyncMode.useServerpod]: also calls
  /// [ServerpodAuthRepository.exchangeFirebaseToken] then registers the device
  /// and uploads the public key bundle (Requirements 2.1, 8.1, 1.4).
  Future<bool> verifyOtp(String smsCode) async {
    state = const AsyncLoading();
    try {
      final userModel = await _authService.verifyOtpAndSignIn(smsCode);
      if (userModel == null) {
        state = const AsyncData(AuthStateError('Sign-in failed'));
        return false;
      }

      if (_syncMode.useServerpod) {
        await _postSignInServerpodFlow();
      }

      state = AsyncData(AuthStateAuthenticated(userModel));
      return true;
    } catch (e) {
      state = AsyncData(AuthStateError(e.toString()));
      return false;
    }
  }

  /// Update the authenticated user's profile information.
  Future<void> updateProfile({required String name, String? status}) async {
    state = const AsyncLoading();
    try {
      final current = currentUser;
      if (current == null) {
        state = const AsyncData(AuthStateUnauthenticated());
        return;
      }

      final updatedUser = current.copyWith(
        name: name,
        status: status ?? current.status,
      );
      await _authService.updateUser(updatedUser);
      state = AsyncData(AuthStateAuthenticated(updatedUser));
    } catch (e) {
      state = AsyncData(AuthStateError(e.toString()));
    }
  }

  /// Exchange Firebase token, register device, and upload key bundle.
  Future<void> _postSignInServerpodFlow() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;

      final idToken = await firebaseUser.getIdToken();
      if (idToken == null) return;

      final deviceIdSvc = ref.read(deviceIdServiceProvider);
      final deviceId = await deviceIdSvc.getDeviceId();

      final identityStore = ref.read(e2eeIdentityStoreProvider);
      final identity = await identityStore.loadOrCreateIdentity();
      final publicBundle = identityStore.publicBundleFor(identity);

      final authRepo = ref.read(serverpodAuthRepositoryProvider);
      await authRepo.exchangeFirebaseToken(
        firebaseIdToken: idToken,
        deviceId: deviceId,
        publicKeyBundle: publicBundle,
      );

      final client = ref.read(serverpodClientProvider);
      final platform = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
              ? 'ios'
              : 'other';
      await client.device.registerDevice(deviceId, platform, null);

      await client.key.uploadBundle(
        deviceId,
        jsonEncode({
          'v': 1,
          'x25519': base64Encode(publicBundle.x25519Public),
        }),
      );
    } catch (e) {
      // Non-fatal: local auth succeeded; Serverpod flow will retry on next launch.
      debugPrint('[AuthNotifier] Serverpod post-sign-in flow failed: $e');
    }
  }

  /// Sign out.
  ///
  /// When [MessagingSyncMode.useServerpod]: also calls
  /// [ServerpodAuthRepository.logout] (Requirement 2.7).
  Future<void> logout() async {
    if (_syncMode.useServerpod) {
      try {
        final repo = ref.read(serverpodAuthRepositoryProvider);
        // deviceId is not tracked here yet; pass empty string until task 3.1.
        await repo.logout('');
      } catch (_) {
        // Local sign-out must always succeed even if server call fails.
      }
    }
    await _authService.logOut();
    state = const AsyncData(AuthStateUnauthenticated());
  }

  // ── Convenience getters (UI compatibility) ────────────────────────────────

  UserModel? get currentUser {
    final s = state.value;
    return s is AuthStateAuthenticated ? s.user : null;
  }

  bool get isAuthenticated => currentUser != null;

  // ── Safety actions ────────────────────────────────────────────────────────

  /// Block [targetAuthUserId].
  ///
  /// - Serverpod path: calls `client.safety.blockUser` directly.
  /// - Firestore path: delegates to [AuthService.blockUser].
  ///
  /// Requirements: 10.3
  Future<void> blockUser(String targetAuthUserId) async {
    if (_syncMode.useServerpod) {
      final client = ref.read(serverpodClientProvider);
      await client.safety.blockUser(targetAuthUserId);
    } else {
      final currentUid = _authService.currentUser?.uid;
      if (currentUid != null) {
        await _authService.blockUser(currentUid, targetAuthUserId);
      }
    }
  }

  /// Submit a report.
  ///
  /// - Serverpod path: calls `client.safety.submitReport` directly.
  /// - Firestore path: delegates to [AuthService.reportContent].
  ///
  /// Requirements: 10.3
  Future<void> reportUser({
    required String targetUserId,
    String? targetChatId,
    String? targetMessageId,
    required String reason,
  }) async {
    if (_syncMode.useServerpod) {
      final client = ref.read(serverpodClientProvider);
      await client.safety.submitReport(
        targetUserId: targetUserId,
        targetChatId: targetChatId,
        targetMessageId: targetMessageId,
        reason: reason,
      );
    } else {
      final currentUid = _authService.currentUser?.uid;
      if (currentUid != null) {
        await _authService.reportContent(
          reporterId: currentUid,
          reportedUserId: targetUserId,
          chatId: targetChatId ?? '',
          reason: reason,
        );
      }
    }
  }
}

/// Provider for [AuthNotifier].
///
/// This is the Riverpod [AsyncNotifier]-based replacement for the legacy
/// [AuthProvider] (ChangeNotifier). Wire this into the app once the legacy
/// provider is removed in M3.
final authNotifierV2Provider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
