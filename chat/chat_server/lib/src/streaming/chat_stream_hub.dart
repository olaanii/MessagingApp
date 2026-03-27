import 'dart:async';

import 'package:chat_server/src/generated/streaming/chat_stream_envelope.dart';
import 'package:chat_server/src/streaming/safety_block_fanout.dart';
import 'package:serverpod/serverpod.dart';

/// In-process fan-out for **one** server instance (ADR-0004).
///
/// Multi-instance deployments need Redis pub/sub or equivalent; see
/// ADR-0009 (`docs/adr/0009-streaming-fanout-scale.md`).
class ChatStreamHub {
  ChatStreamHub._();
  static final ChatStreamHub instance = ChatStreamHub._();

  final Map<String, List<ChatStreamRegistration>> _rooms = {};

  static const int maxSubsPerChat = 256;
  static const int maxPayloadJsonChars = 65536;

  bool register(ChatStreamRegistration reg) {
    final list = _rooms.putIfAbsent(reg.chatId, () => []);
    if (list.length >= maxSubsPerChat) {
      return false;
    }
    if (list.any((r) => r.deviceId == reg.deviceId)) {
      return false;
    }
    list.add(reg);
    return true;
  }

  void unregister(ChatStreamRegistration reg) {
    final list = _rooms[reg.chatId];
    if (list == null) {
      return;
    }
    list.removeWhere((r) => identical(r, reg));
    if (list.isEmpty) {
      _rooms.remove(reg.chatId);
    }
  }

  /// Delivers [envelope] to subscribers in [chatId] except [exceptDeviceId].
  ///
  /// When [session] and [senderAuthUserId] are set, omits subscribers who **blocked**
  /// the sender (`safety_block`: blocker → blocked).
  Future<void> broadcast(
    Session? session,
    String chatId,
    ChatStreamEnvelope envelope, {
    String? exceptDeviceId,
    UuidValue? senderAuthUserId,
  }) async {
    final list = _rooms[chatId];
    if (list == null || list.isEmpty) {
      return;
    }
    final regs = List<ChatStreamRegistration>.from(list);
    final targets =
        regs.where((r) => exceptDeviceId == null || r.deviceId != exceptDeviceId).toList();

    var skipAuthIds = <UuidValue>{};
    if (session != null && senderAuthUserId != null) {
      final candidates = targets
          .map((r) => r.authUserId)
          .whereType<UuidValue>()
          .toSet();
      candidates.remove(senderAuthUserId);
      if (candidates.isNotEmpty) {
        skipAuthIds = await SafetyBlockFanout.subscriberIdsBlockingSender(
          session,
          senderAuthUserId: senderAuthUserId,
          candidateSubscriberAuthIds: candidates,
        );
      }
    }

    for (final reg in targets) {
      final aid = reg.authUserId;
      if (aid != null && skipAuthIds.contains(aid)) {
        continue;
      }
      unawaited(reg.deliver(envelope));
    }
  }
}

class ChatStreamRegistration {
  ChatStreamRegistration({
    required this.chatId,
    required this.deviceId,
    this.authUserId,
    required Future<void> Function(ChatStreamEnvelope envelope) deliver,
  }) : _deliver = deliver;

  final String chatId;
  final String deviceId;

  /// Serverpod auth user when the stream was opened with a logged-in session.
  final UuidValue? authUserId;
  final Future<void> Function(ChatStreamEnvelope envelope) _deliver;

  Future<void> deliver(ChatStreamEnvelope envelope) => _deliver(envelope);
}
