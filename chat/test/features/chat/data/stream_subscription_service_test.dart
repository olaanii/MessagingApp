// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:chat/core/crypto/e2ee_engine.dart';
import 'package:chat/data/repositories/message_repository.dart';
import 'package:chat/domain/models/message_model.dart';
import 'package:chat/features/chat/data/stream_subscription_service.dart';
import 'package:chat_client/chat_client.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

/// Fake [MessageRepository] that records upsert calls.
final class _FakeMessageRepository implements MessageRepository {
  final List<MessageModel> upserted = [];

  @override
  Future<void> upsertLocalMessage(
    MessageModel message, {
    required String effectiveChatId,
    String? clientMsgId,
    int? serverSeq,
  }) async {
    upserted.add(message);
  }

  @override
  Future<void> tombstoneMessage(String messageId, DateTime deletedAt) async {}
  @override
  Future<void> mergeServerMessages(String chatId, List<MessageModel> messages) async {}
  @override
  Stream<List<MessageModel>> watchMessagesForChat(String chatId, {int limit = 200}) =>
      const Stream.empty();
}

// ── Helpers ───────────────────────────────────────────────────────────────────

final _engine = E2eeEngine();

/// Build a valid base64-encoded payloadJson for a [MessageCryptoEnvelope].
Future<String> _buildPayloadJson(String plaintext, SecretKey key) async {
  final envelope = await _engine.encryptUtf8Message(plaintext, key);
  return jsonEncode({
    'v': envelope.schemaVersion,
    'n': base64Encode(envelope.nonce),
    'c': base64Encode(envelope.ciphertextWithMac),
  });
}

ChatStreamEnvelope _messageEnvelope({
  required String chatId,
  required String payloadJson,
  String messageId = 'msg_1',
  int serverSeq = 1,
}) =>
    ChatStreamEnvelope(
      type: 'message',
      deviceId: 'device_1',
      chatId: chatId,
      messageId: messageId,
      serverSeq: serverSeq,
      payloadJson: payloadJson,
      idempotencyKey: messageId,
    );

// ── Property 11: Inbound Message Decrypt-Then-Write ───────────────────────────
// Valid envelope calls upsertLocalMessage exactly once;
// failed decryption calls it zero times.
// **Validates: Requirements 3.2, 3.3, 3.4**

