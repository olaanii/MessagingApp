// ignore_for_file: lines_longer_than_80_chars

import 'package:chat/data/local/db/app_database.dart';
import 'package:chat/data/repositories/drift_repositories.dart';
import 'package:chat/domain/models/message_model.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Property 16: Drift Reactive Stream Emits on Change**
///
/// [DriftMessageRepository.upsertLocalMessage] causes
/// [DriftMessageRepository.watchMessagesForChat] to emit an updated list
/// containing the upserted message.
///
/// **Validates: Requirements 4.4**

AppDatabase _openInMemory() =>
    AppDatabase(NativeDatabase.memory());

MessageModel _makeMessage({
  required String id,
  required String chatId,
  String senderId = 'sender_1',
  String content = 'hello',
  DateTime? timestamp,
}) =>
    MessageModel(
      id: id,
      chatId: chatId,
      senderId: senderId,
      receiverId: '',
      content: content,
      timestamp: timestamp ?? DateTime(2024, 1, 1, 12, 0, 0),
    );

void main() {
  group('Property 16: Drift Reactive Stream Emits on Change', () {
    late AppDatabase db;
    late DriftMessageRepository repo;

    setUp(() {
      db = _openInMemory();
      repo = DriftMessageRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    // ── Core property: upsert causes stream to emit the new message ──────────

    test('stream emits list containing message after upsertLocalMessage', () async {
      const chatId = 'chat_abc';
      final message = _makeMessage(id: 'msg_1', chatId: chatId);

      final stream = repo.watchMessagesForChat(chatId);

      // Collect the first two emissions: initial empty list, then updated list.
      final emissions = <List<MessageModel>>[];
      final subscription = stream.listen(emissions.add);

      // Allow the initial empty emission to arrive.
      await Future<void>.delayed(Duration.zero);

      await repo.upsertLocalMessage(
        message,
        effectiveChatId: chatId,
        clientMsgId: message.id,
      );

      // Allow the reactive emission to propagate.
      await Future<void>.delayed(Duration.zero);

      await subscription.cancel();

      expect(
        emissions.length,
        greaterThanOrEqualTo(2),
        reason: 'stream must emit at least once before and once after upsert',
      );

      final lastEmission = emissions.last;
      expect(
        lastEmission.any((m) => m.id == message.id),
        isTrue,
        reason: 'last emission must contain the upserted message',
      );
    });

    // ── Multiple messages: all appear in stream ──────────────────────────────

    test('stream emits all upserted messages for the same chatId', () async {
      const chatId = 'chat_multi';
      final messages = List.generate(
        5,
        (i) => _makeMessage(
          id: 'msg_$i',
          chatId: chatId,
          content: 'message $i',
          timestamp: DateTime(2024, 1, 1, 12, 0, i),
        ),
      );

      for (final m in messages) {
        await repo.upsertLocalMessage(
          m,
          effectiveChatId: chatId,
          clientMsgId: m.id,
        );
      }

      final result = await repo.watchMessagesForChat(chatId).first;

      expect(result.length, equals(messages.length));
      for (final m in messages) {
        expect(result.any((r) => r.id == m.id), isTrue,
            reason: 'message ${m.id} must appear in stream');
      }
    });

    // ── Cross-chat isolation: stream only emits messages for its chatId ──────

    test('stream for chatId A does not include messages from chatId B', () async {
      const chatA = 'chat_a';
      const chatB = 'chat_b';

      final msgA = _makeMessage(id: 'msg_a', chatId: chatA, content: 'for A');
      final msgB = _makeMessage(id: 'msg_b', chatId: chatB, content: 'for B');

      await repo.upsertLocalMessage(msgA, effectiveChatId: chatA, clientMsgId: msgA.id);
      await repo.upsertLocalMessage(msgB, effectiveChatId: chatB, clientMsgId: msgB.id);

      final resultA = await repo.watchMessagesForChat(chatA).first;
      final resultB = await repo.watchMessagesForChat(chatB).first;

      expect(resultA.every((m) => m.chatId == chatA), isTrue,
          reason: 'stream for chatA must only contain chatA messages');
      expect(resultB.every((m) => m.chatId == chatB), isTrue,
          reason: 'stream for chatB must only contain chatB messages');
    });

    // ── Upsert semantics: updating an existing message emits updated content ─

    test('upserting an existing message id emits updated content', () async {
      const chatId = 'chat_upsert';
      final original = _makeMessage(id: 'msg_upd', chatId: chatId, content: 'original');
      final updated = _makeMessage(id: 'msg_upd', chatId: chatId, content: 'updated');

      await repo.upsertLocalMessage(original, effectiveChatId: chatId, clientMsgId: original.id);
      await repo.upsertLocalMessage(updated, effectiveChatId: chatId, clientMsgId: updated.id);

      final result = await repo.watchMessagesForChat(chatId).first;

      expect(result.length, equals(1), reason: 'upsert must not duplicate the row');
      expect(result.first.content, equals('updated'),
          reason: 'stream must reflect the updated content');
    });

    // ── Empty stream before any upsert ───────────────────────────────────────

    test('stream emits empty list when no messages exist for chatId', () async {
      final result = await repo.watchMessagesForChat('empty_chat').first;
      expect(result, isEmpty);
    });

    // ── Tombstoned messages are excluded from stream ─────────────────────────

    test('tombstoned message is excluded from stream', () async {
      const chatId = 'chat_tomb';
      final message = _makeMessage(id: 'msg_tomb', chatId: chatId);

      await repo.upsertLocalMessage(message, effectiveChatId: chatId, clientMsgId: message.id);
      await repo.tombstoneMessage(message.id, DateTime.now());

      final result = await repo.watchMessagesForChat(chatId).first;

      expect(result.any((m) => m.id == message.id), isFalse,
          reason: 'tombstoned message must not appear in stream');
    });
  });
}
