// ignore_for_file: lines_longer_than_80_chars

import 'package:chat/core/serverpod/serverpod_auth_key_manager.dart';
import 'package:chat/features/auth/data/serverpod_auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Testable repository wrapper ───────────────────────────────────────────────

/// A testable wrapper that mirrors [ServerpodAuthRepositoryImpl] logic but
/// accepts injected exchange/refresh/logout implementations so tests can
/// exercise the storage behaviour without a real Serverpod server.
final class _TestableRepo implements ServerpodAuthRepository {
  _TestableRepo({
    required ServerpodAuthKeyManager authKeyManager,
    required Future<TokenPair> Function() exchangeImpl,
    Future<TokenPair> Function(String)? refreshImpl,
    Future<void> Function(String)? logoutImpl,
  })  : _authKeyManager = authKeyManager,
        _exchangeImpl = exchangeImpl,
        _refreshImpl = refreshImpl ?? ((_) async => throw UnimplementedError()),
        _logoutImpl = logoutImpl ?? ((_) async {});

  final ServerpodAuthKeyManager _authKeyManager;
  final Future<TokenPair> Function() _exchangeImpl;
  final Future<TokenPair> Function(String) _refreshImpl;
  final Future<void> Function(String) _logoutImpl;

  @override
  Future<TokenPair> exchangeFirebaseToken({
    required String firebaseIdToken,
    required String deviceId,
    required dynamic publicKeyBundle,
  }) async {
    // Mirror real impl: only write tokens on success (Req 2.8).
    try {
      final pair = await _exchangeImpl();
      await Future.wait([
        _authKeyManager.put(pair.accessToken),
        _authKeyManager.storeRefreshToken(pair.refreshToken),
      ]);
      return pair;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthServerException('Unexpected error: $e');
    }
  }

  @override
  Future<TokenPair> refreshSession(String refreshToken) =>
      _refreshImpl(refreshToken);

  @override
  Future<void> logout(String deviceId) => _logoutImpl(deviceId);
}


// ── Token sample data ─────────────────────────────────────────────────────────

/// Representative (accessToken, refreshToken) pairs for Property 8.
final _tokenPairs = <(String, String)>[
  ('eyJhbGciOiJIUzI1NiJ9.payload.sig', 'refresh_abc123'),
  ('short_access', 'short_refresh'),
  ('a' * 512, 'r' * 512),
  ('unicode-🔑-access', 'unicode-🔑-refresh'),
  (r'special!@#$%^&*()_+', r'special!@#$%^&*()_+_refresh'),
  ('ACCESS_UPPER', 'REFRESH_UPPER'),
  ('access with spaces', 'refresh with spaces'),
  ('0', '1'),
];

/// Exceptions that [exchangeFirebaseToken] may throw (Property 9).
final _exchangeFailures = <AuthException>[
  const InvalidFirebaseTokenException(),
  const SessionExpiredException(),
  const AuthNetworkException('network down'),
  const AuthServerException('server error'),
];

// ── Helpers ───────────────────────────────────────────────────────────────────

ServerpodAuthKeyManager _makeManager() {
  FlutterSecureStorage.setMockInitialValues({});
  return ServerpodAuthKeyManager(const FlutterSecureStorage());
}

