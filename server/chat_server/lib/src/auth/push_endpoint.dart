import 'package:serverpod/serverpod.dart';

/// Push token registration endpoint.
///
/// Upserts a row in the `push_tokens` table so the server can deliver
/// FCM notifications to the device.
///
/// Requirements: 9.1, 9.5
class PushEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Registers (or updates) the FCM [token] for [userId] on [platform] and
  /// binds it to the stable [deviceId].
  ///
  /// [platform] is one of `'android'`, `'ios'`, or `'web'`.
  Future<void> registerToken(
    Session session,
    String userId,
    String deviceId,
    String token,
    String platform,
  ) async {
    final authUserId = session.authenticated!.userIdentifier;
    final stableDeviceId = deviceId.trim();
    final fcmToken = token.trim();
    final normalizedPlatform = platform.trim().toLowerCase();

    if (userId.trim().isEmpty) {
      throw ArgumentError('userId must not be empty');
    }
    if (fcmToken.isEmpty) {
      throw ArgumentError('token must not be empty');
    }
    if (stableDeviceId.isEmpty) {
      throw ArgumentError('deviceId must not be empty');
    }
    if (normalizedPlatform.isEmpty) {
      throw ArgumentError('platform must not be empty');
    }
    if (userId.trim() != authUserId) {
      throw ArgumentError('userId must match the authenticated user');
    }

    await session.db.unsafeQuery(
      '''
      INSERT INTO push_tokens
             ("authUserId", "deviceId", token, platform, "updatedAt")
      VALUES (@authUserId::uuid, @deviceId, @token, @platform, now())
      ON CONFLICT ("authUserId", "deviceId")
      DO UPDATE SET token = EXCLUDED.token,
                    platform = EXCLUDED.platform,
                    "updatedAt" = now()
      ''',
      parameters: QueryParameters.named({
        'authUserId': authUserId,
        'deviceId': stableDeviceId,
        'token': fcmToken,
        'platform': normalizedPlatform,
      }),
    );
  }
}
