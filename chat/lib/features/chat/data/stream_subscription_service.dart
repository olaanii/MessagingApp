import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:chat_client/chat_client.dart';
import 'package:cryptography/cryptography.dart';

import '../../../core/crypto/e2ee_engine.dart';
import '../../../data/repositories/message_repository.dart';
import '../../../domain/models/message_model.dart';

// ── Inbound event hierarchy ───────────────────────────────────────────────────

/// Events emitted on the broadcast stream returned by [ChatStreamService.subscribe].
sealed class InboundChatEvent {}

/// A decrypted inbound message.
final class MessageEvent extends InboundChatEvent {
  MessageEvent({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.plaintext,
    required this.serverSeq,
    required this.ts,
  });

  final String messageId;
  final String chatId;
  final String senderId;

  /// Decrypted plaintext content.
  final String plaintext;
  final int serverSeq;
  final DateTime ts;
}

/// Server acknowledgement for an outbound message.
final class AckEvent extends InboundChatEvent {
  AckEvent({
    required this.idempotencyKey,
    required this.serverSeq,
    required this.messageId,
  });

  final String idempotencyKey;
  final int serverSeq;
  final String messageId;
}

/// Typing indicator from another participant.
final class TypingEvent extends InboundChatEvent {
  TypingEvent({required this.senderId, required this.chatId});

  final String senderId;
  final String chatId;
}

/// An error or decryption failure on an inbound envelope.
final class ErrorEvent extends InboundChatEvent {
  ErrorEvent({required this.code, required this.message});

  final String code;
  final String message;
}

// ── Connection events ─────────────────────────────────────────────────────────

/// Connection-level events emitted on [ChatStreamService.connectionEventStream].
enum ConnectionEvent {
  /// The server rejected the connection due to an auth error.
  /// The service will NOT attempt automatic reconnection.
  authRequired,
}

// ── Seam type ─────────────────────────────────────────────────────────────────

/// Function signature that opens a bidirectional chat room stream.
///
/// Matches [EndpointChatStream.chatRoom] so the real [Client] and test fakes
/// can both be injected without subclassing the generated [Client].
typedef ChatRoomOpener = Stream<ChatStreamEnvelope> Function(
  String chatId,
  String deviceId,
  Stream<ChatStreamEnvelope> inbound,
);

// ── Interface ─────────────────────────────────────────────────────────────────

/// Manages the bidirectional WebSocket stream to [ChatStreamEndpoint.chatRoom].
///
/// Requirements: 3.1–3.8
abstract interface class ChatStreamService {
  /// Opens the stream for [chatId] / [deviceId].
  ///
  /// Returns a broadcast stream of decrypted [InboundChatEvent]s.
  /// [outbound] is forwarded to the server as-is (already encrypted by the
  /// outbox worker before it reaches here).
  ///
  /// Only opens a connection when [MessagingSyncMode.useServerpod] is active
  /// (callers are responsible for the mode check — Requirement 3.7).
  Stream<InboundChatEvent> subscribe({
    required String chatId,
    required String deviceId,
    required Stream<ChatStreamEnvelope> outbound,
  });

  /// Broadcast stream of [ConnectionEvent]s (e.g. auth_required).
  Stream<ConnectionEvent> get connectionEventStream;

  /// Close the stream and release resources.
  void dispose();
}

// ── Implementation ────────────────────────────────────────────────────────────

/// Concrete implementation backed by the generated Serverpod [Client].
///
/// Reconnects with exponential backoff on non-auth errors (Requirement 3.5).
final class StreamSubscriptionServiceImpl implements ChatStreamService {
  StreamSubscriptionServiceImpl({
    required ChatRoomOpener openChatRoom,
    required MessageRepository messageRepository,
    required E2eeEngine crypto,
    required Future<SecretKey?> Function(String chatId) getChatKey,
  })  : _openChatRoom = openChatRoom,
        _messageRepository = messageRepository,
        _crypto = crypto,
        _getChatKey = getChatKey;

  /// Convenience constructor that extracts [ChatRoomOpener] from a [Client].
  factory StreamSubscriptionServiceImpl.fromClient({
    required Client client,
    required MessageRepository messageRepository,
    required E2eeEngine crypto,
    required Future<SecretKey?> Function(String chatId) getChatKey,
  }) =>
      StreamSubscriptionServiceImpl(
        openChatRoom: client.chatStream.chatRoom,
        messageRepository: messageRepository,
        crypto: crypto,
        getChatKey: getChatKey,
      );

  final ChatRoomOpener _openChatRoom;
  final MessageRepository _messageRepository;
  final E2eeEngine _crypto;
  final Future<SecretKey?> Function(String chatId) _getChatKey;

  final StreamController<ConnectionEvent> _connectionEventController =
      StreamController<ConnectionEvent>.broadcast();

  bool _disposed = false;

  @override
  Stream<ConnectionEvent> get connectionEventStream =>
      _connectionEventController.stream;

  // ── subscribe ─────────────────────────────────────────────────────────────

  /// Requirements: 3.1, 3.5, 3.7, 3.8
  @override
  Stream<InboundChatEvent> subscribe({
    required String chatId,
    required String deviceId,
    required Stream<ChatStreamEnvelope> outbound,
  }) {
    final controller = StreamController<InboundChatEvent>();

    _connectWithBackoff(
      chatId: chatId,
      deviceId: deviceId,
      outbound: outbound,
      sink: controller,
    );

    return controller.stream;
  }

  // ── Backoff reconnect loop ────────────────────────────────────────────────

