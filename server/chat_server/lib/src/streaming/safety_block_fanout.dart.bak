import 'package:chat_server/src/generated/safety/safety_block.dart';
import 'package:serverpod/serverpod.dart';

/// Skip realtime delivery to subscribers who have blocked the sender (ADR-0007:
/// blocker does not receive from blocked — here the subscriber is the blocker).
abstract final class SafetyBlockFanout {
  /// Returns subscriber auth user ids who must **not** receive this sender's event.
  static Future<Set<UuidValue>> subscriberIdsBlockingSender(
    Session session, {
    required UuidValue senderAuthUserId,
    required Set<UuidValue> candidateSubscriberAuthIds,
  }) async {
    if (candidateSubscriberAuthIds.isEmpty) {
      return {};
    }
    final rows = await SafetyBlock.db.find(
      session,
      where: (t) =>
          t.blockerAuthUserId.inSet(candidateSubscriberAuthIds) &
          t.blockedAuthUserId.equals(senderAuthUserId),
      limit: candidateSubscriberAuthIds.length,
    );
    return {for (final r in rows) r.blockerAuthUserId};
  }
}
