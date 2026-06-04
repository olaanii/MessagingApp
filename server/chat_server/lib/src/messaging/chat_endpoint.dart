import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// 1:1 and group threads (MVP: direct only helper).
class ChatEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<void> _assertCanManageGroup(
    Session session,
    String chatId,
    String userId,
  ) async {
    final rows = await session.db.unsafeQuery(
      '''
      SELECT t."createdByAuthUserId", m."role"
      FROM chat_thread t
      JOIN chat_member m ON m."chatId" = t.id
      WHERE t.id = @chatId::uuid AND m."memberAuthUserId" = @userId::uuid
      LIMIT 1
      ''',
      parameters: QueryParameters.named({'chatId': chatId, 'userId': userId}),
    );
    if (rows.isEmpty) throw StateError('not a member of this chat');

    final row = (rows.first as DatabaseResultRow).toColumnMap();
    final creator = row['createdByAuthUserId']?.toString();
    final role = row['role'] as String?;
    if (creator != userId && role != 'admin') {
      throw StateError('not allowed to manage group members');
    }
  }

  /// Opens or returns an existing direct thread with [otherAuthUserId].
  Future<ChatThread> openDirectChat(
    Session session,
    String otherAuthUserId,
  ) async {
    final me = session.authenticated!.userIdentifier;
    if (me == otherAuthUserId) {
      throw ArgumentError('Cannot open direct chat with self');
    }

    final existing = await session.db.unsafeQuery(
      '''
      SELECT t.id, t."type", t."title", t."createdByAuthUserId",
             t."createdAt", t."updatedAt"
      FROM   chat_thread t
      JOIN   chat_member m1 ON m1."chatId" = t.id
      JOIN   chat_member m2 ON m2."chatId" = t.id
      WHERE  t."type" = 'direct'
        AND  m1."memberAuthUserId" = @me::uuid
        AND  m2."memberAuthUserId" = @other::uuid
      LIMIT  1
      ''',
      parameters: QueryParameters.named({'me': me, 'other': otherAuthUserId}),
    );
    if (existing.isNotEmpty) return _threadFromRow(existing.first);

    final newId = const Uuid().v4();
    await session.db.unsafeQuery(
      '''
      WITH ins AS (
        INSERT INTO chat_thread (id, "type", "createdByAuthUserId", "createdAt", "updatedAt")
        VALUES (@id::uuid, 'direct', @me::uuid, now(), now())
        RETURNING id
      )
      INSERT INTO chat_member ("chatId", "memberAuthUserId", "role", "joinedAt", "lastReadSeq")
      SELECT id, @me::uuid,    'member', now(), 0 FROM ins
      UNION ALL
      SELECT id, @other::uuid, 'member', now(), 0 FROM ins
      ''',
      parameters: QueryParameters.named({
        'id': newId,
        'me': me,
        'other': otherAuthUserId,
      }),
    );

    final row = await session.db.unsafeQuery(
      'SELECT id, "type", "title", "createdByAuthUserId", "createdAt", "updatedAt" '
      'FROM chat_thread WHERE id = @id::uuid',
      parameters: QueryParameters.named({'id': newId}),
    );
    return _threadFromRow(row.first);
  }

  Future<ChatThread> createGroupChat(
    Session session,
    String? title,
    List<String> memberAuthUserIds,
  ) async {
    final me = session.authenticated!.userIdentifier;
    final members = {
      me,
      ...memberAuthUserIds.map((id) => id.trim()).where((id) => id.isNotEmpty),
    };
    if (members.length < 2) {
      throw ArgumentError('A group chat requires at least two members');
    }

    final id = const Uuid().v4();
    await session.db.unsafeQuery(
      '''
      INSERT INTO chat_thread
             (id, "type", "title", "createdByAuthUserId", "createdAt", "updatedAt")
      VALUES (@id::uuid, 'group', @title, @me::uuid, now(), now())
      ''',
      parameters: QueryParameters.named({
        'id': id,
        'title': title?.trim().isEmpty ?? true ? null : title!.trim(),
        'me': me,
      }),
    );

    for (final memberId in members) {
      await session.db.unsafeQuery(
        '''
        INSERT INTO chat_member
               ("chatId", "memberAuthUserId", "role", "joinedAt", "lastReadSeq")
        VALUES (@chatId::uuid, @memberId::uuid, @role, now(), 0)
        ''',
        parameters: QueryParameters.named({
          'chatId': id,
          'memberId': memberId,
          'role': memberId == me ? 'admin' : 'member',
        }),
      );
    }

    return getChatDetails(session, UuidValue.fromString(id));
  }

  Future<ChatThread> getChatDetails(Session session, UuidValue chatId) async {
    final me = session.authenticated!.userIdentifier;
    final row = await session.db.unsafeQuery(
      '''
      SELECT t.id, t."type", t."title", t."createdByAuthUserId",
             t."createdAt", t."updatedAt"
      FROM chat_thread t
      JOIN chat_member m ON m."chatId" = t.id
      WHERE t.id = @chatId::uuid AND m."memberAuthUserId" = @me::uuid
      LIMIT 1
      ''',
      parameters: QueryParameters.named({'chatId': chatId.uuid, 'me': me}),
    );
    if (row.isEmpty) throw StateError('chat not found');
    return _threadFromRow(row.first);
  }

  Future<void> addGroupMembers(
    Session session,
    UuidValue chatId,
    List<String> memberAuthUserIds,
  ) async {
    final me = session.authenticated!.userIdentifier;
    await _assertCanManageGroup(session, chatId.uuid, me);
    for (final rawMemberId in memberAuthUserIds) {
      final memberId = rawMemberId.trim();
      if (memberId.isEmpty) continue;
      await session.db.unsafeQuery(
        '''
        INSERT INTO chat_member
               ("chatId", "memberAuthUserId", "role", "joinedAt", "lastReadSeq")
        SELECT @chatId::uuid, @memberId::uuid, 'member', now(), 0
        WHERE NOT EXISTS (
          SELECT 1 FROM chat_member
          WHERE "chatId" = @chatId::uuid
            AND "memberAuthUserId" = @memberId::uuid
        )
        ''',
        parameters: QueryParameters.named({
          'chatId': chatId.uuid,
          'memberId': memberId,
        }),
      );
    }
    await session.db.unsafeQuery(
      'UPDATE chat_thread SET "updatedAt" = now() WHERE id = @chatId::uuid',
      parameters: QueryParameters.named({'chatId': chatId.uuid}),
    );
  }

  Future<void> removeGroupMember(
    Session session,
    UuidValue chatId,
    String memberAuthUserId,
  ) async {
    final me = session.authenticated!.userIdentifier;
    await _assertCanManageGroup(session, chatId.uuid, me);
    final memberId = memberAuthUserId.trim();
    if (memberId.isEmpty) throw ArgumentError('memberAuthUserId is required');

    final countRows = await session.db.unsafeQuery(
      'SELECT COUNT(*) FROM chat_member WHERE "chatId" = @chatId::uuid',
      parameters: QueryParameters.named({'chatId': chatId.uuid}),
    );
    final memberCount = ((countRows.first as DatabaseResultRow)[0] as num).toInt();
    if (memberCount <= 1) throw StateError('cannot remove the last member');

    await session.db.unsafeQuery(
      '''
      DELETE FROM chat_member
      WHERE "chatId" = @chatId::uuid AND "memberAuthUserId" = @memberId::uuid
      ''',
      parameters: QueryParameters.named({
        'chatId': chatId.uuid,
        'memberId': memberId,
      }),
    );
    await session.db.unsafeQuery(
      'UPDATE chat_thread SET "updatedAt" = now() WHERE id = @chatId::uuid',
      parameters: QueryParameters.named({'chatId': chatId.uuid}),
    );
  }

  /// Lists chat threads where the caller is a member, newest-updated first.
  Future<List<ChatThread>> listMyChats(Session session) async {
    final me = session.authenticated!.userIdentifier;
    final rows = await session.db.unsafeQuery(
      '''
      SELECT t.id, t."type", t."title", t."createdByAuthUserId",
             t."createdAt", t."updatedAt"
      FROM   chat_thread t
      JOIN   chat_member m ON m."chatId" = t.id
      WHERE  m."memberAuthUserId" = @me::uuid
      ORDER  BY t."updatedAt" DESC
      ''',
      parameters: QueryParameters.named({'me': me}),
    );
    return rows.map(_threadFromRow).toList();
  }

  static ChatThread _threadFromRow(dynamic row) {
    final c = (row as DatabaseResultRow).toColumnMap();
    return ChatThread(
      id: UuidValue.fromString(c['id'].toString()),
      type: c['type'] as String,
      title: c['title'] as String?,
      createdByAuthUserId: c['createdByAuthUserId'] == null
          ? null
          : UuidValue.fromString(c['createdByAuthUserId'].toString()),
      createdAt: (c['createdAt'] as DateTime).toUtc(),
      updatedAt: (c['updatedAt'] as DateTime).toUtc(),
    );
  }
}
