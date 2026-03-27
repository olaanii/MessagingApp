import 'package:drift/drift.dart';

import '../../domain/models/chat_summary.dart';
import '../../domain/models/message_model.dart';
import '../local/db/app_database.dart';
import 'chat_repository.dart';
import 'message_repository.dart';
import 'sync_repository.dart';

final class DriftChatRepository implements ChatRepository {
  DriftChatRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<ChatSummary>> watchChatsOrdered() {
    final query = _db.select(_db.localChats)
      ..orderBy([
        (t) => OrderingTerm.desc(t.lastMessageAt),
        (t) => OrderingTerm.desc(t.updatedAt),
      ]);
    return query.watch().map(
          (rows) => rows.map((r) => r.toChatSummary()).toList(),
        );
  }

  @override
  Future<void> upsertChat(
    ChatSummary chat, {
    required DateTime updatedAt,
  }) async {
    await _db.into(_db.localChats).insertOnConflictUpdate(
          LocalChatsCompanion.insert(
            id: chat.id,
            type: chat.type,
            title: Value(chat.title),
            lastPreview: Value(chat.lastPreview),
            lastMessageAt: Value(chat.lastMessageAt),
            unreadCount: Value(chat.unreadCount),
            updatedAt: updatedAt,
          ),
        );
  }

  @override
  Future<void> deleteChat(String id) async {
    await (_db.delete(_db.localChats)..where((t) => t.id.equals(id))).go();
  }
}

final class DriftMessageRepository implements MessageRepository {
  DriftMessageRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<MessageModel>> watchMessagesForChat(
    String chatId, {
    int limit = 200,
  }) {
    final query = _db.select(_db.localMessages)
      ..where((m) => m.chatId.equals(chatId) & m.deletedAt.isNull())
      ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
      ..limit(limit);
    return query.watch().map(
          (rows) => rows.map((r) => r.toMessageModel()).toList(),
        );
  }

  @override
  Future<void> upsertLocalMessage(
    MessageModel message, {
    required String effectiveChatId,
    String? clientMsgId,
    int? serverSeq,
  }) async {
    final receiver = message.receiverId;
    await _db.into(_db.localMessages).insertOnConflictUpdate(
          LocalMessagesCompanion.insert(
            id: message.id,
            chatId: effectiveChatId,
            senderId: message.senderId,
            receiverId: receiver.isEmpty
                ? const Value.absent()
                : Value(receiver),
            body: message.content,
            contentType: const Value('text'),
            imageUrl: Value(message.imageUrl),
            status: Value(message.status),
            serverSeq: Value(serverSeq),
            clientMsgId: Value(clientMsgId ?? message.id),
            createdAt: message.timestamp,
            deletedAt: const Value.absent(),
            isPendingDelivery: Value(message.isOffline),
          ),
        );
  }

  @override
  Future<void> tombstoneMessage(String messageId, DateTime deletedAt) async {
    await (_db.update(_db.localMessages)..where((m) => m.id.equals(messageId)))
        .write(LocalMessagesCompanion(deletedAt: Value(deletedAt)));
  }

  @override
  Future<void> mergeServerMessages(
    String chatId,
    List<MessageModel> messages,
  ) async {
    await _db.transaction(() async {
      for (final m in messages) {
        await upsertLocalMessage(
          m,
          effectiveChatId: chatId,
          clientMsgId: m.id,
          serverSeq: null,
        );
      }
    });
  }
}

final class DriftSyncRepository implements SyncRepository {
  DriftSyncRepository(this._db);

  final AppDatabase _db;

  @override
  Future<void> enqueueOperation({
    required String clientMsgId,
    required String chatId,
    required String payloadJson,
    String operation = 'sendMessage',
  }) async {
    await _db.into(_db.outboxEntries).insertOnConflictUpdate(
          OutboxEntriesCompanion.insert(
            clientMsgId: clientMsgId,
            chatId: chatId,
            operation: Value(operation),
            payloadJson: payloadJson,
            createdAt: DateTime.now(),
            state: const Value('pending'),
            attemptCount: const Value(0),
            nextRetryAt: const Value.absent(),
          ),
        );
  }

  @override
  Stream<List<OutboxItem>> watchOutbox({Iterable<String>? states}) {
    final filter = states?.toList() ?? const ['pending', 'sending', 'failed'];
    final q = _db.select(_db.outboxEntries)
      ..where((e) => e.state.isIn(filter))
      ..orderBy([(e) => OrderingTerm.asc(e.createdAt)]);
    return q.watch().map(
          (rows) => rows
              .map(
                (r) => OutboxItem(
                  localId: r.localId,
                  clientMsgId: r.clientMsgId,
                  chatId: r.chatId,
                  operation: r.operation,
                  payloadJson: r.payloadJson,
                  attemptCount: r.attemptCount,
                  state: r.state,
                  createdAt: r.createdAt,
                  nextRetryAt: r.nextRetryAt,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<void> updateOutboxEntry({
    required String clientMsgId,
    required String state,
    int? attemptCount,
    DateTime? nextRetryAt,
  }) async {
    await (_db.update(_db.outboxEntries)
          ..where((e) => e.clientMsgId.equals(clientMsgId)))
        .write(
      OutboxEntriesCompanion(
        state: Value(state),
        attemptCount: attemptCount != null
            ? Value(attemptCount)
            : const Value.absent(),
        nextRetryAt: nextRetryAt != null
            ? Value(nextRetryAt)
            : const Value.absent(),
      ),
    );
  }

  @override
  Future<String?> getCursor(String scopeKey) async {
    final row = await (_db.select(_db.syncStates)
          ..where((s) => s.scopeKey.equals(scopeKey)))
        .getSingleOrNull();
    return row?.cursor;
  }

  @override
  Future<void> setCursor(
    String scopeKey,
    String? cursor, {
    DateTime? at,
  }) async {
    await _db.into(_db.syncStates).insertOnConflictUpdate(
          SyncStatesCompanion.insert(
            scopeKey: scopeKey,
            cursor: Value(cursor),
            lastSyncedAt: Value(at ?? DateTime.now()),
          ),
        );
  }
}
