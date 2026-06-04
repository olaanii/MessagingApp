// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:convert';

import 'package:chat/core/crypto/e2ee_engine.dart';
import 'package:chat/data/repositories/message_repository.dart';
import 'package:chat/domain/models/message_model.dart';
import 'package:chat/features/chat/data/stream_subscription_service.dart';
import 'package:chat_client/chat_client.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

/// Fake [MessageRepository] that records all operations.
final class _FakeMessageRepository implements MessageRepository {
  final List<MessageModel> upserted = [];
  final List<({String idempotencyKey, int serverSeq, String messageId})> ackRecords = [];

  @override
  Stream<List<MessageModel>> watchMessagesForChat(String chatId, {int limit = 200}) =>
      const Stream.empty();

  @override
  Future<void> upsertLocalMessage(
    MessageModel message, {
    required String effectiveChatId,
    String? clientMsgId,
    int? serverSeq,
  }) async {
    upserted.add(message);
    if (clientMsgId != null && serverSeq != null) {
      ackRecords.add((
        idempotencyKey: clientMsgId,
        serverSeq: serverSeq,
        messageId: message.id,
      ));
    }
  }

  @override
  Future<void> tombstoneMessage(String messageId, DateTime deletedAt) async {}

  @override
  Future<void> mergeServerMessages(String chatId, List<MessageModel> messages) async {}
}

// ── Helpers ───────────────────────────────────────────────────────────────────

final _engine = E2eeEngine();

Future<String> _buildEncryptedPayload(String plaintext, SecretKey key) async {
  final envelope = await _engine.encryptUtf8Message(plaintext, key);
  return jsonEncode({
    'v': envelope.schemaVersion,
    'n': base64Encode(envelope.nonce),
    'c': base64Encode(envelope.ciphertextWithMac),
  });
}

ChatStreamEnvelope _msgEnvelope({
  required String chatId,
  required String payloadJson,
  String messageId = 'msg_1',
  int serverSeq = 1,
  String deviceId = 'device_sender',
}) =>
    ChatStreamEnvelope(
      type: 'message',
      deviceId: deviceId,
      chatId: chatId,
      messageId: messageId,
      serverSeq: serverSeq,
      payloadJson: payloadJson,
      idempotencyKey: messageId,
    );

ChatStreamEnvelope _typingEnvelope({
  required String chatId,
  String deviceId = 'device_sender',
}) =>
    ChatStreamEnvelope(
      type: 'typing',
      deviceId: deviceId,
      chatId: chatId,
    );

