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
  String content = 'hello',
  DateTime? timestamp,
}) =>
    MessageModel(
      id: id,
      chatId: chatId,
      senderId: 'sender_1',
      receiverId: 'receiver_1',
      content: content,
      timestamp: timestamp ?? DateTime(2024, 1, 1, 12, 0, 0),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // Task 7.2 / 7.3 — Sync Engine (Drift-based)
  // Requirements: 9.5, 9.6
  // ═══════════════════════════════════════════════════════════════════════════

  group('Task 7.2 / 7.3 — Sync Engine', () {
    late AppDatabase db;
    late DriftSyncRepository syncRepo;
    late DriftMessageRepository messageRepo;

    setUp(() {
      db = _openInMemory();
      syncRepo = DriftSyncRepository(db);
      messageRepo = DriftMessageRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    // ── Cursor storage and retrieval ──────────────────────────────────────

    test('getCursor returns null when no cursor is set', () async {
      final cursor = await syncRepo.getCursor('nonexistent');
      expect(cursor, isNull);
    });

    test('setCursor stores and getCursor retrieves the cursor', () async {
      await syncRepo.setCursor('device_1', 'seq_100_at_2024-06-01');

      final cursor = await syncRepo.getCursor('device_1');
      expect(cursor, equals('seq_100_at_2024-06-01'));
    });

    test('setCursor overwrites previous cursor', () async {
      await syncRepo.setCursor('device_1', 'seq_50');
      await syncRepo.setCursor('device_1', 'seq_200');

      final cursor = await syncRepo.getCursor('device_1');
      expect(cursor, equals('seq_200'));
    });

    test('different scopeKeys maintain independent cursors', () async {
      await syncRepo.setCursor('device_a', 'seq_10');
      await syncRepo.setCursor('device_b', 'seq_99');

      expect(await syncRepo.getCursor('device_a'), equals('seq_10'));
      expect(await syncRepo.getCursor('device_b'), equals('seq_99'));
    });

    // ── Cursor pagination ─────────────────────────────────────────────────

    test('cursor pagination: can retrieve cursor for multiple pages', () async {
      await syncRepo.setCursor('chat_1_device_1', 'page1_cursor');
      await syncRepo.setCursor('chat_2_device_1', 'page2_cursor');
      await syncRepo.setCursor('chat_3_device_1', 'page3_cursor');

      expect(await syncRepo.getCursor('chat_1_device_1'), equals('page1_cursor'));
      expect(await syncRepo.getCursor('chat_2_device_1'), equals('page2_cursor'));
      expect(await syncRepo.getCursor('chat_3_device_1'), equals('page3_cursor'));
    });

    // ── Sync completeness: messages filterable by chat ────────────────────
    // Property 4 (adapted for Drift): all messages for a chat appear in queries

    test('sync completeness: all messages for a chat appear in query', () async {
      const chatId = 'chat_sync_complete';

      final messages = List.generate(5, (i) {
        return _makeMessage(
          id: 'msg_complete_$i',
          chatId: chatId,
          content: 'message $i',
          timestamp: DateTime(2024, 1, 1, 12, 0, i),
        );
      });

      int seq = 0;
      for (final m in messages) {
        seq++;
        await messageRepo.upsertLocalMessage(
          m,
          effectiveChatId: chatId,
          clientMsgId: m.id,
          serverSeq: seq,
        );
      }

      // Verify all messages stored
      final stored = await messageRepo.watchMessagesForChat(chatId).first;
      expect(stored, hasLength(5));

      // Save cursor after seq 5
      await syncRepo.setCursor('device_1', '5');

      // All messages must be retrievable
      final storedIds = stored.map((m) => m.id).toSet();
      expect(storedIds, containsAll([
        'msg_complete_0',
        'msg_complete_1',
        'msg_complete_2',
        'msg_complete_3',
        'msg_complete_4',
      ]));
    });

    test('sync completeness: new messages after cursor are detectable', () async {
      const chatId = 'chat_new_after_cursor';

      // Initial 3 messages
      for (int i = 0; i < 3; i++) {
        final m = _makeMessage(
          id: 'initial_$i',
          chatId: chatId,
          timestamp: DateTime(2024, 1, 1, 12, 0, i),
        );
        await messageRepo.upsertLocalMessage(
          m,
          effectiveChatId: chatId,
          clientMsgId: 'initial_$i',
          serverSeq: i + 1,
        );
      }

      await syncRepo.setCursor('dev_1', '3');

      // 2 more messages arrive
      for (int i = 0; i < 2; i++) {
        final m = _makeMessage(
          id: 'new_$i',
          chatId: chatId,
          timestamp: DateTime(2024, 1, 1, 13, 0, i),
        );
        await messageRepo.upsertLocalMessage(
          m,
          effectiveChatId: chatId,
          clientMsgId: 'new_$i',
          serverSeq: 4 + i,
        );
      }

      // Total should be 5
      final all = await messageRepo.watchMessagesForChat(chatId).first;
      expect(all, hasLength(5));

      // New messages should be present
      final ids = all.map((m) => m.id).toSet();
      expect(ids, containsAll(['new_0', 'new_1']));
    });

    // ── Chat isolation ────────────────────────────────────────────────────

    test('messages from different chats are isolated', () async {
      final chat1Msgs = List.generate(3, (i) {
        return _makeMessage(
          id: 'c1_$i',
          chatId: 'chat_1',
          content: 'chat1 $i',
          timestamp: DateTime(2024, 1, 1, 12, 0, i),
        );
      });
      final chat2Msgs = List.generate(2, (i) {
        return _makeMessage(
          id: 'c2_$i',
          chatId: 'chat_2',
          content: 'chat2 $i',
          timestamp: DateTime(2024, 1, 1, 13, 0, i),
        );
      });

      for (final m in chat1Msgs) {
        await messageRepo.upsertLocalMessage(m, effectiveChatId: 'chat_1', clientMsgId: m.id);
      }
      for (final m in chat2Msgs) {
        await messageRepo.upsertLocalMessage(m, effectiveChatId: 'chat_2', clientMsgId: m.id);
      }

      final result1 = await messageRepo.watchMessagesForChat('chat_1').first;
      final result2 = await messageRepo.watchMessagesForChat('chat_2').first;

      expect(result1, hasLength(3));
      expect(result2, hasLength(2));
      expect(result1.every((m) => m.chatId == 'chat_1'), isTrue);
      expect(result2.every((m) => m.chatId == 'chat_2'), isTrue);
    });
  });
}
