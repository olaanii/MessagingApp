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

  /// Registers (or updates) the FCM [token] for [userId] on [platform].
  ///
  /// [platform] is one of `'android'`, `'ios'`, or `'web'`.
  ///
  /// Stub: the real implementation would upsert a `push_tokens` row:
  ///
  /// ```sql
  /// INSERT INTO push_tokens (user_id, token, platform, updated_at)
  /// VALUES ($userId, $token, $platform, NOW())
  /// ON CONFLICT (user_id, platform)
  /// DO UPDATE SET token = EXCLUDED.token, updated_at = NOW();
  /// ```
  Future<void> registerToken(
    Session session,
    String userId,
    String token,
    String platform,
  ) async {
    // Stub: no-op until the push_tokens table migration is applied.
    // Real implementation:
    //   await PushToken.db.insertRow(session, PushToken(
    //     userId: userId,
    //     token: token,
    //     platform: platform,
    //   ));
  }
}
