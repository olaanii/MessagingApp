import 'dart:async';

import 'package:chat_server/src/generated/security/rate_limit_exception.dart';
import 'package:chat_server/src/generated/streaming/chat_stream_envelope.dart';
import 'package:chat_server/src/security/security_guards.dart';
import 'package:serverpod/serverpod.dart';

import 'chat_stream_hub.dart';

/// Realtime chat channel (ADR-0004). Same authentication contract as RPC
/// once Firebase → Serverpod session land (ADR-0003).
///
/// **Persistence:** MVP uses in-memory sequence + idempotency. Replace with
/// `MessageEndpoint.send` + Postgres before production fan-out.
class _DedupedMessage {
  _DedupedMessage({
    required this.serverSeq,
    required this.messageId,
    this.payloadJson,
  });

  final int serverSeq;
  final String messageId;
  final String? payloadJson;
}

class ChatStreamEndpoint extends Endpoint {
  static final _seqByChat = <String, int>{};
  static final _sent = <String, _DedupedMessage>{};

  UuidValue? _streamAuthUserId(Session session) {
    final info = session.authenticated;
    if (info == null) {
      return null;
    }
    return UuidValueJsonExtension.fromJson(info.userIdentifier);
  }

  String _idemKey(String chatId, String deviceId, String? idempotencyKey) =>
      '$chatId|$deviceId|${idempotencyKey ?? ''}';

  Stream<ChatStreamEnvelope> chatRoom(
    Session session,
    String chatId,
    String deviceId,
    Stream<ChatStreamEnvelope> inbound,
  ) async* {
    if (chatId.isEmpty || deviceId.isEmpty) {
      yield _error(
        deviceId: deviceId,
        chatId: chatId.isEmpty ? null : chatId,
        code: 'bad_request',
        message: 'chatId and deviceId must be non-empty',
      );
      return;
    }

    try {
      SecurityGuards.requireStreamConnectAllowed(session, deviceId: deviceId);
    } on RateLimitException catch (e) {
      yield _error(
        deviceId: deviceId,
        chatId: chatId,
        code: e.code,
        message: e.message,
      );
      return;
    }

    final outbound = StreamController<ChatStreamEnvelope>();

    final registration = ChatStreamRegistration(
      chatId: chatId,
      deviceId: deviceId,
      authUserId: _streamAuthUserId(session),
      deliver: (envelope) async {
        if (!outbound.isClosed) {
          outbound.add(envelope);
        }
      },
    );

    if (!ChatStreamHub.instance.register(registration)) {
      yield _error(
        deviceId: deviceId,
        chatId: chatId,
        code: 'room_full_or_duplicate_device',
        message:
            'Too many subscribers for this chat, or deviceId already connected',
      );
      return;
    }

    late final StreamSubscription<ChatStreamEnvelope> sub;
    try {
      sub = inbound.listen(
        (envelope) async {
          try {
            await _onInbound(
              session: session,
              chatId: chatId,
              deviceId: deviceId,
              envelope: envelope,
              outbound: outbound,
            );
          } on RateLimitException catch (e) {
            if (!outbound.isClosed) {
              outbound.add(
                _error(
                  deviceId: deviceId,
                  chatId: chatId,
                  code: e.code,
                  message: e.message,
                ),
              );
            }
          } catch (error, _) {
            if (!outbound.isClosed) {
              outbound.add(
                _error(
                  deviceId: deviceId,
                  chatId: chatId,
                  code: 'handler_error',
                  message: error.toString(),
                ),
              );
            }
          }
        },
        onError: (Object error, StackTrace st) {
          if (!outbound.isClosed) {
            outbound.add(
              _error(
                deviceId: deviceId,
                chatId: chatId,
                code: 'stream_error',
                message: error.toString(),
              ),
            );
          }
        },
        onDone: () async {
          await outbound.close();
        },
        cancelOnError: false,
      );

      yield* outbound.stream;
    } finally {
      await sub.cancel();
      ChatStreamHub.instance.unregister(registration);
      await outbound.close();
    }
  }

