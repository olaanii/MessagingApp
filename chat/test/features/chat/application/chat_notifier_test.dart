// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:chat/core/sync/messaging_backend.dart';
import 'package:chat/data/providers/repository_providers.dart';
import 'package:chat/data/repositories/message_repository.dart';
import 'package:chat/data/repositories/sync_repository.dart';
import 'package:chat/domain/models/message_model.dart';
import 'package:chat/features/chat/application/chat_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

/// Fake [MessageRepository] that tracks calls to [watchMessagesForChat].
final class _FakeMessageRepository implements MessageRepository {
  int watchCallCount = 0;
  final _controller = StreamController<List<MessageModel>>.broadcast();

  void emitMessages(List<MessageModel> messages) {
    _controller.add(messages);
  }

  @override
  Stream<List<MessageModel>> watchMessagesForChat(
    String chatId, {
    int limit = 200,
  }) {
    watchCallCount++;
    return _controller.stream;
  }

  @override
  Future<void> upsertLocalMessage(
    MessageModel message, {
    required String effectiveChatId,
    String? clientMsgId,
    int? serverSeq,
  }) async {}

  @override
  Future<void> tombstoneMessage(String messageId, DateTime deletedAt) async {}

  @override
  Future<void> mergeServerMessages(
    String chatId,
    List<MessageModel> messages,
  ) async {}
}

/// Fake [SyncRepository] that tracks calls to [enqueueOperation].
final class _FakeSyncRepository implements SyncRepository {
  int enqueueCallCount = 0;

  @override
  Future<void> enqueueOperation({
    required String clientMsgId,
    required String chatId,
    required String payloadJson,
    String operation = 'sendMessage',
  }) async {
    enqueueCallCount++;
  }

  @override
  Stream<List<OutboxItem>> watchOutbox({Iterable<String>? states}) =>
      const Stream.empty();

  @override
  Future<void> updateOutboxEntry({
    required String clientMsgId,
    required String state,
    int? attemptCount,
    DateTime? nextRetryAt,
  }) async {}

  @override
  Future<String?> getCursor(String scopeKey) async => null;

  @override
  Future<void> setCursor(
    String scopeKey,
    String? cursor, {
    DateTime? at,
  }) async {}
}

/// Fake [FirestoreMessagingDelegate] that tracks calls without using Firebase.
final class _FakeFirestoreDelegate implements FirestoreMessagingDelegate {
  int getMessagesStreamCallCount = 0;
  int sendMessageCallCount = 0;
  final _controller = StreamController<List<MessageModel>>.broadcast();