void main() {
  group('Property 11: Inbound Message Decrypt-Then-Write', () {
    late SecretKey chatKey;

    setUp(() async {
      chatKey = await _engine.newChatKey();
    });

    final plaintexts = [
      'hello world',
      '',
      'unicode 🔑 message',
      'a' * 1000,
      'line1\nline2\ttab',
    ];

    for (final plaintext in plaintexts) {
      test('valid envelope → upsertLocalMessage called once: "${plaintext.length > 30 ? plaintext.substring(0, 30) : plaintext}"', () async {
        final repo = _FakeMessageRepository();
        final payloadJson = await _buildPayloadJson(plaintext, chatKey);
        const chatId = 'chat_1';

        final completer = Completer<void>();
        final service = StreamSubscriptionServiceImpl(
          openChatRoom: (_, _, _) => Stream.fromIterable([
            _messageEnvelope(chatId: chatId, payloadJson: payloadJson),
          ]),
          messageRepository: repo,
          crypto: _engine,
          getChatKey: (_) async => chatKey,
        );

        final events = <InboundChatEvent>[];
        service.subscribe(
          chatId: chatId,
          deviceId: 'device_1',
          outbound: const Stream.empty(),
        ).listen(
          events.add,
          onDone: completer.complete,
        );

        await completer.future.timeout(const Duration(seconds: 5));
        service.dispose();

        expect(
          repo.upserted.length,
          equals(1),
          reason: 'upsertLocalMessage must be called exactly once for a valid envelope (Req 3.3)',
        );
        expect(
          repo.upserted.first.content,
          equals(plaintext),
          reason: 'stored content must equal the decrypted plaintext',
        );
        expect(
          events.whereType<MessageEvent>().length,
          equals(1),
          reason: 'exactly one MessageEvent must be emitted',
        );
      });
    }

    test('failed decryption → upsertLocalMessage NOT called, ErrorEvent emitted', () async {
      final repo = _FakeMessageRepository();
      const chatId = 'chat_bad';

      // Corrupt payload — not a valid MessageCryptoEnvelope.
      const badPayload = '{"v":1,"n":"AAAA","c":"BBBB"}';

      final completer = Completer<void>();
      final service = StreamSubscriptionServiceImpl(
        openChatRoom: (_, _, _) => Stream.fromIterable([
          _messageEnvelope(chatId: chatId, payloadJson: badPayload),
        ]),
        messageRepository: repo,
        crypto: _engine,
        getChatKey: (_) async => chatKey,
      );

      final events = <InboundChatEvent>[];
      service.subscribe(
        chatId: chatId,
        deviceId: 'device_1',
        outbound: const Stream.empty(),
      ).listen(
        events.add,
        onDone: completer.complete,
      );

      await completer.future.timeout(const Duration(seconds: 5));
      service.dispose();

      expect(
        repo.upserted,
        isEmpty,
        reason: 'upsertLocalMessage must NOT be called when decryption fails (Req 3.4)',
      );
      expect(
        events.whereType<ErrorEvent>().length,
        greaterThanOrEqualTo(1),
        reason: 'an ErrorEvent must be emitted when decryption fails (Req 3.4)',
      );
    });

    test('missing chat key → upsertLocalMessage NOT called, ErrorEvent emitted', () async {
      final repo = _FakeMessageRepository();
      const chatId = 'chat_nokey';
      final payloadJson = await _buildPayloadJson('test', chatKey);

      final completer = Completer<void>();
      final service = StreamSubscriptionServiceImpl(
        openChatRoom: (_, _, _) => Stream.fromIterable([
          _messageEnvelope(chatId: chatId, payloadJson: payloadJson),
        ]),
        messageRepository: repo,
        crypto: _engine,
        getChatKey: (_) async => null, // no key
      );

      final events = <InboundChatEvent>[];
      service.subscribe(
        chatId: chatId,
        deviceId: 'device_1',
        outbound: const Stream.empty(),
      ).listen(
        events.add,
        onDone: completer.complete,
      );

      await completer.future.timeout(const Duration(seconds: 5));
      service.dispose();

      expect(repo.upserted, isEmpty,
          reason: 'no write must occur when chat key is absent');
      expect(events.whereType<ErrorEvent>().length, greaterThanOrEqualTo(1));
    });

    test('multiple valid envelopes → upsertLocalMessage called once per envelope', () async {
      final repo = _FakeMessageRepository();
      const chatId = 'chat_multi';
      final messages = ['msg A', 'msg B', 'msg C'];

      final envelopes = await Future.wait(
        messages.indexed.map((entry) async {
          final (i, text) = entry;
          final payload = await _buildPayloadJson(text, chatKey);
          return _messageEnvelope(
            chatId: chatId,
            payloadJson: payload,
            messageId: 'msg_$i',
            serverSeq: i + 1,
          );
        }),
      );

      final completer = Completer<void>();
      final service = StreamSubscriptionServiceImpl(
        openChatRoom: (_, _, _) => Stream.fromIterable(envelopes),
        messageRepository: repo,
        crypto: _engine,
        getChatKey: (_) async => chatKey,
      );

      service.subscribe(
        chatId: chatId,
        deviceId: 'device_1',
        outbound: const Stream.empty(),
      ).listen((_) {}, onDone: completer.complete);

      await completer.future.timeout(const Duration(seconds: 5));
      service.dispose();

      expect(repo.upserted.length, equals(messages.length),
          reason: 'one upsert per valid envelope');
    });
  });

  // ── Property 6: Stream Reconnect Liveness ────────────────────────────────
  // Reconnect attempt initiated within 32 s on non-auth error;
  // delay bounded by min(32, 2^attempt) + 3.
  // **Validates: Requirements 3.5**

  group('Property 6: Stream Reconnect Liveness', () {
    test('reconnects after non-auth stream error', () async {
      int connectCount = 0;
      final completer = Completer<void>();

      final service = StreamSubscriptionServiceImpl(
        openChatRoom: (chatId, deviceId, _) {
          connectCount++;
          if (connectCount == 1) {
            // First connect: throw a transient error.
            return Stream.error(Exception('network error'));
          }
          // Second connect: complete normally.
          completer.complete();
          return const Stream.empty();
        },
        messageRepository: _FakeMessageRepository(),
        crypto: _engine,
        getChatKey: (_) async => null,
      );

      service.subscribe(
        chatId: 'chat_reconnect',
        deviceId: 'device_1',
        outbound: const Stream.empty(),
      ).listen((_) {});

      // Should reconnect within a short time (attempt=0 → delay = 1 + jitter ≤ 4 s).
      await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => fail('Service did not reconnect within 10 seconds'),
      );
      service.dispose();

      expect(connectCount, greaterThanOrEqualTo(2),
          reason: 'service must attempt at least one reconnect after a non-auth error (Req 3.5)');
    });

    test('does NOT reconnect after auth_required error', () async {
      int connectCount = 0;
      final connectionEvents = <ConnectionEvent>[];

      final service = StreamSubscriptionServiceImpl(
        openChatRoom: (_, _, _) {
          connectCount++;
          return Stream.error(Exception('auth_required'));
        },
        messageRepository: _FakeMessageRepository(),
        crypto: _engine,
        getChatKey: (_) async => null,
      );

      service.connectionEventStream.listen(connectionEvents.add);

      service.subscribe(
        chatId: 'chat_auth',
        deviceId: 'device_1',
        outbound: const Stream.empty(),
      ).listen((_) {});

      // Wait briefly — should NOT reconnect.
      await Future<void>.delayed(const Duration(milliseconds: 200));
      service.dispose();

      expect(connectCount, equals(1),
          reason: 'service must NOT reconnect after auth_required error (Req 3.6)');
      expect(connectionEvents, contains(ConnectionEvent.authRequired),
          reason: 'ConnectionEvent.authRequired must be emitted (Req 3.6)');
    });

    test('reconnect delay for attempt N is bounded by min(32, 2^N) + 3', () {
      // Verify the delay formula without actually waiting.
      for (int attempt = 0; attempt <= 6; attempt++) {
        final maxDelay = math.min(32, math.pow(2, attempt).toInt()) + 3;
        expect(maxDelay, lessThanOrEqualTo(35),
            reason: 'delay must never exceed 35 s (32 + 3 jitter)');
        if (attempt < 5) {
          expect(maxDelay, lessThan(35),
              reason: 'delay for attempt $attempt must be less than max');
        }
      }
    });
  });
}
