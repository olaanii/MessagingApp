import 'package:serverpod/serverpod.dart';

/// Device registry endpoint — lists active sessions and supports remote revoke.
///
/// This is a stub implementation. The real implementation would query the
/// `sessions` table managed by `serverpod_auth_core` and the `push_tokens`
/// table for FCM token removal.
///
/// Requirements: 7.1, 7.2, 7.3, 7.4
class DeviceEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Returns the list of active sessions for the authenticated user.
  ///
  /// Each map contains: `deviceId`, `name`, `platform`, `lastSeenAt`.
  ///
  /// Stub: returns an empty list until the sessions table is queryable here.
  Future<List<Map<String, dynamic>>> list(Session session) async {
    // Real implementation would query:
    //   SELECT device_id, name, platform, last_seen_at
    //   FROM sessions
    //   WHERE user_id = session.authenticated!.userId
    //     AND revoked_at IS NULL
    return [];
  }

  /// Revokes the session for [deviceId] by setting `sessions.revoked_at`
  /// and removing the device's push token from `push_tokens`.
  ///
  /// Stub: no-op until the sessions table is queryable here.
  Future<void> revoke(Session session, String deviceId) async {
    // Real implementation would:
    //   UPDATE sessions SET revoked_at = NOW()
    //   WHERE device_id = deviceId AND user_id = session.authenticated!.userId
    //
    //   DELETE FROM push_tokens WHERE device_id = deviceId
  }
}
