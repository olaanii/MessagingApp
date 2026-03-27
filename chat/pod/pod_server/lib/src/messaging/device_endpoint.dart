import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Registers or updates this client device for ADR-0003 `device_id` binding.
class DeviceEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<RegisteredDevice> registerDevice(
    Session session,
    String deviceId,
    String platform,
    String? name,
  ) async {
    final owner = session.authenticated!.userIdentifier;
    final existing = await RegisteredDevice.db.findFirstRow(
      session,
      where: (t) => t.deviceId.equals(deviceId),
    );
    if (existing != null) {
      if (existing.ownerAuthUserId != owner) {
        throw StateError('device_id is registered to another user');
      }
      final updated = await RegisteredDevice.db.updateRow(
        session,
        existing.copyWith(
          platform: platform,
          name: name,
          lastSeenAt: DateTime.now().toUtc(),
        ),
      );
      return updated;
    }

    return RegisteredDevice.db.insertRow(
      session,
      RegisteredDevice(
        deviceId: deviceId,
        ownerAuthUserId: owner,
        platform: platform,
        name: name,
        lastSeenAt: DateTime.now().toUtc(),
      ),
    );
  }
}