  Future<void> _onInbound({
    required Session session,
    required String chatId,
    required String deviceId,
    required ChatStreamEnvelope envelope,
    required StreamController<ChatStreamEnvelope> outbound,
  }) async {
    SecurityGuards.requireStreamFrameAllowed(
      session,
      chatId: chatId,
      deviceId: deviceId,
    );

    if (envelope.chatId != null && envelope.chatId != chatId) {
      outbound.add(
        _error(
          deviceId: deviceId,
          chatId: chatId,
          code: 'chat_mismatch',
          message: 'Envelope chatId does not match stream',
        ),
      );
      return;
    }

    final payload = envelope.payloadJson;
    if (payload != null && payload.length > ChatStreamHub.maxPayloadJsonChars) {
      outbound.add(
        _error(
          deviceId: deviceId,
          chatId: chatId,
          code: 'payload_too_large',
          message: 'payloadJson exceeds cap',
        ),
      );
      return;
    }

    if (envelope.type == 'send_message') {
      SecurityGuards.requireStreamSendMessageAllowed(
        session,
        chatId: chatId,
        deviceId: deviceId,
      );
      await _handleSendMessage(
        session: session,
        chatId: chatId,
        deviceId: deviceId,
        envelope: envelope,
        outbound: outbound,
      );
    } else if (envelope.type == 'typing' ||
        envelope.type == 'presence' ||
        envelope.type == 'sync_hint') {
      final relay = envelope.copyWith(
        ts: DateTime.now().toUtc(),
        chatId: chatId,
      );
      await ChatStreamHub.instance.broadcast(
        session,
        chatId,
        relay,
        exceptDeviceId: deviceId,
        senderAuthUserId: _streamAuthUserId(session),
      );
    } else if (envelope.type == 'message_ack') {
      final relay = envelope.copyWith(
        ts: DateTime.now().toUtc(),
        chatId: chatId,
      );
      await ChatStreamHub.instance.broadcast(
        session,
        chatId,
        relay,
        exceptDeviceId: deviceId,
        senderAuthUserId: _streamAuthUserId(session),
      );
    } else {
      outbound.add(
        _error(
          deviceId: deviceId,
          chatId: chatId,
          code: 'unsupported_inbound_type',
          message: envelope.type,
        ),
      );
    }
  }

  Future<void> _handleSendMessage({
    required Session session,
    required String chatId,
    required String deviceId,
    required ChatStreamEnvelope envelope,
    required StreamController<ChatStreamEnvelope> outbound,
  }) async {
    final idem = envelope.idempotencyKey;
    if (idem == null || idem.isEmpty) {
      outbound.add(
        _error(
          deviceId: deviceId,
          chatId: chatId,
          code: 'idempotency_required',
          message: 'idempotencyKey required for send_message',
        ),
      );
      return;
    }

    final key = _idemKey(chatId, deviceId, idem);
    final existing = _sent[key];
    if (existing != null) {
      await ChatStreamHub.instance.broadcast(
        session,
        chatId,
        ChatStreamEnvelope(
          type: 'message',
          idempotencyKey: idem,
          deviceId: deviceId,
          chatId: chatId,
          ts: DateTime.now().toUtc(),
          payloadJson: existing.payloadJson,
          serverSeq: existing.serverSeq,
          messageId: existing.messageId,
        ),
        senderAuthUserId: _streamAuthUserId(session),
      );
      return;
    }

    final seq = (_seqByChat[chatId] ?? 0) + 1;
    _seqByChat[chatId] = seq;
    final messageId = const Uuid().v4();
    _sent[key] = _DedupedMessage(
      serverSeq: seq,
      messageId: messageId,
      payloadJson: envelope.payloadJson,
    );

    await ChatStreamHub.instance.broadcast(
      session,
      chatId,
      ChatStreamEnvelope(
        type: 'message',
        idempotencyKey: idem,
        deviceId: deviceId,
        chatId: chatId,
        ts: DateTime.now().toUtc(),
        payloadJson: envelope.payloadJson,
        serverSeq: seq,
        messageId: messageId,
      ),
      senderAuthUserId: _streamAuthUserId(session),
    );
  }

  ChatStreamEnvelope _error({
    required String deviceId,
    String? chatId,
    required String code,
    required String message,
  }) {
    return ChatStreamEnvelope(
      type: 'error',
      deviceId: deviceId,
      chatId: chatId,
      ts: DateTime.now().toUtc(),
      errorCode: code,
      errorMessage: message,
    );
  }
}
