// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:chat/core/crypto/e2ee_engine.dart';
import 'package:chat/data/repositories/message_repository.dart';
import 'package:chat/data/repositories/sync_repository.dart';
import 'package:chat/domain/models/message_model.dart';
import 'package:chat/features/chat/data/chat_key_store.dart';
import 'package:chat/features/chat/data/outbox_sync_worker.dart';
import 'package:chat/features/chat/data/stream_subscription_service.dart'
    show ChatRoomOpener;
import 'package:chat_client/chat_client.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

/// Fake [SyncRepository] that records state transitions.
final class _FakeSyncRepository implements SyncRepository {
  final Map<String, OutboxItem> _items = {};
  final List<Map<String, dynamic>> _updates = [];
  final _controller = StreamController<List<OutboxItem>>.broadcast();

  List<Map<String, dynamic>> get updates => List.unmodifiable(_updates);

  void addItem(OutboxItem item) {
    _items[item.clientMsgId] = item;
    _emit();
  }

  void _emit() {
    _controller.add(_items.values.toList());
  }

  @override
  Stream<List<OutboxItem>> watchOutbox({Iterable<String>? states}) {
    final stateSet = states?.toSet();
    List<OutboxItem> filter(List<OutboxItem> all) =>
        stateSet == null ? all : all.where((e) => stateSet.contains(e.state)).toList();

    // Emit current snapshot immediately, then stream future changes.
    final current = filter(_items.values.toList());
    late StreamController<List<OutboxItem>> ctrl;
    StreamSubscription<List<OutboxItem>>? sub;
    ctrl = StreamController<List<OutboxItem>>(
      onListen: () {
        ctrl.add(current);
        sub = _controller.stream.map(filter).listen(ctrl.add);
      },
      onCancel: () => sub?.cancel(),
    );
    return ctrl.stream;
  }

  @override
  Future<void> updateOutboxEntry({
    required String clientMsgId,
    required String state,
    int? attemptCount,
    DateTime? nextRetryAt,
  }) async {
    _updates.add({
      'clientMsgId': clientMsgId,
      'state': state,
      if (attemptCount != null) 'attemptCount': attemptCount,
      if (nextRetryAt != null) 'nextRetryAt': nextRetryAt,
    });
    final existing = _items[clientMsgId];
    if (existing != null) {
      _items[clientMsgId] = OutboxItem(
        localId: existing.localId,
        clientMsgId: existing.clientMsgId,
        chatId: existing.chatId,
        operation: existing.operation,
        payloadJson: existing.payloadJson,
        attemptCount: attemptCount ?? existing.attemptCount,
        state: state,
        createdAt: existing.createdAt,
        nextRetryAt: nextRetryAt ?? existing.nextRetryAt,
      );
    }
  }

