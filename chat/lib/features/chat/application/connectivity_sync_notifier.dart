import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/chat_repository.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../core/sync/sync_service.dart';
import '../../../presentation/providers/app_providers.dart';
import 'outbox_worker_notifier.dart';

/// Keeps offline-first sync aligned with connectivity changes.
///
/// When connectivity returns and the user is authenticated, the notifier:
/// - pulls the current chat list from the local repository,
/// - syncs each chat via the Serverpod sync endpoint,
/// - pokes the outbox worker so pending retries are re-queued immediately.
///
/// Requirements: 9.3, 9.5, 9.6
final connectivitySyncNotifierProvider =
    NotifierProvider<ConnectivitySyncNotifier, void>(
  ConnectivitySyncNotifier.new,
);

final class ConnectivitySyncNotifier extends Notifier<void> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _syncing = false;

  @override
  void build() {
    final auth = ref.watch(authNotifierProvider);
    final syncService = ref.watch(syncServiceProvider);
    final chatRepository = ref.watch(chatRepositoryProvider);
    final outboxWorker = ref.read(outboxWorkerNotifierProvider.notifier);

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    if (!auth.isAuthenticated) {
      _subscription?.cancel();
      _subscription = null;
      return;
    }

    _subscription ??= _connectivity.onConnectivityChanged.listen((results) {
      if (_hasConnection(results)) {
        unawaited(
          _reconcile(
            syncService: syncService,
            chatRepository: chatRepository,
            outboxWorker: outboxWorker,
          ),
        );
      }
    });

    unawaited(
      Future.microtask(() async {
        final current = await _connectivity.checkConnectivity();
        if (_hasConnection(current)) {
          await _reconcile(
            syncService: syncService,
            chatRepository: chatRepository,
            outboxWorker: outboxWorker,
          );
        }
      }),
    );
  }

  Future<void> _reconcile({
    required SyncService syncService,
    required ChatRepository chatRepository,
    required OutboxWorkerNotifier outboxWorker,
  }) async {
    if (_syncing) return;
    _syncing = true;
    try {
      final chats = await chatRepository.watchChatsOrdered().first;
      final chatIds = chats.map((chat) => chat.id).toList();
      if (chatIds.isNotEmpty) {
        await syncService.syncChats(chatIds);
      }
      await outboxWorker.refreshPendingEntries();
    } finally {
      _syncing = false;
    }
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
