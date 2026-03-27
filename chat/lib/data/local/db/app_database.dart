import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import '../../../domain/models/chat_summary.dart';
import '../../../domain/models/message_model.dart';

part 'app_database.g.dart';

// --- Tables (mirror `mvp_plan.md` § Local database Drift) ---

class LocalChats extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get title => text().nullable()();
  TextColumn get lastPreview => text().nullable()();
  DateTimeColumn get lastMessageAt => dateTime().nullable()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class LocalMessages extends Table {
  /// Row id (matches [MessageModel.id] / client id).
  TextColumn get id => text()();
  TextColumn get chatId => text()();
  TextColumn get senderId => text()();
  TextColumn get receiverId => text().nullable()();
  /// Plaintext during transition; ciphertext UTF-8 once E2EE is enforced at repo boundary.
  TextColumn get body => text()();
  TextColumn get contentType => text().withDefault(const Constant('text'))();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('sent'))();
  IntColumn get serverSeq => integer().nullable()();
  TextColumn get clientMsgId => text().nullable().unique()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isPendingDelivery =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class ChatMembers extends Table {
  TextColumn get chatId => text()();
  TextColumn get userId => text()();
  TextColumn get role => text().withDefault(const Constant('member'))();
  DateTimeColumn get joinedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {chatId, userId};
}

class OutboxEntries extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get clientMsgId => text().unique()();
  TextColumn get chatId => text()();
  TextColumn get operation =>
      text().withDefault(const Constant('sendMessage'))();
  /// Serialized payload for Serverpod/Firestore adapters (versioned informally).
  TextColumn get payloadJson => text()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  TextColumn get state => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();
}

class SyncStates extends Table {
  TextColumn get scopeKey => text()();
  TextColumn get cursor => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {scopeKey};
}

class PendingMedia extends Table {
  TextColumn get id => text()();
  TextColumn get chatId => text()();
  TextColumn get localPath => text()();
  IntColumn get bytesUploaded => integer().withDefault(const Constant(0))();
  IntColumn get totalBytes => integer().nullable()();
  TextColumn get state => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

LazyDatabase openChatConnection() {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'chat_local.db'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(
  tables: [
    LocalChats,
    LocalMessages,
    ChatMembers,
    OutboxEntries,
    SyncStates,
    PendingMedia,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openChatConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
      );
}

extension LocalMessageMapping on LocalMessage {
  MessageModel toMessageModel() {
    return MessageModel(
      id: id,
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId ?? '',
      content: body,
      imageUrl: imageUrl,
      timestamp: createdAt,
      status: status,
      isOffline: isPendingDelivery,
    );
  }
}

extension LocalChatMapping on LocalChat {
  ChatSummary toChatSummary() {
    return ChatSummary(
      id: id,
      type: type,
      title: title,
      lastPreview: lastPreview,
      lastMessageAt: lastMessageAt,
      unreadCount: unreadCount,
    );
  }
}
