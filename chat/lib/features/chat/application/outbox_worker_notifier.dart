import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/crypto/e2ee_engine.dart';
import '../../../core/device/device_id_service.dart';
import '../../../core/serverpod/serverpod_client_provider.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../presentation/providers/app_providers.dart';
import '../data/chat_key_store.dart';
import '../data/outbox_sync_worker.dart';

// ── OutboxWorkerNotifier ──────────────────────────────────────────────────────

/// Manages the [OutboxSyncWorker] lifecycle, starting it when the user is
/// authenticated and pausing it on sign-out.
///
/// Requirements: 5.1, 5.9
class OutboxWorkerNotifier extends Notifier<void> {
  OutboxSyncWorker? _worker;

  @override
  void build() {
    final syncRepo = ref.watch(syncRepositoryProvider);
    final messageRepo = ref.watch(messageRepositoryProvider);
    final client = ref.watch(serverpodClientProvider);
    final keyStore = ref.watch(chatKeyStoreProvider);

    final deviceIdAsync = ref.watch(deviceIdFutureProvider);
    final deviceId = deviceIdAsync.asData?.value ?? 'local_device';

    _worker = OutboxSyncWorker(
      syncRepo: syncRepo,
      messageRepo: messageRepo,
      openChatRoom: client.chatStream.chatRoom,
      crypto: E2eeEngine(),
      keyStore: keyStore,
      deviceId: deviceId,
    );

    final auth = ref.watch(authNotifierProvider);
    if (auth.isAuthenticated) {
      _worker?.start();
    } else {
      _worker?.pause();
    }

    ref.onDispose(() {
      _worker?.dispose();
      _worker = null;
    });
  }

  /// Re-subscribes the worker to the outbox stream so pending retries can be
  /// retried immediately after connectivity is restored.
  Future<void> refreshPendingEntries() async {
    await _worker?.refresh();
  }
}

/// Provider for [OutboxWorkerNotifier].
///
/// Requirements: 5.1, 5.9
final outboxWorkerNotifierProvider =
    NotifierProvider<OutboxWorkerNotifier, void>(OutboxWorkerNotifier.new);
