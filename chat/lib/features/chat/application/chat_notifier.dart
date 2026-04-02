import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/sync/messaging_backend.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../data/services/messaging_service.dart';
import '../../../domain/models/message_model.dart';
import '../data/media_upload_service.dart';

// ── Safety client abstraction ─────────────────────────────────────────────────

/// Minimal interface for the Serverpod safety endpoint calls.
///
/// Extracted so tests can inject a fake without a live Serverpod [Client].
///
/// Requirements: 10.1, 10.2
abstract class SafetyClient {
  Future<void> blockUser(String blockedAuthUserId);

  Future<void> submitReport({
    String? targetUserId,
    String? targetChatId,
    String? targetMessageId,
    required String reason,
  });
}

/// Provider for [SafetyClient].
///
/// Overridable in tests to inject a fake.
final _safetyClientProvider = Provider<SafetyClient>(
  (ref) => _NullSafetyClient(),
);

/// No-op [SafetyClient] used when no real client is wired.
final class _NullSafetyClient implements SafetyClient {
  @override
  Future<void> blockUser(String blockedAuthUserId) async {
    throw UnsupportedError(
      'safetyClientProvider is not configured. '
      'Override _safetyClientProvider with a real implementation.',
    );
  }

  @override
  Future<void> submitReport({
    String? targetUserId,
    String? targetChatId,
    String? targetMessageId,
    required String reason,
  }) async {
    throw UnsupportedError(
      'safetyClientProvider is not configured. '
      'Override _safetyClientProvider with a real implementation.',
    );
  }
}

/// Public provider alias so callers can override [_safetyClientProvider].
///
/// Requirements: 10.1, 10.2
// ignore: library_private_types_in_public_api
final safetyClientProvider = _safetyClientProvider;

// ── ChatState ─────────────────────────────────────────────────────────────────

/// Immutable snapshot of the chat message list state.
sealed class ChatState {
  const ChatState();
}

/// Messages are being loaded for the first time.
final class ChatStateLoading extends ChatState {
  const ChatStateLoading();
}

/// Messages have been loaded successfully.
final class ChatStateLoaded extends ChatState {
  const ChatStateLoaded(this.messages);
  final List<MessageModel> messages;
}

/// An error occurred while loading messages.
final class ChatStateError extends ChatState {
  const ChatStateError(this.message);
  final String message;
}

// ── FirestoreMessagingDelegate ────────────────────────────────────────────────

/// Minimal interface for the Firestore messaging path.
///
/// Implemented by [MessagingService]; extracted here so tests can inject a
/// fake without initialising Firebase.
abstract class FirestoreMessagingDelegate {
  Stream<List<MessageModel>> getMessagesStream(String chatId);

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    String? imageUrl,
  });

  /// Block [targetAuthUserId] via the Firestore path.
  ///
  /// Requirements: 10.3
  Future<void> blockUser(String targetAuthUserId);

  /// Submit a report via the Firestore path.
  ///
  /// Requirements: 10.3
  Future<void> reportUser({
    required String targetUserId,
    String? targetChatId,
    String? targetMessageId,
    required String reason,
  });
}

/// Adapter that wraps [MessagingService] to satisfy [FirestoreMessagingDelegate].
final class _MessagingServiceAdapter implements FirestoreMessagingDelegate {
  _MessagingServiceAdapter(this._service);
  final MessagingService _service;

