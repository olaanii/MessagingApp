import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/db/app_database.dart';
import '../repositories/chat_repository.dart';
import '../repositories/drift_repositories.dart';
import '../repositories/message_repository.dart';
import '../repositories/sync_repository.dart';

/// Opens one SQLite file per app process; disposed with the [ProviderScope].
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return DriftChatRepository(ref.watch(appDatabaseProvider));
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return DriftMessageRepository(ref.watch(appDatabaseProvider));
});

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return DriftSyncRepository(ref.watch(appDatabaseProvider));
});
