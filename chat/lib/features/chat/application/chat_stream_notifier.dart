import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/serverpod/serverpod_client_provider.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../core/crypto/e2ee_engine.dart';
import '../data/stream_subscription_service.dart';

// ── Connection state ──────────────────────────────────────────────────────────

/// Observable connection state for a chat stream.
enum ChatStreamConnectionState {
  /// Not yet connected or disposed.
  idle,

  /// Stream is open and receiving events.
  connected,

  /// Reconnecting after a transient error.
  reconnecting,

  /// Server rejected the connection due to an auth error.
  authRequired,
}

// ── Notifier ──────────────────────────────────────────────────────────────────

/// Manages the [ChatStreamService] lifecycle for a single [chatId].
///
/// - Starts the stream on build.
/// - Closes the stream on dispose.
/// - Exposes [ChatStreamConnectionState] to the UI.
///
/// Requirements: 3.1, 3.8
class ChatStreamNotifier extends Notifier<ChatStreamConnectionState> {
  ChatStreamNotifier(this._chatId);

  final String _chatId;

  StreamSubscriptionServiceImpl? _service;
  StreamSubscription<InboundChatEvent>? _eventSub;
  StreamSubscription<ConnectionEvent>? _connectionSub;

  @override
  ChatStreamConnectionState build() {
    final client = ref.watch(serverpodClientProvider);
    final messageRepo = ref.watch(messageRepositoryProvider);

    _service = StreamSubscriptionServiceImpl.fromClient(
      client: client,
      messageRepository: messageRepo,
      crypto: E2eeEngine(),
      // TODO(task-7): replace with ChatKeyStore.getChatKey once task 7.1 is done.
      getChatKey: (_) async => null,
    );

    // Listen for auth-required connection events.
    _connectionSub = _service!.connectionEventStream.listen((event) {
      if (event == ConnectionEvent.authRequired) {
        state = ChatStreamConnectionState.authRequired;
      }
    });

    // Open the stream. Outbound messages are sent by OutboxSyncWorker (task 8).
    final inboundStream = _service!.subscribe(
      chatId: _chatId,
      deviceId: _deviceId(),
      outbound: const Stream.empty(),
    );

    _eventSub = inboundStream.listen(
      (_) {
        // Messages are written to Drift inside StreamSubscriptionServiceImpl.
        // Update connection state to connected on first event.
        if (state != ChatStreamConnectionState.connected) {
          state = ChatStreamConnectionState.connected;
        }
      },
      onError: (_) {
        state = ChatStreamConnectionState.reconnecting;
      },
    );

    ref.onDispose(_cleanup);

    return ChatStreamConnectionState.idle;
  }

  void _cleanup() {
    _eventSub?.cancel();
    _connectionSub?.cancel();
    _service?.dispose();
    _service = null;
  }

  /// Stable device ID — placeholder until device identity store is wired (task 3.1).
  String _deviceId() => 'local_device';
}

/// Provider family keyed by [chatId].
///
/// Auto-disposes when the chat screen is closed (Requirement 3.8).
final chatStreamNotifierProvider = NotifierProvider.autoDispose
    .family<ChatStreamNotifier, ChatStreamConnectionState, String>(
  ChatStreamNotifier.new,
);
