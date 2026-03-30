/// Caller abstraction for the server-side `DeviceEndpoint`.
///
/// Using an interface here (rather than calling the generated `Client.device`
/// directly) keeps the repository testable without a live Serverpod connection
/// and avoids a hard dependency on the generated client until `serverpod
/// generate` is run with the new endpoint.
///
/// Requirements: 7.1, 7.2, 7.3
abstract interface class DeviceEndpointCaller {
  Future<List<Map<String, dynamic>>> list();
  Future<void> revoke(String deviceId);
}

// ── Value object ──────────────────────────────────────────────────────────────

/// Immutable snapshot of a single registered device / session.
///
/// Requirements: 7.2
final class DeviceInfo {
  const DeviceInfo({
    required this.deviceId,
    required this.name,
    required this.platform,
    required this.lastSeenAt,
    required this.isCurrentDevice,
  });

  final String deviceId;
  final String name;
  final String platform;
  final DateTime lastSeenAt;
  final bool isCurrentDevice;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceInfo &&
          runtimeType == other.runtimeType &&
          deviceId == other.deviceId &&
          name == other.name &&
          platform == other.platform &&
          lastSeenAt == other.lastSeenAt &&
          isCurrentDevice == other.isCurrentDevice;

  @override
  int get hashCode => Object.hash(
        deviceId,
        name,
        platform,
        lastSeenAt,
        isCurrentDevice,
      );

  @override
  String toString() =>
      'DeviceInfo(deviceId: $deviceId, name: $name, platform: $platform, '
      'lastSeenAt: $lastSeenAt, isCurrentDevice: $isCurrentDevice)';
}

// ── Repository interface ──────────────────────────────────────────────────────

/// Contract for listing and revoking device sessions.
///
/// Requirements: 7.1, 7.2, 7.3
abstract interface class DeviceRepository {
  Future<List<DeviceInfo>> listMyDevices();
  Future<void> revokeDevice(String deviceId);
}

// ── Implementation ────────────────────────────────────────────────────────────

/// Concrete implementation backed by [DeviceEndpointCaller].
///
/// Accepts a [DeviceEndpointCaller] so tests can inject a fake without
/// needing a live Serverpod client.
///
/// Requirements: 7.1, 7.2, 7.3
final class ServerpodDeviceRepository implements DeviceRepository {
  const ServerpodDeviceRepository({
    required DeviceEndpointCaller caller,
    required String currentDeviceId,
  })  : _caller = caller,
        _currentDeviceId = currentDeviceId;

  final DeviceEndpointCaller _caller;
  final String _currentDeviceId;

  @override
  Future<List<DeviceInfo>> listMyDevices() async {
    final raw = await _caller.list();
    return raw.map(_mapToDeviceInfo).toList();
  }

  @override
  Future<void> revokeDevice(String deviceId) => _caller.revoke(deviceId);

  DeviceInfo _mapToDeviceInfo(Map<String, dynamic> map) {
    return DeviceInfo(
      deviceId: map['deviceId'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown device',
      platform: map['platform'] as String? ?? 'unknown',
      lastSeenAt: map['lastSeenAt'] is DateTime
          ? map['lastSeenAt'] as DateTime
          : DateTime.tryParse(map['lastSeenAt']?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
      isCurrentDevice:
          (map['deviceId'] as String? ?? '') == _currentDeviceId,
    );
  }
}
