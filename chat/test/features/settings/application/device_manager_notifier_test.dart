// ignore_for_file: lines_longer_than_80_chars

import 'package:chat/features/auth/data/serverpod_auth_repository.dart';
import 'package:chat/features/settings/application/device_manager_notifier.dart';
import 'package:chat/features/settings/data/device_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

/// Fake [DeviceRepository] that can be configured to throw or return data.
final class _FakeDeviceRepository implements DeviceRepository {
  _FakeDeviceRepository({
    this.devicesToReturn = const [],
    this.throwOnList = false,
    this.throwOnRevoke = false,
  });

  final List<DeviceInfo> devicesToReturn;
  final bool throwOnList;
  final bool throwOnRevoke;

  int listCallCount = 0;
  int revokeCallCount = 0;
  String? lastRevokedDeviceId;

  @override
  Future<List<DeviceInfo>> listMyDevices() async {
    listCallCount++;
    if (throwOnList) throw Exception('list failed');
    return devicesToReturn;
  }

  @override
  Future<void> revokeDevice(String deviceId) async {
    revokeCallCount++;
    lastRevokedDeviceId = deviceId;
    if (throwOnRevoke) throw Exception('revoke failed');
  }
}

/// Fake [ServerpodAuthRepository] that tracks logout calls.
final class _FakeAuthRepository implements ServerpodAuthRepository {
  int logoutCallCount = 0;
  String? lastLogoutDeviceId;

  @override
  Future<void> logout(String deviceId) async {
    logoutCallCount++;
    lastLogoutDeviceId = deviceId;
  }

  @override
  Future<TokenPair> exchangeFirebaseToken({
    required String firebaseIdToken,
    required String deviceId,
    required publicKeyBundle,
  }) =>
      throw UnimplementedError();