  @override
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    getMessagesStreamCallCount++;
    return _controller.stream;
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    String? imageUrl,
  }) async {
    sendMessageCallCount++;
  }

  @override
  Future<void> blockUser(String targetAuthUserId) async {}

  @override
  Future<void> reportUser({
    required String targetUserId,
    String? targetChatId,
    String? targetMessageId,
    required String reason,
  }) async {}
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Build a [ProviderContainer] with the given [syncMode] and injected fakes.
({
  ProviderContainer container,
  _FakeMessageRepository messageRepo,
  _FakeSyncRepository syncRepo,
  _FakeFirestoreDelegate firestoreDelegate,
}) _buildContainer(MessagingSyncMode syncMode) {
  final messageRepo = _FakeMessageRepository();
  final syncRepo = _FakeSyncRepository();
  final firestoreDelegate = _FakeFirestoreDelegate();

  final container = ProviderContainer(
    overrides: [
      messagingSyncModeProvider.overrideWithValue(syncMode),
      messageRepositoryProvider.overrideWithValue(messageRepo),
      syncRepositoryProvider.overrideWithValue(syncRepo),
      firestoreMessagingDelegateProvider.overrideWithValue(firestoreDelegate),
    ],
  );

  return (
    container: container,
    messageRepo: messageRepo,
    syncRepo: syncRepo,
    firestoreDelegate: firestoreDelegate,
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── Property 13: Dual-Mode Isolation ────────────────────────────────────────
  //
  // When useFirestore is active, no Serverpod (Drift) calls are made.
  // When useServerpod is active, no Firestore (MessagingService) read calls
  // are made — verified by confirming the Drift repo IS called instead.
  //
  // **Validates: Requirements 3.7, 4.2, 4.3, 8.5, 10.3, 11.1, 11.2**

  group('Property 13: Dual-Mode Isolation', () {
    // We test across multiple chatId values to verify the property holds
    // for arbitrary inputs (property-based style).
    const chatIds = [
      'chat_abc',
      'chat_xyz',
      'user1_user2',
      'group_123',
      'a',
    ];

    test(
      'useFirestore mode: watchMessagesForChat on Drift repo is NEVER called',
      () {
        for (final chatId in chatIds) {
          final (:container, :messageRepo, syncRepo: _, firestoreDelegate: _) =
              _buildContainer(
            MessagingSyncMode(backend: MessagingBackend.firestore),
          );

          addTearDown(container.dispose);

          // Reading the notifier triggers build(), which subscribes to the
          // appropriate stream based on the sync mode.
          container.read(chatNotifierProvider(chatId));

          // In Firestore mode the Drift MessageRepository must NOT be called.
          expect(
            messageRepo.watchCallCount,
            0,
            reason:
                'chatId=$chatId: Drift watchMessagesForChat must not be called '
                'when useFirestore is active',
          );
        }
      },
    );

    test(
      'useFirestore mode: getMessagesStream on Firestore delegate IS called',
      () {
        for (final chatId in chatIds) {
          final (
            :container,
            messageRepo: _,
            syncRepo: _,
            :firestoreDelegate,
          ) = _buildContainer(
            MessagingSyncMode(backend: MessagingBackend.firestore),
          );

          addTearDown(container.dispose);

          container.read(chatNotifierProvider(chatId));

          // In Firestore mode the Firestore delegate MUST be called.
          expect(
            firestoreDelegate.getMessagesStreamCallCount,
            1,
            reason:
                'chatId=$chatId: Firestore getMessagesStream must be called '
                'exactly once when useFirestore is active',
          );
        }
      },
    );

    test(
      'useServerpod mode: watchMessagesForChat on Drift repo IS called (not Firestore)',
      () {
        for (final chatId in chatIds) {
          final (
            :container,
            :messageRepo,
            syncRepo: _,
            :firestoreDelegate,
          ) = _buildContainer(
            MessagingSyncMode(backend: MessagingBackend.serverpod),
          );

          addTearDown(container.dispose);

          container.read(chatNotifierProvider(chatId));

          // In Serverpod mode the Drift MessageRepository MUST be called.
          expect(
            messageRepo.watchCallCount,
            1,
            reason:
                'chatId=$chatId: Drift watchMessagesForChat must be called '
                'exactly once when useServerpod is active',
          );

          // And the Firestore delegate must NOT be called.
          expect(
            firestoreDelegate.getMessagesStreamCallCount,
            0,
            reason:
                'chatId=$chatId: Firestore getMessagesStream must NOT be called '
                'when useServerpod is active',
          );
        }
      },
    );

    test(
      'useServerpod mode: sendMessage enqueues to outbox (not Firestore)',
      () async {
        for (final chatId in chatIds) {
          final (
            :container,
            messageRepo: _,
            :syncRepo,
            :firestoreDelegate,
          ) = _buildContainer(
            MessagingSyncMode(backend: MessagingBackend.serverpod),
          );

          addTearDown(container.dispose);

          final notifier =
              container.read(chatNotifierProvider(chatId).notifier);

          await notifier.sendMessage(
            senderId: 'sender1',
            receiverId: 'receiver1',
            content: 'hello',
          );

          // In Serverpod mode, send must go through the outbox.
          expect(
            syncRepo.enqueueCallCount,
            1,
            reason:
                'chatId=$chatId: enqueueOperation must be called once when '
                'useServerpod is active',
          );

          // And the Firestore delegate must NOT be called for sends.
          expect(
            firestoreDelegate.sendMessageCallCount,
            0,
            reason:
                'chatId=$chatId: Firestore sendMessage must NOT be called '
                'when useServerpod is active',
          );
        }
      },
    );

    test(
      'useFirestore mode: sendMessage delegates to Firestore (not outbox)',
      () async {
        for (final chatId in chatIds) {
          final (
            :container,
            messageRepo: _,
            :syncRepo,
            :firestoreDelegate,
          ) = _buildContainer(
            MessagingSyncMode(backend: MessagingBackend.firestore),
          );

          addTearDown(container.dispose);

          final notifier =
              container.read(chatNotifierProvider(chatId).notifier);

          await notifier.sendMessage(
            senderId: 'sender1',
            receiverId: 'receiver1',
            content: 'hello',
          );

          // In Firestore mode, the outbox must NOT be used.
          expect(
            syncRepo.enqueueCallCount,
            0,
            reason:
                'chatId=$chatId: enqueueOperation must NOT be called when '
                'useFirestore is active',
          );

          // And the Firestore delegate MUST be called.
          expect(
            firestoreDelegate.sendMessageCallCount,
            1,
            reason:
                'chatId=$chatId: Firestore sendMessage must be called once '
                'when useFirestore is active',
          );
        }
      },
    );

    test(
      'initial state is ChatStateLoading for both modes',
      () {
        for (final backend in MessagingBackend.values) {
          for (final chatId in chatIds) {
            final (:container, messageRepo: _, syncRepo: _, firestoreDelegate: _) =
                _buildContainer(MessagingSyncMode(backend: backend));

            addTearDown(container.dispose);

            final state = container.read(chatNotifierProvider(chatId));

            expect(
              state,
              isA<ChatStateLoading>(),
              reason:
                  'backend=$backend chatId=$chatId: initial state must be '
                  'ChatStateLoading',
            );
          }
        }
      },
    );

    test(
      'useServerpod mode: emitting messages from Drift repo transitions state to ChatStateLoaded',
      () async {
        const chatId = 'chat_abc';
        final (:container, :messageRepo, syncRepo: _, firestoreDelegate: _) =
            _buildContainer(
          MessagingSyncMode(backend: MessagingBackend.serverpod),
        );

        addTearDown(container.dispose);

        // Collect state changes via a listener.
        final states = <ChatState>[];
        container.listen(
          chatNotifierProvider(chatId),
          (_, next) => states.add(next),
          fireImmediately: true,
        );

        final testMessage = MessageModel(
          id: 'msg1',
          senderId: 'alice',
          receiverId: 'bob',
          content: 'hello',
          timestamp: DateTime(2024),
        );

        messageRepo.emitMessages([testMessage]);

        // Allow the stream listener to fire.
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states, isNotEmpty);
        final loaded = states.whereType<ChatStateLoaded>().lastOrNull;
        expect(loaded, isNotNull, reason: 'Expected a ChatStateLoaded state');
        expect(loaded!.messages, hasLength(1));
        expect(loaded.messages.first.id, 'msg1');
      },
    );

    test(
      'useFirestore mode: emitting messages from Firestore delegate transitions state to ChatStateLoaded',
      () async {
        const chatId = 'chat_abc';
        final (
          :container,
          messageRepo: _,
          syncRepo: _,
          :firestoreDelegate,
        ) = _buildContainer(
          MessagingSyncMode(backend: MessagingBackend.firestore),
        );

        addTearDown(container.dispose);

        final states = <ChatState>[];
        container.listen(
          chatNotifierProvider(chatId),
          (_, next) => states.add(next),
          fireImmediately: true,
        );

        final testMessage = MessageModel(
          id: 'msg2',
          senderId: 'alice',
          receiverId: 'bob',
          content: 'world',
          timestamp: DateTime(2024),
        );

        firestoreDelegate._controller.add([testMessage]);

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states, isNotEmpty);
        final loaded = states.whereType<ChatStateLoaded>().lastOrNull;
        expect(loaded, isNotNull, reason: 'Expected a ChatStateLoaded state');
        expect(loaded!.messages.first.id, 'msg2');
      },
    );
  });
}
