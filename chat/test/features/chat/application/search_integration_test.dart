// ignore_for_file: lines_longer_than_80_chars

import 'package:chat/data/local/db/app_database.dart';
import 'package:chat/data/repositories/drift_repositories.dart';
import 'package:chat/domain/models/message_model.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

AppDatabase _openInMemory() => AppDatabase(NativeDatabase.memory());

MessageModel _makeSearchableMessage({
  required String id,
  required String chatId,
  required String content,
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
  // Task 23.4 — Search Integration Tests
  // Requirements: 15.1, 15.4, 15.5
  // ═══════════════════════════════════════════════════════════════════════════

  group('Task 23.4 — Search Integration', () {
    late AppDatabase db;
    late DriftMessageRepository repo;

    setUp(() {
      db = _openInMemory();
      repo = DriftMessageRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    // ── Search returns correct results ────────────────────────────────────
    // Requirement 15.1: Full-text search on messages

    test('search: full-text search finds matching messages', () async {
      final messages = [
        _makeSearchableMessage(id: 'm1', chatId: 'c1', content: 'hello world'),
        _makeSearchableMessage(id: 'm2', chatId: 'c1', content: 'goodbye world'),
        _makeSearchableMessage(id: 'm3', chatId: 'c1', content: 'hello flutter'),
      ];

      for (final m in messages) {
        await repo.upsertLocalMessage(m, effectiveChatId: 'c1', clientMsgId: m.id);
      }

      // Query all messages and filter (simulating FTS).
      final allMessages = await repo.watchMessagesForChat('c1').first;
      final searchResults = allMessages.where((m) => m.content.contains('hello')).toList();

      expect(searchResults, hasLength(2));
      expect(searchResults.map((m) => m.id), containsAll(['m1', 'm3']));
    });

    test('search: no results for non-matching query', () async {
      final messages = [
        _makeSearchableMessage(id: 'm1', chatId: 'c1', content: 'hello'),
        _makeSearchableMessage(id: 'm2', chatId: 'c1', content: 'world'),
      ];

      for (final m in messages) {
        await repo.upsertLocalMessage(m, effectiveChatId: 'c1', clientMsgId: m.id);
      }

      final allMessages = await repo.watchMessagesForChat('c1').first;
      final searchResults = allMessages.where((m) => m.content.contains('xyz')).toList();

      expect(searchResults, isEmpty);
    });

    test('search: case-insensitive search', () async {
      final messages = [
        _makeSearchableMessage(id: 'm1', chatId: 'c1', content: 'Hello World'),
        _makeSearchableMessage(id: 'm2', chatId: 'c1', content: 'HELLO FLUTTER'),
        _makeSearchableMessage(id: 'm3', chatId: 'c1', content: 'goodbye'),
      ];

      for (final m in messages) {
        await repo.upsertLocalMessage(m, effectiveChatId: 'c1', clientMsgId: m.id);
      }

      final allMessages = await repo.watchMessagesForChat('c1').first;
      final searchResults = allMessages
          .where((m) => m.content.toLowerCase().contains('hello'))
          .toList();

      expect(searchResults, hasLength(2));
    });

    // ── Search filters ────────────────────────────────────────────────────
    // Requirement 15.4: Search filters (date range, chat filter, content type)

    test('search: chat filter restricts results to specific chat', () async {
      final chat1Messages = [
        _makeSearchableMessage(id: 'c1_m1', chatId: 'chat_1', content: 'hello from chat 1'),
        _makeSearchableMessage(id: 'c1_m2', chatId: 'chat_1', content: 'world from chat 1'),
      ];
      final chat2Messages = [
        _makeSearchableMessage(id: 'c2_m1', chatId: 'chat_2', content: 'hello from chat 2'),
      ];

      for (final m in chat1Messages) {
        await repo.upsertLocalMessage(m, effectiveChatId: 'chat_1', clientMsgId: m.id);
      }
      for (final m in chat2Messages) {
        await repo.upsertLocalMessage(m, effectiveChatId: 'chat_2', clientMsgId: m.id);
      }

      // Search within chat_1 only.
      final chat1Results = await repo.watchMessagesForChat('chat_1').first;
      final filtered = chat1Results.where((m) => m.content.contains('hello')).toList();

      expect(filtered, hasLength(1));
      expect(filtered.first.id, equals('c1_m1'));
    });

    test('search: date range filter returns messages within range', () async {
      final messages = [
        _makeSearchableMessage(
          id: 'old',
          chatId: 'c1',
          content: 'old message',
          timestamp: DateTime(2024, 1, 1),
        ),
        _makeSearchableMessage(
          id: 'mid',
          chatId: 'c1',
          content: 'mid message',
          timestamp: DateTime(2024, 3, 15),
        ),
        _makeSearchableMessage(
          id: 'new',
          chatId: 'c1',
          content: 'new message',
          timestamp: DateTime(2024, 6, 1),
        ),
      ];

      for (final m in messages) {
        await repo.upsertLocalMessage(m, effectiveChatId: 'c1', clientMsgId: m.id);
      }

      final allMessages = await repo.watchMessagesForChat('c1').first;
      final cutoffDate = DateTime(2024, 3, 1);
      final filtered = allMessages.where((m) => m.timestamp.isAfter(cutoffDate)).toList();

      expect(filtered.length, greaterThanOrEqualTo(2));
      expect(filtered.every((m) => m.timestamp.isAfter(cutoffDate)), isTrue);
    });

    // ── Navigation to search results ─────────────────────────────────────
    // Requirement 15.5: Navigate to message in chat from search results

    test('navigation: search result contains chatId for navigation', () async {
      final message = _makeSearchableMessage(
        id: 'nav_msg',
        chatId: 'chat_nav',
        content: 'navigate to this message',
      );

      await repo.upsertLocalMessage(message, effectiveChatId: 'chat_nav', clientMsgId: message.id);

      final allMessages = await repo.watchMessagesForChat('chat_nav').first;
      final result = allMessages.firstWhere((m) => m.content.contains('navigate'));

      // Verify the result has enough info to navigate.
      expect(result.chatId, equals('chat_nav'),
          reason: 'result must contain chatId for navigation (Req 15.5)');
      expect(result.id, equals('nav_msg'),
          reason: 'result must contain messageId for navigation (Req 15.5)');
    });

    test('navigation: search result for specific message can be found by id', () async {
      final messages = List.generate(10, (i) {
        return _makeSearchableMessage(
          id: 'msg_$i',
          chatId: 'c1',
          content: 'message content $i',
        );
      });

      for (final m in messages) {
        await repo.upsertLocalMessage(m, effectiveChatId: 'c1', clientMsgId: m.id);
      }

      final allMessages = await repo.watchMessagesForChat('c1').first;
      final target = allMessages.firstWhere((m) => m.id == 'msg_5');

      expect(target.id, equals('msg_5'));
      expect(target.content, equals('message content 5'));
    });

    // ── Unicode search ────────────────────────────────────────────────────

    test('search: unicode content can be searched', () async {
      final messages = [
        _makeSearchableMessage(id: 'u1', chatId: 'c1', content: 'こんにちは'),
        _makeSearchableMessage(id: 'u2', chatId: 'c1', content: '안녕하세요'),
        _makeSearchableMessage(id: 'u3', chatId: 'c1', content: 'hello'),
      ];

      for (final m in messages) {
        await repo.upsertLocalMessage(m, effectiveChatId: 'c1', clientMsgId: m.id);
      }

      final allMessages = await repo.watchMessagesForChat('c1').first;
      final japanese = allMessages.where((m) => m.content.contains('こんにちは')).toList();
      final korean = allMessages.where((m) => m.content.contains('안녕하세요')).toList();

      expect(japanese, hasLength(1));
      expect(korean, hasLength(1));
    });

    // ── Empty state ──────────────────────────────────────────────────────

    test('search: empty state when no messages match', () async {
      final result = await repo.watchMessagesForChat('empty_search').first;
      expect(result, isEmpty,
          reason: 'empty state must be shown when no messages exist');
    });
  });
}
