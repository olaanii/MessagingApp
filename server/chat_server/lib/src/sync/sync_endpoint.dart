import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../security/security_guards.dart';

({DateTime timestamp, String messageId})? _decodeCursor(String? cursor) {
  if (cursor == null || cursor.isEmpty) return null;
  try {
    final parts = utf8.decode(base64Url.decode(cursor)).split('|');
    if (parts.length != 2) return null;
    final timestamp = int.tryParse(parts[0]);
    if (timestamp == null) return null;
    return (
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true),
      messageId: parts[1],
    );
  } catch (_) {
    return null;
  }
}

String _encodeCursor(DateTime timestamp, String messageId) {
  return base64Url.encode(
    utf8.encode('${timestamp.millisecondsSinceEpoch}|$messageId'),
  );
}

/// Incremental sync endpoint for chat changes.
class SyncEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<MessageSyncPage> getChanges(
    Session session,
    String? cursor,
    int limit,
  ) async {
    SecurityGuards.requireRpcAllowed(session);
    final me = session.authenticated!.userIdentifier;
    final take = limit.clamp(1, 200);
    final decoded = _decodeCursor(cursor);

    final whereClause = decoded == null
        ? 'cm."memberAuthUserId" = @me::uuid'
        : 'cm."memberAuthUserId" = @me::uuid AND '
            '(m."createdAt" > @ts OR '
            '(m."createdAt" = @ts AND m.id::text > @msgId))';

    final params = <String, dynamic>{'me': me};
    if (decoded != null) {
      params['ts'] = decoded.timestamp;
      params['msgId'] = decoded.messageId;
    }

    final rows = await session.db.unsafeQuery(
      'SELECT m.id, m."chatId", m."senderAuthUserId", m."senderDeviceId", '
      'm."serverSeq", m."clientMsgId", m."ciphertext", m."nonce", '
      'm."schemaVersion", m."createdAt" '
      'FROM chat_message m '
      'JOIN chat_member cm ON cm."chatId" = m."chatId" '
      'WHERE $whereClause '
      'ORDER BY m."createdAt" ASC, m.id ASC '
      'LIMIT @take',
      parameters: QueryParameters.named({...params, 'take': take + 1}),
    );

    final items = rows.map(_messageFromRow).toList();
    return _pageFromItems(items, take);
  }

  Future<MessageSyncPage> getChatChanges(
    Session session,
    String chatId,
    String? cursor,
    int limit,
  ) async {
    SecurityGuards.requireRpcAllowed(session);
    final me = session.authenticated!.userIdentifier;
    await _assertMember(session, chatId, me);

    final take = limit.clamp(1, 200);
    final decoded = _decodeCursor(cursor);

    final whereClause = decoded == null
        ? 'm."chatId" = @chatId::uuid'
        : 'm."chatId" = @chatId::uuid AND '
            '(m."createdAt" > @ts OR '
            '(m."createdAt" = @ts AND m.id::text > @msgId))';

    final params = <String, dynamic>{'chatId': chatId};
    if (decoded != null) {
      params['ts'] = decoded.timestamp;
      params['msgId'] = decoded.messageId;
    }

    final rows = await session.db.unsafeQuery(
      'SELECT m.id, m."chatId", m."senderAuthUserId", m."senderDeviceId", '
      'm."serverSeq", m."clientMsgId", m."ciphertext", m."nonce", '
      'm."schemaVersion", m."createdAt" '
      'FROM chat_message m '
      'WHERE $whereClause '
      'ORDER BY m."createdAt" ASC, m.id ASC '
      'LIMIT @take',
      parameters: QueryParameters.named({...params, 'take': take + 1}),
    );

    final items = rows.map(_messageFromRow).toList();
    return _pageFromItems(items, take);
  }

  Future<void> _assertMember(Session session, String chatId, String userId) async {
    final rows = await session.db.unsafeQuery(
      'SELECT 1 FROM chat_member WHERE "chatId" = @chatId::uuid '
      'AND "memberAuthUserId" = @userId::uuid LIMIT 1',
      parameters: QueryParameters.named({'chatId': chatId, 'userId': userId}),
    );
    if (rows.isEmpty) {
      throw StateError('not a member of this chat');
    }
  }

  MessageSyncPage _pageFromItems(List<ChatMessage> items, int take) {
    final hasMore = items.length > take;
    final pageItems = hasMore ? items.sublist(0, take) : items;
    String? nextCursor;
    if (hasMore && pageItems.isNotEmpty) {
      final last = pageItems.last;
      nextCursor = _encodeCursor(last.createdAt.toUtc(), last.id.uuid);
    }
    return MessageSyncPage(items: pageItems, nextCursor: nextCursor);
  }

  static ChatMessage _messageFromRow(dynamic row) {
    final c = (row as DatabaseResultRow).toColumnMap();
    return ChatMessage(
      id: UuidValue.fromString(c['id'].toString()),
      chatId: UuidValue.fromString(c['chatId'].toString()),
      senderAuthUserId: UuidValue.fromString(c['senderAuthUserId'].toString()),
      senderDeviceId: c['senderDeviceId'] == null
          ? null
          : UuidValue.fromString(c['senderDeviceId'].toString()),
      serverSeq: (c['serverSeq'] as num).toInt(),
      clientMsgId: c['clientMsgId'] as String,
      ciphertext: c['ciphertext'] as String,
      nonce: c['nonce'] as String,
      schemaVersion: (c['schemaVersion'] as num).toInt(),
      createdAt: (c['createdAt'] as DateTime).toUtc(),
    );
  }
}
