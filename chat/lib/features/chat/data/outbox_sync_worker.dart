import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:chat_client/chat_client.dart';

import '../../../core/crypto/e2ee_engine.dart';
import '../../../data/repositories/message_repository.dart';
import '../../../data/repositories/sync_repository.dart';
import '../../../domain/models/message_model.dart';
import 'chat_key_store.dart';
import 'stream_subscription_service.dart' show ChatRoomOpener;

// ── E2EE exception ────────────────────────────────────────────────────────────

/// Thrown when a required chat key is absent from [ChatKeyStore].
final class E2eeException implements Exception {
  const E2eeException._(this.message);

  /// The chat key for the requested chatId was not found in [ChatKeyStore].
  factory E2eeException.keyNotFound(String chatId) =>
      E2eeException._('Chat key not found for chatId=$chatId');

  final String message;

  @override
  String toString() => 'E2eeException: $message';
}

// ── Permanent error sentinel ──────────────────────────────────────────────────

/// Thrown (or detected) when the server returns a permanent error that should
/// immediately dead-letter the outbox entry (auth failure, payload too large).
final class PermanentSendError implements Exception {
  const PermanentSendError(this.message);
  final String message;
  @override
  String toString() => 'PermanentSendError: $message';
}

// ── OutboxSyncWorker ──────────────────────────────────────────────────────────

/// Processes pending outbox entries, encrypts payloads, sends them via the
/// Serverpod chat stream, and updates delivery state.
///
/// Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9
final class OutboxSyncWorker {
  OutboxSyncWorker({
    required SyncRepository syncRepo,
    required MessageRepository messageRepo,
    required ChatRoomOpener openChatRoom,
    required E2eeEngine crypto,
    required ChatKeyStore keyStore,
    required String deviceId,
    DateTime Function()? clock,
    math.Random? random,
  })  : _syncRepo = syncRepo,
        _messageRepo = messageRepo,
        _openChatRoom = openChatRoom,
        _crypto = crypto,
        _keyStore = keyStore,
        _deviceId = deviceId,
        _clock = clock ?? DateTime.now,
        _random = random ?? math.Random();

  final SyncRepository _syncRepo;
  final MessageRepository _messageRepo;
  final ChatRoomOpener _openChatRoom;
  final E2eeEngine _crypto;
  final ChatKeyStore _keyStore;
  final String _deviceId;
  final DateTime Function() _clock;
  final math.Random _random;

  bool _running = false;
  bool _disposed = false;
  StreamSubscription<List<OutboxItem>>? _outboxSub;

  // Per-chat outbound stream controllers (one per active chatId).
  final Map<String, StreamController<ChatStreamEnvelope>> _outboundControllers =
      {};
  // Per-chat inbound ack streams.
  final Map<String, Stream<ChatStreamEnvelope>> _inboundStreams = {};

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Start processing the outbox. Safe to call multiple times — idempotent.
  ///
  /// Requirement 5.1
  void start() {
    if (_disposed || _running) return;
    _running = true;
    _outboxSub = _syncRepo
        .watchOutbox(states: ['pending', 'failed']).listen(_onOutboxBatch);
  }

  /// Pause processing. Entries already in-flight are not cancelled.
  ///
  /// Requirement 5.9
  void pause() {
    if (!_running) return;
    _running = false;
    _outboxSub?.cancel();
    _outboxSub = null;
  }

  /// Dispose all resources. The worker cannot be restarted after disposal.
  void dispose() {
    _disposed = true;
    pause();
    for (final ctrl in _outboundControllers.values) {
      ctrl.close();
    }
    _outboundControllers.clear();
    _inboundStreams.clear();
  }

  // ── Outbox batch handler ──────────────────────────────────────────────────

  void _onOutboxBatch(List<OutboxItem> entries) {
    if (!_running || _disposed) return;
    final now = _clock();
    for (final entry in entries) {
      // Skip entries whose retry window has not elapsed.
      if (entry.nextRetryAt != null && entry.nextRetryAt!.isAfter(now)) {
        continue;
      }
      // Process each eligible entry independently (fire-and-forget per entry).
      _processEntry(entry);
    }
  }

  // ── Entry processing ──────────────────────────────────────────────────────

