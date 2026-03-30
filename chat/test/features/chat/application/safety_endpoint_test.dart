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

/// Fake [SafetyClient] that records calls to [blockUser] and [submitReport].
final class _FakeSafetyClient implements SafetyClient {
  final List<String> blockUserCalls = [];
  final List<Map<String, dynamic>> submitReportCalls = [];

  @override
  Future<void> blockUser(String blockedAuthUserId) async {
    blockUserCalls.add(blockedAuthUserId);
  }

  @override
  Future<void> submitReport({
    String? targetUserId,
    String? targetChatId,
    String? targetMessageId,
    required String reason,
  }) async {
    submitReportCalls.add({
      'targetUserId': targetUserId,
      'targetChatId': targetChatId,
      'targetMessageId': targetMessageId,
      'reason': reason,
    });
  }
}

/// Fake [FirestoreMessagingDelegate] that records safety calls.
final class _FakeFirestoreDelegate implements FirestoreMessagingDelegate {
  final List<String> blockUserCalls = [];
  final List<Map<String, dynamic>> reportUserCalls = [];
  final _controller = StreamController<List<MessageModel>>.broadcast();

  @override
  Stream<List<MessageModel>> getMessagesStream(String chatId) =>
      _controller.stream;

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    String? imageUrl,
  }) async {}

  @override
  Future<void> blockUser(String targetAuthUserId) async {
    blockUserCalls.add(targetAuthUserId);
  }

  @override
  Future<void> reportUser({
    required String targetUserId,
    String? targetChatId,
    String? targetMessageId,
    required String reason,
  }) async {
    reportUserCalls.add({
      'targetUserId': targetUserId,
      'targetChatId': targetChatId,
      'targetMessageId': targetMessageId,
      'reason': reason,
    });
  }
}