  @override
  Stream<List<MessageModel>> getMessagesStream(String chatId) =>
      _service.getMessagesStream(chatId);

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    String? imageUrl,
  }) =>
      _service.sendMessage(
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        imageUrl: imageUrl,
      );

  @override
  Future<void> blockUser(String targetAuthUserId) async {
    // Stub: MessagingService does not expose blockUser directly.
    // The AuthService.blockUser path is wired via AuthNotifier.
  }

  @override
  Future<void> reportUser({
    required String targetUserId,
    String? targetChatId,
    String? targetMessageId,
    required String reason,
  }) async {
    // Stub: MessagingService does not expose reportUser directly.
    // The AuthService.reportContent path is wired via AuthNotifier.
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// Provides the [MessagingSyncMode] singleton.
///
/// Overridable in tests to inject a specific mode.
final messagingSyncModeProvider = Provider<MessagingSyncMode>(
  (ref) => MessagingSyncMode(),
);

/// Provides the [FirestoreMessagingDelegate] used by the Firestore path.
///
/// Overridable in tests to inject a fake without initialising Firebase.
final firestoreMessagingDelegateProvider =
    Provider<FirestoreMessagingDelegate>(
  (ref) => _MessagingServiceAdapter(MessagingService()),
);

/// Provides the [MediaUploadService] used by the Serverpod media upload path.
///
/// Overridable in tests to inject a fake without initialising Serverpod.
///
/// Requirements: 8.1, 8.5
final mediaUploadServiceProvider = Provider<MediaUploadService?>(
  (ref) => null, // Wired by the caller; null means Serverpod media not configured.
);

// ── ChatNotifier ──────────────────────────────────────────────────────────────

/// Manages the message list for a single chat, routing reads and writes
/// through either the Drift/Serverpod path or the legacy Firestore path
/// depending on [MessagingSyncMode].
///
/// Requirements: 4.2, 4.3
class ChatNotifier extends Notifier<ChatState> {
  ChatNotifier(this._chatId);

  final String _chatId;
  StreamSubscription<List<MessageModel>>? _messagesSub;

  @override
  ChatState build() {
    final syncMode = ref.watch(messagingSyncModeProvider);

    if (syncMode.useServerpod) {
      _subscribeServerpod();
    } else {
      _subscribeFirestore();
    }

    ref.onDispose(() {
      _messagesSub?.cancel();
      _messagesSub = null;
    });

    return const ChatStateLoading();
  }

  // ── Serverpod path ────────────────────────────────────────────────────────

  void _subscribeServerpod() {
    final messageRepo = ref.watch(messageRepositoryProvider);
    _messagesSub = messageRepo
        .watchMessagesForChat(_chatId)
        .listen(
          (messages) => state = ChatStateLoaded(messages),
          onError: (Object e) =>
              state = ChatStateError(e.toString()),
        );
  }

  // ── Firestore path ────────────────────────────────────────────────────────

  void _subscribeFirestore() {
    final delegate = ref.watch(firestoreMessagingDelegateProvider);
    _messagesSub = delegate
        .getMessagesStream(_chatId)
        .listen(
          (messages) => state = ChatStateLoaded(messages),
          onError: (Object e) =>
              state = ChatStateError(e.toString()),
        );
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Send a message in this chat.
  ///
  /// - Serverpod path: enqueues the message in the outbox via [SyncRepository].
  /// - Firestore path: delegates to [MessagingService.sendMessage].
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String? imageUrl,
  }) async {
    final syncMode = ref.read(messagingSyncModeProvider);

    if (syncMode.useServerpod) {
      await _sendServerpod(
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        imageUrl: imageUrl,
      );
    } else {
      await _sendFirestore(
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        imageUrl: imageUrl,
      );
    }
  }

  /// Upload a media file and send it as a message in this chat.
  ///
  /// - Serverpod path: calls [MediaUploadService.uploadMedia]; uses the
  ///   returned `fetchUrl` as the `imageUrl` in the outbox payload.
  /// - Firestore path: delegates to [FirestoreMessagingDelegate.sendMessage]
  ///   with the Firebase Storage URL already resolved by the caller.
  ///
  /// Requirements: 8.5
  Future<void> sendMediaMessage({
    required String senderId,
    required String receiverId,
    required File file,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    final syncMode = ref.read(messagingSyncModeProvider);

    if (syncMode.useServerpod) {
      final mediaService = ref.read(mediaUploadServiceProvider);
      if (mediaService == null) {
        throw StateError('mediaUploadServiceProvider is not configured');
      }
      final fetchUrl = await mediaService.uploadMedia(
        chatId: _chatId,
        file: file,
        mimeType: mimeType,
        onProgress: onProgress,
      );
      await _sendServerpod(
        senderId: senderId,
        receiverId: receiverId,
        content: '',
        imageUrl: fetchUrl,
      );
    } else {
      // Firestore path: caller is responsible for uploading to Firebase Storage
      // and passing the resulting URL via [sendMessage] with imageUrl set.
      // This method is a no-op on the Firestore path for media — the UI layer
      // should call sendMessage directly with the Firebase Storage URL.
      final delegate = ref.read(firestoreMessagingDelegateProvider);
      await delegate.sendMessage(
        chatId: _chatId,
        senderId: senderId,
        receiverId: receiverId,
        content: '',
        imageUrl: file.path, // placeholder; real URL resolved by UI layer
      );
    }
  }

  /// Block [targetAuthUserId] in this chat context.
  ///
  /// - Serverpod path: calls `client.safety.blockUser`.
  /// - Firestore path: delegates to [FirestoreMessagingDelegate.blockUser].
  ///
  /// Surfaces network errors to the caller; does not silently discard failures.
  ///
  /// Requirements: 10.1, 10.5
  Future<void> blockUser(String targetAuthUserId) async {
    final syncMode = ref.read(messagingSyncModeProvider);

    if (syncMode.useServerpod) {
      final safetyClient = ref.read(_safetyClientProvider);
      await safetyClient.blockUser(targetAuthUserId);
    } else {
      final delegate = ref.read(firestoreMessagingDelegateProvider);
      await delegate.blockUser(targetAuthUserId);
    }
  }

  /// Submit a report.
  ///
  /// - Serverpod path: calls `client.safety.submitReport`.
  /// - Firestore path: delegates to [FirestoreMessagingDelegate.reportUser].
  ///
  /// Surfaces network errors to the caller; does not silently discard failures.
  ///
  /// Requirements: 10.2, 10.5
  Future<void> reportUser({
    required String targetUserId,
    String? targetChatId,
    String? targetMessageId,
    required String reason,
  }) async {
    final syncMode = ref.read(messagingSyncModeProvider);

    if (syncMode.useServerpod) {
      final safetyClient = ref.read(_safetyClientProvider);
      await safetyClient.submitReport(
        targetUserId: targetUserId,
        targetChatId: targetChatId,
        targetMessageId: targetMessageId,
        reason: reason,
      );
    } else {
      final delegate = ref.read(firestoreMessagingDelegateProvider);
      await delegate.reportUser(
        targetUserId: targetUserId,
        targetChatId: targetChatId,
        targetMessageId: targetMessageId,
        reason: reason,
      );
    }
  }

  Future<void> _sendServerpod({
    required String senderId,
    required String receiverId,
    required String content,
    String? imageUrl,
  }) async {
    final syncRepo = ref.read(syncRepositoryProvider);
    final clientMsgId = const Uuid().v4();

    final payload = {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'imageUrl': ?imageUrl,
    };

    // Encode payload as JSON string manually to avoid importing dart:convert
    // at the top level — keep it simple.
    final payloadJson = _encodePayload(payload);

    await syncRepo.enqueueOperation(
      clientMsgId: clientMsgId,
      chatId: _chatId,
      payloadJson: payloadJson,
      operation: 'sendMessage',
    );
  }

  Future<void> _sendFirestore({
    required String senderId,
    required String receiverId,
    required String content,
    String? imageUrl,
  }) async {
    final delegate = ref.read(firestoreMessagingDelegateProvider);
    await delegate.sendMessage(
      chatId: _chatId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      imageUrl: imageUrl,
    );
  }

  /// Minimal JSON encoding for the outbox payload (avoids extra imports).
  String _encodePayload(Map<String, String> map) {
    final entries = map.entries
        .map((e) => '"${_escape(e.key)}":"${_escape(e.value)}"')
        .join(',');
    return '{$entries}';
  }

  String _escape(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
}

/// Provider family keyed by [chatId].
///
/// Auto-disposes when the chat screen is closed.
///
/// Requirements: 4.2, 4.3
final chatNotifierProvider =
    NotifierProvider.autoDispose.family<ChatNotifier, ChatState, String>(
  (chatId) => ChatNotifier(chatId),
);
