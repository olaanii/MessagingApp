// ignore_for_file: lines_longer_than_80_chars

import 'package:chat/core/serverpod/serverpod_auth_key_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Property 7: Token Storage Round-Trip**
///
/// `put(token)` then `get()` returns the same token.
/// `remove()` then `get()` returns null.
///
/// **Validates: Requirements 1.4, 1.5**

void main() {
  // Representative token values used to exercise the property across a range
  // of inputs (empty string, short, long, unicode, special chars, whitespace).
  final tokenSamples = <String>[
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.payload.sig',
    'short',
    '',
    'a' * 2048,
    'token with spaces and\nnewlines',
    'unicode-🔑-token-✅',
    r'special!@#$%^&*()_+-=[]{}|;:,.<>?',
    '0' * 1,
    'refresh_abc123',
    'UPPERCASE_TOKEN',
  ];

  setUp(() {
    // Use flutter_secure_storage's built-in in-memory mock so no platform
    // channel is needed during tests.
    FlutterSecureStorage.setMockInitialValues({});
  });

  ServerpodAuthKeyManager makeManager() =>
      ServerpodAuthKeyManager(const FlutterSecureStorage());

  // ── Property 7a: put → get round-trip ──────────────────────────────────────

  group('Property 7a: put(token) then get() returns the same token', () {
    for (final token in tokenSamples) {
      test('token = ${token.length > 40 ? '${token.substring(0, 40)}…' : token.isEmpty ? '<empty>' : token}', () async {
        final manager = makeManager();

        await manager.put(token);
        final result = await manager.get();

        expect(result, equals(token),
            reason: 'get() must return exactly the token passed to put()');
      });
    }
  });

  // ── Property 7b: remove → get returns null ─────────────────────────────────

  group('Property 7b: remove() then get() returns null', () {
    for (final token in tokenSamples) {
      test('after storing token = ${token.length > 40 ? '${token.substring(0, 40)}…' : token.isEmpty ? '<empty>' : token}', () async {
        final manager = makeManager();

        await manager.put(token);
        await manager.remove();
        final result = await manager.get();

        expect(result, isNull,
            reason: 'get() must return null after remove()');
      });
    }
  });

  // ── Property 7c: get() returns null when nothing stored ───────────────────

  test('get() returns null when no token has been stored', () async {
    final manager = makeManager();
    expect(await manager.get(), isNull);
  });

  // ── Refresh token round-trip ───────────────────────────────────────────────

  group('storeRefreshToken / readRefreshToken round-trip', () {
    for (final token in tokenSamples) {
      test('refresh token = ${token.length > 40 ? '${token.substring(0, 40)}…' : token.isEmpty ? '<empty>' : token}', () async {
        final manager = makeManager();

        await manager.storeRefreshToken(token);
        final result = await manager.readRefreshToken();

        expect(result, equals(token),
            reason: 'readRefreshToken() must return exactly the token passed to storeRefreshToken()');
      });
    }
  });

  test('readRefreshToken() returns null when nothing stored', () async {
    final manager = makeManager();
    expect(await manager.readRefreshToken(), isNull);
  });

  // ── clearAll removes both tokens ───────────────────────────────────────────

  group('clearAll() removes both access and refresh tokens', () {
    for (final token in tokenSamples.take(3)) {
      test('after storing access + refresh token = ${token.isEmpty ? '<empty>' : token.substring(0, token.length.clamp(0, 20))}', () async {
        final manager = makeManager();

        await manager.put(token);
        await manager.storeRefreshToken('refresh_$token');
        await manager.clearAll();

        expect(await manager.get(), isNull,
            reason: 'clearAll() must remove the access token');
        expect(await manager.readRefreshToken(), isNull,
            reason: 'clearAll() must remove the refresh token');
      });
    }
  });

  // ── Overwrite semantics ────────────────────────────────────────────────────

  test('put() overwrites a previously stored token', () async {
    final manager = makeManager();

    await manager.put('first_token');
    await manager.put('second_token');
    final result = await manager.get();

    expect(result, equals('second_token'),
        reason: 'put() must overwrite the previous access token');
  });

  test('storeRefreshToken() overwrites a previously stored refresh token', () async {
    final manager = makeManager();

    await manager.storeRefreshToken('first_refresh');
    await manager.storeRefreshToken('second_refresh');
    final result = await manager.readRefreshToken();

    expect(result, equals('second_refresh'),
        reason: 'storeRefreshToken() must overwrite the previous refresh token');
  });

  // ── Access and refresh tokens are independent ──────────────────────────────

  test('access and refresh tokens are stored independently', () async {
    final manager = makeManager();

    await manager.put('access_token_value');
    await manager.storeRefreshToken('refresh_token_value');

    expect(await manager.get(), equals('access_token_value'));
    expect(await manager.readRefreshToken(), equals('refresh_token_value'));
  });

  test('remove() only removes access token, not refresh token', () async {
    final manager = makeManager();

    await manager.put('access');
    await manager.storeRefreshToken('refresh');
    await manager.remove();

    expect(await manager.get(), isNull);
    expect(await manager.readRefreshToken(), equals('refresh'),
        reason: 'remove() must not affect the refresh token');
  });
}
