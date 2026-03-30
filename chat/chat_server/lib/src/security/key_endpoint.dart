import 'dart:convert';

import 'package:serverpod/serverpod.dart';

/// Server-side key management endpoint for E2EE key distribution.
///
/// Stores and retrieves X25519 public key bundles and wrapped chat key
/// envelopes in the `device_keys` table.
///
/// Table schema (must exist before this endpoint is used):
/// ```sql
/// CREATE TABLE device_keys (
///   id          uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
///   auth_user_id uuid NOT NULL,
///   device_id   text NOT NULL,
///   bundle_json text NOT NULL,   -- JSON-encoded PublicKeyBundle
///   created_at  timestamp NOT NULL DEFAULT now(),
///   UNIQUE (auth_user_id, device_id)
/// );
///
/// CREATE TABLE wrapped_chat_keys (
///   id          uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
///   chat_id     text NOT NULL,
///   recipient_auth_user_id uuid NOT NULL,
///   envelope_json text NOT NULL, -- JSON-encoded WrappedChatKeyEnvelope
///   created_at  timestamp NOT NULL DEFAULT now()
/// );
/// ```
///
/// Requirements: 6.1, 6.2
class KeyEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  // ── uploadBundle ──────────────────────────────────────────────────────────

  /// Upload the caller's [PublicKeyBundle] for [deviceId].
  ///
  /// Upserts the row so re-registration (e.g. after key rotation) is safe.
  ///
  /// [bundleJson] is a JSON-encoded map with fields:
  ///   - `schemaVersion` (int)
  ///   - `x25519Public` (base64-encoded 32-byte public key)
  Future<void> uploadBundle(
    Session session,
    String deviceId,
    String bundleJson,
  ) async {
    _requireNonEmpty(deviceId, 'deviceId');
    _requireNonEmpty(bundleJson, 'bundleJson');
    _validateBundleJson(bundleJson);

    final authUserId = _authenticatedUserId(session);

    await session.db.unsafeQuery(
      '''
      INSERT INTO device_keys (auth_user_id, device_id, bundle_json)
      VALUES (@authUserId, @deviceId, @bundleJson)
      ON CONFLICT (auth_user_id, device_id)
      DO UPDATE SET bundle_json = EXCLUDED.bundle_json,
                    created_at  = now()
      ''',
      parameters: QueryParameters.named({
        'authUserId': authUserId,
        'deviceId': deviceId,
        'bundleJson': bundleJson,
      }),
    );
  }

  // ── fetchUserBundle ───────────────────────────────────────────────────────

  /// Fetch the most-recently uploaded [PublicKeyBundle] for [userId].
  ///
  /// Returns the JSON-encoded bundle string, or `null` if no bundle exists.
  Future<String?> fetchUserBundle(Session session, String userId) async {
    _requireNonEmpty(userId, 'userId');

    final result = await session.db.unsafeQuery(
      '''
      SELECT bundle_json
      FROM   device_keys
      WHERE  auth_user_id = @userId::uuid
      ORDER  BY created_at DESC
      LIMIT  1
      ''',
      parameters: QueryParameters.named({'userId': userId}),
    );

    if (result.isEmpty) return null;
    final row = result.first;
    return row.first as String?;
  }

  // ── uploadWrappedKeys ─────────────────────────────────────────────────────

  /// Upload a batch of wrapped chat key envelopes for [chatId].
  ///
  /// Each element of [envelopesJson] is a JSON-encoded map with fields:
  ///   - `recipientAuthUserId` (String UUID)
  ///   - `schemaVersion` (int)
  ///   - `ephemeralPublic` (base64)
  ///   - `nonce` (base64)
  ///   - `ciphertextWithMac` (base64)
  ///
  /// Existing envelopes for the same (chatId, recipientAuthUserId) are
  /// replaced so that key rotation is idempotent.
  Future<void> uploadWrappedKeys(
    Session session,
    String chatId,
    List<String> envelopesJson,
  ) async {
    _requireNonEmpty(chatId, 'chatId');
    if (envelopesJson.isEmpty) return;

    for (final envJson in envelopesJson) {
      final map = _parseJson(envJson);
      final recipientId = map['recipientAuthUserId'] as String?;
      if (recipientId == null || recipientId.isEmpty) {
        throw ArgumentError(
          'Each envelope must contain a non-empty recipientAuthUserId',
        );
      }

      await session.db.unsafeQuery(
        '''
        INSERT INTO wrapped_chat_keys
               (chat_id, recipient_auth_user_id, envelope_json)
        VALUES (@chatId, @recipientId::uuid, @envelopeJson)
        ON CONFLICT (chat_id, recipient_auth_user_id)
        DO UPDATE SET envelope_json = EXCLUDED.envelope_json,
                      created_at    = now()
        ''',
        parameters: QueryParameters.named({
          'chatId': chatId,
          'recipientId': recipientId,
          'envelopeJson': envJson,
        }),
      );
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Extract the authenticated user's UUID string from the session.
  String _authenticatedUserId(Session session) {
    final auth = session.authenticated;
    if (auth == null) {
      throw ServerpodUnauthenticatedException();
    }
    return auth.userIdentifier;
  }

  void _requireNonEmpty(String value, String name) {
    if (value.trim().isEmpty) {
      throw ArgumentError('$name must not be empty');
    }
  }

  Map<String, dynamic> _parseJson(String json) {
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      throw ArgumentError('Invalid JSON: $json');
    }
  }

  void _validateBundleJson(String bundleJson) {
    final map = _parseJson(bundleJson);
    if (map['x25519Public'] == null) {
      throw ArgumentError('bundleJson must contain x25519Public');
    }
    if (map['schemaVersion'] == null) {
      throw ArgumentError('bundleJson must contain schemaVersion');
    }
  }
}
