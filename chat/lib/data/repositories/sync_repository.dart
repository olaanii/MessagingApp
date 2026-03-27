import 'dart:math';

/// Single pending logical send (Serverpod or legacy Firestore adapter consumes this).
class OutboxItem {
  const OutboxItem({
    required this.clientMsgId,
    required this.chatId,
    required this.operation,
    required this.payloadJson,
    required this.attemptCount,
    required this.state,
    required this.createdAt,
    this.nextRetryAt,
    this.localId,
  });

  final int? localId;
  final String clientMsgId;
  final String chatId;
  final String operation;
  final String payloadJson;
  final int attemptCount;
  final String state;
  final DateTime createdAt;
  final DateTime? nextRetryAt;
}

/// Outbox retries, opaque sync cursors, optional media upload rows (see `PendingMedia`).
abstract class SyncRepository {
  Future<void> enqueueOperation({
    required String clientMsgId,
    required String chatId,
    required String payloadJson,
    String operation = 'sendMessage',
  });

  Stream<List<OutboxItem>> watchOutbox({Iterable<String>? states});

  Future<void> updateOutboxEntry({
    required String clientMsgId,
    required String state,
    int? attemptCount,
    DateTime? nextRetryAt,
  });

  Future<String?> getCursor(String scopeKey);

  Future<void> setCursor(String scopeKey, String? cursor, {DateTime? at});

  /// Exponential backoff cap 5 minutes — align with ADR / Serverpod limits.
  static Duration backoff(int attemptCount) {
    final seconds = min(300, pow(2, max(0, attemptCount)).toInt());
    return Duration(seconds: max(1, seconds));
  }
}
