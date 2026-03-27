import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

UuidValue _uuid(String s) => UuidValueJsonExtension.fromJson(s);

/// 1:1 and group threads (MVP: direct only helper).
class ChatEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Opens or returns an existing direct thread with [otherAuthUserId].
  Future<ChatThread> openDirectChat(
    Session session,
    String otherAuthUserId,
  ) async {
    final me = session.authenticated!.userIdentifier;
    final other = otherAuthUserId;
    if (me == other) {
      throw ArgumentError('Cannot open direct chat with self');
    }

    final meUuid = _uuid(me);
    final otherUuid = _uuid(other);

    final myMemberships = await ChatMemberRow.db.find(
      session,
      where: (t) => t.memberAuthUserId.equals(meUuid),
    );

    for (final m in myMemberships) {
      final thread = await ChatThread.db.findById(session, m.chatId);
      if (thread == null || thread.type != 'direct') continue;
      final members = await ChatMemberRow.db.find(
        session,
        where: (t) => t.chatId.equals(m.chatId),
      );
      if (members.length == 2 &&
          members.any((x) => x.memberAuthUserId == otherUuid)) {
        return thread;
      }
    }

    return await session.db.transaction((transaction) async {
      final chat = await ChatThread.db.insertRow(
        session,
        ChatThread(
          type: 'direct',
          title: null,
          createdByAuthUserId: meUuid,
        ),
        transaction: transaction,
      );
      await ChatMemberRow.db.insertRow(
        session,
        ChatMemberRow(
          chatId: chat.id,
          memberAuthUserId: meUuid,
          role: 'member',
        ),
        transaction: transaction,
      );
      await ChatMemberRow.db.insertRow(
        session,
        ChatMemberRow(
          chatId: chat.id,
          memberAuthUserId: otherUuid,
          role: 'member',
        ),
        transaction: transaction,
      );
      return chat;
    });
  }

  /// Lists chat threads where the caller is a member (by membership rows).
  Future<List<ChatThread>> listMyChats(Session session) async {
    final meUuid = _uuid(session.authenticated!.userIdentifier);
    final rows = await ChatMemberRow.db.find(
      session,
      where: (t) => t.memberAuthUserId.equals(meUuid),
    );
    final chats = <ChatThread>[];
    for (final r in rows) {
      final c = await ChatThread.db.findById(session, r.chatId);
      if (c != null) chats.add(c);
    }
    chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return chats;
  }
}
