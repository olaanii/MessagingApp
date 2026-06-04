import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../notifications/push_delivery_service.dart';

String _encodeCursor(int serverSeq, String messageId) =>
    base64Url.encode(utf8.encode('$serverSeq|$messageId'));

({int seq, String messageId})? _decodeCursor(String? cursor) {
  if (cursor == null || cursor.isEmpty) return null;
  try {
    final parts = utf8.decode(base64Url.decode(cursor)).split('|');
    if (parts.length != 2) return null;
    final seq = int.tryParse(parts[0]);
    if (seq == null) return null;
    return (seq: seq, messageId: parts[1]);
  } catch (_) {
    return null;
  }
}

/// Ciphertext message relay + per-chat sync cursor (ADR-0005).
class MessageEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<void> _assertMember(
    Session session,
    String chatId,
    String userId,
  ) async {
    final r = await session.db.unsafeQuery(
      'SELECT 1 FROM chat_member WHERE "chatId" = @chatId::uuid '
      'AND "memberAuthUserId" = @userId::uuid LIMIT 1',
      parameters: QueryParameters.named({'chatId': chatId, 'userId': userId}),
    );
    if (r.isEmpty) throw StateError('not a member of this chat');
  }

  Future<void> _assertNotBlocked(
    Session session,
    String chatId,
    String senderId,
  ) async {
    final rows = await session.db.unsafeQuery(
      '''
      SELECT 1
      FROM chat_member m
      JOIN safety_block b
        ON (b."blockerAuthUserId" = m."memberAuthUserId"
            AND b."blockedAuthUserId" = @senderId::uuid)
        OR (b."blockerAuthUserId" = @senderId::uuid
            AND b."blockedAuthUserId" = m."memberAuthUserId")
      WHERE m."chatId" = @chatId::uuid
        AND m."memberAuthUserId" <> @senderId::uuid
      LIMIT 1
      ''',
      parameters: QueryParameters.named({
        'chatId': chatId,
        'senderId': senderId,
      }),
    );
    if (rows.isNotEmpty) throw StateError('messaging blocked');
  }

  Future<ChatMessage> sendMessage(
    Session session,
    UuidValue chatId,
    String deviceId,
    String clientMsgId,
    String ciphertextB64,
    String nonceB64,
    int schemaVersion,
  ) async {
    final me = session.authenticated!.userIdentifier;
    await _assertMember(session, chatId.uuid, me);
    await _assertNotBlocked(session, chatId.uuid, me);

    final dup = await session.db.unsafeQuery(
      'SELECT id, "chatId", "senderAuthUserId", "senderDeviceId", "serverSeq", '
      '"clientMsgId", "ciphertext", "nonce", "schemaVersion", "createdAt", '
      '"deletedAt" '
      'FROM chat_message '
      'WHERE "chatId" = @chatId::uuid '
      '  AND "clientMsgId" = @clientMsgId '
      '  AND "senderAuthUserId" = @me::uuid '
      'LIMIT 1',
      parameters: QueryParameters.named({
        'chatId': chatId.uuid,
        'clientMsgId': clientMsgId,
        'me': me,
      }),
    );
    if (dup.isNotEmpty) return _msgFromRow(dup.first);

    final msgId = const Uuid().v4();
    await session.db.unsafeQuery(
      '''
      WITH seq AS (
        SELECT COALESCE(MAX("serverSeq"), 0) + 1 AS next
        FROM   chat_message
        WHERE  "chatId" = @chatId::uuid
      )
      INSERT INTO chat_message
             (id, "chatId", "senderAuthUserId", "senderDeviceId",
              "serverSeq", "clientMsgId", "ciphertext", "nonce",
              "schemaVersion", "createdAt")
      SELECT @id::uuid, @chatId::uuid, @me::uuid,
             CASE WHEN @deviceId = '' THEN NULL ELSE @deviceId::uuid END,
             seq.next, @clientMsgId, @ciphertext, @nonce,
             @schemaVersion, now()
      FROM   seq
      ''',
      parameters: QueryParameters.named({
        'id': msgId,
        'chatId': chatId.uuid,
        'me': me,
        'deviceId': deviceId,
        'clientMsgId': clientMsgId,
        'ciphertext': ciphertextB64,
        'nonce': nonceB64,
        'schemaVersion': schemaVersion,
      }),
    );

    await session.db.unsafeQuery(
      'UPDATE chat_thread SET "updatedAt" = now() WHERE id = @chatId::uuid',
      parameters: QueryParameters.named({'chatId': chatId.uuid}),
    );

    final storedMessage = _msgFromRow(
      (await session.db.unsafeQuery(
        'SELECT id, "chatId", "senderAuthUserId", "senderDeviceId", '
        '"serverSeq", "clientMsgId", "ciphertext", "nonce", '
        '"schemaVersion", "createdAt", "deletedAt" '
        'FROM chat_message WHERE id = @id::uuid',
        parameters: QueryParameters.named({'id': msgId}),
      )).first,
    );

    await PushDeliveryService.instance.notifyNewMessage(
      session: session,
      chatId: chatId.uuid,
      senderAuthUserId: me,
      messageId: storedMessage.id.uuid,
    );

    return storedMessage;
  }

  Future<MessageSyncPage> syncMessages(
    Session session,
    UuidValue chatId,
    String? cursor,
    int limit,
  ) async {
    final me = session.authenticated!.userIdentifier;
    await _assertMember(session, chatId.uuid, me);
    final take = limit.clamp(1, 200);
    final decoded = _decodeCursor(cursor);

    final String whereClause = decoded == null
        ? '"chatId" = @chatId::uuid'
        : '"chatId" = @chatId::uuid AND ("serverSeq" > @seq OR '
            '("serverSeq" = @seq AND id::text > @msgId))';

    final params = <String, dynamic>{'chatId': chatId.uuid};
    if (decoded != null) {
      params['seq'] = decoded.seq;
      params['msgId'] = decoded.messageId;
    }

    final rows = await session.db.unsafeQuery(
      'SELECT id, "chatId", "senderAuthUserId", "senderDeviceId", "serverSeq", '
      '"clientMsgId", "ciphertext", "nonce", "schemaVersion", "createdAt", '
      '"deletedAt" '
      'FROM chat_message '
      'WHERE $whereClause '
      'ORDER BY "serverSeq" ASC, id ASC '
      'LIMIT @take',
      parameters: QueryParameters.named({...params, 'take': take + 1}),
    );

    final all = rows.map(_msgFromRow).toList();
    final hasMore = all.length > take;
    final page = hasMore ? all.sublist(0, take) : all;
    String? next;
    if (hasMore && page.isNotEmpty) {
      final last = page.last;
      next = _encodeCursor(last.serverSeq, last.id.uuid);
    }
    return MessageSyncPage(items: page, nextCursor: next);
  }

  Future<ChatMessage> deleteMessage(
    Session session,
    UuidValue chatId,
    UuidValue messageId,
  ) async {
    final me = session.authenticated!.userIdentifier;
    await _assertMember(session, chatId.uuid, me);

    final existing = await session.db.unsafeQuery(
      '''
      SELECT "senderAuthUserId"
      FROM chat_message
      WHERE id = @messageId::uuid AND "chatId" = @chatId::uuid
      LIMIT 1
      ''',
      parameters: QueryParameters.named({
        'chatId': chatId.uuid,
        'messageId': messageId.uuid,
      }),
    );
    if (existing.isEmpty) throw StateError('message not found');

    final sender = (existing.first as DatabaseResultRow)
        .toColumnMap()['senderAuthUserId']
        .toString();
    if (sender != me) throw StateError('cannot delete another user message');

    await session.db.unsafeQuery(
      '''
      UPDATE chat_message
      SET "ciphertext" = '',
          "nonce" = '',
          "deletedAt" = COALESCE("deletedAt", now())
      WHERE id = @messageId::uuid AND "chatId" = @chatId::uuid
      ''',
      parameters: QueryParameters.named({
        'chatId': chatId.uuid,
        'messageId': messageId.uuid,
      }),
    );

    final row = await session.db.unsafeQuery(
      'SELECT id, "chatId", "senderAuthUserId", "senderDeviceId", '
      '"serverSeq", "clientMsgId", "ciphertext", "nonce", '
      '"schemaVersion", "createdAt", "deletedAt" '
      'FROM chat_message WHERE id = @messageId::uuid',
      parameters: QueryParameters.named({'messageId': messageId.uuid}),
    );
    return _msgFromRow(row.first);
  }

  static ChatMessage _msgFromRow(dynamic row) {
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
      deletedAt: (c['deletedAt'] as DateTime?)?.toUtc(),
    );
  }
}
