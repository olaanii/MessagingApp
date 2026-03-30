import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/serverpod_auth_repository.dart';
import '../data/device_repository.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

/// Provides the [DeviceRepository] used by [DeviceManagerNotifier].
///
/// Override in tests to inject a fake.
final deviceRepositoryProvider = Provider<DeviceRepository>(
  (ref) => throw UnimplementedError(
    'deviceRepositoryProvider must be overridden before use',
  ),
);

/// Provides the [ServerpodAuthRepository] used for logout on current-device
/// revoke.
///
/// Override in tests to inject a fake.
final deviceManagerAuthRepositoryProvider =
    Provider<ServerpodAuthRepository>(
  (ref) => throw UnimplementedError(
    'deviceManagerAuthRepositoryProvider must be overridden before use',
  ),
);

/// Callback invoked when the current device is revoked and the app should
/// navigate to the sign-in screen.
///
/// Injected via [deviceManagerNavigateToSignInProvider] so the notifier
/// stays testable without importing GoRouter.
final deviceManagerNavigateToSignInProvider = Provider<VoidCallback>(
  (ref) => throw UnimplementedError(
    'deviceManagerNavigateToSignInProvider must be overridden before use',
  ),
);

// ── DeviceManagerNotifier ─────────────────────────────────────────────────────

/// Manages the list of registered devices for the authenticated user.
///
/// - `build()` loads the device list; surfaces [AsyncError] on failure without
///   crashing (Requirement 7.5).
/// - `revoke(deviceId)` revokes a device; if it is the current device it also
///   calls logout and navigates to sign-in (Requirement 7.4).
///
/// Requirements: 7.1, 7.3, 7.4, 7.5
class DeviceManagerNotifier extends AsyncNotifier<List<DeviceInfo>> {
  @override
  Future<List<DeviceInfo>> build() async {
    final repo = ref.watch(deviceRepositoryProvider);
    // Surface errors as AsyncError state — do not rethrow (Requirement 7.5).
    return repo.listMyDevices();
  }

  /// Revoke [deviceId].
  ///
  /// - Calls [DeviceRepository.revokeDevice].
  /// - If [deviceId] is the current device: calls
  ///   [ServerpodAuthRepository.logout] and the navigation callback.
  /// - Refreshes the device list after a successful revoke.
  ///
  /// Requirements: 7.3, 7.4
  Future<void> revoke(String deviceId) async {
    final repo = ref.read(deviceRepositoryProvider);
    final authRepo = ref.read(deviceManagerAuthRepositoryProvider);
    final navigateToSignIn =
        ref.read(deviceManagerNavigateToSignInProvider);

    await repo.revokeDevice(deviceId);

    // Determine whether the revoked device is the current one.
    final currentDevices = state.value ?? [];
    final isCurrentDevice = currentDevices.any(
      (d) => d.deviceId == deviceId && d.isCurrentDevice,
    );

    if (isCurrentDevice) {
      // Sign out locally and navigate away before refreshing the list.
      await authRepo.logout(deviceId);
      navigateToSignIn();
      return;
    }

    // Refresh the list after revoking a remote device.
    state = const AsyncLoading();
    state = await AsyncValue.guard(repo.listMyDevices);
  }
}

/// Provider for [DeviceManagerNotifier].
final deviceManagerNotifierProvider =
    AsyncNotifierProvider<DeviceManagerNotifier, List<DeviceInfo>>(
  DeviceManagerNotifier.new,
);
