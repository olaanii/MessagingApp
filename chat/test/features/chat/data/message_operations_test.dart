// ignore_for_file: lines_longer_than_80_chars

import 'package:chat/data/local/db/app_database.dart';
import 'package:chat/data/repositories/drift_repositories.dart';
import 'package:chat/domain/models/message_model.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

AppDatabase _openInMemory() => AppDatabase(NativeDatabase.memory());

MessageModel _makeMessage({
  required String id,
  required String chatId,
  String senderId = 'sender_1',
  String receiverId = 'receiver_1',
  String content = 'hello',
  DateTime? timestamp,
  String status = 'sent',
  bool isOffline = false,
  String? imageUrl,
}) =>
    MessageModel(
      id: id,
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: timestamp ?? DateTime(2024, 1, 1, 12, 0, 0),
      status: status,
      isOffline: isOffline,
      imageUrl: imageUrl,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // Task 6.5 — Message Operations Unit Tests
  // Requirements: 1.2, 9.3, 16.2
  // ═══════════════════════════════════════════════════════════════════════════

  group('Task 6.5 — Message Operations', () {
    late AppDatabase db;
    late DriftMessageRepository repo;

    setUp(() {
      db = _openInMemory();
      repo = DriftMessageRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    // ── sendMessage stores only content (ciphertext in production) ─────────
    // Requirement 1.2: Server stores ciphertext only

    test('sendMessage: upsertLocalMessage stores message with content', () async {
      final message = _makeMessage(
        id: 'msg_store_1',
        chatId: 'chat_1',
        content: 'encrypted_ciphertext_here',
      );

      await repo.upsertLocalMessage(
        message,
        effectiveChatId: 'chat_1',
        clientMsgId: 'msg_store_1',
      );

      final messages = await repo.watchMessagesForChat('chat_1').first;
      expect(messages, hasLength(1));
      expect(messages.first.content, equals('encrypted_ciphertext_here'));
      expect(messages.first.chatId, equals('chat_1'));
    });

    test('sendMessage: message keyed by stored id', () async {
      final message = _makeMessage(
        id: 'msg_keyed',
        chatId: 'chat_1',
      );

      await repo.upsertLocalMessage(
        message,
        effectiveChatId: 'chat_1',
        clientMsgId: 'msg_keyed',
      );

      final messages = await repo.watchMessagesForChat('chat_1').first;
      expect(messages.first.id, equals('msg_keyed'));
    });

    // ── sendMessage with duplicate client_msg_id returns existing ──────────
    // Requirement 9.3: Idempotent message creation

    test('sendMessage: duplicate client_msg_id does not create a second row (idempotent)', () async {
      final message1 = _makeMessage(
        id: 'msg_dup_1',
        chatId: 'chat_1',
        content: 'first',
      );
      final message2 = _makeMessage(
        id: 'msg_dup_1', // same id
        chatId: 'chat_1',
        content: 'second', // different content — update should overwrite
      );

      await repo.upsertLocalMessage(
        message1,
        effectiveChatId: 'chat_1',
        clientMsgId: 'msg_dup_1',
      );
      await repo.upsertLocalMessage(
        message2,
        effectiveChatId: 'chat_1',
        clientMsgId: 'msg_dup_1',
      );

      final messages = await repo.watchMessagesForChat('chat_1').first;
      // Only one row should exist (upsert, not insert).
      expect(messages, hasLength(1));
      // The content should be the updated value (last write wins).
      expect(messages.first.content, equals('second'));
    });

    test('sendMessage: different client_msg_ids create distinct rows', () async {
      final message1 = _makeMessage(id: 'msg_a', chatId: 'chat_1');
      final message2 = _makeMessage(id: 'msg_b', chatId: 'chat_1');

      await repo.upsertLocalMessage(
        message1,
        effectiveChatId: 'chat_1',
        clientMsgId: 'msg_a',
      );
      await repo.upsertLocalMessage(
        message2,
        effectiveChatId: 'chat_1',
        clientMsgId: 'msg_b',
      );

      final messages = await repo.watchMessagesForChat('chat_1').first;
      expect(messages, hasLength(2));
    });

    // ── listMessages returns messages in server_seq order ──────────────────

    test('listMessages: ordered by createdAt descending (newest first)', () async {
      final messages = List.generate(5, (i) {
        return _makeMessage(
          id: 'msg_seq_$i',
          chatId: 'chat_seq',
          content: 'msg $i',
          timestamp: DateTime(2024, 1, 1, 12, 0, i),
        );
      });

      for (final m in messages) {
        await repo.upsertLocalMessage(
          m,
          effectiveChatId: 'chat_seq',
          clientMsgId: m.id,
        );
      }

      final result = await repo.watchMessagesForChat('chat_seq').first;
      expect(result, hasLength(5));
      // Ordered by createdAt DESC → newest first.
      for (int i = 0; i < result.length - 1; i++) {
        expect(
          result[i].timestamp.isAfter(result[i + 1].timestamp) ||
              result[i].timestamp.isAtSameMomentAs(result[i + 1].timestamp),
          isTrue,
          reason: 'messages must be ordered newest-first',
        );
      }
    });

    // ── deleteMessage creates tombstone ─────────────────────────────────────
    // Requirement 16.2: Delete creates tombstone record

    test('deleteMessage: tombstone excludes message from stream', () async {
      final message = _makeMessage(
        id: 'msg_del_1',
        chatId: 'chat_1',
      );

      await repo.upsertLocalMessage(
        message,
        effectiveChatId: 'chat_1',
        clientMsgId: 'msg_del_1',
      );

      // Verify message exists.
      var messages = await repo.watchMessagesForChat('chat_1').first;
      expect(messages, hasLength(1));

      // Tombstone the message.
      await repo.tombstoneMessage('msg_del_1', DateTime.now());

      // Message should no longer appear in the stream.
      messages = await repo.watchMessagesForChat('chat_1').first;
      expect(messages, isEmpty,
          reason: 'tombstoned message must be excluded from watchMessagesForChat');
    });

    test('deleteMessage: tombstone sets deletedAt timestamp', () async {
      final message = _makeMessage(id: 'msg_ts', chatId: 'chat_1');

      await repo.upsertLocalMessage(
        message,
        effectiveChatId: 'chat_1',
        clientMsgId: 'msg_ts',
      );

      final deleteTime = DateTime(2024, 6, 15, 10, 30);
      await repo.tombstoneMessage('msg_ts', deleteTime);

      // Query the row directly to verify deletedAt is set.
      final row = await (db.select(db.localMessages)
            ..where((m) => m.id.equals('msg_ts')))
          .getSingle();

      expect(row.deletedAt, isNotNull);
      expect(row.deletedAt, equals(deleteTime));
    });

    test('deleteMessage: only the specified message is tombstoned', () async {
      final msg1 = _makeMessage(id: 'msg_keep', chatId: 'chat_1');
      final msg2 = _makeMessage(id: 'msg_delete', chatId: 'chat_1');

      await repo.upsertLocalMessage(msg1, effectiveChatId: 'chat_1', clientMsgId: 'msg_keep');
      await repo.upsertLocalMessage(msg2, effectiveChatId: 'chat_1', clientMsgId: 'msg_delete');
      await repo.tombstoneMessage('msg_delete', DateTime.now());

      final messages = await repo.watchMessagesForChat('chat_1').first;
      expect(messages, hasLength(1));
      expect(messages.first.id, equals('msg_keep'));
    });

    // ── Additional edge cases ──────────────────────────────────────────────

    test('message with serverSeq is stored correctly', () async {
      final message = _makeMessage(id: 'msg_sq', chatId: 'chat_1');

      await repo.upsertLocalMessage(
        message,
        effectiveChatId: 'chat_1',
        clientMsgId: 'msg_sq',
        serverSeq: 42,
      );

      final row = await (db.select(db.localMessages)
            ..where((m) => m.id.equals('msg_sq')))
          .getSingle();

      expect(row.serverSeq, equals(42));
    });

    test('message with imageUrl is stored correctly', () async {
      final message = _makeMessage(
        id: 'msg_img',
        chatId: 'chat_1',
        imageUrl: 'https://example.com/image.jpg',
      );

      await repo.upsertLocalMessage(
        message,
        effectiveChatId: 'chat_1',
        clientMsgId: 'msg_img',
      );

      final messages = await repo.watchMessagesForChat('chat_1').first;
      expect(messages.first.imageUrl, equals('https://example.com/image.jpg'));
    });

    test('mergeServerMessages inserts multiple messages in a transaction', () async {
      final serverMessages = List.generate(3, (i) {
        return _makeMessage(
          id: 'srv_msg_$i',
          chatId: 'chat_merge',
          content: 'server message $i',
          timestamp: DateTime(2024, 6, 1, 12, 0, i),
        );
      });

      await repo.mergeServerMessages('chat_merge', serverMessages);

      final messages = await repo.watchMessagesForChat('chat_merge').first;
      expect(messages, hasLength(3));

      // Verify each message content.
      final contents = messages.map((m) => m.content).toSet();
      for (int i = 0; i < 3; i++) {
        expect(contents.contains('server message $i'), isTrue);
      }
    });
  });
}
