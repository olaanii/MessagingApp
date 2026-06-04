import 'package:serverpod/serverpod.dart';

/// Structured security log lines — **no** message bodies or ciphertext (ADR-0007).
abstract final class SecurityAudit {
  static void log(
    Session session, {
    required String event,
    String outcome = 'ok',
    String? userIdPrefix,
    String? deviceIdPrefix,
  }) {
    final reqId = session.sessionId.toString();
    final uid = userIdPrefix == null || userIdPrefix.length < 8
        ? userIdPrefix
        : '${userIdPrefix.substring(0, 8)}…';
    final did = deviceIdPrefix == null || deviceIdPrefix.length < 6
        ? deviceIdPrefix
        : '${deviceIdPrefix.substring(0, 6)}…';
    session.log(
      '[security] event=$event outcome=$outcome requestId=$reqId'
      '${uid != null ? ' user=$uid' : ''}'
      '${did != null ? ' device=$did' : ''}',
    );
  }

  static String remoteKey(Session session) {
    final req = session.request;
    if (req == null) {
      return 'unknown';
    }
    return req.remoteInfo;
  }

  static String? authenticatedUserPrefix(Session session) {
    final id = session.authenticated?.userIdentifier;
    if (id == null || id.isEmpty) {
      return null;
    }
    return id.length <= 8 ? id : id.substring(0, 8);
  }
}
