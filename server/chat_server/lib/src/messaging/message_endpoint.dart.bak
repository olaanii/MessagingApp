import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

UuidValue _uuid(String s) => UuidValueJsonExtension.fromJson(s);

String? _encodeCursor(int serverSeq, UuidValue messageId) =>
    base64Url.encode(utf8.encode('$serverSeq|${messageId.uuid}'));

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

  Future<void> _assertMember(Session session, UuidValue chatId, String me) async {
    final row = await ChatMemberRow.db.findFirstRow(
      session,
      where: (t) =>
          t.chatId.equals(chatId) & t.memberAuthUserId.equals(_uuid(me)),
    );
    if (row == null) {
      throw StateError('not a member of this chat');
    }
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
    await _assertMember(session, chatId, me);

    final dev = await RegisteredDevice.db.findFirstRow(
      session,
      where: (t) =>
          t.deviceId.equals(deviceId) & t.ownerAuthUserId.equals(me),
    );
    if (dev == null) {
      throw StateError('register device first');
    }

    final meUuid = _uuid(me);
    final dup = await ChatMessage.db.findFirstRow(
      session,
      where: (t) =>
          t.chatId.equals(chatId) &
          t.clientMsgId.equals(clientMsgId) &
          t.senderAuthUserId.equals(meUuid),
    );
    if (dup != null) {
      return dup;
    }

    return await session.db.transaction((transaction) async {
      final last = await ChatMessage.db.findFirstRow(
        session,
        where: (t) => t.chatId.equals(chatId),
        orderBy: (t) => t.serverSeq,
        orderDescending: true,
        transaction: transaction,
      );
      final nextSeq = (last?.serverSeq ?? 0) + 1;

      final msg = await ChatMessage.db.insertRow(
        session,
        ChatMessage(
          chatId: chatId,
          senderAuthUserId: meUuid,
          senderDeviceId: _uuid(deviceId),
          serverSeq: nextSeq,
          clientMsgId: clientMsgId,
          ciphertext: ciphertextB64,
          nonce: nonceB64,
          schemaVersion: schemaVersion,
        ),
        transaction: transaction,
      );

      final thread = await ChatThread.db.findById(session, chatId);
      if (thread != null) {
        await ChatThread.db.updateRow(
          session,
          thread.copyWith(updatedAt: DateTime.now().toUtc()),
          transaction: transaction,
        );
      }

      return msg;
    });
  }

  Future<MessageSyncPage> syncMessages(
    Session session,
    UuidValue chatId,
    String? cursor,
    int limit,
  ) async {
    final me = session.authenticated!.userIdentifier;
    await _assertMember(session, chatId, me);
    final take = limit.clamp(1, 200);
    final decoded = _decodeCursor(cursor);

    var rows = await ChatMessage.db.find(
      session,
      where: (t) => t.chatId.equals(chatId),
    );
    rows.sort((a, b) {
      final c = a.serverSeq.compareTo(b.serverSeq);
      if (c != 0) return c;
      return a.id.uuid.compareTo(b.id.uuid);
    });

    if (decoded != null) {
      final afterSeq = decoded.seq;
      final afterId = decoded.messageId;
      rows = rows.where((m) {
        if (m.serverSeq > afterSeq) return true;
        if (m.serverSeq < afterSeq) return false;
        return m.id.uuid.compareTo(afterId) > 0;
      }).toList();
    }

    final page = rows.take(take).toList();
    String? next;
    if (rows.length > take && page.isNotEmpty) {
      final last = page.last;
      next = _encodeCursor(last.serverSeq, last.id);
    }
    return MessageSyncPage(items: page, nextCursor: next);
  }
}