/// Minimal fake [MessageRepository].
final class _FakeMessageRepository implements MessageRepository {
  @override
  Stream<List<MessageModel>> watchMessagesForChat(
    String chatId, {
    int limit = 200,
  }) =>
      const Stream.empty();

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

/// Minimal fake [SyncRepository].
final class _FakeSyncRepository implements SyncRepository {
  @override
  Future<void> enqueueOperation({
    required String clientMsgId,
    required String chatId,
    required String payloadJson,
    String operation = 'sendMessage',
  }) async {}

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

// ── Helpers ───────────────────────────────────────────────────────────────────

({
  ProviderContainer container,
  _FakeSafetyClient safetyClient,
  _FakeFirestoreDelegate firestoreDelegate,
}) _buildContainer(MessagingSyncMode syncMode) {
  final safetyClient = _FakeSafetyClient();
  final firestoreDelegate = _FakeFirestoreDelegate();

  final container = ProviderContainer(
    overrides: [
      messagingSyncModeProvider.overrideWithValue(syncMode),
      safetyClientProvider.overrideWithValue(safetyClient),
      firestoreMessagingDelegateProvider.overrideWithValue(firestoreDelegate),
      messageRepositoryProvider.overrideWithValue(_FakeMessageRepository()),
      syncRepositoryProvider.overrideWithValue(_FakeSyncRepository()),
    ],
  );

  return (
    container: container,
    safetyClient: safetyClient,
    firestoreDelegate: firestoreDelegate,
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── Property 15: Safety Endpoint Requires Authentication ────────────────────
  //
  // When ChatNotifier.blockUser is called in Serverpod mode, it calls the
  // safety client (which requires authentication server-side).
  // When in Firestore mode, it delegates to the Firestore path (not the
  // safety client).
  //
  // **Validates: Requirements 10.4**

  group('Property 15: Safety Endpoint Requires Authentication', () {
    const chatId = 'chat_test';

    // ── Serverpod mode: safety client is called ──────────────────────────────

    test(
      'useServerpod mode: blockUser calls the safety client',
      () async {
        final (:container, :safetyClient, firestoreDelegate: _) =
            _buildContainer(
          MessagingSyncMode(backend: MessagingBackend.serverpod),
        );
        addTearDown(container.dispose);

        final notifier = container.read(chatNotifierProvider(chatId).notifier);
        await notifier.blockUser('user-uuid-123');

        expect(
          safetyClient.blockUserCalls,
          contains('user-uuid-123'),
          reason: 'Serverpod mode must route blockUser to the safety client',
        );
      },
    );

    test(
      'useServerpod mode: reportUser calls the safety client',
      () async {
        final (:container, :safetyClient, firestoreDelegate: _) =
            _buildContainer(
          MessagingSyncMode(backend: MessagingBackend.serverpod),
        );
        addTearDown(container.dispose);

        final notifier = container.read(chatNotifierProvider(chatId).notifier);
        await notifier.reportUser(
          targetUserId: 'user-uuid-456',
          targetChatId: chatId,
          reason: 'spam',
        );

        expect(
          safetyClient.submitReportCalls,
          hasLength(1),
          reason: 'Serverpod mode must route reportUser to the safety client',
        );
        expect(
          safetyClient.submitReportCalls.first['targetUserId'],
          'user-uuid-456',
        );
        expect(safetyClient.submitReportCalls.first['reason'], 'spam');
      },
    );

    // ── Firestore mode: safety client is NOT called ──────────────────────────

    test(
      'useFirestore mode: blockUser does NOT call the safety client',
      () async {
        final (:container, :safetyClient, :firestoreDelegate) =
            _buildContainer(
          MessagingSyncMode(backend: MessagingBackend.firestore),
        );
        addTearDown(container.dispose);

        final notifier = container.read(chatNotifierProvider(chatId).notifier);
        await notifier.blockUser('user-uuid-789');

        expect(
          safetyClient.blockUserCalls,
          isEmpty,
          reason:
              'Firestore mode must NOT call the safety client for blockUser',
        );
        expect(
          firestoreDelegate.blockUserCalls,
          contains('user-uuid-789'),
          reason: 'Firestore mode must delegate blockUser to Firestore path',
        );
      },
    );

    test(
      'useFirestore mode: reportUser does NOT call the safety client',
      () async {
        final (:container, :safetyClient, :firestoreDelegate) =
            _buildContainer(
          MessagingSyncMode(backend: MessagingBackend.firestore),
        );
        addTearDown(container.dispose);

        final notifier = container.read(chatNotifierProvider(chatId).notifier);
        await notifier.reportUser(
          targetUserId: 'user-uuid-abc',
          reason: 'harassment',
        );

        expect(
          safetyClient.submitReportCalls,
          isEmpty,
          reason:
              'Firestore mode must NOT call the safety client for reportUser',
        );
        expect(
          firestoreDelegate.reportUserCalls,
          hasLength(1),
          reason: 'Firestore mode must delegate reportUser to Firestore path',
        );
        expect(
          firestoreDelegate.reportUserCalls.first['targetUserId'],
          'user-uuid-abc',
        );
      },
    );

    // ── Property-style: multiple user IDs ───────────────────────────────────

    test(
      'property: Serverpod mode always routes blockUser to safety client '
      'for arbitrary user IDs',
      () async {
        const userIds = [
          'user-1',
          'user-2',
          'user-uuid-aaaa-bbbb',
          'short',
          'a',
        ];

        for (final userId in userIds) {
          final (:container, :safetyClient, firestoreDelegate: _) =
              _buildContainer(
            MessagingSyncMode(backend: MessagingBackend.serverpod),
          );
          addTearDown(container.dispose);

          final notifier =
              container.read(chatNotifierProvider(chatId).notifier);
          await notifier.blockUser(userId);

          expect(
            safetyClient.blockUserCalls,
            contains(userId),
            reason:
                'userId=$userId: Serverpod mode must call safety.blockUser',
          );
        }
      },
    );

    test(
      'property: Firestore mode never routes blockUser to safety client '
      'for arbitrary user IDs',
      () async {
        const userIds = [
          'user-1',
          'user-2',
          'user-uuid-aaaa-bbbb',
          'short',
          'a',
        ];

        for (final userId in userIds) {
          final (:container, :safetyClient, :firestoreDelegate) =
              _buildContainer(
            MessagingSyncMode(backend: MessagingBackend.firestore),
          );
          addTearDown(container.dispose);

          final notifier =
              container.read(chatNotifierProvider(chatId).notifier);
          await notifier.blockUser(userId);

          expect(
            safetyClient.blockUserCalls,
            isEmpty,
            reason:
                'userId=$userId: Firestore mode must NOT call safety.blockUser',
          );
          expect(
            firestoreDelegate.blockUserCalls,
            contains(userId),
            reason:
                'userId=$userId: Firestore mode must delegate to Firestore path',
          );
        }
      },
    );
  });
}
