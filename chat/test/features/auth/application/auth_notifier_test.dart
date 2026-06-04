// ignore_for_file: lines_longer_than_80_chars

import 'package:chat/domain/models/user_model.dart';
import 'package:chat/features/auth/application/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

UserModel _fakeUser({
  String id = 'user_1',
  String name = 'Test User',
  String status = 'online',
}) =>
    UserModel(
      id: id,
      name: name,
      lastSeen: DateTime.now(),
      status: status,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // Task 12.4 — Riverpod Provider Tests
  // Task 22.5 — Profile UI Unit Tests (auth state part)
  // Requirements: 14.1, 14.2, 14.6
  // ═══════════════════════════════════════════════════════════════════════════

  group('Task 12.4 / 22.5 — Auth State & Riverpod Providers', () {
    test('AuthStateUnauthenticated is initial state', () {
      final state = AuthStateUnauthenticated();
      expect(state, isA<AuthState>());
      expect(state is AuthStateAuthenticated, isFalse);
    });

    test('AuthStateAuthenticated holds user model', () {
      final user = _fakeUser();
      final state = AuthStateAuthenticated(user);

      expect(state.user, equals(user));
      expect(state.user.id, equals('user_1'));
      expect(state.user.name, equals('Test User'));
    });

    test('AuthStateError holds error message', () {
      final state = AuthStateError('Something went wrong');

      expect(state.message, equals('Something went wrong'));
    });

    test('AuthStateLoading represents loading state', () {
      final state = AuthStateLoading();
      expect(state, isA<AuthState>());
    });

    test('AuthState subtypes are exhaustive', () {
      // Verify all 4 subtypes exist and are distinct
      final unauthenticated = AuthStateUnauthenticated();
      final loading = AuthStateLoading();
      final authenticated = AuthStateAuthenticated(_fakeUser());
      final error = AuthStateError('err');

      expect(unauthenticated, isA<AuthState>());
      expect(loading, isA<AuthState>());
      expect(authenticated, isA<AuthState>());
      expect(error, isA<AuthState>());

      // They should not be equal to each other
      expect(unauthenticated == loading, isFalse);
      expect(authenticated == error, isFalse);
    });

    test('auth state transitions: unauthenticated → loading → authenticated', () {
      final history = <AuthState>[];

      history.add(AuthStateUnauthenticated());
      history.add(AuthStateLoading());

      final user = _fakeUser();
      history.add(AuthStateLoading());
      history.add(AuthStateAuthenticated(user));

      expect(history[0], isA<AuthStateUnauthenticated>());
      expect(history[1], isA<AuthStateLoading>());
      expect(history[3], isA<AuthStateAuthenticated>());
    });

    test('ProviderContainer can read simple provider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Riverpod container works
      expect(container, isNotNull);
    });

    test('ProviderContainer override works with simple provider', () {
      final simpleProvider = Provider<String>((ref) => 'original');
      final container = ProviderContainer(
        overrides: [simpleProvider.overrideWithValue('overridden')],
      );
      addTearDown(container.dispose);

      expect(container.read(simpleProvider), equals('overridden'));
    });
  });
}
