import 'package:serverpod/serverpod.dart';

/// Device registry endpoint — lists active sessions and supports remote revoke,
/// plus [registerDevice] for ADR-0003 `device_id` binding (merged from pod messaging).
class DeviceEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Returns registered devices for the authenticated user.
  Future<List<String>> list(Session session) async {
    final me = session.authenticated!.userIdentifier;
    final rows = await session.db.unsafeQuery(
      'SELECT "deviceId" FROM registered_device '
      'WHERE "ownerAuthUserId" = @me::uuid ORDER BY "createdAt" DESC',
      parameters: QueryParameters.named({'me': me}),
    );
    return rows.map((r) => r[0] as String).toList();
  }

  /// Revokes a device registration (removes from registered_device).
  Future<void> revoke(Session session, String deviceId) async {
    final me = session.authenticated!.userIdentifier;
    await session.db.unsafeQuery(
      'DELETE FROM registered_device '
      'WHERE "deviceId" = @deviceId AND "ownerAuthUserId" = @me::uuid',
      parameters: QueryParameters.named({'deviceId': deviceId, 'me': me}),
    );
  }

  /// Registers or updates a device for ADR-0003 `device_id` binding.
  Future<void> registerDevice(
    Session session,
    String deviceId,
    String platform,
    String? name,
  ) async {
    final me = session.authenticated!.userIdentifier;
    await session.db.unsafeQuery(
      '''
      INSERT INTO registered_device
             ("deviceId", "ownerAuthUserId", "platform", "name", "createdAt", "lastSeenAt")
      VALUES (@deviceId, @me::uuid, @platform, @name, now(), now())
      ON CONFLICT ("ownerAuthUserId", "deviceId")
      DO UPDATE SET "platform" = @platform, "name" = @name, "lastSeenAt" = now()
      ''',
      parameters: QueryParameters.named({
        'deviceId': deviceId,
        'me': me,
        'platform': platform,
        'name': name,
      }),
    );
  }
}
