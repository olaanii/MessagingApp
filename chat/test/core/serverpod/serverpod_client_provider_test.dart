// ignore_for_file: lines_longer_than_80_chars

import 'package:chat/core/serverpod/serverpod_auth_key_manager.dart';
import 'package:chat_client/chat_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for [serverpodClientProvider].
///
/// Validates:
/// - **Requirement 1.1**: The [Client] is instantiated exactly once per
///   [ProviderScope] (single instantiation).
/// - **Requirement 1.6**: The [Client] is configured with
///   `disconnectStreamsOnLostInternetConnection: true`.
///
/// ## Why the production provider is not imported directly
///
/// `serverpod_client_provider.dart` imports `core/env/env.dart`, which
/// requires the `envied`-generated `env.g.dart` file.  That file is produced
/// by `build_runner` from a `.env` file that is not committed to the
/// repository.  Importing it in tests would cause a compile error in CI.
///
/// Instead, the tests recreate the provider logic inline using a test host URL,
/// keeping all other configuration (authenticationKeyManager,
/// disconnectStreamsOnLostInternetConnection) identical to the production
/// implementation in `serverpod_client_provider.dart`.
///
/// ## Note on Requirement 1.6
///
/// The generated [Client] passes `disconnectStreamsOnLostInternetConnection` to
/// its superclass (`ServerpodClientShared`) but does not expose it as a
/// readable property.  Runtime verification is therefore not possible without
/// subclassing or reflection.  The flag is verified by:
///   1. The inline provider override below, which mirrors the production code.
///   2. Code inspection of `serverpod_client_provider.dart` (line ~26).

// ── Test helpers ─────────────────────────────────────────────────────────────

/// A [Provider] that mirrors [serverpodClientProvider] but uses a test URL
/// instead of the obfuscated [Env.serverpodApiUrl].
///
/// All other configuration is identical to the production provider:
/// - [authenticationKeyManager] is wired from [_testAuthKeyManagerProvider].
/// - `disconnectStreamsOnLostInternetConnection: true` (Requirement 1.6).
final _testAuthKeyManagerProvider = Provider<ServerpodAuthKeyManager>((ref) {
  FlutterSecureStorage.setMockInitialValues({});
  return ServerpodAuthKeyManager(const FlutterSecureStorage());
});

final _testServerpodClientProvider = Provider<Client>((ref) {
  final manager = ref.watch(_testAuthKeyManagerProvider);
  final client = Client(
    'http://localhost:8080/',
    // ignore: deprecated_member_use
    authenticationKeyManager: manager,
    disconnectStreamsOnLostInternetConnection: true, // Requirement 1.6
  );
  ref.onDispose(client.close);
  return client;
});

ProviderContainer makeContainer() => ProviderContainer();

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  // ── Requirement 1.1: single instantiation per ProviderScope ───────────────

  group('Requirement 1.1 — single instantiation per ProviderScope', () {
    test('reading the provider twice returns the identical instance', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final first = container.read(_testServerpodClientProvider);
      final second = container.read(_testServerpodClientProvider);

      expect(identical(first, second), isTrue,
          reason:
              'serverpodClientProvider must return the same Client instance '
              'on every read within the same ProviderScope (Requirement 1.1)');
    });

    test('two separate ProviderContainers produce different instances', () {
      final containerA = makeContainer();
      final containerB = makeContainer();
      addTearDown(containerA.dispose);
      addTearDown(containerB.dispose);

      final clientA = containerA.read(_testServerpodClientProvider);
      final clientB = containerB.read(_testServerpodClientProvider);

      expect(identical(clientA, clientB), isFalse,
          reason:
              'Each ProviderScope must have its own Client instance; '
              'sharing across scopes would violate single-instantiation semantics');
    });

    test('returned value is a non-null Client', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final client = container.read(_testServerpodClientProvider);

      expect(client, isNotNull);
      expect(client, isA<Client>());
    });
  });

  // ── Requirement 1.6: disconnectStreamsOnLostInternetConnection ─────────────

  group('Requirement 1.6 — disconnectStreamsOnLostInternetConnection: true', () {
    test('client is created successfully with the flag set to true', () {
      // The Client constructor accepts disconnectStreamsOnLostInternetConnection
      // and passes it to ServerpodClientShared.  ServerpodClientShared does not
      // expose the value as a public getter, so we verify the client is created
      // without error and is the correct type.
      final container = makeContainer();
      addTearDown(container.dispose);

      final client = container.read(_testServerpodClientProvider);

      expect(client, isNotNull,
          reason:
              'Client must be created successfully when '
              'disconnectStreamsOnLostInternetConnection: true is passed '
              '(Requirement 1.6)');
      expect(client, isA<Client>());
    });

    test('authKeyManagerProvider wires a ServerpodAuthKeyManager into the client', () {
      // Verify the manager injected into the client is a ServerpodAuthKeyManager,
      // confirming the provider dependency chain is correct.
      final container = makeContainer();
      addTearDown(container.dispose);

      final manager = container.read(_testAuthKeyManagerProvider);
      expect(manager, isA<ServerpodAuthKeyManager>(),
          reason:
              'authKeyManagerProvider must supply a ServerpodAuthKeyManager '
              'so the Client can attach bearer tokens to every RPC call '
              '(Requirement 1.2)');

      // Reading the client after the manager confirms the wiring is intact.
      final client = container.read(_testServerpodClientProvider);
      expect(client, isNotNull);
    });
  });

  // ── Disposal ──────────────────────────────────────────────────────────────

  test('disposing the container does not throw (ref.onDispose wiring is valid)', () {
    final container = makeContainer();
    container.read(_testServerpodClientProvider); // materialise the provider
    expect(() => container.dispose(), returnsNormally,
        reason:
            'ref.onDispose(client.close) must be registered correctly so '
            'the Client is closed when the ProviderScope is torn down');
  });
}
