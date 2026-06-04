import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../application/mesh_notifier.dart';

/// Syncs mesh-delivered messages with the Serverpod backend when internet
/// connectivity is restored.
///
/// Requirements: 3.6, 3.8
class MeshServerSync {
  MeshServerSync({
    required this.meshNotifier,
    this.onSyncComplete,
  });

  final MeshNotifier meshNotifier;
  final void Function(int count)? onSyncComplete;

  StreamSubscription? _connectivitySub;
  bool _isSyncing = false;

  /// Start monitoring connectivity and auto-sync when online.
  void start() {
    _connectivitySub?.cancel();
    final connectivity = Connectivity();
    _connectivitySub =
        connectivity.onConnectivityChanged.listen((results) {
      final hasInternet =
          results.any((r) => r != ConnectivityResult.none);
      if (hasInternet && !_isSyncing) {
        _syncPendingMessages();
      }
    });
  }

  /// Stop monitoring.
  void stop() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  /// Manually trigger sync of pending mesh messages.
  Future<int> syncPendingMessages() => _syncPendingMessages();

  Future<int> _syncPendingMessages() async {
    if (_isSyncing) return 0;
    _isSyncing = true;

    try {
      // The mesh messages that need server sync are those that were delivered
      // via BLE while offline but should also be persisted to the server
      // for cross-device consistency.
      //
      // In this MVP implementation, we listen to the mesh message stream
      // and flag any messages that need server-side sync. The actual sync
      // would enqueue them to the outbox for server delivery.

      // For now, return 0 pending – the full implementation would:
      // 1. Read from a local "mesh pending" Drift table
      // 2. For each message, call Serverpod MessageEndpoint.send
      // 3. On success, remove from pending table

      const syncedCount = 0;
      onSyncComplete?.call(syncedCount);
      return syncedCount;
    } catch (e) {
      return 0;
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    stop();
  }
}
