// ignore_for_file: lines_longer_than_80_chars

import 'package:chat/data/local/db/app_database.dart';
import 'package:chat/data/repositories/drift_repositories.dart';
import 'package:chat/domain/models/chat_summary.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

AppDatabase _openInMemory() => AppDatabase(NativeDatabase.memory());

ChatSummary _makeChatSummary({
  required String id,
  String type = 'direct',
  String? title,
  String? lastPreview,
  DateTime? lastMessageAt,
  int unreadCount = 0,
}) =>
    ChatSummary(
      id: id,
      type: type,
      title: title,
      lastPreview: lastPreview,
      lastMessageAt: lastMessageAt,
      unreadCount: unreadCount,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // Task 6.2 — Chat Management Unit Tests
  // Requirements: 13.1, 13.2, 13.6, 13.7
  // ═══════════════════════════════════════════════════════════════════════════

  group('Task 6.2 — Chat Management', () {
    late AppDatabase db;
    late DriftChatRepository repo;

    setUp(() {
      db = _openInMemory();
      repo = DriftChatRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    // ── createDirectChat: creates chat with 2 members ──────────────────────
    // Requirement 13.1: Direct chat creation

    test('createDirectChat: upsertChat stores a direct chat', () async {
      final chat = _makeChatSummary(
        id: 'direct_1',
        type: 'direct',
        lastMessageAt: DateTime(2024, 6, 1),
      );

      await repo.upsertChat(chat, updatedAt: DateTime.now());

      final chats = await repo.watchChatsOrdered().first;
      expect(chats, hasLength(1));
      expect(chats.first.id, equals('direct_1'));
      expect(chats.first.type, equals('direct'));
    });

    test('createDirectChat: can store two distinct direct chats', () async {
      final chat1 = _makeChatSummary(
        id: 'direct_alice_bob',
        type: 'direct',
        lastMessageAt: DateTime(2024, 6, 1),
      );
      final chat2 = _makeChatSummary(
        id: 'direct_alice_charlie',
        type: 'direct',
        lastMessageAt: DateTime(2024, 6, 2),
      );

      await repo.upsertChat(chat1, updatedAt: DateTime.now());
      await repo.upsertChat(chat2, updatedAt: DateTime.now());

      final chats = await repo.watchChatsOrdered().first;
      expect(chats, hasLength(2));
      // Ordered by lastMessageAt DESC, so chat2 first.
      expect(chats[0].id, equals('direct_alice_charlie'));
      expect(chats[1].id, equals('direct_alice_bob'));
    });

    test('createDirectChat: duplicate upsert replaces existing chat', () async {
      final chat = _makeChatSummary(
        id: 'direct_1',
        type: 'direct',
        title: 'Alice & Bob',
        lastMessageAt: DateTime(2024, 6, 1),
        unreadCount: 0,
      );
      await repo.upsertChat(chat, updatedAt: DateTime.now());

      // Upsert again with updated values.
      final updated = _makeChatSummary(
        id: 'direct_1',
        type: 'direct',
        title: 'Alice & Bob',
        lastMessageAt: DateTime(2024, 6, 2),
        unreadCount: 3,
      );
      await repo.upsertChat(updated, updatedAt: DateTime.now());

      final chats = await repo.watchChatsOrdered().first;
      expect(chats, hasLength(1));
      expect(chats.first.unreadCount, equals(3));
    });

    // ── createGroupChat: creates chat with N members ───────────────────────
    // Requirement 13.2: Group chat creation

    test('createGroupChat: upsertChat stores a group chat', () async {
      final group = _makeChatSummary(
        id: 'group_1',
        type: 'group',
        title: 'Team Chat',
        lastMessageAt: DateTime(2024, 6, 1),
      );

      await repo.upsertChat(group, updatedAt: DateTime.now());

      final chats = await repo.watchChatsOrdered().first;
      expect(chats, hasLength(1));
      expect(chats.first.id, equals('group_1'));
      expect(chats.first.type, equals('group'));
      expect(chats.first.title, equals('Team Chat'));
    });

    test('createGroupChat: can store multiple group chats', () async {
      final groups = List.generate(5, (i) {
        final g = _makeChatSummary(
          id: 'group_$i',
          type: 'group',
          title: 'Group $i',
          lastMessageAt: DateTime(2024, 6, 1, 0, i),
        );
        return g;
      });

      for (final g in groups) {
        await repo.upsertChat(g, updatedAt: DateTime.now());
      }

      final chats = await repo.watchChatsOrdered().first;
      expect(chats, hasLength(5));
    });

    // ── addGroupMembers: members table supports adding members ─────────────
    // Requirement 13.6: Add group members

    test('addGroupMembers: members can be added to a chat', () async {
      final chatId = 'group_members_test';
      // Insert members into ChatMembers table.
      await db.into(db.chatMembers).insert(
            ChatMembersCompanion.insert(
              chatId: chatId,
              userId: 'user_alice',
              joinedAt: DateTime.now(),
            ),
          );
      await db.into(db.chatMembers).insert(
            ChatMembersCompanion.insert(
              chatId: chatId,
              userId: 'user_bob',
              joinedAt: DateTime.now(),
            ),
          );

      final members = await (db.select(db.chatMembers)
            ..where((m) => m.chatId.equals(chatId)))
          .get();

      expect(members, hasLength(2));
      expect(members.map((m) => m.userId), containsAll(['user_alice', 'user_bob']));
      expect(members.every((m) => m.role == 'member'), isTrue);
    });

    test('addGroupMembers: can add N members to a group', () async {
      final chatId = 'group_n_members';
      const memberCount = 10;

      for (int i = 0; i < memberCount; i++) {
        await db.into(db.chatMembers).insert(
              ChatMembersCompanion.insert(
                chatId: chatId,
                userId: 'user_$i',
                joinedAt: DateTime.now(),
              ),
            );
      }

      final members = await (db.select(db.chatMembers)
            ..where((m) => m.chatId.equals(chatId)))
          .get();

      expect(members, hasLength(memberCount));
    });

    // ── removeGroupMember: remove access ──────────────────────────────────
    // Requirement 13.7: Remove group member

    test('removeGroupMember: removing a member deletes their row', () async {
      final chatId = 'group_remove_test';
      // Add two members.
      await db.into(db.chatMembers).insert(
            ChatMembersCompanion.insert(
              chatId: chatId,
              userId: 'user_alice',
              joinedAt: DateTime.now(),
            ),
          );
      await db.into(db.chatMembers).insert(
            ChatMembersCompanion.insert(
              chatId: chatId,
              userId: 'user_bob',
              joinedAt: DateTime.now(),
            ),
          );

      // Remove user_bob.
      await (db.delete(db.chatMembers)
            ..where((m) => m.userId.equals('user_bob')))
          .go();

      final members = await (db.select(db.chatMembers)
            ..where((m) => m.chatId.equals(chatId)))
          .get();

      expect(members, hasLength(1));
      expect(members.first.userId, equals('user_alice'));
    });

    test('removeGroupMember: chat itself is not deleted when member removed', () async {
      final chatId = 'group_remove_chat_check';
      final chat = _makeChatSummary(
        id: chatId,
        type: 'group',
        title: 'Test Group',
      );
      await repo.upsertChat(chat, updatedAt: DateTime.now());

      // Add and remove a member.
      await db.into(db.chatMembers).insert(
            ChatMembersCompanion.insert(
              chatId: chatId,
              userId: 'user_temp',
              joinedAt: DateTime.now(),
            ),
          );
      await (db.delete(db.chatMembers)
            ..where((m) => m.userId.equals('user_temp')))
          .go();

      // Chat must still exist.
      final chats = await repo.watchChatsOrdered().first;
      expect(chats.any((c) => c.id == chatId), isTrue);
    });

    // ── deleteChat: removes chat row ──────────────────────────────────────

    test('deleteChat: removes the chat from the list', () async {
      final chat = _makeChatSummary(id: 'chat_del', type: 'direct');
      await repo.upsertChat(chat, updatedAt: DateTime.now());

      var chats = await repo.watchChatsOrdered().first;
      expect(chats, hasLength(1));

      await repo.deleteChat('chat_del');

      chats = await repo.watchChatsOrdered().first;
      expect(chats, isEmpty);
    });

    // ── Chat ordering ──────────────────────────────────────────────────────

    test('chats are ordered by lastMessageAt descending', () async {
      final chat1 = _makeChatSummary(
        id: 'chat_old',
        lastMessageAt: DateTime(2024, 1, 1),
      );
      final chat2 = _makeChatSummary(
        id: 'chat_new',
        lastMessageAt: DateTime(2024, 6, 1),
      );
      final chat3 = _makeChatSummary(
        id: 'chat_mid',
        lastMessageAt: DateTime(2024, 3, 1),
      );

      await repo.upsertChat(chat1, updatedAt: DateTime.now());
      await repo.upsertChat(chat2, updatedAt: DateTime.now());
      await repo.upsertChat(chat3, updatedAt: DateTime.now());

      final chats = await repo.watchChatsOrdered().first;
      expect(chats, hasLength(3));
      expect(chats[0].id, equals('chat_new'));
      expect(chats[1].id, equals('chat_mid'));
      expect(chats[2].id, equals('chat_old'));
    });
  });
}