  /// Process a single outbox entry end-to-end.
  ///
  /// Requirements: 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8
  Future<void> _processEntry(OutboxItem entry) async {
    // Requirement 5.5: dead_letter immediately if already at/beyond threshold.
    if (entry.attemptCount >= 10) {
      await _syncRepo.updateOutboxEntry(
        clientMsgId: entry.clientMsgId,
        state: 'dead_letter',
        attemptCount: entry.attemptCount,
      );
      return;
    }

    // Mark as sending.
    await _syncRepo.updateOutboxEntry(
      clientMsgId: entry.clientMsgId,
      state: 'sending',
    );

    try {
      // Requirement 6.3 / 6.4: retrieve chat key — throw if absent.
      final chatKey = await _keyStore.getChatKey(entry.chatId);
      if (chatKey == null) {
        throw E2eeException.keyNotFound(entry.chatId);
      }

      // Requirement 5.2 / 5.8: encrypt before transmitting.
      final cryptoEnvelope =
          await _crypto.encryptUtf8Message(entry.payloadJson, chatKey);
      final encryptedPayload = _serializeEnvelope(cryptoEnvelope);

      // Requirement 5.7: use clientMsgId as idempotency key.
      final outboundEnvelope = ChatStreamEnvelope(
        type: 'send_message',
        idempotencyKey: entry.clientMsgId,
        deviceId: _deviceId,
        chatId: entry.chatId,
        payloadJson: encryptedPayload,
      );

      // Send and await ack.
      final ack = await _sendAndAwaitAck(
        entry.chatId,
        outboundEnvelope,
        entry.clientMsgId,
      );

      // Requirement 5.3: on ack, mark sent and update local message.
      await _syncRepo.updateOutboxEntry(
        clientMsgId: entry.clientMsgId,
        state: 'sent',
      );

      await _messageRepo.upsertLocalMessage(
        MessageModel(
          id: ack.messageId,
          chatId: entry.chatId,
          senderId: _deviceId,
          receiverId: '',
          content: entry.payloadJson,
          timestamp: _clock(),
          status: 'sent',
        ),
        effectiveChatId: entry.chatId,
        clientMsgId: entry.clientMsgId,
        serverSeq: ack.serverSeq,
      );
    } on PermanentSendError {
      // Requirement 5.6: permanent error → dead_letter immediately.
      await _syncRepo.updateOutboxEntry(
        clientMsgId: entry.clientMsgId,
        state: 'dead_letter',
      );
    } on E2eeException {
      // Key not found — treat as permanent for this entry.
      await _syncRepo.updateOutboxEntry(
        clientMsgId: entry.clientMsgId,
        state: 'dead_letter',
      );
    } catch (_) {
      // Requirement 5.4 / 5.5: transient error → backoff or dead_letter.
      final newAttemptCount = entry.attemptCount + 1;
      if (newAttemptCount >= 10) {
        // Requirement 5.5: dead_letter after 10 attempts.
        await _syncRepo.updateOutboxEntry(
          clientMsgId: entry.clientMsgId,
          state: 'dead_letter',
          attemptCount: newAttemptCount,
        );
      } else {
        final backoff = _computeBackoff(newAttemptCount);
        await _syncRepo.updateOutboxEntry(
          clientMsgId: entry.clientMsgId,
          state: 'failed',
          attemptCount: newAttemptCount,
          nextRetryAt: _clock().add(backoff),
        );
      }
    }
  }

  // ── Stream management ─────────────────────────────────────────────────────

  /// Ensure a bidirectional stream is open for [chatId] and send [envelope],
  /// then wait for the matching ack envelope.
  Future<_AckResult> _sendAndAwaitAck(
    String chatId,
    ChatStreamEnvelope envelope,
    String clientMsgId,
  ) async {
    // Lazily open a stream per chatId.
    if (!_outboundControllers.containsKey(chatId)) {
      final outboundCtrl = StreamController<ChatStreamEnvelope>();
      _outboundControllers[chatId] = outboundCtrl;
      _inboundStreams[chatId] =
          _openChatRoom(chatId, _deviceId, outboundCtrl.stream).asBroadcastStream();
    }

    final inbound = _inboundStreams[chatId]!;
    final outbound = _outboundControllers[chatId]!;

    // Listen for the ack before sending to avoid a race.
    final ackFuture = inbound
        .where((e) =>
            e.type == 'message_ack' && e.idempotencyKey == clientMsgId)
        .first
        .timeout(const Duration(seconds: 10));

    outbound.add(envelope);

    final ackEnvelope = await ackFuture;

    // Check for permanent error codes in the ack.
    if (ackEnvelope.errorCode != null) {
      final code = ackEnvelope.errorCode!;
      if (code == 'auth_required' || code == 'payload_too_large') {
        throw PermanentSendError(code);
      }
    }

    return _AckResult(
      serverSeq: ackEnvelope.serverSeq ?? 0,
      messageId: ackEnvelope.messageId ?? clientMsgId,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Requirement 5.4: `delay = min(30s, 2^attemptCount) + random(0..2s)`.
  Duration _computeBackoff(int attemptCount) {
    final baseSecs = math.min(30, math.pow(2, attemptCount).toInt());
    final jitterMs = _random.nextInt(2001); // 0..2000 ms
    return Duration(seconds: baseSecs, milliseconds: jitterMs);
  }

  /// Serialise [MessageCryptoEnvelope] to the wire JSON format:
  /// `{"v":1,"n":"<base64>","c":"<base64>"}`.
  String _serializeEnvelope(MessageCryptoEnvelope envelope) {
    return jsonEncode({
      'v': envelope.schemaVersion,
      'n': base64Encode(envelope.nonce),
      'c': base64Encode(envelope.ciphertextWithMac),
    });
  }
}

// ── Internal result type ──────────────────────────────────────────────────────

final class _AckResult {
  const _AckResult({required this.serverSeq, required this.messageId});
  final int serverSeq;
  final String messageId;
}
