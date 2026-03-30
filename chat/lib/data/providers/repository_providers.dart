import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/chat_repository.dart';
import '../repositories/drift_repositories.dart';
import '../repositories/message_repository.dart';
import '../repositories/sync_repository.dart';
import 'database_provider.dart';

/// Requirement 4.5: THE messageRepositoryProvider, chatRepositoryProvider, and
/// syncRepositoryProvider SHALL each inject the [AppDatabase] instance from
/// [appDatabaseProvider].

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return DriftChatRepository(ref.watch(appDatabaseProvider));
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return DriftMessageRepository(ref.watch(appDatabaseProvider));
});

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return DriftSyncRepository(ref.watch(appDatabaseProvider));
});