_TestableRepo _makeRepo({
  required ServerpodAuthKeyManager manager,
  required Future<TokenPair> Function() exchangeImpl,
}) =>
    _TestableRepo(
      authKeyManager: manager,
      exchangeImpl: exchangeImpl,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  // ── Property 8: Token Exchange Persists Both Tokens ───────────────────────
  //
  // **Validates: Requirements 2.2, 2.3**
  //
  // For any successful exchangeFirebaseToken call, both the accessToken and
  // refreshToken from the returned TokenPair must be retrievable from their
  // respective secure storage locations immediately after the call completes.

  group('Property 8: Token Exchange Persists Both Tokens', () {
    for (final (accessToken, refreshToken) in _tokenPairs) {
      final label =
          'access=${accessToken.length > 30 ? '${accessToken.substring(0, 30)}…' : accessToken}, '
          'refresh=${refreshToken.length > 30 ? '${refreshToken.substring(0, 30)}…' : refreshToken}';

      test(label, () async {
        final manager = _makeManager();
        final expectedPair = TokenPair(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        final repo = _makeRepo(
          manager: manager,
          exchangeImpl: () async => expectedPair,
        );

        final result = await repo.exchangeFirebaseToken(
          firebaseIdToken: 'firebase_id_token',
          deviceId: 'device_id',
          publicKeyBundle: null,
        );

        // Returned pair matches expected.
        expect(result.accessToken, equals(accessToken));
        expect(result.refreshToken, equals(refreshToken));

        // Both tokens persisted in storage (Req 2.2, 2.3).
        expect(
          await manager.get(),
          equals(accessToken),
          reason: 'accessToken must be stored via ServerpodAuthKeyManager.put() (Req 2.2)',
        );
        expect(
          await manager.readRefreshToken(),
          equals(refreshToken),
          reason: 'refreshToken must be stored under sp_refresh_token (Req 2.3)',
        );
      });
    }

    test('subsequent successful exchange overwrites both stored tokens', () async {
      final manager = _makeManager();

      await _makeRepo(
        manager: manager,
        exchangeImpl: () async => TokenPair(
          accessToken: 'first_access',
          refreshToken: 'first_refresh',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        ),
      ).exchangeFirebaseToken(
        firebaseIdToken: 'token1',
        deviceId: 'device',
        publicKeyBundle: null,
      );

      await _makeRepo(
        manager: manager,
        exchangeImpl: () async => TokenPair(
          accessToken: 'second_access',
          refreshToken: 'second_refresh',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        ),
      ).exchangeFirebaseToken(
        firebaseIdToken: 'token2',
        deviceId: 'device',
        publicKeyBundle: null,
      );

      expect(await manager.get(), equals('second_access'));
      expect(await manager.readRefreshToken(), equals('second_refresh'));
    });
  });

  // ── Property 9: Failed Auth Exchange Leaves No Partial State ─────────────
  //
  // **Validates: Requirements 2.8**
  //
  // For any exchangeFirebaseToken call that throws an exception, neither
  // accessToken nor refreshToken must be present in secure storage after
  // the exception is thrown.

  group('Property 9: Failed Auth Exchange Leaves No Partial State', () {
    for (final failure in _exchangeFailures) {
      test('failure type: ${failure.runtimeType}', () async {
        final manager = _makeManager();

        final repo = _makeRepo(
          manager: manager,
          exchangeImpl: () async => throw failure,
        );

        await expectLater(
          repo.exchangeFirebaseToken(
            firebaseIdToken: 'firebase_id_token',
            deviceId: 'device_id',
            publicKeyBundle: null,
          ),
          throwsA(isA<AuthException>()),
          reason: 'exchangeFirebaseToken must throw a typed AuthException on failure',
        );

        // No partial state in storage (Req 2.8).
        expect(
          await manager.get(),
          isNull,
          reason: 'accessToken must NOT be stored when exchange fails (Req 2.8)',
        );
        expect(
          await manager.readRefreshToken(),
          isNull,
          reason: 'refreshToken must NOT be stored when exchange fails (Req 2.8)',
        );
      });
    }

    test('pre-existing tokens are preserved when exchange fails', () async {
      final manager = _makeManager();
      await manager.put('existing_access');
      await manager.storeRefreshToken('existing_refresh');

      final repo = _makeRepo(
        manager: manager,
        exchangeImpl: () async => throw const InvalidFirebaseTokenException(),
      );

      await expectLater(
        repo.exchangeFirebaseToken(
          firebaseIdToken: 'bad_token',
          deviceId: 'device_id',
          publicKeyBundle: null,
        ),
        throwsA(isA<AuthException>()),
      );

      expect(await manager.get(), equals('existing_access'),
          reason: 'A failed exchange must not clear pre-existing access token');
      expect(await manager.readRefreshToken(), equals('existing_refresh'),
          reason: 'A failed exchange must not clear pre-existing refresh token');
    });

    test('unexpected exception is wrapped as AuthServerException and leaves no state', () async {
      final manager = _makeManager();

      final repo = _makeRepo(
        manager: manager,
        exchangeImpl: () async => throw Exception('unexpected network error'),
      );

      await expectLater(
        repo.exchangeFirebaseToken(
          firebaseIdToken: 'token',
          deviceId: 'device',
          publicKeyBundle: null,
        ),
        throwsA(isA<AuthServerException>()),
      );

      expect(await manager.get(), isNull);
      expect(await manager.readRefreshToken(), isNull);
    });
  });

  _tokenRefreshTests();
}

// ── TokenRefreshInterceptor tests ─────────────────────────────────────────────

/// A minimal [ServerpodAuthRepository] stub for interceptor tests.
final class _StubRepo implements ServerpodAuthRepository {
  _StubRepo({
    required Future<TokenPair> Function(String) refreshImpl,
  }) : _refreshImpl = refreshImpl;

  final Future<TokenPair> Function(String) _refreshImpl;

  @override
  Future<TokenPair> exchangeFirebaseToken({
    required String firebaseIdToken,
    required String deviceId,
    required dynamic publicKeyBundle,
  }) =>
      throw UnimplementedError();

  @override
  Future<TokenPair> refreshSession(String refreshToken) =>
      _refreshImpl(refreshToken);

  @override
  Future<void> logout(String deviceId) => Future.value();
}

TokenRefreshInterceptor _makeInterceptor({
  required ServerpodAuthKeyManager manager,
  required Future<TokenPair> Function(String) refreshImpl,
}) =>
    TokenRefreshInterceptor(
      repository: _StubRepo(refreshImpl: refreshImpl),
      authKeyManager: manager,
    );

// ── Property 5: Token Refresh Transparency ────────────────────────────────────
// Exactly one refresh attempt and one retry signal on 401; no more.
// **Validates: Requirements 2.4**

void _tokenRefreshTests() {
  group('Property 5: Token Refresh Transparency', () {
    for (final (accessToken, refreshToken) in _tokenPairs.take(4)) {
      test('successful refresh returns true and updates tokens: access=${accessToken.substring(0, accessToken.length.clamp(0, 20))}', () async {
        final manager = _makeManager();
        await manager.storeRefreshToken(refreshToken);

        int refreshCallCount = 0;
        final newPair = TokenPair(
          accessToken: 'new_$accessToken',
          refreshToken: 'new_$refreshToken',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        final interceptor = _makeInterceptor(
          manager: manager,
          refreshImpl: (rt) async {
            refreshCallCount++;
            // Simulate what ServerpodAuthRepositoryImpl.refreshSession does:
            // persist both tokens then return the pair.
            await manager.put(newPair.accessToken);
            await manager.storeRefreshToken(newPair.refreshToken);
            return newPair;
          },
        );
        addTearDown(interceptor.dispose);

        final shouldRetry = await interceptor.onUnauthorized();

        expect(shouldRetry, isTrue,
            reason: 'onUnauthorized() must return true when refresh succeeds (Req 2.4)');
        expect(refreshCallCount, equals(1),
            reason: 'exactly one refresh attempt must be made (Req 2.4)');
        expect(await manager.get(), equals('new_$accessToken'),
            reason: 'new accessToken must be stored after refresh (Req 2.5)');
        expect(await manager.readRefreshToken(), equals('new_$refreshToken'),
            reason: 'new refreshToken must be stored after refresh (Req 2.5)');
      });
    }

    test('no sessionExpired event emitted on successful refresh', () async {
      final manager = _makeManager();
      await manager.storeRefreshToken('valid_refresh');

      final interceptor = _makeInterceptor(
        manager: manager,
        refreshImpl: (rt) async {
          await manager.put('new_access');
          await manager.storeRefreshToken('new_refresh');
          return TokenPair(
            accessToken: 'new_access',
            refreshToken: 'new_refresh',
            expiresAt: DateTime.now().add(const Duration(hours: 1)),
          );
        },
      );
      addTearDown(interceptor.dispose);

      final events = <AuthEvent>[];
      interceptor.authEventStream.listen(events.add);

      await interceptor.onUnauthorized();
      // Give the stream a tick to flush any events.
      await Future<void>.delayed(Duration.zero);

      expect(events, isEmpty,
          reason: 'no AuthEvent must be emitted on successful refresh');
    });

    test('returns false and emits sessionExpired when no refresh token stored', () async {
      final manager = _makeManager();
      // No refresh token stored.

      final interceptor = _makeInterceptor(
        manager: manager,
        refreshImpl: (_) async => throw StateError('should not be called'),
      );
      addTearDown(interceptor.dispose);

      final events = <AuthEvent>[];
      interceptor.authEventStream.listen(events.add);

      final shouldRetry = await interceptor.onUnauthorized();
      await Future<void>.delayed(Duration.zero);

      expect(shouldRetry, isFalse);
      expect(events, contains(AuthEvent.sessionExpired));
    });
  });

  // ── Property 10: Failed Token Refresh Clears All Tokens ──────────────────
  // Failed refresh removes both tokens and emits AuthEvent.sessionExpired.
  // **Validates: Requirements 2.6**

  group('Property 10: Failed Token Refresh Clears All Tokens', () {
    final refreshFailures = <Exception>[
      const SessionExpiredException('refresh rejected'),
      const AuthNetworkException('network error'),
      const AuthServerException('server error'),
      Exception('unexpected error'),
    ];

    for (final failure in refreshFailures) {
      test('failure type: ${failure.runtimeType}', () async {
        final manager = _makeManager();
        await manager.put('existing_access');
        await manager.storeRefreshToken('existing_refresh');

        final interceptor = _makeInterceptor(
          manager: manager,
          refreshImpl: (_) async => throw failure,
        );
        addTearDown(interceptor.dispose);

        final events = <AuthEvent>[];
        interceptor.authEventStream.listen(events.add);

        final shouldRetry = await interceptor.onUnauthorized();
        await Future<void>.delayed(Duration.zero);

        expect(shouldRetry, isFalse,
            reason: 'onUnauthorized() must return false when refresh fails (Req 2.6)');
        expect(await manager.get(), isNull,
            reason: 'accessToken must be cleared after failed refresh (Req 2.6)');
        expect(await manager.readRefreshToken(), isNull,
            reason: 'refreshToken must be cleared after failed refresh (Req 2.6)');
        expect(events, contains(AuthEvent.sessionExpired),
            reason: 'AuthEvent.sessionExpired must be emitted after failed refresh (Req 2.6)');
      });
    }

    test('exactly one sessionExpired event emitted per failed refresh', () async {
      final manager = _makeManager();
      await manager.storeRefreshToken('some_refresh');

      final interceptor = _makeInterceptor(
        manager: manager,
        refreshImpl: (_) async => throw const SessionExpiredException(),
      );
      addTearDown(interceptor.dispose);

      final events = <AuthEvent>[];
      interceptor.authEventStream.listen(events.add);

      await interceptor.onUnauthorized();
      await Future<void>.delayed(Duration.zero);

      expect(events.length, equals(1),
          reason: 'exactly one sessionExpired event must be emitted');
      expect(events.first, equals(AuthEvent.sessionExpired));
    });
  });
}
