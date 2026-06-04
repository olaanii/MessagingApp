import 'package:serverpod/serverpod.dart';

/// Skip realtime delivery to subscribers who have blocked the sender (ADR-0007).
abstract final class SafetyBlockFanout {
  static Future<Set<UuidValue>> subscriberIdsBlockingSender(
    Session session, {
    required UuidValue senderAuthUserId,
    required Set<UuidValue> candidateSubscriberAuthIds,
  }) async {
    if (candidateSubscriberAuthIds.isEmpty) return {};

    // UuidValues are validated; safe to embed in literal IN list.
    final inList = candidateSubscriberAuthIds
        .map((id) => "'${id.uuid}'::uuid")
        .join(', ');

    final rows = await session.db.unsafeQuery(
      'SELECT "blockerAuthUserId" FROM safety_block '
      'WHERE "blockedAuthUserId" = @blocked::uuid '
      'AND "blockerAuthUserId" IN ($inList)',
      parameters: QueryParameters.named({'blocked': senderAuthUserId.uuid}),
    );

    return {
      for (final row in rows) UuidValue.fromString(row[0].toString()),
    };
  }
}