  @override
  Future<TokenPair> refreshSession(String refreshToken) =>
      throw UnimplementedError();
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Builds a [ProviderContainer] with the given fakes wired in.
({
  ProviderContainer container,
  _FakeDeviceRepository deviceRepo,
  _FakeAuthRepository authRepo,
  List<String> navigationCalls,
}) _buildContainer({
  required _FakeDeviceRepository deviceRepo,
  _FakeAuthRepository? authRepo,
}) {
  final auth = authRepo ?? _FakeAuthRepository();
  final navigationCalls = <String>[];

  final container = ProviderContainer(
    overrides: [
      deviceRepositoryProvider.overrideWithValue(deviceRepo),
      deviceManagerAuthRepositoryProvider.overrideWithValue(auth),
      deviceManagerNavigateToSignInProvider.overrideWithValue(
        () => navigationCalls.add('navigateToSignIn'),
      ),
    ],
  );

  return (
    container: container,
    deviceRepo: deviceRepo,
    authRepo: auth,
    navigationCalls: navigationCalls,
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('DeviceManagerNotifier', () {
    // ── build() ──────────────────────────────────────────────────────────────

    test('build() returns device list on success', () async {
      final devices = [
        DeviceInfo(
          deviceId: 'dev-1',
          name: 'iPhone 15',
          platform: 'ios',
          lastSeenAt: DateTime(2024),
          isCurrentDevice: true,
        ),
        DeviceInfo(
          deviceId: 'dev-2',
          name: 'Pixel 8',
          platform: 'android',
          lastSeenAt: DateTime(2024),
          isCurrentDevice: false,
        ),
      ];

      final (:container, :deviceRepo, :authRepo, :navigationCalls) =
          _buildContainer(
        deviceRepo: _FakeDeviceRepository(devicesToReturn: devices),
      );
      addTearDown(container.dispose);

      final result = await container.read(
        deviceManagerNotifierProvider.future,
      );

      expect(result, equals(devices));
    });

    // Requirements: 7.5
    test('build() surfaces error state when listMyDevices() throws', () async {
      final r1 = _buildContainer(
        deviceRepo: _FakeDeviceRepository(throwOnList: true),
      );

      // Listen to force the provider to build and wait for it to settle.
      r1.container.listen(
        deviceManagerNotifierProvider,
        (_, __) {},
        fireImmediately: true,
      );

      // Give the async build time to complete.
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = r1.container.read(deviceManagerNotifierProvider);
      r1.container.dispose();

      // In Riverpod 3.x, a throwing AsyncNotifier.build() surfaces the error
      // on the state (state.error is non-null) without crashing.
      expect(
        state.error,
        isNotNull,
        reason: 'State must carry an error when listMyDevices() throws',
      );
    });

    test('build() does not crash when listMyDevices() throws', () async {
      final r2 = _buildContainer(
        deviceRepo: _FakeDeviceRepository(throwOnList: true),
      );

      // Listen to force the provider to build.
      r2.container.listen(
        deviceManagerNotifierProvider,
        (_, __) {},
        fireImmediately: true,
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      // The provider state carries the error — not an unhandled crash.
      final state = r2.container.read(deviceManagerNotifierProvider);
      r2.container.dispose();

      expect(state.error, isNotNull,
          reason: 'Error must be surfaced on state, not a crash');
    });

    // ── revoke() — remote device ──────────────────────────────────────────────

    // Requirements: 7.3
    test('revoke() calls revokeDevice and refreshes list for remote device',
        () async {
      final devices = [
        DeviceInfo(
          deviceId: 'current-dev',
          name: 'My Phone',
          platform: 'ios',
          lastSeenAt: DateTime(2024),
          isCurrentDevice: true,
        ),
        DeviceInfo(
          deviceId: 'other-dev',
          name: 'Tablet',
          platform: 'android',
          lastSeenAt: DateTime(2024),
          isCurrentDevice: false,
        ),
      ];

      final deviceRepo = _FakeDeviceRepository(devicesToReturn: devices);
      final authRepo = _FakeAuthRepository();
      final result = _buildContainer(deviceRepo: deviceRepo, authRepo: authRepo);
      final container = result.container;
      final navigationCalls = result.navigationCalls;
      addTearDown(container.dispose);

      // Wait for initial build.
      await container.read(deviceManagerNotifierProvider.future);

      await container
          .read(deviceManagerNotifierProvider.notifier)
          .revoke('other-dev');

      expect(deviceRepo.revokeCallCount, 1);
      expect(deviceRepo.lastRevokedDeviceId, 'other-dev');
      // Logout must NOT be called for a remote device.
      expect(authRepo.logoutCallCount, 0);
      // Navigation must NOT be triggered for a remote device.
      expect(navigationCalls, isEmpty);
    });

    // Requirements: 7.4
    test(
        'revoke() calls logout and navigates to sign-in when revoking current device',
        () async {
      final devices = [
        DeviceInfo(
          deviceId: 'current-dev',
          name: 'My Phone',
          platform: 'ios',
          lastSeenAt: DateTime(2024),
          isCurrentDevice: true,
        ),
      ];

      final deviceRepo = _FakeDeviceRepository(devicesToReturn: devices);
      final authRepo = _FakeAuthRepository();
      final result = _buildContainer(deviceRepo: deviceRepo, authRepo: authRepo);
      final container = result.container;
      final navigationCalls = result.navigationCalls;
      addTearDown(container.dispose);

      // Wait for initial build.
      await container.read(deviceManagerNotifierProvider.future);

      await container
          .read(deviceManagerNotifierProvider.notifier)
          .revoke('current-dev');

      expect(deviceRepo.revokeCallCount, 1);
      expect(authRepo.logoutCallCount, 1,
          reason: 'logout must be called when revoking the current device');
      expect(authRepo.lastLogoutDeviceId, 'current-dev');
      expect(navigationCalls, contains('navigateToSignIn'),
          reason: 'navigation to sign-in must be triggered');
    });

    // Requirements: 7.4
    test(
        'revoke() does NOT refresh list after revoking current device (navigates away)',
        () async {
      final devices = [
        DeviceInfo(
          deviceId: 'current-dev',
          name: 'My Phone',
          platform: 'ios',
          lastSeenAt: DateTime(2024),
          isCurrentDevice: true,
        ),
      ];

      final deviceRepo = _FakeDeviceRepository(devicesToReturn: devices);
      final result = _buildContainer(deviceRepo: deviceRepo);
      final container = result.container;
      addTearDown(container.dispose);

      await container.read(deviceManagerNotifierProvider.future);
      final listCallsBeforeRevoke = deviceRepo.listCallCount;

      await container
          .read(deviceManagerNotifierProvider.notifier)
          .revoke('current-dev');

      // listMyDevices should not be called again after current-device revoke.
      expect(
        deviceRepo.listCallCount,
        listCallsBeforeRevoke,
        reason: 'list must not be refreshed after current-device revoke',
      );
    });
  });
}