  /// Stream reconnect algorithm per design doc.
  ///
  /// delay = min(32, 2^attempt) + random(0..3) seconds
  /// Resets attempt counter on successful connect.
  ///
  /// Requirements: 3.5, 3.6
  Future<void> _connectWithBackoff({
    required String chatId,
    required String deviceId,
    required Stream<ChatStreamEnvelope> outbound,
    required StreamController<InboundChatEvent> sink,
  }) async {
    int attempt = 0;
    final rng = math.Random();

    while (!_disposed) {
      bool cleanClose = false;
      try {
        final inbound = _openChatRoom(chatId, deviceId, outbound);
        attempt = 0; // reset on successful connect

        await for (final envelope in inbound) {
          if (_disposed) break;
          await _handleInbound(envelope, chatId, sink);
        }
        cleanClose = true; // stream ended without error
      } catch (e) {
        if (_disposed) break;

        final errorCode = _extractErrorCode(e);
        if (errorCode == 'auth_required') {
          // Requirement 3.6: do not reconnect on auth error.
          _connectionEventController.add(ConnectionEvent.authRequired);
          break;
        }

        // Requirement 3.5: exponential backoff, max 32 s.
        final delaySecs = math.min(32, math.pow(2, attempt).toInt()) +
            rng.nextInt(4); // 0..3 s jitter
        attempt++;
        await Future<void>.delayed(Duration(seconds: delaySecs));
        continue;
      }

      // Clean stream close — exit the reconnect loop.
      if (cleanClose) break;
    }

    if (!sink.isClosed) await sink.close();
  }

  // ── Inbound envelope handler ──────────────────────────────────────────────

  /// Requirements: 3.2, 3.3, 3.4
  Future<void> _handleInbound(
    ChatStreamEnvelope envelope,
    String chatId,
    StreamController<InboundChatEvent> sink,
  ) async {
    switch (envelope.type) {
      case 'message':
        await _handleMessage(envelope, chatId, sink);
      case 'message_ack':
        _handleAck(envelope, sink);
      case 'typing':
        _handleTyping(envelope, sink);
      case 'error':
        sink.add(ErrorEvent(
          code: envelope.errorCode ?? 'unknown',
          message: envelope.errorMessage ?? '',
        ));
      default:
        // Ignore unknown envelope types (forward-compatible).
        break;
    }
  }

  /// Decrypt → write to Drift → emit MessageEvent.
  ///
  /// Requirements: 3.2, 3.3, 3.4
  Future<void> _handleMessage(
    ChatStreamEnvelope envelope,
    String chatId,
    StreamController<InboundChatEvent> sink,
  ) async {
    final payloadJson = envelope.payloadJson;
    if (payloadJson == null) {
      sink.add(ErrorEvent(code: 'missing_payload', message: 'payloadJson is null'));
      return;
    }

    try {
      final chatKey = await _getChatKey(chatId);
      if (chatKey == null) {
        sink.add(ErrorEvent(
          code: 'key_not_found',
          message: 'No chat key for chatId=$chatId',
        ));
        return;
      }

      // Deserialise the MessageCryptoEnvelope from the payloadJson.
      final cryptoEnvelope = _parseCryptoEnvelope(payloadJson);
      final plaintext = await _crypto.decryptUtf8Message(cryptoEnvelope, chatKey);

      // Requirement 3.3: write exactly once on success.
      final messageId = envelope.messageId ?? envelope.idempotencyKey ?? '';
      final serverSeq = envelope.serverSeq ?? 0;
      final ts = envelope.ts ?? DateTime.now();

      await _messageRepository.upsertLocalMessage(
        MessageModel(
          id: messageId,
          chatId: chatId,
          senderId: envelope.deviceId,
          receiverId: '',
          content: plaintext,
          timestamp: ts,
        ),
        effectiveChatId: chatId,
        clientMsgId: envelope.idempotencyKey,
        serverSeq: serverSeq,
      );

      sink.add(MessageEvent(
        messageId: messageId,
        chatId: chatId,
        senderId: envelope.deviceId,
        plaintext: plaintext,
        serverSeq: serverSeq,
        ts: ts,
      ));
    } catch (_) {
      // Requirement 3.4: on decryption failure emit ErrorEvent, no partial write.
      sink.add(ErrorEvent(
        code: 'decryption_failed',
        message: 'Failed to decrypt envelope for chatId=$chatId',
      ));
    }
  }

  void _handleAck(
    ChatStreamEnvelope envelope,
    StreamController<InboundChatEvent> sink,
  ) {
    sink.add(AckEvent(
      idempotencyKey: envelope.idempotencyKey ?? '',
      serverSeq: envelope.serverSeq ?? 0,
      messageId: envelope.messageId ?? '',
    ));
  }

  void _handleTyping(
    ChatStreamEnvelope envelope,
    StreamController<InboundChatEvent> sink,
  ) {
    sink.add(TypingEvent(
      senderId: envelope.deviceId,
      chatId: envelope.chatId ?? '',
    ));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String? _extractErrorCode(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('auth_required')) return 'auth_required';
    return null;
  }

  /// Parse a base64-encoded [MessageCryptoEnvelope] from [payloadJson].
  ///
  /// The envelope is serialised as `{ "v": 1, "n": "<base64>", "c": "<base64>" }`.
  MessageCryptoEnvelope _parseCryptoEnvelope(String payloadJson) {
    final map = jsonDecode(payloadJson) as Map<String, dynamic>;
    return MessageCryptoEnvelope(
      schemaVersion: map['v'] as int,
      nonce: base64Decode(map['n'] as String),
      ciphertextWithMac: base64Decode(map['c'] as String),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _connectionEventController.close();
  }
}
