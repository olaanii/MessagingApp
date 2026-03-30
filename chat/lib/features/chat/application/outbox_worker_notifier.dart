import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/crypto/e2ee_engine.dart';
import '../../../core/serverpod/serverpod_client_provider.dart';
import '../../../data/providers/repository_providers.dart';
import '../../auth/application/auth_notifier.dart';
import '../data/chat_key_store.dart';
import '../data/outbox_sync_worker.dart';

// ── ChatKeyStore provider ─────────────────────────────────────────────────────

/// Provides the [ChatKeyStore] singleton backed by flutter_secure_storage.
///
/// Overridable in tests.
final chatKeyStoreProvider = Provider<ChatKeyStore>((ref) {
  return FlutterSecureStorageChatKeyStore();
});

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

    _worker = OutboxSyncWorker(
      syncRepo: syncRepo,
      messageRepo: messageRepo,
      openChatRoom: client.chatStream.chatRoom,
      crypto: E2eeEngine(),
      keyStore: keyStore,
      deviceId: 'local_device', // TODO: replace with stable device ID (task 3.1)
    );

    // Watch auth state and start/pause accordingly.
    final authState = ref.watch(authNotifierV2Provider);
    authState.whenData((state) {
      if (state is AuthStateAuthenticated) {
        _worker?.start();
      } else {
        _worker?.pause();
      }
    });

    ref.onDispose(() {
      _worker?.dispose();
      _worker = null;
    });
  }
}

/// Provider for [OutboxWorkerNotifier].
///
/// Requirements: 5.1, 5.9
final outboxWorkerNotifierProvider =
    NotifierProvider<OutboxWorkerNotifier, void>(OutboxWorkerNotifier.new);