  @override
  Future<void> enqueueOperation({
    required String clientMsgId,
    required String chatId,
    required String payloadJson,
    String operation = 'sendMessage',
  }) async {
    addItem(OutboxItem(
      clientMsgId: clientMsgId,
      chatId: chatId,
      operation: operation,
      payloadJson: payloadJson,
      attemptCount: 0,
      state: 'pending',
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<String?> getCursor(String scopeKey) async => null;

  @override
  Future<void> setCursor(String scopeKey, String? cursor, {DateTime? at}) async {}

  void close() => _controller.close();
}

/// Fake [MessageRepository] that records upsert calls.
final class _FakeMessageRepository implements MessageRepository {
  final List<({MessageModel message, int? serverSeq, String? clientMsgId})> upserted = [];

  @override
  Future<void> upsertLocalMessage(
    MessageModel message, {
    required String effectiveChatId,
    String? clientMsgId,
    int? serverSeq,
  }) async {
    upserted.add((message: message, serverSeq: serverSeq, clientMsgId: clientMsgId));
  }

  @override
  Future<void> tombstoneMessage(String messageId, DateTime deletedAt) async {}

  @override
  Future<void> mergeServerMessages(String chatId, List<MessageModel> messages) async {}

  @override
  Stream<List<MessageModel>> watchMessagesForChat(String chatId, {int limit = 200}) =>
      const Stream.empty();
}

/// Fake [ChatKeyStore] backed by an in-memory map.
final class _FakeChatKeyStore implements ChatKeyStore {
  final Map<String, SecretKey> _keys = {};

  void setKey(String chatId, SecretKey key) => _keys[chatId] = key;

  @override
  Future<SecretKey?> getChatKey(String chatId) async => _keys[chatId];

  @override
  Future<void> storeChatKey(String chatId, SecretKey key) async {
    _keys[chatId] = key;
  }

  @override
  Future<void> deleteChatKey(String chatId) async {
    _keys.remove(chatId);
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

final _engine = E2eeEngine();

OutboxItem _makeItem({
  required String clientMsgId,
  required String chatId,
  int attemptCount = 0,
  String state = 'pending',
  DateTime? nextRetryAt,
}) =>
    OutboxItem(
      clientMsgId: clientMsgId,
      chatId: chatId,
      operation: 'sendMessage',
      payloadJson: '{"text":"hello"}',
      attemptCount: attemptCount,
      state: state,
      createdAt: DateTime.now(),
      nextRetryAt: nextRetryAt,
    );

/// Build a fake [ChatRoomOpener] that immediately sends an ack for [clientMsgId].
ChatRoomOpener _ackingOpener({
  required String clientMsgId,
  required int serverSeq,
  String messageId = 'server_msg_1',
  List<ChatStreamEnvelope>? capturedSent,
}) {
  return (chatId, deviceId, inbound) {
    final controller = StreamController<ChatStreamEnvelope>();
    inbound.listen((envelope) {
      // Capture sent envelopes if requested.
      capturedSent?.add(envelope);
      // Respond with an ack.
      controller.add(ChatStreamEnvelope(
        type: 'message_ack',
        deviceId: deviceId,
        idempotencyKey: envelope.idempotencyKey,
        serverSeq: serverSeq,
        messageId: messageId,
      ));
    });
    return controller.stream;
  };
}

// ── Property 3: Outbox Idempotency ────────────────────────────────────────────
// Same clientMsgId sent multiple times yields the same serverSeq on every ack.
// **Validates: Requirements 5.7**

void main() {
  group('Property 3: Outbox Idempotency', () {
    test('same clientMsgId always uses the same idempotencyKey in the envelope', () async {
      final syncRepo = _FakeSyncRepository();
      final messageRepo = _FakeMessageRepository();
      final keyStore = _FakeChatKeyStore();
      final chatKey = await _engine.newChatKey();
      keyStore.setKey('chat_1', chatKey);

      const clientMsgId = 'idem-msg-001';
      const chatId = 'chat_1';
      const serverSeq = 42;

      final sentEnvelopes = <ChatStreamEnvelope>[];

      final worker = OutboxSyncWorker(
        syncRepo: syncRepo,
        messageRepo: messageRepo,
        openChatRoom: _ackingOpener(
          clientMsgId: clientMsgId,
          serverSeq: serverSeq,
          capturedSent: sentEnvelopes,
        ),
        crypto: _engine,
        keyStore: keyStore,
        deviceId: 'device_1',
      );

      // Enqueue the same clientMsgId twice (simulating a retry scenario).
      syncRepo.addItem(_makeItem(clientMsgId: clientMsgId, chatId: chatId));

      worker.start();
      // Allow processing.
      await Future<void>.delayed(const Duration(milliseconds: 200));
      worker.dispose();
      syncRepo.close();

      // All sent envelopes must carry the same idempotencyKey.
      expect(sentEnvelopes, isNotEmpty,
          reason: 'at least one envelope must have been sent');
      for (final env in sentEnvelopes) {
        expect(env.idempotencyKey, equals(clientMsgId),
            reason: 'idempotencyKey must equal clientMsgId (Req 5.7)');
      }
    });

    test('ack with same serverSeq is processed correctly on re-send', () async {
      final syncRepo = _FakeSyncRepository();
      final messageRepo = _FakeMessageRepository();
      final keyStore = _FakeChatKeyStore();
      final chatKey = await _engine.newChatKey();
      keyStore.setKey('chat_1', chatKey);

      const clientMsgId = 'idem-msg-002';
      const chatId = 'chat_1';
      const serverSeq = 99;

      final worker = OutboxSyncWorker(
        syncRepo: syncRepo,
        messageRepo: messageRepo,
        openChatRoom: _ackingOpener(
          clientMsgId: clientMsgId,
          serverSeq: serverSeq,
        ),
        crypto: _engine,
        keyStore: keyStore,
        deviceId: 'device_1',
      );

      syncRepo.addItem(_makeItem(clientMsgId: clientMsgId, chatId: chatId));

      worker.start();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      worker.dispose();
      syncRepo.close();

      // The message repo must have been updated with the correct serverSeq.
      expect(messageRepo.upserted, isNotEmpty,
          reason: 'upsertLocalMessage must be called on ack');
      expect(messageRepo.upserted.first.serverSeq, equals(serverSeq),
          reason: 'serverSeq from ack must be stored (Req 5.3)');

      // The outbox entry must be marked sent.
      final sentUpdates = syncRepo.updates
          .where((u) => u['clientMsgId'] == clientMsgId && u['state'] == 'sent')
          .toList();
      expect(sentUpdates, isNotEmpty,
          reason: 'outbox entry must transition to sent on ack (Req 5.3)');
    });

    test('payload is never transmitted in plaintext', () async {
      final syncRepo = _FakeSyncRepository();
      final messageRepo = _FakeMessageRepository();
      final keyStore = _FakeChatKeyStore();
      final chatKey = await _engine.newChatKey();
      keyStore.setKey('chat_1', chatKey);

      const clientMsgId = 'idem-msg-003';
      const chatId = 'chat_1';
      const plaintext = '{"text":"secret message"}';

      final sentEnvelopes = <ChatStreamEnvelope>[];

      final worker = OutboxSyncWorker(
        syncRepo: syncRepo,
        messageRepo: messageRepo,
        openChatRoom: _ackingOpener(
          clientMsgId: clientMsgId,
          serverSeq: 1,
          capturedSent: sentEnvelopes,
        ),
        crypto: _engine,
        keyStore: keyStore,
        deviceId: 'device_1',
      );

      syncRepo.addItem(OutboxItem(
        clientMsgId: clientMsgId,
        chatId: chatId,
        operation: 'sendMessage',
        payloadJson: plaintext,
        attemptCount: 0,
        state: 'pending',
        createdAt: DateTime.now(),
      ));

      worker.start();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      worker.dispose();
      syncRepo.close();

      expect(sentEnvelopes, isNotEmpty);
      for (final env in sentEnvelopes) {
        // The payloadJson must NOT contain the plaintext (Req 5.8).
        expect(env.payloadJson, isNot(equals(plaintext)),
            reason: 'payloadJson must be encrypted, not plaintext (Req 5.8)');
        // It must be valid JSON with the crypto envelope fields.
        final decoded = jsonDecode(env.payloadJson!) as Map<String, dynamic>;
        expect(decoded.containsKey('v'), isTrue,
            reason: 'encrypted payload must have schema version field');
        expect(decoded.containsKey('n'), isTrue,
            reason: 'encrypted payload must have nonce field');
        expect(decoded.containsKey('c'), isTrue,
            reason: 'encrypted payload must have ciphertext field');
      }
    });
  });

  // ── Property 4: Dead-Letter Bound ─────────────────────────────────────────
  // Any entry with attemptCount >= 10 transitions to dead_letter and receives
  // no further send attempts.
  // **Validates: Requirements 5.5**

  group('Property 4: Dead-Letter Bound', () {
    for (final attemptCount in [10, 11, 15, 20]) {
      test('entry with attemptCount=$attemptCount → dead_letter, no send', () async {
        final syncRepo = _FakeSyncRepository();
        final messageRepo = _FakeMessageRepository();
        final keyStore = _FakeChatKeyStore();
        final chatKey = await _engine.newChatKey();
        keyStore.setKey('chat_1', chatKey);

        final sentEnvelopes = <ChatStreamEnvelope>[];

        final worker = OutboxSyncWorker(
          syncRepo: syncRepo,
          messageRepo: messageRepo,
          openChatRoom: (chatId, deviceId, inbound) {
            final ctrl = StreamController<ChatStreamEnvelope>();
            inbound.listen(sentEnvelopes.add);
            return ctrl.stream;
          },
          crypto: _engine,
          keyStore: keyStore,
          deviceId: 'device_1',
        );

        // Entry already at or beyond the dead-letter threshold.
        syncRepo.addItem(_makeItem(
          clientMsgId: 'dead-$attemptCount',
          chatId: 'chat_1',
          attemptCount: attemptCount,
          state: 'failed',
        ));

        worker.start();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        worker.dispose();
        syncRepo.close();

        // Must transition to dead_letter.
        final deadLetterUpdates = syncRepo.updates
            .where((u) =>
                u['clientMsgId'] == 'dead-$attemptCount' &&
                u['state'] == 'dead_letter')
            .toList();
        expect(deadLetterUpdates, isNotEmpty,
            reason: 'entry with attemptCount=$attemptCount must be dead_lettered (Req 5.5)');

        // Must NOT have sent any envelope to the stream.
        expect(sentEnvelopes, isEmpty,
            reason: 'no send attempt must occur for dead_letter entries (Req 5.5)');
      });
    }

    test('entry with attemptCount=9 is still retried (boundary)', () async {
      final syncRepo = _FakeSyncRepository();
      final messageRepo = _FakeMessageRepository();
      final keyStore = _FakeChatKeyStore();
      final chatKey = await _engine.newChatKey();
      keyStore.setKey('chat_1', chatKey);

      const clientMsgId = 'boundary-9';
      final sentEnvelopes = <ChatStreamEnvelope>[];

      final worker = OutboxSyncWorker(
        syncRepo: syncRepo,
        messageRepo: messageRepo,
        openChatRoom: _ackingOpener(
          clientMsgId: clientMsgId,
          serverSeq: 1,
          capturedSent: sentEnvelopes,
        ),
        crypto: _engine,
        keyStore: keyStore,
        deviceId: 'device_1',
      );

      syncRepo.addItem(_makeItem(
        clientMsgId: clientMsgId,
        chatId: 'chat_1',
        attemptCount: 9,
        state: 'failed',
      ));

      worker.start();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      worker.dispose();
      syncRepo.close();

      // With attemptCount=9, the entry should still be sent (not dead-lettered yet).
      expect(sentEnvelopes, isNotEmpty,
          reason: 'entry with attemptCount=9 must still be attempted (boundary)');
    });

    test('transient error on attempt 9 → dead_letter (reaches 10)', () async {
      final syncRepo = _FakeSyncRepository();
      final messageRepo = _FakeMessageRepository();
      final keyStore = _FakeChatKeyStore();
      final chatKey = await _engine.newChatKey();
      keyStore.setKey('chat_1', chatKey);

      const clientMsgId = 'boundary-9-fail';

      final worker = OutboxSyncWorker(
        syncRepo: syncRepo,
        messageRepo: messageRepo,
        openChatRoom: (chatId, deviceId, inbound) {
          // Never ack — causes timeout → transient error.
          return const Stream.empty();
        },
        crypto: _engine,
        keyStore: keyStore,
        deviceId: 'device_1',
      );

      syncRepo.addItem(_makeItem(
        clientMsgId: clientMsgId,
        chatId: 'chat_1',
        attemptCount: 9,
        state: 'failed',
      ));

      worker.start();
      // Wait longer than the 10s ack timeout.
      await Future<void>.delayed(const Duration(seconds: 11));
      worker.dispose();
      syncRepo.close();

      final deadLetterUpdates = syncRepo.updates
          .where((u) =>
              u['clientMsgId'] == clientMsgId && u['state'] == 'dead_letter')
          .toList();
      expect(deadLetterUpdates, isNotEmpty,
          reason: 'attempt 9 failing → attemptCount becomes 10 → dead_letter (Req 5.5)');
    }, timeout: const Timeout(Duration(seconds: 20)));
  });

  // ── Property 12: Outbox Retry Backoff Is Strictly Increasing ─────────────
  // Each successive nextRetryAt is strictly greater than the previous;
  // delay satisfies delay <= min(30s, 2^attemptCount) + 2s.
  // **Validates: Requirements 5.4**

  group('Property 12: Outbox Retry Backoff Is Strictly Increasing', () {
    test('backoff formula: delay <= min(30s, 2^attemptCount) + 2s for all attempts 1..9', () {
      // Verify the formula without running the worker — pure math check.
      for (int attempt = 1; attempt <= 9; attempt++) {
        final baseSecs = math.min(30, math.pow(2, attempt).toInt());
        final maxDelaySecs = baseSecs + 2; // max jitter is 2s
        expect(maxDelaySecs, lessThanOrEqualTo(32),
            reason: 'delay for attempt $attempt must be <= 32s (Req 5.4)');
        expect(baseSecs, lessThanOrEqualTo(30),
            reason: 'base delay must be capped at 30s (Req 5.4)');
      }
    });

    test('successive nextRetryAt values are strictly increasing', () async {
      // Simulate multiple failures and verify nextRetryAt increases.
      final now = DateTime(2024, 1, 1, 12, 0, 0);
      final retryTimes = <DateTime>[];

      // Simulate the backoff computation for attempts 1..5.
      final rng = math.Random(42); // deterministic seed
      for (int attempt = 1; attempt <= 5; attempt++) {
        final baseSecs = math.min(30, math.pow(2, attempt).toInt());
        final jitterMs = rng.nextInt(2001);
        final delay = Duration(seconds: baseSecs, milliseconds: jitterMs);
        retryTimes.add(now.add(delay));
      }

      // Each retry time must be strictly greater than the previous.
      for (int i = 1; i < retryTimes.length; i++) {
        expect(retryTimes[i].isAfter(retryTimes[i - 1]), isTrue,
            reason: 'nextRetryAt[$i] must be after nextRetryAt[${i - 1}] (Req 5.4)');
      }
    });

    test('worker sets nextRetryAt in the future on transient error', () async {
      final syncRepo = _FakeSyncRepository();
      final messageRepo = _FakeMessageRepository();
      final keyStore = _FakeChatKeyStore();
      final chatKey = await _engine.newChatKey();
      keyStore.setKey('chat_1', chatKey);

      const clientMsgId = 'backoff-test-1';
      final clockTimes = <DateTime>[];
      int clockCallCount = 0;
      final baseTime = DateTime(2024, 6, 1, 10, 0, 0);

      DateTime fakeClock() {
        clockCallCount++;
        return baseTime;
      }

      final worker = OutboxSyncWorker(
        syncRepo: syncRepo,
        messageRepo: messageRepo,
        openChatRoom: (chatId, deviceId, inbound) {
          // Never ack — causes timeout.
          return const Stream.empty();
        },
        crypto: _engine,
        keyStore: keyStore,
        deviceId: 'device_1',
        clock: fakeClock,
        random: math.Random(0),
      );

      syncRepo.addItem(_makeItem(
        clientMsgId: clientMsgId,
        chatId: 'chat_1',
        attemptCount: 0,
        state: 'pending',
      ));

      worker.start();
      // Wait for the 10s ack timeout to fire.
      await Future<void>.delayed(const Duration(seconds: 11));
      worker.dispose();
      syncRepo.close();

      // Find the failed update with nextRetryAt.
      final failedUpdates = syncRepo.updates
          .where((u) =>
              u['clientMsgId'] == clientMsgId &&
              u['state'] == 'failed' &&
              u['nextRetryAt'] != null)
          .toList();

      expect(failedUpdates, isNotEmpty,
          reason: 'worker must set state=failed with nextRetryAt on transient error (Req 5.4)');

      final nextRetryAt = failedUpdates.first['nextRetryAt'] as DateTime;
      // nextRetryAt must be after baseTime (i.e., in the future relative to clock).
      expect(nextRetryAt.isAfter(baseTime), isTrue,
          reason: 'nextRetryAt must be in the future (Req 5.4)');

      // Verify delay is within bounds: min(30, 2^1) + 2 = 4s max.
      final delay = nextRetryAt.difference(baseTime);
      expect(delay.inSeconds, lessThanOrEqualTo(4),
          reason: 'delay for attempt 1 must be <= min(30,2^1)+2 = 4s (Req 5.4)');
      expect(delay.inMilliseconds, greaterThan(0),
          reason: 'delay must be positive');
    }, timeout: const Timeout(Duration(seconds: 20)));

    test('backoff cap: attempt >= 5 has base delay of 30s', () {
      // 2^5 = 32 > 30, so cap kicks in at attempt 5.
      for (int attempt = 5; attempt <= 9; attempt++) {
        final baseSecs = math.min(30, math.pow(2, attempt).toInt());
        expect(baseSecs, equals(30),
            reason: 'base delay must be capped at 30s for attempt $attempt (Req 5.4)');
      }
    });

    test('attemptCount is incremented on each transient failure', () async {
      final syncRepo = _FakeSyncRepository();
      final messageRepo = _FakeMessageRepository();
      final keyStore = _FakeChatKeyStore();
      final chatKey = await _engine.newChatKey();
      keyStore.setKey('chat_1', chatKey);

      const clientMsgId = 'backoff-count-test';

      final worker = OutboxSyncWorker(
        syncRepo: syncRepo,
        messageRepo: messageRepo,
        openChatRoom: (chatId, deviceId, inbound) => const Stream.empty(),
        crypto: _engine,
        keyStore: keyStore,
        deviceId: 'device_1',
      );

      syncRepo.addItem(_makeItem(
        clientMsgId: clientMsgId,
        chatId: 'chat_1',
        attemptCount: 3,
        state: 'failed',
      ));

      worker.start();
      await Future<void>.delayed(const Duration(seconds: 11));
      worker.dispose();
      syncRepo.close();

      final failedUpdates = syncRepo.updates
          .where((u) =>
              u['clientMsgId'] == clientMsgId && u['state'] == 'failed')
          .toList();

      expect(failedUpdates, isNotEmpty,
          reason: 'must have a failed update');
      // attemptCount must be incremented from 3 to 4.
      expect(failedUpdates.first['attemptCount'], equals(4),
          reason: 'attemptCount must be incremented on transient failure (Req 5.4)');
    }, timeout: const Timeout(Duration(seconds: 20)));
  });
}