ChatStreamEnvelope _ackEnvelope({
  required String idempotencyKey,
  required int serverSeq,
  String messageId = 'msg_1',
}) =>
    ChatStreamEnvelope(
      type: 'message_ack',
      deviceId: 'device_server',
      idempotencyKey: idempotencyKey,
      serverSeq: serverSeq,
      messageId: messageId,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // Task 8.4 / 17.5 — Streaming Integration Tests
  // Requirements: 2.6, 17.1, 17.5
  // ═══════════════════════════════════════════════════════════════════════════

  group('Task 8.4 / 17.5 — Streaming Integration', () {
    late SecretKey chatKey;

    setUp(() async {
      chatKey = await _engine.newChatKey();
    });

    // ── Message event delivered to all chat members ───────────────────────
    // Requirement 2.6, 17.1

    test('message event: valid envelope is decrypted and stored', () async {
      final repo = _FakeMessageRepository();
      const chatId = 'chat_stream_1';
      final payloadJson = await _buildEncryptedPayload('hello streaming', chatKey);

      final completer = Completer<void>();
      final service = StreamSubscriptionServiceImpl(
        openChatRoom: (_, _, _) => Stream.fromIterable([
          _msgEnvelope(chatId: chatId, payloadJson: payloadJson),
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
      ).listen(events.add, onDone: completer.complete);

      await completer.future.timeout(const Duration(seconds: 5));
      service.dispose();

      // Message was stored.
      expect(repo.upserted, hasLength(1));
      expect(repo.upserted.first.content, equals('hello streaming'));

      // MessageEvent was emitted.
      final messageEvents = events.whereType<MessageEvent>().toList();
      expect(messageEvents, hasLength(1));
      expect(messageEvents.first.plaintext, equals('hello streaming'));
      expect(messageEvents.first.chatId, equals(chatId));
    });

    test('message event: multiple envelopes produce multiple MessageEvents', () async {
      final repo = _FakeMessageRepository();
      const chatId = 'chat_stream_multi';

      final envelopes = await Future.wait(
        List.generate(3, (i) async {
          final payload = await _buildEncryptedPayload('msg $i', chatKey);
          return _msgEnvelope(
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

      final events = <InboundChatEvent>[];
      service.subscribe(
        chatId: chatId,
        deviceId: 'device_1',
        outbound: const Stream.empty(),
      ).listen(events.add, onDone: completer.complete);

      await completer.future.timeout(const Duration(seconds: 5));
      service.dispose();

      final messageEvents = events.whereType<MessageEvent>().toList();
      expect(messageEvents, hasLength(3));
      expect(repo.upserted, hasLength(3));
    });

    // ── Typing indicator ─────────────────────────────────────────────────
    // Requirement 17.1, 17.2, 17.3, 17.4

    test('typing event: TypingEvent is emitted on typing envelope', () async {
      final repo = _FakeMessageRepository();
      const chatId = 'chat_typing';

      final completer = Completer<void>();
      final service = StreamSubscriptionServiceImpl(
        openChatRoom: (_, _, _) => Stream.fromIterable([
          _typingEnvelope(chatId: chatId, deviceId: 'device_other'),
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
      ).listen(events.add, onDone: completer.complete);

      await completer.future.timeout(const Duration(seconds: 5));
      service.dispose();

      final typingEvents = events.whereType<TypingEvent>().toList();
      expect(typingEvents, hasLength(1));
      expect(typingEvents.first.senderId, equals('device_other'));
      expect(typingEvents.first.chatId, equals(chatId));
    });

    // ── Message ack ──────────────────────────────────────────────────────
    // Requirement 16.3, 16.4, 16.5, 16.6

    test('message_ack: AckEvent is emitted on ack envelope', () async {
      final repo = _FakeMessageRepository();
      const chatId = 'chat_ack';

      final completer = Completer<void>();
      final service = StreamSubscriptionServiceImpl(
        openChatRoom: (_, _, _) => Stream.fromIterable([
          _ackEnvelope(idempotencyKey: 'client_msg_1', serverSeq: 42, messageId: 'server_msg_1'),
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
      ).listen(events.add, onDone: completer.complete);

      await completer.future.timeout(const Duration(seconds: 5));
      service.dispose();

      final ackEvents = events.whereType<AckEvent>().toList();
      expect(ackEvents, hasLength(1));
      expect(ackEvents.first.idempotencyKey, equals('client_msg_1'));
      expect(ackEvents.first.serverSeq, equals(42));
      expect(ackEvents.first.messageId, equals('server_msg_1'));
    });

    // ── Presence: connection events ──────────────────────────────────────
    // Requirement 17.5

    test('connection event: authRequired is emitted on auth error', () async {
      final repo = _FakeMessageRepository();
      const chatId = 'chat_presence';

      final service = StreamSubscriptionServiceImpl(
        openChatRoom: (_, _, _) => Stream.error(Exception('auth_required')),
        messageRepository: repo,
        crypto: _engine,
        getChatKey: (_) async => chatKey,
      );

      final connectionEvents = <ConnectionEvent>[];
      service.connectionEventStream.listen(connectionEvents.add);

      service.subscribe(
        chatId: chatId,
        deviceId: 'device_1',
        outbound: const Stream.empty(),
      ).listen((_) {});

      // Wait for the error to propagate.
      await Future<void>.delayed(const Duration(milliseconds: 200));
      service.dispose();

      expect(connectionEvents, contains(ConnectionEvent.authRequired));
    });

    // ── Decryption failure handling ──────────────────────────────────────

    test('decryption failure: ErrorEvent emitted, no partial write', () async {
      final repo = _FakeMessageRepository();
      const chatId = 'chat_decrypt_fail';

      final completer = Completer<void>();
      final service = StreamSubscriptionServiceImpl(
        openChatRoom: (_, _, _) => Stream.fromIterable([
          _msgEnvelope(chatId: chatId, payloadJson: '{"v":1,"n":"AAAA","c":"BBBB"}'),
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
      ).listen(events.add, onDone: completer.complete);

      await completer.future.timeout(const Duration(seconds: 5));
      service.dispose();

      expect(repo.upserted, isEmpty,
          reason: 'no write must occur on decryption failure');
      final errorEvents = events.whereType<ErrorEvent>().toList();
      expect(errorEvents, isNotEmpty);
      expect(errorEvents.first.code, equals('decryption_failed'));
    });

    // ── Missing chat key ─────────────────────────────────────────────────

    test('missing chat key: ErrorEvent emitted, no write', () async {
      final repo = _FakeMessageRepository();
      const chatId = 'chat_no_key';
      final payloadJson = await _buildEncryptedPayload('secret', chatKey);

      final completer = Completer<void>();
      final service = StreamSubscriptionServiceImpl(
        openChatRoom: (_, _, _) => Stream.fromIterable([
          _msgEnvelope(chatId: chatId, payloadJson: payloadJson),
        ]),
        messageRepository: repo,
        crypto: _engine,
        getChatKey: (_) async => null, // no key available
      );

      final events = <InboundChatEvent>[];
      service.subscribe(
        chatId: chatId,
        deviceId: 'device_1',
        outbound: const Stream.empty(),
      ).listen(events.add, onDone: completer.complete);

      await completer.future.timeout(const Duration(seconds: 5));
      service.dispose();

      expect(repo.upserted, isEmpty);
      final errorEvents = events.whereType<ErrorEvent>().toList();
      expect(errorEvents, isNotEmpty);
      expect(errorEvents.first.code, equals('key_not_found'));
    });

    // ── Outbound forwarding ──────────────────────────────────────────────

    test('outbound envelopes are forwarded to the chat room', () async {
      final repo = _FakeMessageRepository();
      const chatId = 'chat_outbound';
      final outboundEnvelopes = <ChatStreamEnvelope>[];

      final outboundController = StreamController<ChatStreamEnvelope>();

      final completer = Completer<void>();
      final service = StreamSubscriptionServiceImpl(
        openChatRoom: (_, _, inbound) {
          // Capture what the server would receive.
          inbound.listen(outboundEnvelopes.add);
          completer.complete();
          return const Stream.empty();
        },
        messageRepository: repo,
        crypto: _engine,
        getChatKey: (_) async => chatKey,
      );

      service.subscribe(
        chatId: chatId,
        deviceId: 'device_1',
        outbound: outboundController.stream,
      ).listen((_) {});

      // Send an outbound envelope.
      outboundController.add(ChatStreamEnvelope(
        type: 'message',
        deviceId: 'device_1',
        payloadJson: '{"v":1,"n":"AAAA","c":"BBBB"}',
        idempotencyKey: 'out_1',
      ));

      await completer.future.timeout(const Duration(seconds: 5));
      await outboundController.close();
      service.dispose();

      expect(outboundEnvelopes, hasLength(1));
      expect(outboundEnvelopes.first.idempotencyKey, equals('out_1'));
    });
  });
}
